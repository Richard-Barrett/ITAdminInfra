#!/bin/bash

USERNAME="admin"
PASSWORD="dockeradmin"
AUTH_URL="https://rbarrett-rbarrett-test-rbarrett-ucp-1-ucpleader.train.mirantis.com/auth/login"

curl -sk -d "{\"username\":\"$USERNAME\",\"password\":\"$PASSWORD\"}" $(echo $AUTH_URL) | jq '.' > auth-token
echo "Bearer auth-token can be found at $(pwd)/auth-token"
