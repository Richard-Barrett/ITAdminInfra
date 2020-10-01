#!/bin/bash
# ===========================================
# Created by: Richard Barrett
# Date Created: 09/11/2020 
# Purpose: Local or Remote Backup for Swarm 
# Company: Mirantis
# ===========================================

# Official documentation
# ======================================================================================================================
# https://docs.mirantis.com/docker-enterprise/v3.1/dockeree-products/ucp/ucp-monitor-and-troubleshoot.html
# ...
# ======================================================================================================================
set -e

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG

# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

echo "================================ CHECK FOR RETHINKDB+REPAIR "================================"
while true; do
    read -p "Do you wish to check RethinkDB Cluster (yes/no)?" yn
    case $yn in
        [Yy]* ) echo "=================================================="; \
                echo "Checking ReThinkDB for Configured Manager Nodes..."; \
                echo "=================================================="; \
                NODE_ADDRESS=$(docker info --format '{{.Swarm.NodeAddr}}'); \
                # NUM_MANAGERS will be the current number of manager nodes in the cluster
                NUM_MANAGERS=$(docker node ls --filter role=manager -q | wc -l); \
                # VERSION will be your most recent version of the docker/ucp-auth image
                VERSION=$(docker image ls --format '{{.Tag}}' docker/ucp-auth | head -n 1); \
                # This reconfigure-db command will repair the RethinkDB cluster to have a
                # number of replicas equal to the number of manager nodes in the cluster.
                docker container run --rm -v ucp-auth-store-certs:/tls docker/ucp-auth:${VERSION} \
                --db-addr=${NODE_ADDRESS}:12383 --debug reconfigure-db --num-replicas ${NUM_MANAGERS}; \
                echo "=================================================="; \                
                break;; \
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

while true; do
    read -p "Do you wish to perform emergency repair on RethinkDB Cluster (yes/no)?" yn
    case $yn in
        [Yy]* ) echo "===================================================="; \
                echo "Repairing ReThinkDB Cluster with Emergency Repair..."; \
                echo "===================================================="; \
                NODE_ADDRESS=$(docker info --format '{{.Swarm.NodeAddr}}'); \
                # NUM_MANAGERS will be the current number of manager nodes in the cluster
                NUM_MANAGERS=$(docker node ls --filter role=manager -q | wc -l); \
                # VERSION will be your most recent version of the docker/ucp-auth image
                VERSION=$(docker image ls --format '{{.Tag}}' docker/ucp-auth | head -n 1); \
                # This reconfigure-db command will repair the RethinkDB cluster to have a
                # number of replicas equal to the number of manager nodes in the cluster.
                docker container run --rm -v ucp-auth-store-certs:/tls docker/ucp-auth:${VERSION} \
                --db-addr=${NODE_ADDRESS}:12383 --debug reconfigure-db --emrgency-repair; \
                echo "===================================================="; \                
                break;; \
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
