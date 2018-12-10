#!/usr/bin/env bash
set -x

source common.sh
: ${DNS_SERVER_1:=1.1.1.1}
: ${DNS_SERVER_2:=8.8.8.8}

ansible-playbook -e "local_ip=$LOCAL_IP cidr=$CIDR default_route=$DEFAULT_ROUTE public_interface=$PUBLIC_INTERFACE parameters_extra='$PARAMETERS_EXTRA' dns_server_1=$DNS_SERVER_1 dns_server_2=$DNS_SERVER_2" run_all_in_one.yaml

# NOTE(flaper87): We're using tripleo-current,
# and this template only exists on master
# -e $SCRIPTDIR/tripleo-heat-templates/environments/standalone/standalone-tripleo.yaml \
