cat << 'SCRIPT_EOF' > /jffs/scripts/ASNmanager.sh && chmod +x /jffs/scripts/ASNmanager.sh && sed -i 's/\r$//' /jffs/scripts/ASNmanager.sh && /jffs/scripts/ASNmanager.sh
#!/bin/sh
# ASN Manager for Asuswrt-Merlin

# Interactive menu only: CLI / WebUI calls (with arguments) must never grab the TTY
[ $# -eq 0 ] && { [ -t 0 ] || exec < /dev/tty 2>/dev/null; }

SCRIPT_VERSION="2.2.1"
SCRIPT_PATH="/jffs/scripts/ASNmanager.sh"
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
[ -t 1 ] || { CYAN=''; GREEN=''; YELLOW=''; RED=''; MAGENTA=''; NC=''; }

# Service presets: one line per preset -> "Name|ASN ASN ..." (single source for menu + WebUI)
PRESET_DATA='Amazon / AWS|16509 14618
Google Services|15169 8075 22577
YouTube|43515 36040
Netflix|2906 40027
Cloudflare|13335 209242
Steam / Valve|32590
Meta / Facebook / IG / WhatsApp|32934 63293
Microsoft / Azure / Xbox|8075 8068 8074 36444
Apple / iCloud|714
Telegram|62041 59930 44907 211157 20473
Akamai CDN|20940 16625
Fastly CDN|54113
PlayStation / Sony|33494 19684 29237
TikTok / ByteDance|138699 396986
Hetzner & OVH Hosting|24940 16276
Disney+ / Hulu|394464
Spotify|8403 45102 23507
Twitch|46489
Riot Games / LoL / Valorant|6507
Epic Games|32252 13488
Nintendo|9003
Zoom|20224 394622
DigitalOcean & Linode|14061 63949
Oracle Cloud|31898
OpenAI / ChatGPT|398324
GitHub|36459 19864
NVIDIA / GeForce NOW|40676
EA / Electronic Arts|29748
Blizzard / Battle.net|57976
Ubisoft|32499'
PRESET_COUNT=$(echo "$PRESET_DATA" | grep -c .)

print_presets() {
    echo "$PRESET_DATA" | awk -F'|' '{ n=split($2,a," "); l=""; for(i=1;i<=n;i++) l=l (i>1?", ":"") "AS" a[i]; printf " [%d]%s %s (%s)\n", NR, (NR<10?" ":""), $1, l }'
}

preset_asns() {
    case "$1" in ''|*[!0-9]*) return 1 ;; esac
    echo "$PRESET_DATA" | sed -n "${1}p" | cut -d'|' -f2
}

ensure_script() {
    # Merlin hook scripts need a shebang and the exec bit
    [ -s "$1" ] || echo '#!/bin/sh' > "$1"
    chmod +x "$1"
}

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

get_target_info() {
    case "$1" in
        WAN|WAN1) echo "254 0x8000 9990" ;;
        WAN2)     echo "253 0x8500 9890" ;;
        OVPN1)    echo "111 0x1000 9991" ;; OVPN2) echo "112 0x2000 9992" ;; OVPN3) echo "113 0x3000 9993" ;; OVPN4) echo "114 0x4000 9994" ;; OVPN5) echo "115 0x5000 9995" ;;
        WGC1)     echo "211 0x6100 9996" ;; WGC2) echo "212 0x6200 9997" ;; WGC3) echo "213 0x6300 9998" ;; WGC4) echo "214 0x6400 9999" ;; WGC5) echo "215 0x6500 10000" ;;
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
    
    # Add cron job to fetch updates via internet
    cru a ASN_Worker "$MIN $HOUR */$INTERVAL * * $WORKER_SCRIPT force"
    
    ensure_script "$SERVICES_START"
    sed -i '/cru [ad] ASN_Worker/d' "$SERVICES_START"
    sed -i '/asn-bypass-worker.sh/d' "$SERVICES_START" 2>/dev/null
    
    # Register the cron job again on boot
    echo "cru a ASN_Worker \"$MIN $HOUR */$INTERVAL * * $WORKER_SCRIPT force\"" >> "$SERVICES_START"
    
    # Let the worker load from cache on every router boot in the background
    echo "$WORKER_SCRIPT boot >/dev/null 2>&1 &" >> "$SERVICES_START"
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
    sleep 2
}

iface_ips_report() {
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
    [ -n "$wan1_dev" ] && ip addr show dev "$wan1_dev" 2>/dev/null | grep -q "inet " && print_ip_info "WAN / WAN1 (${wan1_dev})" "$wan1_dev" "$GREEN" || echo -e " ${RED}[OFFLINE]${NC} WAN / WAN1\n"
    wan2_dev=$(nvram get wan1_ifname 2>/dev/null)
    [ -n "$wan2_dev" ] && ip addr show dev "$wan2_dev" 2>/dev/null | grep -q "inet " && print_ip_info "WAN2 (${wan2_dev})" "$wan2_dev" "$GREEN"

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
}

show_interface_ips() {
    clear
    iface_ips_report
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
            [ -n "$USB_DIRS" ] && set -- $USB_DIRS && BACKUP_DIR="${1}/ASNmanager" && mkdir -p "$BACKUP_DIR"
            ;;
        3)
            FOUND_BACKUPS=$(find /jffs /mnt /tmp/mnt -maxdepth 4 -name "asn_manager_backup_*.conf" 2>/dev/null)
            [ -z "$FOUND_BACKUPS" ] && echo -e "${RED}No backup files found.${NC}" && sleep 2 && return
            i=1
            set -- $FOUND_BACKUPS
            for f in "$@"; do echo -e " [$i] $f"; i=$((i+1)); done
            echo -n "Select backup file to restore [1]: "
            read -r f_sel
            [ -z "$f_sel" ] && f_sel=1
            eval imp_file=\${$f_sel}
            if [ -f "$imp_file" ]; then
                grep -q "\[ASN_LIST\]" "$imp_file" && sed -n '/\[ASN_LIST\]/,/\[SCHEDULE\]/p' "$imp_file" | grep -v '\[.*\]' | grep -v '^$' > "$ASN_FILE" || cp "$imp_file" "$ASN_FILE"
                sort -u "$ASN_FILE" -o "$ASN_FILE" 2>/dev/null
                apply_schedule
                echo -e "\n${GREEN}Configuration restored! Run Option [6] to apply rules.${NC}"
                sleep 3
            fi
            return
            ;;
        *) return ;;
    esac
    BACKUP_FILE="${BACKUP_DIR}/asn_manager_backup_$(date +%Y%m%d_%H%M%S).conf"
    echo "# ASN Manager Backup" > "$BACKUP_FILE"
    echo "[ASN_LIST]" >> "$BACKUP_FILE"
    [ -f "$ASN_FILE" ] && cat "$ASN_FILE" >> "$BACKUP_FILE"
    echo -e "${GREEN}Backup created at:${NC} ${CYAN}$BACKUP_FILE${NC}"
    sleep 2
}

cleanup_rules() {
    for active_set in $(ipset list -n | grep "^ASN_"); do
        dest_name=$(echo "$active_set" | sed -E 's/ASN_([^_]+).*/\1/')
        info=$(get_target_info "$dest_name")
        
        if [ -n "$info" ]; then
            TABLE=$(echo "$info" | cut -d' ' -f1)
            FWMARK_VAL=$(echo "$info" | cut -d' ' -f2)
            FWMARK="${FWMARK_VAL}/${FWMARK_VAL}"
            
            iptables -t mangle -S PREROUTING 2>/dev/null | grep "match-set $active_set " | sed 's/^-A /-D /' | while read -r rule; do
                iptables -t mangle $rule 2>/dev/null
            done
            iptables -t mangle -S OUTPUT 2>/dev/null | grep "match-set $active_set " | sed 's/^-A /-D /' | while read -r rule; do
                iptables -t mangle $rule 2>/dev/null
            done
            
            while ip rule del fwmark "$FWMARK" 2>/dev/null; do :; done
            
            case "$dest_name" in
                OVPN*|WGC*)
                    ip route flush table "$TABLE" 2>/dev/null
                    ;;
            esac
        fi
        
        ipset flush "$active_set" 2>/dev/null
        ipset destroy "$active_set" 2>/dev/null
    done
}

uninstall_menu() {
    clear
    echo -e "${RED}--- Uninstall ASN Manager ---${NC}"
    echo -n "Are you ABSOLUTELY sure you want to completely uninstall ASN Manager? (y/n): "
    read -r final_conf
    case "$final_conf" in
        [Yy]*)
            # Stop the traffic statistics and remove its rules / saved numbers (its rules reference the ASN sets)
            ts_purge >/dev/null 2>&1

            # Clean up kernel iptables rules, ipsets, and ip rules completely
            cleanup_rules
            
            # Remove WebUI page, menu entry and hooks
            webui_uninstall >/dev/null 2>&1

            # Remove cronjob, cache and associated files
            cru d ASN_Worker 2>/dev/null
            sed -i '/cru [ad] ASN_Worker/d' "/jffs/scripts/services-start" 2>/dev/null
            sed -i '/asn-bypass-worker.sh/d' "/jffs/scripts/services-start" 2>/dev/null
            for f in /jffs/scripts/services-start /jffs/scripts/service-event /jffs/scripts/services-stop; do
                [ -f "$f" ] && [ -z "$(grep -v '^#!/bin/sh$' "$f" | grep -v '^[[:space:]]*$')" ] && rm -f "$f"
            done
            rm -f /tmp/asn_[0-9]*.txt /tmp/asn_counts.txt /tmp/asn_progress.txt /tmp/asn_failed.txt /tmp/ASNmanager-*.tmp /tmp/ASNmanager-update.sh 2>/dev/null
            rm -rf "/jffs/scripts/asn_cache" 2>/dev/null
            rm -f "$ASN_FILE" "$SCHEDULE_FILE" "$STATS_FILE" "$WORKER_SCRIPT" "$SCRIPT_PATH" "$SCRIPT_PATH.bak" "$SCRIPT_PATH.new" 2>/dev/null
            
            echo -e "\n${GREEN}ASN Manager successfully uninstalled. All rules, caches, WebUI files and hooks removed.${NC}"
            ls /jffs/asn_manager_backup_*.conf >/dev/null 2>&1 && echo -e "${YELLOW}Backups kept: /jffs/asn_manager_backup_*.conf${NC}"
            exit 0
            ;;
    esac
}

prompt_destination() {
    echo ""
    echo -e "${YELLOW}Select Target Interface for ASN(s):${NC}"
    echo -e " [1]  WAN / WAN1 (Primary Gateway)"
    echo -e " [2]  WAN2 (Secondary Dual-WAN Gateway)"
    echo -e " [3]  OpenVPN Client 1 (OVPN1)"
    echo -e " [4]  OpenVPN Client 2 (OVPN2)"
    echo -e " [5]  OpenVPN Client 3 (OVPN3)"
    echo -e " [6]  OpenVPN Client 4 (OVPN4)"
    echo -e " [7]  OpenVPN Client 5 (OVPN5)"
    echo -e " [8]  WireGuard Client 1 (WGC1)"
    echo -e " [9]  WireGuard Client 2 (WGC2)"
    echo -e " [10] WireGuard Client 3 (WGC3)"
    echo -e " [11] WireGuard Client 4 (WGC4)"
    echo -e " [12] WireGuard Client 5 (WGC5)"
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
    if [ -n "$SELECTED_SRC_IP" ] && ! echo "$SELECTED_SRC_IP" | grep -qE '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$'; then
        echo -e "${RED}Invalid IP format! Applying globally instead.${NC}"
        SELECTED_SRC_IP=""
        sleep 2
    fi
}

service_presets() {
    clear
    echo -e "${YELLOW}--- Add ASN Service Presets ---${NC}"
    print_presets
    echo -e " [0]  Cancel"
    echo ""
    echo -n "Select preset [0-${PRESET_COUNT}]: "
    read -r p_opt
    PRESET_ASNS=$(preset_asns "$p_opt")
    [ -z "$PRESET_ASNS" ] && return

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
    echo -e "${YELLOW}--- Remove ASN or Service Preset ---${NC}"
    echo -e " [1] Remove Individual ASN"
    echo -e " [2] Remove Service Preset"
    echo -e " [3] Clear ALL ASNs & Reset List"
    echo -e " [0] Cancel"
    echo ""
    echo -n "Select option [0-3]: "
    read -r r_opt
    case "$r_opt" in
        1)
            echo -n "Enter ASN number to remove (e.g. 15169): "
            read -r rem_asn
            clean_rem=$(echo "$rem_asn" | sed -E 's/[Aa][Ss]([0-9]+)/\1/g')
            [ -n "$clean_rem" ] && sed -i "/^${clean_rem}:/d" "$ASN_FILE"
            echo -e "${GREEN}ASN removed. Run Option [6] to apply rules.${NC}"
            ;;
        2)
            clear
            echo -e "${YELLOW}--- Remove Service Preset ---${NC}"
            print_presets
            echo -e " [0]  Cancel"
            echo ""
            echo -n "Select preset to remove [0-${PRESET_COUNT}]: "
            read -r p_rem
            REM_ASNS=$(preset_asns "$p_rem")
            [ -z "$REM_ASNS" ] && return
            for asn in $REM_ASNS; do
                sed -i "/^${asn}:/d" "$ASN_FILE"
            done
            echo -e "${GREEN}Preset ASNs removed! Run Option [6] to apply rules.${NC}"
            ;;
        3)
            > "$ASN_FILE"
            > "$STATS_FILE"
            echo -e "${GREEN}All ASNs cleared.${NC}"
            ;;
    esac
    sleep 2
}

is_remote_newer() {
    awk -v cur="$1" -v rem="$2" '
    BEGIN {
        split(cur, c, "."); split(rem, r, ".");
        for (i = 1; i <= 3; i++) {
            c[i] = c[i] + 0; r[i] = r[i] + 0;
            if (r[i] > c[i]) exit 0;
            if (r[i] < c[i]) exit 1;
        }
        exit 1;
    }' 2>/dev/null
}

check_menu_update() {
    UPDATE_NOTICE=""
    TMP_CHECK="/tmp/ASNmanager-menu-check.tmp"
    rm -f "$TMP_CHECK" 2>/dev/null
    FETCH_URL="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/main/ASNmanager.sh"

    if curl -s -S -k --connect-timeout 1 "$FETCH_URL" -o "$TMP_CHECK" && [ -s "$TMP_CHECK" ]; then
        sed -i 's/\r$//' "$TMP_CHECK" 2>/dev/null
        REMOTE_VERSION=$(grep -m 1 "^SCRIPT_VERSION=" "$TMP_CHECK" | cut -d'"' -f2 | tr -d '\r')
        if [ -n "$REMOTE_VERSION" ] && is_remote_newer "$SCRIPT_VERSION" "$REMOTE_VERSION"; then
            UPDATE_NOTICE=" ${GREEN}(New v${REMOTE_VERSION} available!)${NC}"
        fi
    fi
    rm -f "$TMP_CHECK" 2>/dev/null
}

