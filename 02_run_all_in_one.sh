#!/usr/bin/env bash
set -x

source common.sh


: ${DNS_SERVER_1:=1.1.1.1}

# run CoreDns container (host-net), Neutron upstream-dns will point to this server and CoreDns will point to external DNS server
sudo systemctl start docker
sudo systemctl enable docker
sudo chcon -t container_file_t -R "$(pwd)/coredns_cfg"
sed -i "s/DNS_SERVER_1/$DNS_SERVER_1/g" coredns_cfg/Corefile
sudo docker run -d  -m 128m --restart="unless-stopped" --net host --cap-add=NET_ADMIN -v "$PWD"/coredns_cfg:/etc/coredns   --name coredns coredns/coredns:latest -conf  /etc/coredns/Corefile


function verify_dns {

ips=($(dig  +short  -t srv _etcd-server-ssl._tcp.ostest.shiftstack.com. @"${LOCAL_IP}"))
if [[ "$?" -eq 0 && "${#ips[@]}" -ne 0 ]]; then
   echo "DNS resolve SRV record _etcd-server-ssl._tcp.ostest.shiftstack.com. -  Success"
else
   return 1
fi

ips=($(dig +short  google.com  @"${LOCAL_IP}"))
echo $ips
if [[ "$?" -eq 0 && "${#ips[@]}" -ne 0 ]]; then
   echo "DNS resolve google.com - success"
else
   return 1
fi
   return 0
}
set +x
if verify_dns; then
  echo "Pre tripleo deployment - DNS is working!";
else
  echo -e "Pre tripleo deployment -DNS can not resolve SRV record, google.com\\nplease ***fix it*** (Docker service enabled? IPtables??)";
  exit
fi
set -x
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
    - $LOCAL_IP
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
  $PARAMETERS_EXTRA
EOF_CAT

lolcat $SCRIPTDIR/standalone_parameters.yaml

sudo openstack tripleo deploy \
    --templates $SCRIPTDIR/tripleo-heat-templates \
    --local-ip=$LOCAL_IP/$CIDR \
    -e $SCRIPTDIR/containers-prepare-parameters.yaml \
    -r $SCRIPTDIR/tripleo-heat-templates/roles/Standalone.yaml \
    -e $SCRIPTDIR/tripleo-heat-templates/environments/standalone/standalone-tripleo.yaml \
    -e $SCRIPTDIR/standalone_parameters.yaml \
    --output-dir $SCRIPTDIR/standalone \
    --standalone

# NOTE(flaper87): We're using tripleo-current,
# and this template only exists on master
# -e $SCRIPTDIR/tripleo-heat-templates/environments/standalone/standalone-tripleo.yaml \

sudo chown -R $USER:$USER ~/.config/openstack
sed -i.bak 's/cloud:/#cloud:/' ~/.config/openstack/clouds.yaml
sed -i.bak '4i\      domain_name: default' ~/.config/openstack/clouds.yaml

# Enable DNS port and verify that DNS still working after tripleo deployment
# FIXME - Make these persist a reboot
sudo iptables -I INPUT 2 -p udp --dport 53 -j ACCEPT
sudo iptables -I INPUT 3 -p udp --sport 53 -j ACCEPT
set +x
if verify_dns; then
  echo "Post tripleo deployment - DNS is working!";
else
  echo -e "Post tripleo deployment -DNS can not resolve SRV record, google.com (IPtables??)\\nplease ****Fix it**** before running next step!";
fi
