#!/usr/bin/env bash

set -euo pipefail

gws=http://localhost:8081
openam=http://localhost:8083/openam

clientId=GnssSiteManager
clientPassword=

username=
password=

jwt=$(curl -s --user ${clientId}:${clientPassword} --data "grant_type=password&username=${username}&password=${password}&scope=openid profile" ${openam}/oauth2/access_token?realm=/ | jq -r .id_token)

function removeSiteFromNetwork {
    removeFromNetwork=$(curl -s ${gws}/corsSites?fourCharacterId=${1} | jq -r ._embedded.corsSites[0]._links.removeFromNetwork.href)
    networkId=$(curl -s ${gws}/corsNetworks?name=${2} | jq ._embedded.corsNetworks[0].id)

    if [ "${removeFromNetwork}" = "null" ]; then
        echo "Could not find RemoveFromNetwork href from ${gws}/corsSites?fourCharacterId=${1}"
        return
    fi

    if [ "${networkId}" = "null" ]; then
        echo "Network not found in ${gws}/corsNetworks?name=${2}"
        return
    fi

    curl -X PUT "${removeFromNetwork}?networkId=${networkId}" -H "Authorization: Bearer ${jwt}"
}

removeSiteFromNetwork $1 $2
