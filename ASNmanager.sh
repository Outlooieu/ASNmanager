cat << 'SCRIPT_EOF' > /jffs/scripts/ASNmanager.sh && chmod +x /jffs/scripts/ASNmanager.sh && sed -i 's/\r$//' /jffs/scripts/ASNmanager.sh && /jffs/scripts/ASNmanager.sh
#!/bin/sh
# ASN Manager for Asuswrt-Merlin

[ -t 0 ] || exec < /dev/tty 2>/dev/null

SCRIPT_VERSION="1.1.0"
ASN_FILE="/jffs/scripts/asn_list.txt"
WORKER_SCRIPT="/jffs/scripts/asn-bypass-worker.sh"
STATS_FILE="/tmp/asn_counts.txt"
SCHEDULE_FILE="/jffs/scripts/asn_schedule.txt"
SERVICES_START="/jffs/scripts/services-start"
GITHUB_USER="Outlooieu"
GITHUB_REPO="ASNmanager"

[ ! -f "$ASN_FILE" ] && touch "$ASN_FILE"

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
MAGENTA='\033[0;35m'
NC='\033[0m'

get_ifname() {
    case "$1" in
        WAN|WAN1) echo "$(nvram get wan0_ifname 2>/dev/null)" ;;
        WAN2)     echo "$(nvram get wan1_ifname 2>/dev/null)" ;;
        OVPN1)    echo "tun11" ;;
        OVPN2)    echo "tun12" ;;
        OVPN3)    echo "tun13" ;;
        OVPN4)    echo "tun14" ;;
        OVPN5)    echo "tun15" ;;
        WGC1)     echo "wgc1" ;;
        WGC2)     echo "wgc2" ;;
        WGC3)     echo "wgc3" ;;
        WGC4)     echo "wgc4" ;;
        WGC5)     echo "wgc5" ;;
        *)        echo "" ;;
    esac
}

check_iface_up() {
    case "$1" in
        WAN|WAN1)
            wan_unit=$(nvram get wan0_ifname 2>/dev/null)
            [ -n "$wan_unit" ] && ip addr show dev "$wan_unit" 2>/dev/null | grep -q "inet " && return 0
            wan_ip=$(nvram get wan0_ipaddr 2>/dev/null)
            [ -n "$wan_ip" ] && [ "$wan_ip" != "0.0.0.0" ] && return 0
            return 1
            ;;
        WAN2)
            wan_unit=$(nvram get wan1_ifname 2>/dev/null)
            [ -n "$wan_unit" ] && ip addr show dev "$wan_unit" 2>/dev/null | grep -q "inet " && return 0
            wan_ip=$(nvram get wan1_ipaddr 2>/dev/null)
            [ -n "$wan_ip" ] && [ "$wan_ip" != "0.0.0.0" ] && return 0
            return 1
            ;;
        *)
            dev=$(get_ifname "$1")
            [ -n "$dev" ] && ip addr show dev "$dev" 2>/dev/null | grep -q "inet " && return 0
            return 1
            ;;
    esac
}

get_target_info() {
    case "$1" in
        WAN|WAN1) echo "254 0x8000 9990" ;;
        WAN2)     echo "253 0x8500 9890" ;;
        OVPN1)    echo "111 0x1000 9991" ;;
        OVPN2)    echo "112 0x2000 9992" ;;
        OVPN3)    echo "113 0x3000 9993" ;;
        OVPN4)    echo "114 0x4000 9994" ;;
        OVPN5)    echo "115 0x5000 9995" ;;
        WGC1)     echo "211 0x6100 9996" ;;
        WGC2)     echo "212 0x6200 9997" ;;
        WGC3)     echo "213 0x6300 9998" ;;
        WGC4)     echo "214 0x6400 9999" ;;
        WGC5)     echo "215 0x6500 10000" ;;
        *)        echo "" ;;
    esac
}

load_schedule() {
    INTERVAL=""
    TIME_VAL=""
    if [ -f "$SCHEDULE_FILE" ]; then
        INTERVAL=$(grep "^INTERVAL=" "$SCHEDULE_FILE" | cut -d'=' -f2)
        TIME_VAL=$(grep "^TIME=" "$SCHEDULE_FILE" | cut -d'=' -f2)
    fi
    [ -z "$INTERVAL" ] && INTERVAL=1
    [ -z "$TIME_VAL" ] && TIME_VAL="04:30"

    RAW_H=$(echo "$TIME_VAL" | cut -d':' -f1)
    RAW_M=$(echo "$TIME_VAL" | cut -d':' -f2)
    HOUR=$(echo "$RAW_H" | sed 's/^0\+\([0-9]\)/\1/')
    MIN=$(echo "$RAW_M" | sed 's/^0\+\([0-9]\)/\1/')
    [ -z "$HOUR" ] && HOUR=0
    [ -z "$MIN" ] && MIN=0
}

