#!/usr/bin/env bash
set -x

source common.sh

sudo setenforce permissive

sudo yum -y update

sudo yum -y install epel-release
sudo yum -y install curl vim-enhanced wget python-pip patch psmisc figlet golang
sudo yum -y install https://dprince.fedorapeople.org/tmate-2.2.1-1.el7.centos.x86_64.rpm

sudo pip install lolcat

# for tripleo-repos install:
sudo yum -y install python-setuptools python-requests

if [ ! -f openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz ]; then
  wget https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz
  tar xvzf openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz
  sudo cp openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit/{kubectl,oc} /usr/local/bin/
fi
cd
git clone https://git.openstack.org/openstack/tripleo-repos
cd tripleo-repos
sudo python setup.py install
cd
#sudo tripleo-repos current
#sudo tripleo-repos current-tripleo

# current-tripleo is broken for the all-in-one atm.
sudo tripleo-repos current-tripleo
sudo yum -y update
sudo yum install -y python2-tripleoclient

# TRIPLEO HEAT TEMPLATES
if [ ! -d $SCRIPTDIR/tripleo-heat-templates ]; then
  cd $SCRIPTDIR
  cp -rv /usr/share/openstack-tripleo-heat-templates ./tripleo-heat-templates
  cd tripleo-heat-templates
  cat ../octavia_hack.patch | patch -p1
fi

