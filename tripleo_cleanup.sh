#!/bin/bash

set -x

sudo docker ps -aq | xargs sudo docker stop
sudo docker ps -aq | xargs sudo docker rm -f

sudo docker volume ls -q | xargs --no-run-if-empty sudo docker volume rm
sudo rm -Rf /var/lib/config-data
sudo rm -Rf /var/lib/docker-puppet/
sudo rm -Rf /var/lib/glance
sudo rm -Rf /var/lib/heat-config/*
sudo rm -Rf /var/lib/kolla
sudo rm -Rf /var/lib/mysql
sudo rm -Rf /var/lib/neutron
sudo rm -Rf /var/lib/nova
sudo rm -Rf /var/lib/openstack
sudo rm -Rf /var/lib/puppet
sudo rm -Rf /var/lib/rabbitmq
sudo rm -Rf /var/lib/tripleo
sudo rm -Rf /var/lib/tripleo-config
sudo rm -Rf /var/lib/tripleo-heat-installer
sudo rm -Rf standalone
sudo rm /etc/my.cnf.d/tripleo.cnf
