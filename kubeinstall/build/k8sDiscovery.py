#!/usr/bin/python3

import os
import sys
import logging
import subprocess
import shlex
import ipaddress
import multiprocessing
import time
import random
import urllib3
import socket

class discovery(object):

    def __init__(self,cidr,healthz=8000,cgi=8003,master_port=6443,ca_certs=None,master=None):
        logging.getLogger(__name__)
        logging.basicConfig(level=logging.INFO)
        if not ca_certs:
            self.ca_certs = '/etc/kubernetes/pki/ca.crt'
        else:
            self.ca_certs = ca_certs
# urllib3.exceptions.SSLError: hostname '172.20.0.13' doesn't match 'kubernetes'
# Not using certificates until there is an out-of-box support to use the certs because of the above error.
#        self.http = urllib3.PoolManager(cert_reqs='CERT_REQUIRED',ca_certs=self.ca_certs)
        self.http = urllib3.PoolManager(10,cert_reqs='CERT_NONE')
        urllib3.disable_warnings()

        self.cidr = cidr
        self.healthz = healthz
        self.cgi = cgi
        self.master_port = master_port
        self.token = None
        self.master = master

    def start_proxy(self):
        try:
            cmd='kubectl --kubeconfig /etc/kubernetes/admin.conf proxy '
            p=subprocess.run(cmd,shell=True,check=True)
            logging.info('Kube proxy started successfully.')
        except:
            logging.critical('Error in starting kube proxy.'+ str(sys.exc_info()))

    def get_health(self,host):
        try:
            url = 'https://' + host + ':' + str(self.healthz) + '/healthz'
            print(url)
            r = self.http.request('GET',url)
            if r.status == 200 and r.data == b'ok' :  
                return True
            else: 
                return False
        except:
            logging.error('Error in getting master health. ' + str(sys.exc_info()))
            return False

    def healthy_masters(self):
        hosts = self.discover_hosts()
        masters = []
        if hosts:
            for i in hosts:
                host = str(i)
                master_healthy = self.get_health(host)
                if master_healthy:
                    masters.append(host)
        return masters

    def expand_cidr(self,cidr=None):
        if not cidr:
            cidr = self.cidr
        return [x for x in ipaddress.ip_network(cidr).hosts()]

    def run_process_silent(self,cmd,check=False,shell=False):
        res = subprocess.run(cmd,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL,check=check,shell=shell)
        return res

    def run_process(self,cmd,check=False,shell=False):
        res = subprocess.run(cmd,check=check,shell=shell)
        return res

    def ping_host(self,q,host):
        cmd = shlex.split('ping -c1 -w1 '+str(host))
        res = self.run_process_silent(cmd)

        if res.returncode == 0:
            q.put(host)

    def discover_hosts(self,hosts=None):
        if not hosts:
            hosts = self.expand_cidr()
        q = multiprocessing.Queue()
        for i in hosts:
            p = multiprocessing.Process(target=self.ping_host,args=(q,i,))
            p.start()
        p.join()
        while q.qsize() > 0 :
            yield(q.get())
        
    def stop_proxy(self):
        try:
            cmd = 'ps -ef |grep "kubectl.*proxy"|grep -v grep|awk \'{print $2}\''
            pid = subprocess.run(cmd,stdout=subprocess.PIPE,shell=True)
        
            if pid.stdout:
                cmd = 'sudo kill -9 {}'.format(int(pid.stdout))
                res = subprocess.run(cmd,shell=True,check=True)
                logging.info('Kube proxy stopped successfully')
            else:
                logging.info('Kube proxy not running')
        except:
            logging.critical('Error in stopping Kube proxy'+ str(sys.exc_info()))
    
    def stop_kubelet(self):
        try:
            cmd = shlex.split("sudo service kubelet stop")
            self.run_process(cmd)
        except:
            logging.critical('Error in stopping Kubelet ' + str(sys.exc_info()))

        try:
            cmd = 'kubelet_pid=$(lsof -i :10250 |grep "10250"|grep -v grep|awk \'{print $2}\')'
            pid = subprocess.run(cmd,stdout=subprocess.PIPE,shell=True)

            if pid.stdout:
                cmd = 'sudo kill -9 {}'.format(int(pid.stdout))
                res = subprocess.run(cmd,shell=True,check=True)
                logging.info('Kubelet stopped successfully')
            else:
                logging.info('Kubelet not running')
        except:
            logging.critical('Error in stopping Kubelet ' + str(sys.exc_info()))
            raise


    def get_token(self,host):
        try:
            url = 'https://' + str(host) + ':' + str(self.cgi) + '/config/master-token.cgi'
            r = self.http.request('GET',url)
            if (r.status == 200):
                return r.data.strip().decode('utf-8')
        except:
            logging.error('Error in getting master token. ' + str(sys.exc_info()))
    
    def get_master_ips(self,host):
