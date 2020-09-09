
#!/bin/bash 
set -e 

echo "============================== CHECK MANAGERS =============================="
while true; do
    read -p "Do you wish to check manager nodes (yes/no)?" yn
    case $yn in
        [Yy]* ) echo "==========================\n"; \
                echo "Checkinging Managers..."; \
                echo "==========================\n"; \
                docker node ls -f "role=manager"; \                
                break;; \
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
