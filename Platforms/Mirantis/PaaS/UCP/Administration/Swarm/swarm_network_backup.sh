#!/bin/bash
# ===========================================
# Created by: Richard Barrett
# Date Created: 09/11/2020 
# Purpose: Local or Remote Backup for Swarm 
# Company: Mirantis
# ===========================================

# Official documentation
# ======================================================================================================================
# https://docs.docker.com/engine/swarm/admin_guide/#back-up-the-swarm
# https://docs.docker.com/engine/reference/commandline/node_ls/
# https://www.tutorialspoint.com/unix/if-else-statement.htm
# https://unix.stackexchange.com/questions/232946/how-to-copy-all-files-from-a-directory-to-a-remote-directory-using-scp
# https://docs.docker.com/engine/swarm/swarm_manager_locking/
# https://docs.docker.com/engine/swarm/swarm_manager_locking/#unlock-a-swarm
# https://linux.die.net/man/1/zip
# https://docs.docker.com/network/overlay/
# ...
# ======================================================================================================================
# Set Trap Error 
set -e 

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG

# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

# System Variables
DOCKER_BRIDGE="docker network ls | egrep "bridge" | awk '{print $1}' | head -n +1"
DOCKER_BRIDGE_BACKUP="docker network inspect $(docker network ls | grep -i "wbridge" | awk '{print $1}' | head -n +1) >> /tmp/backup/swarm_docker_bridge_backup_$(date +'%Y%-^Cd').json"
DOCKER_GATEWAY_BRIDGE="docker network ls | grep -i "docker_gwbridge" | awk '{print $1}'"
DOCKER_GATEWAY_BRIDGE_BACKUP="docker network inspect $(docker network ls | grep -i "docker_gwbridge" | awk '{print $1}') >> /tmp/backup/swarm_docker_gwbridge_backup_$(date +'%Y%-^Cd').json"
DOCKER_NETWORK_OVERLAY="(docker network ls | grep -i "overlay" | awk '{print $1}')"
DOCKER_NETWORK_OVERLAY_BACKUP="docker network inspect $(docker network ls | grep -i "overlay" | awk '{print $1}') >> /tmp/backup/swarm_network_backup_$(date +'%Y%-^Cd').json"

# NETWORK_OVERLAY Check
echo '========================'
echo 'CHECKING NETWORK OVERLAY'
echo "========================'
$NETWORK_OVERLAY
echo '=================================='
echo '.......'
echo '=================================================='
echo 'PERFORMING NETWORK OVERLAY BACKUP in /tmp/backup/'
echo '=================================================='
# Make Directory for backup in /tmp/ directory
# Look for Backup of The Swarm Directory on System 
if [[ -d /tmp/backup/ ]] ; then
    echo 'SWARM BACKUP DIRECTORY EXISTS!'
    echo 'PERFORMING BACK!'
    $DOCKER_BRIDGE_BACKUP
    $DOCKER_GATEWAY_BRIDGE_BACKUP
    $NETWORK_OVERLAY_BACKUP
fi

if [[ ! -d /tmp/backup/ ]] ; then
    sudo mkdir /tmp/backup
    echo 'WARNING SWARM BACKUP DIRECTORY DOES NOT EXIST!'
    exit
fi