apply_schedule() {
    load_schedule
    cru d ASN_Worker 2>/dev/null
    cru a ASN_Worker "$MIN $HOUR */$INTERVAL * * $WORKER_SCRIPT"
    
    [ ! -f "$SERVICES_START" ] && touch "$SERVICES_START" && chmod +x "$SERVICES_START"
    sed -i '/cru [ad] ASN_Worker/d' "$SERVICES_START"
    echo "cru a ASN_Worker \"$MIN $HOUR */$INTERVAL * * $WORKER_SCRIPT\"" >> "$SERVICES_START"
}

configure_schedule() {
    clear
    load_schedule
    echo -e "${YELLOW}--- ASN IP Ranges Auto-Refresh Schedule ---${NC}"
    echo -e "Current Schedule: Re-fetching ASN IP subnets every ${GREEN}${INTERVAL}${NC} day(s) at ${GREEN}${TIME_VAL}${NC} (24h format)"
    echo ""
    echo -n "Enter IP subnet refresh interval in days [1-30] (Default: ${INTERVAL}, 0 to Cancel): "
    read -r user_int
    if [ "$user_int" = "0" ]; then
        echo -e "${YELLOW}Cancelled.${NC}"
        sleep 1
        return
    fi
    [ -z "$user_int" ] && user_int=$INTERVAL

    case "$user_int" in
        ''|*[!0-9]*) echo -e "${RED}Invalid interval! Must be a number.${NC}"; sleep 1; return ;;
    esac

    echo -n "Enter refresh execution time HH:MM (24-hour format, e.g. 04:30, Default: ${TIME_VAL}): "
    read -r user_time
    [ -z "$user_time" ] && user_time=$TIME_VAL

    if ! echo "$user_time" | grep -qE '^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$'; then
        echo -e "${RED}Invalid time format! Use HH:MM in 24-hour format (e.g., 04:30).${NC}"
        sleep 1; return
    fi

    echo "INTERVAL=$user_int" > "$SCHEDULE_FILE"
    echo "TIME=$user_time" >> "$SCHEDULE_FILE"

    apply_schedule
    echo -e "\n${GREEN}ASN IP subnet auto-refresh set to run every ${user_int} day(s) at ${user_time}!${NC}"
    echo -e "${CYAN}Updated active cron job and persistent /jffs/scripts/services-start.${NC}"
    sleep 2
}

