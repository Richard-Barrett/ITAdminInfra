#!/usr/bin/pwsh
#Requires -version 3.0

cd ~
#Remove-Item –path ~\.\Git\ -Recurse -Filter *test* -whatif
Remove-Item –path ~\.\.aws\ -Recurse
Remove-Item –path ~\.\.bash_*\ -Recurse
Remove-Item –path ~\.\.conda*\ -Recurse
Remove-Item –path ~\.\.python_history\ -Recurse
Remove-Item –path ~\.\.conda*\ -Recurse
Remove-Item –path ~\.\.ssh\ -Recurse
Remove-Item –path ~\.\Clouds\ -Recurse
Remove-Item –path ~\.\Git\ -Recurse
Remove-Item –path ~\.\Keys\ -Recurse
Remove-Item –path ~\.\Kubernetes\ -Recurse
Remove-Item –path ~\.\Personal\ -Recurse
Remove-Item –path ~\.\Projects\ -Recurse
Remove-Item –path ~\.\knime-workspace\ -Recurse
Remove-Item –path ~\.\OpenVPN\ -Recurse
Remove-Item –path ~\.\PycharmProjects\ -Recurse
Remove-Item –path ~\.\Postman\ -Recurse
Remove-Item –path ~\.\Scripts\ -Recurse

cd ~\.\Documents\
  Remove-Item * -Recurse
cd ~\.\Downloads\
  Remove-Item * -Recurse
cd ~\.\Images\
  Remove-Item * -Recurse
cd ~\.\Photos\
  Remove-Item * -Recurse
cd ~\.\Pictures\
  Remove-Item * -Recurse
cd '~\VirtualBox VMs\'
  Remove-Item * -Recurse
  

