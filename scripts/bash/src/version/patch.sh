#!/bin/bash
set -e
set -o pipefail

echo "/version/patch.sh" 1>&2

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
src_dir="$script_dir/../../src"

version="${1}"
echo "> version: $version" 1>&2
option_silent=""
option_latest=""
for arg in "$@"; do
  case "$arg" in
    --silent)
      echo "> arg: $arg" 1>&2
      option_silent=$arg
    ;;
    --latest=*)
      echo "> arg: $arg" 1>&2
      option_latest="${arg#*=}"
    ;;
  esac
done

patch_branch=""
source ${src_dir}/version/read.sh "${version}" &>/dev/null
if [ -n "${BRANCH}" ]; then
  echo "> version <${version}> matches version patterns" 1>&2
  patch_prefix="${PREFIX}"
  patch_major="${MAJOR}"
  patch_minor="${MINOR}"
  patch_patch="${PATCH}"
  version_postfix="${POSTFIX}"
  echo "> > prefix: ${patch_prefix}" 1>&2
  echo "> > major: ${patch_major}" 1>&2
  echo "> > minor: ${patch_minor}" 1>&2
  echo "> > patch: ${patch_patch}" 1>&2
  echo "> > postfix: ${version_postfix}" 1>&2
  if [ -n "${patch_minor}" ]; then
    if [ -n "${patch_patch}" ]; then
      patch_patch=$((patch_patch + 1))
      echo "> > increase patch version: ${patch_patch}" 1>&2
    else
      echo "> > initialize patch version: 0" 1>&2
      patch_patch="0"
    fi
  else
    patch_minor="0"
    echo "> > initialize minor version: 0" 1>&2
    patch_patch="0"
    echo "> > initialize patch version: 0" 1>&2
  fi

  # build full branch name
  patch_branch="${patch_prefix}${patch_major}"
  if [ -n "${patch_minor}" ]; then
    patch_branch="${patch_branch}.${patch_minor}"
  fi
  if [ -n "${patch_patch}" ]; then
    patch_branch="${patch_branch}.${patch_patch}"
  fi
  patch_branch="${patch_branch}${version_postfix}"
else
  echo "> version <${version}> does not match version patterns" 1>&2
  if [ -n "${option_silent}" ]; then
    exit 1
  fi
fi

if [ -n "${patch_branch}" ]; then
  latest_minor=""
  if [ -n "${option_latest}" ]; then
    source ${src_dir}/version/read.sh "${option_latest}" &>/dev/null
    if [ -n "${BRANCH}" ]; then
      latest_minor="${MINOR}"
    fi
  fi
  branches=()
  patch_minor=${patch_minor:-0}
  patch_patch=${patch_patch:-0}
  branches+=("${patch_prefix}${patch_major}.${patch_minor}.${patch_patch}${version_postfix}")
  branches+=("${patch_prefix}${patch_major}.${patch_minor}${version_postfix}")
  if [ ${latest_minor:-${patch_minor}} -gt ${patch_minor} ]; then
    echo "> > patching major version skipped, latest minor ${latest_minor} greater and patched major <${patch_minor}>" 1>&2
  else
    branches+=("${patch_prefix}${patch_major}${version_postfix}")
  fi

  # output tags
  for branch in "${branches[@]}"; do
    echo "$branch"
  done
fi
