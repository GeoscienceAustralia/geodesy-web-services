#!/usr/bin/env bash

set -eE

script="$(basename "${BASH_SOURCE[0]}")"

function usage {
    echo "Usage: $script"
    exit 1
}

if [[ $# -gt 0 ]]; then
    echo "No argument excepted"
    usage
fi

environment="local"
export TF_VAR_region=$AWS_DEFAULT_REGION
export TF_VAR_environment=$environment

cd "$(dirname "$(realpath "$0")")"
cd ../

pushd aws/terraform
rm -frv terraform.tfstate.d/$environment/terraform.tfstate
rm -frv .terraform

cat > main_override.tf << EOF
terraform {
  required_version = "~> 0.12.0"
  backend "local" {}
}

provider "aws" {
  version = "~> 2.22.0"
  s3_force_path_style = true
  endpoints {
    s3 = "http://localhost:4572"
  }
}
EOF

terraform init
terraform workspace select $environment || terraform workspace new $environment
terraform apply -auto-approve -input=false

function onExit {
    rm -f main_override.tf
}

onExit
trap onExit ERR
trap "onExit; exit 1" SIGINT
popd
