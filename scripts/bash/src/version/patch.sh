#!/bin/bash
set -e
set -o pipefail

echo "/version/patch.sh" 1>&2

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
src_dir="$script_dir/../../src"

version="${1}"
option_silent=""
option_depth=""
latest=""
for arg in "$@"; do
  case "$arg" in
    --silent)
      echo "> arg: $arg" 1>&2
      option_silent=$arg
    ;;
    --latest=*)
      echo "> arg: $arg" 1>&2
      latest="${arg#*=}"
    ;;
    --depth=*)
      echo "> arg: $arg" 1>&2
      option_depth="${arg#*=}"
    ;;
  esac
done

source ${src_dir}/version/convert.sh "${version}" &>/dev/null
if [ -n "${BRANCH}" ]; then
  echo "> version ${version} matches version patterns: yes" 1>&2
  echo "> prefix: ${PREFIX}" 1>&2
  echo "> major: ${MAJOR}" 1>&2
  echo "> minor: ${MINOR}" 1>&2
  echo "> patch: ${PATCH}" 1>&2
  echo "> postfix: ${POSTFIX}" 1>&2
  base_prefix="$PREFIX"
  base_major="$MAJOR"
  base_minor="$MINOR"
  #base_minor_latest=""
  base_patch="$PATCH"
  base_postfix="$POSTFIX"
  #if [ -n "${depth}" ]; then
  #  base_minor_latest=$("$src_dir/git/read-tags.sh" "--branch=${base_prefix}${base_major}${base_postfix}" "--latest" 2>/dev/null)
  #fi
  BRANCH=""
  if [ -n "${latest}" ]; then
    echo "> --latest given: yes (${latest})" 1>&2
    source ${src_dir}/converter/branch-to-version.sh "${latest}" &>/dev/null
    if [ -n "${BRANCH}" ]; then
      echo "> > latest ${latest} matches version patterns: yes" 1>&2
      echo "> > prefix: ${PREFIX}" 1>&2
      echo "> > major: ${MAJOR}" 1>&2
      echo "> > minor: ${MINOR}" 1>&2
      if [ "${depth:-0}" -eq 3 ] && [ -z "${PATCH}" ]; then
        echo "> > patch: 0 (depth 3 and no patch => 0)" 1>&2
        PATCH="0"
      else
        echo "> > patch: ${PATCH}" 1>&2
      fi
      echo "> > postfix: ${POSTFIX}" 1>&2
      latest_prefix="$PREFIX"
      latest_major="$MAJOR"
      latest_minor="$MINOR"
      latest_patch="$PATCH"
      latest_postfix="$POSTFIX"
      BRANCH="${latest_prefix}${latest_major}"
      if [ -z "${failure}" ] && [ ${latest_major:-0} -gt ${base_major:-0} ]; then
        failure="latest major $latest_major > base major $base_major"
      fi
      if [ -z "${failure}" ] && [ ${base_major:-0} -eq ${latest_major:-0} ] && [ ${latest_minor:-0} -gt ${base_minor:-${latest_minor:-0}} ]; then
        failure="latest minor $latest_minor > base minor $base_minor"
      fi
      if [ -z "${failure}" ]; then
        if [ ${base_major:-0} -gt ${latest_major:-0} ]; then
          echo "> > > base major $base_major > latest major $latest_major" 1>&2
          latest_major="$base_major"
          latest_minor="0"
          if [ -n "${latest_patch}" ]; then
            latest_minor="1"
            latest_patch="0"
          fi
        elif [ ${base_minor:-0} -gt ${latest_minor:-0} ]; then
          echo "> > > base minor $base_minor > latest minor $latest_minor" 1>&2
          latest_minor="$base_minor"
          if [ -n "${latest_patch}" ]; then
            if [ -n "${base_patch}" ]; then
              echo "> > > base has patch (patch from base)" 1>&2
              latest_patch="${base_patch}"
            else
              echo "> > > base has patch (set patch=0)" 1>&2
              latest_patch="0"
            fi
          else
            echo "> > > latest has no patch" 1>&2
          fi
        fi
        if [ -n "${latest_patch}" ]; then
          echo "> > > increase patch version" 1>&2
          BRANCH="${BRANCH}.${latest_minor}"
          PATCH=$((latest_patch + 1))
          BRANCH="${BRANCH}.${PATCH}"
        elif [ -n "${latest_minor}" ]; then
          echo "> > > increase minor version" 1>&2
          MINOR=$((latest_minor + 1))
          BRANCH="${BRANCH}.${MINOR}"
        fi
        POSTFIX="${latest_postfix}"
      else
        echo "> > > ${failure}" 1>&2
        BRANCH=""
        PREFIX=""
        MAJOR=""
        MINOR=""
        PATCH=""
        POSTFIX=""
      fi
    else
      echo "> > latest ${latest} matches version patterns: no" 1>&2
      if [ -n "${option_silent}" ]; then
        exit 1
      fi
    fi
  else
    echo "> --latest given: no" 1>&2
    BRANCH="${base_prefix}${base_major}"
    PREFIX="${base_prefix}"
    MAJOR="${base_major}"
    if [ -z "${base_minor}" ]; then
      echo "> > minor version: no" 1>&2
      MINOR="0"
      PATCH=""
      BRANCH="${BRANCH}.${MINOR}"
    elif [ -z "${base_patch}" ]; then
      echo "> > minor version: yes" 1>&2
      echo "> > patch version: no" 1>&2
      PATCH="0"
      BRANCH="${BRANCH}.${base_minor}.${PATCH}"
    fi
    POSTFIX="${base_postfix}"
  fi
  BRANCH="${BRANCH}${POSTFIX}"
