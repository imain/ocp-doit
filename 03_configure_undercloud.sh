#!/usr/bin/env bash
set -xe

source common.sh

# NOTE: this is the openstack admin section
export OS_CLOUD=standalone

openstack endpoint list | lolcat

if ! openstack flavor show tiny; then
    openstack flavor create --ram 1024 --disk 10 --vcpu 2 --public tiny
fi
if ! openstack flavor show m1.medium; then
    openstack flavor create --ram 4096 --disk 20 --vcpu 2 --public m1.medium
fi
if ! openstack flavor show m1.large; then
    openstack flavor create --ram 8192 --disk 20 --vcpu 4 --public m1.large
fi
if ! openstack network show public; then
    # We're sharing the public network with everyone here.  The other approach is to use eg:
    # neutron rbac-create --target-tenant 3321b17b840d448d8503f4dbe9502b17 --action  access_as_shared --type network e42a14bc-b1f2-4490-896b-e3d3ea2ae310
    # to grant shared access to a specific tenant.
    openstack network create --external --share --provider-physical-network datacentre --provider-network-type flat public
fi
if ! openstack subnet show public-subnet; then
    openstack subnet create public-subnet --subnet-range $NETWORK.0/$CIDR --no-dhcp --gateway $DEFAULT_ROUTE --allocation-pool start=$NETWORK.$FLOATING_IP_START,end=$NETWORK.$FLOATING_IP_END --network public
fi

if ! openstack image show cirros; then
    CIRROS_IMAGE_FILENAME="${CIRROS_IMAGE_FILENAME:-cirros-0.4.0-x86_64-disk.img}"
    if [ ! -f "$CIRROS_IMAGE_FILENAME" ]; then
        wget https://download.cirros-cloud.net/0.4.0/"$CIRROS_IMAGE_FILENAME"
    fi
    openstack image create cirros --container-format bare --disk-format qcow2 --public --file "$CIRROS_IMAGE_FILENAME"
fi

./get_rhcos_image.sh
RHOS_IMAGE_HASH=$(sha512sum $RHCOS_IMAGE_FILENAME | awk '{print $1}')
if ! openstack image show rhcos; then
    openstack image create rhcos --container-format bare --disk-format qcow2 --public --file $RHCOS_IMAGE_FILENAME
elif ! openstack image show rhcos -c properties -f shell | grep -q $RHOS_IMAGE_HASH; then
    echo "rhos image changed, replacing"
    openstack image delete rhcos
    openstack image create rhcos --container-format bare --disk-format qcow2 --public --file $RHCOS_IMAGE_FILENAME
fi

# Set up all the stuff we need for octavia.
OCTAVIA_AMPHORA="amphora-x64-haproxy-centos.qcow2"
echo $OCTAVIA_AMPHORA | figlet | lolcat

if ! openstack image show amphora-image; then
    if [ ! -f "$OCTAVIA_AMPHORA" ]; then
        curl -o $OCTAVIA_AMPHORA https://images.rdoproject.org/octavia/master/amphora-x64-haproxy-centos.qcow2
    fi
    openstack image create --container-format bare --disk-format qcow2 --public --tag amphora-image --file $OCTAVIA_AMPHORA amphora-image
fi

HOST_LOCALDOMAIN=`hostname -A | sed 's/ /\n/g' | grep localdomain`
echo $HOST_LOCALDOMAIN | lolcat
neutron port-update --binding:host_id=$HOST_LOCALDOMAIN $(openstack port list -c ID -c Name | grep health | cut -f2 -d " ")

echo To test: openstack loadbalancer create --vip-subnet-id public-subnet --name lb1 | lolcat

# Create a user without any admin priviledges
if ! openstack project show openshift; then
    openstack project create openshift
fi
if ! openstack user show openshift; then
    openstack user create --password 'password' openshift
fi
openstack role add --user openshift --project openshift _member_
openstack role add --user openshift --project openshift swiftoperator
openstack quota set --secgroups 100 --secgroup-rules 1000 openshift

if ! grep -q openshift ~/.config/openstack/clouds.yaml ; then
cat >> ~/.config/openstack/clouds.yaml << EOF
  openshift:
    auth:
      domain_name: default
      auth_url: http://${LOCAL_IP}:5000/
      project_name: openshift
      username: openshift
      password: password
    region_name: regionOne
    identity_api_version: 3
EOF
fi

# NOTE: this is a non-admin user
export OS_CLOUD=openshift

if ! openstack keypair show default; then
    openstack keypair create --public-key ~/.ssh/id_rsa.pub default
fi
openstack object store account set --property Temp-URL-Key=superkey
if ! openstack network show private; then
    openstack network create --internal private
fi
if ! openstack subnet show private-subnet; then
    openstack subnet create private-subnet --subnet-range 192.168.24.0/24 --network private
fi
# create basic security group to allow ssh/ping/dns
openstack security group list
if ! openstack security group show basic; then
    openstack security group create basic
fi
if ! openstack security group rule list basic | grep "22:22"; then
    openstack security group rule create basic --protocol tcp --dst-port 22:22 --remote-ip 0.0.0.0/0
fi
if ! openstack security group rule list basic | grep "icmp"; then
    openstack security group rule create --protocol icmp basic
fi
if ! openstack security group rule list basic | grep "53:53"; then
    openstack security group rule create --protocol udp --dst-port 53:53 basic
fi


if ! grep -q StrictHostKeyChecking ~/.ssh/config; then
    cat >> ~/.ssh/config <<EOF
Host $NETWORK.*
  StrictHostKeyChecking no
  UserKnownHostsFile=/dev/null
EOF
fi

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
