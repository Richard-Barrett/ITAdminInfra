#!/bin/bash

# Run from cfg Salt Master
master = $(grep log /etc/hosts | awk 'FNR == 1 {print $3}')
curl -sS 'master:9200/_cat/indices?v' | egrep "health|[0-9]gb" | sort -k3
