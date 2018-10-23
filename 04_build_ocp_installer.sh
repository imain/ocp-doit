#!/bin/bash

set -ex

sudo yum install -y golang docker
eval "$(go env)"
echo "$GOPATH" | lolcat # should print $HOME/go or something like that

echo Building terraform | lolcat

mkdir -p $GOPATH/src/github.com/terraform-providers/
cd $GOPATH/src/github.com/terraform-providers/
git clone https://github.com/terraform-providers/terraform-provider-openstack
cd terraform-provider-openstack
make build
mkdir -p ~/.terraform.d/plugins
cd ~/.terraform.d/plugins/
ln -s ~/go/bin/terraform-provider-openstack terraform-provider-openstack_v1.6.1
cd

echo Building the Installer | lolcat

git clone https://github.com/openshift/installer.git "$GOPATH/src/github.com/openshift/installer"
cd "$GOPATH/src/github.com/openshift/installer"

# Check out the OpenStack Pull Request: https://github.com/openshift/installer/pull/144
#git fetch origin pull/144/head:pull_144
#git checkout pull_144
#git rebase -i origin # optional
# NOTE: The upstream installer is moving fast and the PR with it.
# Rebases often fail but always make sure you’re using the latest version of the pull request.
./hack/get-terraform.sh
export MODE=dev
./hack/build.sh

