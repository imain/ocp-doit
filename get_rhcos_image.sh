#!/usr/bin/env bash
set -eu
set -o pipefail

IMAGE_URL="$(curl --silent https://raw.githubusercontent.com/openshift/installer/master/data/data/rhcos.json | jq --raw-output '.baseURI + .images.openstack.path')"

echo "Downloading RHCOS image from:"
echo "$IMAGE_URL"

curl --insecure --compressed -L -O "$IMAGE_URL"