show_interface_ips() {
    clear
    echo -e "${YELLOW}--- Active Interface Public IP & Country Info ---${NC}\n"

    print_ip_info() {
        iface_label="$1"
        dev_name="$2"
        color_code="$3"

        if [ -n "$dev_name" ]; then
            pub_ip=$(curl -s -k --interface "$dev_name" --connect-timeout 3 https://api.ipify.org 2>/dev/null)
        else
            pub_ip=$(curl -s -k --connect-timeout 3 https://api.ipify.org 2>/dev/null)
        fi

        if [ -n "$pub_ip" ]; then
            geo_json=$(curl -s -k --connect-timeout 3 "http://ip-api.com/json/$pub_ip?fields=status,country,countryCode" 2>/dev/null)
            country=$(echo "$geo_json" | grep -oE '"country":"[^"]+' | cut -d'"' -f4)
            ccode=$(echo "$geo_json" | grep -oE '"countryCode":"[^"]+' | cut -d'"' -f4)
            
            [ -z "$country" ] && country="Unknown"
            
            echo -e " ${color_code}[ONLINE]${NC} ${iface_label}"
            echo -e "   IP:     ${CYAN}${pub_ip}${NC}"
            echo -e "   Country: ${GREEN}${country} (${ccode:-??})${NC}\n"
        else
            echo -e " ${RED}[OFFLINE]${NC} ${iface_label}\n"
        fi
    }

    wan1_dev=$(nvram get wan0_ifname 2>/dev/null)
    if [ -n "$wan1_dev" ] && ip addr show dev "$wan1_dev" 2>/dev/null | grep -q "inet "; then
        print_ip_info "WAN / WAN1 (${wan1_dev})" "$wan1_dev" "$GREEN"
    else
        wan_ip=$(nvram get wan0_ipaddr 2>/dev/null)
        [ -n "$wan_ip" ] && [ "$wan_ip" != "0.0.0.0" ] && print_ip_info "WAN / WAN1 (default)" "" "$GREEN" || echo -e " ${RED}[OFFLINE]${NC} WAN / WAN1\n"
    fi

    wan2_dev=$(nvram get wan1_ifname 2>/dev/null)
    multi_wan=$(nvram get wans_mode 2>/dev/null)
    if [ "$multi_wan" = "lb" ] || [ "$multi_wan" = "fo" ] || [ -n "$wan2_dev" ]; then
        [ -n "$wan2_dev" ] && ip addr show dev "$wan2_dev" 2>/dev/null | grep -q "inet " && print_ip_info "WAN2 (${wan2_dev})" "$wan2_dev" "$GREEN"
    fi

    i=1
    while [ $i -le 5 ]; do
        dev="tun$((10 + i))"
        ip addr show dev "$dev" 2>/dev/null | grep -q "inet " && print_ip_info "OpenVPN Client $i (${dev})" "$dev" "$YELLOW"
        i=$((i + 1))
    done

    i=1
    while [ $i -le 5 ]; do
        dev="wgc$i"
        ip addr show dev "$dev" 2>/dev/null | grep -q "inet " && print_ip_info "WireGuard Client $i (${dev})" "$dev" "$MAGENTA"
        i=$((i + 1))
    done

    echo -n "Press Enter to return..."
    read -r _
}

backup_restore_menu() {
    clear
    echo -e "${YELLOW}--- Backup & Restore Configuration ---${NC}"
    USB_DIRS=$(ls -d /mnt/* /tmp/mnt/* 2>/dev/null | grep -v '\*')
    
    echo -e " [1] Export Backup to Internal (/jffs/)"
    [ -n "$USB_DIRS" ] && echo -e " [2] Export Backup to External USB (Folder: ASNmanager)"
    echo -e " [3] Import Backup (Restore)"
    echo -e " [0] Cancel"
    echo ""
    echo -n "Select option [0-3]: "
    read -r b_opt
    
    case "$b_opt" in
        1) BACKUP_DIR="/jffs" ;;
        2)
            if [ -n "$USB_DIRS" ]; then
                set -- $USB_DIRS
                chosen_usb="$1"
                BACKUP_DIR="${chosen_usb}/ASNmanager"
                [ ! -d "$BACKUP_DIR" ] && mkdir -p "$BACKUP_DIR"
            else
                BACKUP_DIR="/jffs"
            fi
            ;;
        3)
            FOUND_BACKUPS=$(find /jffs /mnt /tmp/mnt -maxdepth 4 -name "asn_manager_backup_*.conf" 2>/dev/null)
            if [ -z "$FOUND_BACKUPS" ]; then
                echo -e "${RED}No backup files found.${NC}"
                sleep 2
                return
            fi
            echo -e "${GREEN}Found backups:${NC}"
            i=1
            set -- $FOUND_BACKUPS
            for f in "$@"; do
                echo -e " [$i] $f"
                i=$((i+1))
            done
            echo -n "Select backup file to restore [1]: "
            read -r f_sel
            [ -z "$f_sel" ] && f_sel=1
            eval imp_file=\${$f_sel}
            if [ -f "$imp_file" ]; then
                if grep -q "\[ASN_LIST\]" "$imp_file"; then
                    sed -n '/\[ASN_LIST\]/,/\[SCHEDULE\]/p' "$imp_file" | grep -v '\[.*\]' | grep -v '^$' > "$ASN_FILE"
                    sed -n '/\[SCHEDULE\]/,$p' "$imp_file" | grep -v '\[.*\]' | grep -v '^$' > "$SCHEDULE_FILE"
                else
                    cp "$imp_file" "$ASN_FILE"
                fi
                sort -u "$ASN_FILE" -o "$ASN_FILE" 2>/dev/null
                apply_schedule
                echo -e "\n${GREEN}Configuration successfully restored! Run Option [6] to apply rules.${NC}"
                sleep 3
            else
                echo -e "\n${RED}File not found.${NC}"
                sleep 2
            fi
            return
            ;;
        *) echo -e "${YELLOW}Cancelled.${NC}"; sleep 1; return ;;
    esac
    
    BACKUP_FILE="${BACKUP_DIR}/asn_manager_backup_$(date +%Y%m%d_%H%M%S).conf"
    echo "# ASN Manager Backup" > "$BACKUP_FILE"
    echo "VERSION=$SCRIPT_VERSION" >> "$BACKUP_FILE"
    echo "[ASN_LIST]" >> "$BACKUP_FILE"
    [ -f "$ASN_FILE" ] && cat "$ASN_FILE" >> "$BACKUP_FILE"
    echo "[SCHEDULE]" >> "$BACKUP_FILE"
    [ -f "$SCHEDULE_FILE" ] && cat "$SCHEDULE_FILE" >> "$BACKUP_FILE"
    echo -e "\n${GREEN}Backup successfully created at:${NC} ${CYAN}$BACKUP_FILE${NC}"
    sleep 2
}

uninstall_menu() {
    clear
    echo -e "${RED}--- Uninstall ASN Manager ---${NC}"
    echo -n "Are you ABSOLUTELY sure you want to completely uninstall ASN Manager? (y/n): "
    read -r final_conf
    case "$final_conf" in
        [Yy]*)
            for active_set in $(ipset list -n | grep "^ASN_"); do
                dest_name=$(echo "$active_set" | sed -E 's/ASN_([^_]+).*/\1/')
                info=$(get_target_info "$dest_name")
                if [ -n "$info" ]; then
                    FWMARK=$(echo "$info" | cut -d' ' -f2)/$(echo "$info" | cut -d' ' -f2)
                    iptables -t mangle -D PREROUTING -m set --match-set "$active_set" dst -j MARK --set-mark "$FWMARK" 2>/dev/null
                    iptables -t mangle -D OUTPUT -m set --match-set "$active_set" dst -j MARK --set-mark "$FWMARK" 2>/dev/null
                fi
                ipset flush "$active_set" 2>/dev/null
                ipset destroy "$active_set" 2>/dev/null
            done
            cru d ASN_Worker 2>/dev/null
            rm -f "$ASN_FILE" "$SCHEDULE_FILE" "$STATS_FILE" "$WORKER_SCRIPT" "/jffs/scripts/ASNmanager.sh" 2>/dev/null
            echo -e "\n${GREEN}ASN Manager successfully uninstalled.${NC}"
            exit 0
            ;;
        *) echo -e "${YELLOW}Cancelled.${NC}"; sleep 1 ;;
    esac
}

prompt_destination() {
    echo ""
    echo -e "${YELLOW}Select Target Interface for ASN(s):${NC}"
    echo -e " [1]  WAN / WAN1 (Primary Gateway)"
    echo -e " [2]  WAN2 (Secondary Dual-WAN Gateway)"
    echo -e " [3-7] OpenVPN Clients 1-5 (OVPN1 - OVPN5)"
    echo -e " [8-12] WireGuard Clients 1-5 (WGC1 - WGC5)"
    echo -e " [0]  Cancel"
    echo -n "Choice [0-12] (Default: 1 - WAN1): "
    read -r dest_opt
    case "$dest_opt" in
        0)  SELECTED_DEST="CANCEL" ;;
        2)  SELECTED_DEST="WAN2" ;;
        3)  SELECTED_DEST="OVPN1" ;;
        4)  SELECTED_DEST="OVPN2" ;;
        5)  SELECTED_DEST="OVPN3" ;;
        6)  SELECTED_DEST="OVPN4" ;;
        7)  SELECTED_DEST="OVPN5" ;;
        8)  SELECTED_DEST="WGC1" ;;
        9)  SELECTED_DEST="WGC2" ;;
        10) SELECTED_DEST="WGC3" ;;
        11) SELECTED_DEST="WGC4" ;;
        12) SELECTED_DEST="WGC5" ;;
        *)  SELECTED_DEST="WAN1" ;;
    esac
}

