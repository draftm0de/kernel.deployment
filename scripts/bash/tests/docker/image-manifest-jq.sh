#!/bin/bash
set -e
set -o pipefail

base_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
base_path="$base_path/../../src"

SCRIPT="${base_path}/docker/image-manifest-jq.sh"

IMAGE="draftmode/image.caddy:test"
JQ=".config.digest"
# shellcheck disable=SC1090
source "${SCRIPT}" "${IMAGE}" "${JQ}"
echo "> > ${IMAGE} >> ${JQ}"
echo "PROPERTY:$PROPERTY"

IMAGE="draftmode/image.caddy:test"
JQ=".config.size"
# shellcheck disable=SC1090
source "${SCRIPT}" "${IMAGE}" "${JQ}"
echo "> > ${IMAGE} >> ${JQ}"
echo "PROPERTY:$PROPERTY"