#!/bin/bash
set -e
set -o pipefail

helper_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
helper_path="$helper_path/../../src"

if [ -n "${2}" ]; then
  source "${helper_path}/converter/explode-branch-to-version.sh" "${2}"
elif [ -n "${1}" ]; then
  source "${helper_path}/converter/explode-branch-to-version.sh" "${1}"
fi

if [ -n "${BRANCH}" ]; then
  BRANCH="${PREFIX}${MAJOR}"
  if [ -n "${2}" ]; then
    if [ -n "${PATCH}" ]; then
      BRANCH="${BRANCH}.${MINOR}"
      PATCH=$((PATCH + 1))
      BRANCH="${BRANCH}.${PATCH}"
    elif [ -n "${MINOR}" ]; then
      MINOR=$((MINOR + 1))
      BRANCH="${BRANCH}.${MINOR}"
    fi
  else
    if [ -z "${MINOR}" ]; then
      MINOR=1
      BRANCH="${BRANCH}.1"
    elif [ -z "${PATCH}" ]; then
      PATCH=1
      BRANCH="${BRANCH}.${MINOR}.1"
    fi
  fi
  BRANCH="${BRANCH}${POSTFIX}"
fi

export PREFIX
export MAJOR
export MINOR
export PATCH
export POSTFIX
export BRANCH