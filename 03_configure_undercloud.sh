#!/usr/bin/env bash
set -xe

source common.sh

ansible-playbook -e "network=${NETWORK} default_route=${DEFAULT_ROUTE} floating_ip_start=${FLOATING_IP_START} floating_ip_end=${FLOATING_IP_END} rhcos_image_filename=${RHCOS_IMAGE_FILENAME} local_ip=${LOCAL_IP}" configure_undercloud.yaml

lolcat <<EOF
Undercloud installed and configured.  To test:

export OS_CLOUD=openshift

# launch instance
openstack server create --flavor tiny --image cirros --key-name default --network private --security-group basic foo
# create router
openstack router create internets
# NOTE: this will consume one of your floating IP addresses!
openstack router set internets --external-gateway public
openstack router add subnet internets private-subnet
# create floating ip
openstack floating ip create public

openstack server add floating ip foo xxxx
# login to vm
echo ssh cirros@xxxx
EOF
