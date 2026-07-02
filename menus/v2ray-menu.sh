#!/bin/bash
# ==========================================
# XRAY / V2RAY MENU SERVICE
# ==========================================

# ------------------------------------------
# [ EDIT HERE ]: Define your core variables
# ------------------------------------------
DOMAIN=$(cat /etc/xray/domain)
XRAY_CONFIG="/etc/xray/config.json"
USER_DB="/etc/xray/users.db" # Simple flat file for tracking users/expirations

# Ensure dependencies are met
if ! command -v jq &> /dev/null; then
    apt-get install jq uuid-runtime -y >/dev/null 2>&1
fi

clear

# ==========================================
# Helper Functions
# ==========================================

# Function to get expiration based on unit
calculate_expiration() {
    local duration=$1
    local unit=$2
    case $unit in
        1|m|minutes) exp=$(date -d "+$duration minutes" +%Y-%m-%d-%H-%M-%S) ;;
        2|h|hours)   exp=$(date -d "+$duration hours" +%Y-%m-%d-%H-%M-%S) ;;
        3|d|days)    exp=$(date -d "+$duration days" +%Y-%m-%d-%H-%M-%S) ;;
        *)           exp=$(date -d "+$duration days" +%Y-%m-%d-%H-%M-%S) ;; # Default to days
    esac
    echo "$exp"
}

# Add user to Xray Config (Placeholder - adjust inbound index array based on your config.json structure)
# In standard scripts, inbounds[0] = vmess ws, inbounds[1] = vless ws, etc.
inject_xray_config() {
    local user=$1
    local uuid=$2
    local protocol=$3
    # [ EDIT HERE ]: Map to your actual Xray config structure
    # Example for adding to standard Xray configuration:
    # jq '.inbounds[] | select(.protocol=="'$protocol'") | .settings.clients += [{"id": "'$uuid'", "email": "'$user'"}]' $XRAY_CONFIG > /tmp/xray.tmp && mv /tmp/xray.tmp $XRAY_CONFIG
    # systemctl restart xray
    echo "$user | $uuid | $protocol | $exp" >> $USER_DB
}

# ==========================================
# Creation Logic
# ==========================================

create_vmess() {
    local user=$1
    local duration=$2
    local unit=$3
    local exp=$(calculate_expiration "$duration" "$unit")
    local uuid=$(uuidgen)
    
    inject_xray_config "$user" "$uuid" "vmess"
    
    # Generate Base64 Strings exactly as requested
    local json_tls='{ "v": "2", "ps": "'$user'", "add": "'$DOMAIN'", "port": "443", "id": "'$uuid'", "aid": "0", "net": "ws", "path": "/vmess", "type": "none", "host": "'$DOMAIN'", "tls": "tls" }'
    local json_nontls='{ "v": "2", "ps": "'$user'", "add": "'$DOMAIN'", "port": "80", "id": "'$uuid'", "aid": "0", "net": "ws", "path": "/vmess", "type": "none", "host": "'$DOMAIN'", "tls": "none" }'
    local json_grpc='{ "v": "2", "ps": "'$user'", "add": "'$DOMAIN'", "port": "443", "id": "'$uuid'", "aid": "0", "net": "grpc", "path": "vmess-grpc", "type": "none", "host": "'$DOMAIN'", "tls": "tls" }'

    local link_tls=$(echo -n "$json_tls" | base64 -w 0)
    local link_nontls=$(echo -n "$json_nontls" | base64 -w 0)
    local link_grpc=$(echo -n "$json_grpc" | base64 -w 0)

    clear
    echo "[<= vmess account =>]"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "hostname    : $DOMAIN"
    echo "username    : $user"
    echo "expired     : $exp"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "   account information  "
    echo "━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "uuid/key     : $uuid"
    echo "alterid      : 0"
    echo "path ws      : /vmess"
    echo "service name : vmess-grpc"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "     port & service     "
    echo "━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "vmess ws tls : 443"
    echo "vmess ws non-tls : 80"
    echo "vmess grpc   : 443"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "link vmess ws tls   : vmess://$link_tls"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "link vmess ws non-tls : vmess://$link_nontls"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "link vmess grpc : vmess://$link_grpc"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━"
}

