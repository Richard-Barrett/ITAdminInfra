#!/bin/bash
set -e


# Get Creation Date Info and ID for all Loadbalancers
for i in $(openstack loadbalancer list --fit-width | awk '{print $2}' | head -n -1 | \
tail -n +4); do openstack loadbalancer show $i | grep -w "created_at\|id" | \
awk '{print $4}' && echo "=============== BREAK ==============="; done
