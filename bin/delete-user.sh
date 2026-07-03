#!/bin/bash
user=$1
if [ -z "$user" ]; then echo "Usage: virtarixtech user delete <username>"; exit 1; fi
cat /etc/xray/config.json | jq ".inbounds[0].settings.clients |= map(select(.email != \"$user\"))" > /etc/xray/config.json.tmp && mv /etc/xray/config.json.tmp /etc/xray/config.json
systemctl restart xray
echo "User $user deleted successfully."