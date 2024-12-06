#!/bin/bash
set -e
set -o pipefail

base_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
base_path="$base_path/../../src"

# image-split-name
INPUT="draftmode/my-image:1.0"
SCRIPT="${base_path}/dto/docker-image-name-dto.sh"
# shellcheck disable=SC1090
source "${SCRIPT}" "${INPUT}"
echo "> > ${INPUT}"
echo "DOCKER_REGISTRY:$DOCKER_REGISTRY"
echo "DOCKER_NAME:$DOCKER_NAME"
echo "DOCKER_TAG:$DOCKER_TAG"
echo "DOCKER_DIGEST:$DOCKER_DIGEST"

INPUT="draftmode/my-image@sha256:121212121"
echo "> > ${INPUT}"
# shellcheck disable=SC1090
source "${SCRIPT}" "${INPUT}"
echo "DOCKER_REGISTRY:$DOCKER_REGISTRY"
echo "DOCKER_NAME:$DOCKER_NAME"
echo "DOCKER_TAG:$DOCKER_TAG"
echo "DOCKER_DIGEST:$DOCKER_DIGEST"