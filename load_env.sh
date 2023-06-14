#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ENV_FILEPATH="$SCRIPT_DIR/.env"

if [ ! -f "$ENV_FILEPATH" ]; then  # if a .env file exits
    echo "$ENV_FILEPATH not found. Please create it from .env.sample"
    exit 1
fi

echo "Exporting varaibles in .env file into environment"
read -ra args < <(grep -v '^#' "$ENV_FILEPATH" | xargs)
export "${args[@]}"
