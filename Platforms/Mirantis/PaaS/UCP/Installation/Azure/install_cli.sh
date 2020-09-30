#!/bin/bash
# ====================================================
# Created by: Richard Barrett
# Date Created: 09/30/2020 
# Purpose: Local or Remote Installation for Azure CLI
# Company: Mirantis
# =====================================================

# Official documentation
# ======================================================================================================================
# https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-macos

# ...
# ======================================================================================================================
set -e 


# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG

# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

# Prompt for Brew Installation 
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"


# Update Brew and Install Azure CLI
brew update && brew install azure-cli
