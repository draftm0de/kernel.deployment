#!/bin/bash
set -e
set -o pipefail

docker_image_tags() {
  image="${1}"
  filter="${2}"

  image_name="${image%:*}"
  image_tag="${image##*:}"
  if [ "$image_tag" == "$image_name" ]; then
    image_tag=""
  else
    filter="--tag=$image_tag"
  fi

  content=$(docker images "${image_name}" --format="{{ .Tag }}")
  exit=$?
  if [ $exit -ne 0 ]; then
    exit $exit
  fi

  tags=()
  case $filter in
    --tag=*)
      image_tag="${filter##*=}"
      if [[ "$image_tag" == *'*'* ]]; then
        if [[ "$image_tag" == \** ]]; then
          tags_list=$(echo "$content" | grep ".${image_tag:1}" | sort -V)
        else
          tags_list=$(echo "$content" | grep "${image_tag::-1}." | sort -V)
        fi
        mapfile -t tags <<< "$tags_list"
      else
        image_sha=$(docker_image_sha "$image")
        exit=$?
        if [ $exit -ne 0 ]; then
          exit $exit
        fi
        if [ -n "$image_sha" ]; then
          mapfile -t in_image_tags <<< "$content"
          for in_image_tag in "${in_image_tags[@]}"; do
            image_tag_sha=$(docker_image_sha "${image_name}:${in_image_tag}")
            exit=$?
            if [ $exit -ne 0 ]; then
              exit $exit
            fi
            if [ "$image_tag_sha" == "$image_sha" ]; then
              tags+=("${in_image_tag}")
            fi
          done
        fi
      fi
    ;;
    *)
      tags_list=$(echo "$content" | sort -V)
      mapfile -t tags <<< "$tags_list"
    ;;
  esac
  echo "${tags[*]}"
}

docker_image_sha() {
  image="${1}"

  sha=$(docker inspect --format="{{.Id}}" "$image")
  exit=$?
  if [ $exit -ne 0 ]; then
    exit $exit
  fi
  echo "${sha}"
}

docker_image_remove() {
  read -r -a image_list <<< "$*"

  for image in "${image_list[@]}"; do
    docker rmi "${image}"
  done
}