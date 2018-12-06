#!/usr/bin/env bash
set -x
set -e

source ocp_install_env.sh
source common.sh

$GOPATH/src/github.com/openshift/installer/bin/openshift-install --log-level=debug ${1:-create} ${2:-cluster} --dir ocp
