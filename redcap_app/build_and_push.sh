#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "$SCRIPT_DIR"

az acr login --name "${ACR_NAME}"  # ensure we're logged in

# e.g acryourname.azurecr.io/repository/redcap
docker build -t "${REDCAP_IMAGE_PATH}" .
docker push "${REDCAP_IMAGE_PATH}"