create_vless() {
    local user=$1
    local duration=$2
    local unit=$3
    local exp=$(calculate_expiration "$duration" "$unit")
    local uuid=$(uuidgen)
    
    inject_xray_config "$user" "$uuid" "vless"

    local link_tls="vless://${uuid}@${DOMAIN}:443?path=/vless&security=tls&encryption=none&type=ws&host=${DOMAIN}&sni=${DOMAIN}#${user}"
    local link_nontls="vless://${uuid}@${DOMAIN}:80?path=/vless&encryption=none&type=ws&host=${DOMAIN}#${user}"
    local link_grpc="vless://${uuid}@${DOMAIN}:443?mode=gun&security=tls&encryption=none&type=grpc&servicename=vless-grpc&sni=${DOMAIN}#${user}"

    clear
    echo "[<= vless account =>]"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "hostname    : $DOMAIN"
    echo "username    : $user"
    echo "expired     : $exp"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "   account information  "
    echo "━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "uuid/key     : $uuid"
    echo "encryption   : none"
    echo "path ws      : /vless"
    echo "service name : vless-grpc"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "     port & service     "
    echo "━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "vless ws tls : 443"
    echo "vless ws non-tls : 80"
    echo "vless grpc   : 443"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "link vless ws tls   : $link_tls"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "link vless ws non-tls : $link_nontls"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "link vless grpc : $link_grpc"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━"
}

create_trojan() {
    local user=$1
    local duration=$2
    local unit=$3
    local exp=$(calculate_expiration "$duration" "$unit")
    local uuid=$(uuidgen)
    
    inject_xray_config "$user" "$uuid" "trojan"

    local link_ws="trojan://${uuid}@${DOMAIN}:443?path=%2ftrojanws&security=tls&host=${DOMAIN}&type=ws&sni=${DOMAIN}#${user}"
    local link_grpc="trojan://${uuid}@${DOMAIN}:443?mode=gun&security=tls&type=grpc&servicename=trojan-grpc&sni=${DOMAIN}#${user}"

    clear
    echo "[<= trojan acount =>]"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "hostname    : $DOMAIN"
    echo "username    : $user"
    echo "expired     : $exp"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "   acount information   "
    echo "━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "uuid/key     : $uuid"
    echo "path trojan  : /trojan"
    echo "dynamic path : https://bug.com/trojan"
    echo "service name : trojan-grpc"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "     port & service     "
    echo "━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "trojan ws tls : 443"
    echo "trojan grpc   : 443"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "link trojan ws   : $link_ws"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "link trojan grpc : $link_grpc"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━"
}

# ==========================================
# Input Prompts
# ==========================================

prompt_account() {
    local type=$1
    echo -e "\n--- Create $type Account ---"
    read -p "Username: " user
    read -p "Duration quantity (e.g., 30): " duration
    echo "Select Unit:"
    echo "1. Minutes"
    echo "2. Hours"
    echo "3. Days"
    read -p "Choice (1/2/3): " unit

    case $type in
        "VMess") create_vmess "$user" "$duration" "$unit" ;;
        "VLESS") create_vless "$user" "$duration" "$unit" ;;
        "Trojan") create_trojan "$user" "$duration" "$unit" ;;
    esac
}

prompt_trial() {
    local type=$1
    local user="trial_$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 4 | head -n 1)"
    local duration=30
    local unit=1 # Minutes

    case $type in
        "VMess") create_vmess "$user" "$duration" "$unit" ;;
        "VLESS") create_vless "$user" "$duration" "$unit" ;;
        "Trojan") create_trojan "$user" "$duration" "$unit" ;;
    esac
}

# ==========================================
# Main Menu GUI
# ==========================================

echo "v2ray menu service"
echo "━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[ 1 ] create vmess acount"
echo "[ 2 ] create vless acount"
echo "[ 3 ] create trojan acount"
echo "━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[ 4 ] trial vmess account"
echo "[ 5 ] trial vless account"
echo "[ 6 ] trial trojan account"
echo "━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[ 7 ] delete v2ray acount"
echo "[ 8 ] renew v2ray acount"
echo "[ 9 ] check user login v2ray"
echo "[ 10] list all member v2ray"
echo ""

read -p "Select an option [1-10]: " menu_opt

case $menu_opt in
    1) prompt_account "VMess" ;;
    2) prompt_account "VLESS" ;;
    3) prompt_account "Trojan" ;;
    4) prompt_trial "VMess" ;;
    5) prompt_trial "VLESS" ;;
    6) prompt_trial "Trojan" ;;
    7) echo "Feature to delete account executing..."; # [ EDIT HERE ]: Link to delete logic
       ;;
    8) echo "Feature to renew account executing..."; # [ EDIT HERE ]: Link to renew logic
       ;;
    9) echo "Checking user logins..."; # [ EDIT HERE ]: Link to active login monitor logic
       ;;
    10) cat $USER_DB 2>/dev/null || echo "No users found."; # [ EDIT HERE ]: Link to list logic
       ;;
    *) echo "Invalid option." ;;
esac
