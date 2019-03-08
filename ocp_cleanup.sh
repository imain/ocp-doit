#!/bin/bash

set -e

source ocp_install_env.sh

$GOPATH/src/github.com/openshift/installer/bin/openshift-install --log-level=debug --dir $CLUSTER_NAME destroy cluster

# clean /etc/hosts
grep -qxF "$API_ADDRESS" /etc/hosts || sudo sed -i "/$API_ADDRESS/d" /etc/hosts
grep -qxF "$CONSOLE_ADDRESS" /etc/hosts || sudo sed -i "/$CONSOLE_ADDRESS/d" /etc/hosts
grep -qxF "$AUTH_ADDRESS" /etc/hosts || sudo sed -i "/$AUTH_ADDRESS/d" /etc/hosts

rm -rf $CLUSTER_NAME/
