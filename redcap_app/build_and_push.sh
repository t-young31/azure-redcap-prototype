#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )


function unzip_redcap_zip_file(){   # e.g. redcap13.7.0.zip -> redcap/

    number_of_redcap_zip_files=$(ls redcap*.zip | wc -l)
    if [ ! "$number_of_redcap_zip_files" = "1" ]; then
        echo "Expecting a single redcap .zip file. Found: ${number_of_redcap_zip_files}"
        exit 1
    fi

    redcap_zip_filename=$(ls redcap*.zip)

    echo -n "Unzipping..."
    unzip -oq "${redcap_zip_filename}" -d tmp && mv tmp/redcap/ . && rm -rf tmp
    echo "done"
}

cd "$SCRIPT_DIR"
if [ ! -d "redcap/" ]; then
    unzip_redcap_zip_file
fi
az acr login --name "${ACR_NAME}"  # ensure we're logged in to the ACR

# e.g REDCAP_IMAGE_PATH=acryourname.azurecr.io/repository/redcap
docker build -t "${REDCAP_IMAGE_PATH}" .
#docker push "${REDCAP_IMAGE_PATH}"
