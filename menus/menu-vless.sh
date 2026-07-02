#!/bin/bash
# ==========================================
# Advanced Multi-Transport VLESS Manager
# ==========================================

XRAY_CONFIG="/usr/local/etc/xray/config.json"

if [ -f "/opt/virtarixtech/core/virtarixtech.conf" ]; then
    source /opt/virtarixtech/core/virtarixtech.conf
    DOMAIN="${PRIMARY_DOMAIN}"
fi

if [[ -z "$DOMAIN" ]]; then
    DOMAIN=$(curl -sS -4 ipv4.icanhazip.com 2>/dev/null || echo "yourvps.com")
fi
PORT=443

function create_user() {
    local is_trial=$1
    clear
    echo -e "========================================="
    if [ "$is_trial" = true ]; then
        echo -e "         CREATE VLESS TRIAL USER        "
        user="trial_$(echo $((RANDOM%9000+1000)))"
        duration_input="30m"
        echo -e " Generated Username: $user"
    else
        echo -e "        CREATE STANDARD VLESS USER       "
        read -p " Username: " user
        if [[ -z "$user" ]]; then echo "Username cannot be empty"; sleep 1; return; fi
        read -p " Duration (e.g., 30m, 12h, 7d): " duration_input
    fi

    if [[ "$duration_input" =~ ^[0-9]+m$ ]]; then
        amt=$(echo $duration_input | sed 's/m//'); exp=$(date -d "+$amt minutes" +"%Y-%m-%d %H:%M:%S")
    elif [[ "$duration_input" =~ ^[0-9]+h$ ]]; then
        amt=$(echo $duration_input | sed 's/h//'); exp=$(date -d "+$amt hours" +"%Y-%m-%d %H:%M:%S")
    elif [[ "$duration_input" =~ ^[0-9]+d$ ]]; then
        amt=$(echo $duration_input | sed 's/d//'); exp=$(date -d "+$amt days" +"%Y-%m-%d %H:%M:%S")
    else
        amt=${duration_input:-30}; exp=$(date -d "+$amt days" +"%Y-%m-%d %H:%M:%S")
    fi

    echo -e "\n Select Transport Protocol:"
    echo -e " [1] WebSocket (ws)\n [2] HTTP Upgrade\n [3] TCP\n [4] gRPC\n [5] mKCP\n [6] HTTP/2 (h2)\n [7] XHTTP"
    read -p " Choice [1-7]: " net_choice
    
    case $net_choice in
        2) NET="httpupgrade"; PATH_VAL="/vlessup" ;;
        3) NET="tcp"; PATH_VAL="" ;;
        4) NET="grpc"; PATH_VAL="vlesstunnel" ;;
        5) NET="mkcp"; PATH_VAL="" ;;
        6) NET="h2"; PATH_VAL="/vlesshtwo" ;;
        7) NET="xhttp"; PATH_VAL="/vlessx" ;;
        *) NET="ws"; PATH_VAL="/vless" ;;
    esac

    echo -e "\n Select TLS Client Fingerprint (uTLS):\n [1] Chrome\n [2] Firefox\n [3] Safari\n [4] Edge"
    read -p " Choice [1-4]: " fp_choice
    case $fp_choice in 2) FP="firefox" ;; 3) FP="safari" ;; 4) FP="edge" ;; *) FP="chrome" ;; esac

    echo -e "\n Allow Insecure TLS Certificates?\n [1] No\n [2] Yes"
    read -p " Choice [1-2]: " ins_choice
    if [[ "$ins_choice" == "2" ]]; then ALLOW_INS="true"; else ALLOW_INS="false"; fi

    uuid=$(uuidgen)
    
    jq ".inbounds[1].settings.clients += [{\"id\": \"${uuid}\", \"email\": \"${user}\"}]" $XRAY_CONFIG > $XRAY_CONFIG.tmp && mv $XRAY_CONFIG.tmp $XRAY_CONFIG
    systemctl restart xray 2>/dev/null

    # VLESS direct URI integration using your configured platform domain
    vless_link="vless://${uuid}@${DOMAIN}:${PORT}?encryption=none&security=tls&sni=${DOMAIN}&host=${DOMAIN}&type=${NET}&path=${PATH_VAL}&fp=${FP}&allowInsecure=${ALLOW_INS}#${user}_VLESS"

    clear
    echo -e "========================================="
    echo -e "       VLESS ACCOUNT PROVISIONED         "
    echo -e "========================================="
    echo -e " Username      : $user"
    echo -e " Target Server : $DOMAIN"
    echo -e " Port          : $PORT"
    echo -e " UUID          : $uuid"
    echo -e " Transport     : $NET"
    echo -e " Path / Service: ${PATH_VAL:-None}"
    echo -e " SNI / Host    : $DOMAIN"
    echo -e " Fingerprint   : $FP"
    echo -e " Insecure Cert : $ALLOW_INS"
    echo -e " Expires On    : $exp"
    echo -e "========================================="
    echo -e " Link String:\n ${vless_link}"
    echo -e "========================================="
    read -n 1 -s -r -p "Press any key to return..."
}

function menu_vless() {
    while true; do
        clear
        echo -e "========================================="
        echo -e "       CORE VLESS MANAGEMENT MENU        "
        echo -e "========================================="
        echo -e " [1] Provision Standard User Account"
        echo -e " [2] Provision 30-Minute Trial Account"
        echo -e " [0] Exit Sub-Menu Dashboard"
        echo -e "========================================="
        read -p " Select Option : " opt
        case $opt in
            1) create_user false ;;
            2) create_user true ;;
            0) exit 0 ;;
            *) echo "Invalid Entry"; sleep 1 ;;
        esac
    done
}
menu_vless