#!/bin/bash
set -e
set -o pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
base_path="$script_dir/.."

#git tag -f "1" &>/dev/null
#git tag -f "1.1" &>/dev/null
#git tag -f "1.1.1" &>/dev/null
#git tag -f "1.1.2" &>/dev/null

target="1"
source="yes"
source_branch=$($base_path/git/read-branch.sh "${source}" 2>/dev/null)
target_branch=$($base_path/git/read-branch.sh "${target}" 2>/dev/null)
if [ -n "${target_branch}" ]; then
  echo "> target <${target}> is a branch: yes"
  if [ -n "${source_branch}" ]; then
    echo "> source <${source}> is a branch: yes"
    echo "> > ...nothing to tag"
  else
    echo "> source <${source}> is a branch: no"
    if $base_path/version/convert.sh "${target}" "--silent" 2>/dev/null; then
      echo "> target <${target}> matches version patterns: yes"
      latest_tag=$("$base_path/git/read-tags.sh" "--branch=$target" "--latest" 2>/dev/null)
      echo "> latest tag: ${latest_tag}"
      tags=$($base_path/version/patch.sh "${target}" "--latest=${latest_tag}")
      echo "> next tag: ${tags[*]}"
    else
      echo "> target <${target}> matches version patterns: no"
      echo "> > ...nothing to tag"
    fi
  fi
else
  echo "> target <${target}> is a branch: no"
fi
exit 0

level="patch"
source $base_path/version/convert.sh "$target" "--silent" 2>/dev/null


latest_tag=$("$base_path/git/read-tags.sh" "--branch=$target" "--latest" 2>/dev/null)
tags=$(source "$base_path/version/patch.sh" "${target}" "--latest=${latest_tag}" "--level=${level}")
if [ -n "${tags}" ]; then
  for tag in $tags; do
    echo "tag: $tag"
    #git tag -f "${tag}" "${commit}" &>/dev/null
  done
fi

#git tag -d "1" &>/dev/null
#git tag -d "1.1" &>/dev/null
#git tag -d "1.1.1" &>/dev/null
#git tag -d "1.1.2" &>/dev/null