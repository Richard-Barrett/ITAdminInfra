#!/usr/bin/env pwsh

# To see the full list of requirements go to 
# https://docs.mirantis.com/docker-enterprise/v3.1/dockeree-products/ucp/install-ucp.html#system-requirements
# https://www.thewindowsclub.com/what-is-a-tcp-and-udp-port-how-to-block-or-open-them-in-windows-10

# Set Current Directory Tree Dynamically
$CWD = Get-Location | Select-Object -ExpandProperty Path

# Check for Port Issues
cat $CWD\tcp_ports.txt | 
ForEach-Object { if (-not($_ -like '#*')) {Test-NetConnection -ComputerName $ENV:ComputerName -Port $_ }}
