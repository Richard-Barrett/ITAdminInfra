#!/bin/bash
# Official documentation
# https://docs.mirantis.com/docker-enterprise/v3.1/dockeree-products/ucp/ucp-cli-reference/ucp-cli-port-check-server.html
set -e 

while true; do
    read -p "Do you wish to create a directory lab $LAB in this directory (yes/no)?" yn
    case $yn in
        [Yy]* ) docker run --rm -it \
                -v /var/run/docker.sock:/var/run/docker.sock \
                mirantis/ucp \
                port-check-server; \
                break;; \
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
