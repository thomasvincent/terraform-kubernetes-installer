#!/bin/bash
root=$(pwd)
config_file=$root/config/config.dev.tfvars

cd $root/init
terraform destroy -var-file $config-file

cd $root
terraform destroy -var-file $config_file
