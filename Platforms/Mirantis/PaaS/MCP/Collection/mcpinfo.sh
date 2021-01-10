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
PROMETHEUS_SCRAPE_TARGET="grep mon /etc/hosts | awk '{print $1}' | sed -n 1p"
PROMETHEUS_SCRAPE="curl -s http://$(grep mon /etc/hosts | awk '{print $1}' | sed -n 1p):15010/alerts | grep -wi active"
KIBANA_SCRAPE_TARGET="grep log /etc/hosts | awk '{print $1}' | sed -n 1p"

# Support Dump Sub-Directories
# ============================
OPENSTACK_DIR="/tmp/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo/support_dump_mcpinfo_$(date +'%Y%-m%d')/openstack"
NODES_DIR="/tmp/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo/support_dump_mcpinfo_$(date +'%Y%-m%d')/nodes"
CLUSTER_DIR="/tmp/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo/support_dump_mcpinfo_$(date +'%Y%-m%d')/cluster"
RECLASS_DIR="/tmp/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo/support_dump_mcpinfo_$(date +'%Y%-m%d')/reclass"
GIT_DIR="/tmp/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo/support_dump_mcpinfo_$(date +'%Y%-m%d')/git"
STACKLIGHT_DIR="/tmp/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo/support_dump_mcpinfo_$(date +'%Y%-m%d')/stacklight"
PROMETHEUS_DIR="/tmp/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo/support_dump_mcpinfo_$(date +'%Y%-m%d')/stacklight/prometheus"
KIBANA_DIR="/tmp/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo/support_dump_mcpinfo_$(date +'%Y%-m%d')/stacklight/kibana"
GRAFANA_DIR="/tmp/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo/support_dump_mcpinfo_$(date +'%Y%-m%d')/stacklight/grafana"

# Nodes Sub-Directories
# =====================
CTL_NODES_DIR="/tmp/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo/support_dump_mcpinfo_$(date +'%Y%-m%d')/nodes/ctl_nodes"
CMP_NODES_DIR="/tmp/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo/support_dump_mcpinfo_$(date +'%Y%-m%d')/nodes/cmp_nodes"
OSD_NODES_DIR="/tmp/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo/support_dump_mcpinfo_$(date +'%Y%-m%d')/nodes/osd_nodes"
KVM_NODES_DIR="/tmp/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo/support_dump_mcpinfo_$(date +'%Y%-m%d')/nodes/kvm_nodes"
BMT_NODES_DIR="/tmp/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo/support_dump_mcpinfo_$(date +'%Y%-m%d')/nodes/bmt_nodes"
PRX_NODES_DIR="/tmp/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo/support_dump_mcpinfo_$(date +'%Y%-m%d')/nodes/proxy_nodes"
LOG_NODES_DIR="/tmp/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo/support_dump_mcpinfo_$(date +'%Y%-m%d')/nodes/log_nodes"
RGW_NODES_DIR="/tmp/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo/support_dump_mcpinfo_$(date +'%Y%-m%d')/nodes/rgw_nodes"
MSG_NODES_DIR="/tmp/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo/support_dump_mcpinfo_$(date +'%Y%-m%d')/nodes/msg_nodes"
NAL_NODES_DIR="/tmp/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo/support_dump_mcpinfo_$(date +'%Y%-m%d')/nodes/nal_nodes"
CMN_NODES_DIR="/tmp/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo/support_dump_mcpinfo_$(date +'%Y%-m%d')/nodes/cmn_nodes"
MDB_NODES_DIR="/tmp/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo/support_dump_mcpinfo_$(date +'%Y%-m%d')/nodes/mdb_nodes"
GTW_NODES_DIR="/tmp/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo/support_dump_mcpinfo_$(date +'%Y%-m%d')/nodes/gtw_nodes"
NTW_NODES_DIR="/tmp/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo/support_dump_mcpinfo_$(date +'%Y%-m%d')/nodes/ntw_nodes"
DBS_NODES_DIR="/tmp/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo/support_dump_mcpinfo_$(date +'%Y%-m%d')/nodes/dbs_nodes"
MON_NODES_DIR="/tmp/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo/support_dump_mcpinfo_$(date +'%Y%-m%d')/nodes/mon_nodes"

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
    mkdir $OPENSTACK_DIR $NODES_DIR $CLUSTER_DIR $RECLASS_DIR $GIT_DIR
    mkdir $STACKLIGHT_DIR $PROMETHEUS_DIR $KIBANA_DIR $GRAFANA_DIR
    mkdir $CTL_NODES_DIR $CMP_NODES_DIR $OSD_NODES_DIR $KVM_NODES_DIR
    mkdir $BMT_NODES_DIR $PRX_NODES_DIR $LOG_NODES_DIR $RGW_NODES_DIR
    mkdir $MSG_NODES_DIR $NAL_NODES_DIR $CMN_NODES_DIR $MDB_NODES_DIR
    mkdir $GTW_NODES_DIR $NTW_NODES_DIR $DBS_NODES_DIR $MON_NODES_DIR
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
    mkdir $OPENSTACK_DIR $NODES_DIR $CLUSTER_DIR $RECLASS_DIR $GIT_DIR
    mkdir $STACKLIGHT_DIR $PROMETHEUS_DIR $KIBANA_DIR $GRAFANA_DIR
    mkdir $CTL_NODES_DIR $CMP_NODES_DIR $OSD_NODES_DIR $KVM_NODES_DIR
    mkdir $BMT_NODES_DIR $PRX_NODES_DIR $LOG_NODES_DIR $RGW_NODES_DIR
    mkdir $MSG_NODES_DIR $NAL_NODES_DIR $CMN_NODES_DIR $MDB_NODES_DIR
    mkdir $GTW_NODES_DIR $NTW_NODES_DIR $DBS_NODES_DIR $MON_NODES_DIR
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
SOSREPORT_AUDIT="$(sudo salt "*" cmd.exec_code bash "which sosreport" -t 2 --hide-timeout --out=json > $SUPPORT_DUMP_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_sosreport_audit.json)"
if [ ! $SOSREPORT_AUDIT ] ; then 
  echo "SOSREPORT Audit Created..."
