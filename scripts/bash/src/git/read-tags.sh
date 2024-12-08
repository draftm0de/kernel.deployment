#!/bin/bash
set -e
set -o pipefail

helper_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
helper_path="$helper_path/../../src"
echo "***********"
BRANCH=""
latest=""
options=()
for arg in "$@"; do
  case "$arg" in
    --latest)
      latest="auto"
      options+=("--sort=-v:refname")
      echo "> --sort=-v:refname"
    ;;
    --list*)
      if [[ "$arg" =~ --list[[:space:]](.+) ]]; then
        filter="${BASH_REMATCH[1]}"
        options+=("--list")
        options+=("${filter}")
        echo "> --list ${filter}"
      fi
    ;;
    --branch=*)
      filter="${arg#*=}"
      echo "> --branch=${filter}"
      helper="${helper_path}/converter/explode-branch-to-version.sh"
      # shellcheck disable=SC1090
      source "$helper" "${filter}"
      if [ -n "$BRANCH" ]; then
        list="${PREFIX}${MAJOR}"
        if [ -n "${MINOR}" ]; then
          list="${list}.${MINOR}"
        fi
        if [ -n "${POSTFIX}" ]; then
          list="${list}.*-${POSTFIX}"
        else
          list="${list}.*"
        fi
        options+=("--list")
        options+=("${list}")
        echo "> --list ${list}"
      fi
    ;;
  esac
done

# execute git tag command
TAGS=$(git tag "${options[@]}")

# reduce TAGS to latest
if [ -n "${latest}" ]; then
  TAGS=$(echo "$TAGS" | head -n 1)
fi
export TAGS

