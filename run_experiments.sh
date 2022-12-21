#!/bin/bash

# ----- PREAMBLE ----------------------------------------------------------------------------------------------------- #
SCRIPT_DIR="$(dirname "$0")"
source "${SCRIPT_DIR}"/scripts/util.sh
check_if_dependencies_are_present docker

# ----- SCRIPT ------------------------------------------------------------------------------------------------------- #
IMAGE_NAME=btenmann/"$(basename "${SCRIPT_DIR}")":latest
docker run --rm -v "${SCRIPT_DIR}":/workdir "${IMAGE_NAME}"
