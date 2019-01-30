#!/bin/bash

export OS_CLOUD=openshift
openstack loadbalancer create --vip-subnet-id public-subnet --name lb1
#openstack loadbalancer listener create --protocol HTTPS --name https --protocol-port 443 lb1
#openstack loadbalancer listener create --protocol HTTP --name http --protocol-port 80 lb1
openstack loadbalancer listener create --protocol TCP --name ignition_listener --protocol-port 49500 lb1

openstack loadbalancer listener list

openstack loadbalancer pool create --name ignition_pool --protocol TCP --lb-algorithm ROUND_ROBIN --listener ignition_listener
openstack loadbalancer member create --address 10.0.0.82 --protocol-port 49500 --subnet-id private-subnet ignition_pool
