#!/bin/bash
set -e

DOCKER_REGISTRY_TOKEN_URI="https://auth.docker.io/token?service=registry.docker.io&scope=repository"
DOCKER_REGISTRY_URI="https://index.docker.io/v2"
DOCKER_HUB_URI="https://hub.docker.com/v2"

# ########################################
# docker secret methods
# ########################################
.docker_config_get_auth() {
  local POSITION=${1:-1}
  local DOCKER_JSON_FILE DECODED_AUTH VALUE
  if docker info 2>/dev/null | grep -q "Username"; then
    DECODED_AUTH=$(.docker_get_config_auth_context "$DOCKER_JSON_PATH")
    if [ -n "$DECODED_AUTH" ]; then
      VALUE=$(echo "$DECODED_AUTH" | cut -d':' -f$POSITION)
      if [ -n "$VALUE" ]; then
        echo "$VALUE"
      else
        echo "[Error] Docker secrets: cannot extract property #$POSITION" >&2
        exit 1
      fi
    fi
  else
    echo "[Error] Docker secrets: Docker login required" >&2
    exit 1
  fi
}

.docker_get_config_file() {
  FILES=("$HOME/.docker/config.json" "/etc/docker/config.json")
  for FILE in "${FILES[@]}"; do
    if [ -f  "${FILE}" ]; then
      echo "${FILE}"
    fi
  done
}

.docker_get_config_auth_context() {
  DOCKER_JSON_FILE=$(.docker_get_config_file)
  if [ -f "$DOCKER_JSON_FILE" ]; then
    local AUTH_PATTERN_1='."https://index.docker.io/v1/".auth'
    local AUTH_PATTERN_2='.auths."https://index.docker.io/v1/".auth'

    # Check the first pattern
    AUTH_FIELD=$(jq -r "$AUTH_PATTERN_1" "$DOCKER_JSON_FILE")
    if [ -n "$AUTH_FIELD" ] && [ "$AUTH_FIELD" != "null" ]; then
      DECODED=$(echo "$AUTH_FIELD" | base64 --decode)
      echo "$DECODED"
      return
    fi

    # Check the second pattern
    AUTH_FIELD=$(jq -r "$AUTH_PATTERN_2" "$DOCKER_JSON_FILE")
    if [ -n "$AUTH_FIELD" ] && [ "$AUTH_FIELD" != "null" ]; then
      DECODED=$(echo "$AUTH_FIELD" | base64 --decode)
      echo "$DECODED"
      return
    fi
  fi
}

# ########################################
# internal methods
# ########################################

# Unified function to handle API responses and check status
.handle_api_response() {
  local RESPONSE_FILE="$1"
  local HTTP_CODE="$2"
  local ERROR_MSG="$3"

  if [ "$HTTP_CODE" -eq 200 ]; then
    cat "$RESPONSE_FILE"
  else
    echo "$ERROR_MSG: HTTP status $HTTP_CODE" >&2
    exit 1
  fi
}

# Retrieves Docker API JWT token
.docker_api_get_jwt_token() {
  local USERNAME
  USERNAME=$(.docker_config_get_auth 1)
  EXIT=$?
  if [ $EXIT -ne 0 ]; then
    exit $EXIT
  fi
  local PASSWORD
  PASSWORD=$(.docker_config_get_auth 2)
  EXIT=$?
  if [ $EXIT -ne 0 ]; then
    exit $EXIT
  fi

  RESPONSE=$(curl -s -H "Content-Type: application/json" -X POST \
            -d '{"username": "'$USERNAME'", "password": "'$PASSWORD'"}' \
            "${DOCKER_HUB_URI}/users/login/")
  if ! jq empty <<< "$RESPONSE" 2>/dev/null; then
    echo "[Error] Docker jwt token failure: Invalid JSON response while retrieving JWT token" >&2
    exit 1
  fi

  TOKEN=$(jq -r .token <<< "$RESPONSE")
  if [[ "$TOKEN" == "null" || -z "$TOKEN" ]]; then
    echo "[Error] Docker jwt token failure: Invalid credentials or malformed response" >&2
    exit 1
  fi

  echo "$TOKEN"
}

# Retrieves scoped Docker token
.docker_get_token() {
  local REPOSITORY="${1%:*}"
  local USERNAME
  USERNAME=$(.docker_config_get_auth 1)
  EXIT=$?
  if [ $EXIT -ne 0 ]; then
    exit $EXIT
  fi
  local PASSWORD
  PASSWORD=$(.docker_config_get_auth 2)
  EXIT=$?
  if [ $EXIT -ne 0 ]; then
    exit $EXIT
  fi
  local SCOPE=${4:-pull}

  TOKEN=$(curl -s -u "$USERNAME:$PASSWORD" \
        "${DOCKER_REGISTRY_TOKEN_URI}:${REPOSITORY}:${SCOPE}" | jq -r .token)

  if [[ "$TOKEN" == "null" || -z "$TOKEN" ]]; then
    echo "[Error] Docker token failure: Invalid credentials or malformed response" >&2
    exit 1
  fi

  echo "$TOKEN"
}

