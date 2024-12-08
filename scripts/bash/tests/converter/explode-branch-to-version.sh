#!/bin/bash
set -e
set -o pipefail

base_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
base_path="$base_path/../../src"

SCRIPT="${base_path}/converter/explode-git-branch-to-version.sh"
inputs=("1" "v1" "v1.0" "v1.0.1" "v1.0.1-prod" "DF20241206")

for input in "${inputs[@]}"; do
  # shellcheck disable=SC1090
  source "${SCRIPT}" "${input}"
done