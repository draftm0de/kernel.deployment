#!/bin/bash
set -e
set -o pipefail
tests=()
tests+=("converter/explode-docker-image-name")
tests+=("converter/explode-git-branch-to-version")
tests+=("docker/image-manifest-jq")

for test in "${tests[@]}"; do
  echo "******* ${test} *********"
  script="./tests/${test}.sh"
  # shellcheck disable=SC1090
  source "$script"
done
