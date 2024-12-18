#!/bin/bash
set -e
set -o pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
base_path="$script_dir/../"

for arg in "$@"; do
  case "$arg" in
    --target=*)
      echo "> arg: $arg" 1>&2
      target="${arg#*=}"
    ;;
    --source=*)
      echo "> arg: $arg" 1>&2
      source="${arg#*=}"
    ;;
    --stage=*)
      echo "> arg: $arg" 1>&2
      stage="${arg#*=}"
    ;;
    --version=*)
      echo "> arg: $arg" 1>&2
      version="${arg#*=}"
    ;;
    --digest=*)
      echo "> arg: $arg" 1>&2
      digest="${arg#*=}"
    ;;
  esac
done

if [ -z "${source}" ]; then
  echo "argument --source= missing"
  exit 9
fi
if [ -z "${target}" ]; then
  echo "argument --target= missing"
  exit 9
fi
if [ -z "${version}" ]; then
  echo "argument --version missing"
  exit 9
fi

if "$base_path/version/read.sh" "${source}" "--silent" 2>/dev/null; then
  echo "source branch <${source:-}> does not fit requirements for auto tagging"
  exit 1
fi
if ! "$base_path/version/read.sh" "${target}" "--expect=major" "--silent" 2>/dev/null; then
  echo "target branch <${target:-}> does not fit requirements for auto tagging"
  exit 1
fi

if [ -n "${stage}" ]; then
  version="${version}-${stage}"
fi
target_tag_major=$("$base_path/file/argument.sh" "${version}" "+MAJOR" 2>/dev/null)
if [ -z "${target_tag_major}" ]; then
  echo "argument MAJOR in tag version file <${version}> missing"
  exit 9
fi
target_tag_minor=$("$base_path/file/argument.sh" "${version}" "+MINOR" 2>/dev/null)
if [ -z "${target_tag_minor}" ]; then
  echo "argument MINOR in tag version file <${version}> missing"
  exit 9
fi
echo "> content based major tag: ${target_tag_major}" 1>&2
echo "> content based minor tag: ${target_tag_minor}" 1>&2

target_tag="${target_tag_major}.${target_tag_minor}"
target_tag_major_filter="${target_tag_major}"
if [ -n "${stage}" ]; then
  target_tag_major_filter="${target_tag_major_filter}-${stage}"
  target_tag="${target_tag}-${stage}"
fi

target_tag_digest=$("$base_path/git/list-tags.sh" "--message=${target_tag}" 2>/dev/null)
echo "> target tag <${target_tag}> digest: $target_tag_digest" 1>&2
echo "> image build digest: ${digest}" 1>&2

if [ "${target_tag_digest}" != "${digest}" ]; then
  target_tag_minor_latest=$("$base_path/git/list-tags.sh" "--branch=${target_tag_major_filter}" "--latest" 2>/dev/null)
  echo "> latest minor tag for target <${target}>: ${target_tag_minor_latest}" 1>&2
  target_tag_patch_latest=$("$base_path/git/list-tags.sh" "--branch=${target_tag}" "--latest" 2>/dev/null)
  echo "> latest patch tag for target <${target}>: ${target_tag_patch_latest}" 1>&2
  tags=$("$base_path/version/patch.sh" "${target_tag_patch_latest:-${target_tag}}" "--previous=${target_tag_minor_latest}" 2>/dev/null)
  echo "${tags[*]}"
else
  echo "latest target tag <${target_tag}> digest is equal to build image digest"
  exit 1
fi
