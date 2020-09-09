#!/bin/bash 
set -e 

echo "============================== CHECK CLUSTER QUORUM =============================="
while true; do
    read -p "Do you wish to check Cluster Swarm Quorum (yes/no)?" yn
    case $yn in
        [Yy]* ) echo "==========================\n"; \
                echo "Checking Cluster Quorum..."; \
                echo "==========================\n"; \
                docker node ls -a -f "role=manager"; \
                echo "==============================\n"; \
                echo "Checking for Shutdown Tasks..."; \
                echo "==============================\n"; \
                docker run -v /var/run/docker/swarm/control.sock:/var/run/swarmd.sock \
                --entrypoint "./swarmctl" dperny/tasknuke task ls -a | grep SHUTDOWN | wc -l; \
                echo "==============================\n"; \
                break;; \
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
echo "============================= CHECK CLUSTER COMPLETE ============================="

while true; do
    read -p "Do you wish to check Clear Dangling Shutdown Tasks (yes/no)?" yn
    case $yn in
        [Yy]* ) echo "===================================\n"; \
                echo "Clearing Dnagling Shutdown Tasks..."; \
                echo "===================================\n"; \
                NODE_ADDRESS=$(docker info --format '{{.Swarm.NodeAddr}}'); \
                # NUM_MANAGERS will be the current number of manager nodes in the cluster
                NUM_MANAGERS=$(docker node ls --filter role=manager -q | wc -l)
                # VERSION will be your most recent version of the docker/ucp-auth image
                VERSION=$(docker image ls --format '{{.Tag}}' docker/ucp-auth | head -n 1)
                # This reconfigure-db command will repair the RethinkDB cluster to have a
                # number of replicas equal to the number of manager nodes in the cluster.
                docker run -v /var/run/docker/swarm/control.sock:/var/run/swarmd.sock \
                --entrypoint "./swarmctl" dperny/tasknuke task ls -a | grep SHUTDOWN \
                | awk '{print $1}' | xargs -L 1 sh -c \
                'docker run -v /var/run/docker/swarm/control.sock:/var/run/swarmd.sock dperny/tasknuke "$0"'
                echo "===================================\n"; \
                break;; \
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
