#!/usr/bin/env bash

set -eEuo pipefail

script="$(basename "${BASH_SOURCE[0]}")"

function usage {
    echo "Usage: $script <env> <path> <fourCharacterId> <documentType> <createdDate>
       where
           env: environment, eg., local, dev, test, or prod
           path: file path of the document to be uploaded
           fourCharacterId: four character Id of the document
           documentType: document type code, eg., ant_000, ant_090, ant_180, ant_270, ...
           createdDate: document created date in format of uuuuMMddTHHmmss, eg., 20200816T103045"
    exit 1
}

if [[ $# -lt 1 ]]; then
    echo "Error: environment is empty."
    usage
elif [[ $1 != "local" && $1 != "dev" && $1 != "test" && $1 != "prod" ]]; then
    echo "Error: invalid environment."
    usage
elif [[ $# -lt 2 ]]; then
    echo "Error: document path is empty."
    usage
elif [[ ! -f $2 ]]; then
    echo "Error: invalid document path."
    usage
elif [[ $# -lt 3 ]]; then
    echo "Error: Four Character Id is empty."
    usage
elif [[ $# -lt 4 ]]; then
    echo "Error: document type is empty."
    usage
elif [[ $# -lt 5 ]]; then
    echo "Error: document created date is empty."
    usage
elif [[ ! $5 =~ ^[0-2][0-9]{3}(0[1-9]|1[012])(0[1-9]|[12][0-9]|3[01])T([01][0-9]|2[0-3])([0-5][0-9]){2}$ ]]; then
    echo "Error: invalid or unsupported datetime format in createdDate."
    usage
fi

env=$1
documentPath=$2
fourCharacterId=$3
documentType=$4
createdDate=$5

if [[ $env == "prod" ]]; then
    gws=https://gws.geodesy.ga.gov.au
    openam=https://${env}geodesy-openam.geodesy.ga.gov.au/openam
elif [[ $env == "local" ]]; then
    gws=http://localhost:8081
    openam=http://localhost:8083/openam
else
    gws=https://${env}geodesy-webservices.geodesy.ga.gov.au
    openam=https://${env}geodesy-openam.geodesy.ga.gov.au/openam
fi

clientId=GnssSiteManager
clientPassword=
username=
password=

jwt=$(curl -s --user ${clientId}:${clientPassword} \
              --data "grant_type=password&username=${username}&password=${password}&scope=openid profile" \
              "${openam}/oauth2/access_token?realm=/" | jq -r .id_token)

curl -X POST -F "file=@${documentPath}" \
             -F "fourCharacterId=${fourCharacterId}" \
             -F "documentType=${documentType}" \
             -F "createdDate=${createdDate}" \
             -F "webServiceHost=${gws}" \
             ${gws}/associatedDocuments/save -H "Authorization: Bearer ${jwt}"

echo "Done in saving document ($documentPath) to sitelog ${fourCharacterId}"
