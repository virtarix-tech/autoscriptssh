#!/bin/bash
# ==========================================
# Advanced Multi-Transport VMess Manager
# ==========================================

XRAY_CONFIG="/usr/local/etc/xray/config.json"

# Auto-detect Domain or Fallback to Public IP so links never stay empty
if [ -f "/etc/xray/domain" ] && [ -s "/etc/xray/domain" ]; then
    DOMAIN=$(cat /etc/xray/domain)
else
    DOMAIN=$(curl -sS -4 ipv4.icanhazip.com 2>/dev/null || echo "yourvps.com")
fi

PORT=443

function create_user() {
    local is_trial=$1
    clear
    echo -e "========================================="
    if [ "$is_trial" = true ]; then
        echo -e "         CREATE VMESS TRIAL USER        "
        user="trial_$(symbol=$(db=0; echo $((RANDOM%9000+1000))); echo $symbol)"
        duration_input="30m" # Default trial is 30 minutes
        echo -e " Generated Username: $user"
        echo -e " Default Trial Time: 30m"
    else
        echo -e "        CREATE STANDARD VMESS USER       "
        read -p " Username: " user
        if [[ -z "$user" ]]; then echo "Username cannot be empty"; sleep 1; return; fi
        read -p " Duration (e.g., 30m, 12h, 7d): " duration_input
    fi

    # Expiration Parser (Minutes, Hours, Days)
    if [[ "$duration_input" =~ ^[0-9]+m$ ]]; then
        amt=$(echo $duration_input | sed 's/m//')
        exp=$(date -d "+$amt minutes" +"%Y-%m-%d %H:%M:%S")
    elif [[ "$duration_input" =~ ^[0-9]+h$ ]]; then
        amt=$(echo $duration_input | sed 's/h//')
        exp=$(date -d "+$amt hours" +"%Y-%m-%d %H:%M:%S")
    elif [[ "$duration_input" =~ ^[0-9]+d$ ]]; then
        amt=$(echo $duration_input | sed 's/d//')
        exp=$(date -d "+$amt days" +"%Y-%m-%d %H:%M:%S")
    else
        # Default to days if no modifier is written
        amt=${duration_input:-30}
        exp=$(date -d "+$amt days" +"%Y-%m-%d %H:%M:%S")
    fi

    # Select Transport Protocol
    echo -e "\n Select Transport Protocol:"
    echo -e " [1] WebSocket (ws)"
    echo -e " [2] HTTP Upgrade"
    echo -e " [3] TCP"
    echo -e " [4] gRPC"
    echo -e " [5] mKCP"
    echo -e " [6] HTTP/2 (h2)"
    echo -e " [7] XHTTP"
    read -p " Choice [1-7]: " net_choice
    
    case $net_choice in
        2) NET="httpupgrade"; PATH_VAL="/vmessup" ;;
        3) NET="tcp"; PATH_VAL="" ;;
        4) NET="grpc"; PATH_VAL="vmesstunnel" ;;
        5) NET="mkcp"; PATH_VAL="" ;;
        6) NET="h2"; PATH_VAL="/vmesshtwo" ;;
        7) NET="xhttp"; PATH_VAL="/vmessx" ;;
        *) NET="ws"; PATH_VAL="/vmess" ;;
    esac

    # Select TLS Fingerprint (uTLS)
    echo -e "\n Select TLS Client Fingerprint (uTLS):"
    echo -e " [1] Chrome (Recommended)"
    echo -e " [2] Firefox"
    echo -e " [3] Safari"
    echo -e " [4] Edge"
    read -p " Choice [1-4]: " fp_choice
    case $fp_choice in 2) FP="firefox" ;; 3) FP="safari" ;; 4) FP="edge" ;; *) FP="chrome" ;; esac

    # Allow Insecure Certificates
    echo -e "\n Allow Insecure TLS Certificates?"
    echo -e " [1] No (Secure)"
    echo -e " [2] Yes (Allow Insecure)"
    read -p " Choice [1-2]: " ins_choice
    if [[ "$ins_choice" == "2" ]]; then ALLOW_INS="true"; else ALLOW_INS="false"; fi

    uuid=$(uuidgen)
    
    # Inject user into Xray Config (assuming VMess is inbound index 0)
    jq ".inbounds[0].settings.clients += [{\"id\": \"${uuid}\", \"alterId\": 0, \"email\": \"${user}\"}]" $XRAY_CONFIG > $XRAY_CONFIG.tmp && mv $XRAY_CONFIG.tmp $XRAY_CONFIG
    systemctl restart xray 2>/dev/null

    # Generate V2Ray standardized base64 Link JSON block
    vmess_json=$(cat <<EOF
{
  "v": "2",
  "ps": "${user}_VMESS",
  "add": "${DOMAIN}",
  "port": "${PORT}",
  "id": "${uuid}",
  "aid": "0",
  "net": "${NET}",
  "type": "none",
  "host": "${DOMAIN}",
  "path": "${PATH_VAL}",
  "tls": "tls",
  "sni": "${DOMAIN}",
  "fp": "${FP}",
  "alpn": "h2,http/1.1",
  "allowInsecure": ${ALLOW_INS}
}
EOF
)
    vmess_link="vmess://$(echo -n "$vmess_json" | base64 -w 0)"

    clear
    echo -e "========================================="
    echo -e "       VMESS ACCOUNT PROVISIONED         "
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
    echo -e " Link String:\n ${vmess_link}"
    echo -e "========================================="
    read -n 1 -s -r -p "Press any key to return..."
}

function menu_vmess() {
    while true; do
        clear
        echo -e "========================================="
        echo -e "       CORE VMESS MANAGEMENT MENU        "
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
menu_vmess