update_self() {
    clear
    echo -e "${YELLOW}--- Updating ASN Manager on GitHub ---${NC}"
    echo -e "Installed Version: ${CYAN}v${SCRIPT_VERSION}${NC}"
    echo -e "${CYAN}Checking GitHub for available script updates...${NC}\n"
    
    TMP_SCRIPT="/tmp/ASNmanager-update.sh"
    rm -f "$TMP_SCRIPT" 2>/dev/null
    FETCH_URL="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/main/ASNmanager.sh"

    if curl -s -S -k --connect-timeout 10 "$FETCH_URL" -o "$TMP_SCRIPT" && [ -s "$TMP_SCRIPT" ]; then
        sed -i 's/\r$//' "$TMP_SCRIPT" 2>/dev/null
        REMOTE_VERSION=$(grep -m 1 "^SCRIPT_VERSION=" "$TMP_SCRIPT" | cut -d'"' -f2 | tr -d '\r')
        if [ "$SCRIPT_VERSION" = "$REMOTE_VERSION" ]; then
            echo -e "${GREEN}You are already running the latest version (v${SCRIPT_VERSION}).${NC}"
        elif is_remote_newer "$SCRIPT_VERSION" "$REMOTE_VERSION"; then
            echo -e "New version available: ${GREEN}v${REMOTE_VERSION}${NC}"
            echo -n "Do you want to update now? (y/n): "
            read -r confirm
            case "$confirm" in
                [Yy]*)
                    # The GitHub file is an installer wrapper (cat << SCRIPT_EOF ...) -> keep only the script body
                    if head -n 1 "$TMP_SCRIPT" | grep -q "^cat << .SCRIPT_EOF."; then
                        sed '1d;/^SCRIPT_EOF$/,$d' "$TMP_SCRIPT" > /jffs/scripts/ASNmanager.sh
                    else
                        cp "$TMP_SCRIPT" /jffs/scripts/ASNmanager.sh
                    fi
                    chmod +x /jffs/scripts/ASNmanager.sh
                    sed -i 's/\r$//' /jffs/scripts/ASNmanager.sh 2>/dev/null
                    rm -f "$TMP_SCRIPT" 2>/dev/null
                    echo -e "\n${GREEN}Update successful! Reloading...${NC}"
                    sleep 1
                    exec /bin/sh /jffs/scripts/ASNmanager.sh
                    ;;
            esac
        else
            echo -e "${GREEN}Your version is newer than GitHub.${NC}"
        fi
    else
        echo -e "${RED}Update check failed! Could not reach GitHub.${NC}"
    fi
    rm -f "$TMP_SCRIPT" 2>/dev/null
    echo "" && echo -n "Press Enter to return..." && read -r _
}

show_menu() {
    clear
    load_schedule
    check_menu_update

    echo -e "${CYAN}================================================================${NC}"
    echo -e "${GREEN}"
    echo -e "  _   ___ _  _   __  __   _   _  _   _   ___ ___  ___ "
    echo -e " /_\\ / __| \\| | |  \\/  | /_\\ | \\| | /_\\ / __| __|| _ \\"
    echo -e "/ _ \\\\__ \\ .' | | |\\/| |/ _ \\| .' |/ _ \\ (_ | _| |   /"
    echo -e "/_/ \\_\\___/_|\\_| |_|  |_/_/ \\_\\_|\\_/_/ \\_\\___|___||_|_\\"
    echo -e "${NC}"
    echo -e "${YELLOW}              === ASN MANAGER v${SCRIPT_VERSION} ===${NC}"
    echo -e "${CYAN}================================================================${NC}"
    echo -e " [1]  View current ASN list & routing targets"
    echo -e " [2]  Add ASN(s) with Target Interface & Source IP"
    echo -e " [3]  Find ASN for Domain / IP (Find, Add & Delete)"
    echo -e " [4]  Add ASN Service Presets (AWS, Netflix, Gaming, Streaming...)"
    echo -e " [5]  Remove ASN or Service Preset"
    echo -e " [6]  Build & Apply New Routing Rules (Split @ 3000 max)"
    echo -e " [7]  Check ipset Status & Per-ASN Subnet Count"
    echo -e " [8]  Test IP or Domain Routing"
    echo -e " [9]  Show active interface IP addresses & countries"
    echo -e " [10] Run Traceroute to IP or Domain"
    echo -e " [11] Update ASN Manager on GitHub${UPDATE_NOTICE}"
    echo -e " [12] Set ASN IP Subnet Auto-Refresh Schedule (Every ${INTERVAL}d @ ${TIME_VAL})"
    echo -e " [13] Backup & Restore Configuration (Internal / USB)"
    echo -e " [14] Uninstall ASN Manager"
    webui_enabled && WEBUI_STATE="${GREEN}Enabled${NC}" || WEBUI_STATE="${RED}Disabled${NC}"
    echo -e " [15] WebUI Tab (${WEBUI_STATE})"
    echo -e " [0]  Exit"
    echo -e "${CYAN}----------------------------------------------------------------${NC}"
    echo -n "Select an option [0-15]: "
}

rebuild_worker() {
    if [ ! -s "$ASN_FILE" ]; then
        echo -e "${RED}Error: ASN list is empty. Add ASNs first.${NC}"
        return 1
    fi

    cat << 'WORKER_EOF' > "$WORKER_SCRIPT"
#!/bin/sh
ASN_FILE="/jffs/scripts/asn_list.txt"
STATS_FILE="/tmp/asn_counts.txt"
CACHE_DIR="/jffs/scripts/asn_cache"
EXEC_MODE="$1"

mkdir -p "$CACHE_DIR"

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

[ ! -s "$ASN_FILE" ] && exit 0

# Better DNS & Internet check for boot
n=0
until ping -c 1 -W 2 github.com >/dev/null 2>&1 || ping -c 1 -W 2 google.com >/dev/null 2>&1; do
    n=$((n+1)); [ $n -ge 45 ] && break; sleep 2
done

> "$STATS_FILE"
> /tmp/asn_failed.txt
ASN_TOTAL=$(grep -c ':' "$ASN_FILE")
ASN_NUM=0
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
    cache_file="$CACHE_DIR/${asn}.txt"
    prefixes=""
    
    # Use cache instantly if not forced and cache exists
    if [ "$EXEC_MODE" != "force" ] && [ -s "$cache_file" ]; then
        cp "$cache_file" "$tmp_file"
        return
    fi

    if [ "$asn" = "16509" ] || [ "$asn" = "14618" ]; then
        prefixes=$(curl -fsSk --connect-timeout 6 -m 10 "https://ip-ranges.amazonaws.com/ip-ranges.json" 2>/dev/null | grep -oE '"ip_prefix": "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}"' | cut -d'"' -f4 | sort -u)
    fi
    [ -z "$prefixes" ] && prefixes=$(curl -fsSk --connect-timeout 6 -m 10 "https://raw.githubusercontent.com/ipverse/asn-ip/master/as/${asn}/ipv4-aggregated.cidr" 2>/dev/null | grep -E '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}$' | sort -u)
    [ -z "$prefixes" ] && prefixes=$(curl -fsSk --connect-timeout 8 -m 25 -A "Mozilla/5.0" "https://stat.ripe.net/data/announced-prefixes/data.json?resource=AS${asn}" 2>/dev/null | tr ',' '\n' | grep -oE '"prefix":"[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}"' | cut -d'"' -f4 | sort -u)
    [ -z "$prefixes" ] && prefixes=$(curl -fsSk --connect-timeout 6 -m 10 -A "Mozilla/5.0" "https://api.hackertarget.com/aslookup/?q=AS${asn}" 2>/dev/null | grep -E '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}$' | sort -u)
    [ -z "$prefixes" ] && prefixes=$(curl -fsSk --connect-timeout 6 -m 10 -A "Mozilla/5.0" "https://api.bgpview.io/asn/${asn}/prefixes" 2>/dev/null | tr ',' '\n' | grep -oE '"prefix":"[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}"' | cut -d'"' -f4 | sort -u)
    
    if [ -n "$prefixes" ]; then
        echo "$prefixes" > "$tmp_file"
        cp "$tmp_file" "$cache_file" 2>/dev/null
    elif [ -s "$cache_file" ]; then
        # Fallback to cache if download failed to prevent 0 subnets
        cp "$cache_file" "$tmp_file"
    else
        > "$tmp_file"
    fi
}

# Clean up before building
for active_set in $(ipset list -n | grep "^ASN_"); do
    dest_name=$(echo "$active_set" | sed -E 's/ASN_([^_]+).*/\1/')
    info=$(get_info "$dest_name")
    
    if [ -n "$info" ]; then
        TABLE=$(echo "$info" | cut -d' ' -f1)
        FWMARK_VAL=$(echo "$info" | cut -d' ' -f2)
        FWMARK="${FWMARK_VAL}/${FWMARK_VAL}"
        
        iptables -t mangle -S PREROUTING 2>/dev/null | grep "match-set $active_set " | sed 's/^-A /-D /' | while read -r rule; do
            iptables -t mangle $rule 2>/dev/null
        done
        iptables -t mangle -S OUTPUT 2>/dev/null | grep "match-set $active_set " | sed 's/^-A /-D /' | while read -r rule; do
            iptables -t mangle $rule 2>/dev/null
        done
        
        while ip rule del fwmark "$FWMARK" 2>/dev/null; do :; done
        
        case "$dest_name" in
            OVPN*|WGC*)
                ip route flush table "$TABLE" 2>/dev/null
                ;;
        esac
    fi
    
    ipset flush "$active_set" 2>/dev/null
    ipset destroy "$active_set" 2>/dev/null
done

[ "$EXEC_MODE" = "force" ] && echo -e "${YELLOW}Downloading fresh ASN data from internet...${NC}" || echo -e "${YELLOW}Restoring ASN data from local cache...${NC}"

while IFS=':' read -r asn dest src_ip; do
    [ -z "$asn" ] || [ -z "$dest" ] && continue
    info=$(get_info "$dest")
    [ -z "$info" ] && continue
    ASN_NUM=$((ASN_NUM + 1))
    echo "$ASN_NUM $ASN_TOTAL $asn $dest" > /tmp/asn_progress.txt
    TABLE=$(echo "$info" | cut -d' ' -f1)
    FWMARK_VAL=$(echo "$info" | cut -d' ' -f2)
    FWMARK="${FWMARK_VAL}/${FWMARK_VAL}"
    PRIO=$(echo "$info" | cut -d' ' -f3)

    fetch_asn_prefixes "$asn"
    tmp_file="/tmp/asn_${asn}.txt"
    
    src_text=""
    [ -n "$src_ip" ] && src_text=" [Src: ${src_ip}]"

    if [ -s "$tmp_file" ]; then
        asn_cnt=$(wc -l < "$tmp_file" | tr -d ' ')
        echo "${asn}:${dest}:${asn_cnt}" >> "$STATS_FILE"
        IPSET_NAME="ASN_${dest}_${asn}"
        ipset create "$IPSET_NAME" hash:net family inet hashsize 1024 maxelem 65536 2>/dev/null
        ipset flush "$IPSET_NAME" 2>/dev/null
        awk -v set="$IPSET_NAME" '{print "add " set " " $1}' "$tmp_file" | ipset restore 2>/dev/null

        if check_iface_up "$dest"; then
            iface_dev=$(get_ifname "$dest")
            
            while ip rule del fwmark "$FWMARK" 2>/dev/null; do :; done
            ip rule add from 0/0 fwmark "$FWMARK" table "$TABLE" prio "$PRIO"
            
            if [ -n "$iface_dev" ]; then
                case "$dest" in
                    OVPN*|WGC*)
                        ip route show table "$TABLE" 2>/dev/null | grep -q "^default" || ip route add default dev "$iface_dev" table "$TABLE" 2>/dev/null
                        ;;
                esac
            fi
            
            if [ -n "$src_ip" ]; then
                iptables -t mangle -I PREROUTING 1 -s "$src_ip" -m set --match-set "$IPSET_NAME" dst -j MARK --set-mark "$FWMARK"
            else
                iptables -t mangle -I PREROUTING 1 -m set --match-set "$IPSET_NAME" dst -j MARK --set-mark "$FWMARK"
                iptables -t mangle -I OUTPUT 1 -m set --match-set "$IPSET_NAME" dst -j MARK --set-mark "$FWMARK"
            fi
        fi
        
        [ -t 1 ] && echo -e " ${GREEN}[OK]${NC} AS${asn} -> ${dest}${src_text} ${CYAN}(${asn_cnt} subnets)${NC}"
        rm -f "$tmp_file"
        
        # Prevent API Ban: Sleep 1 sec between downloads (only in force mode)
        [ "$EXEC_MODE" = "force" ] && sleep 1
    else
        [ -t 1 ] && echo -e " ${RED}[FAIL]${NC} AS${asn} -> ${dest}${src_text} ${RED}(0 subnets found)${NC}"
        echo "${asn}:${dest}" >> /tmp/asn_failed.txt
    fi
done < "$ASN_FILE"
rm -f /tmp/asn_progress.txt
WORKER_EOF

    chmod +x "$WORKER_SCRIPT"
    apply_schedule
    return 0
}

# =====================================================================
#  Non-interactive CLI + Merlin WebUI (router tab)
# =====================================================================
# Namespace for WebUI files, service events and settings keys
WEBUI_NS="asnmanager"
ADDON_DIR="/jffs/addons/${WEBUI_NS}"
WEBUI_SRC="$ADDON_DIR/ASNmanager.asp"
WEBUI_TAB="ASN Manager"
WEBUI_MARK="ASNmanager-WebUI"
WEB_DIR="/www/ext/${WEBUI_NS}"
SERVICE_EVENT="/jffs/scripts/service-event"
SETTINGS_FILE="/jffs/addons/custom_settings.txt"
LOCK_DIR="/tmp/${WEBUI_NS}-job.lock"
ASP_URL="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/main/ASNmanager.asp"
VALID_DESTS="WAN1 WAN2 OVPN1 OVPN2 OVPN3 OVPN4 OVPN5 WGC1 WGC2 WGC3 WGC4 WGC5"

# ---------- validation ----------
is_valid_dest() { case " $VALID_DESTS " in *" $1 "*) return 0 ;; esac; return 1; }

is_valid_ip() {
    echo "$1" | grep -qE '^([0-9]{1,3}\.){3}[0-9]{1,3}$' || return 1
    echo "$1" | awk -F. '{ for (i = 1; i <= 4; i++) if ($i > 255) exit 1 }'
}

is_valid_host() { echo "$1" | grep -qE '^[A-Za-z0-9][A-Za-z0-9.-]{0,252}$'; }

