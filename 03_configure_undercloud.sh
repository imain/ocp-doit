#!/usr/bin/env bash
set -xe

source common.sh

# NOTE: this is the openstack admin section
export OS_CLOUD=standalone

openstack endpoint list
openstack flavor create --ram 1024 --disk 10 --vcpu 2 --public tiny
openstack flavor create --ram 10240 --disk 20 --vcpu 2 --public m1.medium
openstack network create --external --provider-physical-network datacentre --provider-network-type flat public
openstack subnet create public-subnet --subnet-range $NETWORK.0/24 --no-dhcp --gateway $DEFAULT_ROUTE --allocation-pool start=$NETWORK.$FLOATING_IP_START,end=$NETWORK.$FLOATING_IP_END --network public

CIRROS_IMAGE_FILENAME="${CIRROS_IMAGE_FILENAME:-cirros-0.4.0-x86_64-disk.img}"
if [ ! -f "$CIRROS_IMAGE_FILENAME" ]; then
    wget https://download.cirros-cloud.net/0.4.0/"$CIRROS_IMAGE_FILENAME"
fi
openstack image create cirros --container-format bare --disk-format qcow2 --public --file "$CIRROS_IMAGE_FILENAME"

RHCOS_IMAGE_VERSION="${RHCOS_IMAGE_VERSION:-47.145}"
RHCOS_IMAGE_NAME="redhat-coreos-maipo-${RHCOS_IMAGE_VERSION}"
RHCOS_IMAGE_FILENAME="${RHCOS_IMAGE_NAME}-openstack.qcow2"
if [ ! -f "$RHCOS_IMAGE_FILENAME" ]; then
    curl --insecure --compressed -L -O "https://releases-redhat-coreos-dev.cloud.paas.upshift.redhat.com/storage/releases/maipo/${RHCOS_IMAGE_VERSION}/${RHCOS_IMAGE_FILENAME}"
fi
openstack image create rhcos --container-format bare --disk-format qcow2 --public --file $RHCOS_IMAGE_FILENAME


# Create a user without any admin priviledges
openstack project create openshift
openstack user create --password 'password' openshift
openstack role add --user openshift --project openshift _member_
openstack role add --user openshift --project openshift swiftoperator
openstack quota set --secgroups 100 --secgroup-rules 1000 openshift


# NOTE: this is a non-admin user
export OS_CLOUD=openshift

if [ ! -f $HOME/.ssh/id_rsa.pub ]; then
    ssh-keygen
fi

openstack keypair create --public-key ~/.ssh/id_rsa.pub default
openstack object store account set --property Temp-URL-Key=superkey
openstack network create --internal private
openstack subnet create private-subnet --subnet-range 192.168.24.0/24 --network private
# create basic security group to allow ssh/ping/dns
openstack security group list
openstack security group create basic
openstack security group rule create basic --protocol tcp --dst-port 22:22 --remote-ip 0.0.0.0/0
openstack security group rule create --protocol icmp basic
openstack security group rule create --protocol udp --dst-port 53:53 basic


cat >> ~/.ssh/config <<EOF
Host $NETWORK.*
  StrictHostKeyChecking no
  UserKnownHostsFile=/dev/null
EOF

lolcat <<EOF
Undercloud installed and configured.  To test:

export OS_CLOUD=openshift

# launch instance
openstack server create --flavor tiny --image cirros --key-name default --network private --security-group basic foo
# create router
openstack router create internets
# NOTE: this will consume one of your floating IP addresses!
openstack router set internets --external-gateway public
openstack router add subnet internets private-net
# create floating ip
openstack floating ip create public

openstack server add floating ip foo xxxx
# login to vm
echo ssh cirros@xxxx
EOF
