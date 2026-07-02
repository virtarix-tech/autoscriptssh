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