else
  echo "> version ${version} matches version patterns: no" 1>&2
  if [ -n "${option_silent}" ]; then
    exit 1
  fi
fi

export PREFIX
export MAJOR
export MINOR
export PATCH
export POSTFIX
export BRANCH

if [ -n "${BRANCH}" ]; then
  branches=()
  tag_major="${PREFIX}${MAJOR}${POSTFIX}"
  case "$option_depth" in
    3)
      MINOR=${MINOR:-0}
      PATCH=${PATCH:-0}
      tag_minor="${PREFIX}${MAJOR}.${MINOR}${POSTFIX}"
      tag_patch="${PREFIX}${MAJOR}.${MINOR}.${PATCH}${POSTFIX}"
      echo "> tag patch: yes (${tag_patch})" 1>&2
      branches+=("${tag_patch}")
      #minor_latest=$(printf "%s\n" "$base_minor_latest" "$tag_minor" | sort -V | tail -n 1)
      #if [ "${minor_latest}" == "${tag_minor}" ]; then
      echo "> tag minor: yes (${tag_minor})" 1>&2
      branches+=("${tag_minor}")
      echo "> tag major: yes (${tag_major})" 1>&2
      branches+=("${tag_major}")
      #else
      #  echo "> tag minor: no (latest minor ${base_minor_latest} > new minor ${tag_minor})" 1>&2
      #  echo "> tag major: no (latest minor ${base_minor_latest} > new minor ${tag_minor})" 1>&2
      #fi
    ;;
    2)
      MAJOR=${MAJOR:-1}
      MINOR=${MINOR:-0}
      tag_minor="${PREFIX}${MAJOR}.${MINOR}${POSTFIX}"
      if [ -n "${PATCH}" ]; then
        tag_patch="${PREFIX}${MAJOR}.${MINOR}.${PATCH}${POSTFIX}"
        echo "> tag patch: yes (${tag_patch})" 1>&2
        branches+=("${tag_patch}")
        #minor_latest=$(printf "%s\n" "$base_minor_latest" "$tag_minor" | sort -V | tail -n 1)
        #if [ "${minor_latest}" == "${tag_minor}" ]; then
        echo "> tag minor: yes (${tag_minor})" 1>&2
        branches+=("${tag_minor}")
        #else
        #  echo "> tag minor: no (latest minor ${base_minor_latest} > new minor ${tag_minor})" 1>&2
        #fi
      else
        echo "> tag major: yes (${tag_major})" 1>&2
        branches+=("${tag_major}")
        echo "> tag minor: yes (${tag_minor})" 1>&2
        branches+=("${tag_minor}")
      fi
    ;;
    *)
      echo "> result: ${BRANCH}" 1>&2
      branches=("$BRANCH")
  esac
  # output tags
  for branch in "${branches[@]}"; do
    echo "$branch"
  done
fi
