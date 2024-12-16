#!/bin/bash
set -e
set -o pipefail
echo "/git/read-branch.sh" 1>&2

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
src_dir="$script_dir/../../src"

branch="${1}"
if [ -z "${branch}" ]; then
  echo ""
  exit 1
fi

silent=""
option_version=""
for arg in "$@"; do
  case "$arg" in
    --silent|--silent=*)
      silent="true"
      echo "> arg: $arg" 1>&2
    ;;
    --version)
      option_version="true"
      echo "> arg: $arg" 1>&2
    ;;
  esac
done

failure=""
exists=$(git branch --list "${branch}" 2>/dev/null)
if [ -n "${exists}" ]; then
  echo "> branch <${branch}> exists: yes" 1>&2
  if [ -n "${option_version}" ]; then
    if $src_dir/version/convert.sh "${branch}" "--silent" 2>/dev/null; then
      echo "> branch <${branch}> matches version pattern: yes" 1>&2
    else
      failure="> branch <${branch}> matches version pattern: no"
    fi
  fi
else
  failure="> branch <${branch}> exists: no"
fi

if [ -n "${failure}" ]; then
  echo "${failure}" 1>&2
  if [ -n "${silent}" ]; then
    exit 1
  fi
else
  if [ -n "${silent}" ]; then
    exit 0
  fi
  echo "${branch}"
fi

