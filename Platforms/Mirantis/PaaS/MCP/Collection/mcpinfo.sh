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
sudo salt "*ctl01*" cmd.exec_code bash "source keystonercv3 && openstack server list --all-projects -f json" | gzip > openstack_servers_$(date +'%Y%-m%d').json.gz


# Get Openstack Version
# Check for Openstack Related Errors

# Check for System Related Errors
# Get Service Information

# Git Log
sudo git --git-dir=/srv/salt/reclass/.git log --pretty=format:"%h%x09%an%x09%ad%x09%s" | gzip > git_$(date +'%Y%-m%d').log.gz
sudo git --git-dir=/srv/salt/reclass/.git log --pretty=format:'{%n  "commit": "%H",%n  "abbreviated_commit": "%h",%n  "tree": "%T", \
%n  "abbreviated_tree": "%t",%n  "parent": "%P",%n  "abbreviated_parent": "%p",%n  "refs": "%D",%n  "encoding": "%e",%n  "subject": "%s", \
%n  "sanitized_subject_line": "%f",%n  "body": "%b",%n  "commit_notes": "%N",%n  "verification_flag": "%G?",%n  "signer": "%GS", \
%n  "signer_key": "%GK",%n  "author": {%n    "name": "%aN",%n    "email": "%aE",%n    "date": "%aD"%n  },%n  "commiter": {%n    "name": "%cN", \
%n    "email": "%cE",%n    "date": "%cD"%n  }%n},' | gzip > git_log_$(date +'%Y%-m%d').json.gz
sudo git --git-dir=/srv/salt/reclass/.git --work-tree=/srv/salt/reclass/ status | gzip > git_status_$(date +'%Y%-m%d').gz

