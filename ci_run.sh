#!/usr/bin/env bash
set -x
set -e

$GOPATH/src/github.com/openshift/ci-operator/ci-operator -template installer-e2e/templates/cluster-launch-installer-e2e-modified.yaml -config $GOPATH/src/github.com/openshift/release/ci-operator/config/openshift/installer/openshift-installer-master.yaml -secret-dir=installer-e2e/cluster-profile-openstack -namespace=openstack --target=cluster-launch-installer-e2e-modified -git-ref=flaper87/installer@cloud-config-install-config
