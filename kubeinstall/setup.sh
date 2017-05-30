#!/bin/bash

# The execution log can be found on the cloud at /var/log/cloud-init-output.log

export SCRIPT_MOUNT_PATH=/var/cache/kubernetes
sudo mkdir -p $SCRIPT_MOUNT_PATH/master/conf
sudo mkdir -p $SCRIPT_MOUNT_PATH/master/services
sudo mkdir -p $SCRIPT_MOUNT_PATH/master/sbin
sudo mkdir -p $SCRIPT_MOUNT_PATH/node/conf
sudo mkdir -p $SCRIPT_MOUNT_PATH/node/services
sudo mkdir -p $SCRIPT_MOUNT_PATH/node/sbin

write_global_env(){
    local -r terrakube_master_subnet=$1
    terrakube_init=/etc/profile.d/terrakube-init.sh
    sudo bash -c "cat <<'EOF' >$terrakube_init
export TERRAKUBE_MASTER_SUBNET=$terrakube_master_subnet
# The export is not visible to the services immediately. So echo here.
echo \$TERRAKUBE_MASTER_SUBNET
EOF"
    chmod +x $terrakube_init
    . $terrakube_init
    echo "Master subnet - " $TERRAKUBE_MASTER_SUBNET
}

ubuntu_install_packages(){
    sudo apt-get update && sudo apt-get install -y apt-transport-https 
    sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
    sudo bash -c "cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF"
    sudo apt-get update
    sudo apt-get install -y docker-engine
    sudo apt-get install -y kubelet kubeadm kubectl kubernetes-cni

#Additional packages

    sudo apt-get update && sudo apt-get install -y nginx jq fcgiwrap python3
    sudo curl -L https://bootstrap.pypa.io/get-pip.py| bash -c "sudo -H python3"
    sudo pip install urllib3[security]
}

kubeadm_init(){
    sudo kubeadm init --token $(sudo kubeadm token generate) 
    export KUBECONFIG=/etc/kubernetes/admin.conf
    sudo chmod a+r /etc/kubernetes/admin.conf
}

weave_kube(){
    kubectl apply -f https://git.io/weave-kube-1.6;
# Standalone weave binary used for resetting nodes. Not used at master
    sudo curl -L git.io/weave -o /usr/local/bin/weave
    sudo chmod a+x /usr/local/bin/weave
}

weave_standalone(){
# Standalone weave binary used for resetting nodes. Not used at master
    sudo curl -L git.io/weave -o /usr/local/bin/weave
    sudo chmod a+x /usr/local/bin/weave
}

copy_scripts(){
    local -r master_subnet=$1
    sudo mkdir -p "${SCRIPT_MOUNT_PATH}/config"
    sudo docker pull cheburakshu/terrakube:latest
    sudo docker run --rm -v "$SCRIPT_MOUNT_PATH":/mnt/kubernetes cheburakshu/terrakube cp -Rfv /kubernetes/. /mnt/kubernetes
    sudo chmod -R a+x $SCRIPT_MOUNT_PATH
}

run_node_services(){
    sudo cp -Rfv $SCRIPT_MOUNT_PATH/node/services/* /lib/systemd/system/
    sudo cp -Rfv $SCRIPT_MOUNT_PATH/node/sbin/* /usr/sbin/
    sudo cp -Rfv $SCRIPT_MOUNT_PATH/k8sDiscovery.py usr/sbin/
    
    sudo service terrakube-node start
}

run_master_services(){
    sudo cp -Rfv $SCRIPT_MOUNT_PATH/master/services/* /lib/systemd/system/
    sudo cp -Rfv $SCRIPT_MOUNT_PATH/master/sbin/* /usr/sbin/
    sudo cp -Rfv $SCRIPT_MOUNT_PATH/master/conf/nginx.conf /etc/nginx/nginx.conf
    sudo cp -Rfv $SCRIPT_MOUNT_PATH/k8sDiscovery.py usr/sbin/
    
    sudo nginx
    sudo service nginx restart
    sudo service terrakube-proxy start
    sudo service terrakube-sync start
}

main(){
    master_subnet=$2
    master_node=$1

    distro=`cat /etc/lsb-release |awk -F"=" '{if ($1 == "DISTRIB_ID") print $2}'`
    if [ $distro == 'Ubuntu' ]; then
        ubuntu_install_packages
    fi

# Write global env variables for terrakube
    write_global_env $2

# If called with a master subnet, initialize the master
    if [ $master_node == "master" ]; then
        kubeadm_init
        weave_kube
    else
        weave_standalone
    fi

# Copy scripts for auto-discovery and disaster recovery

    copy_scripts

# Run master and node services.
   if [ $master_node == "master" ]; then
       run_master_services
   else
       run_node_services
   fi
}


