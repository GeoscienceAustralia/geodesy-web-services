#!/usr/bin/env bash

set -e

gws=http://localhost:8081
openam=http://localhost:8083/openam

clientId=GnssSiteManager
clientPassword=

username=
password=

jwt=$(curl -s --user ${clientId}:${clientPassword} --data "grant_type=password&username=${username}&password=${password}&scope=openid profile" ${openam}/oauth2/access_token?realm=/ | jq .id_token | tr -d '"')
curl -X POST "${gws}/associatedDocuments/add/" -F "name=$1;image=@$2" -H "Content-Type: multipart/form-data"  -H "Authorization: Bearer ${jwt}"
