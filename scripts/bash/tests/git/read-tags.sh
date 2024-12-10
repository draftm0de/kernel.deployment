#!/bin/bash
set -e
set -o pipefail

base_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
base_path="$base_path/../../src"
SCRIPT="${base_path}/git/read-tags.sh"

# debugMode="true"
UnitTest "${SCRIPT}" "1.1" "--branch=1" "--latest"
UnitTest "${SCRIPT}" "1.0.3" "--branch=1.0" "--latest"
UnitTest "${SCRIPT}" "1.1" "--list 1.*" "--latest"
UnitTest "${SCRIPT}" "1.0
1.0.1
1.0.3
1.0x3
1.1" "--list 1.*"

