#!/bin/bash
# ==========================================
# VMess Management Menu
# ==========================================

XRAY_CONFIG="/usr/local/etc/xray/config.json"
DOMAIN=$(cat /etc/xray/domain)
PORT=443 # Default TLS port

function add_vmess() {
    clear
    echo -e "--- Add VMess User ---"
    read -p "Username: " user
    read -p "Duration (days): " days

    uuid=$(uuidgen)
    exp=$(date -d "+${days} days" +"%Y-%m-%d")
    
    # Add user to Xray Config using jq (assuming VMess is the 1st inbound, index 0)
    jq ".inbounds[0].settings.clients += [{\"id\": \"${uuid}\", \"alterId\": 0, \"email\": \"${user}\"}]" $XRAY_CONFIG > $XRAY_CONFIG.tmp
    mv $XRAY_CONFIG.tmp $XRAY_CONFIG

    systemctl restart xray

    # Generate VMess JSON for Base64 link
    vmess_json=$(cat <<EOF
{
  "v": "2",
  "ps": "${user}",
  "add": "${DOMAIN}",
  "port": "${PORT}",
  "id": "${uuid}",
  "aid": "0",
  "net": "ws",
  "path": "/vmess",
  "type": "none",
  "host": "${DOMAIN}",
  "tls": "tls"
}
EOF
)
    vmess_link="vmess://$(echo -n "$vmess_json" | base64 -w 0)"

    clear
    echo -e "========================="
    echo -e " VMess Account Created   "
    echo -e "========================="
    echo -e "Username  : $user"
    echo -e "Domain    : $DOMAIN"
    echo -e "UUID      : $uuid"
    echo -e "Port      : $PORT (TLS)"
    echo -e "Network   : WS"
    echo -e "Path      : /vmess"
    echo -e "Expires   : $exp"
    echo -e "========================="
    echo -e "Link      : $vmess_link"
    echo -e "========================="
    read -n 1 -s -r -p "Press any key to return..."
}

function menu_vmess() {
    clear
    echo -e "========================="
    echo -e "      VMESS MENU         "
    echo -e "========================="
    echo -e " [1] Add VMess User"
    echo -e " [2] Delete VMess User"
    echo -e " [3] Check Online Users"
    echo -e " [0] Back to Main Menu"
    echo -e "========================="
    read -p "Select option: " opt
    case $opt in
        1) add_vmess ;;
        2) echo "Delete logic here" ;; # Add your jq delete logic
        3) echo "Check logic here" ;;
        0) exit 0 ;;
        *) echo "Invalid option"; sleep 1; menu_vmess ;;
    esac
}

menu_vmess