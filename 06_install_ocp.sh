#!/usr/bin/env bash
set -x
set -e

source common.sh
source ocp_install_env.sh

$GOPATH/src/github.com/openshift/installer/bin/openshift-install --log-level=debug create cluster --dir ocp

openstack port set --dns-name $OPENSHIFT_INSTALL_CLUSTER_NAME-api bootstrap-port
