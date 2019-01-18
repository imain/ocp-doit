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
pushd tripleo-repos
sudo python setup.py install
popd

# Trying to use current-tripleo, which is the one that gets
# promoted through CI (more stable).  Sometimes we need to switch
# to current-tripleo-dev which is closer to master.
#sudo tripleo-repos current-tripleo-dev
sudo tripleo-repos current-tripleo

sudo yum -y update
sudo yum install -y python2-tripleoclient

# make sure that 'dig' is installed
sudo yum install -y bind-utils

# TRIPLEO HEAT TEMPLATES
if [ -d $SCRIPTDIR/tripleo-heat-templates ]; then
  rm -Rf $SCRIPTDIR/tripleo-heat-templates
fi

cd $SCRIPTDIR
cp -rv /usr/share/openstack-tripleo-heat-templates ./tripleo-heat-templates

# Patch to make octavia work in standalone:
# https://review.openstack.org/#/c/628957/6
pushd tripleo-heat-templates
git init
git fetch https://git.openstack.org/openstack/tripleo-heat-templates refs/changes/57/628957/6 && git format-patch -1 --stdout FETCH_HEAD | patch -p1
popd

# Set hostname properly.
HOSTNAME=`host $LOCAL_IP | cut -f 5 -d ' ' | sed s/.$//`
echo $HOSTNAME | lolcat
sudo hostnamectl set-hostname $HOSTNAME

# We need this before tripleo now because octavia expects keys.
if [ ! -f $HOME/.ssh/id_rsa.pub ]; then
    ssh-keygen
fi
