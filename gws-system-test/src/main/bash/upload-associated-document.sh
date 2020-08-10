#!/usr/bin/env bash

set -eEuo pipefail

script="$(basename "${BASH_SOURCE[0]}")"

function usage {
    echo "Usage: $script <env> <document-path> <document-name> <description> <created-date>
       where
           env: environment, eg., dev, test, or prod
           document-path: file path of the document to be uploaded
           document-name: document name
           description: document description
           created-date: document created date"
    exit 1
}

env=
documentPath=
documentName=
description=
createdDate=

if [[ $# -lt 1 ]]; then
    echo "Error: environment is empty."
    usage
elif [[ $1 != "dev" && $1 != "test" && $1 != "prod" ]]; then
    echo "Error: invalid environment."
    usage
else
    env=$1
fi

if [[ $# -lt 2 ]]; then
    echo "Error: document path is empty."
    usage
elif [[ ! -f $2 ]]; then
    echo "Error: invalid document path."
    usage
else
    documentPath=$2
fi

if [[ $# -lt 3 ]]; then
    echo "Error: document name is empty."
    usage
else
    documentName=$3
fi

if [[ $# -lt 4 ]]; then
    echo "Error: document description is empty."
    usage
else
    description=$4  #$(echo "$4" | sed 's/ /%20/g')
fi

if [[ $# -lt 5 ]]; then
    echo "Error: document created date is empty."
    usage
else
    createdDate=$5
fi

openam=https://${env}geodesy-openam.geodesy.ga.gov.au/openam
if [[ $env == "prod" ]]; then
    gws=https://gws.geodesy.ga.gov.au
elif [[ $env == "local" ]]; then
    openam=http://localhost:8083/openam
    gws=http://localhost:8081
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

if ! curl -X POST -F "file=@${documentPath}" ${gws}/associatedDocuments/ -H "Authorization: Bearer ${jwt}";
then
    echo "Failed to upload ${documentPath} to s3, skip saving metadata."
elif curl -X POST -F "name=${documentName}" \
                  -F "description=${description}" \
                  -F "contentType=image/${documentName##*.}" \
                  -F "createdDate=${createdDate}" \
                  ${gws}/associatedDocuments/save -H "Authorization: Bearer ${jwt}";
then
    echo "${documentPath} has been uploaded to s3 and saved to database"
else
    echo "Failed to save document ($documentName) metadata to database"
fi
