#!/bin/bash
set -e
set -o pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
src_dir="$script_dir/../../src"

latest=""
filter=""
options=()
for arg in "$@"; do
  case "$arg" in
    --latest)
      latest="auto"
      options+=("--sort=-v:refname")
      echo "> --sort=-v:refname [from argument --latest]"
    ;;
    --list*)
      if [[ "$arg" =~ --list[[:space:]](.+) ]]; then
        filter="${BASH_REMATCH[1]}"
        options+=("--list")
        options+=("${filter}")
        echo "> --list ${filter} [from argument --list]"
      fi
    ;;
    --branch=*)
      branch="${arg#*=}"
      list="$branch"
      # shellcheck disable=SC1090
      source "${src_dir}/converter/explode-branch-to-version.sh" "${branch}" >/dev/null
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
        echo "> --list ${list} [built from argument --branch=${branch}]"
      else
        echo "> --list ${list} [from argument --branch]"
      fi
      options+=("--list")
      options+=("${list}")
      options+=("--sort=-v:refname")
      filter="version"
    ;;
  esac
done

# execute git tag command
read_tags=$(git tag "${options[@]}")

tags=()
while IFS= read -r tag; do
  # echo ":$MAJOR:"
  case "$filter" in
    version|only-version)
      source "${src_dir}/converter/explode-branch-to-version.sh" "${tag}" 1>/dev/null
      if [ -z "${BRANCH}" ]; then
        tag=""
      fi
    ;;
  esac
  if [ -n "$tag" ]; then
    tags+=("$tag")
  fi
done <<< "$read_tags"

# reduce TAGS to latest
if [ -n "${latest}" ]; then
  latest_tag=$(echo "$tags" | head -n 1)
  tags=("$latest_tag")
fi

for tag in "${tags[@]}"; do
  echo "$tag"
done