#
# Get list of all ips registered with a master. The master ip will also be returned.
#        
        try:
            url = 'https://' + str(host) + ':' + str(self.cgi) + '/config/master-ips.cgi'
            r = self.http.request('GET',url)
            if (r.status == 200):
                return (r.data.decode('utf-8').strip().split(','))
        except:
            logging.error('Error in getting master IPs. ' + str(sys.exc_info()))
            return []

    def get_master_resources(self):
        healthy_masters = self.healthy_masters()
        if healthy_masters:
            for i in healthy_masters:
                url='https://' + str(i) + ':' + str(self.cgi) + '/config/master-res.cgi'
                try:
                    r = self.http.request('GET',url,timeout=2)
                    data = r.data.decode('utf-8').strip()
                    if (r.status == 200 and data):
                        yield((str(i),data))
                except:
                    logging.warn('Error in GET - ' + url+ str(sys.exc_info()))

    def get_master_namespace(self):
        master_resources = self.get_master_resources() 
        if master_resources:
            for i in master_resources:
                host = i[0]
                resources = i[1]
                url = 'https://' + host + ':' + str(self.cgi) + '/config/master-ns.cgi'
                try:
                    r = self.http.request('GET',url,timeout=2)
                    data = r.data.decode('utf-8').strip()
                    if (r.status == 200 and data):
                        yield((host,resources,data))
                except:
                    logging.warn('Error in GET - ' + url+ str(sys.exc_info()))

    
    def write_config_files(self):
        namespaces = self.get_master_namespace()
        if namespaces:
            for i in self.get_master_namespace():
                cmd='sudo bash -c \'cat <<\'EOF\' > /var/cache/kubernetes/config/' + i[0] + '.namespaces.conf' + '\n' + i[2] + '\n' + 'EOF\''
                self.run_process(cmd,shell=True)
                cmd='sudo bash -c \'cat <<\'EOF\' > /var/cache/kubernetes/config/' + i[0] + '.resources.conf' + '\n' + i[1] + '\n' + 'EOF\''
                self.run_process(cmd,shell=True)
                yield(i)

    def sync_master(self):
        config_files = self.write_config_files()
        if config_files:
            for i in config_files:
                for name in ['namespaces','resources']:
                    cmd=shlex.split('kubectl --kubeconfig /etc/kubernetes/admin.conf create -f /var/cache/kubernetes/config/' + i[0] + '.' + name + '.conf')
                    self.run_process(cmd)

    def reset_node(self):
        for name in ['kubeadm','weave']:
            cmd = shlex.split('sudo ' + name + ' reset')
            self.run_process(cmd)
            logging.info(name + ' reset successful')

    def leave_master(self):
        self.reset_node()
        self.stop_kubelet()
        self.master = None

    def join_master(self):
        healthy_masters = self.healthy_masters()
        print('healthymasters',list(healthy_masters))
        if healthy_masters:
            print('healthy',healthy_masters)
            for master in list(healthy_masters):
                print('host',master)
                try:
                    master_healthy = self.get_health(master)
                    print(master,master_healthy)
                    node_on_master = self.check_node_ip_on_master(master)
                    print('node on master', node_on_master)
                    if master and master_healthy:
                        if node_on_master:
                            break
                        try:
                            self.token = self.get_token(master)
                            print(self.token,master)
                            cmd = shlex.split('sudo kubeadm join --token ' + self.token + ' ' + master + ':' + str(self.master_port))
                            self.run_process(cmd,check=True)
                            self.master = master
                            logging.info('Joined master ' + master)
                            break
                        except:
                            logging.warn('Error in joining master - ' + master + '.' + str(sys.exc_info()))
                    else:
                        logging.info('Host ' + master + ' is un-healthy. Trying next available master')
                        self.leave_master()
                except:
                    logging.warn('Host ' + master + ' is un-healthy. Trying next available master' + '.' + str(sys.exc_info()))
                
    def monitor_master(self):
        while True:
# Check if the attached master is still healthy
            master_healthy = False
            if self.master:
                try:
                    master_healthy = self.get_health(self.master)
                except:
                    logging.critical('Master - ' + self.master + ' is un-healthy at ' + str(time.ctime()) + '.' + str(sys.exc_info()))
                    master_healthy = False

            if self.master and master_healthy:
                logging.info('Master - ' + self.master + ' is healthy at ' + str(time.ctime()))
                pass  
            else:
                try:
                    if self.master:
                        self.leave_master()
                    print('joining master')
                    self.join_master()
                except:
                    logging.error('Error in joining new master.' + '.' + str(sys.exc_info()))
            time.sleep(10)    
            
    def find_master_ip(self,master_ips,cidr=None):
#
#    Get the master ip from list of ips on master.
#
        if not cidr:
            cidr = self.cidr

        for ip in master_ips:
             if ipaddress.IPv4Address(ip) in ipaddress.IPv4Network(cidr):
                 return ip

    def check_node_ip_on_master(self,host):
        local_ip = socket.gethostbyname(socket.gethostname())
        master_ips = self.get_master_ips(host)
        if local_ip in master_ips:
            return True
        else:
            return False

    def node_bootstrap(self):
#
#   Bootstrap a node. This will be triggered through a daemon and will
#   handle machine launches and reboots
#

# Find the machine's private ip
        local_ip = socket.gethostbyname(socket.gethostname())
        master_ips = []
        hosts = self.discover_hosts()
        if hosts:
            for host in hosts:
                master_ips = self.get_master_ips(host)
                if local_ip in master_ips:
# Set the master ip for this node if it is already registered w/ a master.
                    self.master = self.find_master_ip(master_ips)
                    break
        self.monitor_master()

#d=discovery('172.20.0.0/28')
