#!/usr/bin/env bash
set -x
set -e

source common.sh

eval "$(go env)"

export OS_CLOUD=standalone
export OPENSHIFT_INSTALL_OPENSTACK_CLOUD="${OS_CLOUD}"
export OPENSHIFT_INSTALL_DATA="$GOPATH/src/github.com/openshift/installer/data/data"
export OPENSHIFT_INSTALL_OPENSTACK_REGION=regionOne
export OPENSHIFT_INSTALL_OPENSTACK_IMAGE=rhcos
export OPENSHIFT_INSTALL_BASE_DOMAIN=shiftstack.com
export OPENSHIFT_INSTALL_CLUSTER_NAME=ostest
export OPENSHIFT_INSTALL_EMAIL_ADDRESS=me@redhat.com
export OPENSHIFT_INSTALL_PASSWORD=foobar
export OPENSHIFT_INSTALL_PLATFORM=openstack
export OPENSHIFT_INSTALL_OPENSTACK_EXTERNAL_NETWORK=public
export OPENSHIFT_INSTALL_PULL_SECRET='{"auths": { "quay.io": { "auth": "Y29yZW9zK3RlYzJfaWZidWdsa2VndmF0aXJyemlqZGMybnJ5ZzpWRVM0SVA0TjdSTjNROUUwMFA1Rk9NMjdSQUZNM1lIRjRYSzQ2UlJBTTFZQVdZWTdLOUFIQlM1OVBQVjhEVlla", "email": "" }}}'
export OPENSHIFT_INSTALL_SSH_PUB_KEY="`cat $HOME/.ssh/id_rsa.pub`"

# NOTE(trown): It seems like there is a bug with hardcoded path for the clouds.yaml file in manifests/tectonic.go
# https://github.com/openshift/installer/blob/2b52ad20793d37471c5645cbbe089e8a6656b802/pkg/asset/manifests/tectonic.go#L23
# We can workaround the bug by copying our clouds.yaml there
# This will be fixed by https://github.com/openshift/installer/pull/588
if ! [ -f /etc/openstack/clouds.yaml ]; then
    sudo mkdir /etc/openstack
    sudo cp $HOME/.config/openstack/clouds.yaml /etc/openstack/
fi

$GOPATH/src/github.com/openshift/installer/bin/openshift-install --log-level=debug create cluster --dir ocp

openstack port set --dns-name $OPENSHIFT_INSTALL_CLUSTER_NAME-api bootstrap-port
