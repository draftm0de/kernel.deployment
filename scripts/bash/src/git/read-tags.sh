#!/bin/bash
set -e
set -o pipefail
echo "/git/read-tags.sh" 1>&2

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
src_dir="$script_dir/../../src"

branch=""
filter=""
option_sort=""
option_latest=""
option_list=""
options=()
for arg in "$@"; do
  case "$arg" in
    --latest)
      echo "> arg: $arg" 1>&2
      option_latest="true"
      option_sort="desc"
    ;;
    --latest=*)
      echo "> arg: $arg" 1>&2
      option_latest="${arg#*=}"
      option_sort="desc"
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
    --sort)
      echo "> arg: $arg" 1>&2
      option_sort="desc"
    ;;
    --sort=*)
      echo "> arg: $arg" 1>&2
      option_sort="${arg#*=}"
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

if [[ ${#tags[@]} -gt 0 ]]; then
  # sort array
  if [ -n "${option_sort}" ]; then
    if [ "${option_sort}" == "asc" ]; then
      option_sort="-V"
    elif [ "${option_sort}" == "desc" ]; then
      option_sort="-r"
    else
      option_sort=""
    fi
    if [ -n "${option_sort}" ]; then
      echo "> sort by ${option_sort}" 1>&2
      readarray -t tags < <(printf '%s\n' "${tags[@]}" | sort ${option_sort})
    fi
  fi
  # return first element only
  if [ -n "${option_latest}" ]; then
    tags=("${tags[0]}")
  fi
  # output tags
  for tag in "${tags[@]}"; do
    echo "> tag: ${tags[*]}" 1>&2
    echo "$tag"
  done
else
  echo "> no tags found" 1>&2
fi