norm_asn() {
    a=$(echo "$1" | sed -E 's/^[Aa][Ss]//; s/^0+//')
    case "$a" in ''|*[!0-9]*) return 1 ;; esac
    [ ${#a} -le 10 ] || return 1
    echo "$a"
}

norm_dest() {
    d=$(echo "$1" | tr 'a-z' 'A-Z')
    [ "$d" = "WAN" ] && d="WAN1"
    is_valid_dest "$d" && echo "$d"
}

mark_applied() { mkdir -p "$ADDON_DIR" && date +%s > "$ADDON_DIR/last_apply"; rm -f "$ADDON_DIR/pending"; }
mark_pending() {
    mkdir -p "$ADDON_DIR" || return
    if [ $# -gt 0 ]; then printf '%s\n' "$@"; else echo "-"; fi >> "$ADDON_DIR/pending"
}

# ---------- reusable reports ----------
ipset_status_report() {
    echo -e "${YELLOW}--- ipset Status ---${NC}"
    for s in $(ipset list -n 2>/dev/null | grep "^ASN_"); do
        dest_name=$(echo "$s" | sed -E 's/ASN_([^_]+).*/\1/')
        check_iface_up "$dest_name" && IF_STATUS="${GREEN}[ONLINE]${NC}" || IF_STATUS="${RED}[OFFLINE]${NC}"
        ENTRY_COUNT=$(ipset list "$s" 2>/dev/null | grep -E "Number of entries:" | awk '{print $4}')
        echo -e "${CYAN}$s${NC} ($dest_name) -> Subnets: ${GREEN}${ENTRY_COUNT:-0}${NC} $IF_STATUS"
    done
}

route_test() {
    target="$1"
    if is_valid_ip "$target"; then
        ips="$target"
    else
        ips=$(nslookup "$target" 2>/dev/null | grep -A 20 "Name:" | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}')
        [ -z "$ips" ] && { echo -e "${RED}Could not resolve ${target}${NC}"; return 1; }
    fi
    for test_ip in $ips; do
        matched=0
        for s in $(ipset list -n 2>/dev/null | grep "^ASN_"); do
            if ipset test "$s" "$test_ip" 2>/dev/null; then
                dest_name=$(echo "$s" | sed -E 's/ASN_([^_]+).*/\1/')
                echo -e "${GREEN}MATCHED:${NC} $test_ip -> Routes to ${dest_name} (${s})"
                matched=1; break
            fi
        done
        [ $matched -eq 0 ] && echo -e "${RED}DEFAULT ROUTE:${NC} $test_ip -> Normal router routing"
    done
    return 0
}

# ---------- CLI actions ----------
cli_list() {
    [ -s "$ASN_FILE" ] || { echo "ASN list is empty."; return 0; }
    while IFS=':' read -r asn dest src_ip; do
        [ -z "$asn" ] && continue
        printf "AS%-10s -> %-6s %s\n" "$asn" "$dest" "${src_ip:+[Src: $src_ip]}"
    done < "$ASN_FILE"
}

# add <TARGET> <ASN> [ASN ...] [--src IP]
cli_add() {
    dest=$(norm_dest "$1") || { echo "Invalid target '$1' (use: $VALID_DESTS)"; return 1; }
    shift
    src=""; asns=""
    while [ $# -gt 0 ]; do
        case "$1" in
            --src) src="$2"; shift; [ $# -gt 0 ] && shift ;;
            *) asns="$asns $1"; shift ;;
        esac
    done
    if [ -n "$src" ] && ! is_valid_ip "$src"; then echo "Invalid source IP '$src'"; return 1; fi
    n=0; added=""
    for raw in $(echo "$asns" | tr ',;' '  '); do
        asn=$(norm_asn "$raw") || { echo "Skipping invalid ASN '$raw'"; continue; }
        sed -i "/^${asn}:/d" "$ASN_FILE"
        echo "${asn}:${dest}:${src}" >> "$ASN_FILE"
        n=$((n + 1)); added="$added $asn"
    done
    sort -u "$ASN_FILE" -o "$ASN_FILE" 2>/dev/null
    [ $n -gt 0 ] || { echo "No valid ASN given."; return 1; }
    mark_pending $added
    echo "Saved $n ASN(s) -> ${dest}${src:+ (Src: $src)}. Apply rules to activate."
}

# preset <NR> <TARGET> [--src IP]
cli_preset() {
    list=$(preset_asns "$1") || { echo "Invalid preset '$1'"; return 1; }
    [ -z "$list" ] && { echo "Invalid preset '$1' (1-${PRESET_COUNT})"; return 1; }
    shift
    d="$1"; shift
    cli_add "$d" $list "$@"
}

# edit <ASN> <TARGET> [SRC-IP]
cli_edit() {
    asn=$(norm_asn "$1") || { echo "Invalid ASN '$1'"; return 1; }
    grep -q "^${asn}:" "$ASN_FILE" || { echo "AS${asn} is not in the list."; return 1; }
    norm_dest "$2" >/dev/null || { echo "Invalid target '$2'"; return 1; }
    if [ -n "$3" ] && ! is_valid_ip "$3"; then echo "Invalid source IP '$3'"; return 1; fi
    if [ -n "$3" ]; then cli_add "$2" "$asn" --src "$3"; else cli_add "$2" "$asn"; fi >/dev/null || { echo "Update failed"; return 1; }
    echo "Updated AS${asn} -> $(norm_dest "$2")${3:+ (Src: $3)}. Apply rules to activate."
}

# import <replace|merge> <ASN:TARGET:SRC>[,...]
cli_import() {
    mode="$1"; [ $# -gt 0 ] && shift
    case "$mode" in replace|merge) ;; *) echo "Mode must be replace or merge"; return 1 ;; esac
    set -f
    list=$(echo "$*" | tr ',;' '  ')
    [ "$mode" = "replace" ] && : > "$ASN_FILE"
    n=0; bad=0; added=""
    for e in $list; do
        asn=$(norm_asn "${e%%:*}") || { bad=$((bad + 1)); continue; }
        rest="${e#*:}"
        [ "$rest" = "$e" ] && { bad=$((bad + 1)); continue; }
        case "$rest" in *:*) src="${rest#*:}"; d="${rest%%:*}" ;; *) src=""; d="$rest" ;; esac
        dest=$(norm_dest "$d") || { bad=$((bad + 1)); continue; }
        if [ -n "$src" ] && ! is_valid_ip "$src"; then bad=$((bad + 1)); continue; fi
        sed -i "/^${asn}:/d" "$ASN_FILE"
        echo "${asn}:${dest}:${src}" >> "$ASN_FILE"
        n=$((n + 1)); added="$added $asn"
    done
    set +f
    sort -u "$ASN_FILE" -o "$ASN_FILE" 2>/dev/null
    mark_pending $added
    skipped=""; [ $bad -gt 0 ] && skipped=", $bad invalid entries skipped"
    echo "Imported $n ASN(s) (${mode})${skipped}. Apply rules to activate."
}

cli_remove() {
    n=0
    for raw in $(echo "$*" | tr ',;' '  '); do
        asn=$(norm_asn "$raw") || continue
        grep -q "^${asn}:" "$ASN_FILE" && n=$((n + 1))
        sed -i "/^${asn}:/d" "$ASN_FILE"
    done
    [ $n -gt 0 ] && mark_pending
    echo "Removed $n ASN(s). Apply rules to activate."
}

cli_clear() {
    > "$ASN_FILE"
    mark_pending
    echo "All ASNs cleared. Apply rules to remove active routing."
}

cli_apply() {
    wmode="force"; [ "$1" = "cache" ] && wmode=""
    if [ ! -s "$ASN_FILE" ]; then
        cleanup_rules
        > "$STATS_FILE"
        mark_applied
        echo "ASN list is empty - all ASN routing rules removed."
        return 0
    fi
    rebuild_worker || return 1
    if [ -n "$wmode" ]; then
        echo "Fetching subnets for $(grep -c . "$ASN_FILE") ASN(s)..."
    else
        echo "Rebuilding rules from cache, downloading only missing ASNs..."
    fi
    rm -f /tmp/asn_progress.txt
    "$WORKER_SCRIPT" $wmode >/dev/null 2>&1 &
    wpid=$!
    while kill -0 "$wpid" 2>/dev/null; do
        if [ -n "$JOB_ID" ] && [ -s /tmp/asn_progress.txt ]; then
            read -r pn pt pasn pdest < /tmp/asn_progress.txt
            case "$pn$pt$pasn" in *[!0-9]*|'') ;; *)
                job_status "$JOB_ID" "$JOB_ACT" "running" "AS${pasn} -> $(echo "$pdest" | tr -cd 'A-Z0-9') (${pn}/${pt})" "$pn" "$pt" ;;
            esac
        fi
        sleep 2
    done
    wait "$wpid" 2>/dev/null
    mark_applied
    ok=0; fail=0
    while IFS=':' read -r asn dest src_ip; do
        [ -z "$asn" ] && continue
        cnt=$(grep "^${asn}:${dest}:" "$STATS_FILE" 2>/dev/null | head -n 1 | cut -d':' -f3)
        if [ -n "$cnt" ]; then
            echo "[OK]   AS${asn} -> ${dest}${src_ip:+ [Src: $src_ip]} (${cnt} subnets)"; ok=$((ok + 1))
        else
            echo "[FAIL] AS${asn} -> ${dest} (0 subnets found)"; fail=$((fail + 1))
        fi
    done < "$ASN_FILE"
    echo "Rules applied: ${ok} OK, ${fail} failed."
}

cli_schedule() {
    case "$1" in ''|*[!0-9]*) echo "Interval must be 1-30 days"; return 1 ;; esac
    [ "$1" -ge 1 ] && [ "$1" -le 30 ] || { echo "Interval must be 1-30 days"; return 1; }
    echo "$2" | grep -qE '^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$' || { echo "Time must be HH:MM (24h)"; return 1; }
    echo "INTERVAL=$1" > "$SCHEDULE_FILE"
    echo "TIME=$2" >> "$SCHEDULE_FILE"
    apply_schedule
    echo "Auto-refresh set: every $1 day(s) at $2."
}

# IPv4 addresses of a name. Ignores 0.0.0.0 / 127.x answers from ad blockers and retries with public DNS.
resolve_ipv4() {
    if is_valid_ip "$1"; then echo "$1"; return 0; fi
    for srv in "" 1.1.1.1 8.8.8.8; do
        r=$(nslookup "$1" $srv 2>/dev/null | awk '/^Name:/ { f = 1; next } f && /Address/' \
            | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | grep -vE '^(0\.|127\.)' | awk '!s[$0]++' | head -n 4)
        [ -n "$r" ] && { echo "$r"; return 0; }
    done
    return 1
}

# "AS<num> <holder>" for an IP, with fallbacks if ip-api.com is unreachable or rate-limited
asn_of_ip() {
    r=$(curl -fsSk --connect-timeout 5 -m 8 "http://ip-api.com/line/$1?fields=as" 2>/dev/null | head -n 1)
    echo "$r" | grep -qE '^AS[0-9]+' || r=$(curl -fsSk --connect-timeout 5 -m 8 "https://ipinfo.io/$1/org" 2>/dev/null | head -n 1)
    if ! echo "$r" | grep -qE '^AS[0-9]+'; then
        n=$(curl -fsSk --connect-timeout 5 -m 10 "https://stat.ripe.net/data/network-info/data.json?resource=$1" 2>/dev/null \
            | grep -oE '"asns": *\[ *"?[0-9]+' | grep -oE '[0-9]+$' | head -n 1)
        [ -n "$n" ] && r="AS$n"
    fi
    echo "$r" | grep -qE '^AS[0-9]+' || return 1
    echo "$r" | tr -cd 'A-Za-z0-9 .,&()+/_-' | cut -c1-80
}

cli_lookup() {
    target=$(echo "$1" | sed -E 's#https?://##' | cut -d'/' -f1 | cut -d':' -f1)
    is_valid_host "$target" || { echo "Invalid domain or IP"; return 1; }
    ips=$(resolve_ipv4 "$target") || { echo "Could not resolve $target"; return 1; }
    found=""
    for ip in $ips; do
        info=$(asn_of_ip "$ip") || { echo "$ip -> lookup failed"; continue; }
        num=$(echo "$info" | grep -oE '^AS[0-9]+' | sed 's/^AS//')
        holder=$(echo "$info" | sed -E 's/^AS[0-9]+ ?//')
        in_list=$(grep "^${num}:" "$ASN_FILE" 2>/dev/null | head -n 1 | cut -d':' -f2)
        echo "$ip -> AS${num} ${holder}${in_list:+ [in list: $in_list]}"
        case " $found " in *" AS$num "*) ;; *) found="$found AS$num" ;; esac
    done
    [ -z "$found" ] && { echo "Lookup failed for $target"; return 1; }
    echo "Result:$found"
}

cli_trace() {
    is_valid_host "$1" || { echo "Invalid domain or IP"; return 1; }
    traceroute -n -m 15 -q 1 -w 2 "$1" 2>&1 &
    tr_pid=$!
    ( sleep 45; kill "$tr_pid" 2>/dev/null ) &
    killer=$!
    wait "$tr_pid"
    kill "$killer" 2>/dev/null
    return 0
}

# ---------- WebUI data export ----------
json_esc() { printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g' | tr -d '\r\n\t'; }

web_export() {
    [ -d "$(dirname "$WEB_DIR")" ] || return 0
    mkdir -p "$WEB_DIR" || return 1
    load_schedule
    sets_tmp="/tmp/asnm_sets.$$"
    fail_tmp="/tmp/asnm_fail.$$"
    pend_tmp="/tmp/asnm_pend.$$"
    ipset list -n 2>/dev/null | grep '^ASN_' > "$sets_tmp"
    [ -f "$STATS_FILE" ] || : > "$STATS_FILE"
    cat /tmp/asn_failed.txt > "$fail_tmp" 2>/dev/null || : > "$fail_tmp"

    last_apply=$(cat "$ADDON_DIR/last_apply" 2>/dev/null); case "$last_apply" in ''|*[!0-9]*) last_apply=0 ;; esac
    # The worker also runs from cron, at boot and from the original menu -> its stats file counts as "applied" too
    stats_mtime=0; [ -s "$STATS_FILE" ] && stats_mtime=$(date -r "$STATS_FILE" +%s 2>/dev/null)
    case "$stats_mtime" in ''|*[!0-9]*) stats_mtime=0 ;; esac
    [ "$stats_mtime" -gt "$last_apply" ] && last_apply=$stats_mtime
    if [ -f "$ADDON_DIR/pending" ]; then
        p_mtime=$(date -r "$ADDON_DIR/pending" +%s 2>/dev/null); case "$p_mtime" in ''|*[!0-9]*) p_mtime=0 ;; esac
        [ "$stats_mtime" -gt "$p_mtime" ] && rm -f "$ADDON_DIR/pending"
    fi
    list_mtime=$(date -r "$ASN_FILE" +%s 2>/dev/null); case "$list_mtime" in ''|*[!0-9]*) list_mtime=0 ;; esac
    pending=0
    if [ -s "$ADDON_DIR/pending" ]; then
        pending=1
    elif [ "$last_apply" -gt 0 ] && [ "$list_mtime" -gt "$last_apply" ]; then
        pending=1
    fi
    cat "$ADDON_DIR/pending" > "$pend_tmp" 2>/dev/null || : > "$pend_tmp"
    cron=0; cru l 2>/dev/null | grep -q "#ASN_Worker#" && cron=1
    worker=0; [ -x "$WORKER_SCRIPT" ] && worker=1

    out="$WEB_DIR/data.js.tmp"
    {
        printf '{"version":"%s","generated":%s,"last_apply":%s,"pending":%s,"cron":%s,"worker":%s,' \
            "$SCRIPT_VERSION" "$(date +%s)" "$last_apply" "$pending" "$cron" "$worker"
        printf '"schedule":{"interval":%s,"time":"%s"},' "$INTERVAL" "$(json_esc "$TIME_VAL")"

        printf '"entries":['
        awk -F':' '
            FILENAME == ARGV[1] { cnt[$1 ":" $2] = $3; next }
            FILENAME == ARGV[2] { sets[$0] = 1; next }
            FILENAME == ARGV[3] { fail[$1 ":" $2] = 1; next }
            FILENAME == ARGV[4] { pend[$1] = 1; next }
            {
                sub(/\r$/, "")
                asn = $1; dest = $2; src = $3
                if (asn !~ /^[0-9]+$/ || length(asn) > 10) next
                if (dest !~ /^(WAN|WAN1|WAN2|OVPN[1-5]|WGC[1-5])$/) next
                if (src !~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/) src = ""
                k = asn ":" dest
                c = (k in cnt) ? cnt[k] + 0 : -1
                l = (("ASN_" dest "_" asn) in sets) ? 1 : 0
                f = ((k in fail) && !(k in cnt)) ? 1 : 0
                nw = (asn in pend) ? 1 : 0
                printf "%s{\"asn\":\"%s\",\"dest\":\"%s\",\"src\":\"%s\",\"subnets\":%d,\"loaded\":%d,\"failed\":%d,\"new\":%d}", (n++ ? "," : ""), asn, dest, src, c, l, f, nw
            }' "$STATS_FILE" "$sets_tmp" "$fail_tmp" "$pend_tmp" "$ASN_FILE"
        printf '],'

        printf '"ifaces":['
        first=1
        for d in $VALID_DESTS; do
            dev=$(get_ifname "$d" | tr -cd 'A-Za-z0-9._-')
            exists=0; [ -n "$dev" ] && ip link show "$dev" >/dev/null 2>&1 && exists=1
            up=0; check_iface_up "$d" && up=1
            [ $first -eq 1 ] && first=0 || printf ','
            printf '{"id":"%s","dev":"%s","exists":%s,"up":%s}' "$d" "$dev" "$exists" "$up"
        done
        printf '],'

        printf '"devices":['
        export_devices
        printf '],'

        printf '"presets":['
        echo "$PRESET_DATA" | awk -F'|' '{ gsub(/["\\]/, "", $1); printf "%s{\"name\":\"%s\",\"asns\":\"%s\"}", (NR > 1 ? "," : ""), $1, $2 }'
        printf ']}\n'
    } > "$out" && mv "$out" "$WEB_DIR/data.js"
    rm -f "$sets_tmp" "$fail_tmp" "$pend_tmp"
    ts_export >/dev/null 2>&1
}

