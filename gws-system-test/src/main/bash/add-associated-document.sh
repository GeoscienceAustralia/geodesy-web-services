#!/usr/bin/env bash

set -eEuo pipefail

script="$(basename "${BASH_SOURCE[0]}")"

function usage {
    echo "Usage: $script <env> <path> <fourCharacterId> <documentCode> <createdDate>
       where
           env: environment, eg., dev, test, or prod
           path: file path of the document to be uploaded
           fourCharacterId: four character Id of the document
           documentCode: document code, eg., ant_000, ant_090, ant_180, ant_270, ...
           createdDate: document created date in format of uuuuMMddTHHmmss, eg., 20200816T103045"
    exit 1
}

function validateDocumentCode {
    description=
    if [[ $1 == "ant_000" ]]; then
        description="Antenna North Facing"
    elif [[ $1 == "ant_090" ]]; then
        description="Antenna East Facing"
    elif [[ $1 == "ant_180" ]]; then
        description="Antenna South Facing"
    elif [[ $1 == "ant_270" ]]; then
        description="Antenna West Facing"
    elif [[ $1 == "ant_sn" ]]; then
        description="Antenna Serial No"
    elif [[ $1 == "rec_sn" ]]; then
        description="Receiver Serial No"
    elif [[ $1 == "ant_monu" ]]; then
        description="Antenna Monument"
    elif [[ $1 == "ant_bldg" ]]; then
        description="Antenna Building"
    elif [[ $1 == "ant_roof" ]]; then
        description="Antenna Roof"
    else
        echo "Unknown document code"
        echo "Valid document code: ant_000, ant_090, ant_180, ant_270, ant_sn, rec_sn, ant_monu, ant_bldg, ant_roof"
        usage
    fi
}

if [[ $# -lt 1 ]]; then
    echo "Error: environment is empty."
    usage
elif [[ $1 != "dev" && $1 != "test" && $1 != "prod" ]]; then
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
    echo "Error: document code is empty."
    usage
elif [[ $# -lt 5 ]]; then
    echo "Error: document created date is empty."
    usage
elif [[ ! $5 =~ ^[0-2][0-9]{3}(0[1-9]|1[012])(0[1-9]|[12][0-9]|3[01])T([01][0-9]|2[0-3])([0-5][0-9]){2}$ ]]; then
    echo "Error: invalid or unsupported datetime format in createdDate."
    usage
else
    env=$1
    documentPath=$2
    fourCharacterId=$3
    documentCode=$4
    createdDate=$5
    validateDocumentCode "${documentCode}"
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

inputSiteLogXml=/tmp/sitelog_input.xml
curl "${gws}/siteLogs/search/findByFourCharacterId?id=${fourCharacterId}&format=geodesyml" > ${inputSiteLogXml}

if [[ -f ${inputSiteLogXml} ]]; then
    documentName="${fourCharacterId}_${documentCode}_${createdDate}.${documentPath##*.}"
    contentType=$(file --mime-type -b "$documentPath")
    createdDateFmt="${createdDate:0:4}-${createdDate:4:2}-${createdDate:6:5}:${createdDate:11:2}:${createdDate:13:2}.000Z"
    fileReference="${gws}/associatedDocuments/${documentName}"

    curl -X POST -F "file=@${documentPath}" \
                 -F "documentName=${documentName}" \
                 -H "Authorization: Bearer ${jwt}" \
                 "${gws}/associatedDocuments/"

    outputSiteLogXml=$(xsltproc --stringparam description "$description" \
                                --stringparam documentName "$documentName" \
                                --stringparam contentType "$contentType" \
                                --stringparam createdDate "$createdDateFmt" \
                                --stringparam fileReference "$fileReference" \
                                gws-system-test/src/main/resources/add-associated-document.xslt \
                                ${inputSiteLogXml})

    curl --data "${outputSiteLogXml}" "${gws}/siteLogs/upload" -H "Authorization: Bearer ${jwt}"
    rm ${inputSiteLogXml}
fi
