#!/bin/bash
set -e
set -o pipefail

UnitTest() {
  local source source_print expected arguments response
  source="${1}"
  source_print=$(basename $source)
  shift
  expected="${1}"
  shift
  arguments="${*}"
  if [ -n "${debugMode}" ]; then
    # shellcheck disable=SC1090
    response=$(source "${source}" $arguments)
  else
    # shellcheck disable=SC1090
    response=$(source "${source}" $arguments 2>/dev/null)
  fi
  if [ "$response" == "$expected" ]; then
    echo "${source_print} [${arguments}] successful"
  else
    echo "${source_print} [${arguments}] failure (response: $response, expected: $expected)"
  fi
}

scripts=()
#scripts+=("converter/explode-docker-image-name")
scripts+=("converter/branch-to-version")
#scripts+=("converter/patch-branch")
#scripts+=("docker/image-manifest-jq")
#scripts+=("git/read-commit-tags")
scripts+=("git/read-tags")

for script in "${scripts[@]}"; do
  if [ -z "${1}" ] || [ "${1}" == "${script}" ]; then
    echo "-------------------- ${script} --------------------"
    # shellcheck disable=SC1090
    source "./tests/${script}.sh"
  fi
done
