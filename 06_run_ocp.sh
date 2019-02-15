#!/usr/bin/env bash
set -x
set -e

source ocp_install_env.sh
source common.sh

export OS_CLOUD=openshift

# check whether we already have a floating ip created
FLOATING_IP=$(openstack floating ip list --format value | awk -F ' ' 'NR==1 {print $2}')

# create new floating ip if doesn't exist
if [ -z "$FLOATING_IP" ]; then
    FLOATING_IP=$(openstack floating ip create public --format value | awk 'NR==6')
fi

# add data to /etc/hosts
grep -qxF "$FLOATING_IP $API_ADRESS" /etc/hosts || echo "$FLOATING_IP $API_ADRESS" | sudo tee -a /etc/hosts
grep -qxF "$FLOATING_IP $CONSOLE_ADRESS" /etc/hosts || echo "$FLOATING_IP $CONSOLE_ADRESS" | sudo tee -a /etc/hosts

if [ ! -d ocp ]; then
    mkdir -p ocp
fi

if [ ! -f ocp/install-config.yaml ]; then
    export CLUSTER_ID=$(uuidgen --random)
    cat > ocp/install-config.yaml << EOF
apiVersion: v1beta1
baseDomain: ${BASE_DOMAIN}
clusterID:  ${CLUSTER_ID}
machines:
- name:     master
  replicas: 3
- name:     worker
  replicas: 3
metadata:
  name: ${CLUSTER_NAME}
networking:
  clusterNetworks:
  - cidr:             10.128.0.0/14
    hostSubnetLength: 9
  serviceCIDR: 172.30.0.0/16
  machineCIDR: 10.0.0.0/16
  type:        OpenshiftSDN
platform:
  openstack:
    cloud:            ${OS_CLOUD}
    externalNetwork:  ${OPENSTACK_EXTERNAL_NETWORK}
    region:           ${OPENSTACK_REGION}
    computeFlavor:    ${OPENSTACK_FLAVOR}
    lbFloatingIP:     ${FLOATING_IP}
pullSecret: |
  ${PULL_SECRET}
sshKey: |
  ${SSH_PUB_KEY}
EOF
fi


$GOPATH/src/github.com/openshift/installer/bin/openshift-install --log-level=debug ${1:-create} ${2:-cluster} --dir ocp
