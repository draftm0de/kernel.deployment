#!/bin/bash
set -e
set -o pipefail

REGEX="^(v)?([0-9]+)(\.[0-9]+)?(\.[0-9]+)?(-[a-zA-Z0-9]+)?$"
INPUT="${1}"

PREFIX=""
MAJOR=""
MINOR=""
PATCH=""
POSTFIX=""
BRANCH=""

# Match branch name against the regex
if [[ "$INPUT" =~ $REGEX ]]; then
  PREFIX="${BASH_REMATCH[1]}"
  MAJOR="${BASH_REMATCH[2]}"
  MINOR="${BASH_REMATCH[3]}"
  PATCH="${BASH_REMATCH[4]}"
  POSTFIX="${BASH_REMATCH[5]}"

  # remove leading .
  MINOR="${MINOR#.}"
  PATCH="${PATCH#.}"
  BRANCH="${INPUT}"
fi

export PREFIX
export MAJOR
export MINOR
export PATCH
export POSTFIX
export BRANCH