pubip_export() {
    mkdir -p "$WEB_DIR" || return 1
    tmpd="/tmp/asnm_pubip.$$"; mkdir -p "$tmpd"
    for d in $VALID_DESTS; do
        check_iface_up "$d" || continue
        dev=$(get_ifname "$d")
        [ -z "$dev" ] && continue
        (
            ip=$(curl -s -k --interface "$dev" --connect-timeout 4 -m 6 https://api.ipify.org 2>/dev/null)
            is_valid_ip "$ip" || exit 0
            geo=$(curl -s -k --connect-timeout 4 -m 6 "http://ip-api.com/json/$ip?fields=country,countryCode" 2>/dev/null)
            cc=$(echo "$geo" | grep -oE '"countryCode":"[A-Z]{2}"' | cut -d'"' -f4)
            cn=$(echo "$geo" | grep -oE '"country":"[^"]*"' | cut -d'"' -f4 | tr -cd 'A-Za-z .()-' | cut -c1-40)
            # Round flags (circle-flags, MIT) cached on JFFS and delivered inline in pubip.js;
            # the old rectangular PNG from flagcdn.com is only used as a fallback
            flag=0; svg=""
            if [ -n "$cc" ]; then
                lc=$(echo "$cc" | tr 'A-Z' 'a-z')
                fs="$ADDON_DIR/flags/$lc.svg"; fl="$ADDON_DIR/flags/$lc.png"
                mkdir -p "$ADDON_DIR/flags"
                if [ ! -s "$fs" ]; then
                    for u in "https://raw.githubusercontent.com/HatScripts/circle-flags/gh-pages/flags/$lc.svg" \
                             "https://cdn.jsdelivr.net/gh/HatScripts/circle-flags@gh-pages/flags/$lc.svg"; do
                        if curl -fsSk --connect-timeout 5 -m 10 "$u" -o "$fs.tmp" 2>/dev/null && \
                           head -c 5 "$fs.tmp" | grep -q '<svg' && ! grep -qi '<script\|javascript:' "$fs.tmp" && \
                           [ "$(wc -c < "$fs.tmp")" -le 8192 ]; then
                            mv -f "$fs.tmp" "$fs"; break
                        fi
                    done
                    rm -f "$fs.tmp"
                fi
                if [ -s "$fs" ]; then
                    svg=$(tr -d '\r\n\t' < "$fs" | sed 's/\\/\\\\/g; s/"/\\"/g')
                    flag=2
                else
                    if [ ! -s "$fl" ]; then
                        curl -fsSk --connect-timeout 5 -m 10 "https://flagcdn.com/w40/$lc.png" -o "$fl.tmp" 2>/dev/null && \
                            [ -s "$fl.tmp" ] && mv -f "$fl.tmp" "$fl"
                        rm -f "$fl.tmp"
                    fi
                    [ -s "$fl" ] && flag=1
                fi
            fi
            printf '"%s":{"ip":"%s","cc":"%s","country":"%s","flag":%s,"svg":"%s"}' "$d" "$ip" "$cc" "$cn" "$flag" "$svg" > "$tmpd/$d"
        ) &
    done
    wait
    if [ -d "$ADDON_DIR/flags" ]; then
        mkdir -p "$WEB_DIR/flags" && cp -f "$ADDON_DIR/flags/"*.png "$WEB_DIR/flags/" 2>/dev/null
    fi
    {
        printf '{"ts":%s,"ips":{' "$(date +%s)"
        first=1
        for f in "$tmpd"/*; do
            [ -s "$f" ] || continue
            [ $first -eq 1 ] && first=0 || printf ','
            cat "$f"
        done
        printf '}}\n'
    } > "$WEB_DIR/pubip.js.tmp" && mv "$WEB_DIR/pubip.js.tmp" "$WEB_DIR/pubip.js"
    rm -rf "$tmpd"
}

# Devices for the source picker:
#  LAN  - DHCP clients (custom names from the ASUS client list win over DHCP hostnames)
#  WG   - WireGuard server peers (nvram wgs1_cN_*, plus live peers from "wg show")
#  OVPN - connected OpenVPN server clients (status files)
export_devices() {
    {
        nvram get custom_clientlist 2>/dev/null | tr '<' '\n' | awk -F'>' 'NF >= 2 && $2 != "" { print "C|" toupper($2) "||" $1 }'
        nvram get dhcp_hostnames 2>/dev/null | tr '<' '\n' | awk -F'>' 'NF >= 2 && $1 != "" { print "H|" toupper($1) "||" $2 }'
        nvram get dhcp_staticlist 2>/dev/null | tr '<' '\n' | awk -F'>' 'NF >= 2 && $1 != "" { n = $NF; if (n ~ /^[0-9.]*$/) n = ""; print "S|" toupper($1) "|" $2 "|" n }'
        [ -f /var/lib/misc/dnsmasq.leases ] && awk '{ n = $4; if (n == "*") n = ""; print "L|" toupper($2) "|" $3 "|" n }' /var/lib/misc/dnsmasq.leases

        for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16; do
            addr=$(nvram get "wgs1_c${i}_addr" 2>/dev/null)
            [ -z "$addr" ] && continue
            wip=$(echo "$addr" | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n 1)
            [ -n "$wip" ] && echo "W|WGS1C${i}|${wip}|$(nvram get "wgs1_c${i}_name" 2>/dev/null)"
        done
        if command -v wg >/dev/null 2>&1; then
            for wif in $(wg show interfaces 2>/dev/null); do
                case "$wif" in wgs*) ;; *) continue ;; esac
                wg show "$wif" allowed-ips 2>/dev/null | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}/32' | sed 's#/32##' | \
                    while read -r wip; do echo "W|${wif}|${wip}|"; done
            done
        fi

        for st in /etc/openvpn/server*/status; do
            [ -f "$st" ] || continue
            awk -F'[,\t]' '$1 == "CLIENT_LIST" && $4 ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/ { print "O|OVPN|" $4 "|" $2 }' "$st"
        done
    } | awk -F'|' '
        function add(key, ip, nm, kd) {
            if (ip in seen) { if (nm != "" && !(seen[ip] in lname)) lname[seen[ip]] = nm; return }
            seen[ip] = key; order[++cnt] = key; mip[key] = ip; kind[key] = kd
            if (nm != "") lname[key] = nm
        }
        {
            t = $1; id = $2; ip = $3; nm = $4
            gsub(/[^A-Za-z0-9 ._()+-]/, "", nm)
            if (t == "C" || t == "H" || t == "S" || t == "L") { id = toupper(id); gsub(/[^0-9A-F:]/, "", id) }
            if (id == "") next
            if (t == "C") { if (nm != "") cname[id] = nm; next }
            if (t == "H") { if (nm != "") hname[id] = nm; next }
            if (ip !~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/) next
            if (t == "W") { add("W" ip, ip, nm, "wg"); next }
            if (t == "O") { add("O" ip, ip, nm, "ovpn"); next }
            if (id in mac) { if (nm != "" && !(id in lname)) lname[id] = nm; next }
            if (ip in seen) next
            mac[id] = id; add(id, ip, nm, "lan")
        }
        END {
            for (i = 1; i <= cnt; i++) {
                k = order[i]
                n = (k in cname) ? cname[k] : ((k in hname) ? hname[k] : ((k in lname) ? lname[k] : ""))
                printf "%s{\"ip\":\"%s\",\"mac\":\"%s\",\"name\":\"%s\",\"kind\":\"%s\"}", (i > 1 ? "," : ""), mip[k], mac[k], n, kind[k]
            }
        }'
}

job_status() { # id action state msg [done total]
    mkdir -p "$WEB_DIR" 2>/dev/null
    pd="${5:-0}"; ptot="${6:-0}"
    case "$pd$ptot" in *[!0-9]*) pd=0; ptot=0 ;; esac
    printf '{"id":"%s","action":"%s","state":"%s","msg":"%s","done":%s,"total":%s,"ts":%s}\n' \
        "$1" "$2" "$3" "$(json_esc "$4")" "$pd" "$ptot" "$(date +%s)" > "$WEB_DIR/job.js.tmp" && mv "$WEB_DIR/job.js.tmp" "$WEB_DIR/job.js"
}

job_lock() {
    if mkdir "$LOCK_DIR" 2>/dev/null; then echo $$ > "$LOCK_DIR/pid"; return 0; fi
    p=$(cat "$LOCK_DIR/pid" 2>/dev/null)
    [ -n "$p" ] && kill -0 "$p" 2>/dev/null && return 1
    rm -rf "$LOCK_DIR"
    mkdir "$LOCK_DIR" 2>/dev/null && echo $$ > "$LOCK_DIR/pid"
}

# Payload from the WebUI: "<jobid>|<action>|<arg1>|<arg2>|<arg3>"
web_job() {
    set -f
    old_ifs=$IFS; IFS='|'
    set -- $1
    IFS=$old_ifs
    set +f
    id="$1"; act="$2"; a1="$3"; a2="$4"; a3="$5"
    case "$id" in ''|*[!0-9]*) return 1 ;; esac
    case "$act" in ''|*[!a-z]*) return 1 ;; esac

    if ! job_lock; then
        job_status "$id" "$act" "error" "Another ASN Manager job is still running."
        return 1
    fi
    trap 'rm -rf "$LOCK_DIR"' EXIT
    JOB_ID="$id"; JOB_ACT="$act"
    job_status "$id" "$act" "running" ""
    OUT="$WEB_DIR/output.htm"
    : > "$OUT"

    case "$act" in
        add)
            a3=$(echo "$a3" | tr ',' ' ')
            set -f
            if [ -n "$a2" ]; then cli_add "$a1" $a3 --src "$a2"; else cli_add "$a1" $a3; fi > "$OUT" 2>&1
            rc_add=$?; set +f; [ $rc_add -eq 0 ] ;;
        preset)
            if [ -n "$a3" ]; then cli_preset "$a1" "$a2" --src "$a3"; else cli_preset "$a1" "$a2"; fi > "$OUT" 2>&1 ;;
        remove)   cli_remove "$a1" > "$OUT" 2>&1 ;;
        clear)    cli_clear > "$OUT" 2>&1 ;;
        apply)    cli_apply > "$OUT" 2>&1 ;;
        retry)    cli_apply cache > "$OUT" 2>&1 ;;
        edit)     cli_edit "$a1" "$a2" "$a3" > "$OUT" 2>&1 ;;
        import)   cli_import "$a1" "$a2" > "$OUT" 2>&1 ;;
        schedule) cli_schedule "$a1" "$a2" > "$OUT" 2>&1 ;;
        status)   ipset_status_report > "$OUT" 2>&1 ;;
        ifaces)   iface_ips_report > "$OUT" 2>&1 ;;
        lookup)   cli_lookup "$a1" > "$OUT" 2>&1 ;;
        test)     if is_valid_host "$a1"; then route_test "$a1"; else echo "Invalid domain or IP"; false; fi > "$OUT" 2>&1 ;;
        trace)    cli_trace "$a1" > "$OUT" 2>&1 ;;
        refresh)  echo "Data refreshed." > "$OUT" ;;
        update)   cli_update > "$OUT" 2>&1 ;;
        *)        echo "Unknown action '$act'" > "$OUT"; false ;;
    esac
    rc=$?
    esc=$(printf '\033')
    sed -i "s/${esc}\[[0-9;]*m//g" "$OUT"
    web_export
    msg=$(grep . "$OUT" | tail -n 1)
    [ $rc -eq 0 ] && job_status "$id" "$act" "done" "$msg" || job_status "$id" "$act" "error" "${msg:-Failed}"
    rm -rf "$LOCK_DIR"; trap - EXIT
}

# =====================================================================
#  Traffic statistics (per ASN / per client)
#
#  Counting happens in own iptables chains (ASC_*) in mangle/FORWARD; the routing
#  rules of ASN Manager are never touched.
#    FORWARD -o <dev> -j ASC_U_<TARGET>          upload   (LAN -> internet)
#    FORWARD -i <dev> -j ASC_D_<TARGET>          download (internet -> LAN)
#    ASC_U_<TARGET>:        one rule per ASN (-m set --match-set ASN_<TARGET>_<ASN> -g ASC_U_<TARGET>_<ASN>),
#                           last rule = everything else (-g ASC_U_<TARGET>_O)
#    ASC_U_<TARGET>_<ASN|O>: one counting rule per client (-s <ip>/32)
#  "-g" returns to FORWARD, so every packet is counted exactly once.
#
#  Persistence: the totals are saved on the USB stick, in the ASNmanager folder next to the .conf backups
#  (written at most hourly and only if something changed, plus on disable / shutdown). Nothing is written to
#  /jffs. The working copy lives in /tmp/asnmanager-stats/. "Counting is on" = the hook line in services-start.
# =====================================================================
TS_RT="/tmp/${WEBUI_NS}-stats"
TS_LEGACY="$ADDON_DIR/stats"        # v2.1.0 kept the numbers here (flash): migrated to the USB stick once
TS_FILE="asn_manager_traffic_stats.txt"
TS_MOUNTS=${TS_MOUNTS:-/proc/mounts}
TS_HOOK="ASNmanager-Stats"
TS_SERVICES_STOP="/jffs/scripts/services-stop"
TS_INTERVAL=${TS_INTERVAL:-10}
TS_SAVE_EVERY=${TS_SAVE_EVERY:-3600}
TS_MAX=96
TS_TAB=$(printf '\t')

ts_state() { [ -f "$TS_RT/enabled" ] && echo enabled || echo disabled; }
ts_set_state() { mkdir -p "$TS_RT"; if [ "$1" = "enabled" ]; then : > "$TS_RT/enabled"; else rm -f "$TS_RT/enabled"; fi; }
ts_nd() { [ "$1" = "WAN" ] && echo "WAN1" || echo "$1"; }

# lines of file $2 that are not in file $1 (exact match). BusyBox "grep -vxF -f <empty file>" prints nothing,
# GNU grep prints everything - so grep -f is not used for this.
ts_not_in() { awk 'FILENAME == ARGV[1] { s[$0] = 1; next } !($0 in s)' "$1" "$2"; }

# Is this path below a really mounted USB partition? (the leftover mount-point directory of an unplugged stick
# lives in RAM and must never receive the file)
ts_mounted() {
    mp=$(echo "$1" | sed 's#^/mnt/#/tmp/mnt/#' | cut -d/ -f1-4)
    mpe=$(echo "$mp" | sed 's/ /\\040/g')
    [ -n "$mp" ] && grep -qF " $mpe " "$TS_MOUNTS" 2>/dev/null
}

