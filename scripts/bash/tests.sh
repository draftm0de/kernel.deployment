#!/bin/bash
set -e
set -o pipefail

source "./src/shunit.sh"

main_tags=("1.0" "1.0.1" "1.0.x1" "1.1" "1.1.1" "no.version")

scripts=()
scripts+=("converter/branch-to-version")
scripts+=("converter/patch-version")
scripts+=("docker/image-name-explode")
#scripts+=("docker/image-manifest")
scripts+=("git/read-tags")
scripts+=("git/read-commit-tags")

scripts=("docker/image-name-explode")

shTests
