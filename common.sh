#!/bin/bash

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
USER=`whoami`

if [ -z "$CONFIG" ]; then
    echo "Please run with a configuration environment set."
    echo "eg CONFIG=config_example.sh ./01_all_in_one.sh"
    exit 1
fi
source $CONFIG
figlet $CONFIG | lolcat
lolcat $CONFIG

export REGISTRY=${REGISTRY:-$LOCAL_IP:8787}
export REPO=${REPO:-$REGISTRY/openshift}
