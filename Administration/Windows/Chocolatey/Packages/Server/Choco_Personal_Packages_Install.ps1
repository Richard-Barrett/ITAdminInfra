#!/bin/powershell

# Installs All Packages 
# Packages that need to be installed for personal work on Local Machine 
cat .\Personal_Packages.txt | ForEach-Object { choco install $_ -y}
