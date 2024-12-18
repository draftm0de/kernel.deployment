#!/bin/bash
set -e
set -o pipefail

base_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
base_path="$base_path/../../src"
SCRIPT="${base_path}/git/list-tags.sh"

# debugMode="true"
shTest "${SCRIPT}" "1.1" "--branch=1" "--latest"
shTest "${SCRIPT}" "1.0.3" "--branch=1.0" "--latest"
shTest "${SCRIPT}" "1.0.1
1.0.2
1.0.3" "--branch=1.0"
shTest "${SCRIPT}" "1.0.1
1.0.2
1.0.3" "--branch=1.0" "--sort=asc"
shTest "${SCRIPT}" "1.0.3
1.0.2
1.0.1" "--branch=1.0" "--sort=desc"
shTest "${SCRIPT}" "1.0
1.1" "--branch=1"

content="sha256:1212kjdflkjafk"
git tag -f "2" -m "${content}" >/dev/null
shTest "${SCRIPT}" "${content}" "--message=2"
shTest "${SCRIPT}" "" "--message=3"
git tag -d "2" >/dev/null