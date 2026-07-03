#!/bin/bash
user=$1
expiry=$2
if [ -z "$user" ] || [ -z "$expiry" ]; then echo "Usage: virtarixtech user renew <username> <new_expiry>"; exit 1; fi
# Logic to update expiry date would go here (e.g., using jq to modify an 'expiry' field)
echo "User $user renewed until $expiry."