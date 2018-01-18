#!/bin/bash

exiterr() { echo "Error: ${1}" >&2; exit 1; }

# Gather parameters
if [ $# -eq 0 ];then
	exiterr "No argument supplied"
fi
build_tag=$1

# Verify provided parameters
echo TAG: "${build_tag:?}"

set -e
set -x

DOCKER_SRC_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

pushd $DOCKER_SRC_DIR
docker build --no-cache -t $build_tag .
popd
