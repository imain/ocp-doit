#!/usr/bin/env bash
set -x

source common.sh

set -x

openstack tripleo container image prepare default \
      --output-env-file $SCRIPTDIR/containers-prepare-parameters.yaml

# Pin to a specific tripleo version.
sed -i "s/ tag:.*/ tag: $TRIPLEO_VERSION/" containers-prepare-parameters.yaml

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
    - $LOCAL_IP
  EnablePackageInstall: true
  NeutronDhcpAgentDnsmasqDnsServers:
    - $LOCAL_IP
  # needed for vip & pacemaker
  KernelIpNonLocalBind: 1
  DockerInsecureRegistryAddress:
  - $LOCAL_IP:8787
  NeutronPublicInterface: $PUBLIC_INTERFACE
  # re-use ctlplane bridge for public net
  NeutronBridgeMappings: datacentre:br-ctlplane
  NeutronPhysicalBridge: br-ctlplane
  # enable to force metadata for public net
  NeutronEnableForceMetadata: true
  NeutronDnsDomain: shiftstack.com
  NeutronPluginExtensions: "qos,port_security,dns_domain_ports"
  ControllerExtraConfig:
    neutron::agents::dhcp::dnsmasq_local_resolv: true

  StandaloneEnableRoutedNetworks: false
  StandaloneHomeDir: /home/$USER
  StandaloneLocalMtu: 1500
  OctaviaAmphoraSshKeyFile: /home/$USER/.ssh/id_rsa.pub
  # Octavia is currently broken with selinux enabled.
  SELinuxMode: permissive
  $PARAMETERS_EXTRA
EOF_CAT

lolcat $SCRIPTDIR/standalone_parameters.yaml

sudo openstack tripleo deploy \
    --templates $SCRIPTDIR/tripleo-heat-templates \
    --local-ip=$LOCAL_IP/$CIDR \
    -e $SCRIPTDIR/containers-prepare-parameters.yaml \
    -r $SCRIPTDIR/tripleo-heat-templates/roles/Standalone.yaml \
    -e $SCRIPTDIR/tripleo-heat-templates/environments/standalone/standalone-tripleo.yaml \
    -e $SCRIPTDIR/tripleo-heat-templates/environments/services/octavia.yaml \
    -e $SCRIPTDIR/standalone_parameters.yaml \
    --output-dir $SCRIPTDIR/standalone \
    --standalone

sudo chown -R $USER:$USER ~/.config/openstack
sed -i.bak 's/cloud:/#cloud:/' ~/.config/openstack/clouds.yaml
sed -i.bak '4i\      domain_name: default' ~/.config/openstack/clouds.yaml
