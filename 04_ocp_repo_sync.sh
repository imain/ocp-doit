#!/bin/bash

set -ex

eval "$(go env)"
echo "$GOPATH" | lolcat # should print $HOME/go or something like that

figlet "Syncing Installer Repos" | lolcat

if [ ! -d "$GOPATH/src/github.com/openshift/installer" ]; then
  git clone https://github.com/openshift/installer.git "$GOPATH/src/github.com/openshift/installer"
fi
cd "$GOPATH/src/github.com/openshift/installer"

git am --abort || true
git checkout master
git branch -D we_dont_need_no_stinkin_patches || true
git checkout -b we_dont_need_no_stinkin_patches

echo https://github.com/openshift/installer/pull/611 | lolcat
curl -L https://github.com/openshift/installer/pull/611.patch | git am


figlet "Syncing Terraform Repos" | lolcat

mkdir -p $GOPATH/src/github.com/terraform-providers/
cd $GOPATH/src/github.com/terraform-providers/
if [ ! -d terraform-provider-openstack ]; then
  git clone https://github.com/terraform-providers/terraform-provider-openstack
fi

