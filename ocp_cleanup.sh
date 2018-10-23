#!/bin/bash

set -ex

for server in $(openstack server list | grep rhcos \
        | awk '{print $2}') ; do
    openstack server delete $server
done

for port in $(openstack port list \
        | grep -E 'bootstrap|master' \
        | awk '{print $2}') ; do
    if [ "$port" != "|" ] ; then
        openstack port delete $port
    fi
done

for sg in $(openstack security group list | grep -E \
        'master|worker|default|api|mcs|console' | awk '{print $2}') ; do
    openstack security group delete $sg
done

ROUTER_ID=$(openstack router list | grep openshift-external-router | awk '{print $2}')

for subnet in $(openstack subnet list | grep -E 'worker|masters' \
        | awk '{print $2}') ; do
    openstack router remove subnet ${ROUTER_ID} $subnet
    openstack subnet delete $subnet
done

openstack router delete $ROUTER_ID

openstack network delete openshift

