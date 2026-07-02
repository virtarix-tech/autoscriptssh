#!/bin/bash
# Add Trojan Logic
domain=$(cat /etc/xray/domain)
read -p "Username: " user
read -p "Days: " days
exp=$(date -d "$days days" +"%Y-%m-%d-%H-%M-%S")
# Trojan uses a password/key
key=$(openssl rand -hex 8)

# Generate Trojan Link (Example format)
link="trojan://$key@$domain:443?path=%2ftrojanws&security=tls&host=$domain&type=ws&sni=$domain#$user"

echo -e "━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "[<= trojan acount =>]"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "hostname    : $domain"
echo -e "username    : $user"
echo -e "expired     : $exp"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "uuid/key     : $key"
echo -e "path trojan  : /trojan"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "link trojan ws   : $link"