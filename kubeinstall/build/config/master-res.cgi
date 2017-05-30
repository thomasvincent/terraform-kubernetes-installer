#!/bin/bash

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


## Send response for resources
#

for ns in `echo "$k8_ns"|jq -r '.metadata.name'`; do
    kubectl --kubeconfig /etc/kubernetes/admin.conf --namespace=$ns get --export -o=json svc,rc,secrets,ds | \
    jq '.items[] |
        select(.type!="kubernetes.io/service-account-token") |
        del(
            .spec.clusterIP,
            .metadata.uid,
            .metadata.selfLink,
            .metadata.resourceVersion,
            .metadata.creationTimestamp,
            .metadata.generation,
            .status,
            .spec.template.spec.securityContext,
            .spec.template.spec.dnsPolicy,
            .spec.template.spec.terminationGracePeriodSeconds,
            .spec.template.spec.restartPolicy
        )'
done


if [ $? -ne 0 ]; then
    exit 1
fi
