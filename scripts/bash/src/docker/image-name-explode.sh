#!/bin/bash
set -e
set -o pipefail

# split given full qualified image name into
# example draftmode/my-image:1.0
# - DOCKER_REPOSITORY: draftmode
# - DOCKER_NAME: my-image
# - DOCKER_TAG: 1.0
# - DOCKER_DIGEST:
# example draftmode/my-image@sha256:1212121212
# - DOCKER_REPOSITORY: draftmode
# - DOCKER_NAME: my-image
# - DOCKER_TAG:
# - DOCKER_DIGEST: sha256:1212121212

INPUT="${1}"
DOCKER_HOST=""
DOCKER_PORT=""
DOCKER_REGISTRY=""
DOCKER_REPOSITORY="${INPUT}"
DOCKER_TAG=""
DOCKER_DIGEST=""
if [[ "${DOCKER_REPOSITORY}" == *"/"*"/"* ]]; then
  DOCKER_HOST="${DOCKER_REPOSITORY%%/*}"
  DOCKER_REPOSITORY="${DOCKER_REPOSITORY#*/}"
  if [[ "${DOCKER_HOST}" == *":"* ]]; then
    DOCKER_PORT="${DOCKER_HOST#*:}"
    DOCKER_HOST="${DOCKER_HOST%%:*}"
  fi
fi
if [[ "${DOCKER_REPOSITORY}" == *"/"* ]]; then
  DOCKER_REGISTRY="${DOCKER_REPOSITORY%%/*}"
  DOCKER_REPOSITORY="${DOCKER_REPOSITORY#*/}"
fi
if [[ "${DOCKER_REPOSITORY}" == *"@"* ]]; then
  DOCKER_DIGEST="${DOCKER_REPOSITORY#*@}"
  DOCKER_REPOSITORY="${DOCKER_REPOSITORY%%@*}"
elif [[ "${DOCKER_REPOSITORY}" == *":"* ]]; then
  DOCKER_TAG="${DOCKER_REPOSITORY#*:}"
  DOCKER_REPOSITORY="${DOCKER_REPOSITORY%%:*}"
fi

export DOCKER_HOST
export DOCKER_PORT
export DOCKER_REGISTRY
export DOCKER_REPOSITORY
export DOCKER_TAG
export DOCKER_DIGEST