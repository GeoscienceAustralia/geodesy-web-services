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
           createdDate: document created date in format of uuuuMMdd, eg., 20200816"
    exit 1
}

function setDocumentDescription {
    case "$1" in
        ant_000)
            description="Antenna North Facing"
            ;;
        ant_090)
            description="Antenna East Facing"
            ;;
        ant_180)
            description="Antenna South Facing"
            ;;
        ant_270)
            description="Antenna West Facing"
            ;;
        ant_sn)
            description="Antenna Serial No"
            ;;
        rec_sn)
            description="Receiver Serial No"
            ;;
        ant_monu)
            description="Antenna Monument"
            ;;
        ant_bldg)
            description="Antenna Building"
            ;;
        ant_roof)
            description="Antenna Roof"
            ;;
        *)
            echo "Unknown document code"
            echo "Valid document code: ant_000, ant_090, ant_180, ant_270, ant_sn, rec_sn, ant_monu, ant_bldg, ant_roof"
            usage
            ;;
    esac
}

if [[ $# -lt 1 ]]; then
    echo "Error: environment is empty."
    usage
elif [[ $1 != dev && $1 != test && $1 != prod ]]; then
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
elif [[ ! $5 =~ ^[0-2][0-9]{3}(0[1-9]|1[012])(0[1-9]|[12][0-9]|3[01])$ ]]; then
    echo "Error: invalid or unsupported datetime format in createdDate."
    usage
else
    env=$1
    documentPath=$2
    fourCharacterId=$3
    documentCode=$4
    createdDate=$5
    setDocumentDescription "$documentCode"
fi

openam=https://${env}geodesy-openam.geodesy.ga.gov.au/openam
if [[ $env == prod ]]; then
    gws=https://gws.geodesy.ga.gov.au
else
    gws=https://${env}geodesy-webservices.geodesy.ga.gov.au
fi

clientId=GnssSiteManager
clientPassword=
username=
password=

jwt=$(curl -s --user $clientId:$clientPassword \
              --data "grant_type=password&username=$username&password=$password&scope=openid profile" \
              "$openam/oauth2/access_token?realm=/" | jq -r .id_token)

inputSiteLogXml=$(curl "$gws/siteLogs/search/findByFourCharacterId?id=$fourCharacterId&format=geodesyml")

if [[ -n $inputSiteLogXml ]]; then
    documentName=${fourCharacterId}_${documentCode}_$createdDate.${documentPath##*.}
    contentType=$(file --mime-type -b "$documentPath")
    createdDateFmt=${createdDate:0:4}-${createdDate:4:2}-${createdDate:6:2}Z

    responseHeader=$(curl -D - -F "file=@$documentPath" \
                               -F "documentName=$documentName" \
                               -H "Authorization: Bearer $jwt" \
                               -X POST "$gws/associatedDocuments/")

    relativeUrl=$(echo "$responseHeader" | grep Location | cut -d' ' -f 2)
    if [[ -z $relativeUrl ]]; then
        echo "Error: failed to upload document $documentPath to s3. Exit."
        exit 2
    fi

    outputSiteLogXml=$(xsltproc --stringparam description "$description" \
                                --stringparam documentName "$documentName" \
                                --stringparam contentType "$contentType" \
                                --stringparam createdDate "$createdDateFmt" \
                                --stringparam fileReference "$gws$relativeUrl" \
                                gws-system-test/src/main/resources/add-associated-document.xslt - \
                                <<< "$inputSiteLogXml" )

    curl -d "$outputSiteLogXml" -H "Authorization: Bearer $jwt" "$gws/siteLogs/upload"
fi
