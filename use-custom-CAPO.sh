#!/bin/bash

source ocp_install_env.sh

: ${KUBECONFIG:=$CLUSTER_NAME/auth/kubeconfig}
: ${OLD_IMAGE:=docker.io/openshift/origin-openstack-machine-controllers:v4.0.0}
: ${NEW_IMAGE:=quay.io/trown/openstack-machine-controllers:rebase}

config_map=$(mktemp)

cluster_api_pod=$(oc get pods -n openshift-cluster-api | grep clusterapi | cut -f1 -d " ")

echo $config_map

oc scale --replicas 0 -n openshift-cluster-version deployments/cluster-version-operator

oc get configmaps machine-api-operator-images -o yaml -n openshift-cluster-api > $config_map

sed -i "s%$OLD_IMAGE%$NEW_IMAGE%" $config_map

oc replace --force -f $config_map

oc scale --replicas 0 deployments/clusterapi-manager-controllers -n openshift-cluster-api
sleep 10
oc scale --replicas 1 deployments/clusterapi-manager-controllers -n openshift-cluster-api