prompt_source_ip() {
    echo -n "Enter Source IP for device-specific routing [e.g. 192.168.1.50, Leave blank for ALL devices]: "
    read -r SELECTED_SRC_IP
    SELECTED_SRC_IP=$(echo "$SELECTED_SRC_IP" | tr -d ' ')
    if [ -n "$SELECTED_SRC_IP" ]; then
        if ! echo "$SELECTED_SRC_IP" | grep -qE '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$'; then
            echo -e "${RED}Invalid IP format! Applying globally for all devices instead.${NC}"
            SELECTED_SRC_IP=""
            sleep 2
        fi
    fi
}

service_presets() {
    clear
    echo -e "${YELLOW}--- Add ASN Service Presets ---${NC}"
    echo -e " [1]  Amazon / AWS | [2] Google | [3] YouTube | [4] Netflix"
    echo -e " [5]  Cloudflare   | [6] Steam  | [7] Meta    | [8] Microsoft"
    echo -e " [9]  Apple        | [10] Telegram"
    echo -e " [0]  Cancel"
    echo -n "Select preset [0-10]: "
    read -r p_opt
    case "$p_opt" in
        1) PRESET_ASNS="16509 14618" ;;
        2) PRESET_ASNS="15169 8075 22577" ;;
        3) PRESET_ASNS="43515 36040" ;;
        4) PRESET_ASNS="2906 40027" ;;
        5) PRESET_ASNS="13335 209242" ;;
        6) PRESET_ASNS="32590" ;;
        7) PRESET_ASNS="32934 63293" ;;
        8) PRESET_ASNS="8075 8068 8074 36444" ;;
        9) PRESET_ASNS="714" ;;
        10) PRESET_ASNS="62041 59930 44907 211157 20473" ;;
        *) return ;;
    esac

    prompt_destination
    [ "$SELECTED_DEST" = "CANCEL" ] && return
    prompt_source_ip

    for asn in $PRESET_ASNS; do
        sed -i "/^${asn}:/d" "$ASN_FILE"
        echo "${asn}:${SELECTED_DEST}:${SELECTED_SRC_IP}" >> "$ASN_FILE"
    done
    sort -u "$ASN_FILE" -o "$ASN_FILE" 2>/dev/null
    echo -e "${GREEN}Preset assigned successfully! Run Option [6] to apply rules.${NC}"
    sleep 2
}

