#!/bin/bash
# ======================================================
# Author: Richard Barrett
# Date Created: 10/20/2020
# Organization: Mirantis
# Purpose: Initialize MCPInformation and SOSReport Coll.
# ======================================================

# Official documentation
# ==========================================================================================================================================================
# https://docs.saltstack.com/en/latest/ref/modules/all/salt.modules.status.html
# https://sites.google.com/site/mrxpalmeiras/saltstack/salt-cheat-sheet?tmpl=%2Fsystem%2Fapp%2Ftemplates%2Fprint%2F&showPrintDialog=1#TOC-SERVER-DIAGNOSTICS
# ...
# ==========================================================================================================================================================
start=`date +%s`
#set -e 

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG

# echo an error message before exiting
#trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

# EXIT Codes
# ==========
EXIT=1
EXIT_2=2 
EXIT_126=126

SALT_MINION_ERR="ERROR: Minions returned with non-zero exit code"

# System Variables 
# ================
DATE="$(date +'%Y%-m%d')"
CLUSTER_NAME="$(sudo ls /srv/salt/reclass/classes/cluster/)"
RECLASS_CLUSTER_DIR="/srv/salt/reclass/classes/cluster/$(sudo ls /srv/salt/reclass/classes/cluster/)"
MCP_INFO_DIR="/tmp/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo"
MCP_VERSION="$(sudo grep -wr 'mcp_version:' /srv/salt/reclass/classes/cluster/$(sudo ls /srv/salt/reclass/classes/cluster/)/infra | awk '{print $2,$3}')"
SUPPORT_DUMP_DIR="/tmp/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo/support_dump_mcpinfo_$(date +'%Y%-m%d')"
SOSREPORT_AVAILABILITY="sudo grep -i 'sosreport' $RECLASS_CLUSTER_DIR/infra/init.yml"
SOSREPORT_TARGET_FILE="$RECLASS_CLUSTER_DIR/infra/init.yml"

echo "==========================================================="
echo "  Starting Support Dump for Cloud Names $CLUSTER_NAME..."
echo "==========================================================="

echo "MCP Version is $MCP_VERSION..."
# Make Directories in /tmp/mcpinfo
if [ -d "$MCP_INFO_DIR" ]; then
  # Take action if $MCP_INFO_DIR exists
  echo "The Direcotry $MCP_INFO_DIR exists..."
  echo "Check for Pre-Existing Support Dump..."
  if [ -d "$SUPPORT_DUMP_DIR" ]; then 
    echo "Pre-Existing Support Dump $SUPPORT_DUMP_DIR Exists..."
  else
    echo "Pre-Existing Support Dump $SUPPORT_DUMP_DIR Does Not Exist..."
    echo "Making Support Dump $SUPPORT_DUMP_DIR Sub-Directory..."
    mkdir $SUPPORT_DUMP_DIR
  fi
  # Check for SOSReport Availability
  #if [
  # Prompt for Install and Congifuration of SOSReport Availability
  # Run SOSReport
else
  echo "Directory $MCP_INFO_DIR does not exist..."
  echo "Making $MCP_INFO_DIR for support dump..."
  mkdir $MCP_INFO_DIR
  if [ -d "$SUPPORT_DUMP_DIR" ]; then
    echo "Pre-Existing Support Dump $SUPPORT_DUMP_DIR Exists..."
  else
    echo "Pre-Existing Support Dump $SUPPORT_DUMP_DIR Does Not Exist..."
    echo "Making Support Dump $SUPPORT_DUMP_DIR Sub-Directory..."
    mkdir $SUPPORT_DUMP_DIR
  fi
  # Check for SOSReport Availability 
  #if [  
  # Prompt for Install and Congifuration of SOSReport Availability
  # Run SOSReport
#  echo "Process complete Support Dump Collected and Stored in `$MCP_INFO_DIR`"
fi 

# Check for SOSReport Availability
# Check for SOS Report Module
# Prompt for SOS Report Module Installation
# Check MCP Version
#while [ $EXIT
# SOSREPORT Audit Log for All Nodes
echo "Getting SOSREPORT Audit..."
SOSREPORT_AUDIT="$(sudo salt "*" cmd.exec_code bash "which sosreport" --out=json > $SUPPORT_DUMP_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_sosreport_audit.json)"
if [ ! $SOSREPORT_AUDIT ] ; then 
  echo "SOSREPORT Audit Failed Minion Reported as Down..."
  echo "Not All Minions Accounted For..."
