#!/bin/bash

# Get the public IP address of the server
ip_address=$(hostname -I | awk '{print $1}')

# Replace with your Mastodon instance and access token
instance="mastodon.world"
access_token="access_token_here"

# Construct the API request
api_url="https://$instance/api/v1/statuses"
status="zap is up at $ip_address"

# Post the status to Mastodon
curl -X POST -H "Authorization: Bearer $access_token" \
     -H "Content-Type: application/json" \
     -d "{\"status\":\"$status\"}" \
     $api_url