remove_menu() {
    clear
    echo -e "${YELLOW}--- Remove ASN ---${NC}"
    echo -n "Enter ASN number to remove (e.g. 15169): "
    read -r rem_asn
    clean_rem=$(echo "$rem_asn" | sed -E 's/[Aa][Ss]([0-9]+)/\1/g')
    [ -n "$clean_rem" ] && sed -i "/^${clean_rem}:/d" "$ASN_FILE"
    echo -e "${GREEN}ASN AS$clean_rem removed if present. Run Option [6] to apply rules.${NC}"
    sleep 2
}

is_remote_newer() {
    awk -v cur="$1" -v rem="$2" '
    BEGIN {
        split(cur, c, ".");
        split(rem, r, ".");
        for (i = 1; i <= 3; i++) {
            c[i] = c[i] + 0; r[i] = r[i] + 0;
            if (r[i] > c[i]) exit 0;
            if (r[i] < c[i]) exit 1;
        }
        exit 1;
    }' 2>/dev/null
}

update_self() {
    clear
    echo -e "${YELLOW}--- Updating ASN Manager ---${NC}"
    TMP_SCRIPT="/tmp/ASNmanager-update.sh"
    rm -f "$TMP_SCRIPT" 2>/dev/null
    FETCH_URL="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/main/ASNmanager.sh"

    if curl -s -S -k --connect-timeout 10 "$FETCH_URL" -o "$TMP_SCRIPT" && [ -s "$TMP_SCRIPT" ]; then
        sed -i 's/\r$//' "$TMP_SCRIPT" 2>/dev/null
        REMOTE_VERSION=$(grep -m 1 "^SCRIPT_VERSION=" "$TMP_SCRIPT" | cut -d'"' -f2 | tr -d '\r')
        if [ "$SCRIPT_VERSION" = "$REMOTE_VERSION" ]; then
            echo -e "${GREEN}Already running latest v${SCRIPT_VERSION}.${NC}"
        elif is_remote_newer "$SCRIPT_VERSION" "$REMOTE_VERSION"; then
            cp "$TMP_SCRIPT" /jffs/scripts/ASNmanager.sh && chmod +x /jffs/scripts/ASNmanager.sh
            echo -e "${GREEN}Updated to v${REMOTE_VERSION}! Reloading...${NC}"
            sleep 1; exec /bin/sh /jffs/scripts/ASNmanager.sh
        else
            echo -e "${GREEN}Installed version is newer.${NC}"
        fi
    else
        echo -e "${RED}Update check failed!${NC}"
    fi
    rm -f "$TMP_SCRIPT" 2>/dev/null
    echo -n "Press Enter to return..." && read -r _
}

show_menu() {
    clear
    load_schedule
    echo -e "${CYAN}================================================================${NC}"
    echo -e "${YELLOW}              === ASN MANAGER v${SCRIPT_VERSION} ===${NC}"
    echo -e "${CYAN}================================================================${NC}"
    echo -e " [1]  View current ASN list & routing targets"
    echo -e " [2]  Add ASN(s) with Target Interface & Source IP"
    echo -e " [3]  Find ASN for Domain / IP"
    echo -e " [4]  Add ASN Service Presets"
    echo -e " [5]  Remove ASN"
    echo -e " [6]  Build & Apply New Routing Rules"
    echo -e " [7]  Check ipset Status & Subnet Count"
    echo -e " [8]  Test IP or Domain Routing"
    echo -e " [9]  Show active interface IP addresses & countries"
    echo -e " [10] Run Traceroute to IP or Domain"
    echo -e " [11] Update ASN Manager on GitHub"
    echo -e " [12] Set Auto-Refresh Schedule (Every ${INTERVAL}d @ ${TIME_VAL})"
    echo -e " [13] Backup & Restore Configuration"
    echo -e " [14] Uninstall ASN Manager"
    echo -e " [0]  Exit"
    echo -e "${CYAN}----------------------------------------------------------------${NC}"
    echo -n "Select an option [0-14]: "
}

