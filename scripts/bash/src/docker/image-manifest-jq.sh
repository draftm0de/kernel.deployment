#!/bin/bash
set -e
set -o pipefail

image="${1}"
jq_filter="${2}"
PROPERTY=""
if docker manifest inspect "${image}" &>/dev/null; then
  response=$(docker manifest inspect "${image}" | jq -r "${jq_filter}")
  if [ "$response" != "null" ]; then
    PROPERTY="${response}"
  fi
fi
export PROPERTY