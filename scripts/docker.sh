#!/bin/bash
set -e
set -o pipefail

# Constants
SCRIPT_PATH=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
# ##########################################
# helper functions
docker_get_image_names_from_arguments() {
  image_name=()
  read -r -a arguments <<< "${1}"
  for argument in "${arguments[@]}"; do
    case "${argument}" in
      -*)
        # Skip arguments that start with a dash (-)
        ;;
      *)
        image_name+=("${argument}")
        ;;
    esac
    shift
  done
  echo "${image_name[@]}"
}

docker_get_option_from_arguments() {
  option="${1}"
  read -r -a arguments <<< "${2}"
  option_default="${3}"

  for argument in "${arguments[@]}"; do
     case "${argument}" in
      "${option}")
        echo "${option_default}"
        return
      ;;
      "${option}="*)
        option_default="${argument##*=}"
        echo "${option_default}"
        return
      ;;
      *)
      ;;
     esac
     shift
  done
  echo ""
}

docker_parse_arguments() {
  remaining_args=()
  remote="docker.local"

  for arg in "$@"; do
    case "$arg" in
      --remote=*)
        remote="${arg#*=}"
        ;;
      --remote)
        remote="docker.hub"
        ;;
      --build-args=*)
        build_arg_file="${arg##*=}"
        if [ -f "${build_arg_file}" ]; then
          # shellcheck disable=SC2002
          build_args=$(cat "${build_arg_file}" | awk -F "=" '{ print "--build-arg " $1"="$2;}' | xargs)
          remaining_args+=("${build_args[@]}")
        else
          echo "[Error] --build-args=${build_arg_file} does not exists" >&2
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

