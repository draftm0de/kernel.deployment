#!/bin/bash
set -e
set -o pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
src_dir="$script_dir/../../src"

filter="all"
for arg in "$@"; do
  case "$arg" in
    --filter=*)
      filter="${arg#*=}"
      echo "> --filter $filter [from arguments]"
      ;;
    *)
      commit="$arg"
      ;;
  esac
done
if [ -z "$commit" ]; then
  commit=$(git rev-parse HEAD)
  echo "> --points-at $commit [from git pev-parse HEAD]"
else
  echo "> --points-at $commit [from arguments]"
fi

# fetch all tags
git fetch --tags

filtered_tags=()
if git tag --points-at "$commit" &>/dev/null; then
  commit_tags=$(git tag --points-at "$commit")
  while IFS= read -r commit_tag; do
    case "$filter" in
      version|only-version)
        commit_tag=$(source "${src_dir}/converter/explode-branch-to-version.sh" "${commit_tag}")
      ;;
    esac
    if [ -n "$commit_tag" ]; then
      filtered_tags+=("$commit_tag")
    fi
  done <<< "$commit_tags"
fi
for tag in "${filtered_tags[@]}"; do
  echo "$tag"
done


