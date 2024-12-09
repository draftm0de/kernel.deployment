#!/bin/bash
set -e
set -o pipefail

scripts=()
#scripts+=("converter/explode-docker-image-name")
#scripts+=("converter/explode-branch-to-version")
#scripts+=("converter/patch-branch")
#scripts+=("docker/image-manifest-jq")
scripts+=("git/read-commit-tags")
#scripts+=("git/read-tags")

for script in "${scripts[@]}"; do
  if [ -z "${1}" ] || [ "${1}" == "${script}" ]; then
  # shellcheck disable=SC1090
  source "./tests/${script}.sh"
  fi
done
