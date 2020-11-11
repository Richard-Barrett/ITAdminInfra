#!/bin/bash
# =====================================================
# Author: Richard Barrett
# Date Created: 03/14/2020
# Organziation: Mirantis
# Purpose: Initalize Manual Logrotate on Openstack Logs
# =====================================================

# Official documentation
# ======================================================================================================================
https://docs.saltstack.com/en/latest/ref/modules/all/salt.modules.status.html
https://sites.google.com/site/mrxpalmeiras/saltstack/salt-cheat-sheet?tmpl=%2Fsystem%2Fapp%2Ftemplates%2Fprint%2F&showPrintDialog=1#TOC-SERVER-DIAGNOSTICS
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
sudo cat /etc/hosts

# Test-Ping Nodes
sudo salt "*" test.ping --out=json

# Get Cluster Info by Node Information
sudo salt '*' status.cpuinfo --out=json
sudo salt '*' status.cpustats --out=json
sudo salt '*' status.meminfo --out=json
sudo salt '*' status.diskusage --out=json
sudo salt '*' status.diskstats --out=json
sudo salt '*' status.loadavg --out=json
sudo salt '*' status.netdev --out=json
sudo salt '*' status.netstats --out=json
sudo salt '*' status.nproc --out=json
sudo salt '*' status.procs --out=json
sudo salt '*' status.uptime --out=json
sudo salt '*' status.vmstats --out=json
sudo salt '*' status.w --out=json
sudo salt "*" network.interfaces --out=json

# Get Cluster Service & Node Information
sudo salt "*" service.get_all --out=json

# Get Node Package Information
sudo salt '*' status.version --out=json
sudo salt "*" pkg.list_pkgs --out=json
sudo salt "*" pkg.list_upgrades --out=json

# Get Salt Information
sudo salt-run jobs.active --out=json
sudo salt-run jobs.list_jobs --out=json

# Get Openstack Component Information
sudo salt "*ctl01*" cmd.exec_code bash "source keystonercv3 && openstack server list --all-projects -f json" | gzip > /tmp/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo_$(date +'%Y%-m%d')/$(sudo ls /srv/salt/reclass/classes/cluster/)_logs/openstack/openstack_servers_list_$(date +'%Y%-m%d').json.gz
sudo salt "*ctl01*" cmd.exec_code bash "source keystonercv3 && openstack hypervisor list -f json" | gzip > /tmp/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo_$(date +'%Y%-m%d')/$(sudo ls /srv/salt/reclass/classes/cluster/)_logs/openstack/openstack_hypervisor_list_$(date +'%Y%-m%d').json.gz
sudo salt "*ctl01*" cmd.exec_code bash "source keystonercv3 && openstack endpoint list -f json" | gzip > /tmp/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo_$(date +'%Y%-m%d')/$(sudo ls /srv/salt/reclass/classes/cluster/)_logs/openstack/openstack_endpoint_list_$(date +'%Y%-m%d').json.gz
sudo salt "*ctl01*" cmd.exec_code bash "source keystonercv3 && openstack compute service list --long -f json"
sudo salt "*ctl01*" cmd.exec_code bash "source keystonercv3 && openstack network agent list --long -f json"

sudo salt "*ctl01*" cmd.exec_code bash "source keystonercv3 && openstack image list --long -f json"
sudo salt "*ctl01*" cmd.exec_code bash "source keystonercv3 && openstack flavor list --long -f json"
sudo salt "*ctl01*" cmd.exec_code bash "source keystonercv3 && openstack catalog list -f json"
sudo salt "*ctl01*" cmd.exec_code bash "source keystonercv3 && openstack project list -f json"

sudo salt "*ctl01*" cmd.exec_code bash "source keystonercv3 && openstack network list -f json"
sudo salt "*ctl01*" cmd.exec_code bash "source keystonercv3 && openstack subnet list -f json"
sudo salt "*ctl01*" cmd.exec_code bash "source keystonercv3 && openstack floating ip list -f json"
sudo salt "*ctl01*" cmd.exec_code bash "source keystonercv3 && openstack loadbalancer list -f json"-0\0
sudo salt "*ctl01*" cmd.exec_code bash "source keystonercv3 && openstack user list -f json"
sudo salt "*ctl01*" cmd.exec_code bash "source keystonercv3 && openstack region list -f json"

# Get Openstack Version
sudo salt "*ctl01*" cmd.run "openstack --version" --out=json

# Git Log
sudo git --git-dir=/srv/salt/reclass/.git log --pretty=format:"%h%x09%an%x09%ad%x09%s" | gzip > git_$(date +'%Y%-m%d').log.gz
sudo git --git-dir=/srv/salt/reclass/.git log --pretty=format:'{%n  "commit": "%H",%n  "abbreviated_commit": "%h",%n  "tree": "%T", \
%n  "abbreviated_tree": "%t",%n  "parent": "%P",%n  "abbreviated_parent": "%p",%n  "refs": "%D",%n  "encoding": "%e",%n  "subject": "%s", \
%n  "sanitized_subject_line": "%f",%n  "body": "%b",%n  "commit_notes": "%N",%n  "verification_flag": "%G?",%n  "signer": "%GS", \
%n  "signer_key": "%GK",%n  "author": {%n    "name": "%aN",%n    "email": "%aE",%n    "date": "%aD"%n  },%n  "commiter": {%n    "name": "%cN", \
%n    "email": "%cE",%n    "date": "%cD"%n  }%n},' | gzip > git_log_$(date +'%Y%-m%d').json.gz
sudo git --git-dir=/srv/salt/reclass/.git --work-tree=/srv/salt/reclass/ status | gzip > git_status_$(date +'%Y%-m%d').gz

