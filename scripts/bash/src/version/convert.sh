#!/bin/bash
set -e
set -o pipefail

silent=""
for arg in "$@"; do
  if [[ "$arg" == "--silent" ]]; then
    silent=true
  fi
done

echo "/version/convert.sh" 1>&2
regex="^(v)?([0-9]+)(\.[0-9]+)?(\.[0-9]+)?(-[a-zA-Z0-9]+)?$"
input="${1}"

PREFIX=""
MAJOR=""
MINOR=""
PATCH=""
POSTFIX=""
BRANCH=""
failure=""

# Match branch name against the regex
if [[ "$input" =~ $regex ]]; then
  echo "> <$input> matches version pattern: true" 1>&2
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
      --silent)
      ;;
      --level=*)
        level="${arg#*=}"
        echo "> arg: $arg" 1>&2
        case "${level}" in
          3|patch)
            if [ -z "${MINOR}" ]; then
              failure="> tag level valid: no (minor required)"
            fi
            if [ -n "${PATCH}" ]; then
              failure="> tag level valid: no (patch version already given)"
            fi
          ;;
          2|minor)
            if [ -n "${MINOR}" ]; then
              failure="> tag level valid: no (minor version already given)"
            fi
          ;;
          *)
            failure="> tag level valid: no (given level ${level} invalid)" 1>&2
          ;;
        esac
        if [ -z "${failure}" ]; then
          echo "> tag level valid: yes" 1>&2
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
    if [ -n "${failure}" ]; then
      echo "${failure}" 1>&2
      if [ -n "${silent}" ]; then
        exit 1
      fi
      exit 0
    fi
  done
else
  failure="> <$input> matches version pattern: false" 1>&2
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
