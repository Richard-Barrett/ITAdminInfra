#!/usr/bin/env pwsh

# To see the full list of requirements go to 
# https://docs.mirantis.com/docker-enterprise/v3.1/dockeree-products/ucp/install-ucp.html#system-requirements

# Set Current Directory Tree Dynamically
$CWD = Get-Location | Select-Object -ExpandProperty Path

# Check for Port Issues
cat $CWD\tcp_ports.txt | 
ForEach-Object {Test-NetConnection -ComputerName $ENV:ComputerName -Port $_}
