#!/bin/bash

printf "Content-type: text/json\n\n"


## Send response for resources
#
kubectl --kubeconfig /etc/kubernetes/admin.conf get nodes -o wide |grep " Ready " | awk '{print $1}'|sed -e 's/ip-//g' -e 's/-/./g'|sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/,/g' -e 's/"//g'

#curl -L http://localhost:8001/api/v1/nodes|jq '.items[].status.addresses[]|select (.type=="InternalIP")|.address'|sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/,/g' -e 's/"//g'

