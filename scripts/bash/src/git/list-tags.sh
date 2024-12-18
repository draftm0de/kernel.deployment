#!/bin/bash
set -e
set -o pipefail
echo "/git/read-tags.sh" 1>&2

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
src_dir="$script_dir/../../src"

branch=""
option_sort=""
option_latest=""
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
    --branch=*)
      echo "> arg: $arg" 1>&2
      branch="${arg#*=}"
      tag_filter=$("${src_dir}/version/read.sh" "${branch}" "--format=tag-list" 2>/dev/null)
      if [ -n "$tag_filter" ]; then
        echo "> > branch <${branch}> matches version patterns: yes" 1>&2
        echo "> --list ${tag_filter}" 1>&2
        options+=("--list")
        options+=("${tag_filter}")
      else
        echo "> > branch <${branch}> matches version patterns: no" 1>&2
      fi
    ;;
    --message=*)
      echo "> arg: $arg" 1>&2
      options+=("--list")
      options+=("--format=%(contents:subject)")
      options+=("${arg#*=}")
    ;;
  esac
done
if [[ ! "${options[*]}" == *"--list"* ]]; then
  options+=("--list")
fi

read_tags=$(git tag "${options[@]}")

tags=()
if [ -n "${read_tags}" ]; then
  echo "> found tags" 1>&2
  while IFS= read -r tag; do
    if [ -n "$tag" ]; then
      echo "> > tag: $tag" 1>&2
      tags+=("$tag")
    fi
  done <<< "$read_tags"
fi

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
    echo "> use latest" 1>&2
    tags=("${tags[0]}")
  fi
  # output tags
  echo "> result" 1>&2
  for tag in "${tags[@]}"; do
    echo "> > tag: ${tags[*]}" 1>&2
    echo "$tag"
  done
else
  echo "> no tag(s) found" 1>&2
fi