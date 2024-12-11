#!/bin/bash
set -e
set -o pipefail

base_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
base_path="$base_path/../../src"
SCRIPT="${base_path}/git/read-commit-tags.sh"

shTest "${SCRIPT}" "1.1.1
1.1
1.0.1
1.0" "main" "--filter=version" "--sort=desc"

shTest "${SCRIPT}" "1.0
1.0.1
1.1
1.1.1" "main" "--filter=version" "--sort=asc"

shTest "${SCRIPT}" "1.0
1.0.x1
1.0.1
1.1
1.1.1
no.version" "main" "--sort=asc"

shTest "${SCRIPT}" "1.0
1.0.x1
1.0.1
1.1
1.1.1
no.version" "--sort=asc"

shTest "${SCRIPT}" "{true}" "--sort=asc" "--silent"
shTest "${SCRIPT}" "{false}" "unknown" "--sort=asc" "--silent"
