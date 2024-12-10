#!/bin/bash
set -e
set -o pipefail

base_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
base_path="$base_path/../../src"
SCRIPT="${base_path}/converter/branch-to-version.sh"

UnitTest "${SCRIPT}" "1" "1"
UnitTest "${SCRIPT}" "v1" "v1"
UnitTest "${SCRIPT}" "v1.2" "v1.2"
UnitTest "${SCRIPT}" "v1.2.3" "v1.2.3"
UnitTest "${SCRIPT}" "v1.2.3-prod" "v1.2.3-prod"
UnitTest "${SCRIPT}" "" "DF20241210"
UnitTest "${SCRIPT}" "v1.2.3" "v1.2.3" "--contains=v1.2"
UnitTest "${SCRIPT}" "" "v1.2.3" "--contains=v1.3"
UnitTest "${SCRIPT}" "v1.2.*" "v1.2.3" "--format=tag-list"
UnitTest "${SCRIPT}" "v1.2.*-prod" "v1.2.3-prod" "--format=tag-list"
UnitTest "${SCRIPT}" "v1.*-prod" "v1.2-prod" "--format=tag-list"

