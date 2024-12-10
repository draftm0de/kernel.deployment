#!/bin/bash
set -e
set -o pipefail
echo "/converter/branch-to-version.sh" 1>&2

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
  echo "> $input matches version pattern: true" 1>&2
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
      --contains=*)
        contains="${arg#*=}"
        echo "> arg: $arg" 1>&2
        if [[ "$BRANCH" == "$contains"* ]]; then
          echo "> > branch contains: true" 1>&2
          branch_dots="${BRANCH//[^.]}"
          branch_dot_count=${#branch_dots}
          echo "> > branch dots: $branch_dot_count" 1>&2
          contains_dots="${contains//[^.]}"
          contains_dot_count=${#contains_dots}
          echo "> > contains dots: $contains_dot_count" 1>&2
          contains_dot_count=$((contains_dot_count + 1))
          if [[ $branch_dot_count -eq $contains_dot_count ]]; then
            echo "> > > compare branch: true" 1>&2
          else
            echo "> > > compare branch: failure, count of dots does not match" 1>&2
            return
          fi
        else
          echo "> > branch contains: false" 1>&2
          return
        fi
      ;;
      --format=*)
        format="${arg#*=}"
        echo "> arg: $arg" 1>&2
        case "$format" in
          tag-list)
            branch="${PREFIX}${MAJOR}"
            if [ -n "${PATCH}" ]; then
              branch="${branch}.${MINOR}"
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
  echo "> $input matches version pattern: false" 1>&2
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