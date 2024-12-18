#!/bin/bash
set -e
set -o pipefail

source "./src/shunit.sh"

main_tags=("1.0" "1.0.1" "1.0.x1" "1.1" "1.1.1" "no.version")
scripts=()
scripts+=("./tests/version/read.sh")
shTests
exit 0

SCRIPT="src/version/read.sh"
shTest "${SCRIPT}" "1" "1"
shTest "${SCRIPT}" "{true}" "1" "--silent"
shTest "${SCRIPT}" "{false}" "1prod" "--silent"
shTest "${SCRIPT}" "v1" "v1"
shTest "${SCRIPT}" "v1.2" "v1.2"
shTest "${SCRIPT}" "v1.2.3" "v1.2.3"
shTest "${SCRIPT}" "v1.2.3-prod" "v1.2.3-prod"
shTest "${SCRIPT}" "" "DF20241210"
shTest "${SCRIPT}" "v1.2.3" "v1.2.3" "--contains=v1.2"
shTest "${SCRIPT}" "" "v1.2.3" "--contains=v1.3"
shTest "${SCRIPT}" "v1.2.*" "v1.2" "--format=tag-list"
shTest "${SCRIPT}" "v1.2.*-prod" "v1.2-prod" "--format=tag-list"
shTest "${SCRIPT}" "v1.*-prod" "v1-prod" "--format=tag-list"
shTest "${SCRIPT}" "v1-prod" "v1-prod" "--expect=major"
shTest "${SCRIPT}" "" "v1.2-prod" "--expect=major"
shTest "${SCRIPT}" "v1.2-prod" "v1.2-prod" "--expect=minor"

teardown