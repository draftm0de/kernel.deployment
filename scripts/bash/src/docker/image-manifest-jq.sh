#!/bin/bash
set -e
set -o pipefail

image="${1}"
jq="${2}"
PROPERTY=""
response=$(docker manifest inspect "${image}" 2>/dev/null)
if [ $? -eq 0 ]; then
  PROPERTY=$(echo "$response" | jq -r "${jq}")
  if [ "$PROPERTY" == "null" ]; then
    echo "::warning::${jq} in manifest not found"
    exit 1
  fi
else
  echo "::warning::manifest for ${image} not found"
fi

export PROPERTY