#!/usr/bin/env bash

set -e

script="$(basename "${BASH_SOURCE[0]}")"

function usage {
    echo "Usage: $script [-d|--dry-run] <env>
        where
        -d, --dry-run
            do not run \"terraform apply\"
        env
            deployment environment, eg., dev, test, or prod"
    exit 1
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--dry-run )
            dryRun=true
            shift
            ;;
        dev|test|prod )
            env=$1
            shift
            ;;
        * )
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

if [[ -z $env ]]; then
    echo "Error: deployment environment is empty."
    usage
fi

export TF_VAR_region=$AWS_DEFAULT_REGION
export TF_VAR_environment=$env

cd "$(dirname "$(realpath "$0")")"
cd ..
terraform_workspace="$(pwd)/aws/terraform/workspaces/$env"

pushd aws/terraform
rm -frv terraform.tfstate.d/

terraform init -backend-config="$terraform_workspace/backend.cfg"
terraform workspace select "$env" || terraform workspace new "$env"

if [ -z "$dryRun" ]; then
    terraform apply -auto-approve -input=false
else
    terraform plan -input=false
fi
popd
