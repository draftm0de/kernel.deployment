#!/bin/bash
set -e
set -o pipefail

DOCKER_HUB_URI="https://hub.docker.com/v2"
DOCKER_HUB_REGISTRY="https://registry.hub.docker.com/v2"
DOCKER_HUB_AUTH="https://auth.docker.io/"
# ########################################
# internal methods
hub_config_get_auth() {
  local POSITION=${1:-1}
  local DOCKER_JSON_FILE DECODED_AUTH VALUE
  if docker info 2>/dev/null | grep -q "Username"; then
    DECODED_AUTH=$(hub_get_config_auth_context "$DOCKER_JSON_PATH")
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

hub_get_config_file() {
  FILES=("$HOME/.docker/config.json" "/etc/docker/config.json")
  for FILE in "${FILES[@]}"; do
    if [ -f  "${FILE}" ]; then
      echo "${FILE}"
    fi
  done
}

hub_get_config_auth_context() {
  DOCKER_JSON_FILE=$(hub_get_config_file)
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
hub_get_bearer_token() {
  failure="[Error] Docker Bearer token failure:"
  local username
  username=$(hub_config_get_auth 1)
  exit=$?
  if [ $exit -ne 0 ]; then
    exit $exit
  fi

  local password
  password=$(hub_config_get_auth 2)
  exit=$?
  if [ $exit -ne 0 ]; then
    exit $exit
  fi

  repository="draftmode/image.caddy"
  scope="repository:$repository"

  uri="${DOCKER_HUB_AUTH}token?service=registry.docker.io&scope=$scope:pull"
  response=$(curl -s -u $username:$password $uri)
  if ! jq empty <<< "${response}" 2>/dev/null; then
    echo "$failure Invalid JSON response while retrieving Bearer token" >&2
    exit 1
  fi
  local token
  token=$(jq -r .token <<< "${response}")
  if [[ "${token}" == "null" || -z "${token}" ]]; then
    echo "$failure Invalid credentials or malformed response" >&2
    exit 1
  fi
  echo "${token}"
}

hub_get_jwt_token() {
  failure="[Error] Docker jwt token failure:"
  local username
  username=$(hub_config_get_auth 1)
  exit=$?
  if [ $exit -ne 0 ]; then
    exit $exit
  fi

  local password
  password=$(hub_config_get_auth 2)
  exit=$?
  if [ $exit -ne 0 ]; then
    exit $exit
  fi

  uri="${DOCKER_HUB_URI}/users/login/"
  response=$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'${username}'", "password": "'${password}'"}' "${uri}")

  if ! jq empty <<< "${response}" 2>/dev/null; then
    echo "$failure Invalid JSON response while retrieving JWT token" >&2
    exit 1
  fi

  local token
  token=$(jq -r .token <<< "${response}")
  if [[ "${token}" == "null" || -z "${token}" ]]; then
    echo "$failure Invalid credentials or malformed response" >&2
    exit 1
  fi

  echo "${token}"
}
# internal methods
# ########################################

docker_manifest() {
  image="${1}"
  if [[ "$image" == *@* ]]; then
    image_name="${image%@*}"
    image_tag="${image#*@}"
  else
    image_name="${image%:*}"
    image_tag="${image#*:}"
  fi

  local token
  token=$(hub_get_bearer_token "$image_name")

#  curl -H "Authorization: Bearer $token" \
#     -H "Accept: application/vnd.docker.distribution.manifest.v2+json" \
#     https://registry.hub.docker.com/v2/draftmode/image.caddy/manifests/test
  response=$(mktemp)
  uri="${DOCKER_HUB_REGISTRY}/${image_name}/manifests/$image_tag"
  http_code=$(curl -s -o "$response" \
    -w "%{http_code}" \
    -H "Authorization: Bearer $token" \
    -H "Accept: application/vnd.docker.distribution.manifest.v2+json" "${uri}")

  uri="${DOCKER_HUB_REGISTRY}/${image_name}/blobs/$image_tag"
  echo "$uri"

  http_code=$(curl -s -o "$response" \
    -w "%{http_code}" \
    -I \
    -L \
    -H "Authorization: Bearer $token" \
    "${uri}")

  content=$(cat "$response")
  rm -f "$response"
  case $http_code in
    200)
      echo "found"
      echo "$content" | jq .
    ;;
    *)
      echo "${failure} unsupported response code $http_code" >&2
      exit 1
    ;;
  esac
}

