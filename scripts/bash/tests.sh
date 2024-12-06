#!/bin/bash
set -e
set -o pipefail

echo "> converter/explode-docker-image-name"
source ./tests/converter/explode-docker-image-name.sh

echo "> converter/explode-git-branch-to-version"
source ./tests/converter/explode-git-branch-to-version.sh