# Folder for the numbers: the ASNmanager folder of the USB stick, next to the .conf backups. Empty result = no USB storage.
# Order: where the numbers already are, where the backups are, first mounted USB partition (same default as the backup menu).
ts_store_dir() {
    if [ -f "$TS_RT/usbdir" ]; then
        d=$(cat "$TS_RT/usbdir")
        ts_mounted "$d" && { echo "$d"; return 0; }
        rm -f "$TS_RT/usbdir"
    fi
    d=$(find /tmp/mnt /mnt -maxdepth 4 -name "$TS_FILE" 2>/dev/null | head -n 1)
    [ -z "$d" ] && d=$(find /tmp/mnt /mnt -maxdepth 4 -name 'asn_manager_backup_*.conf' 2>/dev/null | head -n 1)
    if [ -n "$d" ]; then d=$(dirname "$d")
    else
        d=$(ls -d /tmp/mnt/* 2>/dev/null | grep -v '\*' | head -n 1)
        [ -n "$d" ] && d="$d/ASNmanager"
    fi
    [ -n "$d" ] || return 1
    d=$(echo "$d" | sed 's#^/mnt/#/tmp/mnt/#')
    ts_mounted "$d" || return 1
    mkdir -p "$TS_RT" 2>/dev/null; echo "$d" > "$TS_RT/usbdir"
    echo "$d"
}

# Merges the saved numbers into the working copy - once per boot, as soon as the USB stick is there.
# Saving is only allowed after this, so numbers on the stick are never overwritten by an unmerged copy.
ts_try_load() {
    [ -f "$TS_RT/loaded" ] && return 0
    dir=$(ts_store_dir) || return 1
    f="$dir/$TS_FILE"
    if [ -f "$TS_RT/reset_pending" ]; then            # a reset happened while the stick was missing
        rm -f "$f" "$TS_RT/reset_pending"
    elif [ -s "$f" ]; then
        awk -F'\t' 'NF == 3' "$f" > "$TS_RT/saved.tmp"
        [ -s "$TS_RT/saved.tmp" ] && { ts_sum "$TS_RT/base.txt" "$TS_RT/saved.tmp" > "$TS_RT/base.new" && mv -f "$TS_RT/base.new" "$TS_RT/base.txt"; }
        rm -f "$TS_RT/saved.tmp"
        sv=$(sed -n 's/^# since=//p' "$f" | head -n 1)
        case "$sv" in ''|*[!0-9]*) ;; *)
            cur=$(cat "$TS_RT/since" 2>/dev/null)
            { [ -z "$cur" ] || [ "$sv" -lt "$cur" ]; } && echo "$sv" > "$TS_RT/since" ;;
        esac
    fi
    : > "$TS_RT/loaded"
}

ts_ensure_rt() {
    mkdir -p "$TS_RT" 2>/dev/null
    ts_try_load >/dev/null 2>&1
    return 0
}

ts_lock() {
    mkdir -p "$TS_RT" 2>/dev/null
    i=0
    while ! mkdir "$TS_RT/lock" 2>/dev/null; do
        i=$((i + 1)); [ $i -ge 40 ] && { rm -rf "$TS_RT/lock"; mkdir "$TS_RT/lock" 2>/dev/null; break; }
        sleep 1
    done
}
ts_unlock() { rm -rf "$TS_RT/lock"; }

ts_worker_running() {
    [ -f /tmp/asn_progress.txt ] && return 0
    ps w 2>/dev/null | grep -q '[a]sn-bypass-worker' && return 0
    return 1
}

ts_egress_devs() { for d in $VALID_DESTS; do get_ifname "$d"; done | tr '\n' ' '; }

# Client IPs that get their own counter rule (private addresses only, deduplicated). Sources:
#   1. devices of the WebUI export (LAN, WireGuard / OpenVPN server peers)
#   2. live neighbour table (ARP) of all interfaces except WAN / VPN clients -> devices that just connected
#   3. DHCP leases
ts_client_ips() {
    excl=" $(ts_egress_devs) lo "
    {
        [ -f "$WEB_DIR/data.js" ] && sed -n 's/.*"devices":\[\([^]]*\)\].*/\1/p' "$WEB_DIR/data.js" | grep -oE '"ip":"[0-9]{1,3}(\.[0-9]{1,3}){3}"' | cut -d'"' -f4
        ip -4 neigh show 2>/dev/null | awk -v excl="$excl" '$2 == "dev" && index(excl, " " $3 " ") == 0 && $1 ~ /^[0-9.]+$/ && $0 !~ /FAILED|INCOMPLETE/ { print $1 }'
        [ -f /var/lib/misc/dnsmasq.leases ] && awk '{ print $3 }' /var/lib/misc/dnsmasq.leases
    } 2>/dev/null | awk '/^(10\.|192\.168\.|172\.(1[6-9]|2[0-9]|3[01])\.)/ && !s[$0]++' | head -n "$TS_MAX"
}

# Which network a client IP belongs to (longest matching connected route, WAN / VPN clients excluded).
# Output: "ip<TAB>code"  code = lan | g24 | g5 | g6 | wgs | ovs | dev:<interface>
ts_net_codes() {
    ts_client_ips > "$TS_RT/nets.ips"
    ip route show 2>/dev/null > "$TS_RT/nets.routes"
    awk -v excl=" $(ts_egress_devs) lo " -v b0="$(nvram get wl0_nband 2>/dev/null)" -v b1="$(nvram get wl1_nband 2>/dev/null)" -v b2="$(nvram get wl2_nband 2>/dev/null)" '
        function ip2n(s,   a) { split(s, a, "."); return ((a[1] * 256 + a[2]) * 256 + a[3]) * 256 + a[4] }
        function code(dev,   u, nb) {
            if (dev == "br0") return "lan"
            if (dev ~ /^wgs[0-9]+$/) return "wgs"
            if (dev ~ /^tun2[0-9]+$/) return "ovs"
            if (dev ~ /^wl[0-9]+\.[0-9]+$/) {
                u = dev; sub(/^wl/, "", u); sub(/\..*/, "", u)
                nb = (u == 0) ? b0 : ((u == 1) ? b1 : b2)
                if (nb == "") nb = (u == 0) ? "2" : "1"
                return (nb == "2") ? "g24" : ((nb == "4") ? "g6" : "g5")
            }
            gsub(/[^A-Za-z0-9._-]/, "", dev); return "dev:" dev
        }
        FILENAME == ARGV[1] {
            if ($1 !~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(\/[0-9]+)?$/ || $0 ~ / via /) next
            dev = ""; for (i = 2; i < NF; i++) if ($i == "dev") dev = $(i + 1)
            if (dev == "" || index(excl, " " dev " ") > 0) next
            len = 32; base = $1; if (index($1, "/") > 0) { split($1, p, "/"); base = p[1]; len = p[2] + 0 }
            if (len < 8) next
            q = 1; for (j = 0; j < 32 - len; j++) q *= 2     # 2^(32-len) without "^": BusyBox awk may be built without math support
            n++; rb[n] = ip2n(base); rl[n] = len; rq[n] = q; rd[n] = dev
            next
        }
        {
            v = ip2n($1); best = -1; bl = -1
            for (i = 1; i <= n; i++) if (int(v / rq[i]) == int(rb[i] / rq[i]) && rl[i] > bl) { bl = rl[i]; best = i }
            if (best > 0) printf "%s\t%s\n", $1, code(rd[best])
        }' "$TS_RT/nets.routes" "$TS_RT/nets.ips"
    rm -f "$TS_RT/nets.ips" "$TS_RT/nets.routes"
}

# live counters of our chains -> "dir|TARGET|X|ip<TAB>packets<TAB>bytes"  (X = ASN or O = not assigned; ip empty = row total)
ts_live() {
    iptables-save -t mangle -c 2>/dev/null | awk '
        $2 == "-A" && $3 ~ /^ASC_[UD]_/ {
            cnt = $1; gsub(/[][]/, "", cnt); split(cnt, c, ":")
            n = split($3, p, "_"); tgt = ""; ip = ""
            for (i = 4; i <= NF; i++) { if ($i == "-g" || $i == "-j") tgt = $(i + 1); if ($i == "-s" || $i == "-d") ip = $(i + 1) }
            sub(/\/32$/, "", ip)
            if (n == 3 && tgt ~ /^ASC_[UD]_/) { m = split(tgt, q, "_"); if (m == 4) printf "%s|%s|%s|\t%s\t%s\n", p[2], p[3], q[4], c[1], c[2] }
            else if (n == 4 && ip != "") printf "%s|%s|%s|%s\t%s\t%s\n", p[2], p[3], p[4], ip, c[1], c[2]
        }'
}

# sums counter lines by key; zero lines of clients are dropped, rows ("...|") stay so every ASN is listed
ts_sum() { cat "$@" 2>/dev/null | awk -F'\t' 'NF == 3 { p[$1] += $2; b[$1] += $3 } END { for (k in p) if (p[k] > 0 || b[k] > 0 || k ~ /\|$/) printf "%s\t%.0f\t%.0f\n", k, p[k], b[k] }'; }

ts_bank() { # add counter lines from stdin to the working base file (zero lines are not stored)
    awk -F'\t' 'NF == 3 && ($2 > 0 || $3 > 0)' > "$TS_RT/bank.tmp"
    [ -s "$TS_RT/bank.tmp" ] || { rm -f "$TS_RT/bank.tmp"; return 0; }
    ts_sum "$TS_RT/base.txt" "$TS_RT/bank.tmp" > "$TS_RT/base.new" && mv -f "$TS_RT/base.new" "$TS_RT/base.txt"
    rm -f "$TS_RT/bank.tmp"
}

# ---------- build the wanted rule set (plan.rules / plan.chains / plan.jumps) ----------
ts_build_plan() {
    sets=$(ipset list -n 2>/dev/null | grep '^ASN_')
    clients=$(ts_client_ips)
    : > "$TS_RT/plan.rules"; : > "$TS_RT/plan.chains"; : > "$TS_RT/plan.jumps"

    used=$( [ -f "$ASN_FILE" ] && awk -F':' '$1 ~ /^[0-9]+$/ { d = ($2 == "WAN") ? "WAN1" : $2; print d }' "$ASN_FILE" | sort -u )
    for d in $VALID_DESTS; do
        dev=$(get_ifname "$d")
        [ -z "$dev" ] && continue
        echo " $used " | tr '\n' ' ' | grep -q " $d " || {
            case "$d" in WAN1) ;; *) [ -d "/sys/class/net/$dev" ] || continue ;; esac
        }
        echo "-A FORWARD -o $dev -j ASC_U_$d" >> "$TS_RT/plan.jumps"
        echo "-A FORWARD -i $dev -j ASC_D_$d" >> "$TS_RT/plan.jumps"
        echo "ASC_U_$d" >> "$TS_RT/plan.chains"; echo "ASC_D_$d" >> "$TS_RT/plan.chains"

        # ASN rules of this target in list order (first match wins)
        if [ -f "$ASN_FILE" ]; then
            while IFS=':' read -r asn rdest src; do
                case "$asn" in ''|*[!0-9]*) continue ;; esac
                [ "$(ts_nd "$rdest")" = "$d" ] || continue
                set_name="ASN_${rdest}_${asn}"
                echo "$sets" | grep -qx "$set_name" || continue
                echo "$src" | grep -qE '^[0-9]{1,3}(\.[0-9]{1,3}){3}$' || src=""
                echo "ASC_U_${d}_${asn}" >> "$TS_RT/plan.chains"; echo "ASC_D_${d}_${asn}" >> "$TS_RT/plan.chains"
                if [ -n "$src" ]; then
                    printf 'U|%s|%s|\t-A ASC_U_%s -s %s/32 -m set --match-set %s dst -g ASC_U_%s_%s\n' "$d" "$asn" "$d" "$src" "$set_name" "$d" "$asn"
                    printf 'D|%s|%s|\t-A ASC_D_%s -d %s/32 -m set --match-set %s src -g ASC_D_%s_%s\n' "$d" "$asn" "$d" "$src" "$set_name" "$d" "$asn"
                    printf 'U|%s|%s|%s\t-A ASC_U_%s_%s -s %s/32\n' "$d" "$asn" "$src" "$d" "$asn" "$src"
                    printf 'D|%s|%s|%s\t-A ASC_D_%s_%s -d %s/32\n' "$d" "$asn" "$src" "$d" "$asn" "$src"
                else
                    printf 'U|%s|%s|\t-A ASC_U_%s -m set --match-set %s dst -g ASC_U_%s_%s\n' "$d" "$asn" "$d" "$set_name" "$d" "$asn"
                    printf 'D|%s|%s|\t-A ASC_D_%s -m set --match-set %s src -g ASC_D_%s_%s\n' "$d" "$asn" "$d" "$set_name" "$d" "$asn"
                    for ip in $clients; do
                        printf 'U|%s|%s|%s\t-A ASC_U_%s_%s -s %s/32\n' "$d" "$asn" "$ip" "$d" "$asn" "$ip"
                        printf 'D|%s|%s|%s\t-A ASC_D_%s_%s -d %s/32\n' "$d" "$asn" "$ip" "$d" "$asn" "$ip"
                    done
                fi
            done < "$ASN_FILE" >> "$TS_RT/plan.rules"
        fi

        # everything else on this interface = "not assigned to an ASN"
        echo "ASC_U_${d}_O" >> "$TS_RT/plan.chains"; echo "ASC_D_${d}_O" >> "$TS_RT/plan.chains"
        {
            printf 'U|%s|O|\t-A ASC_U_%s -g ASC_U_%s_O\n' "$d" "$d" "$d"
            printf 'D|%s|O|\t-A ASC_D_%s -g ASC_D_%s_O\n' "$d" "$d" "$d"
            for ip in $clients; do
                printf 'U|%s|O|%s\t-A ASC_U_%s_O -s %s/32\n' "$d" "$ip" "$d" "$ip"
                printf 'D|%s|O|%s\t-A ASC_D_%s_O -d %s/32\n' "$d" "$ip" "$d" "$ip"
            done
        } >> "$TS_RT/plan.rules"
    done
}

