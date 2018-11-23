#!/bin/bash

set -ex
source common.sh

eval "$(go env)"
echo "$GOPATH" | lolcat # should print $HOME/go or something like that

figlet "Syncing Installer repo" | lolcat

if [ ! -d "$GOPATH/src/github.com/openshift/installer" ]; then
  git clone https://github.com/openshift/installer.git "$GOPATH/src/github.com/openshift/installer"
fi

pushd "$GOPATH/src/github.com/openshift/installer"
git am --abort || true
git checkout master
git branch -D we_dont_need_no_stinkin_patches || true
git checkout -b we_dont_need_no_stinkin_patches

#echo https://github.com/openshift/installer/pull/611 | lolcat
#curl -L https://github.com/openshift/installer/pull/611.patch | git am
patch_file=$(mktemp)
echo $patch_file
curl -L https://github.com/tomassedovic/installer/commit/dns-workaround.patch -o $patch_file
sed -i "s/10.1.11.152/$BOOTSTRAP_FLOATING_IP/g" $patch_file
git am < $patch_file
popd


figlet "Syncing Terraform repo" | lolcat

mkdir -p $GOPATH/src/github.com/terraform-providers/
pushd $GOPATH/src/github.com/terraform-providers/
if [ ! -d terraform-provider-openstack ]; then
  git clone https://github.com/terraform-providers/terraform-provider-openstack
fi
popd

figlet "Syncing Openshift release repo" | lolcat

if [ ! -d $GOPATH/src/github.com/openshift/release ]; then
  git clone https://github.com/openshift/release.git $GOPATH/src/github.com/openshift/release
fi

figlet "Syncing ci-operator repo" | lolcat

if [ ! -d $GOPATH/src/github.com/openshift/ci-operator ]; then
  git clone https://github.com/openshift/ci-operator.git "$GOPATH/src/github.com/openshift/ci-operator"
fi

figlet "Syncing installer-e2e repo" | lolcat
if [ ! -d installer-e2e ]; then
  git clone https://github.com/sallyom/installer-e2e
fi
