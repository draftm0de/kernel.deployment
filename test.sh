#!/bin/bash
set -e
set -o pipefail
source_minor="2"
target_minor="1"

if [ -n "${source_minor}" ] && [ -n "${target_minor}" ] && (( ${source_minor} > ${target_minor} )); then
  echo "::error::> source minor version is greater than target minor version"
fi