#!/bin/bash
set -e
set -o pipefail

echo "> dto/docker-image-name-dto"
source ./tests/dto/docker-image-name-dto.sh

echo "> dto/git-branch-version-dto"
source ./tests/dto/git-branch-version-dto.sh