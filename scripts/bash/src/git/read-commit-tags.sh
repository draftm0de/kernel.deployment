#!/bin/bash
set -e
set -o pipefail
echo "/git/read-tags.sh" 1>&2

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
src_dir="$script_dir/../../src"

filter=""
option_sort=""
option_latest=""
for arg in "$@"; do
  case "$arg" in
    --filter=*)
      echo "> arg: $arg" 1>&2
      filter="${arg#*=}"
      echo "> > filter: $filter" 1>&2
      ;;
    --commit=*)
      echo "> arg: $arg" 1>&2
      commit="${arg#*=}"
      echo "> > commit: $commit" 1>&2
    ;;
    --latest)
      echo "> arg: $arg" 1>&2
      option_latest="true"
      option_sort="desc"
    ;;
    --sort)
      echo "> arg: $arg" 1>&2
      option_sort="desc"
    ;;
    --sort=*)
      echo "> arg: $arg" 1>&2
      option_sort="${arg#*=}"
    ;;
    --silent|--silent=*)
      silent="true"
      echo "> arg: $arg" 1>&2
    ;;
    *)
      echo "> arg: $arg" 1>&2
      echo "> > commit=$arg" 1>&2
      commit="$arg"
      ;;
  esac
done
if [ -z "$commit" ]; then
  commit=$(git rev-parse HEAD)
  echo "> commit from rev-parse HEAD: $commit" 1>&2
fi
echo "> --points-at $commit" 1>&2

# fetch all tags
git fetch --tags

tags=()
if git tag --points-at "$commit" &>/dev/null; then
  echo "> found tags: yes" 1>&2
  commit_tags=$(git tag --points-at "$commit")
  while IFS= read -r commit_tag; do
    case "$filter" in
      version)
        is_version=$(source "${src_dir}/converter/branch-to-version.sh" "${commit_tag}" 2>/dev/null)
        if [ -n "${is_version}" ]; then
          echo "> > commit tag $commit_tag matches version patterns: apply " 1>&2
        else
          echo "> > commit tag $commit_tag does not match version patterns: skip" 1>&2
          commit_tag=""
        fi
      ;;
      *)
        echo "> > apply commit tag ${commit_tag}" 1>&2
    esac
    if [ -n "$commit_tag" ]; then
      tags+=("$commit_tag")
    fi
  done <<< "$commit_tags"
else
  echo "> found tags: no" 1>&2
fi

if [[ ${#tags[@]} -gt 0 ]]; then
  if [ -n "${silent}" ]; then
    exit 0
  fi
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
    echo "$tag"
  done
else
  if [ -n "${silent}" ]; then
    exit 1
  fi
fi


