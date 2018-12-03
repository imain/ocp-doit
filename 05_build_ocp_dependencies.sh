#!/bin/bash

set -ex

source common.sh

eval "$(go env)"
echo "$GOPATH" | lolcat # should print $HOME/go or something like that

if [ "$(cat /proc/sys/user/max_user_namespaces)" = "0" ]; then
	echo 10000 | sudo tee /proc/sys/user/max_user_namespaces
fi
if ! grep -q $USER /etc/subuid ; then
	echo $USER:10000:65536 | sudo tee -a /etc/subuid
fi
if ! grep -q $USER /etc/subgid ; then
	echo $USER:10000:65536 | sudo tee -a /etc/subgid
fi

figlet "Run docker registry" | lolcat

OVERRIDE_IMAGES=""
podman rm -f registry || true
mkdir -p ${PWD}/certs
podman run -d -v "${PWD}/certs:/certs" -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/registry.crt -e REGISTRY_HTTP_TLS_KEY=/certs/registry.key -p 8787:5000 --name registry docker.io/library/registry

figlet "Building terraform" | lolcat

pushd $GOPATH/src/github.com/terraform-providers/terraform-provider-openstack
make build
mkdir -p ~/.terraform.d/plugins
cd ~/.terraform.d/plugins/
rm -f terraform-provider-openstack_v1.6.1
ln -s ~/go/bin/terraform-provider-openstack terraform-provider-openstack_v1.6.1
popd

./build_ocp_installer.sh

pushd "$GOPATH/src/github.com/openshift/ci-operator"
make build
popd

figlet "Building the Machine Config Operator" -f banner | lolcat

cd "$GOPATH/src/github.com/openshift/machine-config-operator"

VERSION=$(git describe --abbrev=8 --dirty --always)
ALL_IMAGES=$(ls Dockerfile.*)
for IMAGE in $ALL_IMAGES; do
    NAME="${IMAGE#Dockerfile.}"
    podman build -t "${NAME}:${VERSION}" -f "${IMAGE}"
    podman push --tls-verify=false "${NAME}:${VERSION}" "${REPO}/origin-${NAME}:${VERSION}"
    podman push --tls-verify=false "${NAME}:${VERSION}" "${REPO}/origin-${NAME}:latest"
    OVERRIDE_IMAGES="$OVERRIDE_IMAGES $NAME=${REPO}/origin-${NAME}:${VERSION}"
done

figlet "Building Origin" -f banner | lolcat

cd "$GOPATH/src/github.com/openshift/origin"

make build WHAT=cmd/oc
cp -f _output/local/bin/linux/amd64/oc /usr/local/bin/

oc adm release new --insecure=true -n openshift \
  $OVERRIDE_IMAGES \
  --from-image-stream=origin-v4.0 \
  --to-image=10.1.8.88:8787/shiftstack/origin-release:v4.0