else 
  echo "SOSREPORT Audit Succeeded..."
  CONTINUE
fi
  
#mkdir /tmp/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo_$(date +'%Y%-m%d')
#mkdir /tmp/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo_$(date +'%Y%-m%d')/$(sudo ls /srv/salt/reclass/classes/cluster/)_logs
#mkdir /tmp/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo_$(date +'%Y%-m%d')/$(sudo ls /srv/salt/reclass/classes/cluster/)_logs/openstack
#mkdir /tmp/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo_$(date +'%Y%-m%d')/$(sudo ls /srv/salt/reclass/classes/cluster/)_logs/salt
#mkdir /tmp/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo_$(date +'%Y%-m%d')/$(sudo ls /srv/salt/reclass/classes/cluster/)_cluster
#mkdir /tmp/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo_$(date +'%Y%-m%d')/$(sudo ls /srv/salt/reclass/classes/cluster/)_cluster/nodes
#mkdir /tmp/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo_$(date +'%Y%-m%d')/$(sudo ls /srv/salt/reclass/classes/cluster/)_cluster/topology
#mkdir /tmp/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo_$(date +'%Y%-m%d')/$(sudo ls /srv/salt/reclass/classes/cluster/)_cluster/services
#mkdir /tmp/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo_$(date +'%Y%-m%d')/$(sudo ls /srv/salt/reclass/classes/cluster/)_cluster/packages
echo "Getting Reclass Topology & MCP Version..."
# Get Reclass Topology 
sudo tree /srv/salt/reclass -J > $SUPPORT_DUMP_DIR/$(echo $CLUSTER_NAME)_reclass_topology_$(date +'%Y%-m%d').json #| gzip > /tmp/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo_$(date +'%Y%-m%d')/$(sudo ls /srv/salt/reclass/classes/cluster/)_cluster/topology/reclass_topology_$(date +'%Y%-m%d').json.gz
echo $MCP_VERSION > $SUPPORT_DUMP_DIR/$(echo $CLUSTER_NAME)_mcp_version.log

echo "Getting Hosts..."
# Get Nodes
#sudo cat /etc/hosts > $(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo_$(date +'%Y%-m%d')_hosts.txt 
sudo jq -R -s 'split("\n")' /etc/hosts > $SUPPORT_DUMP_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_hosts.json

# Test-Ping Nodes
sudo salt "*" test.ping --out=json > $SUPPORT_DUMP_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_test_ping.json

echo "Getting Salt Cluster Information..."
# Get Cluster Info by Node Information
sudo salt '*' status.cpuinfo --out=json > $SUPPORT_DUMP_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_nodes_cpuinfo.json
sudo salt '*' status.cpustats --out=json > $SUPPORT_DUMP_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_nodes_cpustats.json
sudo salt '*' status.meminfo --out=json > $SUPPORT_DUMP_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_nodes_meminfo.json
sudo salt '*' status.diskusage --out=json > $SUPPORT_DUMP_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_nodes_diskusage.json
sudo salt '*' status.diskstats --out=json > $SUPPORT_DUMP_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_nodes_diskstats.json
sudo salt '*' status.loadavg --out=json > $SUPPORT_DUMP_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_nodes_loadavg.json
sudo salt '*' status.netdev --out=json > $SUPPORT_DUMP_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_nodes_netdev.json
sudo salt '*' status.netstats --out=json > $SUPPORT_DUMP_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_nodes_netstats.json
sudo salt '*' status.nproc --out=json > $SUPPORT_DUMP_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_nodes_nproc.json
sudo salt '*' status.procs --out=json > $SUPPORT_DUMP_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_nodes_procs.json
sudo salt '*' status.uptime --out=json > $SUPPORT_DUMP_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_nodes_uptime.json
sudo salt '*' status.vmstats --out=json > $SUPPORT_DUMP_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_nodes_vmstats.json
sudo salt '*' status.w --out=json > $SUPPORT_DUMP_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_nodes_w.json
sudo salt "*" network.interfaces --out=json > $SUPPORT_DUMP_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_nodes_netinterfaces.json

