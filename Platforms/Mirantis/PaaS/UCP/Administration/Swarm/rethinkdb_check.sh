#!/bin/bash
set -e

echo "================================ CHECK FOR RETHINKDB+REPAIR "================================\n"
while true; do
    read -p "Do you wish to check RethinkDB Cluster (yes/no)?" yn
    case $yn in
        [Yy]* ) echo "==================================================\n"; \
                echo "Checking ReThinkDB for Configured Manager Nodes..."; \
                echo "==================================================\n"; \
                NODE_ADDRESS=$(docker info --format '{{.Swarm.NodeAddr}}'); \
                # NUM_MANAGERS will be the current number of manager nodes in the cluster
                NUM_MANAGERS=$(docker node ls --filter role=manager -q | wc -l); \
                # VERSION will be your most recent version of the docker/ucp-auth image
                VERSION=$(docker image ls --format '{{.Tag}}' docker/ucp-auth | head -n 1); \
                # This reconfigure-db command will repair the RethinkDB cluster to have a
                # number of replicas equal to the number of manager nodes in the cluster.
                docker container run --rm -v ucp-auth-store-certs:/tls docker/ucp-auth:${VERSION} \
                --db-addr=${NODE_ADDRESS}:12383 --debug reconfigure-db --num-replicas ${NUM_MANAGERS}; \
                echo "==================================================\n"; \                
                break;; \
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

while true; do
    read -p "Do you wish to perform emergency repair on RethinkDB Cluster (yes/no)?" yn
    case $yn in
        [Yy]* ) echo "====================================================\n"; \
                echo "Repairing ReThinkDB Cluster with Emergency Repair..."; \
                echo "====================================================\n"; \
                NODE_ADDRESS=$(docker info --format '{{.Swarm.NodeAddr}}'); \
                # NUM_MANAGERS will be the current number of manager nodes in the cluster
                NUM_MANAGERS=$(docker node ls --filter role=manager -q | wc -l); \
                # VERSION will be your most recent version of the docker/ucp-auth image
                VERSION=$(docker image ls --format '{{.Tag}}' docker/ucp-auth | head -n 1); \
                # This reconfigure-db command will repair the RethinkDB cluster to have a
                # number of replicas equal to the number of manager nodes in the cluster.
                docker container run --rm -v ucp-auth-store-certs:/tls docker/ucp-auth:${VERSION} \
                --db-addr=${NODE_ADDRESS}:12383 --debug reconfigure-db --emrgency-repair; \
                echo "====================================================\n"; \                
                break;; \
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
