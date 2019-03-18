#!/bin/bash

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
USER=`whoami`

CONFIG=${CONFIG:-config.sh}
if [ ! -r "$CONFIG" ]; then
    echo "Could not find ocp-doit configuration file."
    echo "Make sure $CONFIG file exists in the ocp-doit directory and that it is readable"
    exit 1
fi
source $CONFIG
cat $CONFIG

export REGISTRY=${REGISTRY:-$LOCAL_IP:8787}
export REPO=${REPO:-$REGISTRY/openshift}

export RHCOS_IMAGE_VERSION="${RHCOS_IMAGE_VERSION:-47.188}"
export RHCOS_IMAGE_NAME="redhat-coreos-maipo-${RHCOS_IMAGE_VERSION}"
export RHCOS_IMAGE_FILENAME="${RHCOS_IMAGE_NAME}-openstack.qcow2"

# NOTE(flaper87): Hardcoding the CI release image until we stabilize OpenStack based deployments.
# This forces the installer to use the latest release image built in CI and, therefore, pick the latest
# images built for every component. There should not be propagation delays for component's images when
# using this release image.
export OPENSHIFT_INSTALL_RELEASE_IMAGE_OVERRIDE="registry.svc.ci.openshift.org/openshift/origin-release:v4.0"

# We are pinning to upstream tripleo version.  This has passed CI promotion.
# We'll have to check once in a while for a new version though.
TRIPLEO_VERSION='54c5a6de8ce5b9cfae83632a7d81000721d56071_786d88d2'
