#!/bin/bash
set -e
set -o pipefail
echo "/git/read-tags.sh" 1>&2

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
src_dir="$script_dir/../../src"

branch=""
filter=""
option_latest=""
option_list=""
options=()
for arg in "$@"; do
  case "$arg" in
    --latest)
      echo "> arg: $arg" 1>&2
      option_latest="true"
      options+=("--sort=-v:refname")
      echo "> --sort=-v:refname" 1>&2
    ;;
    --list)
      option_list="true"
    ;;
    --branch=*)
      echo "> arg: $arg" 1>&2
      branch="${arg#*=}"
      # shellcheck disable=SC1090
      tag_list=$(source "${src_dir}/converter/branch-to-version.sh" "${branch}" "--format=tag-list" 2>/dev/null)
      if [ -n "$tag_list" ]; then
        list="$tag_list"
        echo "> > branch matches version patterns: yes" 1>&2
        echo "> > --list ${list}" 1>&2
        filter="branch"
      else
        echo "> > branch matches version patterns: no" 1>&2
        list="$branch"
        echo "> > --list ${list}" 1>&2
      fi
      options+=("--list")
      options+=("${list}")
    ;;
    *)
      if [ -n "$option_list" ]; then
        options+=("--list")
        options+=("${arg}")
        option_list=""
        echo "> arg --list ${arg}" 1>&2
      fi
  esac
done

# execute git tag command
read_tags=$(git tag "${options[@]}")

tags=()
while IFS= read -r tag; do
  case "$filter" in
    branch)
      message="> tag $tag contains $branch"
      tag=$(source "${src_dir}/converter/branch-to-version.sh" "${tag}" "--contains=${branch}" 2>/dev/null)
      if [ -n "${tag}" ]; then
        echo "$message: yes" 1>&2
      else
        echo "$message: no" 1>&2
      fi
    ;;
  esac
  if [ -n "$tag" ]; then
    tags+=("$tag")
  fi
done <<< "$read_tags"

# reduce TAGS to latest
if [ -n "${option_latest}" ]; then
  latest_tag=$(echo "$tags" | head -n 1)
  tags=("$latest_tag")
fi

for tag in "${tags[@]}"; do
  echo "$tag"
done