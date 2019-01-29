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

# NOTE: Used to be in 02, here is where tripleo was started.

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

