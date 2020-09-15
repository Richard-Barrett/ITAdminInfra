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
# https://medium.com/@raghavendar_d/backup-restore-docker-swarm-f6a77bd95681
# ...
# ======================================================================================================================
set -e 

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG

# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

# System Variables 
MANAGERS=$(docker node ls -f "role=manager")

# Check for auto-lock enabled 
# If the swarm has auto-lock enabled, you need the unlock key to restore the swarm from backup. 
# Retrieve the unlock key if necessary and store it in a safe location. 
# If you are unsure, read Lock your swarm to protect its encryption key.

# Check for Docker Manager Nodes within the Cluster 
echo "The Following is a list of Managers within your Cluster:"
echo "=================================== LISTING MANAGERS ==================================="
docker node ls -f "role=manager"
echo "=================================== END LISTING MANAGERS ==============================="

# Check for Docker Installation
# If No Installation Install Docker Dependencies
# Enable Docker for System Enablement on Restart
REQUIRED_PKGS="docker-ee docker-ee-cli containerd.io"
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKGS|grep "install ok installed")
echo Checking for $REQUIRED_PKGS: $PKG_OK
if [ "" = "$PKG_OK" ]; then
  echo "No $REQUIRED_PKGS. Setting up $REQUIRED_PKGS."
  sudo apt-get --yes install $REQUIRED_PKGS 
fi

# Stop Docker 
sudo systemctl stop docker.service 

# Look for Backup of The Swarm Directory on System 
if [[ -d /tmp/backup/ ]] ; then
    echo 'SWARM BACKUP EXISTS!'
fi

if [[ ! -d /tmp/backup/ ]] ; then
    echo 'WARNING SWARM BACKUP DOES NOT EXIST!'
    exit
fi

# Copy the Backup of The Swarm Directory to /var/lib/docker/
sudo cp -R /tmp/backup/swarm_backup_*/ /var/lib/docker/swarm/

# Start the Docker Daemon
sudo systemctl start docker.service 
systemctl is-active --quiet docker.service && echo 'DOCKER SERVICE IS RUNNING'

# Initialise the Docker Swarm Forcefully
docker swarm init --force-new-cluster
