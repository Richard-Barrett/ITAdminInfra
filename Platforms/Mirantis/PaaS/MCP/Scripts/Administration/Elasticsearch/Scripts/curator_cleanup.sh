#!/bin/bash

# Ping Test Log Nodes
sudo salt "*log*" test.ping

# Check for Curator curator.yml and curator_action.yml
sudo salt "*log*" cmd.run "ls /etc/elasticsearch/"

# Run Curator curator.yml and curator_action.yml
sudo salt "*log*" cmd.run "curator --config /etc/elasticsearch/curator.yml /etc/elasticsearch/curator_actions.yml"
