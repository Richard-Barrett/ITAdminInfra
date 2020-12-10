#!/bin/bash
# ============================================
# Created by: Richard Barrett
# Date Created: 11/11/2020
# Purpose: MKE Auto Collector for Support Dump
# Company: Mirantis
# ============================================
#set -e

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG

# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

# System Variables
# ================
DATE="$(date +'%Y%-m%d')"
REPOSITORY_TAG=$(docker image ls --format '{{.Repository}}'| awk -F "/" '{print $1}'| sort -u | grep -v "calico")
MKE_CLUSTER_DIR="/tmp/mke_cluster/"
MKE_SUPPORT_DUMP_DIR="/tmp/mke_cluster/support_dump"
MKE_UCP_VERSION=$((docker container inspect ucp-proxy --format '{{index .Config.Labels "com.docker.ucp.version"}}' 2>/dev/null || echo -n 3.2.6)|tr -d [[:space:]])
REQUEST_URL="https://127.0.0.1"
USERNAME="admin"
PASSWORD="dockeradmin"
AUTHTOKEN=$(curl -sk -d '{"username":"$USERNAME","password":"$PASSWORD"}' ${REQUEST_URL}/auth/login | jq -r .auth_token)

echo "============================================================="
echo "  Starting Backup for MKE/UCP Cluster Version $UCP_VERSION..."
echo "============================================================="
echo "MKE/UCP Version is $MKE_UCP_VERSION..."
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

AUTHTOKEN=$(curl -sk -d '{"username":"$USERNAME","password":"$PASSWORD"}' ${REQUEST_URL}/auth/login | jq -r .auth_token)
curl -k -X POST "${REQUEST_URL}/api/support" -H 'Accept-encoding: gzip' -H  "accept: application/json" -H "Authorization: Bearer $AUTHTOKEN" \
-o $MKE_SUPPORT_DUMP_DIR/docker-support-${HOSTNAME}-$(date +%Y%m%d-%H_%M_%S)_support.zip
echo "Support Dump Collected..."
echo "============================================================="
echo "  Ending Backup for MKE/UCP Cluster Version $UCP_VERSION..."
echo "============================================================="

#docker container run --rm \
#--name ucp \
#-v /var/run/docker.sock:/var/run/docker.sock \
#--log-driver none \
#$(echo $REPOSITORY_TAG)/ucp:${MKE_UCP_VERSION} \
#support > \
#$MKE_SUPPORT_DUMP_DIR/docker-support-${HOSTNAME}-$(date +%Y%m%d-%H_%M_%S).tgz