docker_filter_tag() {
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

docker_increment_image_tag() {
  version="${1}"
  base_version="${2}"
  failure="[Error] increment image tag failure:"

  major_version=$(echo "${version}" | cut -d. -f1)
  minor_version=$(echo "${version}" | cut -d. -f2)

  if [ -n "${base_version}" ]; then
    # no TARGET_IMAGE:[TAG] given
    if [ -z "${version}" ]; then
      echo "${base_version}"
      return
    fi
    major_base=$(echo "${base_version}" | cut -d. -f1)
    minor_base=$(echo "${base_version}" | cut -d. -f2)
    if [[ ${major_base} -gt ${major_version} ]]; then
      if [[ "${version}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
          echo "${major_base}.${minor_base}.1"
          return
      elif [[ "${version}" =~ ^[0-9]+\.[0-9]+$ ]]; then
        echo "${major_base}.${minor_base}"
        return
      fi
    fi
    if [[ ${major_base} -lt ${major_version} ]]; then
      echo "${failure} --tag-increase=${base_version} major version conflict: ${base_version} cannot be lower then given TARGET_IMAGE:[TAG] tag ${version}" >&2
      exit 1
    fi
    if [[ ${minor_base} -gt ${minor_version} ]]; then
      if [[ "${version}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
          echo "${major_base}.${minor_base}.1"
          return
      elif [[ "${version}" =~ ^[0-9]+\.[0-9]+$ ]]; then
        echo "${major_base}.${minor_base}"
        return
      fi
    fi
    if [[ ${minor_base} -lt ${minor_version} ]]; then
      echo "${failure} --tag-increase=${base_version} minor version conflict: ${base_version} cannot be lower then given TARGET_IMAGE:[TAG] tag ${version}" >&2
      exit 1
    fi
  fi

  # Check if the version has the patch part (X.Y.Z format)
  if [[ "${version}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    # Extract base version (X.Y) and patch version (Z)
    patch_version=$(echo "${version}" | cut -d. -f3)

    # Increment the patch version (Z)
    patch_version=$((patch_version + 1))

    # Construct the new version as X.Y.(Z+1)
    new_version="${major_version}.${minor_version}.${patch_version}"
  # Check if the version is in X.Y format
  elif [[ "${version}" =~ ^[0-9]+\.[0-9]+$ ]]; then
    # Extract major (X) and minor (Y)
    major_version=$(echo "${version}" | cut -d. -f1)
    minor_version=$(echo "${version}" | cut -d. -f2)

    # Increment the minor version (Y)
    minor_version=$((minor_version + 1))

    # Construct the new version as X.(Y+1)
    new_version="${major_version}.${minor_version}"
  fi
  echo "${new_version}"
}

docker_incremented_image_tag() {
  target_image="${1}"
  base_tag="${2}"
  failure="[Error] docker tag incremented failure:"

  # split image into name + tag
  target_name="${target_image%%:*}"
  target_tag="${target_image#*:}"
  if [ "${target_name}" == "${target_tag}" ]; then
    target_tag=""
  fi

  if [ "${base_tag}" == "true" ]; then
    if [ -z "${target_tag}" ]; then
      echo "${failure} --tag-increase without any BASE_TAG requires a TARGET_IMAGE:TAG" >&2
      exit 1
    fi
    base_tag=""
  fi

  # Regular expression to find the version (X.Y or X.Y.Z)
  tag_regex="[0-9]+\.[0-9]+(\.[0-9]+)?"
  if [[ "${target_tag}" =~ ${tag_regex} ]]; then
    clean_target_tag=$(echo "${target_tag}" | grep -oE "${tag_regex}")
  else
    if [ -n "${target_tag}" ]; then
      echo "${failure} no valid version number in ${target_image} found" >&2
      exit 1
    fi
    clean_target_tag=${target_tag}
  fi

  new_version=$(docker_increment_image_tag "${clean_target_tag}" "${base_tag}")
  if [ -n "${new_version}" ]; then
    if [ -n "${target_tag}" ]; then
      # Replace the old version with the new version in the BASE string
      new_tag=$(echo "${target_tag}" | sed "s/${clean_target_tag}/${new_version}/")
      echo "${new_tag}"
    else
      echo "${new_version}"
    fi
  fi
}

docker_get_image_tag_level() {
  tag="${1}"
  level="${2}"
  failure="[Error] docker tag --tag-level=${level} failure:"

  major=$(echo "${tag}" | cut -d. -f1)
  minor=$(echo "${tag}" | cut -d. -f2)

  if [[ "${level}" -gt 3 ]]; then
    echo "${failure} ${level} cannot be greater than 3" >&2
    exit 1
  elif [[ "${level}" -eq 3 ]]; then
    if [ "${tag}" = "${major}" ]; then
      echo "${failure} ${level} requires a patch version, given tag: ${tag} " >&2
      exit 1
    elif [ "${tag}" = "${major}.${minor}" ]; then
      echo "${failure} ${level} requires a patch version, given tag: ${tag} " >&2
      exit 1
    fi
    tags=("${tag}" "${major}.${minor}" "${major}")
  elif [[ "${level}" -eq 2 ]]; then
    if [ "${tag}" == "${major}" ]; then
      echo "${failure} requires a minor version, given tag: ${tag} " >&2
      exit 1
    fi
    tags=("${major}.${minor}" "${major}")
  else
    tags=("${tag}")
  fi
  echo "${tags[*]}"
}

# helper functions
# ##########################################

# ##########################################
# base methods
handle_image_tags() {
  cmd=${cmd//image tags /}; cmd=${cmd//tags /};
  images=$(docker_get_image_names_from_arguments "$cmd")
  images="${images[*]}"

  tag_list=$(docker_image_tags "$images")

  format=$(docker_get_option_from_arguments "--format" "$cmd")
  latest=$(docker_get_option_from_arguments "--latest" "$cmd" "true")
  case "$format" in
    patch)
      pattern="([0-9]+)\.([0-9]+)\.([0-9]+)"
      tag_list=$(docker_filter_tag "$tag_list" "$pattern" "$latest")
    ;;
    minor)
      pattern="([0-9]+)\.([0-9]+)"
      tag_list=$(docker_filter_tag "$tag_list" "$pattern" "$latest")
    ;;
    major)
      pattern="([0-9]+)"
      tag_list=$(docker_filter_tag "$tag_list" "$pattern" "$latest")
    ;;
  esac

  output=$(docker_get_option_from_arguments "--with-image-name" "$cmd" "true")
  tag_pre_fix=""
  if [ -n "$output" ]; then
    local image_name
    image_name="${images%%:*}"
    tag_pre_fix="${image_name}:"
  fi

  read -r -a tags <<< "$tag_list"
  for tag in "${tags[@]}"; do
    echo "${tag_pre_fix}${tag}"
  done
}

handle_image_sha() {
  cmd=${cmd//image sha /};
  images=$(docker_get_image_names_from_arguments "$cmd")
  sha=$(docker_image_sha "$images")
  echo "$sha"
}

handle_image_rmi() {
  cmd=${cmd//image rm /}; cmd=${cmd//rm /};
  images=$(docker_get_image_names_from_arguments "$cmd")
  docker_image_remove "$images"
}

handle_image_tag() {
  cmd=${cmd//image tag /}; cmd=${cmd//tag /};
  failure="[Error] docker tag failure:"
  images=$(docker_get_image_names_from_arguments "$cmd")
  read -r -a image <<< "$images"

  source_image="${image[0]}"
  if [ -z "${source_image}" ]; then
    echo "$failure requires exactly 2 arguments, SOURCE_IMAGE[:TAG] missing" >&2
    exit 1
  fi
  target_image="${image[1]}"
  if [ -z "${target_image}" ]; then
    echo "$failure requires exactly 2 arguments, TARGET_IMAGE[:TAG] missing" >&2
    exit 1
  fi

  option_tag_increase=$(docker_get_option_from_arguments "--tag-increase" "${cmd}" "true")
  if [ -n "${option_tag_increase}" ]; then
    new_image_tag=$(docker_incremented_image_tag "${target_image}" "${option_tag_increase}")
  else
    target_tag="${target_image#*:}"
    if [ "${target_image}" == "${target_tag}" ]; then
      echo "$failure --tag-level requires OPTION --tag-increase OR a TARGET_IMAGE:TAG" >&2
      exit 1
    fi
    new_image_tag="${target_tag}"
  fi
  option_tag_level=$(docker_get_option_from_arguments "--tag-level" "${cmd}" "1")
  if [ -n "${option_tag_level}" ] && [[ "${option_tag_level}" -gt 1 ]]; then
    new_image_tag=$(docker_get_image_tag_level "${new_image_tag}" "${option_tag_level}")
  fi

  option_dry_run=$(docker_get_option_from_arguments "--dry-run" "${cmd}" "true")

  read -r -a new_image_tags <<< "${new_image_tag}"
  target_image_name="${target_image%%:*}"
  for target_tag in "${new_image_tags[@]}"; do
    new_target_image="${target_image_name}:${target_tag}"
    if [ -n "${option_dry_run}" ]; then
      echo "docker image tag ${source_image} ${new_target_image}"
    else
      docker image tag "${source_image}" "${new_target_image}"
    fi
  done
}
# base methods
# ##########################################

# ##########################################
# Main
read -r interpreter cmd <<< "$(docker_parse_arguments "$@")"

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