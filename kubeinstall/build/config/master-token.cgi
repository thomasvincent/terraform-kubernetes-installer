#!/bin/bash

printf "Content-type: text/plain\n\n"


## Send response for kubeadm token
#
kubeadm token list|grep "<never>"|cut -f1 -d" "

