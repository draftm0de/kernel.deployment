#!/bin/bash
set -e

# Constants
SCRIPT_PATH=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
source "${SCRIPT_PATH}/docker.sh.methods"
INTERPRETER_LOCAL="docker.local"

# Argument handling
read -r INTERPRETER CMD <<< "$(.parse_arguments "$@")"

# Include custom docker command interpreter
SCRIPT_FILE="${SCRIPT_PATH}/interpreter/${INTERPRETER}.sh"
if [ -f "${SCRIPT_FILE}" ]; then
  # shellcheck disable=SC1090
  source "${SCRIPT_FILE}"
else
  echo "[Error] interpreter/${INTERPRETER}.sh is not implemented" >&2
  exit 1
fi

# Functions for command handling
handle_image_tags() {
  CMD=${CMD//image tags /}; CMD=${CMD//tags /};
  local IMAGES
  IMAGES=$(.get_image_names_from_arguments "$CMD")

  local FILTER
  local CMD_FILTER
  CMD_FILTER=$(.get_option_from_arguments "--sha" "$CMD")
  if [ -n "$CMD_FILTER" ]; then
    FILTER="--sha=$CMD_FILTER"
  fi

  CMD_FILTER=$(.get_option_from_arguments "--tag" "$CMD")
  if [ -n "$CMD_FILTER" ]; then
    FILTER="--tag=$CMD_FILTER"
  fi

  local IMAGE_NAME="${IMAGES%:*}"
  local IMAGE_TAG="${IMAGES##*:}"
  if [ "$IMAGE_TAG" != "$IMAGE_NAME" ]; then
    FILTER="--tag=$IMAGE_TAG"
  fi

  local TAGS_LIST
  TAGS_LIST=$(docker_image_tags "$IMAGE_NAME" "$FILTER")

  local OPTION
  OPTION=$(.get_option_from_arguments "--latest" "$CMD" "patch")
  if [ -n "$OPTION" ]; then
    TAGS_LIST=$(.filter_image_tags "$OPTION" "$TAGS_LIST")
  fi

  OPTION=$(.get_option_from_arguments "--exists" "$CMD" "exit")
  case "$OPTION" in
    exit)
      if [ -n "$TAGS_LIST" ]; then
        echo "[Error] tags for $IMAGE_NAME $FILTER already exists" >&2
        exit 1
      fi
    ;;
    *)
    ;;
  esac

  read -r -a TAGS <<< "$TAGS_LIST"
  for tag in "${TAGS[@]}"; do
    echo "$tag"
  done
}

handle_image_rm() {
  if [ "${INTERPRETER}" != "$INTERPRETER_LOCAL" ]; then
    CMD=${CMD//image rm /}; CMD=${CMD//rmi /};

    local IMAGES
    IMAGES=$(.get_image_names_from_arguments "$CMD")
    docker_image_remove "$IMAGES"
  else
    CMD="docker $CMD"
    read -r -a COMMAND <<< "$CMD"
  fi
}

handle_image_sha() {
  CMD=${CMD//image sha /};

  local IMAGES
  IMAGES=$(.get_image_names_from_arguments "$CMD")

  local SHA
  SHA=$(docker_image_sha "$IMAGES")
  EXIT=$?
  if [ $EXIT -ne 0 ]; then
    exit $EXIT
  fi

  local OPTION_COMPARE
  OPTION_COMPARE=$(.get_option_from_arguments "--compare" "$CMD" "eq")

  if [ -n "$OPTION_COMPARE" ]; then
    .compare_image_sha "$OPTION_COMPARE" "$IMAGES" "$SHA"
  else
    echo "$SHA"
  fi
}

handle_image_tag() {
  local IMAGE
  local IMAGES
  local SOURCE_IMAGE
  local TARGET_IMAGE
  local COMMAND

  # cleanup command
  COMMAND=${CMD//image tag /}; COMMAND=${COMMAND//tag /};
  IMAGE=$(.get_image_names_from_arguments "$COMMAND")

  read -r -a IMAGES <<< "$IMAGE"
  SOURCE_IMAGE="${IMAGES[0]}"
  TARGET_IMAGE="${IMAGES[1]}"
  if [ -z "$SOURCE_IMAGE" ]; then
    echo "[Error] \"docker tag\" requires exactly 2 arguments, SOURCE_IMAGE[:TAG] missing" >&2
    exit 1
  fi
  if [ -z "$TARGET_IMAGE" ]; then
    echo "[Error] \"docker tag\" requires exactly 2 arguments, TARGET_IMAGE[:TAG] missing" >&2
    exit 1
  fi

  local TAG_INCREASE
  TAG_INCREASE=$(.get_option_from_arguments "--tag-increase" "$CMD" "true")

  if [ -n "$TAG_INCREASE" ]; then
    local NEW_TAG
    NEW_TAG=$(.get_incremented_image_tag "$TARGET_IMAGE" "$TAG_INCREASE")
    EXIT=$?
    if [ $EXIT -ne 0 ]; then
      exit $EXIT
    fi

    local TAG_LEVEL
    TAG_LEVEL=$(.get_option_from_arguments "--tag-level" "$CMD" "1")
    if [ -n "$TAG_LEVEL" ] && [[ "$TAG_LEVEL" -gt 1 ]]; then
      NEW_TAG=$(.get_image_tag_level "$NEW_TAG" "$TAG_LEVEL")
    fi

    read -r -a NEW_TAGS <<< "$NEW_TAG"
    TARGET_IMAGE_NAME="${TARGET_IMAGE%%:*}"
    for TARGET_TAG in "${NEW_TAGS[@]}"; do
      # docker image tag "$SOURCE_IMAGE" "$TARGET_IMAGE_NAME:$TARGET_TAG"
      echo "$TARGET_IMAGE_NAME:$TARGET_TAG"
    done
  fi
}

# ########################################
# handle arguments
# ########################################
COMMAND=("-")
case "$CMD" in
  "image tags "*|"tags "*)
    handle_image_tags
  ;;
  "rmi "*|"image rm "*)
    handle_image_rm
  ;;
  "image sha "*)
    handle_image_sha
  ;;
  "image tag "*|"tag "*)
    handle_image_tag
    exit 0
  ;;
  *)
    CMD="docker $CMD"
    read -r -a COMMAND <<< "$CMD"
  ;;
esac

if [ "${COMMAND[*]}" != "-" ]; then
  RESULT=$("${COMMAND[@]}")
  if [ -n "$RESULT" ]; then
    echo "$RESULT"
  fi
fi
