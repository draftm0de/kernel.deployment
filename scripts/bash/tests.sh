#!/bin/bash
set -e
set -o pipefail
tests=()
#tests+=("converter/explode-docker-image-name")
#tests+=("converter/explode-branch-to-version")
#tests+=("converter/patch-branch")
#tests+=("docker/image-manifest-jq")
#tests+=("git/read-commit-tags")
tests+=("git/read-tags")

for test in "${tests[@]}"; do
  echo "******* ${test} *********"
  script="./tests/${test}.sh"
  # shellcheck disable=SC1090
  source "$script"
done
