#!/bin/bash
set -e

# Docuementation 
# https://serverfault.com/questions/392415/how-to-find-all-filenames-with-given-extension
# https://docs.openstack.org/python-octaviaclient/latest/cli/index.html

# System Variables 
CREDS="sudo find / -type f -name 'keystonercv3'"

# Source CREDS
source $CREDS
echo "===================================="
echo "KEYSTONERCV3 CREDS HAVE BEEN SOURCED"
echo "===================================="
echo "GETTING ALL INFO CREATED_AT AND ID"
echo "===================================="

# Get Creation Date Info and ID for all Loadbalancers
for i in $(openstack loadbalancer list --fit-width | awk '{print $2}' | head -n -1 | \
tail -n +4); do openstack loadbalancer show $i | grep -w "created_at\|id" | \
awk '{print $4}' && echo "=============== BREAK ==============="; done
