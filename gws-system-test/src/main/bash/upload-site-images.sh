#!/usr/bin/env bash

set -eEuo pipefail

script="$(basename "${BASH_SOURCE[0]}")"
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

function usage {
    echo "Usage: $script <env> <path>
       where
           env: environment, eg., dev, test, or prod
           path: file path of the document to be uploaded"
    exit 1
}

if [[ $# -lt 1 ]]; then
    echo "Error: environment is empty."
    usage
elif [[ $1 != dev && $1 != test && $1 != prod ]]; then
    echo "Error: invalid environment."
    usage
elif [[ $# -lt 2 ]]; then
    echo "Error: image path is empty."
    usage
elif [[ ! -d $2 ]]; then
    echo "Error: invalid image path."
    usage
else
    env=$1
    imageHome=$2
fi

count=0
for imagePath in $( find "$imageHome" -type f ); do
    contentType=$(file --mime-type -b "$imagePath")
    if [[ "$contentType" =~ image/* || "$contentType" =~ bitmap/* ]]; then
        createdDate=$(date --utc +"%Y%m%dT%H%M%S" -r "$imagePath")
        imageName=${imagePath##*/}
        fourCharacterId=$(echo imageName | cut -d '_' -f 1)
        instrument=$(echo $imageName | cut -d '_' -f 2)
        direction=$(echo $imageName | cut -d '_' -f 3)
        imageCode=${instrument}_${direction}
        if [[ $imageCode =~ "^ant_(000|090|180|270)$" ]]; then
            continue
        fi

        count=$((count + 1))
        echo "\n $count. Uploading $imagePath"
        $script_dir/add-associated-document.sh $env $imagePath $fourCharacterId $imageCode $createdDate
    fi
done
echo "Number of images uploaded: $count"
