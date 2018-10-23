#!/usr/bin/env bash
set -x

source common.sh


cat > $SCRIPTDIR/standalone_parameters.yaml <<-EOF_CAT
parameter_defaults:
  CertmongerCA: local
  CloudName: $LOCAL_IP
  ContainerImagePrepare:
  - set:
      ceph_image: daemon
      ceph_namespace: docker.io/ceph
      ceph_tag: v3.0.3-stable-3.0-luminous-centos-7-x86_64
      name_prefix: centos-binary-
      name_suffix: ''
      namespace: docker.io/tripleomaster
      neutron_driver: null
      tag: current-tripleo
    tag_from_label: rdo_version
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
  StandaloneExtraConfig:
    nova::compute::libvirt::services::libvirt_virt_type: qemu
    nova::compute::libvirt::libvirt_virt_type: qemu
EOF_CAT

sudo openstack tripleo deploy  --templates $SCRIPTDIR/tripleo-heat-templates --local-ip=$LOCAL_IP/$CIDR   -e $SCRIPTDIR/tripleo-heat-templates/environments/standalone.yaml -r $SCRIPTDIR/standalone.yaml -e $SCRIPTDIR/standalone_parameters.yaml --output-dir $SCRIPTDIR/standalone --standalone -e $SCRIPTDIR/tripleo-heat-templates/environments/enable-designate.yaml

