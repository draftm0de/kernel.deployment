#!/bin/bash
set -e
set -o pipefail

source "./src/bashunit.sh"

main_tags=("1.0" "1.0.1" "1.0.x1" "1.1" "1.1.1" "no.version")

scripts=()
scripts+=("converter/branch-to-version")
scripts+=("git/read-tags")
scripts+=("git/read-commit-tags")
scripts+=("docker/image-name-explode")
#scripts+=("converter/explode-docker-image-name")
#scripts+=("converter/patch-branch")
#scripts+=("docker/image-manifest-jq")

#scripts=("git/read-commit-tags")

UnitTests

