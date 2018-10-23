#!/usr/bin/env bash
set -x

source common.sh

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
    - 1.1.1.1
    - 8.8.8.8
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
  # Needed if running in a VM
  NovaComputeLibvirtType: qemu
EOF_CAT

sudo openstack tripleo deploy \
    --templates $SCRIPTDIR/tripleo-heat-templates \
    --local-ip=$LOCAL_IP/$CIDR \
    -e $SCRIPTDIR/containers-prepare-parameters.yaml \
    -e $SCRIPTDIR/tripleo-heat-templates/environments/standalone/standalone-tripleo.yaml \
    -r $SCRIPTDIR/standalone.yaml \
    -e $SCRIPTDIR/standalone_parameters.yaml \
    --output-dir $SCRIPTDIR/standalone \
    --standalone \
    -e $SCRIPTDIR/tripleo-heat-templates/environments/enable-designate.yaml