else
  echo "SOSREPORT Audit Failed Minion Reported as Down..."
  echo "Not All Minions Accounted For..." 
  CONTINUE
fi
  
echo "Getting Reclass Topology & MCP Version..."
# Get Reclass Topology 
sudo tree /srv/salt/reclass -J > $RECLASS_DIR/$(echo $CLUSTER_NAME)_reclass_topology_$(date +'%Y%-m%d').json 
echo $MCP_VERSION > $SUPPORT_DUMP_DIR/$(echo $CLUSTER_NAME)_mcp_version.log

echo "Getting Hosts..."
# Get Nodes
#sudo cat /etc/hosts > $(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo_$(date +'%Y%-m%d')_hosts.txt 
sudo jq -R -s 'split("\n")' /etc/hosts > $SUPPORT_DUMP_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_hosts.json

# Test-Ping Nodes
sudo salt "*" test.ping -t 5 --hide-timeout --out=json > $SUPPORT_DUMP_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_test_ping.json

# Collecting Errors Across ctl* Nodes
echo "Getting Errors on ctl* Nodes..."
sudo salt "*ctl01*" cmd.run "sudo grep -Eir 'ERROR' /var/log/ -R" > $CTL_NODES_DIR/ctl01_errors.log
sudo salt "*ctl02*" cmd.run "sudo grep -Eir 'ERROR' /var/log/ -R" > $CTL_NODES_DIR/ctl02_errors.log
sudo salt "*ctl03*" cmd.run "sudo grep -Eir 'ERROR' /var/log/ -R" > $CTL_NODES_DIR/ctl03_errors.log

# Collection Warnings Across ctl* Nodes
echo "Getting Warnings on ctl* Nodes..."
sudo salt "*ctl01*" cmd.run "sudo grep -Eir 'WARNING' /var/log/ -R" > $CTL_NODES_DIR/ctl01_warnings.log
sudo salt "*ctl02*" cmd.run "sudo grep -Eir 'WARNING' /var/log/ -R" > $CTL_NODES_DIR/ctl02_warnings.log
sudo salt "*ctl03*" cmd.run "sudo grep -Eir 'WARNING' /var/log/ -R" > $CTL_NODES_DIR/ctl03_warnings.log

# Collecting Errors on msg* nodes
echo "Getting Errors on msg* Nodes..."
sudo salt "*msg01*" cmd.run "sudo grep -Eir 'ERROR' /var/log/ -R" > $MSG_NODES_DIR/msg01_errors.log
sudo salt "*msg02*" cmd.run "sudo grep -Eir 'ERROR' /var/log/ -R" > $MSG_NODES_DIR/msg02_errors.log
sudo salt "*msg03*" cmd.run "sudo grep -Eir 'ERROR' /var/log/ -R" > $MSG_NODES_DIR/msg03_errors.log

