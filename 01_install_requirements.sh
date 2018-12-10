#!/usr/bin/env bash
set -x

source common.sh

sudo yum -y install ansible

ansible-playbook install_requirements.yaml
