#!/usr/bin/env bash
set -xe

source common.sh

RHCOS_IMAGE_VERSION="${RHCOS_IMAGE_VERSION:-47.188}"
RHCOS_IMAGE_NAME="redhat-coreos-maipo-${RHCOS_IMAGE_VERSION}"
RHCOS_IMAGE_FILENAME="${RHCOS_IMAGE_NAME}-openstack.qcow2"
if [ ! -f "$RHCOS_IMAGE_FILENAME" ]; then
    curl --insecure --compressed -L -o "${RHCOS_IMAGE_FILENAME}" "https://releases-redhat-coreos-dev.cloud.paas.upshift.redhat.com/storage/releases/maipo/${RHCOS_IMAGE_VERSION}/${RHCOS_IMAGE_FILENAME}".gz
fi
