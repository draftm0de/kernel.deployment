#!/bin/bash
set -e
set -o pipefail

base_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
base_path="$base_path/../../src"
SCRIPT="${base_path}/git/read-commit-tags.sh"

# shellcheck disable=SC1090
# source "${SCRIPT}" "main" "--filter=versioned"
# echo "$TAGS"

# shellcheck disable=SC1090
# source "${SCRIPT}" "--filter=versioned"
# echo "$TAGS"

# shellcheck disable=SC1090
source "${SCRIPT}" "--filter=versioned"
echo "$TAGS"


