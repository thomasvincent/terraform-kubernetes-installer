#!/bin/bash

# FCGI Server endpoint - :8003/config/master-ns.cgi
# Requirements - jq, fcgiwrap packages

printf "Content-type: text/plain\n\n"

k8_ns="$(kubectl --kubeconfig /etc/kubernetes/admin.conf get --export -o=json ns | \
jq '.items[] |
        select(.metadata.name!="kube-system") |
        select(.metadata.name!="default") |
        del(.status,
        .metadata.uid,
        .metadata.selfLink,
        .metadata.resourceVersion,
        .metadata.creationTimestamp,
        .metadata.generation
    )')"

if [ $? -ne 0 ]; then
    exit 1
fi
#
# Send response for namespaces
echo "$k8_ns"

