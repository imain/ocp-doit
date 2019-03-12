#!/bin/bash

source ocp_install_env.sh

# an example of the 'addresses' string is "ostest-rxxzv-openshift=10.0.128.61, 10.1.10.16"
# we need the network name right before the = sign (ostest-rxxzv-openshift),
# and the first ip address as a node ip (10.0.128.61).
ADDRESSES=`openstack server show ostest-$1 -f value -c addresses`
NETWORK_NAME=`echo $ADDRESSES | cut -d'=' -f1`
NODE_IP=`echo $ADDRESSES | cut -d'=' -f2 | cut -d',' -f1`
shift

sudo ip netns exec "qdhcp-$(openstack --os-cloud standalone network show $NETWORK_NAME -f value -c id)" ssh -o "StrictHostKeyChecking no" -o "UserKnownHostsFile /dev/null" -i ${SSH_PRIV_KEY} core@$NODE_IP $@
