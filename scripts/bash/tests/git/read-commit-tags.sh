#!/bin/bash
set -e
set -o pipefail

base_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
base_path="$base_path/../../src"
SCRIPT="${base_path}/git/read-commit-tags.sh"

UnitTest "${SCRIPT}" "1.1.1
1.1
1.0.1
1.0" "main" "--filter=version" "--sort=desc"

UnitTest "${SCRIPT}" "1.0
1.0.1
1.1
1.1.1" "main" "--filter=version" "--sort=asc"

UnitTest "${SCRIPT}" "1.0
1.0.x1
1.0.1
1.1
1.1.1
no.version" "main" "--sort=asc"

UnitTest "${SCRIPT}" "1.0
1.0.x1
1.0.1
1.1
1.1.1
no.version" "--sort=asc"

UnitTest "${SCRIPT}" "{true}" "--sort=asc" "--silent"
UnitTest "${SCRIPT}" "{false}" "unknown" "--sort=asc" "--silent"
