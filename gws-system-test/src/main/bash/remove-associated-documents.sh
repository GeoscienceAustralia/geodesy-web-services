#!/usr/bin/env bash

set -euo pipefail

gws=http://localhost:8081
openam=http://localhost:8083/openam

clientId=GnssSiteManager
clientPassword=

username=
password=

jwt=$(curl -s --user ${clientId}:${clientPassword} --data "grant_type=password&username=${username}&password=${password}&scope=openid profile" ${openam}/oauth2/access_token?realm=/ | jq -r .id_token)
curl -X DELETE "${gws}/associatedDocuments/$1" -H "Authorization: Bearer ${jwt}"
