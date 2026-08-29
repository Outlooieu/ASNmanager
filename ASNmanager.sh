cat << 'SCRIPT_EOF' > /jffs/scripts/ASNmanager.sh && chmod +x /jffs/scripts/ASNmanager.sh && sed -i 's/\r$//' /jffs/scripts/ASNmanager.sh && /jffs/scripts/ASNmanager.sh
#!/bin/sh
# ASN Manager for Asuswrt-Merlin

[ -t 0 ] || exec < /dev/tty 2>/dev/null

SCRIPT_VERSION="1.0.0"
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

    # WAN1
    wan1_dev=$(nvram get wan0_ifname 2>/dev/null)
    if [ -n "$wan1_dev" ] && ip addr show dev "$wan1_dev" 2>/dev/null | grep -q "inet "; then
        print_ip_info "WAN / WAN1 (${wan1_dev})" "$wan1_dev" "$GREEN"
    else
        wan_ip=$(nvram get wan0_ipaddr 2>/dev/null)
        if [ -n "$wan_ip" ] && [ "$wan_ip" != "0.0.0.0" ]; then
            print_ip_info "WAN / WAN1 (default)" "" "$GREEN"
        else
            echo -e " ${RED}[OFFLINE]${NC} WAN / WAN1\n"
        fi
    fi

    # WAN2
    wan2_dev=$(nvram get wan1_ifname 2>/dev/null)
    multi_wan=$(nvram get wans_mode 2>/dev/null)
    if [ "$multi_wan" = "lb" ] || [ "$multi_wan" = "fo" ] || [ -n "$wan2_dev" ]; then
        if [ -n "$wan2_dev" ] && ip addr show dev "$wan2_dev" 2>/dev/null | grep -q "inet "; then
            print_ip_info "WAN2 (${wan2_dev})" "$wan2_dev" "$GREEN"
        fi
    fi

    # OpenVPN Clients (tun11 - tun15)
    i=1
    while [ $i -le 5 ]; do
        dev="tun$((10 + i))"
        if ip addr show dev "$dev" 2>/dev/null | grep -q "inet "; then
            print_ip_info "OpenVPN Client $i (${dev})" "$dev" "$YELLOW"
        fi
        i=$((i + 1))
    done

    # WireGuard Clients (wgc1 - wgc5)
    i=1
    while [ $i -le 5 ]; do
        dev="wgc$i"
        if ip addr show dev "$dev" 2>/dev/null | grep -q "inet "; then
            print_ip_info "WireGuard Client $i (${dev})" "$dev" "$MAGENTA"
        fi
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
    if [ -n "$USB_DIRS" ]; then
        echo -e " [2] Export Backup to External USB (Folder: ASNmanager)"
    fi
    echo -e " [3] Import Backup (Restore)"
    echo -e " [0] Cancel"
    echo ""
    echo -n "Select option [0-3]: "
    read -r b_opt
    
    case "$b_opt" in
        1)
            BACKUP_DIR="/jffs"
            ;;
        2)
            if [ -n "$USB_DIRS" ]; then
                echo -e "\n${YELLOW}Available USB mount points:${NC}"
                i=1
                set -- $USB_DIRS
                for u in "$@"; do
                    echo -e " [$i] $u"
                    i=$((i+1))
                done
                echo -n "Select USB target [1]: "
                read -r u_sel
                [ -z "$u_sel" ] && u_sel=1
                eval chosen_usb=\${$u_sel}
                if [ -n "$chosen_usb" ]; then
                    BACKUP_DIR="${chosen_usb}/ASNmanager"
                    [ ! -d "$BACKUP_DIR" ] && mkdir -p "$BACKUP_DIR"
                else
                    BACKUP_DIR="/jffs"
                fi
            else
                BACKUP_DIR="/jffs"
            fi
            ;;
        3)
            echo ""
            echo -e "${YELLOW}Searching for backup files across /jffs and USB drives...${NC}"
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
                sort -u -n "$ASN_FILE" -o "$ASN_FILE" 2>/dev/null
                apply_schedule
                echo -e "\n${GREEN}Configuration successfully restored from $imp_file!${NC}"
                echo -e "${YELLOW}Run Option [6] to apply the restored routing rules.${NC}"
                sleep 3
            else
                echo -e "\n${RED}Invalid selection or file not found.${NC}"
                sleep 2
            fi
            return
            ;;
        *)
            echo -e "${YELLOW}Cancelled.${NC}"
            sleep 1
            return
            ;;
    esac
    
    BACKUP_FILE="${BACKUP_DIR}/asn_manager_backup_$(date +%Y%m%d_%H%M%S).conf"
    echo "# ASN Manager Backup" > "$BACKUP_FILE"
    echo "VERSION=$SCRIPT_VERSION" >> "$BACKUP_FILE"
    echo "[ASN_LIST]" >> "$BACKUP_FILE"
    [ -f "$ASN_FILE" ] && cat "$ASN_FILE" >> "$BACKUP_FILE"
    echo "[SCHEDULE]" >> "$BACKUP_FILE"
    [ -f "$SCHEDULE_FILE" ] && cat "$SCHEDULE_FILE" >> "$BACKUP_FILE"
    
    echo -e "\n${GREEN}Backup successfully created at:${NC}"
    echo -e "${CYAN}$BACKUP_FILE${NC}"
    sleep 2
}

