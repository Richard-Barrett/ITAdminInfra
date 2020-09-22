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
DOCKER_VERSION="docker version | grep -w "Version" | head -n +1 | awk '{print $2}'"
DOCKER_NETWORK_COMMAND="docker network create"
DOCKER_INGRESS_NETWORK_OVERLAY="docker network ls | grep -i "overlay" | awk '{print $1}'"
DOCKER_INGRESS_NETWORK_OVERLAY_BACKUP="docker network inspect $(docker network ls | grep -i "overlay" | awk '{print $1}') >> /tmp/backup/swarm_network_backup_$(date +'%Y%-^Cd').json"
SWARMCTL_NETWORK_COMMAND="swarmctl network create"

# Network Recreate Variables 
NAME="cat /tmp/backup/ingress.json | jq ".[].Name" --raw-output"
INTERNAL="cat /tmp/backup/ingress.json | jq ".[].Internal" --raw-output"
ATTACHABLE="cat /tmp/backup/ingress.json | jq ".[].Attachable" --raw-output"
IPV6="cat /tmp/backup/ingress.json | jq ".[].EnableIPv6" --raw-output"
INGRESS="--ingress=true"
IPAM="cat /tmp/backup/ingress.json | jq ".[].IPAM.Config[].Subnet" --raw-output"
GATEWAY="cat /tmp/backup/ingress.json | jq ".[].IPAM.Config[].Gateway" --raw-output"
SUBNET="cat /tmp/backup/ingress.json | jq ".[].IPAM.Config[].Subnet" --raw-output"

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
    $DOCKER_INGRESS_NETWORK_OVERLAY_BACKUP
fi
if [[ ! -d /tmp/backup/ ]] ; then
    sudo mkdir /tmp/backup
    echo 'WARNING SWARM BACKUP DIRECTORY DOES NOT EXIST!'
    exit
fi

# Rebuild Docker Ingress Network
if [[ $DOCKER_VERSION => 17.06 ]] ; then 
    <rebuild_using_docker_network_create_command>
elif [[ $DOCKER_VERSION =< 17.06 ]] ; then 
    <rebuild_using_swarmctl_network_create_command>
fi 
