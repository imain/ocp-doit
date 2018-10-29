#!/bin/bash

LOCAL_IP=10.1.8.88
CIDR=22
NETWORK=10.1.8
DEFAULT_ROUTE=10.1.11.254
PUBLIC_INTERFACE=em1
DNS_SERVER_1=10.11.5.9

# Needed if running in a VM
PARAMETERS_EXTRA="NtpServer: ['clock.redhat.com']"
