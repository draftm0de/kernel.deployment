#!/bin/bash
set -e
set -o pipefail

SCRIPT="../../src/git/read-tags.sh"

# shellcheck disable=SC1090
source "${SCRIPT}" "--branch=1"
echo "$TAGS"

# shellcheck disable=SC1090
source "${SCRIPT}" "--branch=1" "--latest"
echo "$TAGS"

# shellcheck disable=SC1090
source "${SCRIPT}" "--list 1.*" "--latest"
echo "$TAGS"