rebuild_worker() {
    [ ! -s "$ASN_FILE" ] && echo -e "${RED}Error: ASN list is empty.${NC}" && return 1

    cat << 'WORKER_EOF' > "$WORKER_SCRIPT"
#!/bin/sh
# Generated by ASN Manager

ASN_FILE="/jffs/scripts/asn_list.txt"
STATS_FILE="/tmp/asn_counts.txt"

[ ! -s "$ASN_FILE" ] && exit 0

n=0
until ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; do
    n=$((n+1))
    [ $n -ge 30 ] && break
    sleep 2
done

> "$STATS_FILE"

get_ifname() {
    case "$1" in
        WAN|WAN1) echo "$(nvram get wan0_ifname 2>/dev/null)" ;;
        WAN2)     echo "$(nvram get wan1_ifname 2>/dev/null)" ;;
        OVPN1)    echo "tun11" ;; OVPN2) echo "tun12" ;; OVPN3) echo "tun13" ;; OVPN4) echo "tun14" ;; OVPN5) echo "tun15" ;;
        WGC1)     echo "wgc1" ;; WGC2) echo "wgc2" ;; WGC3) echo "wgc3" ;; WGC4) echo "wgc4" ;; WGC5) echo "wgc5" ;;
        *)        echo "" ;;
    esac
}

check_iface_up() {
    case "$1" in
        WAN|WAN1)
            wan_unit=$(nvram get wan0_ifname 2>/dev/null)
            [ -n "$wan_unit" ] && ip addr show dev "$wan_unit" 2>/dev/null | grep -q "inet " && return 0
            wan_ip=$(nvram get wan0_ipaddr 2>/dev/null)
            [ -n "$wan_ip" ] && [ "$wan_ip" != "0.0.0.0" ] && return 0
            return 1
            ;;
        WAN2)
            wan_unit=$(nvram get wan1_ifname 2>/dev/null)
            [ -n "$wan_unit" ] && ip addr show dev "$wan_unit" 2>/dev/null | grep -q "inet " && return 0
            wan_ip=$(nvram get wan1_ipaddr 2>/dev/null)
            [ -n "$wan_ip" ] && [ "$wan_ip" != "0.0.0.0" ] && return 0
            return 1
            ;;
        *)
            dev=$(get_ifname "$1")
            [ -n "$dev" ] && ip addr show dev "$dev" 2>/dev/null | grep -q "inet " && return 0
            return 1
            ;;
    esac
}

get_info() {
    case "$1" in
        WAN|WAN1) echo "254 0x8000 9990" ;;
        WAN2)     echo "253 0x8500 9890" ;;
        OVPN1)    echo "111 0x1000 9991" ;; OVPN2) echo "112 0x2000 9992" ;; OVPN3) echo "113 0x3000 9993" ;; OVPN4) echo "114 0x4000 9994" ;; OVPN5) echo "115 0x5000 9995" ;;
        WGC1)     echo "211 0x6100 9996" ;; WGC2) echo "212 0x6200 9997" ;; WGC3) echo "213 0x6300 9998" ;; WGC4) echo "214 0x6400 9999" ;; WGC5) echo "215 0x6500 10000" ;;
        *)        echo "" ;;
    esac
}

fetch_asn_prefixes() {
    asn="$1"
    tmp_file="/tmp/asn_${asn}.txt"
    prefixes=""

    if [ "$asn" = "16509" ] || [ "$asn" = "14618" ]; then
        prefixes=$(curl -fsSk --connect-timeout 6 -m 10 "https://ip-ranges.amazonaws.com/ip-ranges.json" 2>/dev/null | grep -oE '"ip_prefix": "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}"' | cut -d'"' -f4 | sort -u)
    fi
    [ -z "$prefixes" ] && prefixes=$(curl -fsSk --connect-timeout 6 -m 10 "https://raw.githubusercontent.com/ipverse/asn-ip/master/as/${asn}/ipv4-aggregated.cidr" 2>/dev/null | grep -E '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}$' | sort -u)
    [ -z "$prefixes" ] && prefixes=$(curl -fsSk --connect-timeout 8 -m 25 -A "Mozilla/5.0" "https://stat.ripe.net/data/announced-prefixes/data.json?resource=AS${asn}" 2>/dev/null | tr ',' '\n' | grep -oE '"prefix":"[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}"' | cut -d'"' -f4 | sort -u)
    [ -z "$prefixes" ] && prefixes=$(curl -fsSk --connect-timeout 6 -m 10 -A "Mozilla/5.0" "https://api.hackertarget.com/aslookup/?q=AS${asn}" 2>/dev/null | grep -E '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}$' | sort -u)
    [ -z "$prefixes" ] && prefixes=$(curl -fsSk --connect-timeout 6 -m 10 -A "Mozilla/5.0" "https://api.bgpview.io/asn/${asn}/prefixes" 2>/dev/null | tr ',' '\n' | grep -oE '"prefix":"[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}"' | cut -d'"' -f4 | sort -u)

    echo "$prefixes" > "$tmp_file"
}

