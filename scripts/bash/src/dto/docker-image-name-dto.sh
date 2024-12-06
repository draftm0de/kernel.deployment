#!/bin/bash
set -e
set -o pipefail

# split given full qualified image name into
# example draftmode/my-image:1.0
# - DOCKER_REGISTRY: draftmode
# - DOCKER_NAME: my-image
# - DOCKER_TAG: 1.0
# - DOCKER_DIGEST:
# example draftmode/my-image@sha256:1212121212
# - DOCKER_REGISTRY: draftmode
# - DOCKER_NAME: my-image
# - DOCKER_TAG:
# - DOCKER_DIGEST: sha256:1212121212

INPUT="${1}"
DOCKER_REGISTRY=""
DOCKER_NAME="${INPUT}"
DOCKER_TAG=""
DOCKER_DIGEST=""
if [[ "${DOCKER_NAME}" == *"/"* ]]; then
  DOCKER_REGISTRY="${DOCKER_NAME%%/*}"
  DOCKER_NAME="${DOCKER_NAME#*/}"
fi
if [[ "${DOCKER_NAME}" == *"@"* ]]; then
  DOCKER_DIGEST="${DOCKER_NAME#*@}"
  DOCKER_NAME="${DOCKER_NAME%%@*}"
elif [[ "${DOCKER_NAME}" == *":"* ]]; then
  DOCKER_TAG="${DOCKER_NAME#*:}"
  DOCKER_NAME="${DOCKER_NAME%%:*}"
fi
export DOCKER_REGISTRY
export DOCKER_NAME
export DOCKER_TAG
export DOCKER_DIGEST