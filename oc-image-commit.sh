#!/bin/bash

set -eu

if [ "$#" -eq 1 ]; then
    RELEASE_IMAGE="registry.svc.ci.openshift.org/origin/release:4.2"
    CLUSTER_IMAGE_NAME="$1"
else
    RELEASE_IMAGE=$1
    CLUSTER_IMAGE_NAME=$2
fi

CLUSTER_IMAGE_REF="$(oc adm release info --image-for=$CLUSTER_IMAGE_NAME $RELEASE_IMAGE)"

echo
echo "Cluster image: $CLUSTER_IMAGE_REF"
echo "$CLUSTER_IMAGE_NAME commit in $RELEASE_IMAGE:"
echo $(oc image info --output json "$CLUSTER_IMAGE_REF" | jq --raw-output '.config.config.Labels["vcs-url"] + "/commits/" + .config.config.Labels["vcs-ref"]')
