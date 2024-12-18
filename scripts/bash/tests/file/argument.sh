#!/bin/bash
set -e
set -o pipefail

base_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
base_path="$base_path/../../src"
SCRIPT="${base_path}/file/argument.sh"

#debugMode="true"
shTest "${SCRIPT}" "{false}" "invalid-filename" "key"

file="argument.test"
value="12"
key="TEST"
echo "${key}=${value}" > ${file}
shTest "${SCRIPT}" "${value}" "${file}" "${key}"
shTest "${SCRIPT}" "" "${file}" "key"
shTest "${SCRIPT}" "{false}" "${file}" "+key"
rm $file
