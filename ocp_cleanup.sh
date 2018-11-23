#!/bin/bash

set -e

export OS_CLOUD="standalone"
eval "$(go env)"

$GOPATH/src/github.com/openshift/installer/bin/openshift-install --log-level=debug --dir ocp destroy cluster

rm -rf ocp
