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
export OPENSHIFT_INSTALL_BASE_DOMAIN=localdomain
export OPENSHIFT_INSTALL_CLUSTER_NAME=ostest
export OPENSHIFT_INSTALL_EMAIL_ADDRESS=me@redhat.com
export OPENSHIFT_INSTALL_PASSWORD=foobar
export OPENSHIFT_INSTALL_PLATFORM=openstack
export OPENSHIFT_INSTALL_OPENSTACK_EXTERNAL_NETWORK=public
export OPENSHIFT_INSTALL_PULL_SECRET='{"auths": { "quay.io": { "auth": "Y29yZW9zK3RlYzJfaWZidWdsa2VndmF0aXJyemlqZGMybnJ5ZzpWRVM0SVA0TjdSTjNROUUwMFA1Rk9NMjdSQUZNM1lIRjRYSzQ2UlJBTTFZQVdZWTdLOUFIQlM1OVBQVjhEVlla", "email": "" }}}'
export OPENSHIFT_INSTALL_SSH_PUB_KEY="`cat $HOME/.ssh/id_rsa.pub`"

$GOPATH/src/github.com/openshift/installer/bin/openshift-install --log-level=debug cluster --dir ocp
