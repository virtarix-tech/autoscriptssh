#!/bin/bash
# ==========================================
# VLESS Management Menu
# ==========================================

XRAY_CONFIG="/usr/local/etc/xray/config.json"
DOMAIN=$(cat /etc/xray/domain)
PORT=443

function add_vless() {
    clear
    echo -e "--- Add VLESS User ---"
    read -p "Username: " user
    read -p "Duration (days): " days

    uuid=$(uuidgen)
    exp=$(date -d "+${days} days" +"%Y-%m-%d")
    
    # Add user to Xray Config (assuming VLESS is the 2nd inbound, index 1)
    jq ".inbounds[1].settings.clients += [{\"id\": \"${uuid}\", \"email\": \"${user}\"}]" $XRAY_CONFIG > $XRAY_CONFIG.tmp
    mv $XRAY_CONFIG.tmp $XRAY_CONFIG

    systemctl restart xray

    # Generate VLESS Link
    vless_link="vless://${uuid}@${DOMAIN}:${PORT}?encryption=none&security=tls&sni=${DOMAIN}&type=ws&path=/vless#${user}"

    clear
    echo -e "========================="
    echo -e " VLESS Account Created   "
    echo -e "========================="
    echo -e "Username  : $user"
    echo -e "Domain    : $DOMAIN"
    echo -e "UUID      : $uuid"
    echo -e "Port      : $PORT (TLS)"
    echo -e "Network   : WS"
    echo -e "Path      : /vless"
    echo -e "Expires   : $exp"
    echo -e "========================="
    echo -e "Link      : $vless_link"
    echo -e "========================="
    read -n 1 -s -r -p "Press any key to return..."
}

function menu_vless() {
    clear
    echo -e "========================="
    echo -e "      VLESS MENU         "
    echo -e "========================="
    echo -e " [1] Add VLESS User"
    echo -e " [2] Delete VLESS User"
    echo -e " [3] Check Online Users"
    echo -e " [0] Back to Main Menu"
    echo -e "========================="
    read -p "Select option: " opt
    case $opt in
        1) add_vless ;;
        2) echo "Delete logic here" ;;
        3) echo "Check logic here" ;;
        0) exit 0 ;;
        *) echo "Invalid option"; sleep 1; menu_vless ;;
    esac
}

menu_vless