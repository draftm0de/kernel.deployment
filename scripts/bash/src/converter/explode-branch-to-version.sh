#!/bin/bash
set -e
set -o pipefail

regex="^(v)?([0-9]+)(\.[0-9]+)?(\.[0-9]+)?(-[a-zA-Z0-9]+)?$"
input="${1}"

PREFIX=""
MAJOR=""
MINOR=""
PATCH=""
POSTFIX=""
BRANCH=""

# Match branch name against the regex
if [[ "$input" =~ $regex ]]; then
  PREFIX="${BASH_REMATCH[1]}"
  MAJOR="${BASH_REMATCH[2]}"
  MINOR="${BASH_REMATCH[3]}"
  PATCH="${BASH_REMATCH[4]}"
  POSTFIX="${BASH_REMATCH[5]}"

  # remove leading .
  MINOR="${MINOR#.}"
  PATCH="${PATCH#.}"
  BRANCH="${input}"
  echo "> > branch [$input] matches version patterns"
else
  echo "> > branch [$input] does not match version patterns"
fi

export PREFIX
export MAJOR
export MINOR
export PATCH
export POSTFIX
export BRANCH