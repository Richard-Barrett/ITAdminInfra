#!/bin/bash
# ======================================================
# Author: Richard Barrett
# Date Created: 12/04/2020
# Organization: Mirantis
# Purpose: Initialize MKE Automated Backup for MKE/UCP
# ======================================================

# Official documentation
# ==========================================================================================================================================================
# https://docs.mirantis.com/docker-enterprise/v3.1/dockeree-products/mke/mke-cli-reference/mke-cli-backup.html#
# ...
# ==========================================================================================================================================================
start=`date +%s`
#set -e

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG

# echo an error message before exiting
#trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

# System Variables
# ================
DATE="$(date +'%Y%-m%d')"
CLUSTER_NAME="$(sudo ls /srv/salt/reclass/classes/cluster/)"
MANAGERS=$(docker node ls -f "role=manager")
REPOSITORY_TAG=$(docker image ls --format '{{.Repository}}'| awk -F "/" '{print $1}'| sort -u | grep -v "calico")
MKE_CLUSTER_DIR="/tmp/mke_cluster/"
MKE_BACKUP_DIR="/tmp/mke_cluster/backups"
UCP_VERSION=$((docker container inspect ucp-proxy --format '{{index .Config.Labels "com.docker.ucp.version"}}' 2>/dev/null || echo -n 3.2.6)|tr -d [[:space:]])
HASH=$(echo "dockeradmin_$(date +'%Y%-m%d')" | base64)

echo "============================================================="
echo "  Starting Backup for MKE/UCP Cluster Version $UCP_VERSION..."
echo "============================================================="

# Make Directories in $MKE_CLUSTER_DIR
# ====================================
echo "MKE/UCP Version is $UCP_VERSION..."
echo "Using Repsitory Tag $REPOSITORY_TAG..."
# Make Directories in $MKE_CLUSTER_DIR
if [ -d "$MKE_CLUSTER_DIR" ]; then
    echo "Directory $MKE_CLUSTER_DIR already exists..."
    if [ -d "$MKE_BACKUP_DIR" ]; then
        echo "Directory $MKE_BACKUP_DIR already exists..."
    else
	echo "Making Directory $MKE_BACKUP_DIR..."
        mkdir $MKE_BACKUP_DIR
    fi
else
    mkdir $MKE_CLUSTER_DIR
    if [ -d "$MKE_BACKUP_DIR" ]; then
        echo "Directory $MKE_BACKUP_DIR already exists..."
    else
        echo "Making Directory $MKE_BACKUP_DIR..."
        mkdir $MKE_BACKUP_DIR
    fi
fi


docker container run \
    --rm \
    --interactive \
    --name ucp \
    --log-driver none \
    --volume /var/run/docker.sock:/var/run/docker.sock \
    $(echo $REPOSITORY_TAG)/ucp \
    backup [command --passphrase $HASH] > $MKE_BACKUP_DIR/mke_cluster_backup_$DATE.tar

echo "============================================================="
echo "  Ending Backup for MKE/UCP Cluster Version $UCP_VERSION..."
echo "============================================================="
