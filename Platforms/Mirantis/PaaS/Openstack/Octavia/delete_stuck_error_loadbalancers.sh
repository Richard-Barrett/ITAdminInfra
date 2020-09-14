#!/bin/bash

# Docuementation 
# https://serverfault.com/questions/392415/how-to-find-all-filenames-with-given-extension
# https://docs.openstack.org/python-octaviaclient/latest/cli/index.html

# System Variables 
CREDS="sudo find / -type f -name 'keystonercv3'"

# Perform Process
echo "=================="
echo "INITIATING CLEANUP"
echo "=================="
echo "CLEANUP STARTED..."

# Source CREDS
source $CREDS
echo "======================================"
echo "KEYSTONERCV3 CREDS HAVE BEEN SOURCED"
echo "======================================"
echo "STARTING CLEANUP"
echo "DELETING LOADBALANCERS IN ERROR STATE"
echo "======================================"

# Clean up loadbalancers stuck in ERROR 
for i in $(openstack loadbalancer list --fit-width | grep -i "ERROR" | awk '{print $2}'); do openstack loadbalancer delete --cascade $i --force; done

# Echo Completion
echo "=========================================================="
echo "YOU HAVE DELETED ALL LOAD BALANCERS IN STATUS WITH ERROR"
echo "=========================================================="
echo "CURRENT LOADBALANCERS STILL IN ERROR STATE:"
openstack loadbalancer list --fit-width | grep -i "ERROR" | awk '{print $2}' | wc -l