docker_image_tags() {
  image="${1}"
  filter="${2}"
  failure="[Error] get tags for $image (filter: $filter) failure:"

  image_name="${image%:*}"
  image_tag="${image##*:}"
  if [ "$image_tag" == "$image_name" ]; then
    image_tag=""
  else
    filter="--tag=$image_tag"
  fi

  local token
  token=$(hub_get_jwt_token "$image_name")

  response=$(mktemp)
  uri="${DOCKER_HUB_URI}/repositories/${image_name}/tags"
  http_code=$(curl -s -o "$response" -w "%{http_code}" -H "Authorization: JWT $token" "${uri}")
  content=$(cat "$response")
  rm -f "$response"

  tags=()
  case $http_code in
    404)
    ;;
    401)
      message=$(jq -r '.message' <<< "$content")
      echo "${failure} ${message}" >&2
      exit 1
    ;;
    200)
      case "$filter" in
        --tag=*)
          image_tag="${filter##*=}"
          if [[ "$image_tag" == *'*'* ]]; then
            if [[ "$image_tag" == \** ]]; then
              tags_list=$(jq -r --arg image_prefix "${image_tag:1}" '.results[] | select(.name | endswith($image_prefix)) | .name ' <<< "$content" | sort -V)
            else
              tags_list=$(jq -r --arg image_prefix "${image_tag::-1}" '.results[] | select(.name | startswith($image_prefix)) | .name ' <<< "$content" | sort -V)
            fi
            mapfile -t tags <<< "$tags_list"
          else
            image_tag_sha=$(jq -r --arg image_tag "$image_tag" '.results[] | select(.name == $image_tag) | .images[0].digest' <<< "$content" | sort -V)
            if [ -n "$image_tag_sha" ]; then
              tags_list=$(jq -r --arg image_tag_sha "$image_tag_sha" '.results[] | select(.images[0].digest == $image_tag_sha) | .name ' <<< "$content" | sort -V)
              mapfile -t tags <<< "$tags_list"
            fi
          fi
        ;;
        *)
          tags_list=$(jq -r '.results[].name' <<< "$content" | sort -V)
          mapfile -t tags <<< "$tags_list"
      esac
    ;;
    *)
      echo "${failure} unsupported response code $http_code" >&2
      exit 1
  esac
  echo "${tags[*]}"
}

docker_image_sha() {
  image_name="${1%:*}"
  image_tag="${1##*:}"
  failure="[Error] get sha for $1 failure:"

  if [ "$image_name" == "$image_tag" ]; then
    echo "$failure Image tag missing" >&2
    exit 1
  fi

  local jwt_token
  jwt_token=$(hub_get_jwt_token "$image_name")

  response=$(mktemp)
  uri="https://hub.docker.com/v2/repositories/${image_name}/tags/${image_tag}"
  http_code=$(curl -s -o "$response" -w "%{http_code}" -H "Authorization: JWT $jwt_token" "${uri}")
  content=$(cat "$response")
  rm -f "$response"

  sha=""
  case $http_code in
    200)
      sha=$(jq -r '.digest' <<< "$content")
    ;;
    404)
    ;;
    401)
      message=$(jq -r '.message' <<< "$content")
      echo "${failure} ${message}" >&2
      exit 1
    ;;
    *)
      echo "${failure} unsupported response code $http_code" >&2
      exit 1
  esac
  echo "$sha"
}

docker_image_remove() {
  image_list="$1"
  failure="[Error] delete image failure:"

  read -r -a images <<< "${image_list}"

  local token
  token=$(docker_api_get_jwt_token)

  for image in "${images[@]}"; do
    repository="${image%:*}"
    tag="${image##*:}"
    [ "${repository}" == "${tag}" ] && tag="latest"

    http_code=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: JWT $token" -X DELETE \
            "${DOCKER_HUB_URI}/repositories/${repository}/tags/${tag}/")
    case "$http_code" in
      204)
        echo "[Notice] delete ${repository}:${tag} successfully" >&2
      ;;
      404)
        echo "[Notice] No such image: ${repository}:${tag}" >&2
      ;;
      *)
        echo "${failure} unsupported response code $http_code" >&2
        exit 1
      ;;
    esac
  done
}



