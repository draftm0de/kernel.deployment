#!/bin/bash
set -e
set -o pipefail

base_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
base_path="$base_path/../../src"
SCRIPT="${base_path}/version/patch.sh"

#debugMode="true"
shTest "${SCRIPT}" "1.1" "1"
shTest "${SCRIPT}" "1.1.1" "1.1"
shTest "${SCRIPT}" "1.2.1" "1.2" "--latest="
shTest "${SCRIPT}" "1.1.4" "1.1" "--latest=1.1.3"
shTest "${SCRIPT}" "1.2.1" "1.2" "--latest=1.1.3"
shTest "${SCRIPT}" "1.2.6" "1.2.5" "--latest=1.1.3"
shTest "${SCRIPT}" "" "1" "--latest=2.1"
shTest "${SCRIPT}" "" "1.1" "--latest=1.2.1"
