#!/usr/bin/env bash
set -x

source common.sh

sudo setenforce permissive

sudo yum -y update

# So we need go 1.10 now to build the installer.  Go the easy route and just install
# upstream packages.  Hopefully this is temporary.

export GOLANG_SOURCE="http://cbs.centos.org/kojifiles/packages/golang/1.10.2/1.el7"
export GOLANG_VERSION="1.10.2-1.el7"

# Should be a noop or fix golang version
sudo yum -y autoremove golang

sudo yum -y install http://cbs.centos.org/kojifiles/packages/go-srpm-macros/2/17.el7/noarch/go-srpm-macros-2-17.el7.noarch.rpm
sudo yum -y install $GOLANG_SOURCE/noarch/golang-src-$GOLANG_VERSION.noarch.rpm \
                    $GOLANG_SOURCE/x86_64/golang-$GOLANG_VERSION.x86_64.rpm \
                    $GOLANG_SOURCE/x86_64/golang-bin-$GOLANG_VERSION.x86_64.rpm

exit 0

sudo yum -y install curl vim-enhanced epel-release wget python-pip patch psmisc figlet
sudo yum -y install https://dprince.fedorapeople.org/tmate-2.2.1-1.el7.centos.x86_64.rpm

sudo pip install lolcat

# for tripleo-repos install:
sudo yum -y install python-setuptools python-requests

cd
git clone https://git.openstack.org/openstack/tripleo-repos
cd tripleo-repos
sudo python setup.py install
cd
#sudo tripleo-repos current
#sudo tripleo-repos current-tripleo

# current-tripleo is broken for the all-in-one atm.
sudo tripleo-repos current-tripleo

sudo yum install -y python2-tripleoclient

# TRIPLEO HEAT TEMPLATES
if [ ! -d $SCRIPTDIR/tripleo-heat-templates ]; then
  cd $SCRIPTDIR
  cp -rv /usr/share/openstack-tripleo-heat-templates ./tripleo-heat-templates
  cd tripleo-heat-templates
  cat ../octavia_hack.patch | patch -p1
fi

