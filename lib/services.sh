# File: /opt/virtarixtech/lib/services.sh
# Purpose: Safe service orchestration and restarts.

source /opt/virtarixtech/core/virtarixtech.conf
source /opt/virtarixtech/lib/system.sh

restart_service() {
    local service_name="$1"
    
    if [ "$service_name" == "all" ]; then
        log_event "INFO" "Restarting ALL Virtarixtech services..."
        local services=(virtarixtech-ws virtarixtech-dnstt virtarixtech-monitor virtarixtech-udp-custom stunnel4 dropbear danted ssh sshd)
        for svc in "${services[@]}"; do
            systemctl restart "$svc" >/dev/null 2>&1
            log_event "INFO" "Restarted $svc"
        done
        return 0
    fi

    # Strict whitelist to prevent arbitrary systemctl execution
    case "$service_name" in
        dropbear|stunnel4|virtarixtech-ws|virtarixtech-dnstt|virtarixtech-monitor|danted|virtarixtech-udp-custom|ssh|sshd)
            log_event "INFO" "Restarting service: $service_name"
            systemctl restart "$service_name"
            
            if systemctl is-active --quiet "$service_name"; then
                log_event "INFO" "Successfully restarted $service_name."
                return 0
            else
                log_event "ERROR" "Failed to restart $service_name. Check journalctl -xe."
                return 1
            fi
            ;;
        *)
            log_event "WARN" "Attempted to restart unauthorized/unknown service: $service_name"
            return 1
            ;;
    esac
}

