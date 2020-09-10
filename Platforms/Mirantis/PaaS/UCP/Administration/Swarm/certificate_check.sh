#!/bin/bash
# Official documentation here
# https://docs.mirantis.com/docker-enterprise/v3.1/dockeree-products/ucp/ucp-cli-reference/ucp-cli-dump-certs.html
set -e 

while true; do
    read -p "Do you wish to view cluster *.ca information (yes/no)?" yn
    case $yn in
        [Yy]* ) docker container run --rm \
                --name ucp \
                -v /var/run/docker.sock:/var/run/docker.sock \
                mirantis/ucp \
                dump-certs --ca; \ 
                break;; \
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
