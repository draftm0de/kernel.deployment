#!/bin/bash
set -e
set -o pipefail

base_path="../src"

#git tag -f "1" &>/dev/null
#git tag -f "1.1" &>/dev/null
#git tag -f "1.1.1" &>/dev/null
#git tag -f "1.1.2" &>/dev/null

target="1.2"
level="patch"
source $base_path/version/convert.sh "$target" "--level=${level}" "--silent" 2>/dev/null
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
