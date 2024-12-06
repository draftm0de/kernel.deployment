#!/bin/bash
set -e
set -o pipefail

image="${1}"
jq="${2}"
PROPERTY=""
response=$(docker manifest inspect "${image}" 2>/dev/null)
if [ $? -eq 0 ]; then
  echo "> manifest found"
  PROPERTY=$(echo "$response" | jq -r "${jq}")
  if [ "$PROPERTY" == "null" ]; then
    echo "::error::${{ inputs.property }} not found in manifest"
    exit 1
  fi
else
  echo "::error::manifest for ${{ inputs.image }} not found"
fi

export PROPERTY