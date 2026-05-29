#!/bin/bash

set -e

# echo "==> Terraform Init"
# terraform init

echo "==> Terraform Format"
terraform fmt

echo "==> Terraform Validate"
terraform validate
