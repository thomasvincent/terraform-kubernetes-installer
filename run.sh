#!/bin/bash
root=$(pwd)
config_file=$root/config/config.dev.tfvars

cd $root/init
rm terraform.tfstate
terraform get
terraform plan -var-file $config_file
terraform apply -var-file $config_file

cd $root
terraform get
terraform plan -var-file $config_file
terraform apply -var-file $config_file
