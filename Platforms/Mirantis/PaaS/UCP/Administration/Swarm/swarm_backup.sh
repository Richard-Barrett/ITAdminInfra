#!/bin/bash
# ===========================================
# Created by: Richard Barrett
# Date Created: 09/11/2020 
# Purpose: Local or Remote Backup for Swarm 
# ===========================================

# Official documentation
# ======================================================================================================================
# https://docs.docker.com/engine/swarm/admin_guide/#back-up-the-swarm
# https://docs.docker.com/engine/reference/commandline/node_ls/
# https://www.tutorialspoint.com/unix/if-else-statement.htm
#https://unix.stackexchange.com/questions/232946/how-to-copy-all-files-from-a-directory-to-a-remote-directory-using-scp
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
$MANAGERS 
echo "=================================== END LISTING MANAGERS ===============================\n"

# Interactive Prompt for Local or Remote Storage
echo "Would you like to perform a Local or Remote Backup (local/remote)?
read ANS
while true; do
    read -p "Perform the backup for selection $ANS backup (yes/no)?" yn
    case $yn in
        [Yy]* ) echo "===================================\n"; \
                echo "        Peforming backup..."; \
                echo "===================================\n"; \
                if [ $ANS == local];
                  then echo "Performing Local Backup in /tmp/; \
                  # Quorum Check 
                  # Make Directory for backup in /tmp/ directory
                  # Checl if Auto-Lock is Enabled
                  # Stop Docker on Local Manager Node for Local Backup
                  # Store all Files in /tmp/backup/ as /tmp/backup/swarm_backup_$(date +'%Y%-m%d')
                  # Gzip backup /tmp/backup/swarm_backup_$(date +'%Y%-m%d')
                elif [ $ANS == remote]; \
                  then echo "Performing Remote Backup in /tmp/; \
                  echo "What is the remote IP Address (XXX.XXX.XX.XX)?"; \
                  read IP; \
                  echo "What is username for the remote host (jdoe)?"; \
                  read USER
                  echo "What is the directory you wish to store the backup (/home/)?"; \
                  read DIR
                  # Quorum Check 
                  # Make Directory for backup in /tmp/ directory
                  # Checl if Auto-Lock is Enabled
                  # Stop Docker on Local Manager Node for Local Backup
                  # Store all Files in /tmp/backup/ as /tmp/backup/swarm_backup_$(date +'%Y%-m%d')
                  # Gzip backup /tmp/backup/swarm_backup_$(date +'%Y%-m%d')
                  # SCP -r $IP:/home/
                  scp -r /tmp/backup/swarm_backup_$(date +'%Y%-m%d') $USER@$IP:$DIR; \
                fi; \
                echo "===================================\n"; \
                break;; \
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
