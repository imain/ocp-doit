#!/usr/bin/env bash
set -x

source common.sh
: ${DNS_SERVER_1:=1.1.1.1}
: ${DNS_SERVER_2:=8.8.8.8}

openstack tripleo container image prepare default \
      --output-env-file $SCRIPTDIR/containers-prepare-parameters.yaml

cat > $SCRIPTDIR/standalone_parameters.yaml <<-EOF_CAT
parameter_defaults:
  CloudName: $LOCAL_IP
  # default gateway
  ControlPlaneStaticRoutes:
   - ip_netmask: 0.0.0.0/0
     next_hop: $DEFAULT_ROUTE
     default: true
  Debug: true
  DeploymentUser: $USER
  DnsServers:
    - $DNS_SERVER_1
    - $DNS_SERVER_2
  # needed for vip & pacemaker
  KernelIpNonLocalBind: 1
  DockerInsecureRegistryAddress:
  - $LOCAL_IP:8787
  NeutronPublicInterface: $PUBLIC_INTERFACE
  # domain name used by the host
  NeutronDnsDomain: localdomain
  # re-use ctlplane bridge for public net
  NeutronBridgeMappings: datacentre:br-ctlplane
  NeutronPhysicalBridge: br-ctlplane
  # enable to force metadata for public net
  #NeutronEnableForceMetadata: true
  StandaloneEnableRoutedNetworks: false
  StandaloneHomeDir: /home/$USER
  StandaloneLocalMtu: 1500
  $PARAMETERS_EXTRA
EOF_CAT

lolcat $SCRIPTDIR/standalone_parameters.yaml

sudo openstack tripleo deploy \
    --templates $SCRIPTDIR/tripleo-heat-templates \
    --local-ip=$LOCAL_IP/$CIDR \
    -e $SCRIPTDIR/containers-prepare-parameters.yaml \
    -r $SCRIPTDIR/standalone.yaml \
    -e $SCRIPTDIR/standalone_parameters.yaml \
    -e $SCRIPTDIR/tripleo-heat-templates/environments/standalone.yaml \
    --output-dir $SCRIPTDIR/standalone \
    --standalone \
    -e $SCRIPTDIR/tripleo-heat-templates/environments/enable-designate.yaml

# NOTE(flaper87): We're using tripleo-current,
# and this template only exists on master
# -e $SCRIPTDIR/tripleo-heat-templates/environments/standalone/standalone-tripleo.yaml \

sudo chown -R $USER:$USER ~/.config/openstack
sed -i.bak 's/cloud:/#cloud:/' ~/.config/openstack/clouds.yaml
sed -i.bak '4i\      domain_name: default' ~/.config/openstack/clouds.yaml