# Collecting Warnings on msg* nodes
echo "Getting Warningss on msg* Nodes..."
sudo salt "*msg01*" cmd.run "sudo grep -Eir 'WARNING' /var/log/ -R" > $MSG_NODES_DIR/msg01_warnings.log
sudo salt "*msg02*" cmd.run "sudo grep -Eir 'WARNING' /var/log/ -R" > $MSG_NODES_DIR/msg02_warnings.log
sudo salt "*msg03*" cmd.run "sudo grep -Eir 'WARNING' /var/log/ -R" > $MSG_NODES_DIR/msg03_warnings.log

# Collecting Errors from prx* nodes
echo "Getting Errors on prx* Nodes..."
sudo salt "*prx01*" cmd.run "sudo grep -Eir 'ERROR' /var/log/ -R" > $PRX_NODES_DIR/prx01_errors.log
sudo salt "*prx02*" cmd.run "sudo grep -Eir 'ERROR' /var/log/ -R" > $PRX_NODES_DIR/prx02_errors.log

# Collecting Warnings from prx* nodes
echo "Getting Warnings on prx* Nodes..."
sudo salt "*prx01*" cmd.run "sudo grep -Eir 'WARNING' /var/log/ -R" > $PRX_NODES_DIR/prx01_warnings.log
sudo salt "*prx02*" cmd.run "sudo grep -Eir 'WARNING' /var/log/ -R" > $PRX_NODES_DIR/prx02_warnings.log

# Collecting Errors from log* nodes
echo "Getting Errors on log* Nodes..."
sudo salt "*log01*" cmd.run "sudo grep -Eir 'ERROR' /var/log/ -R" > $LOG_NODES_DIR/log01_errors.log
sudo salt "*log02*" cmd.run "sudo grep -Eir 'ERROR' /var/log/ -R" > $LOG_NODES_DIR/log02_errors.log
sudo salt "*log03*" cmd.run "sudo grep -Eir 'ERROR' /var/log/ -R" > $LOG_NODES_DIR/log03_errors.log

# Collecting Warnings from log* nodes
echo "Getting Warnings on log* Nodes..."
sudo salt "*log01*" cmd.run "sudo grep -Eir 'WARNING' /var/log/ -R" > $LOG_NODES_DIR/log01_warnings.log
sudo salt "*log02*" cmd.run "sudo grep -Eir 'WARNING' /var/log/ -R" > $LOG_NODES_DIR/log02_warnings.log
sudo salt "*log03*" cmd.run "sudo grep -Eir 'WARNING' /var/log/ -R" > $LOG_NODES_DIR/log03_warnings.log

# Collecting Errors from mon* Nodes
echo "Getting Errors on mon* Nodes..."
sudo salt "*mon01*" cmd.run "sudo grep -Eir 'ERROR' /var/log/ -R" > $MON_NODES_DIR/mon01_errors.log
sudo salt "*mon02*" cmd.run "sudo grep -Eir 'ERROR' /var/log/ -R" > $MON_NODES_DIR/mon02_errors.log
sudo salt "*mon03*" cmd.run "sudo grep -Eir 'ERROR' /var/log/ -R" > $MON_NODES_DIR/mon03_errors.log

# Collecting Warnings from mon* Nodes
echo "Getting Warnings on mon* Nodes..."
sudo salt "*mon01*" cmd.run "sudo grep -Eir 'WARNING' /var/log/ -R" > $MON_NODES_DIR/mon01_warnings.log
sudo salt "*mon02*" cmd.run "sudo grep -Eir 'WARNING' /var/log/ -R" > $MON_NODES_DIR/mon02_warnings.log
sudo salt "*mon03*" cmd.run "sudo grep -Eir 'WARNING' /var/log/ -R" > $MON_NODES_DIR/mon03_warnings.log

# Get Cluster Info by Node Information
echo "Getting Salt Cluster Information..."
sudo salt '*' status.cpuinfo --out=json > $CLUSTER_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_nodes_cpuinfo.json
sudo salt '*' status.cpustats --out=json > $CLUSTER_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_nodes_cpustats.json
sudo salt '*' status.meminfo --out=json > $CLUSTER_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_nodes_meminfo.json
sudo salt '*' status.diskusage --out=json > $CLUSTER_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_nodes_diskusage.json
sudo salt '*' status.diskstats --out=json > $CLUSTER_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_nodes_diskstats.json
sudo salt '*' status.loadavg --out=json > $CLUSTER_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_nodes_loadavg.json
sudo salt '*' status.netdev --out=json > $CLUSTER_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_nodes_netdev.json
sudo salt '*' status.netstats --out=json > $CLUSTER_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_nodes_netstats.json
sudo salt '*' status.nproc --out=json > $CLUSTER_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_nodes_nproc.json
sudo salt '*' status.procs --out=json > $CLUSTER_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_nodes_procs.json
sudo salt '*' status.uptime --out=json > $CLUSTER_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_nodes_uptime.json
sudo salt '*' status.vmstats --out=json > $CLUSTER_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_nodes_vmstats.json
sudo salt '*' status.w --out=json > $CLUSTER_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_nodes_w.json
sudo salt "*" network.interfaces --out=json > $CLUSTER_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_nodes_netinterfaces.json

