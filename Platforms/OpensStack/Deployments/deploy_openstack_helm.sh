#!/bin/bash

# Documentation 
# http://pwittrock.github.io/docs/tasks/tools/install-kubectl/#install-kubectl-binary-via-curl

# Debug Settings
set -xe

# System Variables
OS-RELEASE="$(cat /etc/os-release)"

# Check for Version of OS Release

# Check for Make, Helm Stable, and Git installations
sudo apt-get install helm -y
sudo apt-get install git -y

# Install Kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

# Add Helm Stable and Force Helm Update
helm repo add "stable" "https://charts.helm.sh/stable"

# Run through installation and deployment
# Clone Repositories 
git clone https://opendev.org/openstack/openstack-helm-infra.git 
git clone https://opendev.org/openstack/openstack-helm.git

cd openstack-helm/
./tools/deployment/developer/common/010-deploy-k8s.sh
