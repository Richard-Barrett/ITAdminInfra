#!/bin/bash
# ============================================
# Created by: Richard Barrett
# Date Created: 09/11/2020
# Purpose: MKE Auto Collector for Support Dump
# Company: Mirantis
# ============================================

# Official documentation
# ======================================================================================================================
# https://docs.docker.com/engine/swarm/admin_guide/#back-up-the-swarm
# https://docs.docker.com/engine/reference/commandline/node_ls/
# https://www.tutorialspoint.com/unix/if-else-statement.htm
# https://unix.stackexchange.com/questions/232946/how-to-copy-all-files-from-a-directory-to-a-remote-directory-using-scp
# https://docs.docker.com/engine/swarm/swarm_manager_locking/
# https://docs.docker.com/engine/swarm/swarm_manager_locking/#unlock-a-swarm
# https://linux.die.net/man/1/zip
# https://medium.com/@raghavendar_d/backup-restore-docker-swarm-f6a77bd95681
# ...
# ======================================================================================================================
#set -e

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG

# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

# System Variables
# ================
DATE="$(date +'%Y%-m%d')"
#CLUSTER_NAME="$(sudo ls /srv/salt/reclass/classes/cluster/)"
MANAGERS=$(docker node ls -f "role=manager")
REPOSITORY_TAG=$(docker image ls --format '{{.Repository}}'| awk -F "/" '{print $1}'| sort -u | grep -v "calico")
MKE_CLUSTER_DIR="/tmp/mke_cluster/"
MKE_SUPPORT_DUMP_DIR="/tmp/mke_cluster/support_dump"
UCP_VERSION=$((docker container inspect ucp-proxy --format '{{index .Config.Labels "com.docker.ucp.version"}}' 2>/dev/null || echo -n 3.2.6)|tr -d [[:space:]])

echo "============================================================="
echo "  Starting Backup for MKE/UCP Cluster Version $UCP_VERSION..."
echo "============================================================="

echo "MKE/UCP Version is $UCP_VERSION..."
echo "Using Repsitory Tag $REPOSITORY_TAG..."
# Make Directories in $MKE_CLUSTER_DIR
if [ -d "$MKE_CLUSTER_DIR" ]; then
    echo "Directory $MKE_CLUSTER_DIR already exists..."
    if [ -d "$MKE_SUPPORT_DUMP_DIR" ]; then
        echo "Directory $MKE_SUPPORT_DUMP_DIR already exists..."
    else
	echo "Making Directory $MKE_SUPPORT_DUMP_DIR..."
        mkdir $MKE_SUPPORT_DUMP_DIR
    fi
else
    mkdir $MKE_CLUSTER_DIR
    if [ -d "$MKE_SUPPORT_DUMP_DIR" ]; then
        echo "Directory $MKE_SUPPORT_DUMP_DIR already exists..."
    else
        echo "Making Directory $MKE_SUPPORT_DUMP_DIR..."
        mkdir $MKE_SUPPORT_DUMP_DIR
    fi
fi

docker container run --rm \
--name ucp \
-v /var/run/docker.sock:/var/run/docker.sock \
--log-driver none \
$(echo $REPOSITORY_TAG)/ucp:${UCP_VERSION} \
support > \
$MKE_SUPPORT_DUMP_DIR/docker-support-${HOSTNAME}-$(date +%Y%m%d-%H_%M_%S).tgz
echo "Support Dump Collected..."
