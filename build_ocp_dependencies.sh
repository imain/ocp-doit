#!/bin/bash

set -ex

source common.sh

eval "$(go env)"
echo "$GOPATH" | lolcat


pushd "$GOPATH/src/github.com/openshift/ci-operator"
make build
popd
