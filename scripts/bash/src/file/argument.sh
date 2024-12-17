#!/bin/bash
set -e
set -o pipefail

echo "/file/argument.sh" 1>&2

file="${1}"
key="${2}"
if [ "${key:0:1}" == "+" ]; then
  key="${key:1}"
  required="true"
fi

if [ -f "${file}" ]; then
  value=$(grep "^$key=" "$file" | tee /dev/null | cut -d'=' -f2 || true)
else
  echo "> file <${file}> does not exist" 1>&2
  exit 0
fi

if [ -z "${value}" ] && [ -n "${required}" ]; then
  echo "> argument <${key}> in file <${file}> does not exist, or is empty" 1>&2
  exit 0
fi

echo "$value"
