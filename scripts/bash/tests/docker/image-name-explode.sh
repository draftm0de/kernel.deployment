#!/bin/bash
set -e
set -o pipefail

base_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
base_path="$base_path/../../src"
SCRIPT="${base_path}/docker/image-name-explode.sh"

INPUT="draftmode/my-image:1.0"
source "${SCRIPT}" "${INPUT}"
echo "> > ${INPUT}"
echo "DOCKER_HOST:$DOCKER_HOST"
echo "DOCKER_PORT:$DOCKER_PORT"
echo "DOCKER_REGISTRY:$DOCKER_REGISTRY"
echo "DOCKER_REPOSITORY:$DOCKER_REPOSITORY"
echo "DOCKER_TAG:$DOCKER_TAG"
echo "DOCKER_DIGEST:$DOCKER_DIGEST"

INPUT="draftmode/my-image@sha256:121212121"
echo "> > ${INPUT}"
# shellcheck disable=SC1090
source "${SCRIPT}" "${INPUT}"
echo "DOCKER_HOST:$DOCKER_HOST"
echo "DOCKER_PORT:$DOCKER_PORT"
echo "DOCKER_REGISTRY:$DOCKER_REGISTRY"
echo "DOCKER_REPOSITORY:$DOCKER_REPOSITORY"
echo "DOCKER_TAG:$DOCKER_TAG"
echo "DOCKER_DIGEST:$DOCKER_DIGEST"

INPUT="docker.io:212/draftmode/my-image@sha256:121212121"
echo "> > ${INPUT}"
# shellcheck disable=SC1090
source "${SCRIPT}" "${INPUT}"
echo "DOCKER_HOST:$DOCKER_HOST"
echo "DOCKER_PORT:$DOCKER_PORT"
echo "DOCKER_REGISTRY:$DOCKER_REGISTRY"
echo "DOCKER_REPOSITORY:$DOCKER_REPOSITORY"
echo "DOCKER_TAG:$DOCKER_TAG"
echo "DOCKER_DIGEST:$DOCKER_DIGEST"

INPUT="docker.io/draftmode/my-image:test"
echo "> > ${INPUT}"
# shellcheck disable=SC1090
source "${SCRIPT}" "${INPUT}"
echo "DOCKER_HOST:$DOCKER_HOST"
echo "DOCKER_PORT:$DOCKER_PORT"
echo "DOCKER_REGISTRY:$DOCKER_REGISTRY"
echo "DOCKER_REPOSITORY:$DOCKER_REPOSITORY"
echo "DOCKER_TAG:$DOCKER_TAG"
echo "DOCKER_DIGEST:$DOCKER_DIGEST"