# ---------- apply the plan, keep all counters ----------
ts_sync() {
    ts_worker_running && return 1
    ts_ensure_rt
    ts_build_plan
    ts_live > "$TS_RT/live.txt"

    # 1) chains vanished or were reset from outside (e.g. firewall restart): keep the last seen values
    if [ -s "$TS_RT/last_live.txt" ]; then
        awk -F'\t' 'FILENAME == ARGV[1] { lp[$1] = $2; lb[$1] = $3; next } { if (($1 in lp) && $3 >= lb[$1]) delete lb[$1] }
                    END { for (k in lb) printf "%s\t%s\t%s\n", k, lp[k], lb[k] }' "$TS_RT/last_live.txt" "$TS_RT/live.txt" | ts_bank
    fi
    # 2) rules that are no longer wanted (ASN removed, client gone): bank their counters
    awk -F'\t' 'FILENAME == ARGV[1] { want[$1] = 1; next } !($1 in want)' "$TS_RT/plan.rules" "$TS_RT/live.txt" | ts_bank

    # 3) write our chains in one atomic step, existing counters carried over
    {
        echo "*mangle"
        awk '!s[$0]++ { print ":" $0 " - [0:0]" }' "$TS_RT/plan.chains"
        awk -F'\t' 'FILENAME == ARGV[1] { c[$1] = "[" $2 ":" $3 "]"; next } { k = $1; print ((k in c) ? c[k] : "[0:0]") " " $2 }' \
            "$TS_RT/live.txt" "$TS_RT/plan.rules"
        echo "COMMIT"
    } > "$TS_RT/restore.txt"
    if ! iptables-restore -n -c < "$TS_RT/restore.txt" 2>"$TS_RT/restore.err"; then
        echo "iptables-restore failed: $(head -n 2 "$TS_RT/restore.err")"
        return 1
    fi

    # 4) remove FORWARD jumps / chains that are not part of the plan any more
    iptables-save -t mangle 2>/dev/null | grep -E '^-A FORWARD .*-j ASC_[UD]_' > "$TS_RT/jumps.now"
    ts_not_in "$TS_RT/plan.jumps" "$TS_RT/jumps.now" | sed 's/^-A /-D /' | while read -r r; do iptables -t mangle $r 2>/dev/null; done
    iptables-save -t mangle 2>/dev/null | sed -n 's/^:\(ASC_[UD]_[^ ]*\) .*/\1/p' > "$TS_RT/chains.all"
    ts_not_in "$TS_RT/plan.chains" "$TS_RT/chains.all" > "$TS_RT/chains.old"
    while read -r c; do iptables -t mangle -F "$c" 2>/dev/null; done < "$TS_RT/chains.old"
    while read -r c; do iptables -t mangle -X "$c" 2>/dev/null; done < "$TS_RT/chains.old"

    # 5) add missing jumps (position 1: we only count, the packet continues in FORWARD)
    ts_not_in "$TS_RT/jumps.now" "$TS_RT/plan.jumps" | sed 's/^-A FORWARD /-I FORWARD 1 /' | while read -r r; do iptables -t mangle $r; done

    # 6) ASN sets the worker could not destroy because our rules still referenced them
    for s in $(ipset list -n 2>/dev/null | grep '^ASN_'); do
        a=${s##*_}; d=${s#ASN_}; d=${d%_*}
        grep -q "^${a}:${d}:" "$ASN_FILE" 2>/dev/null && continue
        iptables-save 2>/dev/null | grep -q -- "--match-set $s " || ipset destroy "$s" 2>/dev/null
    done

    ts_net_codes > "$TS_RT/nets.txt"
    ts_live > "$TS_RT/last_live.txt"
    rm -f "$TS_RT/live.txt" "$TS_RT/restore.txt" "$TS_RT/restore.err" "$TS_RT/jumps.now" "$TS_RT/chains.old" "$TS_RT/chains.all"
    return 0
}

ts_remove_rules() {
    iptables-save -t mangle 2>/dev/null | grep -E '^-A FORWARD .*-j ASC_[UD]_' | sed 's/^-A /-D /' | while read -r r; do iptables -t mangle $r 2>/dev/null; done
    chains=$(iptables-save -t mangle 2>/dev/null | sed -n 's/^:\(ASC_[UD]_[^ ]*\) .*/\1/p')
    for c in $chains; do iptables -t mangle -F "$c" 2>/dev/null; done
    for c in $chains; do iptables -t mangle -X "$c" 2>/dev/null; done
}

ts_signature() {
    {
        date -r "$ASN_FILE" +%s 2>/dev/null
        ipset list -n 2>/dev/null | grep '^ASN_' | sort
        ts_client_ips | sort
        for d in $VALID_DESTS; do dev=$(get_ifname "$d"); [ -n "$dev" ] && [ -d "/sys/class/net/$dev" ] && echo "$d=$dev"; done
        ip route show 2>/dev/null | md5sum
        iptables -t mangle -S FORWARD 2>/dev/null | grep -c 'ASC_[UD]_'
    } | md5sum | cut -d' ' -f1
}

# ---------- persistence ----------
# Writes base + live counters to the USB stick - only if the content changed. Returns 1 if there is no stick.
ts_save() {
    ts_ensure_rt
    [ -f "$TS_RT/loaded" ] || return 1
    dir=$(ts_store_dir) || return 1
    mkdir -p "$dir" 2>/dev/null || return 1
    if [ "$(ts_state)" = "enabled" ]; then ts_live > "$TS_RT/live.save"; else : > "$TS_RT/live.save"; fi
    ts_sum "$TS_RT/base.txt" "$TS_RT/live.save" | awk -F'\t' '$2 > 0 || $3 > 0' | sort > "$TS_RT/data.new"
    rm -f "$TS_RT/live.save"
    f="$dir/$TS_FILE"
    if [ -s "$TS_RT/data.new" ]; then
        {
            echo "# ASN Manager traffic statistics - do not edit"
            sv=$(cat "$TS_RT/since" 2>/dev/null); [ -n "$sv" ] && echo "# since=$sv"
            cat "$TS_RT/data.new"
        } > "$TS_RT/save.new"
        if ! cmp -s "$TS_RT/save.new" "$f" 2>/dev/null; then
            cp "$TS_RT/save.new" "$f.tmp" 2>/dev/null && mv -f "$f.tmp" "$f" 2>/dev/null || { rm -f "$f.tmp"; rm -f "$TS_RT/data.new" "$TS_RT/save.new"; return 1; }
        fi
    else
        rm -f "$f"
    fi
    rm -f "$TS_RT/data.new" "$TS_RT/save.new"
    return 0
}

ts_hooks_add() {
    ensure_script "$SERVICES_START"
    sed -i "/# ${TS_HOOK}\$/d" "$SERVICES_START"
    echo "$SCRIPT_PATH stats boot >/dev/null 2>&1 & # ${TS_HOOK}" >> "$SERVICES_START"
    ensure_script "$TS_SERVICES_STOP"
    sed -i "/# ${TS_HOOK}\$/d" "$TS_SERVICES_STOP"
    echo "$SCRIPT_PATH stats save >/dev/null 2>&1 # ${TS_HOOK}" >> "$TS_SERVICES_STOP"
}

ts_hooks_del() {
    for f in "$SERVICES_START" "$TS_SERVICES_STOP"; do
        [ -f "$f" ] || continue
        sed -i "/# ${TS_HOOK}\$/d" "$f"
        [ -z "$(grep -v '^#!/bin/sh$' "$f" | grep -v '^[[:space:]]*$')" ] && rm -f "$f"
    done
    return 0
}

# test builds of the statistics (/tmp/asnstats) used the same chain names: stop them so they do not fight with us
# menu start: if counting is enabled but the background loop is gone, start it again
ts_ensure_loop() {
    ts_migrate_legacy
    [ "$(ts_state)" = "enabled" ] || return 0
    p=$(cat "$TS_RT/loop.pid" 2>/dev/null)
    [ -n "$p" ] && kill -0 "$p" 2>/dev/null && return 0
    ts_start_loop
}

ts_legacy_cleanup() {
    if [ -f /tmp/asnstats/loop.pid ]; then
        kill "$(cat /tmp/asnstats/loop.pid 2>/dev/null)" 2>/dev/null
        rm -rf /tmp/asnstats
    fi
    [ -f "$SERVICE_EVENT" ] && sed -i '/# ASNstats-Test$/d' "$SERVICE_EVENT" 2>/dev/null
    return 0
}

# ---------- export for the WebUI (RAM only) ----------
ts_export() {
    [ -d "$(dirname "$WEB_DIR")" ] || return 0
    mkdir -p "$WEB_DIR" 2>/dev/null || return 0
    ts_ensure_rt
    st=$(ts_state); since=$(cat "$TS_RT/since" 2>/dev/null); case "$since" in ''|*[!0-9]*) since=0 ;; esac
    store=$(ts_store_dir 2>/dev/null | tr -cd 'A-Za-z0-9._/ -')
    saved=0; [ -n "$store" ] && saved=$(date -r "$store/$TS_FILE" +%s 2>/dev/null); case "$saved" in ''|*[!0-9]*) saved=0 ;; esac
    [ -f "$TS_RT/nets.txt" ] || ts_net_codes > "$TS_RT/nets.txt"
    nets=$(awk -F'\t' '$2 != "" { printf "%s\"%s\":\"%s\"", (n++ ? "," : ""), $1, $2 }' "$TS_RT/nets.txt" 2>/dev/null)
    if [ "$st" != "enabled" ]; then : > "$TS_RT/live.out"
    elif [ "$1" = "reuse" ] && [ -f "$TS_RT/last_live.txt" ]; then cp "$TS_RT/last_live.txt" "$TS_RT/live.out"   # loop: counters were just read
    else ts_live > "$TS_RT/live.out"; fi
    ts_sum "$TS_RT/base.txt" "$TS_RT/live.out" | sort | awk -F'\t' -v ts="$(date +%s)" -v st="$st" -v since="$since" -v saved="$saved" -v store="$store" -v iv="$TS_INTERVAL" -v nets="$nets" '
        {
            split($1, k, "|"); d = k[1]; dest = k[2]; x = k[3]; ip = k[4]
            if (dest !~ /^[A-Z0-9]+$/ || x !~ /^([0-9]+|O)$/) next
            id = dest "|" x
            if (!(id in seen)) { seen[id] = 1; order[++n] = id }
            if (ip == "") { if (d == "U") { ub[id] += $3; up[id] += $2 } else { db[id] += $3; dp[id] += $2 } ; next }
            if (ip !~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/) next
            cid = id "|" ip
            if (!(cid in cs)) { cs[cid] = 1; cl[id] = cl[id] " " ip }
            if (d == "U") { cub[cid] += $3; cup[cid] += $2 } else { cdb[cid] += $3; cdp[cid] += $2 }
        }
        END {
            printf "{\"ts\":%s,\"state\":\"%s\",\"since\":%s,\"saved\":%s,\"store\":\"%s\",\"interval\":%s,\"nets\":{%s},\"rows\":[", ts, st, since, saved, store, iv, nets
            for (i = 1; i <= n; i++) {
                id = order[i]; split(id, q, "|")
                printf "%s{\"dest\":\"%s\",\"asn\":\"%s\",\"ub\":%.0f,\"up\":%.0f,\"db\":%.0f,\"dp\":%.0f,\"cl\":[", (i > 1 ? "," : ""), q[1], q[2], ub[id], up[id], db[id], dp[id]
                m = split(cl[id], ips, " "); f = 0
                for (j = 1; j <= m; j++) {
                    cid = id "|" ips[j]
                    if (cub[cid] + cdb[cid] <= 0) continue
                    printf "%s[\"%s\",%.0f,%.0f,%.0f,%.0f]", (f++ ? "," : ""), ips[j], cub[cid], cup[cid], cdb[cid], cdp[cid]
                }
                printf "]}"
            }
            printf "]}\n"
        }' > "$WEB_DIR/stats.js.tmp" && mv -f "$WEB_DIR/stats.js.tmp" "$WEB_DIR/stats.js"
    rm -f "$TS_RT/live.out"
}

# ---------- background loop: follows ASN / client / interface changes, refreshes stats.js, saves hourly ----------
ts_loop() {
    mkdir -p "$TS_RT"
    echo $$ > "$TS_RT/loop.pid"
    last_save=$(date +%s)
    while [ "$(ts_state)" = "enabled" ] && [ "$(cat "$TS_RT/loop.pid" 2>/dev/null)" = "$$" ]; do
        sig=$(ts_signature)
        if [ "$sig" != "$(cat "$TS_RT/sig" 2>/dev/null)" ]; then
            ts_lock; ts_sync >/dev/null 2>&1 && echo "$sig" > "$TS_RT/sig"; ts_unlock
        else
            ts_live > "$TS_RT/last_live.txt"
        fi
        ts_export reuse
        now=$(date +%s)
        if [ $((now - last_save)) -ge "$TS_SAVE_EVERY" ]; then ts_save; last_save=$now; fi
        sleep "$TS_INTERVAL"
    done
}

ts_stop_loop() {
    p=$(cat "$TS_RT/loop.pid" 2>/dev/null); rm -f "$TS_RT/loop.pid"
    [ -n "$p" ] && kill "$p" 2>/dev/null
    return 0
}

# The loop must survive the end of an SSH session (terminal hangup sends SIGHUP to the whole process group)
ts_start_loop() { ts_stop_loop; ( trap '' HUP; exec "$SCRIPT_PATH" stats loop </dev/null >/dev/null 2>&1 ) & }

# ---------- actions ----------
ts_enable() {
    ts_legacy_cleanup
    ts_ensure_rt
    ts_set_state enabled
    [ -s "$TS_RT/since" ] || date +%s > "$TS_RT/since"
    ts_lock
    rm -f "$TS_RT/sig"
    i=0; while ts_worker_running && [ $i -lt 120 ]; do sleep 2; i=$((i + 1)); done
    ts_sync; rc=$?
    ts_signature > "$TS_RT/sig"
    ts_unlock
    ts_hooks_add
    ts_start_loop
    ts_export
    [ $rc -eq 0 ] && echo "Traffic statistics enabled." || echo "Traffic statistics enabled, but the rule setup reported an error."
}

ts_disable() {
    ts_ensure_rt; ts_lock
    ts_set_state disabled
    ts_stop_loop
    ts_live | ts_bank            # keep the numbers
    ts_remove_rules
    rm -f "$TS_RT/last_live.txt" "$TS_RT/sig"
    ts_unlock
    ts_hooks_del
    if ts_save; then echo "Traffic statistics disabled, numbers kept and saved on the USB stick."
    else echo "Traffic statistics disabled, numbers kept in RAM (no USB storage found: not saved)."; fi
    ts_export
}

ts_reset() {
    ts_ensure_rt; ts_lock
    ts_set_state disabled
    ts_stop_loop
    ts_remove_rules
    rm -f "$TS_RT/base.txt" "$TS_RT/last_live.txt" "$TS_RT/sig" "$TS_RT/since"
    d=$(ts_store_dir)
    if [ -n "$d" ]; then
        rm -f "$d/$TS_FILE" "$TS_RT/reset_pending"; : > "$TS_RT/loaded"
    else                                            # stick missing: delete the file as soon as it is back
        : > "$TS_RT/reset_pending"; rm -f "$TS_RT/loaded"
    fi
    rm -rf "$TS_LEGACY"
    ts_unlock
    ts_hooks_del
    ts_export
    echo "Traffic statistics disabled and reset."
}

# v2.1.0 kept state and numbers in /jffs/addons/asnmanager/stats: take them over, then remove that folder
ts_migrate_legacy() {
    [ -f "$TS_LEGACY/state" ] || [ -f "$TS_LEGACY/base.txt" ] || return 0
    mkdir -p "$TS_RT"
    if [ ! -f "$TS_RT/legacy_done" ]; then
        # After a reboot the working copy is empty: take the saved numbers. While the router kept running since the update,
        # the working copy of the old version already holds everything (merging would count the live numbers twice).
        if [ ! -f "$TS_RT/session" ]; then
            awk -F'\t' 'NF == 3' "$TS_LEGACY/base.txt" > "$TS_RT/legacy.tmp" 2>/dev/null
            [ -s "$TS_RT/legacy.tmp" ] && { ts_sum "$TS_RT/base.txt" "$TS_RT/legacy.tmp" > "$TS_RT/base.new" && mv -f "$TS_RT/base.new" "$TS_RT/base.txt"; }
            rm -f "$TS_RT/legacy.tmp"
            lsince=$(cat "$TS_LEGACY/since" 2>/dev/null); [ -n "$lsince" ] && [ ! -s "$TS_RT/since" ] && echo "$lsince" > "$TS_RT/since"
        fi
        : > "$TS_RT/legacy_done"
        if [ "$(cat "$TS_LEGACY/state" 2>/dev/null)" = "enabled" ]; then
            ts_set_state enabled
            ts_start_loop            # replaces the loop of the old version
        fi
    fi
    ts_save && rm -rf "$TS_LEGACY"   # remove the old folder only when the numbers are on the stick
}

# router start (services-start): resume counting if it was enabled (the hook line only exists while it is enabled)
ts_boot() {
    ts_legacy_cleanup
    ts_ensure_rt
    ts_migrate_legacy
    grep -q "# ${TS_HOOK}\$" "$SERVICES_START" 2>/dev/null || return 0
    ts_set_state enabled
    ts_start_loop
}

