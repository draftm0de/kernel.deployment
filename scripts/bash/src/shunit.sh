#!/bin/bash
set -e
set -o pipefail

shTest() {
  local source source_print expected arguments response
  source="${1}"
  source_print=$(basename $source)
  shift
  expected="${1}"
  shift
  arguments="${*}"
  if [[ "${expected}" == "{file"*"}" ]]; then
    expected="${expected#\{file:}"
    expected="${expected%\}}"
    if [ -f "${expected}" ]; then
      expected=$(cat "${expected}")
    else
      echo "${source_print} [${arguments}] failure, expected {file:} does not exist"
      return
    fi
  fi
  if [ "${expected}" == "{true}" ] || [ "${expected}" == "{false}" ]; then
    if [ -n "${debugMode}" ]; then
      if ${source} $arguments; then
        if [ "${expected}" == "{true}" ]; then
          echo "${source_print} [${arguments}] successful"
        else
          echo "${source_print} [${arguments}] failure"
        fi
      else
        if [ "${expected}" == "{false}" ]; then
          echo "${source_print} [${arguments}] successful"
        else
          echo "${source_print} [${arguments}] failure"
        fi
      fi
    else
      if ${source} $arguments 2>/dev/null; then
        if [ "${expected}" == "{true}" ]; then
          echo "${source_print} [${arguments}] successful"
        else
          echo "${source_print} [${arguments}] failure"
        fi
      else
        if [ "${expected}" == "{false}" ]; then
          echo "${source_print} [${arguments}] successful"
        else
          echo "${source_print} [${arguments}] failure"
        fi
      fi
    fi
  else
    if [ -n "${debugMode}" ]; then
      # shellcheck disable=SC1090
      response=$(source "${source}" $arguments)
    else
      # shellcheck disable=SC1090
      response=$(source "${source}" $arguments 2>/dev/null)
    fi
    if [ "$response" == "$expected" ]; then
      echo "${source_print} [${arguments}] successful"
    else
      echo "${source_print} [${arguments}] failure (response: $response, expected: $expected)"
    fi
  fi
}

setup() {
  if [ -n "${main_tags[*]}" ]; then
    for tag in "${main_tags[@]}"; do
      git tag -f "${tag}" main &>/dev/null
    done
  fi
}

teardown() {
  if [ -n "${main_tags[*]}" ]; then
    for tag in "${main_tags[@]}"; do
      git tag -d "${tag}" &>/dev/null
    done
  fi
}

shTests() {
  if [ -n "${scripts[*]}" ]; then
    setup
    for script in "${scripts[@]}"; do
      if [ -z "${1}" ] || [ "${1}" == "${script}" ]; then
        echo "-------------------- ${script} --------------------"
        source "./tests/${script}.sh"
      fi
    done
    teardown
  fi
}