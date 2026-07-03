#!/bin/bash
# File: /opt/virtarixtech/bin/delete-user.sh
# Purpose: Remove a user from the Xray config safely.

user=$1

if [[ -z "$user" ]]; then
    echo "Usage: virtarixtech user delete <username>"
    exit 1
fi

# The logic to remove the user
cat /etc/xray/config.json | jq ".inbounds[0].settings.clients |= map(select(.email != \"$user\"))" > /etc/xray/config.json.tmp && mv /etc/xray/config.json.tmp /etc/xray/config.json

# Restart Xray to apply changes
systemctl restart xray

echo "User $user has been deleted successfully."