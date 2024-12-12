#!/bin/bash
set -e
set -o pipefail

base_path="../src"

#git tag -f "1" &>/dev/null
#git tag -f "1.1" &>/dev/null
#git tag -f "1.1.1" &>/dev/null
#git tag -f "1.1.2" &>/dev/null

target="3.1"
depth="3"
commit="main"
latest_tag=$("$base_path/git/read-tags.sh" "--branch=$target" "--latest" 2>/dev/null)
commit_tags=$(source "$base_path/version/patch.sh" "${target}" "--latest=${latest_tag}" "--depth=${depth}")
if [ -n "${commit_tags}" ]; then
  for tag in $commit_tags; do
    echo "tag: $tag"
    #git tag -f "${tag}" "${commit}" &>/dev/null
  done
fi

#git tag -d "1" &>/dev/null
#git tag -d "1.1" &>/dev/null
#git tag -d "1.1.1" &>/dev/null
#git tag -d "1.1.2" &>/dev/null
