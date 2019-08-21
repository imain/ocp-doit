#!/bin/bash

#
# This script is a temporary thing to work out what's necessary to epose the
# API properly. This really should be automated by the installer next.
#

set -ex

source ocp_install_env.sh
source common.sh

LB_FLOATING_IP=$(openstack server show ${CLUSTER_NAME}-api -f value -c addresses | cut -d " " -f 2)

echo "Attempting to expose cluster's API on floating IP: ${LB_FLOATING_IP}" | highlight

if ! grep -q ${LB_FLOATING_IP} /etc/hosts ; then
    (echo "${LB_FLOATING_IP} api.${CLUSTER_NAME}.shiftstack.com" && grep -v "api.${CLUSTER_NAME}.shiftstack.com" /etc/hosts) | sudo tee /etc/hosts
fi
