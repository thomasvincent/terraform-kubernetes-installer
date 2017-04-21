#!/bin/bash
terraform get
terraform plan -var-file config.dev.tfvars
