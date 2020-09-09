#!/usr/bin/env pwsh
# Check for Port Issues
cat ~\ITAdminInfra\Platforms\Mirantis\PaaS\UCP\Adminsitration\Swarm\Windows\tcp_ports.txt | 
ForEach-Object {Test-NetConnection -ComputerName $ENV:ComputerName -Port $_)
