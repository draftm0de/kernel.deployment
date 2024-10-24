#!/bin/bash
set -e
set -o pipefail

# Constants
SCRIPT_PATH=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
# ##########################################
# helper functions
helper_get_image_names_from_arguments() {
  IMAGE_NAME=()
  # shellcheck disable=SC2206
  ARGS=(${1})
  for arg in "${ARGS[@]}"; do
    case "$arg" in
      -*)
        # Skip arguments that start with a dash (-)
        ;;
      *)
        IMAGE_NAME+=("$arg")
        ;;
    esac
    shift
  done
  echo "${IMAGE_NAME[@]}"
}

helper_get_option_from_arguments() {
  local OPTION="${1}"
  # shellcheck disable=SC2206
  local ARGS=(${2})
  local OPTION_DEFAULT="${3}"

  for arg in "${ARGS[@]}"; do
     case "$arg" in
      "${OPTION}")
        echo "$OPTION_DEFAULT"
        return
      ;;
      "${OPTION}="*)
        local OPTION_DEFAULT="${arg##*=}"
        echo "$OPTION_DEFAULT"
        return
      ;;
      *)
      ;;
     esac
     shift
  done
  echo ""
}

helper_parse_arguments() {
  local -a remaining_args=()
  local remote="docker.local"

  for arg in "$@"; do
    case "$arg" in
      --remote=*)
        remote="${arg#*=}"
        ;;
      --remote)
        remote="docker.hub"
        ;;
      --build-args=*)
        BUILD_ARG_FILE="${arg##*=}"
        if [ -f "$BUILD_ARG_FILE" ]; then
          # shellcheck disable=SC2002
          BUILD_ARGS=$(cat "$BUILD_ARG_FILE" | awk -F "=" '{ print "--build-arg " $1"="$2;}' | xargs)
          remaining_args+=("${BUILD_ARGS[@]}")
        else
          echo "[Error] --build-args=$BUILD_ARG_FILE does not exists" >&2
          exit 1
        fi
      ;;
      *)
        remaining_args+=("$arg")
        ;;
    esac
  done
  echo "$remote" "${remaining_args[@]}"
}

helper_filter_tag() {
  tag_list="${1}"
  pattern="${2}"
  latest="${3}"
  read -r -a tags <<< "$tag_list"

  matching_tags=()
  for tag in "${tags[@]}"; do
    if [[ "$tag" =~ ^([a-zA-Z0-9-]*)?${pattern}$ ]]; then
      matching_tags+=("$tag")
    fi
  done
  if [ -n "$latest" ]; then
    latest_tag=$(echo "${matching_tags[@]}" | tr ' ' '\n' | sed -E 's/^[a-zA-Z0-9-]*//' | sort -V | tail -n 1)
    for tag in "${matching_tags[@]}"; do
      if [[ "$tag" =~ $latest_tag$ ]]; then
        echo "$tag"
        break
      fi
    done
  else
    echo "${matching_tags[@]}"
  fi
}
# helper functions
# ##########################################

# ##########################################
# base methods
handle_image_tags() {
  cmd=${cmd//image tags /}; cmd=${cmd//tags /};
  images=$(helper_get_image_names_from_arguments "$cmd")

  tag_list=$(docker_image_tags "$images")

  format=$(helper_get_option_from_arguments "--format" "$cmd")
  latest=$(helper_get_option_from_arguments "--latest" "$cmd" "true")
  case "$format" in
    patch)
      pattern="([0-9]+)\.([0-9]+)\.([0-9]+)"
      tag_list=$(helper_filter_tag "$tag_list" "$pattern" "$latest")
    ;;
    minor)
      pattern="([0-9]+)\.([0-9]+)"
      tag_list=$(helper_filter_tag "$tag_list" "$pattern" "$latest")
    ;;
    major)
      pattern="([0-9]+)"
      tag_list=$(helper_filter_tag "$tag_list" "$pattern" "$latest")
    ;;
  esac

  read -r -a tags <<< "$tag_list"
  for tag in "${tags[@]}"; do
    echo "$tag"
  done
}

handle_image_sha() {
  cmd=${cmd//image sha /};
  images=$(helper_get_image_names_from_arguments "$cmd")
  sha=$(docker_image_sha "$images")
  echo "$sha"
}

handle_image_rmi() {
  cmd=${cmd//image rm /}; cmd=${cmd//rm /};
  images=$(helper_get_image_names_from_arguments "$cmd")
  docker_image_remove "$images"
}

handle_image_tag() {
  cmd=${cmd//image tag /}; cmd=${cmd//tag /};
}
# base methods
# ##########################################

# ##########################################
# Main
read -r interpreter cmd <<< "$(helper_parse_arguments "$@")"

# Include custom docker command interpreter
script_file="${SCRIPT_PATH}/interpreter/${interpreter}.sh"
if [ -f "${script_file}" ]; then
  # shellcheck disable=SC1090
  source "${script_file}"
else
  echo "[Error] interpreter/${interpreter}.sh is not implemented" >&2
  exit 1
fi

command=("-")
case "$cmd" in
  "image tags "*|"tags "*)
    handle_image_tags
  ;;
  "rmi "*|"image rm "*)
    handle_image_rmi
  ;;
  "image sha "*)
    handle_image_sha
  ;;
  "image tag "*|"tag "*)
    handle_image_tag
  ;;
  *)
    cmd="docker $cmd"
    read -r -a command <<< "${cmd}"
  ;;
esac

if [ "${command[*]}" != "-" ]; then
  result=$("${command[@]}")
  if [ -n "${result}" ]; then
    echo "${result}"
  fi
fi