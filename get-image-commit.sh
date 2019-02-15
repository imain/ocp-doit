#!/bin/bash

set -eu

RELEASE_IMAGE=$1
CLUSTER_IMAGE_NAME=$2

CLUSTER_IMAGE="$(podman run --rm $RELEASE_IMAGE image $CLUSTER_IMAGE_NAME)"

podman pull "$CLUSTER_IMAGE"

echo
echo "$CLUSTER_IMAGE_NAME commit in $RELEASE_IMAGE:"
echo "$(podman inspect -f '{{ index .Labels "vcs-url" }}' $CLUSTER_IMAGE)/commit/$(podman inspect -f '{{ index .Labels "vcs-ref" }}' $CLUSTER_IMAGE)"
