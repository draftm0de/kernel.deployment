#!/bin/bash
set -e
set -o pipefail

echo "/converter/patch-version.sh" 1>&2

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
src_dir="$script_dir/../../src"

version="${1}"
silent=""
latest=""
for arg in "$@"; do
  case "$arg" in
    --silent)
      echo "> arg: $arg" 1>&2
      silent=$arg
    ;;
    --latest=*)
      echo "> arg: $arg" 1>&2
      latest="${arg#*=}"
    ;;
  esac
done

source ${src_dir}/converter/branch-to-version.sh "${version}" &>/dev/null
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
  base_patch="$PATCH"
  base_postfix="$POSTFIX"
  BRANCH=""
  if [ -n "${latest}" ]; then
    echo "> --latest given: yes (${latest})" 1>&2
    source ${src_dir}/converter/branch-to-version.sh "${latest}" &>/dev/null
    if [ -n "${BRANCH}" ]; then
      echo "> > latest ${latest} matches version patterns: yes" 1>&2
      echo "> > prefix: ${PREFIX}" 1>&2
      echo "> > major: ${MAJOR}" 1>&2
      echo "> > minor: ${MINOR}" 1>&2
      echo "> > patch: ${PATCH}" 1>&2
      echo "> > postfix: ${POSTFIX}" 1>&2
      latest_prefix="$PREFIX"
      latest_major="$MAJOR"
      latest_minor="$MINOR"
      latest_patch="$PATCH"
      latest_postfix="$POSTFIX"
      BRANCH="${latest_prefix}${latest_major}"
      if [ -z "${failure}" ] && [ $latest_major -gt $base_major ]; then
        failure="latest major $latest_major > base major $base_major"
      fi
      if [ -z "${failure}" ] && [ $base_major -eq $latest_major ] && [ $latest_minor -gt $base_minor ]; then
        failure="latest minor $latest_minor > base minor $base_minor"
      fi
      if [ -z "${failure}" ]; then
        if [ $base_major -gt $latest_major ]; then
          echo "> > > base major $base_major > latest major $latest_major" 1>&2
          latest_major="$base_major"
          latest_minor="0"
          if [ -n "${latest_patch}" ]; then
            latest_minor="1"
            latest_patch="0"
          fi
        elif [ $base_minor -gt $latest_minor ]; then
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
      if [ -n "${silent}" ]; then
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
      MINOR="1"
      PATCH=""
      BRANCH="${BRANCH}.1"
    elif [ -z "${base_patch}" ]; then
      echo "> > minor version: yes" 1>&2
      echo "> > patch version: no" 1>&2
      PATCH=1
      BRANCH="${BRANCH}.${base_minor}.1"
    fi
    POSTFIX="${base_postfix}"
  fi
  BRANCH="${BRANCH}${POSTFIX}"
  echo "> result: ${BRANCH}" 1>&2
else
  echo "> version ${version} matches version patterns: no" 1>&2
  if [ -n "${silent}" ]; then
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
  echo "$BRANCH"
fi
