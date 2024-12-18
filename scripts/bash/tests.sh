#!/bin/bash
set -e
set -o pipefail

source "./src/shunit.sh"

main_tags=("1.0" "1.0.1" "1.0.x1" "1.0.2" "1.0.3" "1.1" "1.1.1" "no.version")

scripts=()
scripts+=("./tests/file/argument.sh")
scripts+=("./tests/git/list-tags.sh")
#scripts+=("./tests/image/explode-name.sh")
scripts+=("./tests/version/read.sh")
scripts+=("./tests/version/patch.sh")
#scripts+=("./tests/workflow/tag-by-file.sh")

shTests
