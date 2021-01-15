#!/bin/bash

# Documentation:
# ======================================================
# https://falco.org/docs/getting-started/installation/
# ======================================================

curl -s https://falco.org/repo/falcosecurity-3672BA8F.asc | apt-key add -
echo "deb https://dl.bintray.com/falcosecurity/deb stable main" | tee -a /etc/apt/sources.list.d/falcosecurity.list
apt-get update -y

apt-get install -y falco
service falco start
systemctl enable falco
