#!/bin/bash

set -ex

source common.sh

figlet "Building the Installer" | highlight

eval "$(go env)"
echo "$GOPATH" | highlight # should print $HOME/go or something like that

pushd "$GOPATH/src/github.com/openshift/installer"
export MODE=dev
./hack/build.sh
popd
