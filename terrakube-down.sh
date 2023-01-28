#!/bin/bash

set -eou pipefail

root_dir=$(pwd)
config_file="$root_dir/config/config.dev.tfvars"

cd "$root_dir/init"

terraform init -input=false
terraform destroy -var-file "$config_file" -auto-approve

cd "$root_dir"

terraform init -input=false
terraform destroy -var-file "$config_file" -auto-approve
