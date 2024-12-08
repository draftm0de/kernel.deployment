#!/bin/bash
set -e
set -o pipefail

filter="all"
filter_notice="(use default)"
for arg in "$@"; do
  case "$arg" in
    --filter=*)
      arg_filter="${arg#*=}"
      case "$arg_filter" in
        all|versioned)
          filter_notice="(received from args)"
          filter="$arg_filter"
        ;;
        *)
          filter_notice="(received invalid from args, use: all)"
          filter="all"
        ;;
      esac
      ;;
    *)
      commit="$arg"
      ;;
  esac
done
commit_notice="(received from args)"
if [ -z "$commit" ]; then
  commit=$(git rev-parse HEAD)
  commit_notice="(got from rev-parse HEAD)"
fi
echo "> commit: ${commit} ${commit_notice}"
echo "> filter: ${filter} ${filter_notice}"

# fetch all tags
git fetch --tags

filtered_tags=()
versioned_regex="^(v)?([0-9]+)(\.[0-9]+)?(\.[0-9]+)?(-[a-zA-Z0-9]+)?$"
if git tag --contains "$commit" &>/dev/null; then
  commit_tags=$(git tag --contains "$commit")
  while IFS= read -r commit_tag; do
    isValid="false"
    case "$filter" in
      versioned)
        if [[ $commit_tag =~ $versioned_regex ]]; then
          isValid="true"
        fi
      ;;
      all)
        isValid="true"
      ;;
    esac
    if [ "$isValid" == "true" ]; then
      echo "> > tag: $commit_tag, matches ${filter}"
      filtered_tags+=("$commit_tag")
    else
      echo "> > tag: $commit_tag, does not match ${filter}"
    fi
  done <<< "$commit_tags"
fi
TAGS="${filtered_tags[*]}"
export TAGS
