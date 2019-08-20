#!/bin/bash

set -ex

source common.sh

eval "$(go env)"
echo "$GOPATH" | highlight


pushd "$GOPATH/src/github.com/openshift/ci-operator"
make build
popd
