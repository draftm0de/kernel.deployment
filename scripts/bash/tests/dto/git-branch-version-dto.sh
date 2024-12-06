#!/bin/bash
set -e
set -o pipefail

base_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
base_path="$base_path/../../src"

SCRIPT="${base_path}/dto/git-branch-version-dto.sh"
INPUT="1"
# shellcheck disable=SC1090
source "${SCRIPT}" "${INPUT}"
echo "> > ${INPUT}"
echo "PREFIX:$PREFIX"
echo "MAJOR:$MAJOR"
echo "MINOR:$MINOR"
echo "PATCH:$PATCH"
echo "POSTFIX:$POSTFIX"
echo "BRANCH:$BRANCH"

INPUT="v1"
# shellcheck disable=SC1090
source "${SCRIPT}" "${INPUT}"
echo "> > ${INPUT}"
echo "PREFIX:$PREFIX"
echo "MAJOR:$MAJOR"
echo "MINOR:$MINOR"
echo "PATCH:$PATCH"
echo "POSTFIX:$POSTFIX"
echo "BRANCH:$BRANCH"

INPUT="v1.0"
# shellcheck disable=SC1090
source "${SCRIPT}" "${INPUT}"
echo "> > ${INPUT}"
echo "PREFIX:$PREFIX"
echo "MAJOR:$MAJOR"
echo "MINOR:$MINOR"
echo "PATCH:$PATCH"
echo "POSTFIX:$POSTFIX"
echo "BRANCH:$BRANCH"

INPUT="v1.0.1"
# shellcheck disable=SC1090
source "${SCRIPT}" "${INPUT}"
echo "> > ${INPUT}"
echo "PREFIX:$PREFIX"
echo "MAJOR:$MAJOR"
echo "MINOR:$MINOR"
echo "PATCH:$PATCH"
echo "POSTFIX:$POSTFIX"
echo "BRANCH:$BRANCH"

INPUT="v1.0.1-prod"
# shellcheck disable=SC1090
source "${SCRIPT}" "${INPUT}"
echo "> > ${INPUT}"
echo "PREFIX:$PREFIX"
echo "MAJOR:$MAJOR"
echo "MINOR:$MINOR"
echo "PATCH:$PATCH"
echo "POSTFIX:$POSTFIX"
echo "BRANCH:$BRANCH"

INPUT="DF20241206"
# shellcheck disable=SC1090
source "${SCRIPT}" "${INPUT}"
echo "> > ${INPUT}"
echo "PREFIX:$PREFIX"
echo "MAJOR:$MAJOR"
echo "MINOR:$MINOR"
echo "PATCH:$PATCH"
echo "POSTFIX:$POSTFIX"
echo "BRANCH:$BRANCH"