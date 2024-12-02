#!/bin/bash
set -e
set -o pipefail

build_args_file=".build_args"
if [ -f "$build_args_file" ]; then
  # Read the arguments from the file
  args=$(cat $build_args_file | sed 's/^/--build-arg /' | tr '\n' ' ')
  echo "$args"
fi