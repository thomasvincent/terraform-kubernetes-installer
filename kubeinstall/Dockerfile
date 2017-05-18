FROM ubuntu:latest

RUN apt-get update && apt-get install -y \
    apt-transport-https curl && \
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list  && \
    apt-get update && \
# Install docker if you don't have it already.
    apt-get install -y \
    docker-engine kubelet kubeadm kubectl kubernetes-cni
