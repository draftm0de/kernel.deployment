#!/bin/bash
set -e
set -o pipefail

base_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
base_path="$base_path/../../src"

SCRIPT="${base_path}/git/read-tags.sh"

# shellcheck disable=SC1090
source "${SCRIPT}" "--branch=1"
echo "TAGS:$TAGS"

# shellcheck disable=SC1090
source "${SCRIPT}" "--branch=1" "--latest"
echo "TAGS:$TAGS"

# shellcheck disable=SC1090
source "${SCRIPT}" "--list 1.*" "--latest"
echo "TAGS:$TAGS"
