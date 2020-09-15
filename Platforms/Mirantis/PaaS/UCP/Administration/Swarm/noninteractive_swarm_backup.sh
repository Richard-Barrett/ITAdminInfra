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
# ...
# ======================================================================================================================
set -e 

# System Variables 
MANAGERS=$(docker node ls -f "role=manager")

# Check for auto-lock enabled 
# If the swarm has auto-lock enabled, you need the unlock key to restore the swarm from backup. 
# Retrieve the unlock key if necessary and store it in a safe location. 
# If you are unsure, read Lock your swarm to protect its encryption key.

# Check for Docker Manager Nodes within the Cluster 
echo "The Following is a list of Managers within your Cluster:"
echo "=================================== LISTING MANAGERS ===================================\n"
docker node ls -f "role=manager"
echo "=================================== END LISTING MANAGERS ===============================\n"
# Quorum Check 
# docker node ls -f "role=manager"
# Make Directory for backup in /tmp/ directory
sudo mkdir /tmp/backup
# Check if Auto-Lock is Enabled (OPTIONAL)
# Stop Docker on Local Manager Node for Local Backup
sudo systemctl stop docker.service
# Store all Files in /tmp/backup/ as /tmp/backup/swarm_backup_$(date +'%Y%-m%d')
sudo cp -R /var/lib/docker/swarm/ /tmp/backup/swarm_backup_$(date +'%Y%-m%d')
# Zip backup /tmp/backup/swarm_backup_$(date +'%Y%-m%d')
which zip
zip -r /tmp/backup/swarm_backup_$(date +'%Y%-m%d').zip /tmp/backup/swarm_backup_$(date +'%Y%-m%d')
# Remove Unzipped Contents
sudo rm -rf /tmp/backup/swarm_backup_$(date +'%Y%-m%d')
# Start Docker Services Locally 
sudo systemctl start docker.service