uninstall_menu() {
    clear
    echo -e "${RED}--- Uninstall ASN Manager ---${NC}"
    echo -e "${YELLOW}This will remove all ASN lists, firewall rules, ipsets, cron jobs,${NC}"
    echo -e "${YELLOW}and delete the script files from the router.${NC}"
    echo ""
    echo -n "Would you like to create a backup before uninstalling? (y/n): "
    read -r b_conf
    case "$b_conf" in
        [Yy]*)
            USB_DIRS=$(ls -d /mnt/* /tmp/mnt/* 2>/dev/null | grep -v '\*')
            echo -e "\nWhere do you want to save the backup?"
            echo -e " [1] Internal (/jffs/)"
            if [ -n "$USB_DIRS" ]; then
                echo -e " [2] External USB (Folder: ASNmanager)"
            fi
            echo -n "Choice [1]: "
            read -r u_choice
            [ -z "$u_choice" ] && u_choice=1
            
            if [ "$u_choice" = "2" ] && [ -n "$USB_DIRS" ]; then
                set -- $USB_DIRS
                chosen_usb="$1"
                BACKUP_DIR="${chosen_usb}/ASNmanager"
                [ ! -d "$BACKUP_DIR" ] && mkdir -p "$BACKUP_DIR"
            else
                BACKUP_DIR="/jffs"
            fi
            
            BACKUP_FILE="${BACKUP_DIR}/asn_manager_backup_uninstall_$(date +%Y%m%d_%H%M%S).conf"
            echo "# ASN Manager Backup" > "$BACKUP_FILE"
            echo "VERSION=$SCRIPT_VERSION" >> "$BACKUP_FILE"
            echo "[ASN_LIST]" >> "$BACKUP_FILE"
            [ -f "$ASN_FILE" ] && cat "$ASN_FILE" >> "$BACKUP_FILE"
            echo "[SCHEDULE]" >> "$BACKUP_FILE"
            [ -f "$SCHEDULE_FILE" ] && cat "$SCHEDULE_FILE" >> "$BACKUP_FILE"
            echo -e "${GREEN}Backup successfully saved to:${NC} ${CYAN}$BACKUP_FILE${NC}"
            sleep 2
            ;;
    esac

    echo ""
    echo -e -n "${RED}Are you ABSOLUTELY sure you want to completely uninstall ASN Manager? (y/n): ${NC}"
    read -r final_conf
    case "$final_conf" in
        [Yy]*)
            echo -e "\n${CYAN}Cleaning up firewall rules and ipsets...${NC}"
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

            echo -e "${CYAN}Removing cron jobs and startup entries...${NC}"
            cru d ASN_Worker 2>/dev/null
            [ -f "$SERVICES_START" ] && sed -i '/cru [ad] ASN_Worker/d' "$SERVICES_START"
            [ -f "$SERVICES_START" ] && sed -i '/ASNmanager/d' "$SERVICES_START"

            echo -e "${CYAN}Deleting script and configuration lists...${NC}"
            rm -f "$ASN_FILE" 2>/dev/null
            rm -f "$SCHEDULE_FILE" 2>/dev/null
            rm -f "$STATS_FILE" 2>/dev/null
            rm -f "$WORKER_SCRIPT" 2>/dev/null
            rm -f "/jffs/scripts/ASNmanager.sh" 2>/dev/null

            echo -e "\n${GREEN}ASN Manager has been successfully uninstalled.${NC}"
            echo -e "${YELLOW}Your backups remain safe and untouched.${NC}"
            echo -n "Press Enter to exit..."
            read -r _
            clear
            exit 0
            ;;
        *)
            echo -e "${YELLOW}Uninstallation cancelled.${NC}"
            sleep 1
            ;;
    esac
}

prompt_destination() {
    echo ""
    echo -e "${YELLOW}Select Target Interface for ASN(s):${NC}"
    echo -e " [1]  WAN / WAN1 (Primary Gateway - Table 254)"
    echo -e " [2]  WAN2 (Secondary Dual-WAN Gateway - Table 253)"
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

service_presets() {
    clear
    echo -e "${YELLOW}--- Add ASN Service Presets with Interface Selection ---${NC}"
    echo -e " [1]  Amazon / AWS (AS16509, AS14618)"
    echo -e " [2]  Google Services (AS15169, AS8075, AS22577)"
    echo -e " [3]  YouTube (AS43515, AS36040)"
    echo -e " [4]  Netflix (AS2906, AS40027)"
    echo -e " [5]  Cloudflare (AS13335, AS209242)"
    echo -e " [6]  Steam / Valve (AS32590)"
    echo -e " [7]  Meta / Facebook / IG / WhatsApp (AS32934, AS63293)"
    echo -e " [8]  Microsoft / Azure / Xbox (AS8075, AS8068, AS8074, AS36444)"
    echo -e " [9]  Apple / iCloud (AS714)"
    echo -e " [10] Telegram (AS62041, AS59930, AS44907, AS211157, AS20473)"
    echo -e " [11] Akamai CDN (AS20940, AS16625)"
    echo -e " [12] Fastly CDN (AS54113)"
    echo -e " [13] PlayStation / Sony (AS33494, AS19684, AS29237)"
    echo -e " [14] TikTok / ByteDance (AS138699, AS396986)"
    echo -e " [15] Hetzner & OVH Hosting (AS24940, AS16276)"
    echo -e " [16] Disney+ / Hulu (AS394464)"
    echo -e " [17] Spotify (AS8403, AS45102, AS23507)"
    echo -e " [18] Twitch (AS46489)"
    echo -e " [19] Riot Games / LoL / Valorant (AS6507)"
    echo -e " [20] Epic Games (AS32252, AS13488)"
    echo -e " [21] Nintendo (AS9003)"
    echo -e " [22] Zoom (AS20224, AS394622)"
    echo -e " [23] DigitalOcean & Linode (AS14061, AS63949)"
    echo -e " [24] Oracle Cloud (AS31898)"
    echo -e " [25] OpenAI / ChatGPT (AS398324)"
    echo -e " [26] GitHub (AS36459, AS19864)"
    echo -e " [27] NVIDIA / GeForce NOW (AS40676)"
    echo -e " [28] EA / Electronic Arts (AS29748)"
    echo -e " [29] Blizzard / Battle.net (AS57976)"
    echo -e " [30] Ubisoft (AS32499)"
    echo -e " [0]  Cancel"
    echo ""
    echo -n "Select preset [0-30]: "
    read -r p_opt
    case "$p_opt" in
        1)  PRESET_ASNS="16509 14618" ;;
        2)  PRESET_ASNS="15169 8075 22577" ;;
        3)  PRESET_ASNS="43515 36040" ;;
        4)  PRESET_ASNS="2906 40027" ;;
        5)  PRESET_ASNS="13335 209242" ;;
        6)  PRESET_ASNS="32590" ;;
        7)  PRESET_ASNS="32934 63293" ;;
        8)  PRESET_ASNS="8075 8068 8074 36444" ;;
        9)  PRESET_ASNS="714" ;;
        10) PRESET_ASNS="62041 59930 44907 211157 20473" ;;
        11) PRESET_ASNS="20940 16625" ;;
        12) PRESET_ASNS="54113" ;;
        13) PRESET_ASNS="33494 19684 29237" ;;
        14) PRESET_ASNS="138699 396986" ;;
        15) PRESET_ASNS="24940 16276" ;;
        16) PRESET_ASNS="394464" ;;
        17) PRESET_ASNS="8403 45102 23507" ;;
        18) PRESET_ASNS="46489" ;;
        19) PRESET_ASNS="6507" ;;
        20) PRESET_ASNS="32252 13488" ;;
        21) PRESET_ASNS="9003" ;;
        22) PRESET_ASNS="20224 394622" ;;
        23) PRESET_ASNS="14061 63949" ;;
        24) PRESET_ASNS="31898" ;;
        25) PRESET_ASNS="398324" ;;
        26) PRESET_ASNS="36459 19864" ;;
        27) PRESET_ASNS="40676" ;;
        28) PRESET_ASNS="29748" ;;
        29) PRESET_ASNS="57976" ;;
        30) PRESET_ASNS="32499" ;;
        *) return ;;
    esac

    prompt_destination
    if [ "$SELECTED_DEST" = "CANCEL" ]; then
        echo -e "${YELLOW}Operation cancelled.${NC}"
        sleep 1
        return
    fi

    for asn in $PRESET_ASNS; do
        sed -i "/^${asn}:/d" "$ASN_FILE"
        echo "${asn}:${SELECTED_DEST}" >> "$ASN_FILE"
    done
    sort -u -n "$ASN_FILE" -o "$ASN_FILE" 2>/dev/null
    echo -e "${GREEN}Preset ASNs assigned to ${SELECTED_DEST}! Run Option [6] to apply rules.${NC}"
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
            echo ""
            echo -n "Enter ASN number to remove (e.g. 15169): "
            read -r rem_asn
            clean_rem=$(echo "$rem_asn" | sed -E 's/[Aa][Ss]([0-9]+)/\1/g')
            if [ -n "$clean_rem" ]; then
                sed -i "/^${clean_rem}:/d" "$ASN_FILE"
                echo -e "${GREEN}ASN AS$clean_rem removed if present. Run Option [6] to apply rules.${NC}"
            fi
            ;;
        2)
            clear
            echo -e "${YELLOW}Select Service Preset to Remove:${NC}"
            echo -e " [1]  Amazon / AWS (AS16509, AS14618)"
            echo -e " [2]  Google Services (AS15169, AS8075, AS22577)"
            echo -e " [3]  YouTube (AS43515, AS36040)"
            echo -e " [4]  Netflix (AS2906, AS40027)"
            echo -e " [5]  Cloudflare (AS13335, AS209242)"
            echo -e " [6]  Steam / Valve (AS32590)"
            echo -e " [7]  Meta / Facebook / IG / WhatsApp (AS32934, AS63293)"
            echo -e " [8]  Microsoft / Azure / Xbox (AS8075, AS8068, AS8074, AS36444)"
            echo -e " [9]  Apple / iCloud (AS714)"
            echo -e " [10] Telegram (AS62041, AS59930, AS44907, AS211157, AS20473)"
            echo -e " [11] Akamai CDN (AS20940, AS16625)"
            echo -e " [12] Fastly CDN (AS54113)"
            echo -e " [13] PlayStation / Sony (AS33494, AS19684, AS29237)"
            echo -e " [14] TikTok / ByteDance (AS138699, AS396986)"
            echo -e " [15] Hetzner & OVH Hosting (AS24940, AS16276)"
            echo -e " [16] Disney+ / Hulu (AS394464)"
            echo -e " [17] Spotify (AS8403, AS45102, AS23507)"
            echo -e " [18] Twitch (AS46489)"
            echo -e " [19] Riot Games / LoL / Valorant (AS6507)"
            echo -e " [20] Epic Games (AS32252, AS13488)"
            echo -e " [21] Nintendo (AS9003)"
            echo -e " [22] Zoom (AS20224, AS394622)"
            echo -e " [23] DigitalOcean & Linode (AS14061, AS63949)"
            echo -e " [24] Oracle Cloud (AS31898)"
            echo -e " [25] OpenAI / ChatGPT (AS398324)"
            echo -e " [26] GitHub (AS36459, AS19864)"
            echo -e " [27] NVIDIA / GeForce NOW (AS40676)"
            echo -e " [28] EA / Electronic Arts (AS29748)"
            echo -e " [29] Blizzard / Battle.net (AS57976)"
            echo -e " [30] Ubisoft (AS32499)"
            echo -e " [0]  Cancel"
            echo ""
            echo -n "Select preset to remove [0-30]: "
            read -r p_rem
            case "$p_rem" in
                1)  REM_ASNS="16509 14618" ;;
                2)  REM_ASNS="15169 8075 22577" ;;
                3)  REM_ASNS="43515 36040" ;;
                4)  REM_ASNS="2906 40027" ;;
                5)  REM_ASNS="13335 209242" ;;
                6)  REM_ASNS="32590" ;;
                7)  REM_ASNS="32934 63293" ;;
                8)  REM_ASNS="8075 8068 8074 36444" ;;
                9)  REM_ASNS="714" ;;
                10) REM_ASNS="62041 59930 44907 211157 20473" ;;
                11) REM_ASNS="20940 16625" ;;
                12) REM_ASNS="54113" ;;
                13) REM_ASNS="33494 19684 29237" ;;
                14) REM_ASNS="138699 396986" ;;
                15) REM_ASNS="24940 16276" ;;
                16) REM_ASNS="394464" ;;
                17) REM_ASNS="8403 45102 23507" ;;
                18) REM_ASNS="46489" ;;
                19) REM_ASNS="6507" ;;
                20) REM_ASNS="32252 13488" ;;
                21) REM_ASNS="9003" ;;
                22) REM_ASNS="20224 394622" ;;
                23) REM_ASNS="14061 63949" ;;
                24) REM_ASNS="31898" ;;
                25) REM_ASNS="398324" ;;
                26) REM_ASNS="36459 19864" ;;
                27) REM_ASNS="40676" ;;
                28) REM_ASNS="29748" ;;
                29) REM_ASNS="57976" ;;
                30) REM_ASNS="32499" ;;
                *) return ;;
            esac
            for asn in $REM_ASNS; do
                sed -i "/^${asn}:/d" "$ASN_FILE"
            done
            echo -e "${GREEN}Preset ASNs removed! Run Option [6] to apply rules.${NC}"
            ;;
        3)
            echo ""
            echo -n "Are you sure you want to clear ALL configured ASNs? (y/n): "
            read -r confirm_all
            case "$confirm_all" in
                [Yy]*)
                    > "$ASN_FILE"
                    > "$STATS_FILE"
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
                    echo -e "${GREEN}All ASNs cleared and active tables destroyed successfully!${NC}"
                    ;;
                *)
                    echo -e "${YELLOW}Operation cancelled.${NC}"
                    ;;
            esac
            ;;
        *) return ;;
    esac
    sleep 2
}

is_remote_newer() {
    awk -v cur="$1" -v rem="$2" '
    BEGIN {
        split(cur, c, ".");
        split(rem, r, ".");
        for (i = 1; i <= 3; i++) {
            c[i] = c[i] + 0;
            r[i] = r[i] + 0;
            if (r[i] > c[i]) exit 0;
            if (r[i] < c[i]) exit 1;
        }
        exit 1;
    }' 2>/dev/null
}

update_self() {
    clear
    echo -e "${YELLOW}--- Updating ASN Manager on GitHub ---${NC}"
    echo -e "Installed Version: ${CYAN}v${SCRIPT_VERSION}${NC}"
    echo -e "${CYAN}Checking GitHub for available script updates...${NC}\n"
    
    TMP_SCRIPT="/tmp/ASNmanager-update.sh"
    rm -f "$TMP_SCRIPT" 2>/dev/null

    FETCH_URL="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/main/ASNmanager.sh"

    if curl -s -S -k --connect-timeout 10 "$FETCH_URL" -o "$TMP_SCRIPT"; then
        if [ ! -s "$TMP_SCRIPT" ] || grep -q "404: Not Found" "$TMP_SCRIPT"; then
            FETCH_URL="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/master/ASNmanager.sh"
            curl -s -S -k --connect-timeout 10 "$FETCH_URL" -o "$TMP_SCRIPT"
        fi

        if [ ! -s "$TMP_SCRIPT" ]; then
            rm -f "$TMP_SCRIPT" 2>/dev/null
            echo -e "${RED}Update check failed! Downloaded file is empty or missing on GitHub.${NC}"
            echo ""
            echo -n "Press Enter to return..."
            read -r _
            return
        fi

        sed -i 's/\r$//' "$TMP_SCRIPT" 2>/dev/null
        REMOTE_VERSION=$(grep -m 1 "^SCRIPT_VERSION=" "$TMP_SCRIPT" | cut -d'"' -f2 | tr -d '\r')

        echo -e "Remote Version on GitHub: ${CYAN}v${REMOTE_VERSION:-unknown}${NC}"

        if [ -z "$REMOTE_VERSION" ]; then
            echo -e "${RED}Error: Unable to parse version from downloaded file.${NC}"
            rm -f "$TMP_SCRIPT" 2>/dev/null
        elif [ "$SCRIPT_VERSION" = "$REMOTE_VERSION" ]; then
            echo -e "${GREEN}You are already running the latest version (v${SCRIPT_VERSION}). No update needed.${NC}"
            rm -f "$TMP_SCRIPT" 2>/dev/null
        elif is_remote_newer "$SCRIPT_VERSION" "$REMOTE_VERSION"; then
            echo -e "New version available: ${GREEN}v${REMOTE_VERSION}${NC} (Installed: v${SCRIPT_VERSION})"
            echo -n "Do you want to update now? (y/n): "
            read -r confirm
            case "$confirm" in
                [Yy]*)
                    cp "$TMP_SCRIPT" /jffs/scripts/ASNmanager.sh
                    chmod +x /jffs/scripts/ASNmanager.sh
                    sed -i 's/\r$//' /jffs/scripts/ASNmanager.sh 2>/dev/null
                    rm -f "$TMP_SCRIPT" 2>/dev/null
                    logger -t "ASN-Manager" "Script updated to v${REMOTE_VERSION} via menu." 2>/dev/null
                    echo -e "\n${GREEN}Update successful! Reloading ASN Manager...${NC}"
                    sleep 1
                    exec /bin/sh /jffs/scripts/ASNmanager.sh
                    ;;
                *)
                    echo -e "${YELLOW}Update cancelled.${NC}"
                    rm -f "$TMP_SCRIPT" 2>/dev/null
                    ;;
            esac
        else
            echo -e "${GREEN}Your installed version (v${SCRIPT_VERSION}) is newer than GitHub (v${REMOTE_VERSION}). No update needed.${NC}"
            rm -f "$TMP_SCRIPT" 2>/dev/null
        fi
    else
        rm -f "$TMP_SCRIPT" 2>/dev/null
        echo -e "${RED}Update check failed! Could not reach GitHub.${NC}"
        echo -e "${YELLOW}Verify network connectivity to GitHub.${NC}"
    fi
    echo ""
    echo -n "Press Enter to return..."
    read -r _
}

show_menu() {
    clear
    load_schedule
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
    echo -e " [2]  Add ASN(s) with Target Interface selection"
    echo -e " [3]  Find ASN for Domain / IP (Find, Add & Delete)"
    echo -e " [4]  Add ASN Service Presets (AWS, Netflix, Gaming, Streaming...)"
    echo -e " [5]  Remove ASN or Service Preset"
    echo -e " [6]  Build & Apply New Routing Rules (Split @ 3000 max)"
    echo -e " [7]  Check ipset Status & Per-ASN Subnet Count"
    echo -e " [8]  Test IP or Domain Routing"
    echo -e " [9]  Show active interface IP addresses & countries"
    echo -e " [10] Run Traceroute to IP or Domain"
    echo -e " [11] Update ASN Manager on GitHub"
    echo -e " [12] Set ASN IP Subnet Auto-Refresh Schedule (Every ${INTERVAL}d @ ${TIME_VAL})"
    echo -e " [13] Backup & Restore Configuration (Internal / USB)"
    echo -e " [14] Uninstall ASN Manager"
    echo -e " [0]  Exit"
    echo -e "${CYAN}----------------------------------------------------------------${NC}"
    echo -n "Select an option [0-14]: "
}

rebuild_worker() {
    if [ ! -s "$ASN_FILE" ]; then
        logger -t "ASN-Manager" "Error: ASN list is empty. Aborting build." 2>/dev/null
        echo -e "${RED}Error: ASN list is empty. Add ASNs first via Option [2], [3], or [4].${NC}"
        return 1
    fi

    cat << 'WORKER_EOF' > "$WORKER_SCRIPT"
#!/bin/sh
# Generated by ASN Manager (Chunked High-Performance Engine)

ASN_FILE="/jffs/scripts/asn_list.txt"
STATS_FILE="/tmp/asn_counts.txt"
MAX_PER_SET=3000

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

[ ! -s "$ASN_FILE" ] && exit 0

n=0
until ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; do
    n=$((n+1))
    [ $n -ge 30 ] && break
    sleep 2
done

logger -t "ASN-Manager" "Network ready. Fetching IP subnets and building chunked rules..."
> "$STATS_FILE"

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

get_info() {
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

fetch_asn_prefixes() {
    asn="$1"
    tmp_file="/tmp/asn_${asn}.txt"
    prefixes=""

    if [ "$asn" = "16509" ] || [ "$asn" = "14618" ]; then
        prefixes=$(curl -fsSk --connect-timeout 6 -m 10 "https://ip-ranges.amazonaws.com/ip-ranges.json" 2>/dev/null | grep -oE '"ip_prefix": "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}"' | cut -d'"' -f4 | sort -u)
    fi

    if [ -z "$prefixes" ]; then
        prefixes=$(curl -fsSk --connect-timeout 6 -m 10 "https://raw.githubusercontent.com/ipverse/asn-ip/master/as/${asn}/ipv4-aggregated.cidr" 2>/dev/null | grep -E '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}$' | sort -u)
    fi

    if [ -z "$prefixes" ]; then
        prefixes=$(curl -fsSk --connect-timeout 8 -m 25 -A "Mozilla/5.0" "https://stat.ripe.net/data/announced-prefixes/data.json?resource=AS${asn}" 2>/dev/null | tr ',' '\n' | grep -oE '"prefix":"[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}"' | cut -d'"' -f4 | sort -u)
    fi

    if [ -z "$prefixes" ]; then
        prefixes=$(curl -fsSk --connect-timeout 6 -m 10 -A "Mozilla/5.0" "https://api.hackertarget.com/aslookup/?q=AS${asn}" 2>/dev/null | grep -E '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}$' | sort -u)
    fi

    if [ -z "$prefixes" ]; then
        prefixes=$(curl -fsSk --connect-timeout 6 -m 10 -A "Mozilla/5.0" "https://api.bgpview.io/asn/${asn}/prefixes" 2>/dev/null | tr ',' '\n' | grep -oE '"prefix":"[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}"' | cut -d'"' -f4 | sort -u)
    fi

    echo "$prefixes" > "$tmp_file"
}

DESTS=$(cut -d':' -f2 "$ASN_FILE" | sort -u)

for dest in $DESTS; do
    [ -z "$dest" ] && continue
    info=$(get_info "$dest")
    TABLE=$(echo "$info" | cut -d' ' -f1)
    FWMARK="$(echo "$info" | cut -d' ' -f2)/$(echo "$info" | cut -d' ' -f2)"
    PRIO=$(echo "$info" | cut -d' ' -f3)

    echo -e "\n${CYAN}==> Processing Target Interface [${dest}]${NC}"

    for old_set in $(ipset list -n | grep "^ASN_${dest}_"); do
        iptables -t mangle -D PREROUTING -m set --match-set "$old_set" dst -j MARK --set-mark "$FWMARK" 2>/dev/null
        iptables -t mangle -D OUTPUT -m set --match-set "$old_set" dst -j MARK --set-mark "$FWMARK" 2>/dev/null
        ipset flush "$old_set" 2>/dev/null
        ipset destroy "$old_set" 2>/dev/null
    done

    ASNS_FOR_DEST=$(grep ":${dest}$" "$ASN_FILE" | cut -d':' -f1)

    batch_count=0
    for asn in $ASNS_FOR_DEST; do
        [ -z "$asn" ] && continue
        echo -e "  ${YELLOW}[*]${NC} Requesting subnets for AS${asn}..."
        fetch_asn_prefixes "$asn" &
        batch_count=$((batch_count + 1))
        
        if [ "$batch_count" -ge 4 ]; then
            wait
            batch_count=0
        fi
    done
    wait

    ALL_DEST_FILE="/tmp/all_${dest}.txt"
    > "$ALL_DEST_FILE"

    for asn in $ASNS_FOR_DEST; do
        [ -z "$asn" ] && continue
        tmp_file="/tmp/asn_${asn}.txt"
        if [ -s "$tmp_file" ]; then
            grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+$' "$tmp_file" >> "$ALL_DEST_FILE"
            asn_cnt=$(wc -l < "$tmp_file" | tr -d ' ')
            echo "${asn}:${dest}:${asn_cnt}" >> "$STATS_FILE"
            echo -e "  ${GREEN}[+]${NC} AS${asn} -> ${GREEN}${asn_cnt}${NC} subnets retrieved"
            rm -f "$tmp_file"
        else
            echo "${asn}:${dest}:0" >> "$STATS_FILE"
            echo -e "  ${RED}[!]${NC} AS${asn} -> ${RED}0 subnets found${NC}"
            rm -f "$tmp_file" 2>/dev/null
        fi
    done

    SORTED_DEST_FILE="/tmp/sorted_${dest}.txt"
    sort -u "$ALL_DEST_FILE" > "$SORTED_DEST_FILE"
    rm -f "$ALL_DEST_FILE"

    TOTAL_SUBNETS=$(wc -l < "$SORTED_DEST_FILE" | tr -d ' ')
    echo -e "  ${CYAN}Total unique subnets for ${dest}: ${TOTAL_SUBNETS:-0}${NC}"

    if [ "${TOTAL_SUBNETS:-0}" -gt 0 ]; then
        rm -f /tmp/chunk_${dest}_* 2>/dev/null
        awk -v prefix="/tmp/chunk_${dest}_" 'NR==1{file=prefix sprintf("%02d",++c)} {print > file} NR%3000==0{close(file); file=prefix sprintf("%02d",++c)}' "$SORTED_DEST_FILE"

        set_idx=1
        for chunk in /tmp/chunk_${dest}_*; do
            [ ! -f "$chunk" ] && continue
            IPSET_NAME="ASN_${dest}_${set_idx}"
            
            ipset create "$IPSET_NAME" hash:net family inet hashsize 1024 maxelem 4096 2>/dev/null
            awk -v set="$IPSET_NAME" '{print "add " set " " $1}' "$chunk" | ipset restore 2>/dev/null
            
            chunk_cnt=$(wc -l < "$chunk" | tr -d ' ')
            echo -e "  ${GREEN}[Loaded]${NC} ipset ${IPSET_NAME} -> ${GREEN}${chunk_cnt}${NC} subnets"

            if check_iface_up "$dest"; then
                ip rule del fwmark "$FWMARK" 2>/dev/null
                ip rule add from 0/0 fwmark "$FWMARK" table "$TABLE" prio "$PRIO"

                iptables -t mangle -D PREROUTING -m set --match-set "$IPSET_NAME" dst -j MARK --set-mark "$FWMARK" 2>/dev/null
                iptables -t mangle -I PREROUTING 1 -m set --match-set "$IPSET_NAME" dst -j MARK --set-mark "$FWMARK"

                iptables -t mangle -D OUTPUT -m set --match-set "$IPSET_NAME" dst -j MARK --set-mark "$FWMARK" 2>/dev/null
                iptables -t mangle -I OUTPUT 1 -m set --match-set "$IPSET_NAME" dst -j MARK --set-mark "$FWMARK"
            fi

            rm -f "$chunk"
            set_idx=$((set_idx + 1))
        done
        
        if ! check_iface_up "$dest"; then
            echo -e "  ${RED}[!] Interface ${dest} is OFFLINE. Skipping routing rule binding.${NC}"
            logger -t "ASN-Manager" "WARNING: Interface $dest is OFFLINE. Skipped policy routing rule binding."
        fi
    fi
    rm -f "$SORTED_DEST_FILE"
done

for active_set in $(ipset list -n | grep "^ASN_"); do
    found=0
    for dest in $DESTS; do
        case "$active_set" in
            ASN_${dest}_*)
                found=1
                break
                ;;
        esac
    done
    if [ $found -eq 0 ]; then
        dest_name=$(echo "$active_set" | sed -E 's/ASN_([^_]+).*/\1/')
        info=$(get_info "$dest_name")
        if [ -n "$info" ]; then
            FWMARK="$(echo "$info" | cut -d' ' -f2)/$(echo "$info" | cut -d' ' -f2)"
            iptables -t mangle -D PREROUTING -m set --match-set "$active_set" dst -j MARK --set-mark "$FWMARK" 2>/dev/null
            iptables -t mangle -D OUTPUT -m set --match-set "$active_set" dst -j MARK --set-mark "$FWMARK" 2>/dev/null
        fi
        ipset flush "$active_set" 2>/dev/null
        ipset destroy "$active_set" 2>/dev/null
        logger -t "ASN-Manager" "Removed orphan set: $active_set"
    fi
done

logger -t "ASN-Manager" "Routing rules successfully applied with 3000 max chunking."
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
            if [ -s "$ASN_FILE" ]; then
                TMP_DISP="/tmp/asn_display.txt"
                
                sort -t':' -k2,2 -k1,1n "$ASN_FILE" | awk -F':' '
                BEGIN {
                    prev_if = ""
                    col = 0
                    line = ""
                    c_green = "\033[0;32m"
                    c_yellow = "\033[1;33m"
                    c_magenta = "\033[0;35m"
                    c_reset = "\033[0m"
                }
                function get_colored_if(target) {
                    if (target ~ /^WGC/) return c_magenta target c_reset
                    if (target ~ /^OVPN/) return c_yellow target c_reset
                    if (target ~ /^WAN/) return c_green target c_reset
                    return target
                }
                {
                    curr_if = $2
                    asn = $1
                    colored_target = get_colored_if(curr_if)
                    item = sprintf("AS%-8s -> %s", asn, colored_target)
                    
                    if (prev_if != "" && curr_if != prev_if) {
                        if (col == 1) {
                            print line
                            col = 0
                            line = ""
                        }
                        print ""
                    }
                    
                    if (col == 0) {
                        line = sprintf("%-33s | ", item)
                        col = 1
                    } else {
                        print line item
                        line = ""
                        col = 0
                    }
                    prev_if = curr_if
                }
                END {
                    if (col == 1) {
                        print line
                    }
                }' > "$TMP_DISP"

                total_lines=$(wc -l < "$TMP_DISP" | tr -d ' ')
                page_size=18
                current_line=1
                total_pages=$(( (total_lines + page_size - 1) / page_size ))

                while [ "$current_line" -le "$total_lines" ]; do
                    clear
                    current_page=$(( (current_line / page_size) + 1 ))
                    echo -e "${YELLOW}--- Current ASN Routing List (Page ${current_page}/${total_pages}) ---${NC}"
                    printf "${CYAN}%-24s | %-24s\n${NC}" "ASN -> TARGET" "ASN -> TARGET"
                    echo "--------------------------------------------------------"
                    sed -n "${current_line},$((current_line + page_size - 1))p" "$TMP_DISP"
                    current_line=$((current_line + page_size))
                    echo ""
                    if [ "$current_line" -le "$total_lines" ]; then
                        echo -n "Press Enter for next page..."
                        read -r _
                    else
                        echo -n "Press Enter to return to main menu..."
                        read -r _
                    fi
                done
                rm -f "$TMP_DISP" 2>/dev/null
            else
                clear
                echo -e "${YELLOW}--- Current ASN Routing List ---${NC}"
                echo -e "${RED}ASN list is currently empty.${NC}"
                echo ""
                echo -n "Press Enter to return..."
                read -r _
            fi
            ;;
        2)
            clear
            echo -e "${YELLOW}--- Add ASN(s) ---${NC}"
            echo -e "Enter one or multiple ASNs (e.g. ${GREEN}AS15169, 13335 8075${NC}):"
            read -r new_asns
            if [ -n "$new_asns" ]; then
                prompt_destination
                if [ "$SELECTED_DEST" != "CANCEL" ]; then
                    clean_asns=$(echo "$new_asns" | tr ',' ' ' | tr ';' ' ' | sed -E 's/[Aa][Ss]([0-9]+)/\1/g')
                    for asn in $clean_asns; do
                        case $asn in
                            ''|*[!0-9]*) ;;
                            *) 
                                sed -i "/^${asn}:/d" "$ASN_FILE"
                                echo "${asn}:${SELECTED_DEST}" >> "$ASN_FILE"
                                ;;
                        esac
                    done
                    sort -u -n "$ASN_FILE" -o "$ASN_FILE" 2>/dev/null
                    echo -e "${GREEN}ASN(s) assigned to ${SELECTED_DEST} successfully.${NC}"
                else
                    echo -e "${YELLOW}Operation cancelled.${NC}"
                fi
            else
                echo -e "${RED}No input received.${NC}"
            fi
            sleep 1.5
            ;;
        3)
            clear
            echo -e "${YELLOW}--- Find ASN for Domain / IP ---${NC}"
            echo -n "Enter Domain or IP (e.g. github.com or 8.8.8.8): "
            read -r target

            if [ -n "$target" ]; then
                clean_target=$(echo "$target" | sed -E 's#https?://##' | cut -d'/' -f1)
                lookup_ip="$clean_target"
                if echo "$clean_target" | grep -q '[^0-9.]'; then
                    echo -e "${CYAN}Resolving IP for ${clean_target}...${NC}"
                    lookup_ip=$(nslookup "$clean_target" 2>/dev/null | grep -A 20 "Name:" | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n 1)
                fi

                if [ -n "$lookup_ip" ]; then
                    echo -e "${CYAN}Looking up ASN details for IP: ${lookup_ip}...${NC}\n"
                    asn_info=$(curl -fsSk --connect-timeout 5 "http://ip-api.com/line/$lookup_ip?fields=as")

                    if [ -n "$asn_info" ]; then
                        echo -e "Result: ${GREEN}$asn_info${NC}"
                        asn_num=$(echo "$asn_info" | grep -oE '[Aa][Ss][0-9]+|[0-9]+' | head -n 1 | sed -E 's/[Aa][Ss]//g')

                        if [ -n "$asn_num" ]; then
                            echo ""
                            if grep -q "^${asn_num}:" "$ASN_FILE"; then
                                curr_dest=$(grep "^${asn_num}:" "$ASN_FILE" | cut -d':' -f2)
                                echo -e "${YELLOW}AS$asn_num is currently configured for interface: ${GREEN}${curr_dest}${NC}"
                                echo -e " [1] Change Target Interface"
                                echo -e " [2] Remove AS$asn_num from List"
                                echo -e " [0] Cancel / Keep"
                                echo ""
                                echo -n "Select action [0-2]: "
                                read -r manage_opt
                                case "$manage_opt" in
                                    1)
                                        prompt_destination
                                        if [ "$SELECTED_DEST" != "CANCEL" ]; then
                                            sed -i "/^${asn_num}:/d" "$ASN_FILE"
                                            echo "${asn_num}:${SELECTED_DEST}" >> "$ASN_FILE"
                                            sort -u -n "$ASN_FILE" -o "$ASN_FILE" 2>/dev/null
                                            echo -e "${GREEN}AS$asn_num updated to ${SELECTED_DEST}! Run Option [6] to apply rules.${NC}"
                                        else
                                            echo -e "${YELLOW}Operation cancelled.${NC}"
                                        fi
                                        ;;
                                    2)
                                        sed -i "/^${asn_num}:/d" "$ASN_FILE"
                                        echo -e "${GREEN}AS$asn_num removed from list! Run Option [6] to apply rules.${NC}"
                                        ;;
                                    *)
                                        echo -e "No changes made."
                                        ;;
                                esac
                            else
                                echo -n "Would you like to add AS$asn_num to your ASN list? (y/n): "
                                read -r add_confirm
                                case $add_confirm in
                                    [Yy]*)
                                        prompt_destination
                                        if [ "$SELECTED_DEST" != "CANCEL" ]; then
                                            sed -i "/^${asn_num}:/d" "$ASN_FILE"
                                            echo "${asn_num}:${SELECTED_DEST}" >> "$ASN_FILE"
                                            sort -u -n "$ASN_FILE" -o "$ASN_FILE" 2>/dev/null
                                            echo -e "${GREEN}AS$asn_num assigned to ${SELECTED_DEST}! Run Option [6] to apply rules.${NC}"
                                        else
                                            echo -e "${YELLOW}Operation cancelled.${NC}"
                                        fi
                                        ;;
                                    *)
                                        echo -e "Skipped adding to list."
                                        ;;
                                esac
                            fi
                        fi
                    fi
                fi
            fi
            echo ""
            echo -n "Press Enter to return..."
            read -r _
            ;;
        4)
            service_presets
            ;;
        5)
            remove_menu
            ;;
        6)
            clear
            echo -e "${YELLOW}--- Rebuilding Worker Script & Fetching Subnets ---${NC}"
            if rebuild_worker; then
                "$WORKER_SCRIPT"
                echo -e "\n${GREEN}Finished! ASN routes updated successfully.${NC}"
            fi
            echo ""
            echo -n "Press Enter to return..."
            read -r _
            ;;
        7)
            clear
            echo -e "${YELLOW}--- ipset Status & Per-ASN Subnet Count ---${NC}"
            sets=$(ipset list -n | grep "^ASN_")
            if [ -n "$sets" ]; then
                for s in $sets; do
                    dest_name=$(echo "$s" | sed -E 's/ASN_([^_]+).*/\1/')
                    if check_iface_up "$dest_name"; then
                        IF_STATUS="${GREEN}[ONLINE / READY]${NC}"
                    else
                        IF_STATUS="${RED}[OFFLINE / DISCONNECTED]${NC}"
                    fi

                    echo -e "${CYAN}Set: $s${NC} -> Interface ${dest_name}: ${IF_STATUS}"
                    ENTRY_COUNT=$(ipset list "$s" 2>/dev/null | grep -E "Number of entries:" | awk '{print $4}')
                    echo -e " Subnets Loaded in Table: ${GREEN}${ENTRY_COUNT:-0}${NC}"
                    echo "------------------------------------------------------"
                done

                if [ -f "$STATS_FILE" ]; then
                    echo -e "\n${YELLOW}Per-ASN Subnet Breakdown:${NC}"
                    while IFS=':' read -r asn d cnt; do
                        printf "   - AS%-10s -> %-8s : %s subnets\n" "$asn" "$d" "$cnt"
                    done < "$STATS_FILE"
                fi
            else
                echo -e "${RED}No ASN ipset tables active. Run Option [6] to build rules.${NC}"
            fi
            echo ""
            echo -n "Press Enter to return..."
            read -r _
            ;;
        8)
            clear
            echo -e "${YELLOW}--- Test IP or Domain Routing ---${NC}"
            echo -n "Enter IP or Domain (e.g. 1.1.1.1 or google.com): "
            read -r target

            if [ -n "$target" ]; then
                clean_target=$(echo "$target" | sed -E 's#https?://##' | cut -d'/' -f1)
                resolved_ips="$clean_target"
                if echo "$clean_target" | grep -q '[^0-9.]'; then
                    echo -e "${CYAN}Resolving IP addresses for ${clean_target}...${NC}\n"
                    resolved_ips=$(nslookup "$clean_target" 2>/dev/null | grep -A 20 "Name:" | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | sort -u)
                fi

                for test_ip in $resolved_ips; do
                    MATCHED=0
                    sets=$(ipset list -n | grep "^ASN_")
                    for s in $sets; do
                        if ipset test "$s" "$test_ip" 2>/dev/null; then
                            dest_name=$(echo "$s" | sed -E 's/ASN_([^_]+).*/\1/')
                            echo -e "  [${GREEN}MATCHED: ${dest_name} (${s})${NC}]  $test_ip ($clean_target) -> Routes to $dest_name"
                            MATCHED=1
                            break
                        fi
                    done
                    if [ $MATCHED -eq 0 ]; then
                        echo -e "  [${RED}DEFAULT ROUTE${NC}] $test_ip ($clean_target) -> Follows default router behavior"
                    fi
                done
            fi
            echo ""
            echo -n "Press Enter to return..."
            read -r _
            ;;
        9)
            show_interface_ips
            ;;
        10)
            clear
            echo -e "${YELLOW}--- Traceroute & Route Inspector ---${NC}"
            echo -n "Enter IP or Domain to traceroute (e.g. 1.1.1.1 or google.com): "
            read -r target

            if [ -n "$target" ]; then
                clean_target=$(echo "$target" | sed -E 's#https?://##' | cut -d'/' -f1)
                resolved_ips="$clean_target"

                if echo "$clean_target" | grep -q '[^0-9.]'; then
                    echo -e "${CYAN}Resolving IP addresses for ${clean_target}...${NC}\n"
                    resolved_ips=$(nslookup "$clean_target" 2>/dev/null | grep -A 20 "Name:" | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n 12 | sort -u)
                fi

                echo -e "${CYAN}--- Assigned Target Interface ---${NC}"
                MATCHED_IFACE=""
                for test_ip in $resolved_ips; do
                    MATCHED=0
                    sets=$(ipset list -n | grep "^ASN_")
                    for s in $sets; do
                        if ipset test "$s" "$test_ip" 2>/dev/null; then
                            dest_name=$(echo "$s" | sed -E 's/ASN_([^_]+).*/\1/')
                            echo -e "  [${GREEN}MATCHED: ${dest_name} (${s})${NC}]  $test_ip ($clean_target) -> Routes to $dest_name"
                            MATCHED=1
                            ifname=$(get_ifname "$dest_name")
                            [ -n "$ifname" ] && MATCHED_IFACE="$ifname"
                            break
                        fi
                    done
                    if [ $MATCHED -eq 0 ]; then
                        echo -e "  [${RED}DEFAULT ROUTE${NC}] $test_ip ($clean_target) -> Follows default router behavior"
                    fi
                done

                TRACE_CMD="traceroute -n -m 12"
                if [ -n "$MATCHED_IFACE" ]; then
                    TRACE_CMD="traceroute -i $MATCHED_IFACE -n -m 12"
                    echo -e "\n${CYAN}Running traceroute via interface [${MATCHED_IFACE}] to ${clean_target} (Press Ctrl+C to stop)...${NC}\n"
                else
                    echo -e "\n${CYAN}Running traceroute to ${clean_target} (Press Ctrl+C to stop)...${NC}\n"
                fi

                trap 'echo -e "\n${YELLOW}[!] Traceroute interrupted.${NC}"' INT
                $TRACE_CMD "$clean_target"
                trap - INT
            fi
            echo ""
            echo -n "Press Enter to return..."
            read -r _
            ;;
        11)
            update_self
            ;;
        12)
            configure_schedule
            ;;
        13)
            backup_restore_menu
            ;;
        14)
            uninstall_menu
            ;;
        0)
            clear
            exit 0
            ;;
        *)
            ;;
    esac
done
SCRIPT_EOF

