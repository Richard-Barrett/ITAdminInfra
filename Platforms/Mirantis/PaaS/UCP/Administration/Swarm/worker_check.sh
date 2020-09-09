#!/bin/bash
set -e 

echo "============================== CHECK WORKERS =============================="
while true; do
    read -p "Do you wish to check worker nodes (yes/no)?" yn
    case $yn in
        [Yy]* ) echo "==========================\n"; \
                echo "Checkinging Workers..."; \
                echo "==========================\n"; \
                docker node ls -f "role=worker"; \                
                break;; \
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
