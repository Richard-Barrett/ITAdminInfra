#!/bin/bash
# =====================================================
# Author: Richard Barrett
# Date Created: 03/14/2020
# Organziation: Mirantis
# Purpose: Initalize Manual Logrotate on Openstack Logs
# =====================================================

# Official documentation
# ======================================================================================================================
# ...
# ======================================================================================================================
set -e 

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG

# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

# System Variables 
# ================
DATE="$(date +'%Y%-m%d')"

# Check for SOS Report Module
# Prompt for SOS Report Module Installation
# Check MCP Version

# Make Directories in /tmp/mcpinfo
mkdir /tmp/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo_$(date +'%Y%-m%d')
mkdir /tmp/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo_$(date +'%Y%-m%d')/$(sudo ls /srv/salt/reclass/classes/cluster/)_logs
mkdir /tmp/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo_$(date +'%Y%-m%d')/$(sudo ls /srv/salt/reclass/classes/cluster/)_logs/openstack
mkdir /tmp/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo_$(date +'%Y%-m%d')/$(sudo ls /srv/salt/reclass/classes/cluster/)_logs/salt
mkdir /tmp/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo_$(date +'%Y%-m%d')/$(sudo ls /srv/salt/reclass/classes/cluster/)_cluster
mkdir /tmp/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo_$(date +'%Y%-m%d')/$(sudo ls /srv/salt/reclass/classes/cluster/)_cluster/nodes
mkdir /tmp/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo_$(date +'%Y%-m%d')/$(sudo ls /srv/salt/reclass/classes/cluster/)_cluster/topology
mkdir /tmp/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo_$(date +'%Y%-m%d')/$(sudo ls /srv/salt/reclass/classes/cluster/)_cluster/services
mkdir /tmp/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo_$(date +'%Y%-m%d')/$(sudo ls /srv/salt/reclass/classes/cluster/)_cluster/packages

# Get Reclass Topology 
sudo tree /srv/salt/reclass -J | gzip > /tmp/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo_$(date +'%Y%-m%d')/$(sudo ls /srv/salt/reclass/classes/cluster/)_cluster/topology/reclass_topology_$(date +'%Y%-m%d').json.gz

# Get Nodes
# Test-Ping Nodes
# Get Node DMIDecode Information
# Get Node Package Information
# Get Salt Information

# Get Openstack Component Information
# Get Openstack Version
# Check for Openstack Related Errors

# Check for System Related Errors
# Get Service Information




