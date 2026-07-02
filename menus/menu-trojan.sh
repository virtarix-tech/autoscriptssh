#!/bin/bash
# ==========================================
# Trojan Management Menu
# ==========================================

XRAY_CONFIG="/usr/local/etc/xray/config.json"
DOMAIN=$(cat /etc/xray/domain)
PORT=443

function add_trojan() {
    clear
    echo -e "--- Add Trojan User ---"
    read -p "Username: " user
    read -p "Custom Password (leave blank for random): " pass
    read -p "Duration (days): " days

    if [[ -z "$pass" ]]; then
        pass=$(uuidgen | head -c 8) # Generate short random password if left blank
    fi
    
    exp=$(date -d "+${days} days" +"%Y-%m-%d")
    
    # Add user to Xray Config (assuming Trojan is the 3rd inbound, index 2)
    jq ".inbounds[2].settings.clients += [{\"password\": \"${pass}\", \"email\": \"${user}\"}]" $XRAY_CONFIG > $XRAY_CONFIG.tmp
    mv $XRAY_CONFIG.tmp $XRAY_CONFIG

    systemctl restart xray

    # Generate Trojan Link
    trojan_link="trojan://${pass}@${DOMAIN}:${PORT}?security=tls&sni=${DOMAIN}&type=ws&path=/trojan#${user}"

    clear
    echo -e "========================="
    echo -e " Trojan Account Created  "
    echo -e "========================="
    echo -e "Username  : $user"
    echo -e "Domain    : $DOMAIN"
    echo -e "Password  : $pass"
    echo -e "Port      : $PORT (TLS)"
    echo -e "Network   : WS"
    echo -e "Path      : /trojan"
    echo -e "Expires   : $exp"
    echo -e "========================="
    echo -e "Link      : $trojan_link"
    echo -e "========================="
    read -n 1 -s -r -p "Press any key to return..."
}

function menu_trojan() {
    clear
    echo -e "========================="
    echo -e "     TROJAN MENU         "
    echo -e "========================="
    echo -e " [1] Add Trojan User"
    echo -e " [2] Delete Trojan User"
    echo -e " [3] Check Online Users"
    echo -e " [0] Back to Main Menu"
    echo -e "========================="
    read -p "Select option: " opt
    case $opt in
        1) add_trojan ;;
        2) echo "Delete logic here" ;;
        3) echo "Check logic here" ;;
        0) exit 0 ;;
        *) echo "Invalid option"; sleep 1; menu_trojan ;;
    esac
}

menu_trojan