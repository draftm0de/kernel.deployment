#!/bin/bash
set -e
set -o pipefail

echo "/docker/image-manifest-jq" 1>&2

image="${1}"
silent=""
for arg in "$@"; do
  case "$arg" in
    --jq=*)
      echo "> arg: $arg" 1>&2
      jq_filter="${arg#*=}"
    ;;
    --silent)
      echo "> arg: $arg" 1>&2
      silent=$arg
    ;;
  esac
done

response=""
if [ -n "${image}" ]; then
  if docker manifest inspect "${image}" &>/dev/null; then
    manifest=$(docker manifest inspect "${image}")
    if [ -n "${jq_filter}" ]; then
      property=$(echo "${manifest}" | jq -r "${jq_filter}")
      if [ "$property" != "null" ]; then
        response="${property}"
      else
        echo "> jq ${jq_filter} in manifest not found" 1>&2
      fi
    else
      response="${manifest}"
    fi
  else
    echo "> manifest $image not found" 1>&2
  fi
else
  echo "> missing #argument manifest" 1>&2
fi

if [ -n "${response}" ]; then
  echo "$response"
else
  if [ -n "${silent}" ]; then
    exit 1
  fi
fi