# Clean old rules/sets
for active_set in $(ipset list -n | grep "^ASN_"); do
    dest_name=$(echo "$active_set" | sed -E 's/ASN_([^_]+).*/\1/')
    info=$(get_info "$dest_name")
    if [ -n "$info" ]; then
        FWMARK=$(echo "$info" | cut -d' ' -f2)/$(echo "$info" | cut -d' ' -f2)
        iptables -t mangle -D PREROUTING -m set --match-set "$active_set" dst -j MARK --set-mark "$FWMARK" 2>/dev/null
        iptables -t mangle -D OUTPUT -m set --match-set "$active_set" dst -j MARK --set-mark "$FWMARK" 2>/dev/null
    fi
    ipset flush "$active_set" 2>/dev/null
    ipset destroy "$active_set" 2>/dev/null
done

# Read ASN list entries (Format: ASN:DEST:SRC_IP)
while IFS=':' read -r asn dest src_ip; do
    [ -z "$asn" ] || [ -z "$dest" ] && continue
    info=$(get_info "$dest")
    [ -z "$info" ] && continue
    
    TABLE=$(echo "$info" | cut -d' ' -f1)
    FWMARK="$(echo "$info" | cut -d' ' -f2)/$(echo "$info" | cut -d' ' -f2)"
    PRIO=$(echo "$info" | cut -d' ' -f3)

    echo "Fetching AS${asn} for ${dest}..."
    fetch_asn_prefixes "$asn"
    
    tmp_file="/tmp/asn_${asn}.txt"
    if [ -s "$tmp_file" ]; then
        asn_cnt=$(wc -l < "$tmp_file" | tr -d ' ')
        echo "${asn}:${dest}:${asn_cnt}" >> "$STATS_FILE"
        
        IPSET_NAME="ASN_${dest}_${asn}"
        ipset create "$IPSET_NAME" hash:net family inet hashsize 1024 maxelem 65536 2>/dev/null
        ipset flush "$IPSET_NAME" 2>/dev/null
        awk -v set="$IPSET_NAME" '{print "add " set " " $1}' "$tmp_file" | ipset restore 2>/dev/null

        if check_iface_up "$dest"; then
            ip rule del fwmark "$FWMARK" 2>/dev/null
            ip rule add from 0/0 fwmark "$FWMARK" table "$TABLE" prio "$PRIO"

            # Apply iptables with or without source IP restriction
            if [ -n "$src_ip" ]; then
                iptables -t mangle -I PREROUTING 1 -s "$src_ip" -m set --match-set "$IPSET_NAME" dst -j MARK --set-mark "$FWMARK"
            else
                iptables -t mangle -I PREROUTING 1 -m set --match-set "$IPSET_NAME" dst -j MARK --set-mark "$FWMARK"
                iptables -t mangle -I OUTPUT 1 -m set --match-set "$IPSET_NAME" dst -j MARK --set-mark "$FWMARK"
            fi
        fi
        rm -f "$tmp_file"
    fi
done < "$ASN_FILE"
WORKER_EOF

    chmod +x "$WORKER_SCRIPT"
    apply_schedule
    return 0
}