# Get Cluster Service & Node Information
echo "Getting Node Services..."
sudo salt "*" service.get_all --out=json > $CLUSTER_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_nodes_service_all.json

# Get Node Package Information
echo "Getting Node Packages and Possible Updates..."
sudo salt '*' status.version --out=json > $NODES_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_nodes_version.json
sudo salt "*" pkg.list_pkgs --out=json > $NODES_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_nodes_list_pkgs.json
sudo salt "*" pkg.list_upgrades --out=json > $NODES_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_nodes_list_pkg_upgrades.json

# Get Salt Information
echo "Getting Cluster Salt Jobs..."
sudo salt-run jobs.active --out=json > $CLUSTER_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_salt_jobs_active.json
sudo salt-run jobs.list_jobs --out=json > $CLUSTER_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_salt_jobs_audit.json

# Get Openstack Component Information
echo "Getting Openstack Control Plane Information..."
echo "Getting Nova Instances..."
sudo salt "*ctl01*" cmd.exec_code bash "source keystonercv3 && openstack server list --all-projects -f json" > $OPENSTACK_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_openstack_servers_list.json 
sudo salt "*ctl01*" cmd.exec_code bash "source keystonercv3 && openstack hypervisor list -f json" > $OPENSTACK_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_openstack_hypervisor_list.json 
echo "Getting Endpoints List..."
sudo salt "*ctl01*" cmd.exec_code bash "source keystonercv3 && openstack endpoint list -f json" > $OPENSTACK_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_openstack_endpoint_list.json 
echo "Getting Compute Service List..."
sudo salt "*ctl01*" cmd.exec_code bash "source keystonercv3 && openstack compute service list --long -f json" > $OPENSTACK_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_openstack_compute_service_list.json
echo "Getting Network Agent List..."
sudo salt "*ctl01*" cmd.exec_code bash "source keystonercv3 && openstack network agent list --long -f json" > $OPENSTACK_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_openstack_network_agent_list.json
echo "Getting Glance Image List..."
sudo salt "*ctl01*" cmd.exec_code bash "source keystonercv3 && openstack image list --long -f json" > $OPENSTACK_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_openstack_image_list.json
echo "Getting Available Nova Flavors..."
sudo salt "*ctl01*" cmd.exec_code bash "source keystonercv3 && openstack flavor list --long -f json" > $OPENSTACK_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_openstack_flavor_list.json
echo "Getting Catalog List..."
sudo salt "*ctl01*" cmd.exec_code bash "source keystonercv3 && openstack catalog list -f json" > $OPENSTACK_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_openstack_catalog_list.json
echo "Getting Project Lists..."
sudo salt "*ctl01*" cmd.exec_code bash "source keystonercv3 && openstack project list -f json" > $OPENSTACK_DIR/$(sudo ls /srv/salt/reclass/classes/cluster/)_mcpinfo_$(date +'%Y%-m%d')_openstack_project_list.json
echo "Getting Network List..."
sudo salt "*ctl01*" cmd.exec_code bash "source keystonercv3 && openstack network list -f json" > $OPENSTACK_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_openstack_network_list.json
echo "Getting Subnet List..."
sudo salt "*ctl01*" cmd.exec_code bash "source keystonercv3 && openstack subnet list -f json" > $OPENSTACK_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_openstack_subnet_list.json
echo "Getting Floating IP List..."
sudo salt "*ctl01*" cmd.exec_code bash "source keystonercv3 && openstack floating ip list -f json" > $OPENSTACK_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_openstack_floating_ip_list.json
echo "Getting Loadbalancer List..."
sudo salt "*ctl01*" cmd.exec_code bash "source keystonercv3 && openstack loadbalancer list -f json" > $OPENSTACK_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_openstack_loadblancer_list.json
echo "Getting Keystone Users List..."
sudo salt "*ctl01*" cmd.exec_code bash "source keystonercv3 && openstack user list -f json" > $OPENSTACK_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_openstack_user_list.json
echo "Getting Regions List..."
sudo salt "*ctl01*" cmd.exec_code bash "source keystonercv3 && openstack region list -f json" > $OPENSTACK_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_openstack_region_list.json

