#!/bin/bash
# Official Documentation
# https://docs.mirantis.com/docker-enterprise/v3.1/dockeree-products/ucp/ucp-cli-reference/ucp-cli-images.html
set -e

echo "Process for Image List to list cluster images\n"
while true; do
    read -p "Do you wish to list cluster images used for UCP (yes/no)?" yn
    case $yn in
        [Yy]* ) echo "================== LIST CLUSTER IMAGES FOR UCP ==================\n"; \
                docker container run --rm -it \
                --name ucp \
                -v /var/run/docker.sock:/var/run/docker.sock \
                mirantis/ucp \
                images --list; \
                echo "================== LIST PROCESSED FOR CLUSTER  ==================\n"; \
                break;; \
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done


echo "Process for Image Pull to get missing images\n"
while true; do
    read -p "Do you wish to pull cluster images used for UCP (yes/no)?" yn
    case $yn in
        [Yy]* ) echo "================== PULL CLUSTER IMAGES FOR UCP ==================\n"; \
                docker container run --rm -it \
                --name ucp \
                -v /var/run/docker.sock:/var/run/docker.sock \
                mirantis/ucp \
                images --pull; \
                echo "================== PULL PROCESSED FOR CLUSTER  ==================\n"; \
                break;; \
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