while true; do
    show_menu
    read -r opt
    case $opt in
        1)
            clear
            echo -e "${YELLOW}--- Current ASN Routing List (ASN -> Target [Source IP]) ---${NC}\n"
            if [ -s "$ASN_FILE" ]; then
                while IFS=':' read -r asn dest src_ip; do
                    [ -z "$src_ip" ] && src_ip="All Devices (Global)"
                    echo -e " AS${asn} -> ${GREEN}${dest}${NC} [Source: ${CYAN}${src_ip}${NC}]"
                done < "$ASN_FILE"
            else
                echo -e "${RED}List is empty.${NC}"
            fi
            echo "" && echo -n "Press Enter to return..." && read -r _
            ;;
        2)
            clear
            echo -e "${YELLOW}--- Add ASN(s) ---${NC}"
            echo -n "Enter ASN(s) (e.g. 15169 or AS15169, 13335): "
            read -r new_asns
            if [ -n "$new_asns" ]; then
                prompt_destination
                if [ "$SELECTED_DEST" != "CANCEL" ]; then
                    prompt_source_ip
                    clean_asns=$(echo "$new_asns" | tr ',' ' ' | sed -E 's/[Aa][Ss]([0-9]+)/\1/g')
                    for asn in $clean_asns; do
                        case $asn in
                            ''|*[!0-9]*) ;;
                            *)
                                sed -i "/^${asn}:/d" "$ASN_FILE"
                                echo "${asn}:${SELECTED_DEST}:${SELECTED_SRC_IP}" >> "$ASN_FILE"
                                ;;
                        esac
                    done
                    sort -u "$ASN_FILE" -o "$ASN_FILE" 2>/dev/null
                    echo -e "${GREEN}ASN(s) added successfully! Run Option [6] to apply rules.${NC}"
                fi
            fi
            sleep 2
            ;;
        3)
            clear
            echo -e "${YELLOW}--- Find ASN for Domain / IP ---${NC}"
            echo -n "Enter Domain or IP (e.g. github.com): "
            read -r target
            if [ -n "$target" ]; then
                clean_target=$(echo "$target" | sed -E 's#https?://##' | cut -d'/' -f1)
                lookup_ip="$clean_target"
                echo "$clean_target" | grep -q '[^0-9.]' && lookup_ip=$(nslookup "$clean_target" 2>/dev/null | grep -A 20 "Name:" | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n 1)
                if [ -n "$lookup_ip" ]; then
                    asn_info=$(curl -fsSk --connect-timeout 5 "http://ip-api.com/line/$lookup_ip?fields=as")
                    echo -e "Result: ${GREEN}$asn_info${NC}"
                    asn_num=$(echo "$asn_info" | grep -oE '[Aa][Ss][0-9]+|[0-9]+' | head -n 1 | sed -E 's/[Aa][Ss]//g')
                    if [ -n "$asn_num" ]; then
                        echo -n "Add AS$asn_num to your list? (y/n): "
                        read -r add_conf
                        case $add_conf in
                            [Yy]*)
                                prompt_destination
                                [ "$SELECTED_DEST" != "CANCEL" ] && prompt_source_ip
                                [ "$SELECTED_DEST" != "CANCEL" ] && echo "${asn_num}:${SELECTED_DEST}:${SELECTED_SRC_IP}" >> "$ASN_FILE"
                                sort -u "$ASN_FILE" -o "$ASN_FILE" 2>/dev/null
                                echo -e "${GREEN}Added! Run Option [6] to apply rules.${NC}"
                                ;;
                        esac
                    fi
                fi
            fi
            echo "" && echo -n "Press Enter to return..." && read -r _
            ;;
        4) service_presets ;;
        5) remove_menu ;;
        6)
            clear
            echo -e "${YELLOW}--- Rebuilding Worker Script & Applying Rules ---${NC}"
            if rebuild_worker; then
                "$WORKER_SCRIPT"
                echo -e "\n${GREEN}Finished! Rules successfully applied.${NC}"
            fi
            echo "" && echo -n "Press Enter to return..." && read -r _
            ;;
        7)
            clear
            echo -e "${YELLOW}--- ipset Status ---${NC}"
            ipset list -n | grep "^ASN_" | while read -r s; do
                cnt=$(ipset list "$s" 2>/dev/null | grep -E "Number of entries:" | awk '{print $4}')
                echo -e " ${CYAN}$s${NC} -> Subnets: ${GREEN}${cnt:-0}${NC}"
            done
            echo "" && echo -n "Press Enter to return..." && read -r _
            ;;
        8)
            clear
            echo -e "${YELLOW}--- Test IP Routing ---${NC}"
            echo -n "Enter IP to test: " && read -r test_ip
            if [ -n "$test_ip" ]; then
                matched=0
                for s in $(ipset list -n | grep "^ASN_"); do
                    if ipset test "$s" "$test_ip" 2>/dev/null; then
                        echo -e "Matched set: ${GREEN}${s}${NC}"
                        matched=1
                    fi
                done
                [ $matched -eq 0 ] && echo -e "${RED}No ASN match (Follows default routing).${NC}"
            fi
            echo "" && echo -n "Press Enter to return..." && read -r _
            ;;
        9) show_interface_ips ;;
        10)
            clear
            echo -n "Enter Domain/IP for traceroute: " && read -r t_target
            [ -n "$t_target" ] && traceroute -n -m 12 "$t_target"
            echo "" && echo -n "Press Enter to return..." && read -r _
            ;;
        11) update_self ;;
        12) configure_schedule ;;
        13) backup_restore_menu ;;
        14) uninstall_menu ;;
        0) clear; exit 0 ;;
    esac
done
SCRIPT_EOF
