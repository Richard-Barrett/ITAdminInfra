#!/usr/bin/env pwsh

docker swarm leave
Stop-Service docker
Get-ContainerNetwork | Remove-ContainerNetwork
Start-Service docker
echo "YOU MAY NOW ISSUE A JOIN COMMAND FOR A WORKER NODE"
