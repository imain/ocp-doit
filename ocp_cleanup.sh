#!/bin/bash

set -e

source ocp_install_env.sh

$GOPATH/src/github.com/openshift/installer/bin/openshift-install --log-level=debug --dir ocp destroy cluster

# clean /etc/hosts
grep -qxF "$API_ADRESS" /etc/hosts || sudo sed -i "/$API_ADRESS/d" /etc/hosts
grep -qxF "$CONSOLE_ADRESS" /etc/hosts || sudo sed -i "/$CONSOLE_ADRESS/d" /etc/hosts

rm -rf ocp/{auth,terraform.tfstate}
