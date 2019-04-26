#!/bin/bash

set -x

sudo podman ps -aq | xargs --no-run-if-empty sudo podman stop
sudo podman ps -aq | xargs --no-run-if-empty sudo podman rm -f

sudo podman volume ls -q | xargs --no-run-if-empty sudo podman volume rm
sudo rm -Rf /var/lib/cinder
sudo rm -Rf /var/lib/config-data
sudo rm -Rf /var/lib/container-puppet
sudo rm -Rf /var/lib/containers/storage/overlay
sudo rm -Rf /var/lib/docker-puppet
sudo rm -Rf /var/lib/glance
sudo rm -Rf /var/lib/heat*
sudo rm -Rf /var/lib/kolla
sudo rm -Rf /var/lib/mysql
sudo rm -Rf /var/lib/neutron
sudo rm -Rf /var/lib/nova
sudo rm -Rf /var/lib/openstack
sudo rm -Rf /var/lib/os-*
sudo rm -Rf /var/lib/puppet
sudo rm -Rf /var/lib/rabbitmq
sudo rm -Rf /var/lib/tripleo
sudo rm -Rf /var/lib/tripleo-config
sudo rm -Rf /var/lib/tripleo-heat-installer
sudo rm -Rf standalone
sudo rm /etc/my.cnf.d/tripleo.cnf
