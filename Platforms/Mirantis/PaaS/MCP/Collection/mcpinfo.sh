#!/bin/bash
# =====================================================
# Author: Richard Barrett
# Date Created: 03/14/2020
# Organziation: Mirantis
# Purpose: Initalize Manual Logrotate on Openstack Logs
# =====================================================

# Official documentation
# ======================================================================================================================
# ...
# ======================================================================================================================
set -e 

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG

# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

