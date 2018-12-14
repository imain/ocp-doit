#!/bin/bash

source ocp_install_env.sh

NODE_ADDRESSES=`openstack server show ostest-$1 -f value -c addresses | cut -d',' -f1`
NODE_IP=${NODE_ADDRESSES#"openshift="}
sudo ip netns exec "qdhcp-$(openstack --os-cloud standalone network show openshift -f value -c id)" ssh -o "StrictHostKeyChecking no" -o "UserKnownHostsFile /dev/null" -i ${SSH_PRIV_KEY} core@$NODE_IP
