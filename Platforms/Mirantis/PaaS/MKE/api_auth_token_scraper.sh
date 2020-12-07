#!/bin/bash

USERNAME="admin"
PASSWORD="dockeradmin"
REQUEST_URL="https://rbarrett-rbarrett-test-rbarrett-ucp-1-ucpleader.train.mirantis.com"
AUTH_URL="${REQUEST_URL}/auth/login"

curl -sk -d "{\"username\":\"$USERNAME\",\"password\":\"$PASSWORD\"}" $(echo $AUTH_URL) | jq '.' > auth-token
echo "Bearer auth-token can be found at $(pwd)/auth-token"
