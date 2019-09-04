#!/bin/bash

set -eu

if [ "$#" -eq 1 ]; then
    RELEASE_IMAGE="registry.svc.ci.openshift.org/origin/release:4.2"
    CLUSTER_IMAGE_NAME="$1"
else
    RELEASE_IMAGE=$1
    CLUSTER_IMAGE_NAME=$2
fi

podman pull "$RELEASE_IMAGE"

CLUSTER_IMAGE="$(podman run --rm $RELEASE_IMAGE image $CLUSTER_IMAGE_NAME)"

podman pull "$CLUSTER_IMAGE"

echo
echo "$CLUSTER_IMAGE_NAME commit in $RELEASE_IMAGE:"
echo "$(podman inspect -f '{{ index .Labels "vcs-url" }}' $CLUSTER_IMAGE)/commit/$(podman inspect -f '{{ index .Labels "vcs-ref" }}' $CLUSTER_IMAGE)"
echo "$(podman inspect -f '{{ index .Labels "vcs-url" }}' $CLUSTER_IMAGE)/commits/$(podman inspect -f '{{ index .Labels "vcs-ref" }}' $CLUSTER_IMAGE)"