# Retrieves image SHA using the token
.docker_image_sha_by_token() {
  local IMAGE_NAME="${1%:*}"
  local IMAGE_TAG="${1##*:}"
  local TOKEN="$2"
  local FAILURE="[Error] get sha for $1 failure"

  if [ -z "$TOKEN" ]; then
    echo "$FAILURE: No API token provided" >&2
    exit 1
  fi

  if [ "$IMAGE_TAG" == "$IMAGE_NAME" ]; then
    echo "$FAILURE: Image tag missing" >&2
    exit 1
  fi

  RESPONSE=$(mktemp)
  HTTP_CODE=$(curl -s -o "$RESPONSE" -w "%{http_code}" -H "Authorization: Bearer $TOKEN" \
                 -H "Accept: application/vnd.docker.distribution.manifest.v2+json" \
                 "${DOCKER_REGISTRY_URI}/${IMAGE_NAME}/manifests/${IMAGE_TAG}")
  if [ "$HTTP_CODE" -eq 404 ]; then
    echo ""
    return
  fi
  MANIFEST=$(.handle_api_response "$RESPONSE" "$HTTP_CODE" "$FAILURE: Failed to retrieve manifest")
  EXIT=$?
  if [ $EXIT -ne 0 ]; then
    exit $EXIT
  fi
  SHA=$(jq -r '.config.digest' <<< "$MANIFEST")

  rm -f "$RESPONSE"  # Clean up the temporary file

  if [ "$SHA" == "null" ]; then
    echo "$FAILURE: node .config.digest in manifest not found" >&2
    exit 1
  fi

  echo "$SHA"
}

# ########################################
# docker_image_tags
# arguments:
# - image_name (e.g. draftmode/base.caddy, draftmode/base.caddy:latest)
# - username (docker username)
# - password (docker password)
# return:
# - string of tag
# ########################################
docker_image_tags() {
  local IMAGE_NAME="${1}"
  local FILTER="${2}"
  local FAILURE="[Error] get tags for $IMAGE_NAME $FILTER failure"

  # get docker api token
  TOKEN=$(.docker_get_token "$IMAGE_NAME")
  EXIT=$?
  if [ $EXIT -ne 0 ]; then
    exit $EXIT
  fi

  # prepare curl request
  RESPONSE=$(mktemp)
  HTTP_CODE=$(curl -s -o "$RESPONSE" -w "%{http_code}" -H "Authorization: Bearer $TOKEN" \
                 "${DOCKER_REGISTRY_URI}/${IMAGE_NAME}/tags/list")

  if [ "$HTTP_CODE" -eq 404 ]; then
    TAGS=()
  else
    TAG_LIST=$(.handle_api_response "$RESPONSE" "$HTTP_CODE" "$FAILURE: Failed to retrieve tags")
    EXIT=$?
    if [ $EXIT -ne 0 ]; then
      exit $EXIT
    fi
    local TAGS_STRING
    TAGS_STRING=$(jq -r '.tags[]' <<< "$TAG_LIST" | sort -V)
    mapfile -t TAGS <<< "$TAGS_STRING"
  fi

  rm -f "$RESPONSE"  # Clean up the temporary file

  case "$FILTER" in
    --tag=*)
      IMAGE_TAG="${FILTER##*=}"
      local IMAGE_SHA
      if [ ${#TAGS[@]} -gt 0 ]; then
        IMAGE_SHA=$(.docker_image_sha_by_token "$IMAGE_NAME:$IMAGE_TAG" "$TOKEN")
      else
        IMAGE_SHA="-"
      fi
      local SHA_TAGS=()
      local TAG_SHA
      for SHA_TAG in "${TAGS[@]}"; do
        # exclude passed TAG from TAG_LIST
        if [ "$SHA_TAG" != "$IMAGE_TAG" ]; then
          TAG_SHA=$(.docker_image_sha_by_token "$IMAGE_NAME:$SHA_TAG" "$TOKEN")
          if [ "$TAG_SHA" == "$IMAGE_SHA" ]; then
            SHA_TAGS+=("$SHA_TAG")
          fi
        fi
      done
      echo "${SHA_TAGS[*]}"
    ;;
    --sha=*)
      IMAGE_SHA="${FILTER##*=}"
      local SHA_TAGS=()
      local TAG_SHA
      for SHA_TAG in "${TAGS[@]}"; do
        TAG_SHA=$(.docker_image_sha_by_token "$IMAGE_NAME:$SHA_TAG" "$TOKEN")
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
  local IMAGE_NAME="${1}"

  TOKEN=$(.docker_get_token "$IMAGE_NAME")
  EXIT=$?
  if [ $EXIT -ne 0 ]; then
    exit $EXIT
  fi

  SHA=$(.docker_image_sha_by_token "$IMAGE_NAME" "$TOKEN")
  EXIT=$?
  if [ $EXIT -ne 0 ]; then
    exit $EXIT
  fi
  echo "$SHA"
}

# ########################################
# docker_image_remove
# arguments:
# - image_name(s) (e.g. draftmode/base.caddy draftmode/base.proxy:latest)
# - username (docker username)
# - password (docker password)
# ########################################
docker_image_remove() {
  local IMAGE_LIST="$1"

  # explode images into array
  read -r -a IMAGES <<< "$IMAGE_LIST"

  # get docker api token
  TOKEN=$(.docker_api_get_jwt_token)
  EXIT=$?
  if [ $EXIT -ne 0 ]; then
    exit $EXIT
  fi

  for IMAGE in "${IMAGES[@]}"; do
    REPOSITORY="${IMAGE%:*}"
    TAG="${IMAGE##*:}"
    [ "$REPOSITORY" == "$TAG" ] && TAG="latest"

    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: JWT $TOKEN" -X DELETE \
            "${DOCKER_HUB_URI}/repositories/$REPOSITORY/tags/$TAG/")
    case "$HTTP_CODE" in
      204)
        echo "[Notice] delete ${REPOSITORY}:${TAG} successfully" >&2
      ;;
      404)
        echo "[Notice] No such image: ${REPOSITORY}:${TAG}" >&2
      ;;
      *)
        echo "[Error] delete ${REPOSITORY}:${TAG} failure: retrieved $HTTP_CODE" >&2
      ;;
    esac
  done
}