# complete removal (uninstall); the .conf backups on the stick are left alone
ts_purge() {
    ts_stop_loop
    ts_remove_rules
    ts_hooks_del
    d=$(ts_store_dir 2>/dev/null); [ -n "$d" ] && rm -f "$d/$TS_FILE"
    rm -rf "$TS_RT" "$TS_LEGACY" "$WEB_DIR/stats.js"
    ts_legacy_cleanup
    return 0
}

ts_human() { awk -v b="$1" 'BEGIN { split("B KB MB GB TB", u, " "); i = 1; while (b >= 1024 && i < 5) { b /= 1024; i++ }; fmt = (i == 1) ? "%d %s" : "%.2f %s"; printf fmt, b, u[i] }'; }

ts_show() {
    ts_ensure_rt
    if [ "$(ts_state)" = "enabled" ]; then ts_live > "$TS_RT/live.out"; else : > "$TS_RT/live.out"; fi
    echo "Traffic statistics: $(ts_state)"
    ts_sum "$TS_RT/base.txt" "$TS_RT/live.out" | awk -F'\t' '$1 ~ /\|$/ { split($1, k, "|"); id = k[2] " " (k[3] == "O" ? "not-assigned" : "AS" k[3]); if (k[1] == "U") u[id] += $3; else d[id] += $3; s[id] = 1 }
        END { for (i in s) printf "%s\t%.0f\t%.0f\n", i, d[i], u[i] }' | sort | while IFS="$TS_TAB" read -r id dn upb; do
            printf "  %-24s down %12s   up %12s\n" "$id" "$(ts_human "$dn")" "$(ts_human "$upb")"
        done
    rm -f "$TS_RT/live.out"
}

ts_unknown() {
    [ -r /proc/net/nf_conntrack ] || { echo "conntrack table not readable"; return 1; }
    known=$(ts_client_ips | tr '\n' ' ')
    mine=$(ip -4 addr show 2>/dev/null | awk '$1 == "inet" { sub(/\/.*/, "", $2); print $2 }' | tr '\n' ' ')
    echo "Private source addresses in the connection table that have no counter rule:"
    awk -v known=" $known $mine " '
        { ip = ""; for (i = 1; i <= NF; i++) if ($i ~ /^src=/) { ip = substr($i, 5); break }
          if (ip ~ /^(10\.|192\.168\.|172\.(1[6-9]|2[0-9]|3[01])\.)/ && index(known, " " ip " ") == 0) c[ip]++ }
        END { for (k in c) print c[k], k }' /proc/net/nf_conntrack | sort -rn | head -n 20 | while read -r n ip; do
        mac=$(ip -4 neigh show "$ip" 2>/dev/null | awk '{ for (i = 1; i < NF; i++) if ($i == "lladdr") print $(i + 1) }' | head -n 1)
        nm=$( [ -f /var/lib/misc/dnsmasq.leases ] && awk -v ip="$ip" '$3 == ip && $4 != "*" { print $4 }' /var/lib/misc/dnsmasq.leases | head -n 1)
        printf '  %-16s %4s connection(s)   MAC %-17s %s\n' "$ip" "$n" "${mac:--}" "${nm}"
    done
    echo "(an empty list means every active device already has its own counter rule)"
}

ts_probe() {
    echo "== ASN Manager traffic statistics - probe"
    printf '*mangle\n:ASC_PROBE - [0:0]\n[7:700] -A ASC_PROBE -s 127.0.0.2/32\nCOMMIT\n' | iptables-restore -n -c 2>/dev/null
    if iptables-save -t mangle -c 2>/dev/null | grep -q '^\[7:700\] -A ASC_PROBE'; then echo "[OK]   iptables-restore -n -c keeps counters"
    else echo "[FAIL] iptables-restore -n -c / iptables-save -c not usable"; fi
    iptables -t mangle -F ASC_PROBE 2>/dev/null; iptables -t mangle -X ASC_PROBE 2>/dev/null
    echo "[INFO] ASN sets:        $(ipset list -n 2>/dev/null | grep -c '^ASN_')"
    echo "[INFO] clients:         $(ts_client_ips | grep -c .)"
    a=$( { fc status 2>/dev/null | head -n 3; } | tr '\n' ';')
    echo "[INFO] acceleration:    ${a:-no fc output}"
    echo "[INFO] state:           $(ts_state)"
    d=$(ts_store_dir 2>/dev/null)
    if [ -n "$d" ]; then echo "[OK]   numbers are saved in: $d/$TS_FILE"
    else echo "[WARN] no USB storage found - numbers are kept in RAM only and are lost on reboot"; fi
}

# service events from the WebUI (start_asnmanagerstats<action>)
ts_event() {
    case "$1" in
        enable)  ts_enable ;;
        disable) ts_disable ;;
        reset)   ts_reset ;;
        refresh) ts_export ;;
    esac
}

ts_cli() {
    case "$1" in
        enable)  ts_enable ;;
        disable) ts_disable ;;
        reset)   ts_reset ;;
        show|"") ts_show ;;
        unknown) ts_unknown ;;
        probe)   ts_probe ;;
        sync)    ts_lock; ts_sync && echo "Rules synced."; ts_unlock; ts_export ;;
        export)  ts_export ;;
        save)    ts_save ;;
        boot)    ts_boot ;;
        loop)    ts_loop ;;
        *)       echo "Usage: stats enable | disable | reset | show | unknown | probe"; return 1 ;;
    esac
}

# ---------- update from GitHub (WebUI + command line) ----------
UPD_URL="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/main/ASNmanager.sh"
UPD_NOTES="https://github.com/${GITHUB_USER}/${GITHUB_REPO}/blob/main/CHANGELOG.md"

# Downloads the installer file to $1 and prints its version. Empty output = GitHub not reachable / not ASN Manager.
upd_fetch() {
    rm -f "$1"
    curl -s -S -k --connect-timeout 8 -m 60 "$UPD_URL" -o "$1" 2>/dev/null && [ -s "$1" ] || return 1
    sed -i 's/\r$//' "$1" 2>/dev/null
    grep -q '^SCRIPT_VERSION="' "$1" || return 1
    grep -m 1 '^SCRIPT_VERSION=' "$1" | cut -d'"' -f2 | tr -cd '0-9.'
}

# Writes $WEB_DIR/update.js (installed version, GitHub version, newer yes/no) for the WebUI. Changes nothing else.
upd_check() {
    [ -d "$(dirname "$WEB_DIR")" ] || return 0
    mkdir -p "$WEB_DIR" 2>/dev/null || return 0
    u_tmp="/tmp/${WEBUI_NS}-upd-check.tmp"
    u_rv=$(upd_fetch "$u_tmp"); rm -f "$u_tmp"
    u_newer=0; u_err=""
    if [ -z "$u_rv" ]; then u_err="unreachable"
    elif is_remote_newer "$SCRIPT_VERSION" "$u_rv"; then u_newer=1; fi
    printf '{"ts":%s,"local":"%s","remote":"%s","newer":%s,"error":"%s","notes":"%s"}\n' \
        "$(date +%s)" "$SCRIPT_VERSION" "$u_rv" "$u_newer" "$u_err" "$UPD_NOTES" > "$WEB_DIR/update.js.tmp" && mv -f "$WEB_DIR/update.js.tmp" "$WEB_DIR/update.js"
}

# Installs a newer version from GitHub. Safe by design:
#  - syntax check before anything is replaced, previous script kept as ASNmanager.sh.bak
#  - the new file is written next to the script and renamed (atomic; the running old copy stays intact)
#  - the new version must be able to start, otherwise the old one is restored
cli_update() {
    u_tmp="/tmp/${WEBUI_NS}-update.tmp"; u_body="/tmp/${WEBUI_NS}-update.body"
    echo "Checking GitHub..."
    u_rv=$(upd_fetch "$u_tmp")
    if [ -z "$u_rv" ]; then rm -f "$u_tmp"; echo "Could not reach GitHub or the downloaded file is not ASN Manager - nothing changed."; return 1; fi
    if ! is_remote_newer "$SCRIPT_VERSION" "$u_rv"; then rm -f "$u_tmp"; echo "Already up to date (v${SCRIPT_VERSION})."; return 0; fi
    echo "Installing v${u_rv}..."
    # the GitHub file is an installer wrapper (cat << 'SCRIPT_EOF' ...): keep only the script body
    if head -n 1 "$u_tmp" | grep -q "^cat << .SCRIPT_EOF."; then sed '1d;/^SCRIPT_EOF$/,$d' "$u_tmp" > "$u_body"; else cp "$u_tmp" "$u_body"; fi
    rm -f "$u_tmp"
    if ! /bin/sh -n "$u_body" 2>/dev/null || ! grep -q '^SCRIPT_VERSION="' "$u_body"; then
        rm -f "$u_body"; echo "Downloaded file is damaged (syntax check failed) - nothing changed."; return 1
    fi
    cp -f "$SCRIPT_PATH" "$SCRIPT_PATH.bak" 2>/dev/null
    if ! { cp "$u_body" "$SCRIPT_PATH.new" && chmod +x "$SCRIPT_PATH.new" && mv -f "$SCRIPT_PATH.new" "$SCRIPT_PATH"; }; then
        rm -f "$u_body" "$SCRIPT_PATH.new"; echo "Could not write the new script - nothing changed."; return 1
    fi
    rm -f "$u_body"
    if ! "$SCRIPT_PATH" help >/dev/null 2>&1; then
        cp -f "$SCRIPT_PATH.bak" "$SCRIPT_PATH.new" && chmod +x "$SCRIPT_PATH.new" && mv -f "$SCRIPT_PATH.new" "$SCRIPT_PATH"
        echo "The new version did not start - the old version was restored."; return 1
    fi
    webui_enabled && "$SCRIPT_PATH" webui update >/dev/null 2>&1        # fetch the matching WebUI page
    "$SCRIPT_PATH" stats boot >/dev/null 2>&1                           # restart the statistics loop with the new code
    echo "Updated to v${u_rv}. The page reloads."
}

service_event() {
    [ "$1" = "start" ] || return 0
    case "$2" in
        "${WEBUI_NS}cmd")
            payload=$(sed -n "s/^${WEBUI_NS}_cmd //p" "$SETTINGS_FILE" 2>/dev/null | head -n 1)
            sed -i "/^${WEBUI_NS}_cmd /d" "$SETTINGS_FILE" 2>/dev/null
            [ -n "$payload" ] && web_job "$payload"
            ;;
        "${WEBUI_NS}refresh") web_export ;;
        "${WEBUI_NS}pubip") pubip_export ;;
        "${WEBUI_NS}stats"*) ts_event "${2#${WEBUI_NS}stats}" ;;
        "${WEBUI_NS}updatecheck") upd_check ;;
    esac
    return 0
}

# ---------- WebUI mount / install ----------
webui_lock()   { exec 9>/tmp/addonwebui.lock; command -v flock >/dev/null 2>&1 && flock -x 9; }
webui_unlock() { command -v flock >/dev/null 2>&1 && flock -u 9; exec 9>&-; }

menu_remount() {
    umount /www/require/modules/menuTree.js 2>/dev/null
    mount -o bind /tmp/menuTree.js /www/require/modules/menuTree.js
}

# Where the tab appears: "vpn" (default, after Instant Guard) or "addons"
webui_location() {
    l=$(cat "$ADDON_DIR/webui.location" 2>/dev/null)
    [ "$l" = "addons" ] && echo "addons" || echo "vpn"
}

webui_set_location() {
    case "$1" in vpn|addons) ;; *) echo "Usage: webui location <addons|vpn>"; return 1 ;; esac
    mkdir -p "$ADDON_DIR" && echo "$1" > "$ADDON_DIR/webui.location"
    webui_mount >/dev/null && echo "WebUI tab moved to: $1 menu. Reload the router page."
}

webui_mount() {
    webui_enabled || return 0
    [ -s "$WEBUI_SRC" ] || { echo "WebUI page missing: $WEBUI_SRC"; return 1; }
    [ -f /usr/sbin/helper.sh ] || { echo "Addon API (helper.sh) not found."; return 1; }
    . /usr/sbin/helper.sh
    webui_lock

    # Drop our previous page if its content changed (e.g. after an update)
    old=$(cat "$ADDON_DIR/webui_page" 2>/dev/null)
    case "$old" in
        user[0-9]*.asp)
            if [ -f "/www/user/$old" ] && grep -q "$WEBUI_MARK" "/www/user/$old" && \
               [ "$(md5sum < "$WEBUI_SRC")" != "$(md5sum < "/www/user/$old")" ]; then
                rm -f "/www/user/$old"
            fi ;;
    esac

    am_get_webui_page "$WEBUI_SRC"
    if [ "$am_webui_page" = "none" ]; then
        webui_unlock
        echo "No free WebUI slot (user1-20.asp all in use)."
        return 1
    fi
    cp -f "$WEBUI_SRC" "/www/user/$am_webui_page"
    echo "$am_webui_page" > "$ADDON_DIR/webui_page"

    [ -f /tmp/menuTree.js ] || cp /www/require/modules/menuTree.js /tmp/
    # remove our previous entries by page URL (the tab name can be shared with another install)
    [ -n "$old" ] && sed -i "/{url: \"$old\", tabName: \"$WEBUI_TAB\"}/d" /tmp/menuTree.js
    sed -i "/{url: \"$am_webui_page\", tabName:/d" /tmp/menuTree.js
    entry="{url: \"$am_webui_page\", tabName: \"$WEBUI_TAB\"},"
    if [ "$(webui_location)" = "vpn" ]; then
        # VPN menu: insert as last tab (after Instant Guard), i.e. before the menu's "__INHERIT__" end marker
        vpn_ln=$(grep -n 'menu_VPN"' /tmp/menuTree.js | head -n 1 | cut -d':' -f1)
        if [ -n "$vpn_ln" ]; then
            end_ln=$(awk -v s="$vpn_ln" 'NR > s && /tabName: *"__INHERIT__"/ { print NR; exit }' /tmp/menuTree.js)
            [ -n "$end_ln" ] && sed -i "${end_ln}i $entry" /tmp/menuTree.js
        fi
    fi
    help_ln=$(grep -n "shared-jy/redirect.htm" /tmp/menuTree.js | head -n 1 | cut -d':' -f1)
    if grep -q "{url: \"$am_webui_page\", tabName:" /tmp/menuTree.js; then
        :
    elif [ -n "$help_ln" ]; then
        # Shared "Addons" menu (vnStat-on-Merlin, scMerlin, ...) already exists -> add our tab there
        sed -i "${help_ln}i $entry" /tmp/menuTree.js
    else
        # Fallback: official Merlin example location (Tools menu)
        sed -i "/url: \"Tools_OtherSettings.asp\", tabName:/a $entry" /tmp/menuTree.js
    fi
    menu_remount
    webui_unlock

    mkdir -p "$WEB_DIR"
    web_export
    echo "WebUI mounted as $am_webui_page"
}

webui_unmount() {
    page=$(cat "$ADDON_DIR/webui_page" 2>/dev/null)
    webui_lock
    if [ -f /tmp/menuTree.js ]; then
        case "$page" in user[0-9]*.asp) sed -i "/{url: \"$page\", tabName: \"$WEBUI_TAB\"}/d" /tmp/menuTree.js ;; esac
        menu_remount
    fi
    case "$page" in
        user[0-9]*.asp) [ -f "/www/user/$page" ] && grep -q "$WEBUI_MARK" "/www/user/$page" && rm -f "/www/user/$page" ;;
    esac
    webui_unlock
    rm -rf "$WEB_DIR"
    echo "WebUI unmounted."
}