# Get Openstack Version
echo "Getting Openstack Version..."
sudo salt "*ctl01*" cmd.run "openstack --version" --out=json > $OPENSTACK_DIR/$(echo $CLUSTER_NAME)_mcpinfo_$(date +'%Y%-m%d')_openstack_version.json

# Git Log
echo "Scraping Git Information for Cluster Changes..."
sudo git --git-dir=/srv/salt/reclass/.git log --pretty=format:"%h%x09%an%x09%ad%x09%s" > $GIT_DIR/$(echo $CLUSTER_NAME)_git_$(date +'%Y%-m%d').log #| gzip > git_$(date +'%Y%-m%d').log.gz
sudo git --git-dir=/srv/salt/reclass/.git log --pretty=format:'{%n  "commit": "%H",%n  "abbreviated_commit": "%h",%n  "tree": "%T", \
%n  "abbreviated_tree": "%t",%n  "parent": "%P",%n  "abbreviated_parent": "%p",%n  "refs": "%D",%n  "encoding": "%e",%n  "subject": "%s", \
%n  "sanitized_subject_line": "%f",%n  "body": "%b",%n  "commit_notes": "%N",%n  "verification_flag": "%G?",%n  "signer": "%GS", \
%n  "signer_key": "%GK",%n  "author": {%n    "name": "%aN",%n    "email": "%aE",%n    "date": "%aD"%n  },%n  "commiter": {%n    "name": "%cN", \
%n    "email": "%cE",%n    "date": "%cD"%n  }%n},' > $GIT_DIR/$(echo $CLUSTER_NAME)_git_log_$(date +'%Y%-m%d').json #| gzip > git_log_$(date +'%Y%-m%d').json.gz
sudo git --git-dir=/srv/salt/reclass/.git --work-tree=/srv/salt/reclass/ status > $GIT_DIR/$(echo $CLUSTER_NAME)_git_$(date +'%Y%-m%d')_status.json #| gzip > git_status_$(date +'%Y%-m%d').gz
sudo git --git-dir=/srv/salt/reclass/.git diff master --stat > $GIT_DIR/$(echo $CLUSTER_NAME)_git_$(date +'%Y%-m%d')_diff_stat.log 

# Copy out Stacklight Information
echo "Scraping Prometheus for Current Alerts..."
$PROMETHEUS_SCRAPE > $PROMETHEUS_DIR/alerts_active_$(date +'%Y%-m%d').html

# Scrape Kibana
echo "Scraping Kibana..."
curl -s -XGET http://$KIBANA_SCRAPE_TARGET:9200/_cluster/health?pretty > $KIBANA_DIR/$(echo $CLUSTER_NAME)_cluster_health_$(date +'%Y%-m%d').json
curl -s -XGET http://$KIBANA_SCRAPE_TARGET:9200/_cluster/state?pretty > $KIBANA_DIR/$(echo $CLUSTER_NAME)_cluster_state_$(date +'%Y%-m%d').json
curl -s -XGET http://$KIBANA_SCRAPE_TARGET:9200/_segments/?pretty > $KIBANA_DIR/$(echo $CLUSTER_NAME)_segments_$(date +'%Y%-m%d').json
curl -s -XGET http://$KIBANA_SCRAPE_TARGET:9200/_cat/allocation > $KIBANA_DIR/$(echo $CLUSTER_NAME)_cluster_allocation_$(date +'%Y%-m%d').json
curl -s -XGET http://$KIBANA_SCRAPE_TARGET:9200/_cat/segments > $KIBANA_DIR/$(echo $CLUSTER_NAME)_cluster_segments_$(date +'%Y%-m%d').json
curl -s -XGET http://$KIBANA_SCRAPE_TARGET:9200/_cat/shards > $KIBANA_DIR/$(echo $CLUSTER_NAME)_cluster_shards_$(date +'%Y%-m%d').json
curl -s -XGET http://$KIBANA_SCRAPE_TARGET:9200/_cat/thread_pool > $KIBANA_DIR/$(echo $CLUSTER_NAME)_cluster_thread_pool_$(date +'%Y%-m%d').json
curl -s -XGET http://$KIBANA_SCRAPE_TARGET:9200/_cat/indices > $KIBANA_DIR/$(echo $CLUSTER_NAME)_cluster_indicies_$(date +'%Y%-m%d').json

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
