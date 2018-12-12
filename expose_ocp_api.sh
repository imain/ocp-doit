#!/bin/bash

#
# This script is a temporary thing to work out what's necessary to epose the
# API properly. This really should be automated by the installer next.
#

set -ex

source ocp_install_env.sh
source common.sh

if [ "${LB_FLOATING_IP}" = "" ] ; then
    echo "Please set LB_FLOATING_IP in your config." | lolcat
    exit 1
fi

echo "Attempting to expose cluster's API on floating IP: ${LB_FLOATING_IP}" | lolcat

if ! openstack floating ip list | grep ${LB_FLOATING_IP} ; then
    openstack floating ip create --floating-ip-address ${LB_FLOATING_IP} ${OPENSHIFT_INSTALL_OPENSTACK_EXTERNAL_NETWORK}
fi
openstack floating ip set --port lb-port ${LB_FLOATING_IP}

if ! grep -q ${LB_FLOATING_IP} /etc/resolv.conf ; then
    (echo "nameserver ${LB_FLOATING_IP}" && cat /etc/resolv.conf) | sudo tee /etc/resolv.conf
fi
