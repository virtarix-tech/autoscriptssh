#!/bin/bash
# Add VMess Logic
domain=$(cat /etc/xray/domain)
read -p "Username: " user
read -p "Days: " days
exp=$(date -d "$days days" +"%Y-%m-%d-%H-%M-%S")
uuid=$(cat /proc/sys/kernel/random/uuid)

# Formatting the output to match your requirement
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "[<= vmess account =>]"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "hostname    : $domain"
echo -e "username    : $user"
echo -e "expired     : $exp"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "uuid/key     : $uuid"
echo -e "path ws      : /vmess"
# ... add remaining logic to write to your JSON config ...