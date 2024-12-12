#!/bin/bash
set -e
set -o pipefail

base_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
base_path="$base_path/../../src"
SCRIPT="${base_path}/docker/image-manifest.sh"

shTest "${SCRIPT}" "{file:tests/docker/image-manifest-busybox.1.34.json}" "busybox:1.34"
shTest "${SCRIPT}" "2" "busybox:1.34" "--jq=.schemaVersion"
shTest "${SCRIPT}" "" "busybox:1.34" "--jq=.unknownTag"
shTest "${SCRIPT}" "{false}" "busybox:1.34" "--jq=.unknownTag" "--silent"
shTest "${SCRIPT}" "" "unknown/registry:1.0" "--jq=.schemaVersion"
shTest "${SCRIPT}" "{false}" "unknown/registry:1.0" "--jq=.schemaVersion" "--silent"