webui_install() {
    if ! nvram get rc_support 2>/dev/null | grep -q am_addons; then
        echo "This firmware does not support Addon WebUI pages (Merlin 384.15+ required)."
        return 1
    fi
    [ "$(nvram get jffs2_scripts 2>/dev/null)" = "1" ] || echo "Warning: 'Enable JFFS custom scripts and configs' is disabled - hooks will not run."
    mkdir -p "$ADDON_DIR"
    if [ "$1" != "local" ]; then
        echo "Downloading WebUI page..."
        if curl -fsSk --connect-timeout 10 "$ASP_URL" -o "$WEBUI_SRC.new" && grep -q "$WEBUI_MARK" "$WEBUI_SRC.new"; then
            sed -i 's/\r$//' "$WEBUI_SRC.new"
            mv -f "$WEBUI_SRC.new" "$WEBUI_SRC"
        else
            rm -f "$WEBUI_SRC.new"
            [ -s "$WEBUI_SRC" ] || { echo "Download failed and no local page at $WEBUI_SRC"; return 1; }
            echo "Download failed - using existing local page."
        fi
    fi
    [ -s "$WEBUI_SRC" ] || { echo "Missing $WEBUI_SRC"; return 1; }

    ensure_script "$SERVICE_EVENT"
    sed -i "/# ${WEBUI_MARK}\$/d" "$SERVICE_EVENT"
    echo 'if echo "$2" | grep -q "^'"$WEBUI_NS"'"; then '"$SCRIPT_PATH"' service_event "$1" "$2" </dev/null >/dev/null 2>&1 & fi # '"$WEBUI_MARK" >> "$SERVICE_EVENT"

    ensure_script "$SERVICES_START"
    sed -i "/# ${WEBUI_MARK}\$/d" "$SERVICES_START"
    echo "$SCRIPT_PATH webui mount >/dev/null 2>&1 & # $WEBUI_MARK" >> "$SERVICES_START"

    webui_mount && echo "WebUI installed. Reload the router page and open the '$WEBUI_TAB' tab."
}

webui_enabled() { [ ! -f "$ADDON_DIR/webui.disabled" ]; }
webui_installed() { [ -f "$ADDON_DIR/webui_page" ] && grep -q "$WEBUI_MARK" "$SERVICE_EVENT" 2>/dev/null; }
webui_page_version() { sed -n "s/.*<!-- ${WEBUI_MARK} v\([0-9.]*\) -->.*/\1/p" "$WEBUI_SRC" 2>/dev/null | head -n 1; }

# Called at menu start: install the WebUI (default) or update the page after a script update
webui_auto() {
    webui_enabled || return 0
    nvram get rc_support 2>/dev/null | grep -q am_addons || return 0
    if ! webui_installed; then
        echo -e "${CYAN}Installing WebUI page (router tab)...${NC}"
        webui_install >/dev/null 2>&1 && echo -e "${GREEN}WebUI installed.${NC}" || echo -e "${RED}WebUI install failed - see menu option [15].${NC}"
        sleep 1
    elif [ "$(webui_page_version)" != "$SCRIPT_VERSION" ]; then
        webui_install >/dev/null 2>&1
    else
        # re-mount so menu placement changes (e.g. new default location) take effect
        webui_mount >/dev/null 2>&1
    fi
}

webui_disable() {
    webui_unmount >/dev/null 2>&1
    sed -i "/# ${WEBUI_MARK}\$/d" "$SERVICE_EVENT" 2>/dev/null
    sed -i "/# ${WEBUI_MARK}\$/d" "$SERVICES_START" 2>/dev/null
    rm -f "$ADDON_DIR/webui_page"
    mkdir -p "$ADDON_DIR" && : > "$ADDON_DIR/webui.disabled"
    echo "WebUI disabled."
}

webui_enable() {
    rm -f "$ADDON_DIR/webui.disabled"
    webui_install
}

webui_menu() {
    clear
    echo -e "${YELLOW}--- WebUI (Router Tab) ---${NC}"
    if ! webui_enabled; then
        echo -e "Status: ${RED}Disabled${NC}"
        echo -n "Enable the WebUI tab? (y/n): "; read -r c
        case "$c" in [Yy]*) webui_enable ;; esac
    else
        page=$(cat "$ADDON_DIR/webui_page" 2>/dev/null)
        webui_installed && echo -e "Status: ${GREEN}Enabled${NC} (${page})" || echo -e "Status: ${YELLOW}Enabled, not installed${NC}"
        echo -e " [1] Disable WebUI tab"
        echo -e " [2] Reinstall / update WebUI page"
        [ "$(webui_location)" = "vpn" ] && echo -e " [3] Move tab to Addons menu (now: VPN)" || echo -e " [3] Move tab to VPN menu (now: Addons)"
        echo -e " [0] Cancel"
        echo -n "Select option [0-3]: "; read -r c
        case "$c" in
            1) webui_disable ;;
            2) webui_install ;;
            3) [ "$(webui_location)" = "vpn" ] && webui_set_location addons || webui_set_location vpn ;;
        esac
    fi
    echo "" && echo -n "Press Enter to return..." && read -r _
}

webui_uninstall() {
    ts_purge >/dev/null 2>&1
    webui_unmount >/dev/null 2>&1
    sed -i "/# ${WEBUI_MARK}\$/d" "$SERVICE_EVENT" 2>/dev/null
    sed -i "/# ${WEBUI_MARK}\$/d" "$SERVICES_START" 2>/dev/null
    sed -i "/^${WEBUI_NS}_/d" "$SETTINGS_FILE" 2>/dev/null
    rm -rf "$ADDON_DIR" "$WEB_DIR" "$LOCK_DIR"
    rm -f /tmp/asn_progress.txt /tmp/asn_failed.txt /tmp/asnm_* 2>/dev/null
    # Remove hook scripts that only contain the shebang now
    for f in "$SERVICE_EVENT" "$SERVICES_START"; do
        [ -f "$f" ] && [ -z "$(grep -v '^#!/bin/sh$' "$f" | grep -v '^[[:space:]]*$')" ] && rm -f "$f"
    done
    echo "WebUI removed."
}

cli_usage() {
    cat << USAGE_EOF
ASN Manager v${SCRIPT_VERSION} - usage: ASNmanager.sh [command]
  (no command)                       interactive menu
  list                               show ASN list
  add <TARGET> <ASN>... [--src IP]   add ASN(s), TARGET: ${VALID_DESTS}
  preset <1-${PRESET_COUNT}> <TARGET> [--src IP]  add a service preset
  presets                            list service presets
  remove <ASN>...                    remove ASN(s)
  clear                              remove all ASNs
  apply                              fetch subnets & apply rules
  retry                              rebuild from cache, download only missing/failed ASNs
  edit <ASN> <TARGET> [SRC-IP]       change target / source IP of an ASN
  import <replace|merge> <ASN:TARGET:SRC>[,...]  import entries
  status                             ipset status
  test <IP|domain>                   check which route a target takes
  lookup <IP|domain>                 find the ASN of a target
  trace <IP|domain>                  traceroute
  ifaces                             public IP / country per interface
  schedule <days> <HH:MM>            auto-refresh schedule
  stats enable | disable | reset     traffic statistics (per ASN and client) on / off / off + delete numbers
  stats show | unknown | probe       print numbers / list addresses without counter rule / self-check
  update check | install             look for a new version on GitHub / install it (the WebUI offers this as well)
  webui install [local] | enable | disable | update | uninstall | mount | unmount | export
  webui location <vpn|addons>        show the tab in the VPN (default) or the Addons menu
USAGE_EOF
}

cli_main() {
    cmd="$1"; [ $# -gt 0 ] && shift
    rc=0
    case "$cmd" in
        list)     cli_list ;;
        add)      cli_add "$@" ;;
        preset)   cli_preset "$@" ;;
        presets)  print_presets ;;
        remove|del) cli_remove "$@" ;;
        clear)    cli_clear ;;
        apply)    cli_apply ;;
        retry)    cli_apply cache ;;
        edit)     cli_edit "$@" ;;
        import)   cli_import "$@" ;;
        status)   ipset_status_report ;;
        test)     if is_valid_host "$1"; then route_test "$1"; else echo "Usage: test <IP|domain>"; false; fi ;;
        lookup)   cli_lookup "$1" ;;
        trace)    cli_trace "$1" ;;
        ifaces)   iface_ips_report ;;
        pubip)    pubip_export && cat "$WEB_DIR/pubip.js" ;;
        schedule) cli_schedule "$1" "$2" ;;
        webui)
            case "$1" in
                install)   rm -f "$ADDON_DIR/webui.disabled"; webui_install "$2" ;;
                enable)    webui_enable ;;
                disable)   webui_disable ;;
                update)    webui_install ;;
                uninstall) webui_uninstall ;;
                mount)     webui_mount ;;
                unmount)   webui_unmount ;;
                export)    web_export ;;
                location)  webui_set_location "$2" ;;
                *)         cli_usage; false ;;
            esac ;;
        stats)    ts_cli "$@" ;;
        update)
            case "$1" in
                check)       upd_check; sed 's/[{}"]//g' "$WEB_DIR/update.js" 2>/dev/null ;;
                install|"")  cli_update ;;
                *)           echo "Usage: update check | install"; false ;;
            esac ;;
        service_event) service_event "$1" "$2"; return 0 ;;
        help|-h|--help) cli_usage ;;
        *)        cli_usage; false ;;
    esac
    rc=$?
    # Keep the WebUI view in sync after CLI changes
    case "$cmd" in add|preset|remove|del|clear|apply|retry|edit|import|schedule)
        [ -f "$ADDON_DIR/webui_page" ] && web_export ;;
    esac
    return $rc
}

[ $# -gt 0 ] && { cli_main "$@"; exit $?; }

webui_auto
ts_ensure_loop

while true; do
    show_menu
    read -r opt
    case $opt in
        1)
            clear
            if [ ! -s "$ASN_FILE" ]; then
                echo -e "${YELLOW}--- Current ASN Routing List ---${NC}\n"
                echo -e "${RED}ASN list is currently empty.${NC}"
                echo "" && echo -n "Press Enter to return..." && read -r _
            else
                print_section() {
                    sec_title="$1"
                    sec_pattern="$2"
                    
                    sec_file="/tmp/asn_sec_$$.tmp"
                    grep -E "$sec_pattern" "$ASN_FILE" > "$sec_file"
                    
                    if [ -s "$sec_file" ]; then
                        echo -e "${YELLOW}--- ${sec_title} ---${NC}"
                        echo -e "${CYAN}ASN -> TARGET           | ASN -> TARGET${NC}"
                        echo -e "--------------------------------------------------------"
                        
                        TMP_LIST="/tmp/asn_display_$$.tmp"
                        > "$TMP_LIST"
                        while IFS=':' read -r asn dest src_ip; do
                            [ -z "$asn" ] && continue
                            printf "AS%-7s -> %-8s" "$asn" "$dest" >> "$TMP_LIST"
                            [ -n "$src_ip" ] && echo " [${src_ip}]" >> "$TMP_LIST" || echo "" >> "$TMP_LIST"
                        done < "$sec_file"
                        
                        awk '
                        {
                            left[NR] = $0;
                        }
                        END {
                            n = NR;
                            half = int((n + 1) / 2);
                            for (i = 1; i <= half; i++) {
                                l = left[i];
                                r = (i + half <= n) ? left[i + half] : "";
                                printf " %-22s | %s\n", l, r;
                            }
                        }' "$TMP_LIST"
                        echo ""
                        rm -f "$TMP_LIST"
                    fi
                    rm -f "$sec_file"
                }

                echo -e "${YELLOW}=== Current ASN Routing List (Grouped by Interface) ===${NC}\n"
                
                print_section "WAN / Gateway" ":(WAN|WAN1|WAN2)(:|$)"
                print_section "OpenVPN Clients (OVPN)" ":OVPN[1-5](:|$)"
                print_section "WireGuard Clients (WGC)" ":WGC[1-5](:|$)"
                
                echo -n "Press Enter to return to main menu..."
                read -r _
            fi
            ;;
        2)
            clear
            echo -e "${YELLOW}--- Add ASN(s) ---${NC}"
            echo -n "Enter ASN(s) (e.g. AS15169, 13335): "
            read -r new_asns
            if [ -n "$new_asns" ]; then
                prompt_destination
                if [ "$SELECTED_DEST" != "CANCEL" ]; then
                    prompt_source_ip
                    clean_asns=$(echo "$new_asns" | tr ',' ' ' | tr ';' ' ' | sed -E 's/[Aa][Ss]([0-9]+)/\1/g')
                    for asn in $clean_asns; do
                        case $asn in
                            ''|*[!0-9]*) ;;
                            *) sed -i "/^${asn}:/d" "$ASN_FILE" && echo "${asn}:${SELECTED_DEST}:${SELECTED_SRC_IP}" >> "$ASN_FILE" ;;
                        esac
                    done
                    sort -u "$ASN_FILE" -o "$ASN_FILE" 2>/dev/null
                    echo -e "${GREEN}Saved successfully.${NC}"
                fi
            fi
            sleep 1.5
            ;;
        3)
            clear
            echo -n "Enter Domain or IP: "
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
                        if grep -q "^${asn_num}:" "$ASN_FILE"; then
                            echo -e "${YELLOW}AS$asn_num is already in the list.${NC}"
                            echo -n "Remove it? (y/n): " && read -r rem_c
                            [ "$rem_c" = "y" ] && sed -i "/^${asn_num}:/d" "$ASN_FILE" && echo -e "${GREEN}Removed.${NC}"
                        else
                            echo -n "Add AS$asn_num to list? (y/n): " && read -r add_c
                            if [ "$add_c" = "y" ]; then
                                prompt_destination
                                [ "$SELECTED_DEST" != "CANCEL" ] && prompt_source_ip && echo "${asn_num}:${SELECTED_DEST}:${SELECTED_SRC_IP}" >> "$ASN_FILE" && sort -u "$ASN_FILE" -o "$ASN_FILE" 2>/dev/null && echo -e "${GREEN}Added.${NC}"
                            fi
                        fi
                    fi
                fi
            fi
            echo "" && echo -n "Press Enter to return..." && read -r _
            ;;
        4) service_presets ;;
        5) remove_menu ;;
        6)
            clear
            echo -e "${YELLOW}--- Rebuilding Worker & Fetching Subnets ---${NC}"
            if rebuild_worker; then
                "$WORKER_SCRIPT" force
                mark_applied
                echo -e "\n${GREEN}Finished! Rules updated.${NC}"
            fi
            echo "" && echo -n "Press Enter to return..." && read -r _
            ;;
        7)
            clear
            ipset_status_report
            echo "" && echo -n "Press Enter to return..." && read -r _
            ;;
        8)
            clear
            echo -n "Enter IP or Domain to test: " && read -r target
            [ -n "$target" ] && route_test "$target"
            echo "" && echo -n "Press Enter to return..." && read -r _
            ;;
        9) show_interface_ips ;;
        10)
            clear
            echo -n "Enter IP/Domain to traceroute: " && read -r target
            if [ -n "$target" ]; then
                echo -e "\n${YELLOW}--- Running Traceroute (Press [Enter] to abort & return) ---${NC}\n"
                traceroute -n -m 12 "$target" &
                TR_PID=$!
                read -r _
                kill -9 $TR_PID 2>/dev/null
                wait $TR_PID 2>/dev/null
            fi
            ;;
        11) update_self ;;
        12) configure_schedule ;;
        13) backup_restore_menu ;;
        14) uninstall_menu ;;
        15) webui_menu ;;
        0) clear; exit 0 ;;
    esac
done
SCRIPT_EOF
