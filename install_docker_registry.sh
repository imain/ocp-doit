#!/bin/bash

set -ex

source common.sh

eval "$(go env)"
echo "$GOPATH" | highlight

if [ "$(cat /proc/sys/user/max_user_namespaces)" = "0" ]; then
	echo 10000 | sudo tee /proc/sys/user/max_user_namespaces
fi
if ! grep -q $USER /etc/subuid ; then
	echo $USER:10000:65536 | sudo tee -a /etc/subuid
fi
if ! grep -q $USER /etc/subgid ; then
	echo $USER:10000:65536 | sudo tee -a /etc/subgid
fi

figlet "Run docker registry" | highlight

OVERRIDE_IMAGES=""
sudo podman rm -f registry || true
mkdir -p ${PWD}/certs
# We are not setting up a cert here causing it to break.  Just letting the registry generate one for now.
#sudo podman run -d -v "${PWD}/certs:/certs" -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/registry.crt -e REGISTRY_HTTP_TLS_KEY=/certs/registry.key -p 8787:5000 --name registry docker.io/library/registry
sudo podman run -d -v "${PWD}/certs:/certs" -p 8787:5000 --name registry docker.io/library/registry
