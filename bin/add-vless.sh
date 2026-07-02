#!/bin/bash
# Add VLESS Logic
domain=$(cat /etc/xray/domain)
read -p "Username: " user
read -p "Days: " days
exp=$(date -d "$days days" +"%Y-%m-%d-%H-%M-%S")
uuid=$(cat /proc/sys/kernel/random/uuid)

# Generate VLESS Link (Example format)
link="vless://$uuid@$domain:443?path=/vless&security=tls&encryption=none&type=ws&host=$domain&sni=$domain#$user"

echo -e "━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "[<= vless account =>]"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "hostname    : $domain"
echo -e "username    : $user"
echo -e "expired     : $exp"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "uuid/key     : $uuid"
echo -e "path ws      : /vless"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "link vless ws tls   : $link"
# Add to /opt/virtarixtech/bin/add-vmess (and similarly for vless/trojan)
# We use jq to safely insert the user into the JSON array
jq --arg uuid "$uuid" --arg user "$user" '.inbounds[0].settings.clients += [{"id": $uuid, "alterId": 0, "email": $user}]' /etc/xray/config.json > /etc/xray/config.json.tmp && mv /etc/xray/config.json.tmp /etc/xray/config.json

# Restart Xray to apply changes
systemctl restart xray