# Get Cluster Service & Node Information
echo "Getting Node Services..."
sudo salt "*" service.get_all --out=json > $SUPPORT_DUMP_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_nodes_service_all.json

# Get Node Package Information
echo "Getting Node Packages and Possible Updates..."
sudo salt '*' status.version --out=json > $SUPPORT_DUMP_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_nodes_version.json
sudo salt "*" pkg.list_pkgs --out=json > $SUPPORT_DUMP_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_nodes_list_pkgs.json
sudo salt "*" pkg.list_upgrades --out=json > $SUPPORT_DUMP_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_nodes_list_pkg_upgrades.json

# Get Salt Information
echo "Getting Cluster Salt Jobs..."
sudo salt-run jobs.active --out=json > $SUPPORT_DUMP_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_salt_jobs_active.json
sudo salt-run jobs.list_jobs --out=json > $SUPPORT_DUMP_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_salt_jobs_audit.json

# Get Openstack Component Information
echo "Getting Openstack Control Plane Information..."
echo "Getting Nova Instances..."
sudo salt "*ctl01*" cmd.exec_code bash "source keystonercv3 && openstack server list --all-projects -f json" > $SUPPORT_DUMP_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_openstack_servers_list.json #| gzip > /tmp/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo_$(date +'%Y%-m%d')/$(sudo ls /srv/salt/reclass/classes/cluster/)_logs/openstack/openstack_servers_list_$(date +'%Y%-m%d').json.gz
sudo salt "*ctl01*" cmd.exec_code bash "source keystonercv3 && openstack hypervisor list -f json" > $SUPPORT_DUMP_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_openstack_hypervisor_list.json #| gzip > /tmp/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo_$(date +'%Y%-m%d')/$(sudo ls /srv/salt/reclass/classes/cluster/)_logs/openstack/openstack_hypervisor_list_$(date +'%Y%-m%d').json.gz
echo "Getting Endpoints List..."
sudo salt "*ctl01*" cmd.exec_code bash "source keystonercv3 && openstack endpoint list -f json" > $SUPPORT_DUMP_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_openstack_endpoint_list.json #| gzip > /tmp/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo_$(date +'%Y%-m%d')/$(sudo ls /srv/salt/reclass/classes/cluster/)_logs/openstack/openstack_endpoint_list_$(date +'%Y%-m%d').json.gz
echo "Getting Compute Service List..."
sudo salt "*ctl01*" cmd.exec_code bash "source keystonercv3 && openstack compute service list --long -f json" > $SUPPORT_DUMP_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_openstack_compute_service_list.json
echo "Getting Network Agent List..."
sudo salt "*ctl01*" cmd.exec_code bash "source keystonercv3 && openstack network agent list --long -f json" > $SUPPORT_DUMP_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_openstack_network_agent_list.json
echo "Getting Glance Image List..."
sudo salt "*ctl01*" cmd.exec_code bash "source keystonercv3 && openstack image list --long -f json" > $SUPPORT_DUMP_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_openstack_image_list.json
echo "Getting Available Nova Flavors..."
sudo salt "*ctl01*" cmd.exec_code bash "source keystonercv3 && openstack flavor list --long -f json" > $SUPPORT_DUMP_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_openstack_flavor_list.json
echo "Getting Catalog List..."
sudo salt "*ctl01*" cmd.exec_code bash "source keystonercv3 && openstack catalog list -f json" > $SUPPORT_DUMP_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_openstack_catalog_list.json
echo "Getting Project Lists..."
sudo salt "*ctl01*" cmd.exec_code bash "source keystonercv3 && openstack project list -f json" > $SUPPORT_DUMP_DIR/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo_$(date +'%Y%-m%d')_openstack_project_list.json
echo "Getting Network List..."
sudo salt "*ctl01*" cmd.exec_code bash "source keystonercv3 && openstack network list -f json" > $SUPPORT_DUMP_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_openstack_network_list.json
echo "Getting Subnet List..."
sudo salt "*ctl01*" cmd.exec_code bash "source keystonercv3 && openstack subnet list -f json" > $SUPPORT_DUMP_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_openstack_subnet_list.json
echo "Getting Floating IP List..."
sudo salt "*ctl01*" cmd.exec_code bash "source keystonercv3 && openstack floating ip list -f json" > $SUPPORT_DUMP_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_openstack_floating_ip_list.json
echo "Getting Loadbalancer List..."
sudo salt "*ctl01*" cmd.exec_code bash "source keystonercv3 && openstack loadbalancer list -f json" > $SUPPORT_DUMP_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_openstack_loadblancer_list.json
echo "Getting Keystone Users List..."
sudo salt "*ctl01*" cmd.exec_code bash "source keystonercv3 && openstack user list -f json" > $SUPPORT_DUMP_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_openstack_user_list.json
echo "Getting Regions List..."
sudo salt "*ctl01*" cmd.exec_code bash "source keystonercv3 && openstack region list -f json" > $SUPPORT_DUMP_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_openstack_region_list.json

