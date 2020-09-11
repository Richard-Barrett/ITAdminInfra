# Quorum Check 
$MANAGERS ; \
# Make Directory for backup in /tmp/ directory
sudo mkdir /tmp/backup; \
# Check if Auto-Lock is Enabled (OPTIONAL)
# Stop Docker on Local Manager Node for Local Backup
sudo systemctl stop docker.service; \
# Store all Files in /tmp/backup/ as /tmp/backup/swarm_backup_$(date +'%Y%-m%d')
sudo cp -R /var/lib/docker/swarm/ /tmp/backup/swarm_backup_$(date +'%Y%-m%d'); \
# Zip backup /tmp/backup/swarm_backup_$(date +'%Y%-m%d')
which zip; \
zip -r /tmp/backup/swarm_backup_$(date +'%Y%-m%d').zip /tmp/backup/swarm_backup_$(date +'%Y%-m%d'); \
# Remove Unzipped Contents
sudp rm -rf /tmp/backup/swarm_backup_$(date +'%Y%-m%d'); \
# Start Docker Services Locally 
sudo systemctl start docker.service; \
