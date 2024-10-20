#!/bin/bash
set -e

# ########################################
# docker_image_tags
# arguments:
# - image_name (e.g. draftmode/base.caddy, draftmode/base.caddy:latest)
# return:
# - string of tag
# ########################################
docker_image_tags() {
  local IMAGE_NAME="${1}"
  local FILTER="${2}"

  # Get all tags for the image name
  local TAGS
  TAGS_STRING=$(docker images "$IMAGE_NAME" --format="{{ .Tag }}")
  RESULT_EXIT=$?
  if [ $RESULT_EXIT -ne 0 ]; then
    TAGS=()
  else
    # convert tags into an array
    mapfile -t TAGS <<< "$TAGS_STRING"
  fi

  case "$FILTER" in
    --tag=*)
      local IMAGE_TAG="${FILTER##*=}"
      local IMAGE_SHA
      if [ ${#TAGS[@]} -gt 0 ]; then
        IMAGE_SHA=$(docker_image_sha "$IMAGE_NAME:$IMAGE_TAG")
        RESULT_EXIT=$?
        if [ $RESULT_EXIT -ne 0 ]; then
          exit $RESULT_EXIT
        fi
      else
        IMAGE_SHA="-"
      fi
      local SHA_TAGS=()
      local TAG_SHA
      for SHA_TAG in "${TAGS[@]}"; do
        # exclude passed TAG from TAG_LIST
        if [ "$SHA_TAG" != "$IMAGE_TAG" ]; then
          TAG_SHA=$(docker_image_sha "$IMAGE_NAME:$SHA_TAG")
          RESULT_EXIT=$?
          if [ $RESULT_EXIT -ne 0 ]; then
            exit $RESULT_EXIT
          fi
          if [ "$TAG_SHA" == "$IMAGE_SHA" ]; then
            SHA_TAGS+=("$SHA_TAG")
          fi
        fi
      done
      echo "${SHA_TAGS[*]}"
    ;;
    --sha=*)
      local IMAGE_SHA="${FILTER##*=}"
      local SHA_TAGS=()
      local TAG_SHA
      for SHA_TAG in "${TAGS[@]}"; do
        TAG_SHA=$(docker_image_sha "$IMAGE_NAME:$SHA_TAG")
        if [ "$TAG_SHA" == "$IMAGE_SHA" ]; then
          SHA_TAGS+=("$SHA_TAG")
        fi
      done
      echo "${SHA_TAGS[*]}"
    ;;
    *)
      echo "${TAGS[*]}"
    ;;
  esac
}

# ########################################
# docker_image_sha
# arguments:
# - image_name (e.g. draftmode/base.caddy, draftmode/base.caddy:latest)
# - username (docker username)
# - password (docker password)
# return:
# - string of sha (e.g. sha256:17a42d6b26d2158c95b53acb2074503df708f984eae216cc8ed8ee79fe497ebb)
# ########################################
docker_image_sha() {
  local IMAGE="${1}"
  local FILTER="${2}"

  # Get the image SHA
  local SHA
  SHA=$(docker inspect --format="{{.Id}}" "$IMAGE")
  RESULT_EXIT=$?
  if [ $RESULT_EXIT -ne 0 ]; then
    exit $RESULT_EXIT
  fi

  # Return the SHA
  echo "$SHA"
}

# ########################################
# docker_image_remove
# arguments:
# - image_name(s) (e.g. draftmode/base.caddy draftmode/base.proxy:latest)
# ########################################
docker_image_remove() {
  local IMAGE_LIST=("$@")  # Split images into an array

  for IMAGE in "${IMAGE_LIST[@]}"; do
    docker rmi "$IMAGE"
  done
}