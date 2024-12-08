#!/bin/bash
set -e
set -o pipefail

base_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
base_path="$base_path/../../src"

SCRIPT="${base_path}/git/read-commit-tags.sh"

commit="main"
filter="--filter=versioned"
# shellcheck disable=SC1090
source "${SCRIPT}" "${commit}" "${filter}"
echo "TAGS:$TAGS"

commit=""
filter="--filter=versioned"
# shellcheck disable=SC1090
source "${SCRIPT}" "${commit}" "${filter}"
echo "TAGS:$TAGS"

commit=""
filter=""
# shellcheck disable=SC1090
source "${SCRIPT}" "${commit}" "${filter}"
echo "TAGS:$TAGS"


