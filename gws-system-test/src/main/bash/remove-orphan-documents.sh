#!/usr/bin/env bash

set -eEuo pipefail

script="$(basename "${BASH_SOURCE[0]}")"

function usage {
    echo "Usage: $script [-h hoursToKeep] <env>
       where
           -h: hours since last modified time within which orphan documents can be kept
           env: environment, eg., dev, test, or prod"
    exit 1
}

hoursToKeep=12
while [[ $# -gt 0 ]]; do
    case $1 in
        dev|test|prod )
            env=$1
            shift
            ;;
        -h)
            hoursToKeep=$2
            shift 2
            ;;
        * )
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

if [[ -z $env ]]; then
    echo "Error: environment is empty."
    usage
fi

openam=https://${env}geodesy-openam.geodesy.ga.gov.au/openam
if [[ $env == "prod" ]]; then
    gws=https://gws.geodesy.ga.gov.au
else
    gws=https://${env}geodesy-webservices.geodesy.ga.gov.au
fi

clientId=GnssSiteManager
clientPassword=

username=
password=

jwt=$(curl -s --user ${clientId}:${clientPassword} \
              --data "grant_type=password&username=${username}&password=${password}&scope=openid profile" \
              "${openam}/oauth2/access_token?realm=/" | jq -r .id_token)

curl -X DELETE "${gws}/associatedDocuments/removeOrphanDocuments?hoursToKeep=${hoursToKeep}" \
     -H "Authorization: Bearer ${jwt}"
