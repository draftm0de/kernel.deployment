#!/bin/bash
set -e
set -o pipefail

base_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
base_path="$base_path/../../src"

SCRIPT="${base_path}/converter/increase-branch.sh"
inputs=("1 1.0" "1.2 1.2.3" "v1.2" "v1")

for input in "${inputs[@]}"; do
  # shellcheck disable=SC1090
  # echo "input"
  if [[ "$input" == *" "* ]]; then
    base_branch="${input%% *}"
    latest_branch="${input#* }"
  else
    base_branch="$input"
    latest_branch=""
  fi
  echo "> > latest_branch:$latest_branch:"
  echo "> > base_branch:$base_branch:"
  source "${SCRIPT}" "${base_branch}" "${latest_branch}"
  echo "> > > increased branch: $BRANCH"
done


