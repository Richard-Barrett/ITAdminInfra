#!/bin/powershell

# Installs All Packages 
# Packages that need to be installed for developer work on Local Machine 
cat .\Developer_Packages.txt | ForEach-Object { choco install $_ -y}
