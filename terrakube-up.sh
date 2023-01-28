#!/bin/bash

set -eou pipefail

root_dir=$(pwd)
config_file="$root_dir/config/config.dev.tfvars"

cd "$root_dir/init"

terraform init -input=false
terraform plan -var-file "$config_file" -out=tfplan
terraform apply tfplan

cd "$root_dir"

terraform init -input=false
terraform plan -var-file "$config_file" -out=tfplan
terraform apply tfplan
