#!/usr/bin/pwsh
#Requires -version 3.0

cd ~
#Remove-Item –path ~\.\Git\ -Recurse -Filter *test* -whatif
Remove-Item –path ~\.\Git\ -Recurse