# Get Openstack Version
echo "Getting Openstack Version..."
sudo salt "*ctl01*" cmd.run "openstack --version" --out=json > $SUPPORT_DUMP_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_openstack_version.json

# Git Log
echo "Scraping Git Information for Cluster Changes..."
sudo git --git-dir=/srv/salt/reclass/.git log --pretty=format:"%h%x09%an%x09%ad%x09%s" > $SUPPORT_DUMP_DIR/$(echo $CLUSTER_NAME)_git_$(date +'%Y%-m%d').log #| gzip > git_$(date +'%Y%-m%d').log.gz
sudo git --git-dir=/srv/salt/reclass/.git log --pretty=format:'{%n  "commit": "%H",%n  "abbreviated_commit": "%h",%n  "tree": "%T", \
%n  "abbreviated_tree": "%t",%n  "parent": "%P",%n  "abbreviated_parent": "%p",%n  "refs": "%D",%n  "encoding": "%e",%n  "subject": "%s", \
%n  "sanitized_subject_line": "%f",%n  "body": "%b",%n  "commit_notes": "%N",%n  "verification_flag": "%G?",%n  "signer": "%GS", \
%n  "signer_key": "%GK",%n  "author": {%n    "name": "%aN",%n    "email": "%aE",%n    "date": "%aD"%n  },%n  "commiter": {%n    "name": "%cN", \
%n    "email": "%cE",%n    "date": "%cD"%n  }%n},' > $SUPPORT_DUMP_DIR/$(echo $CLUSTER_NAME)_git_log_$(date +'%Y%-m%d').json #| gzip > git_log_$(date +'%Y%-m%d').json.gz
sudo git --git-dir=/srv/salt/reclass/.git --work-tree=/srv/salt/reclass/ status > $SUPPORT_DUMP_DIR/$(echo $CLUSTER_NAME)_git_$(date +'%Y%-m%d')_status.json #| gzip > git_status_$(date +'%Y%-m%d').gz
sudo git --git-dir=/srv/salt/reclass/.git diff master --stat > $SUPPORT_DUMP_DIR/$(echo $CLUSTER_NAME)_git_$(date +'%Y%-m%d')_diff_stat.log 

# Copy out Stacklight Information
echo "Scraping Prometheus for Current Alerts..."

# Scrape Grafana
echo "Scraping Grafana..."

# Scrape Kibana
echo "Scraping Kibana..."

# Copy Openstack Logs to Salt-Master
# Nova
# Cinder
# Glance
# Nuetron
# Keystone
# Octavia

# Compress Directory with TAR
# ===========================
echo "Compressing $SUPPORT_DUMP_DIR..."
tar -zcf $SUPPORT_DUMP_DIR.tar.gz $SUPPORT_DUMP_DIR
echo "Directory $SUPPORT_DUMP_DIR succesfully compressed..."

# Leave Only Compressed Directory as File
# =======================================
#echo "Cleaning up $SUPPORT_DUMP_DIR Directory..."
#rm -rf $SUPPORT_DUMP_DIR
#echo "Clean-up Successful..."

echo "============================"
echo "   Ending Support Dump..."
echo "============================"
end=`date +%s`
echo Execution time was `expr $end - $start` seconds.
