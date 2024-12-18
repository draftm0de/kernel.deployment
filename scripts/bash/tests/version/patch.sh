#!/bin/bash
set -e
set -o pipefail

base_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
base_path="$base_path/../../src"
SCRIPT="${base_path}/version/patch.sh"

#debugMode="true"
shTest "${SCRIPT}" "1.0.4
1.0
1" "1.0.3"
shTest "${SCRIPT}" "3.0.0
3.0
3" "3"
shTest "${SCRIPT}" "3.3.0
3.3
3" "3.3"
shTest "${SCRIPT}" "1.0.4
1.0" "1.0.3" "--previous=1.1"
shTest "${SCRIPT}" "1.1.2
1.1
1" "1.1.1" "--previous=1.1"
shTest "${SCRIPT}" "{false}" "1x.1" "--silent"
shTest "${SCRIPT}" "{true}" "1.1" "--silent"
