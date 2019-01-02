eval "$(go env)"

export OS_CLOUD=openshift
export OPENSHIFT_INSTALL_DATA="$GOPATH/src/github.com/openshift/installer/data/data"
export OPENSTACK_REGION=regionOne
export OPENSTACK_IMAGE=rhcos
export OPENSTACK_FLAVOR=m1.medium
export BASE_DOMAIN=shiftstack.com
export CLUSTER_NAME=ostest
export OPENSTACK_EXTERNAL_NETWORK=public
export PULL_SECRET='{"auths": { "quay.io": { "auth": "Y29yZW9zK3RlYzJfaWZidWdsa2VndmF0aXJyemlqZGMybnJ5ZzpWRVM0SVA0TjdSTjNROUUwMFA1Rk9NMjdSQUZNM1lIRjRYSzQ2UlJBTTFZQVdZWTdLOUFIQlM1OVBQVjhEVlla", "email": "" }}}'
export SSH_PUB_KEY="`cat $HOME/.ssh/id_rsa.pub`"

# Not used by the installer.  Used by s.sh.
export SSH_PRIV_KEY="$HOME/.ssh/id_rsa"

