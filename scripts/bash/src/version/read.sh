#!/bin/bash
set -e
set -o pipefail

echo "/version/read.sh" 1>&2
regex="^(v)?([0-9]+)(\.[0-9]+)?(\.[0-9]+)?(-[a-zA-Z0-9]+)?$"

# handle argument --silent
input="${1}"
silent=""
if [[ "$*" == *"--silent"* ]]; then
  echo "> arg: --silent" 1>&2
  silent="true"
fi

PREFIX=""
MAJOR=""
MINOR=""
PATCH=""
POSTFIX=""
BRANCH=""

failure=""

# Match branch name against the regex
if [[ "$input" =~ $regex ]]; then
  echo "> <$input> matches version pattern successfully" 1>&2
  PREFIX="${BASH_REMATCH[1]}"
  MAJOR="${BASH_REMATCH[2]}"
  MINOR="${BASH_REMATCH[3]}"
  PATCH="${BASH_REMATCH[4]}"
  POSTFIX="${BASH_REMATCH[5]}"

  # remove leading .
  MINOR="${MINOR#.}"
  PATCH="${PATCH#.}"
  BRANCH="${input}"
  for arg in "$@"; do
    case "$arg" in
      --expect=*)
        expect="${arg#*=}"
        case "${expect}" in
          major)
            if [ -n "${MINOR}" ]; then
              failure="> level verification failure: minor exists"
            fi
          ;;
          minor)
            if [ -z "${MINOR}" ]; then
              failure="> level verification failure: minor missing"
            fi
            if [ -n "${PATCH}" ]; then
              failure="> level verification failure: patch existing"
            fi
          ;;
          *)
            failure="> level verification failure: level <${expect}> invalid, allowed (major|minor)" 1>&2
          ;;
        esac
        if [ -z "${failure}" ]; then
          echo "> level verification passed successfully" 1>&2
        fi
      ;;
      --contains=*)
        contains="${arg#*=}"
        echo "> arg: $arg" 1>&2
        if [[ "$BRANCH" == "$contains"* ]]; then
          branch_dots="${BRANCH//[^.]}"
          branch_dot_count=${#branch_dots}
          contains_dots="${contains//[^.]}"
          contains_dot_count=${#contains_dots}
          contains_dot_count=$((contains_dot_count + 1))
          if [[ $branch_dot_count -eq $contains_dot_count ]]; then
            echo "> <$input> contains ${contains}: yes" 1>&2
          else
            failure="> <$input> contains ${contains}: no (level does not match)" 1>&2
          fi
        else
          failure="> <$input> contains ${contains}: no" 1>&2
        fi
      ;;
      --format=*)
        format="${arg#*=}"
        echo "> arg: $arg" 1>&2
        case "$format" in
          tag-list)
            branch="${PREFIX}${MAJOR}"
            if [ -n "${MINOR}" ]; then
              branch="${branch}.${MINOR}"
            fi
            if [ -n "${PATCH}" ]; then
              branch="${branch}.${PATCH}"
            fi
            if [ -n "${POSTFIX}" ]; then
              branch="${branch}.*${POSTFIX}"
            else
              branch="${branch}.*"
            fi
            BRANCH="$branch"
          ;;
        esac
      ;;
    esac
  done
else
  failure="> <$input> matches version pattern failure" 1>&2
fi
if [ -n "${failure}" ]; then
  echo "${failure}" 1>&2
  if [ -n "${silent}" ]; then
    exit 1
  fi
  exit 0
else
  if [ -n "${silent}" ]; then
    exit 0
  fi
fi

export PREFIX
export MAJOR
export MINOR
export PATCH
export POSTFIX
export BRANCH

if [ -n "${BRANCH}" ]; then
  echo "$BRANCH"
fi
