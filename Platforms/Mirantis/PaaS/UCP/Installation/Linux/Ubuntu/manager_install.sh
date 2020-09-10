#!/bin/bash

# Documentation:
# ========================================================================================
# https://www.cyberciti.biz/faq/how-to-open-firewall-port-on-ubuntu-linux-12-04-14-04-lts/
# ========================================================================================
set -e

# System Variables 
GWD=$(pwd)
cat $GWD

# Check Firewall Status 
sudo ufw status 

# Check IPTables 
sudo iptables -S
sudo iptables -L

# Enable Firewall
sudo enable ufw 

# Check Firewall Statussu
do ufw status verbose

# Allow Ports & Services in UFW
sudo ufw allow ssh
sudo ufw allow http
for i in $(cat $GWD/tcp_ports.txt); \ 
    do echo "Allowing $i through firewall\n" && sudo ufw allow $i\tcp && echo "$i has been allowed through firewall\n";
done 

# Remove Old Versions od Docker
sudo apt-get remove docker docker-engine docker-ce docker-ce-cli docker.io -y

# Update the apt package index.
sudo apt-get update -y

# Install docker 
sudo apt-get install docker docker-engine docker-ce docker-ce-cli docker.io -y

# Start and Automate Docker 
sudo systemctl start docker
sudo systemctl enable docker

# Crreate Docker Group and Add Current User to Docker Group
sudo groupadd docker
sudo gpasswd -a $USER docker

# Install packages to allow apt to use a repository over HTTPS.
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common -y

# Check for Requirements
for i in $(cat $GWD/requirements.txt); \
    do which $i; \
done 

# Install DNSUTILS
sudo apt-get install dnsutils -y

# Install UCP Bootstrap Components 
UCP_IP=$(sudo dig TXT +short o-o.myaddr.l.google.com @ns1.google.com | awk -F'"' '{ print $2}')
UCP_FQDN=$(sudo hostname -f)
docker container run --rm -it --name ucp \
-v /var/run/docker.sock:/var/run/docker.sock \
docker/ucp:3.2.4 install \
--admin-username admin \
--admin-password adminadmin \
--san ${UCP_IP} \
--san ${UCP_FQDN}

# Interactively Create Manager and Worker Tokens
docker swarm join-token manager
docker swarm join-token worker
