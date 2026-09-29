cat << 'SCRIPT_EOF' > /jffs/scripts/ASNmanager.sh && chmod +x /jffs/scripts/ASNmanager.sh && sed -i 's/\r$//' /jffs/scripts/ASNmanager.sh && /jffs/scripts/ASNmanager.sh
#!/bin/sh
# ASN Manager for Asuswrt-Merlin

# Interactive menu only: CLI / WebUI calls (with arguments) must never grab the TTY
[ $# -eq 0 ] && { [ -t 0 ] || exec < /dev/tty 2>/dev/null; }

SCRIPT_VERSION="2.0.0"
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
            # Clean up kernel iptables rules, ipsets, and ip rules completely
            cleanup_rules
            
            # Remove WebUI page, menu entry and hooks
            webui_uninstall >/dev/null 2>&1

            # Remove cronjob, cache and associated files
            cru d ASN_Worker 2>/dev/null
            sed -i '/cru [ad] ASN_Worker/d' "/jffs/scripts/services-start" 2>/dev/null
            sed -i '/asn-bypass-worker.sh/d' "/jffs/scripts/services-start" 2>/dev/null
            for f in /jffs/scripts/services-start /jffs/scripts/service-event; do
                [ -f "$f" ] && [ -z "$(grep -v '^#!/bin/sh$' "$f" | grep -v '^[[:space:]]*$')" ] && rm -f "$f"
            done
            rm -f /tmp/asn_[0-9]*.txt /tmp/asn_counts.txt /tmp/asn_progress.txt /tmp/asn_failed.txt /tmp/ASNmanager-*.tmp /tmp/ASNmanager-update.sh 2>/dev/null
            rm -rf "/jffs/scripts/asn_cache" 2>/dev/null
            rm -f "$ASN_FILE" "$SCHEDULE_FILE" "$STATS_FILE" "$WORKER_SCRIPT" "$SCRIPT_PATH" 2>/dev/null
            
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
#  Non-interactive CLI + Merlin WebUI (Addons tab)
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
        echo -e "${CYAN}Installing WebUI page (Addons tab)...${NC}"
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
