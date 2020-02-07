#!/bin/bash
set -e

terraform init
terraform validate
terraform apply -var-file terraform.tfvars -auto-approve=true