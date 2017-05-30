#!/bin/bash

dt=`date +%Y%m%d%H%M%S`
sudo docker build -t cheburakshu/terrakube .
export DOCKER_ID_USER="cheburakshu"
sudo docker login
sudo docker tag cheburakshu/terrakube:latest cheburakshu/terrakube:latest #$dt
sudo docker push $DOCKER_ID_USER/terrakube:latest #$dt
