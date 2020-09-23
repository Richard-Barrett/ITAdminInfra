#!/usr/bin/env pwsh

# Set Current Directory Tree Dynamically
$CWD = Get-Location | Select-Object -ExpandProperty Path

# Check for Port Issues
cat $CWD\tcp_ports.txt | 
ForEach-Object {Test-NetConnection -ComputerName $ENV:ComputerName -Port $_)
