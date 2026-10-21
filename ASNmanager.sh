#!/bin/sh
version=3.1.9
# ASN Manager for Asuswrt-Merlin

# Interactive menu only: CLI / WebUI calls (with arguments) must never grab the TTY
# (only if a terminal exists - without one, e.g. in an automated install, a failing "exec <" would end the shell)
[ $# -eq 0 ] && ! [ -t 0 ] && ( exec < /dev/tty ) 2>/dev/null && exec < /dev/tty

SCRIPT_VERSION="3.1.9"
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
        WAN|WAN1) if [ -n "$NV_OK" ]; then echo "$NV_W0"; else echo "$(nvram get wan0_ifname 2>/dev/null)"; fi ;;
        WAN2)     if [ -n "$NV_OK" ]; then echo "$NV_W1"; else echo "$(nvram get wan1_ifname 2>/dev/null)"; fi ;;
        OVPN1)    echo "tun11" ;; OVPN2) echo "tun12" ;; OVPN3) echo "tun13" ;; OVPN4) echo "tun14" ;; OVPN5) echo "tun15" ;;
        WGC1)     echo "wgc1" ;; WGC2) echo "wgc2" ;; WGC3) echo "wgc3" ;; WGC4) echo "wgc4" ;; WGC5) echo "wgc5" ;;
        *)        echo "" ;;
    esac
}

check_iface_up() {
    case "$1" in
        WAN|WAN1)
            if [ -n "$NV_OK" ]; then wan_unit=$NV_W0; else wan_unit=$(nvram get wan0_ifname 2>/dev/null); fi
            [ -n "$wan_unit" ] && ip addr show dev "$wan_unit" 2>/dev/null | grep -q "inet " && return 0
            if [ -n "$NV_OK" ]; then wan_ip=$NV_I0; else wan_ip=$(nvram get wan0_ipaddr 2>/dev/null); fi
            [ -n "$wan_ip" ] && [ "$wan_ip" != "0.0.0.0" ] && return 0
            return 1
            ;;
        WAN2)
            if [ -n "$NV_OK" ]; then wan_unit=$NV_W1; else wan_unit=$(nvram get wan1_ifname 2>/dev/null); fi
            [ -n "$wan_unit" ] && ip addr show dev "$wan_unit" 2>/dev/null | grep -q "inet " && return 0
            if [ -n "$NV_OK" ]; then wan_ip=$NV_I1; else wan_ip=$(nvram get wan1_ipaddr 2>/dev/null); fi
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
            pub_ip=$(curl -s -k --interface "$dev_name" --connect-timeout 3 -m 8 https://api.ipify.org 2>/dev/null)
        else
            pub_ip=$(curl -s -k --connect-timeout 3 -m 8 https://api.ipify.org 2>/dev/null)
        fi
        if [ -n "$pub_ip" ]; then
            geo_json=$(curl -s -k --connect-timeout 3 -m 8 "http://ip-api.com/json/$pub_ip?fields=status,country,countryCode" 2>/dev/null)
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

RULES_SINGLE="/jffs/addons/asnmanager/rules.single"      # exists = one set + one rule per ASN (the old way), otherwise combined sets
rules_mode() { [ -f "$RULES_SINGLE" ] && echo single || echo combined; }
rules_set_mode() {
    case "$1" in
        combined) rm -f "$RULES_SINGLE" ;;
        single)   mkdir -p "$ADDON_DIR"; : > "$RULES_SINGLE" ;;
        *)        echo "rules mode: $(rules_mode)   (usage: rulemode combined | single)"; return 0 ;;
    esac
    echo "Marking rules: $(rules_mode). Apply the rules once to switch."
    [ -f "$ADDON_DIR/webui_page" ] && web_export >/dev/null 2>&1
    return 0
}

# =====================================================================
#  Nothing may block for ever: time limit for commands, and a clean-up of runaway runs
# =====================================================================
# run_to SECONDS command ... : like the command, but it is killed after SECONDS (BusyBox nslookup has no time limit)
run_to() {
    rt_s=$1; shift
    "$@" &
    rt_p=$!
    ( sleep "$rt_s"; kill "$rt_p" 2>/dev/null; sleep 1; kill -9 "$rt_p" 2>/dev/null ) >/dev/null 2>&1 &
    rt_w=$!
    wait "$rt_p" 2>/dev/null; rt_r=$?
    kill "$rt_w" 2>/dev/null
    return $rt_r
}
nsl() { run_to 6 nslookup "$@"; }

# nvram is read ONCE per run: every "nvram get" is a process of its own and takes long on a busy router, the routing check used to ask for the
# WAN interface for every ASN (hundreds of calls per run). get_ifname / check_iface_up use these values when they are set.
nv_refresh() {
    NV_W0=$(nvram get wan0_ifname 2>/dev/null); NV_W1=$(nvram get wan1_ifname 2>/dev/null)
    NV_I0=$(nvram get wan0_ipaddr 2>/dev/null);  NV_I1=$(nvram get wan1_ipaddr 2>/dev/null)
    NV_OK=1
}

# seconds since a process was started
proc_age() {
    [ -r "/proc/$1/stat" ] || { echo 0; return; }
    pa_st=$(awk '{ print $22 }' "/proc/$1/stat" 2>/dev/null); pa_up=$(awk '{ print int($1) }' /proc/uptime 2>/dev/null)
    case "$pa_st$pa_up" in ''|*[!0-9]*) echo 0; return ;; esac
    echo $(( pa_up - pa_st / 100 ))
}
proc_kids() { for pk_d in /proc/[0-9]*; do [ "$(awk '{ print $4 }' "$pk_d/stat" 2>/dev/null)" = "$1" ] && echo "${pk_d#/proc/}"; done; }

# the cron run of the routing check: not while the previous one still works, and never longer than 4 minutes
rc_run_once() {
    rr_d=/tmp/asnmanager-check.lock
    if ! mkdir "$rr_d" 2>/dev/null; then
        rr_o=$(cat "$rr_d/pid" 2>/dev/null)
        if [ -n "$rr_o" ] && [ -d "/proc/$rr_o" ] && [ "$(proc_age "$rr_o")" -lt 600 ]; then return 0; fi
        rm -rf "$rr_d"; mkdir "$rr_d" 2>/dev/null || return 0
    fi
    echo $$ > "$rr_d/pid"
    run_to "${RC_LIMIT:-240}" rc_check
    rm -rf "$rr_d"
}

# periodic runs (routing check, failover, helpers of the counting loop) that run longer than REAP_AGE (15 minutes) hang: kill them and what they wait for
proc_reap() {
    pr_loop=$(cat "$TS_RT/loop.pid" 2>/dev/null); pr_max=${REAP_AGE:-900}
    for pr_p in $(ps w 2>/dev/null | grep -E 'ASNmanager\.sh (check run|failover run|stats loop|stats export)' | grep -v grep | awk '{ print $1 }'); do
        [ "$pr_p" = "$$" ] && continue
        [ "$pr_p" = "$pr_loop" ] && continue                         # the counting loop itself keeps running
        [ -d "/proc/$pr_p" ] || continue                             # gone in the meantime
        [ "$(proc_age "$pr_p")" -gt "$pr_max" ] || continue
        for pr_k in $(proc_kids "$pr_p"); do
            logger -t ASNmanager "hanging run: child $pr_k ($(tr '\0' ' ' 2>/dev/null < /proc/$pr_k/cmdline | cut -c1-70)) of $pr_p killed"
            kill -9 "$pr_k" 2>/dev/null
        done
        logger -t ASNmanager "hanging run: process $pr_p ($(tr '\0' ' ' 2>/dev/null < /proc/$pr_p/cmdline | cut -c1-70)) older than ${pr_max}s killed"
        kill -9 "$pr_p" 2>/dev/null
    done
    return 0
}

# =====================================================================
#  Custom entries: single IPs / CIDR ranges and domains
#  File /jffs/scripts/custom_list.txt, one entry per line:  C<n>:TARGET:SOURCES:ip|dom:VALUE
#  IP / CIDR: part of the marking set of its target (like the subnets of an ASN).
#  Domain: dnsmasq fills an ipset (one per target / source group) with the addresses it resolves for the domain
#  and all its subdomains; that set is NOT rebuilt by "apply", so what was learned stays.
#  Every entry also has its own set ASNC_<id> (IP: the range, domain: the addresses learned for just this domain).
#  It does not route anything - it is used for the traffic statistics and the "learned" numbers per entry.
# =====================================================================
CUSTOM_FILE="/jffs/scripts/custom_list.txt"
DNSMASQ_ADD="/jffs/configs/dnsmasq.conf.add"
CU_BEGIN="# ASNmanager domains begin"
CU_END="# ASNmanager domains end"
CU_GROUPS="/tmp/asnmanager-domgroups.txt"      # RAM: "target|sources <TAB> ipset <TAB> domains"
CU_STATUS="/tmp/asnmanager-custom.status"      # RAM: "id <TAB> ok|down"
UGROUPS_FILE="/tmp/asn_groups.txt"             # RAM, written by the worker: "target|sources <TAB> combined ipset"

cu_is_cidr() {
    cic_ip=${1%%/*}; cic_p=32
    case "$1" in */*) cic_p=${1#*/} ;; esac
    is_valid_ip "$cic_ip" || return 1
    case "$cic_p" in ''|*[!0-9]*) return 1 ;; esac
    [ "$cic_p" -ge 8 ] && [ "$cic_p" -le 32 ]          # /0 ... /7 would send half the internet
}
cu_norm_domain() {
    cnd=$(echo "$1" | tr 'A-Z' 'a-z' | sed -E 's/^\*\.//; s/^\.//; s/\.$//')
    echo "$cnd" | grep -qE '^([a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z][a-z0-9-]{0,61}$' && echo "$cnd"
}
# what is this token?  prints "asn 15169" | "ip 1.2.3.0/24" | "dom example.com"
cu_kind() {
    if cuk=$(norm_asn "$1"); then echo "asn $cuk"; return 0; fi
    if cu_is_cidr "$1"; then cuk="$1"; case "$cuk" in */*) ;; *) cuk="$cuk/32" ;; esac; echo "ip $cuk"; return 0; fi
    if cuk=$(cu_norm_domain "$1") && [ -n "$cuk" ]; then echo "dom $cuk"; return 0; fi
    return 1
}
cu_has() { grep -q "^$1:" "$CUSTOM_FILE" 2>/dev/null; }
# ids are never given out twice (the traffic statistics keep their numbers under the id): high-water mark in .seq
cu_next_id() {
    cnx=$(sed -n 's/^C\([0-9][0-9]*\):.*/\1/p' "$CUSTOM_FILE" 2>/dev/null | sort -n | tail -n 1)
    cnq=$(cat "$CUSTOM_FILE.seq" 2>/dev/null); case "$cnq" in ''|*[!0-9]*) cnq=0 ;; esac
    [ "${cnx:-0}" -gt "$cnq" ] && cnq=${cnx:-0}
    cnq=$((cnq + 1)); echo "$cnq" > "$CUSTOM_FILE.seq"
    echo "C$cnq"
}
# cu_save KIND TARGET SOURCES VALUE -> prints the id; the same kind + value is replaced
cu_save() {
    [ -f "$CUSTOM_FILE" ] || : > "$CUSTOM_FILE"
    awk -F: -v k="$1" -v v="$4" '!($4 == k && $5 == v)' "$CUSTOM_FILE" > "$CUSTOM_FILE.new" && mv -f "$CUSTOM_FILE.new" "$CUSTOM_FILE"
    cus_id=$(cu_next_id)
    echo "${cus_id}:$2:$3:$1:$4" >> "$CUSTOM_FILE"
    echo "$cus_id"
}
# text for an id, e.g. "ip 1.2.3.0/24" / "domain *.example.com"
cu_label() {
    awk -F: -v id="$1" '$1 == id { printf "%s", ($4 == "dom" ? "domain *." $5 : "ip " $5) }' "$CUSTOM_FILE" 2>/dev/null
}

cu_list() {
    [ -s "$CUSTOM_FILE" ] || { echo "No custom entries (IP/CIDR or domains)."; return 0; }
    while IFS=: read -r cl_id cl_d cl_s cl_k cl_v; do
        [ -n "$cl_id" ] || continue
        cl_x=""; [ "$cl_k" = "dom" ] && cl_x="  ($(cu_learned "$cl_id" "$cl_d" "$cl_s") learned)"
        [ "$cl_k" = "dom" ] && cl_v="*.${cl_v}"
        printf "%-5s %-6s -> %-6s %s\n" "$cl_id" "$cl_k" "$cl_d" "$cl_v${cl_s:+  [Src: $cl_s]}$cl_x"
    done < "$CUSTOM_FILE"
}
cu_print_section() {
    [ -s "$CUSTOM_FILE" ] || return 0
    echo -e "${YELLOW}--- Custom entries (IP/CIDR, domains) ---${NC}"
    echo -e "${CYAN}ID    TYPE   -> TARGET  VALUE${NC}"
    echo "--------------------------------------------------------"
    cu_list
    echo ""
}

# CLI: custom list | apply | early | purge
cli_custom() {
    case "$1" in
        apply)  cu_apply ;;
        early)  cu_apply_dom ;;
        purge)  cu_purge ;;
        learned) cu_learned_report "$2" ;;
        list|"") cu_list ;;
        *)      echo "Usage: custom list | learned [ID] | apply | early | purge" ;;
    esac
}

# import <replace|merge> <DEST:SRC:KIND:VALUE>[;...]   (used by restore / WebUI)
cli_cimport() {
    cim_mode="$1"; [ $# -gt 0 ] && shift
    case "$cim_mode" in replace|merge) ;; *) echo "Mode must be replace or merge"; return 1 ;; esac
    [ "$cim_mode" = "replace" ] && : > "$CUSTOM_FILE"
    cim_n=0; cim_bad=0; cim_added=""
    for cim_e in $(echo "$*" | tr ';' ' '); do
        cim_d=$(echo "$cim_e" | cut -d: -f1); cim_s=$(echo "$cim_e" | cut -d: -f2); cim_k=$(echo "$cim_e" | cut -d: -f3); cim_v=$(echo "$cim_e" | cut -d: -f4)
        cim_d=$(norm_dest "$cim_d") || { cim_bad=$((cim_bad + 1)); continue; }
        cim_s=$(norm_src "$cim_s"); is_valid_src "$cim_s" || { cim_bad=$((cim_bad + 1)); continue; }
        case "$cim_k" in
            ip)  cu_is_cidr "$cim_v" || { cim_bad=$((cim_bad + 1)); continue; }; case "$cim_v" in */*) ;; *) cim_v="$cim_v/32" ;; esac ;;
            dom) cim_v=$(cu_norm_domain "$cim_v") || { cim_bad=$((cim_bad + 1)); continue; } ;;
            *)   cim_bad=$((cim_bad + 1)); continue ;;
        esac
        cim_id=$(cu_save "$cim_k" "$cim_d" "$cim_s" "$cim_v")
        cim_n=$((cim_n + 1)); cim_added="$cim_added $cim_id"
    done
    mark_pending $cim_added
    cim_skip=""; [ $cim_bad -gt 0 ] && cim_skip=", $cim_bad invalid entries skipped"
    echo "Imported $cim_n custom entry(ies) (${cim_mode})${cim_skip}. Apply rules to activate."
}

# ---------------- applying: routing rule + table of a target, marking rules, sets ----------------
cu_usable() { check_iface_up "$1" >/dev/null 2>&1 || grep -q "^${1}=" "$FO_CONF" 2>/dev/null; }
cu_fw() { cf=$(get_target_info "$1" | cut -d' ' -f2); echo "${cf}/${cf}"; }
cu_route() {
    cr_info=$(get_target_info "$1"); [ -n "$cr_info" ] || return 1
    cr_table=$(echo "$cr_info" | cut -d' ' -f1); cr_mark=$(echo "$cr_info" | cut -d' ' -f2); cr_prio=$(echo "$cr_info" | cut -d' ' -f3)
    cr_fw="${cr_mark}/${cr_mark}"
    ip rule show 2>/dev/null | grep -q "fwmark ${cr_fw}" || ip rule add from 0/0 fwmark "$cr_fw" table "$cr_table" prio "$cr_prio" 2>/dev/null
    case "$1" in
        OVPN*|WGC*)
            cr_dev=$(get_ifname "$1")
            [ -n "$cr_dev" ] && { ip route show table "$cr_table" 2>/dev/null | grep -q '^default' || ip route add default dev "$cr_dev" table "$cr_table" 2>/dev/null; } ;;
    esac
    return 0
}
cu_rules_del() {          # every marking rule that uses the set $1
    for cr_t in PREROUTING OUTPUT; do
        iptables -t mangle -S "$cr_t" 2>/dev/null | grep -- "match-set $1 " | sed 's/^-A /-D /' | while read -r cr_r; do iptables -t mangle $cr_r 2>/dev/null; done
    done
}
cu_rules_add() {          # SET TARGET SOURCES
    cu_rules_del "$1"
    cra_fw=$(cu_fw "$2")
    if [ -n "$3" ]; then
        iptables -t mangle -I PREROUTING 1 -s "$3" -m set --match-set "$1" dst -j MARK --set-mark "$cra_fw"
    else
        iptables -t mangle -I PREROUTING 1 -m set --match-set "$1" dst -j MARK --set-mark "$cra_fw"
        iptables -t mangle -I OUTPUT 1 -m set --match-set "$1" dst -j MARK --set-mark "$cra_fw"
    fi
}
# the combined set of a target + source group (the worker made it for the ASNs; created here if only custom entries use the group)
cu_group_set() {          # TARGET SOURCES -> prints the set name
    cgs_key="${1}|${2}"
    cgs_name=$(awk -F'\t' -v k="$cgs_key" '$1 == k { print $2; exit }' "$UGROUPS_FILE" 2>/dev/null)
    if [ -z "$cgs_name" ]; then
        cgs_name="ASNU_${1}_x$(echo "$cgs_key" | md5sum | cut -c1-6)"
        printf '%s\t%s\n' "$cgs_key" "$cgs_name" >> "$UGROUPS_FILE"
    fi
    if ! ipset list -n 2>/dev/null | grep -qx "$cgs_name"; then
        ipset create "$cgs_name" hash:net family inet hashsize 1024 maxelem 524288 2>/dev/null
        cu_rules_add "$cgs_name" "$1" "$2"
    fi
    echo "$cgs_name"
}

cu_apply_ip() {
    [ -s "$CUSTOM_FILE" ] || return 0
    [ -f "$UGROUPS_FILE" ] || : > "$UGROUPS_FILE"
    cai_single=0; [ -f "$RULES_SINGLE" ] && cai_single=1
    while IFS=: read -r cid cdest csrc ckind cval; do
        [ "$ckind" = "ip" ] || continue
        case "$cid" in C[0-9]*) ;; *) continue ;; esac
        ipset create "ASNC_$cid" hash:net family inet hashsize 64 maxelem 1024 2>/dev/null
        ipset flush "ASNC_$cid" 2>/dev/null; ipset add -exist "ASNC_$cid" "$cval" 2>/dev/null
        if ! cu_usable "$cdest"; then printf '%s\tdown\n' "$cid" >> "$CU_STATUS"; continue; fi
        cu_route "$cdest"
        if [ "$cai_single" = "1" ]; then
            cai_set="ASN_${cdest}_${cid}"
            ipset create "$cai_set" hash:net family inet hashsize 1024 maxelem 65536 2>/dev/null
            ipset flush "$cai_set" 2>/dev/null
            ipset add -exist "$cai_set" "$cval" 2>/dev/null
            cu_rules_add "$cai_set" "$cdest" "$csrc"
        else
            cai_set=$(cu_group_set "$cdest" "$csrc")
            ipset add -exist "$cai_set" "$cval" 2>/dev/null
        fi
        printf '%s\tok\n' "$cid" >> "$CU_STATUS"
    done < "$CUSTOM_FILE"
}

# writes (or removes) our block in dnsmasq.conf.add; dnsmasq is restarted when the block changed, or with $2 = force
# (a domain set was just created: dnsmasq adds an address only when it fetches the answer from its upstream, not
# when it answers from its cache - the restart empties the cache, so names already looked up are learned again)
cu_dnsmasq_write() {
    cdw_new=/tmp/asnmanager-dnsmasq.new
    if [ -f "$DNSMASQ_ADD" ]; then sed "/^${CU_BEGIN}\$/,/^${CU_END}\$/d" "$DNSMASQ_ADD" > "$cdw_new"; else : > "$cdw_new"; fi
    if [ -s "$1" ]; then { echo "$CU_BEGIN"; cat "$1"; echo "$CU_END"; } >> "$cdw_new"; fi
    if [ -f "$DNSMASQ_ADD" ]; then cdw_cur="$DNSMASQ_ADD"; else cdw_cur=/dev/null; fi
    if cmp -s "$cdw_new" "$cdw_cur"; then
        rm -f "$cdw_new"
        [ "$2" = "force" ] || return 0
        service restart_dnsmasq >/dev/null 2>&1
        logger -t ASNmanager "Domain routing: new domain set, dnsmasq restarted (cache emptied)"
        return 0
    fi
    if [ -s "$cdw_new" ]; then mkdir -p "$(dirname "$DNSMASQ_ADD")" && cp "$cdw_new" "$DNSMASQ_ADD"; else rm -f "$DNSMASQ_ADD"; fi
    rm -f "$cdw_new"
    service restart_dnsmasq >/dev/null 2>&1
    logger -t ASNmanager "Domain routing: dnsmasq configuration changed, dnsmasq restarted"
}

cu_apply_dom() {
    : > "$CU_GROUPS.raw"; : > /tmp/asnmanager-dnsmasq.lines; cad_new=""
    if [ -s "$CUSTOM_FILE" ]; then
        while IFS=: read -r cid cdest csrc ckind cval; do
            [ "$ckind" = "dom" ] || continue
            case "$cid" in C[0-9]*) ;; *) continue ;; esac
            cad_key="${cdest}|${csrc}"
            cad_set="ASND_${cdest}_$(echo "$cad_key" | md5sum | cut -c1-6)"
            printf '%s\t%s\t%s\n' "$cad_key" "$cad_set" "$cval" >> "$CU_GROUPS.raw"
            # one line per domain: the group set routes, the entry's own set counts what was learned for this domain
            ipset list -n 2>/dev/null | grep -qx "ASNC_$cid" || { ipset create "ASNC_$cid" hash:ip family inet hashsize 1024 maxelem 262144 2>/dev/null; cad_new=force; }
            echo "ipset=/$cval/$cad_set,ASNC_$cid" >> /tmp/asnmanager-dnsmasq.lines
        done < "$CUSTOM_FILE"
    fi
    awk -F'\t' '{ if ($1 in l) l[$1] = l[$1] " " $3; else { l[$1] = $3; s[$1] = $2 } } END { for (k in l) printf "%s\t%s\t%s\n", k, s[k], l[k] }' "$CU_GROUPS.raw" > "$CU_GROUPS.new"
    mv -f "$CU_GROUPS.new" "$CU_GROUPS"; rm -f "$CU_GROUPS.raw"
    # marking rules of every domain set go (they are added again below); sets of groups that no longer exist are destroyed
    for cad_s in $(ipset list -n 2>/dev/null | grep '^ASND_'); do
        cu_rules_del "$cad_s"
        cut -f2 "$CU_GROUPS" | grep -qx "$cad_s" || ipset destroy "$cad_s" 2>/dev/null
    done
    while IFS="$(printf '\t')" read -r cad_key cad_set cad_list; do
        [ -n "$cad_set" ] || continue
        cad_t=${cad_key%%|*}; cad_src=${cad_key#*|}
        ipset list -n 2>/dev/null | grep -qx "$cad_set" || { ipset create "$cad_set" hash:ip family inet hashsize 1024 maxelem 262144 2>/dev/null; cad_new=force; }
        if cu_usable "$cad_t"; then cu_route "$cad_t"; cu_rules_add "$cad_set" "$cad_t" "$cad_src"; fi
    done < "$CU_GROUPS"
    cu_dnsmasq_write /tmp/asnmanager-dnsmasq.lines "$cad_new"
    rm -f /tmp/asnmanager-dnsmasq.lines
    cu_cset_cleanup
}

# per-entry sets of entries that no longer exist (a set the statistics still use is removed by its next sync)
cu_cset_cleanup() {
    for ccc_s in $(ipset list -n 2>/dev/null | grep '^ASNC_'); do
        cu_has "${ccc_s#ASNC_}" || ipset destroy "$ccc_s" 2>/dev/null
    done
    return 0
}

# number of addresses learned for a domain entry: its own set; an older group set as fallback
cu_learned() {            # ID TARGET SOURCES
    cl_c=$(ipset list -t "ASNC_$1" 2>/dev/null | sed -n 's/^Number of entries: //p')
    if [ -z "$cl_c" ]; then
        cl_set=$(awk -F'\t' -v k="${2}|${3}" '$1 == k { print $2; exit }' "$CU_GROUPS" 2>/dev/null)
        [ -n "$cl_set" ] || cl_set="ASND_${2}_$(echo "${2}|${3}" | md5sum | cut -c1-6)"
        cl_c=$(ipset list -t "$cl_set" 2>/dev/null | sed -n 's/^Number of entries: //p')
    fi
    echo "${cl_c:-0}"
}
# the learned addresses of a domain entry (max. $2 lines)
cu_learned_ips() { ipset list "ASNC_$1" 2>/dev/null | awk -v m="${2:-100000}" '/^Members:/ { f = 1; next } f && $1 ~ /^[0-9.]+$/ && n++ < m { print $1 }'; }

# CLI: learned [ID] - addresses dnsmasq has put into the set of each domain entry
cu_learned_report() {
    [ -s "$CUSTOM_FILE" ] || { echo "No custom entries."; return 0; }
    clr_any=0
    while IFS=: read -r cid cdest csrc ckind cval; do
        [ "$ckind" = "dom" ] || continue
        [ -n "$1" ] && [ "$1" != "$cid" ] && continue
        clr_any=1
        echo -e "${CYAN}$cid${NC} *.$cval -> $cdest${csrc:+ [Src: $csrc]}: ${GREEN}$(cu_learned "$cid" "$cdest" "$csrc")${NC} address(es) learned"
        cu_learned_ips "$cid" | sort -t. -k1,1n -k2,2n -k3,3n -k4,4n | awk '{ printf "  %s\n", $1 }'
    done < "$CUSTOM_FILE"
    [ $clr_any -eq 1 ] || echo "No domain entry${1:+ with id $1}."
    echo "(dnsmasq stores only the addresses, not which subdomain they belong to)"
}

# small file for the WebUI: learned numbers of the domain entries (refreshed by the statistics loop too)
cu_learned_js() {
    [ -d "$WEB_DIR" ] || return 0
    {
        printf '{"ts":%s,"c":{' "$(date +%s)"
        cljs_n=0
        if [ -s "$CUSTOM_FILE" ]; then
            while IFS=: read -r cid cdest csrc ckind cval; do
                [ "$ckind" = "dom" ] || continue
                case "$cid" in C[0-9]*) ;; *) continue ;; esac
                [ $cljs_n -gt 0 ] && printf ','
                printf '"%s":%s' "$cid" "$(cu_learned "$cid" "$cdest" "$csrc")"
                cljs_n=$((cljs_n + 1))
            done < "$CUSTOM_FILE"
        fi
        printf '}}\n'
    } > "$WEB_DIR/learned.js.tmp" 2>/dev/null && mv -f "$WEB_DIR/learned.js.tmp" "$WEB_DIR/learned.js"
}

cu_apply() {
    : > "$CU_STATUS"
    cu_apply_ip
    cu_apply_dom
    if [ -s "$CUSTOM_FILE" ]; then
        while IFS=: read -r cid cdest csrc ckind cval; do
            [ "$ckind" = "dom" ] || continue
            if cu_usable "$cdest"; then printf '%s\tok\n' "$cid" >> "$CU_STATUS"; else printf '%s\tdown\n' "$cid" >> "$CU_STATUS"; fi
        done < "$CUSTOM_FILE"
    fi
    cu_cset_cleanup
    return 0
}

# removes everything of the domain routing: rules, sets, our lines in dnsmasq.conf.add
cu_purge() {
    for cp_s in $(ipset list -n 2>/dev/null | grep '^ASND_'); do cu_rules_del "$cp_s"; ipset destroy "$cp_s" 2>/dev/null; done
    for cp_s in $(ipset list -n 2>/dev/null | grep '^ASNC_'); do ipset destroy "$cp_s" 2>/dev/null; done
    cu_dnsmasq_write /dev/null
    rm -f "$CU_GROUPS" "$CU_STATUS" /tmp/asnmanager-dnsmasq.lines
}

# "custom":[...] part of data.js
cu_json() {
    printf '"custom":['
    cj_n=0
    if [ -s "$CUSTOM_FILE" ]; then
        while IFS=: read -r cid cdest csrc ckind cval; do
            case "$cid" in C[0-9]*) ;; *) continue ;; esac
            case "$cdest" in WAN|WAN1|WAN2|OVPN[1-5]|WGC[1-5]) ;; *) continue ;; esac
            cj_st=$(awk -F'\t' -v k="$cid" '$1 == k { print $2; exit }' "$CU_STATUS" 2>/dev/null)
            cj_l=0; [ "$cj_st" = "ok" ] && cj_l=1
            cj_new=0; grep -qx "$cid" "$1" 2>/dev/null && cj_new=1
            cj_c=0; cj_ips=""
            if [ "$ckind" = "dom" ]; then
                cj_c=$(cu_learned "$cid" "$cdest" "$csrc")
                cj_ips=$(cu_learned_ips "$cid" 200 | awk '{ printf "%s\"%s\"", (n++ ? "," : ""), $1 }')
            fi
            [ $cj_n -gt 0 ] && printf ','
            printf '{"id":"%s","dest":"%s","src":"%s","kind":"%s","value":"%s","loaded":%d,"new":%d,"learned":%d,"ips":[%s]}' \
                "$cid" "$cdest" "$(echo "$csrc" | tr -cd '0-9.,')" "$ckind" "$(echo "$cval" | tr -cd 'A-Za-z0-9./-')" "$cj_l" "$cj_new" "${cj_c:-0}" "$cj_ips"
            cj_n=$((cj_n + 1))
        done < "$CUSTOM_FILE"
    fi
    printf '],'
    cu_learned_js >/dev/null 2>&1
}

# routing check rows of the custom entries (appended to check.js)
cu_check_rows() {          # $1 = rc_out file, $2 = number of rows already written
    ccr_n=$2
    [ -s "$CUSTOM_FILE" ] || return 0
    while IFS=: read -r cid cdest csrc ckind cval; do
        case "$cid" in C[0-9]*) ;; *) continue ;; esac
        d=$(ts_nd "$cdest"); info=$(rc_info "$d"); [ -n "$info" ] || continue
        mark=${info#* }
        code=ok; got=""; sample=""
        exp=$(cat "$FO_RT/active_$d" 2>/dev/null); [ -n "$exp" ] || exp=$d
        xdev=$(get_ifname "$d"); [ "$exp" != "$d" ] && [ "$exp" != "BLOCK" ] && xdev=$(get_ifname "$exp")
        if [ "$ckind" = "ip" ]; then
            sample=${cval%%/*}
            case "$cval" in */32) ;; *) sample=$(echo "$sample" | awk -F. '{ printf "%d.%d.%d.%d", $1, $2, $3, ($4 + 1) % 256 }') ;; esac
            if [ -n "$sample" ] && cut -d' ' -f1 "$EP_CACHE" 2>/dev/null | grep -qx "$sample"; then code=skipped; fi
            rc_rule_active "ASN_${cdest}_${cid}" "$d" "$sample" || { [ "$code" = "skipped" ] || code=norule; }
        else
            cc_set=$(awk -F'\t' -v k="${cdest}|${csrc}" '$1 == k { print $2; exit }' "$CU_GROUPS" 2>/dev/null)
            sample=$(cu_learned_ips "$cid" 1)
            [ -z "$sample" ] && [ -n "$cc_set" ] && sample=$(ipset list "$cc_set" 2>/dev/null | awk '/^Members:/ { f = 1; next } f && NF { print $1; exit }')
            if [ -z "$cc_set" ] || ! echo "$rc_rules" | grep -q -- "--match-set $cc_set dst"; then code=norule
            elif [ -z "$sample" ]; then code=nolearned; fi
        fi
        if [ "$code" = "ok" ]; then
            if [ "$exp" != "BLOCK" ] && ! check_iface_up "$exp"; then code=down
            elif [ "$exp" = "BLOCK" ]; then code=blocked
            else
                got=$(ip route get "$sample" mark "$mark" 2>/dev/null | head -n 1 | sed -n 's/.* dev \([^ ]*\).*/\1/p')
                if [ -z "$got" ]; then code=noroute
                elif [ "$got" != "$xdev" ]; then code=wrongdev
                elif [ "$exp" != "$d" ]; then code=failover; fi
            fi
        fi
        case "$code" in ok) state=ok ;; skipped|nolearned|norule|failover|blocked) state=warn ;; *) state=fail ;; esac
        [ "$code" = "skipped" ] && code=ok
        dev=$(get_ifname "$d")
        [ $ccr_n -gt 0 ] && printf ',' >> "$1"
        printf '{"asn":"%s","dest":"%s","src":"%s","state":"%s","code":"%s","dev":"%s","got":"%s","sample":"%s","recent":-1,"fo":"%s"}' \
            "$cid" "$d" "$(echo "$csrc" | tr -cd '0-9.,')" "$state" "$code" "$dev" "$got" "$sample" "$([ "$exp" != "$d" ] && echo "$exp")" >> "$1"
        ccr_n=$((ccr_n + 1))
    done < "$CUSTOM_FILE"
    return 0
}

cu_ipset_report() {
    cir_n=0
    for cir_s in $(ipset list -n 2>/dev/null | grep '^ASND_'); do
        cir_n=$((cir_n + 1))
        cir_c=$(ipset list -t "$cir_s" 2>/dev/null | sed -n 's/^Number of entries: //p')
        echo -e "${CYAN}$cir_s${NC} (domains, filled by dnsmasq) -> learned addresses: ${GREEN}${cir_c:-0}${NC}"
    done
    if [ $cir_n -gt 0 ] && [ -s "$CUSTOM_FILE" ]; then
        while IFS=: read -r cid cdest csrc ckind cval; do
            [ "$ckind" = "dom" ] && echo "   $cid *.$cval: $(cu_learned "$cid" "$cdest" "$csrc") learned  (list: ASNmanager.sh custom learned $cid)"
        done < "$CUSTOM_FILE"
    fi
    return 0
}

# ---------- backup: ASN list, schedule, failover chains, settings ----------
backup_text() {
    echo "# ASN Manager Backup"
    echo "# version=$SCRIPT_VERSION"
    echo "# created=$(date +%s)"
    echo "[ASN_LIST]"
    [ -s "$ASN_FILE" ] && cat "$ASN_FILE"
    echo "[CUSTOM]"
    [ -s "$CUSTOM_FILE" ] && awk -F: '{ print $2 ":" $3 ":" $4 ":" $5 }' "$CUSTOM_FILE"
    load_schedule
    echo "[SCHEDULE]"
    echo "INTERVAL=$INTERVAL"
    echo "TIME=$TIME_VAL"
    echo "[FAILOVER]"
    [ -s "$FO_CONF" ] && cat "$FO_CONF"
    echo "[SETTINGS]"
    echo "STATS=$(ts_state)"
    echo "STATS_SAVING=$(ts_saving && echo on || echo off)"
    echo "STATS_MODE=$(ts_mode)"
    echo "RULES_MODE=$(rules_mode)"
    echo "WEBUI_LOCATION=$(webui_location)"
    return 0
}

# backup_write <dir>: writes asn_manager_backup_<time>.conf and prints its path
backup_write() {
    bw_dir="${1:-/jffs}"; mkdir -p "$bw_dir" 2>/dev/null
    bw_file="$bw_dir/asn_manager_backup_$(date +%Y%m%d_%H%M%S).conf"
    backup_text > "$bw_file" && echo "$bw_file"
}

# for the WebUI: the page asks for a fresh copy and downloads it
backup_export() {
    mkdir -p "$WEB_DIR" 2>/dev/null || return 0
    # ".js" like every other data file: the router's web server does not deliver every file type (a "backup.txt" came back as an error)
    rm -f "$WEB_DIR/backup.txt" 2>/dev/null
    { echo "# generated=$(date +%s)-$$"; backup_text; } > "$WEB_DIR/backup.js.tmp" && mv -f "$WEB_DIR/backup.js.tmp" "$WEB_DIR/backup.js"
}

# ---------- restore ----------
RS_DIR="/tmp/${WEBUI_NS}-restore"

# splits a backup file into its sections; sets RS_* variables
rs_scan() {
    rm -rf "$RS_DIR"; mkdir -p "$RS_DIR"
    tr -d '\r' < "$1" > "$RS_DIR/raw.txt"
    RS_HAS_ASN=0; RS_HAS_FO=0; RS_HAS_SET=0
    if grep -qE '^\[(ASN_LIST|CUSTOM)\]' "$RS_DIR/raw.txt"; then
        awk -v d="$RS_DIR" '
            /^\[ASN_LIST\]/ { f = d "/asn.txt"; next }
            /^\[CUSTOM\]/ { f = d "/custom.txt"; next }
            /^\[SCHEDULE\]/ { f = d "/sched.txt"; next }
            /^\[FAILOVER\]/ { f = d "/fo.txt"; next }
            /^\[SETTINGS\]/ { f = d "/set.txt"; next }
            /^\[/ { f = ""; next }
            /^#/ || /^[ \t]*$/ { next }
            f != "" { print > f }' "$RS_DIR/raw.txt"
        RS_HAS_ASN=1
        grep -q '^\[FAILOVER\]' "$RS_DIR/raw.txt" && RS_HAS_FO=1
        grep -q '^\[SETTINGS\]' "$RS_DIR/raw.txt" && RS_HAS_SET=1
    else
        grep -E '^[0-9]+:' "$RS_DIR/raw.txt" > "$RS_DIR/asn.txt"          # an old plain list
        [ -s "$RS_DIR/asn.txt" ] && RS_HAS_ASN=1
    fi
    touch "$RS_DIR/asn.txt" "$RS_DIR/custom.txt" "$RS_DIR/sched.txt" "$RS_DIR/fo.txt" "$RS_DIR/set.txt"
    RS_N_ASNL=$(grep -c '^[0-9]' "$RS_DIR/asn.txt")
    RS_N_CUS=$(grep -c ':' "$RS_DIR/custom.txt")
    RS_N_ASN=$((RS_N_ASNL + RS_N_CUS))                 # the "ASN list" of a backup = ASNs + custom entries
    RS_N_FO=$(grep -c '=' "$RS_DIR/fo.txt")
    RS_N_SET=$(grep -c '=' "$RS_DIR/set.txt")
    RS_INT=$(sed -n 's/^INTERVAL=//p' "$RS_DIR/sched.txt" | head -n 1)
    RS_TIME=$(sed -n 's/^TIME=//p' "$RS_DIR/sched.txt" | head -n 1)
    RS_VER=$(sed -n 's/^# version=//p' "$RS_DIR/raw.txt" | head -n 1)
    [ -n "$RS_INT" ] && [ -n "$RS_TIME" ] && RS_HAS_SCHED=1 || RS_HAS_SCHED=0
    [ -n "$RS_VER" ] || RS_VER=""
    return 0
}

# one setting of a backup (also used by the WebUI)
rs_setting() {
    case "$1:$2" in
        STATS:enabled)    [ "$(ts_state)" = "enabled" ] || ts_enable ;;
        STATS:disabled)   [ "$(ts_state)" = "enabled" ] && ts_disable ;;
        STATS_SAVING:on|STATS_SAVING:off)  ts_save_mode "$2" ;;
        STATS_MODE:asn|STATS_MODE:iface)   ts_set_mode "$2" ;;
        RULES_MODE:combined|RULES_MODE:single)  rules_set_mode "$2" ;;
        WEBUI_LOCATION:vpn|WEBUI_LOCATION:addons)  [ "$(webui_location)" = "$2" ] || webui_set_location "$2" ;;
        STATS:*|STATS_SAVING:*|STATS_MODE:*|RULES_MODE:*|WEBUI_LOCATION:*)   echo "Invalid value '$2' for $1 skipped."; return 0 ;;
        *)                echo "Unknown setting '$1' skipped."; return 0 ;;
    esac
    echo "Setting applied: $1 = $2."
    return 0
}

# rs_apply <categories: asn,schedule,failover,settings> <replace|merge>
rs_apply() {
    ra_cats=",$1,"; ra_mode="${2:-replace}"
    case "$ra_cats" in *,asn,*)
        if [ "$RS_N_ASNL" -gt 0 ]; then
            ra_list=$(tr '\n' ';' < "$RS_DIR/asn.txt" | sed 's/;$//')
            cli_import "$ra_mode" "$ra_list"
        elif [ "$ra_mode" = "replace" ]; then
            : > "$ASN_FILE"; echo "ASN list cleared (the backup has no entries). Apply rules to activate."
        fi
        if [ "$RS_N_CUS" -gt 0 ]; then
            cli_cimport "$ra_mode" "$(tr '\n' ';' < "$RS_DIR/custom.txt" | sed 's/;$//')"
        elif [ "$ra_mode" = "replace" ]; then
            [ -f "$CUSTOM_FILE" ] && : > "$CUSTOM_FILE"
        fi ;;
    esac
    case "$ra_cats" in *,schedule,*)
        [ "$RS_HAS_SCHED" = "1" ] && cli_schedule "$RS_INT" "$RS_TIME" ;;
    esac
    case "$ra_cats" in *,failover,*)
        for ra_t in $(cut -d= -f1 "$FO_CONF" 2>/dev/null); do grep -q "^${ra_t}=" "$RS_DIR/fo.txt" || fo_set "$ra_t" ""; done
        while IFS='=' read -r ra_t ra_c; do [ -n "$ra_t" ] && fo_set "$ra_t" "$ra_c"; done < "$RS_DIR/fo.txt" ;;
    esac
    case "$ra_cats" in *,settings,*)
        while IFS='=' read -r ra_k ra_v; do [ -n "$ra_k" ] && rs_setting "$ra_k" "$ra_v"; done < "$RS_DIR/set.txt" ;;
    esac
    [ -f "$ADDON_DIR/webui_page" ] && web_export >/dev/null 2>&1
    return 0
}

# restore <file> [--only asn,schedule,failover,settings] [--merge]   (without --only everything in the file)
cli_restore() {
    rf="$1"; [ -f "$rf" ] || { echo "File not found: $rf"; return 1; }
    shift; rc_only=""; rc_mode="replace"
    while [ $# -gt 0 ]; do
        case "$1" in --only) rc_only="$2"; shift ;; --merge) rc_mode="merge" ;; esac
        shift
    done
    rs_scan "$rf"
    rc_all=""
    [ "$RS_HAS_ASN" = "1" ] && rc_all="asn"
    [ "$RS_HAS_SCHED" = "1" ] && rc_all="${rc_all:+$rc_all,}schedule"
    [ "$RS_HAS_FO" = "1" ] && rc_all="${rc_all:+$rc_all,}failover"
    [ "$RS_HAS_SET" = "1" ] && rc_all="${rc_all:+$rc_all,}settings"
    rc_use=""
    for rc_c in $(echo "$rc_all" | tr ',' ' '); do
        if [ -z "$rc_only" ] || echo ",$rc_only," | grep -q ",$rc_c,"; then rc_use="${rc_use:+$rc_use,}$rc_c"; fi
    done
    [ -n "$rc_use" ] || { echo "Nothing to restore (the file contains: ${rc_all:-nothing usable})."; return 1; }
    echo "Restoring: $rc_use${RS_VER:+  (backup of version $RS_VER)}"
    rs_apply "$rc_use" "$rc_mode"
    echo "Done. Apply the rules to activate the ASN list."
}

rs_ask() { echo -n "$1 [Y/n]: "; read -r rs_a; case "$rs_a" in n|N|no|NO) return 1 ;; esac; return 0; }

restore_menu() {
    rm_found=$(find /jffs /mnt /tmp/mnt -maxdepth 4 -name "asn_manager_backup_*.conf" 2>/dev/null | sort -u)
    [ -z "$rm_found" ] && { echo -e "${RED}No backup files found.${NC}"; sleep 2; return; }
    echo ""; rm_i=1
    echo "$rm_found" | while read -r rm_f; do echo -e " [$rm_i] $rm_f"; rm_i=$((rm_i + 1)); done
    echo -n "Select backup file to restore [1]: "; read -r rm_sel; [ -z "$rm_sel" ] && rm_sel=1
    rm_file=$(echo "$rm_found" | sed -n "${rm_sel}p")
    [ -f "$rm_file" ] || { echo "Not a valid choice."; sleep 1; return; }
    rs_scan "$rm_file"
    echo ""
    echo -e "${YELLOW}Backup:${NC} $rm_file${RS_VER:+  (version $RS_VER)}"
    echo "Choose what to restore:"
    rm_cats=""; rm_mode="replace"
    if [ "$RS_HAS_ASN" = "1" ]; then
        echo -n "  ASN list ($RS_N_ASN entries): [r]eplace the current list / [m]erge into it / [s]kip (r): "; read -r rm_a
        case "$rm_a" in s|S) ;; m|M) rm_mode="merge"; rm_cats="asn" ;; *) rm_cats="asn" ;; esac
    fi
    if [ "$RS_HAS_SCHED" = "1" ]; then
        rs_ask "  Auto-refresh schedule (every $RS_INT day(s) at $RS_TIME)?" && rm_cats="${rm_cats:+$rm_cats,}schedule"
    fi
    if [ "$RS_HAS_FO" = "1" ]; then
        rs_ask "  Failover chains ($RS_N_FO; chains not in the backup are removed)?" && rm_cats="${rm_cats:+$rm_cats,}failover"
    fi
    if [ "$RS_HAS_SET" = "1" ]; then
        echo "  Settings in the backup:"; sed 's/^/     /' "$RS_DIR/set.txt"
        rs_ask "  Restore these settings?" && rm_cats="${rm_cats:+$rm_cats,}settings"
    fi
    if [ -z "$rm_cats" ]; then echo "Nothing selected."; sleep 1; return; fi
    rs_ask "Restore now ($rm_cats)?" || return
    echo ""
    rs_apply "$rm_cats" "$rm_mode"
    echo -e "\n${GREEN}Done.${NC} Run option [7] to apply the ASN rules."
    sleep 3
}

backup_restore_menu() {
    clear
    echo -e "${YELLOW}--- Backup & Restore Configuration ---${NC}"
    USB_DIRS=$(ls -d /mnt/* /tmp/mnt/* 2>/dev/null | grep -v '\*')
    echo -e " [1] Export Backup to Internal (/jffs/)"
    [ -n "$USB_DIRS" ] && echo -e " [2] Export Backup to External USB (Folder: ASNmanager)"
    echo -e " [3] Import Backup (Restore) - you choose what to restore"
    echo -e " [0] Cancel"
    echo "     A backup contains: ASN list, auto-refresh schedule, failover chains, settings."
    echo ""
    echo -n "Select option [0-3]: "
    read -r b_opt
    case "$b_opt" in
        1) BACKUP_DIR="/jffs" ;;
        2)
            [ -n "$USB_DIRS" ] && set -- $USB_DIRS && BACKUP_DIR="${1}/ASNmanager" && mkdir -p "$BACKUP_DIR"
            ;;
        3) restore_menu; return ;;
        *) return ;;
    esac
    BACKUP_FILE=$(backup_write "$BACKUP_DIR")
    echo -e "${GREEN}Backup created at:${NC} ${CYAN}$BACKUP_FILE${NC}"
    sleep 2
}

cleanup_rules() {
    for active_set in $(ipset list -n | grep -E "^ASNU?_"); do
        dest_name=$(echo "$active_set" | sed -E 's/^ASNU?_([^_]+).*/\1/')
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
            # Backups (.conf) in /jffs and on USB devices: ask first
            bk_files=$(find /jffs /tmp/mnt -maxdepth 4 -name 'asn_manager_backup_*.conf' 2>/dev/null)
            bk_del=0
            if [ -n "$bk_files" ]; then
                echo -n "Also delete the $(echo "$bk_files" | grep -c .) backup file(s) (.conf) in /jffs and on USB devices? (y/N): "
                read -r bk_ans
                case "$bk_ans" in [Yy]*) bk_del=1 ;; esac
            fi

            # Stop the traffic statistics and remove its rules / saved numbers (its rules reference the ASN sets)
            ts_purge >/dev/null 2>&1
            fo_purge >/dev/null 2>&1
            ep_purge >/dev/null 2>&1
            st_cleanup >/dev/null 2>&1
            cu_purge >/dev/null 2>&1
            rm -f /tmp/asn_groups.txt

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
            rm -f "$ASN_FILE" "$CUSTOM_FILE" "$CUSTOM_FILE.seq" "$SCHEDULE_FILE" "$STATS_FILE" "$WORKER_SCRIPT" "$SCRIPT_PATH" "$SCRIPT_PATH.bak" "$SCRIPT_PATH.new" 2>/dev/null
            rm -rf /tmp/${WEBUI_NS}-* /tmp/asnm_* /tmp/asn_display_*.tmp /tmp/asn_sec_*.tmp /tmp/asnstats 2>/dev/null
            [ $bk_del -eq 1 ] && echo "$bk_files" | while read -r bk_f; do [ -n "$bk_f" ] && rm -f "$bk_f"; done
            for bk_d in /tmp/mnt/*/ASNmanager /tmp/mnt/*/*/ASNmanager; do [ -d "$bk_d" ] && rmdir "$bk_d" 2>/dev/null; done
            rmdir "$ADDON_DIR" 2>/dev/null

            echo -e "\n${GREEN}ASN Manager successfully uninstalled. All rules, caches, WebUI files and hooks removed.${NC}"
            if [ $bk_del -eq 0 ] && [ -n "$bk_files" ]; then
                echo -e "${YELLOW}Backups kept:${NC}"; echo "$bk_files" | sed 's/^/  /'
            fi
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
    echo -n "Enter Source IP(s) for device-specific routing [e.g. 192.168.1.50 or 192.168.1.50,192.168.1.60, blank = ALL devices]: "
    read -r SELECTED_SRC_IP
    SELECTED_SRC_IP=$(echo "$SELECTED_SRC_IP" | tr -d ' ')
    SELECTED_SRC_IP=$(norm_src "$SELECTED_SRC_IP")
    if [ -n "$SELECTED_SRC_IP" ] && ! is_valid_src "$SELECTED_SRC_IP"; then
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
    echo -e "${GREEN}Preset assigned successfully! Run option [7] to apply rules.${NC}"
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
            echo -n "Enter ASN number or entry ID to remove (e.g. 15169 or C1 - IDs are shown in option [1]): "
            read -r rem_asn
            [ -n "$rem_asn" ] && cli_remove "$rem_asn" >/dev/null
            echo -e "${GREEN}Removed. Run option [7] to apply rules.${NC}"
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
            echo -e "${GREEN}Preset ASNs removed! Run option [7] to apply rules.${NC}"
            ;;
        3)
            > "$ASN_FILE"
            [ -f "$CUSTOM_FILE" ] && : > "$CUSTOM_FILE"
            > "$STATS_FILE"
            echo -e "${GREEN}All entries cleared.${NC}"
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

    if curl -s -S -k --connect-timeout 1 -m 10 "$FETCH_URL" -o "$TMP_CHECK" && [ -s "$TMP_CHECK" ]; then
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

    if curl -s -S -k --connect-timeout 10 -m 60 "$FETCH_URL" -o "$TMP_SCRIPT" && [ -s "$TMP_SCRIPT" ]; then
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
    webui_enabled && WEBUI_STATE="${GREEN}Enabled${NC}" || WEBUI_STATE="${RED}Disabled${NC}"
    FO_N=$(grep -c '=' "$FO_CONF" 2>/dev/null); FO_N=${FO_N:-0}
    echo -e "${YELLOW} ASNs${NC}"
    echo -e " [1]  Show ASN list & routing targets"
    echo -e " [2]  Add ASN(s) - target interface & source devices"
    echo -e " [3]  Find ASN for domain / IP (find, add & delete)"
    echo -e " [4]  Add service presets (AWS, Netflix, Gaming, Streaming ...)"
    echo -e " [5]  Edit ASN (target / source devices)"
    echo -e " [6]  Remove ASN or service preset"
    echo -e "${YELLOW} Rules & automation${NC}"
    echo -e " [7]  Build & apply routing rules"
    echo -e " [8]  Auto-refresh schedule (every ${INTERVAL}d @ ${TIME_VAL})"
    echo -e " [9]  Failover chains (${FO_N} configured)"
    echo -e "${YELLOW} Check & diagnose${NC}"
    echo -e " [10] Routing check & tunnel protection"
    echo -e " [11] ipset status & subnet count per ASN"
    echo -e " [12] Test routing of an IP or domain"
    echo -e " [13] Traceroute to an IP or domain"
    echo -e " [14] Interface IP addresses & countries"
    echo -e " [15] Speed test of a target interface"
    echo -e "${YELLOW} ASN Manager${NC}"
    echo -e " [16] WebUI tab (${WEBUI_STATE})"
    echo -e " [17] Backup & restore (internal / USB)"
    echo -e " [18] Update ASN Manager${UPDATE_NOTICE}"
    echo -e " [19] Job status & rescue"
    echo -e " [20] Uninstall ASN Manager"
    echo -e " [e]  Exit"
    echo -e "${CYAN}----------------------------------------------------------------${NC}"
    echo -n "Select an option [1-20, e]: "
}

# menu number -> action (the order of the menu is defined here and in show_menu only)
menu_action() {
    case "$1" in
        1) echo list ;;      2) echo add ;;       3) echo find ;;      4) echo presets ;;   5) echo edit ;;      6) echo remove ;;
        7) echo apply ;;     8) echo schedule ;;  9) echo failover ;;
        10) echo check ;;    11) echo ipset ;;    12) echo test ;;     13) echo trace ;;    14) echo ifips ;;    15) echo speed ;;
        16) echo webui ;;    17) echo backup ;;   18) echo update ;;   19) echo job ;;      20) echo uninstall ;;
        e|E|0) echo exit ;;
    esac
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
# the WAN values from nvram once (not once per ASN)
NV_W0=$(nvram get wan0_ifname 2>/dev/null); NV_W1=$(nvram get wan1_ifname 2>/dev/null); NV_I0=$(nvram get wan0_ipaddr 2>/dev/null); NV_I1=$(nvram get wan1_ipaddr 2>/dev/null); NV_OK=1
# 1 = one combined set + one marking rule per target / source group (cheap per packet), 0 = one set + one rule per ASN
UNION=1; [ -f /jffs/addons/asnmanager/rules.single ] && UNION=0
UGROUPS=/tmp/asn_groups.txt; : > "$UGROUPS"; UGN=0; DONE_DESTS=" "

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# no ASNs: only the custom entries (IP/CIDR, domains) may be left
[ ! -s "$ASN_FILE" ] && { [ -x /jffs/scripts/ASNmanager.sh ] && /jffs/scripts/ASNmanager.sh custom apply >/dev/null 2>&1; exit 0; }
# domain sets and their marking rules first (also before the internet wait at boot): what dnsmasq learned stays
[ -x /jffs/scripts/ASNmanager.sh ] && /jffs/scripts/ASNmanager.sh custom early >/dev/null 2>&1

# Better DNS & Internet check for boot
n=0
nmax=45; [ -n "$ASN_QUICK" ] && nmax=5      # started by the user (WebUI / menu): do not wait minutes
until ping -c 1 -W 2 github.com >/dev/null 2>&1 || ping -c 1 -W 2 google.com >/dev/null 2>&1; do
    n=$((n+1)); [ $n -ge $nmax ] && break; sleep 2
done

> "$STATS_FILE"
> /tmp/asn_failed.txt
ASN_TOTAL=$(grep -c ':' "$ASN_FILE")
ASN_NUM=0
get_ifname() {
    case "$1" in
        WAN|WAN1) if [ -n "$NV_OK" ]; then echo "$NV_W0"; else echo "$(nvram get wan0_ifname 2>/dev/null)"; fi ;;
        WAN2)     if [ -n "$NV_OK" ]; then echo "$NV_W1"; else echo "$(nvram get wan1_ifname 2>/dev/null)"; fi ;;
        OVPN1)    echo "tun11" ;; OVPN2) echo "tun12" ;; OVPN3) echo "tun13" ;; OVPN4) echo "tun14" ;; OVPN5) echo "tun15" ;;
        WGC1)     echo "wgc1" ;; WGC2) echo "wgc2" ;; WGC3) echo "wgc3" ;; WGC4) echo "wgc4" ;; WGC5) echo "wgc5" ;;
        *)        echo "" ;;
    esac
}
check_iface_up() {
    case "$1" in
        WAN|WAN1)
            if [ -n "$NV_OK" ]; then wan_unit=$NV_W0; else wan_unit=$(nvram get wan0_ifname 2>/dev/null); fi
            [ -n "$wan_unit" ] && ip addr show dev "$wan_unit" 2>/dev/null | grep -q "inet " && return 0
            if [ -n "$NV_OK" ]; then wan_ip=$NV_I0; else wan_ip=$(nvram get wan0_ipaddr 2>/dev/null); fi
            [ -n "$wan_ip" ] && [ "$wan_ip" != "0.0.0.0" ] && return 0
            return 1
            ;;
        WAN2)
            if [ -n "$NV_OK" ]; then wan_unit=$NV_W1; else wan_unit=$(nvram get wan1_ifname 2>/dev/null); fi
            [ -n "$wan_unit" ] && ip addr show dev "$wan_unit" 2>/dev/null | grep -q "inet " && return 0
            if [ -n "$NV_OK" ]; then wan_ip=$NV_I1; else wan_ip=$(nvram get wan1_ipaddr 2>/dev/null); fi
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
for active_set in $(ipset list -n | grep -E "^ASNU?_"); do
    dest_name=$(echo "$active_set" | sed -E 's/^ASNU?_([^_]+).*/\1/')
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

        # with a failover chain the rules are needed while the target is offline as well (the chain decides where the traffic goes)
        if check_iface_up "$dest" || grep -q "^$(echo "$dest" | sed 's/^WAN$/WAN1/')=" /jffs/addons/asnmanager/failover.conf 2>/dev/null; then
            iface_dev=$(get_ifname "$dest")
            
            # routing rule and table of this target: once per target
            case "$DONE_DESTS" in *" $dest "*) ;; *)
                DONE_DESTS="$DONE_DESTS$dest "
                while ip rule del fwmark "$FWMARK" 2>/dev/null; do :; done
                ip rule add from 0/0 fwmark "$FWMARK" table "$TABLE" prio "$PRIO"
                if [ -n "$iface_dev" ]; then
                    case "$dest" in
                        OVPN*|WGC*)
                            ip route show table "$TABLE" 2>/dev/null | grep -q "^default" || ip route add default dev "$iface_dev" table "$TABLE" 2>/dev/null
                            ;;
                    esac
                fi ;;
            esac

            rule_done=0
            if [ "$UNION" = "1" ]; then
                # all ASNs of the same target and source devices share ONE set and ONE rule
                gkey="${dest}|${src_ip}"
                gname=$(awk -F'\t' -v k="$gkey" '$1 == k { print $2; exit }' "$UGROUPS")
                if [ -z "$gname" ]; then
                    UGN=$((UGN + 1)); gname="ASNU_${dest}_${UGN}"
                    ipset create "$gname" hash:net family inet hashsize 4096 maxelem 524288 2>/dev/null
                    ipset flush "$gname" 2>/dev/null
                    printf '%s\t%s\n' "$gkey" "$gname" >> "$UGROUPS"
                    if [ -n "$src_ip" ]; then
                        iptables -t mangle -I PREROUTING 1 -s "$src_ip" -m set --match-set "$gname" dst -j MARK --set-mark "$FWMARK"
                    else
                        iptables -t mangle -I PREROUTING 1 -m set --match-set "$gname" dst -j MARK --set-mark "$FWMARK"
                        iptables -t mangle -I OUTPUT 1 -m set --match-set "$gname" dst -j MARK --set-mark "$FWMARK"
                    fi
                fi
                # overlapping prefixes of two ASNs are fine (-exist); the set is filled while its rule is already active
                awk -v set="$gname" '{print "add " set " " $1}' "$tmp_file" | ipset restore -exist 2>/dev/null && rule_done=1
            fi
            if [ "$rule_done" = "0" ]; then
                # one rule per ASN (also the fallback if the combined set could not be filled)
                if [ -n "$src_ip" ]; then
                    iptables -t mangle -I PREROUTING 1 -s "$src_ip" -m set --match-set "$IPSET_NAME" dst -j MARK --set-mark "$FWMARK"
                else
                    iptables -t mangle -I PREROUTING 1 -m set --match-set "$IPSET_NAME" dst -j MARK --set-mark "$FWMARK"
                    iptables -t mangle -I OUTPUT 1 -m set --match-set "$IPSET_NAME" dst -j MARK --set-mark "$FWMARK"
                fi
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
# custom entries (IP/CIDR into the combined sets, domain rules)
[ -x /jffs/scripts/ASNmanager.sh ] && /jffs/scripts/ASNmanager.sh custom apply >/dev/null 2>&1
# VPN servers always via WAN (tunnel protection), also after a scheduled run
[ -x /jffs/scripts/ASNmanager.sh ] && /jffs/scripts/ASNmanager.sh guard >/dev/null 2>&1
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

# source devices of a rule: empty (all devices), one IP or a comma separated list (max. 32)
is_valid_src() {
    [ -z "$1" ] && return 0
    vs_n=0
    for vs_x in $(echo "$1" | tr ',' ' '); do is_valid_ip "$vs_x" || return 1; vs_n=$((vs_n + 1)); done
    [ $vs_n -ge 1 ] && [ $vs_n -le 32 ]
}
# removes blanks and duplicates: "a, b,a" -> "a,b"
norm_src() { echo "$1" | tr -d ' \t' | awk 'BEGIN { RS = "," } NF { gsub(/\n/, ""); if ($0 != "" && !s[$0]++) o = o (o == "" ? "" : ",") $0 } END { print o }'; }

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
    ru_n=$(ipset list -n 2>/dev/null | grep -c '^ASNU_')
    if [ "$ru_n" -gt 0 ]; then echo -e "${YELLOW}Marking rules:${NC} combined - ${ru_n} set(s), $(iptables -t mangle -S PREROUTING 2>/dev/null | grep -c 'match-set ASNU_') rule(s) for all ASNs"
    else echo -e "${YELLOW}Marking rules:${NC} one rule per ASN ($(iptables -t mangle -S PREROUTING 2>/dev/null | grep -c 'match-set ASN_') rule(s))"; fi
    cu_ipset_report
}

route_test() {
    target="$1"
    if is_valid_ip "$target"; then
        ips="$target"
    else
        ips=$(nsl "$target" 2>/dev/null | grep -A 20 "Name:" | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}')
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
    [ -s "$ASN_FILE" ] || [ -s "$CUSTOM_FILE" ] || { echo "ASN list is empty."; return 0; }
    while IFS=':' read -r asn dest src_ip; do
        [ -z "$asn" ] && continue
        printf "AS%-10s -> %-6s %s\n" "$asn" "$dest" "${src_ip:+[Src: $src_ip]}"
    done < "$ASN_FILE"
    [ -s "$CUSTOM_FILE" ] && cu_list
    return 0
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
    src=$(norm_src "$src")
    if ! is_valid_src "$src"; then echo "Invalid source IP '$src'"; return 1; fi
    n=0; cn=0; added=""
    set -f
    for raw in $(echo "$asns" | tr ',;' '  '); do
        k=$(cu_kind "$raw") || { echo "Skipping invalid entry '$raw'"; continue; }
        case "$k" in
            asn*)
                asn=${k#asn }
                sed -i "/^${asn}:/d" "$ASN_FILE"
                echo "${asn}:${dest}:${src}" >> "$ASN_FILE"
                n=$((n + 1)); added="$added $asn" ;;
            *)
                cid=$(cu_save "${k%% *}" "$dest" "$src" "${k#* }")
                cn=$((cn + 1)); added="$added $cid" ;;
        esac
    done
    set +f
    sort -u "$ASN_FILE" -o "$ASN_FILE" 2>/dev/null
    [ $((n + cn)) -gt 0 ] || { echo "No valid ASN, IP/CIDR or domain given."; return 1; }
    mark_pending $added
    if [ $cn -eq 0 ]; then echo "Saved $n ASN(s) -> ${dest}${src:+ (Src: $src)}. Apply rules to activate."
    elif [ $n -eq 0 ]; then echo "Saved $cn IP/domain entry(ies) -> ${dest}${src:+ (Src: $src)}. Apply rules to activate."
    else echo "Saved $n ASN(s) and $cn IP/domain entry(ies) -> ${dest}${src:+ (Src: $src)}. Apply rules to activate."; fi
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
    case "$1" in
        C[0-9]*|c[0-9]*)
            ced_id="C${1#?}"
            cu_has "$ced_id" || { echo "${ced_id} is not in the list."; return 1; }
            ced_d=$(norm_dest "$2") || { echo "Invalid target '$2'"; return 1; }
            ced_s=$(norm_src "$3"); is_valid_src "$ced_s" || { echo "Invalid source IP '$3'"; return 1; }
            awk -F: -v OFS=: -v id="$ced_id" -v d="$ced_d" -v s="$ced_s" '$1 == id { $2 = d; $3 = s } { print }' "$CUSTOM_FILE" > "$CUSTOM_FILE.new" && mv -f "$CUSTOM_FILE.new" "$CUSTOM_FILE"
            mark_pending "$ced_id"
            echo "Updated ${ced_id} -> ${ced_d}${ced_s:+ (Src: $ced_s)}. Apply rules to activate."
            return 0 ;;
    esac
    asn=$(norm_asn "$1") || { echo "Invalid ASN '$1'"; return 1; }
    grep -q "^${asn}:" "$ASN_FILE" || { echo "AS${asn} is not in the list."; return 1; }
    norm_dest "$2" >/dev/null || { echo "Invalid target '$2'"; return 1; }
    if ! is_valid_src "$(norm_src "$3")"; then echo "Invalid source IP '$3'"; return 1; fi
    if [ -n "$3" ]; then cli_add "$2" "$asn" --src "$3"; else cli_add "$2" "$asn"; fi >/dev/null || { echo "Update failed"; return 1; }
    echo "Updated AS${asn} -> $(norm_dest "$2")${3:+ (Src: $3)}. Apply rules to activate."
}

# import <replace|merge> <ASN:TARGET:SRC>[;...]   (SRC may be a comma separated list of IPs)
cli_import() {
    mode="$1"; [ $# -gt 0 ] && shift
    case "$mode" in replace|merge) ;; *) echo "Mode must be replace or merge"; return 1 ;; esac
    set -f
    # tokens split at ';' ',' and blanks; a token without ':' that is an IP extends the previous entry's sources
    list=$(echo "$*" | tr ';, ' '\n\n\n' | awk 'NF {
            if (index($0, ":")) { if (e != "") print e; e = $0 }
            else if ($0 ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/ && e != "") e = e "," $0
            else { if (e != "") print e; e = ""; print "BAD:" $0 } }
        END { if (e != "") print e }')
    [ "$mode" = "replace" ] && : > "$ASN_FILE"
    n=0; bad=0; added=""
    for e in $list; do
        case "$e" in BAD:*) bad=$((bad + 1)); continue ;; esac
        asn=$(norm_asn "${e%%:*}") || { bad=$((bad + 1)); continue; }
        rest="${e#*:}"
        [ "$rest" = "$e" ] && { bad=$((bad + 1)); continue; }
        case "$rest" in *:*) src="${rest#*:}"; d="${rest%%:*}" ;; *) src=""; d="$rest" ;; esac
        dest=$(norm_dest "$d") || { bad=$((bad + 1)); continue; }
        src=$(norm_src "$src")
        if ! is_valid_src "$src"; then bad=$((bad + 1)); continue; fi
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
    n=0; cn=0
    set -f
    for raw in $(echo "$*" | tr ',;' '  '); do
        case "$raw" in
            C[0-9]*|c[0-9]*)
                cid="C${raw#?}"
                cu_has "$cid" && { sed -i "/^${cid}:/d" "$CUSTOM_FILE"; cn=$((cn + 1)); }
                continue ;;
        esac
        k=$(cu_kind "$raw") || continue
        case "$k" in
            asn*) a=${k#asn }; grep -q "^${a}:" "$ASN_FILE" && n=$((n + 1)); sed -i "/^${a}:/d" "$ASN_FILE" ;;
            *)
                kk=${k%% *}; vv=${k#* }
                if awk -F: -v k="$kk" -v v="$vv" '$4 == k && $5 == v { f = 1 } END { exit !f }' "$CUSTOM_FILE" 2>/dev/null; then
                    cn=$((cn + 1))
                    awk -F: -v k="$kk" -v v="$vv" '!($4 == k && $5 == v)' "$CUSTOM_FILE" > "$CUSTOM_FILE.new" && mv -f "$CUSTOM_FILE.new" "$CUSTOM_FILE"
                fi ;;
        esac
    done
    set +f
    [ $((n + cn)) -gt 0 ] && mark_pending
    if [ $cn -eq 0 ]; then echo "Removed $n ASN(s). Apply rules to activate."
    else echo "Removed $n ASN(s) and $cn IP/domain entry(ies). Apply rules to activate."; fi
}

cli_clear() {
    > "$ASN_FILE"
    [ -f "$CUSTOM_FILE" ] && : > "$CUSTOM_FILE"
    mark_pending
    echo "All ASNs cleared. Apply rules to remove active routing."
}

cli_apply() {
    wmode="force"; [ "$1" = "cache" ] && wmode=""
    if [ ! -s "$ASN_FILE" ]; then
        cleanup_rules
        > "$STATS_FILE"
        mark_applied
        cu_apply                       # custom entries (or the removal of their rules, sets and dnsmasq lines)
        if [ -s "$CUSTOM_FILE" ]; then echo "No ASNs in the list - ASN rules removed, custom entries applied."
        else echo "ASN list is empty - all ASN routing rules removed."; fi
        return 0
    fi
    rebuild_worker || return 1
    if [ -n "$wmode" ]; then
        echo "Fetching subnets for $(grep -c . "$ASN_FILE") ASN(s)..."
    else
        echo "Rebuilding rules from cache, downloading only missing ASNs..."
    fi
    rm -f /tmp/asn_progress.txt
    ASN_QUICK=1 "$WORKER_SCRIPT" $wmode >/dev/null 2>&1 &
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
    ep_guard_sync >/dev/null 2>&1
    fo_round_safe >/dev/null 2>&1
    rc_check >/dev/null 2>&1
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
        r=$(nsl "$1" $srv 2>/dev/null | awk '/^Name:/ { f = 1; next } f && /Address/' \
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
        printf '"rules":"%s",' "$(rules_mode)"

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
        cu_json "$pend_tmp"

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
    printf '{"id":"%s","action":"%s","state":"%s","msg":"%s","done":%s,"total":%s,"ts":%s,"busy":"%s","busyid":"%s"}\n' \
        "$1" "$2" "$3" "$(json_esc "$4")" "$pd" "$ptot" "$(date +%s)" "$(echo "$5" | tr -cd 'a-z')" "$(echo "$6" | tr -cd '0-9')" > "$WEB_DIR/job.js.tmp" && mv "$WEB_DIR/job.js.tmp" "$WEB_DIR/job.js"
}

# A job still runs only if its process is alive, really is ASN Manager (a process id can be reused after a job
# was killed) and the job is younger than 60 minutes. Lock content: "<pid> <action> <start> <job id>".
job_alive() {
    [ -n "$1" ] && kill -0 "$1" 2>/dev/null || return 1
    tr '\0' ' ' < "/proc/$1/cmdline" 2>/dev/null | grep -q "ASNmanager" || return 1
    case "$2" in ''|*[!0-9]*) return 0 ;; esac
    [ $(( $(date +%s) - $2 )) -lt 3600 ]
}

job_lock() {
    LOCK_ACT=""; LOCK_SINCE=""; LOCK_ID=""
    if ! mkdir "$LOCK_DIR" 2>/dev/null; then
        lk_pid=""; [ -f "$LOCK_DIR/pid" ] && read -r lk_pid LOCK_ACT LOCK_SINCE LOCK_ID < "$LOCK_DIR/pid"
        job_alive "$lk_pid" "$LOCK_SINCE" && return 1
        rm -rf "$LOCK_DIR"                                   # left over from a job that no longer runs
        mkdir "$LOCK_DIR" 2>/dev/null || return 1
    fi
    echo "$$ ${JOB_NEXT_ACT:-cli} $(date +%s) ${JOB_NEXT_ID:-0}" > "$LOCK_DIR/pid"
    return 0
}

# job [clear] - show the running WebUI job / remove its lock by hand
cli_job() {
    if [ "$1" = "clear" ]; then rm -rf "$LOCK_DIR"; echo "Job lock removed."; return 0; fi
    [ -d "$LOCK_DIR" ] || { echo "No ASN Manager job is running."; return 0; }
    lk_pid=""; lk_act=""; lk_t=""; [ -f "$LOCK_DIR/pid" ] && read -r lk_pid lk_act lk_t lk_id < "$LOCK_DIR/pid"
    lk_when=""; case "$lk_t" in ''|*[!0-9]*) ;; *) lk_when=" since $(date -d "@$lk_t" '+%H:%M:%S' 2>/dev/null)" ;; esac
    if job_alive "$lk_pid" "$lk_t"; then echo "Running: ${lk_act:-unknown job} (process $lk_pid${lk_when})."
    else echo "Left-over lock from ${lk_act:-an old job} (process $lk_pid${lk_when}) - the next job clears it automatically."; fi
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

    JOB_NEXT_ACT="$act"; JOB_NEXT_ID="$id"
    if ! job_lock; then
        lk_when=""; case "$LOCK_SINCE" in ''|*[!0-9]*) ;; *) lk_when=" (since $(date -d "@$LOCK_SINCE" '+%H:%M:%S' 2>/dev/null))" ;; esac
        job_status "$id" "$act" "error" "Another ASN Manager job is still running: ${LOCK_ACT:-unknown}${lk_when}." "$LOCK_ACT" "$LOCK_ID"
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
        cimport)  cli_cimport "$a1" "$a2" > "$OUT" 2>&1 ;;
        schedule) cli_schedule "$a1" "$a2" > "$OUT" 2>&1 ;;
        status)   ipset_status_report > "$OUT" 2>&1 ;;
        ifaces)   iface_ips_report > "$OUT" 2>&1 ;;
        lookup)   cli_lookup "$a1" > "$OUT" 2>&1 ;;
        test)     if is_valid_host "$a1"; then route_test "$a1"; else echo "Invalid domain or IP"; false; fi > "$OUT" 2>&1 ;;
        trace)    cli_trace "$a1" > "$OUT" 2>&1 ;;
        refresh)  echo "Data refreshed." > "$OUT" ;;
        update)   cli_update > "$OUT" 2>&1 ;;
        statssave) ts_save_mode "$a1" > "$OUT" 2>&1 ;;
        speedtest) st_run "$a1" > "$OUT" 2>&1 ;;
        setting)  rs_setting "$a1" "$a2" > "$OUT" 2>&1 ;;
        failover) fbs=""; [ -n "$a2" ] && fbs="$a2"; [ -n "$a3" ] && fbs="${fbs:+$fbs,}$a3"
                  fo_set "$a1" "$fbs" > "$OUT" 2>&1 ;;
        *)        echo "Unknown action '$act'" > "$OUT"; false ;;
    esac
    rc=$?
    esc=$(printf '\033')
    sed -i "s/${esc}\[[0-9;]*m//g" "$OUT"
    # after an update this process is still the OLD script (old version number in its data): the new script writes the data
    if [ "$act" = "update" ] && grep -q '^Updated to' "$OUT"; then "$SCRIPT_PATH" webui export >/dev/null 2>&1; else web_export; fi
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
#  Persistence: the totals are saved on the USB device, in the ASNmanager folder next to the .conf backups
#  (written at most hourly and only if something changed, plus on disable / shutdown). Nothing is written to
#  /jffs. The working copy lives in /tmp/asnmanager-stats/. "Counting is on" = the hook line in services-start.
# =====================================================================
TS_RT="/tmp/${WEBUI_NS}-stats"
TS_LEGACY="$ADDON_DIR/stats"        # v2.1.0 kept the numbers here (flash): migrated to the USB device once
TS_FILE="asn_manager_traffic_stats.txt"
TS_LIGHT="$ADDON_DIR/stats.light"      # exists = count per interface and device only (no rule per ASN: much cheaper)
TS_NOSAVE="$ADDON_DIR/stats.nosave"   # exists = saving to the USB device is turned off (numbers in RAM only)
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

# Folder for the numbers: the ASNmanager folder of the USB device, next to the .conf backups. Empty result = no USB storage.
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

# Merges the saved numbers into the working copy - once per boot, as soon as the USB device is there.
# Saving is only allowed after this, so numbers on the USB device are never overwritten by an unmerged copy.
ts_saving() { [ ! -f "$TS_NOSAVE" ]; }
ts_mode() { [ -f "$TS_LIGHT" ] && echo iface || echo asn; }

ts_try_load() {
    [ -f "$TS_RT/loaded" ] && return 0
    if ! ts_saving; then mkdir -p "$TS_RT"; : > "$TS_RT/loaded"; return 0; fi     # saving off: nothing is read from the USB device
    dir=$(ts_store_dir) || return 1
    f="$dir/$TS_FILE"
    if [ -f "$TS_RT/reset_pending" ]; then            # a reset happened while the USB device was missing
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
    tl_i=0
    while ! mkdir "$TS_RT/lock" 2>/dev/null; do
        tl_o=$(cat "$TS_RT/lock/pid" 2>/dev/null)
        if [ -n "$tl_o" ]; then
            ts_pid_alive "$tl_o" || { rm -rf "$TS_RT/lock"; continue; }              # the owner is gone (killed)
        elif [ $tl_i -ge 3 ]; then rm -rf "$TS_RT/lock"; continue; fi               # never got an owner: left over
        tl_i=$((tl_i + 1)); [ $tl_i -ge 40 ] && { rm -rf "$TS_RT/lock"; mkdir "$TS_RT/lock" 2>/dev/null; break; }
        sleep 1
    done
    echo $$ > "$TS_RT/lock/pid" 2>/dev/null
}
ts_unlock() { rm -rf "$TS_RT/lock"; }

# a process that really runs (a finished one waiting to be collected - "zombie" - does not count)
ts_pid_alive() { [ -n "$1" ] && kill -0 "$1" 2>/dev/null && ! grep -q ') Z' "/proc/$1/stat" 2>/dev/null; }

ts_worker_running() {
    ps w 2>/dev/null | grep -q '[s]h /jffs/scripts/asn-bypass-worker.sh' && return 0
    rm -f /tmp/asn_progress.txt          # no worker is running: a progress file is left over from a killed one
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
        }' | awk -F'\t' '{ if (!($1 in pk)) o[++n] = $1; pk[$1] += $2; by[$1] += $3 } END { for (i = 1; i <= n; i++) printf "%s\t%.0f\t%.0f\n", o[i], pk[o[i]], by[o[i]] }'
}

# sums counter lines by key; zero lines of clients are dropped, rows ("...|") stay so every ASN is listed
ts_sum() { cat "$@" 2>/dev/null | awk -F'\t' 'NF == 3 { p[$1] += $2; b[$1] += $3 } END { for (k in p) if (p[k] > 0 || b[k] > 0 || k ~ /\|$/) printf "%s\t%.0f\t%.0f\n", k, p[k], b[k] }'; }

ts_bank() { # add counter lines from stdin to the working base file (zero lines are not stored)
    awk -F'\t' 'NF == 3 && ($2 > 0 || $3 > 0)' > "$TS_RT/bank.tmp"
    [ -s "$TS_RT/bank.tmp" ] || { rm -f "$TS_RT/bank.tmp"; return 0; }
    ts_sum "$TS_RT/base.txt" "$TS_RT/bank.tmp" > "$TS_RT/base.new" && mv -f "$TS_RT/base.new" "$TS_RT/base.txt"
    rm -f "$TS_RT/bank.tmp"
}

# rules of one row: TARGET KEY SET SOURCES  (KEY = ASN number or custom entry id C<n>; uses $clients)
ts_plan_row() {
    tpr_srcs=""
    for x in $(echo "$4" | tr ',' ' '); do echo "$x" | grep -qE '^[0-9]{1,3}(\.[0-9]{1,3}){3}$' && tpr_srcs="$tpr_srcs $x"; done
    echo "ASC_U_${1}_${2}" >> "$TS_RT/plan.chains"; echo "ASC_D_${1}_${2}" >> "$TS_RT/plan.chains"
    if [ -n "$tpr_srcs" ]; then
        for x in $tpr_srcs; do
            printf 'U|%s|%s|\t-A ASC_U_%s -s %s/32 -m set --match-set %s dst -g ASC_U_%s_%s\n' "$1" "$2" "$1" "$x" "$3" "$1" "$2"
            printf 'D|%s|%s|\t-A ASC_D_%s -d %s/32 -m set --match-set %s src -g ASC_D_%s_%s\n' "$1" "$2" "$1" "$x" "$3" "$1" "$2"
            printf 'U|%s|%s|%s\t-A ASC_U_%s_%s -s %s/32\n' "$1" "$2" "$x" "$1" "$2" "$x"
            printf 'D|%s|%s|%s\t-A ASC_D_%s_%s -d %s/32\n' "$1" "$2" "$x" "$1" "$2" "$x"
        done
    else
        printf 'U|%s|%s|\t-A ASC_U_%s -m set --match-set %s dst -g ASC_U_%s_%s\n' "$1" "$2" "$1" "$3" "$1" "$2"
        printf 'D|%s|%s|\t-A ASC_D_%s -m set --match-set %s src -g ASC_D_%s_%s\n' "$1" "$2" "$1" "$3" "$1" "$2"
        for ip in $clients; do
            printf 'U|%s|%s|%s\t-A ASC_U_%s_%s -s %s/32\n' "$1" "$2" "$ip" "$1" "$2" "$ip"
            printf 'D|%s|%s|%s\t-A ASC_D_%s_%s -d %s/32\n' "$1" "$2" "$ip" "$1" "$2" "$ip"
        done
    fi
}

# ---------- build the wanted rule set (plan.rules / plan.chains / plan.jumps) ----------
ts_build_plan() {
    sets=$(ipset list -n 2>/dev/null | grep -E '^ASNC?_')
    clients=$(ts_client_ips)
    tmode=$(ts_mode); okey=O; [ "$tmode" = "iface" ] && okey=ALL
    : > "$TS_RT/plan.rules"; : > "$TS_RT/plan.chains"; : > "$TS_RT/plan.jumps"

    used=$( { [ -f "$ASN_FILE" ] && awk -F':' '$1 ~ /^[0-9]+$/ { d = ($2 == "WAN") ? "WAN1" : $2; print d }' "$ASN_FILE"
              [ -f "$CUSTOM_FILE" ] && awk -F':' '$1 ~ /^C[0-9]+$/ { d = ($2 == "WAN") ? "WAN1" : $2; print d }' "$CUSTOM_FILE"; } | sort -u )
    for d in $VALID_DESTS; do
        dev=$(get_ifname "$d")
        [ -z "$dev" ] && continue
        echo " $used " | tr '\n' ' ' | grep -q " $d " || {
            case "$d" in WAN1) ;; *) [ -d "/sys/class/net/$dev" ] || continue ;; esac
        }
        echo "-A FORWARD -o $dev -j ASC_U_$d" >> "$TS_RT/plan.jumps"
        echo "-A FORWARD -i $dev -j ASC_D_$d" >> "$TS_RT/plan.jumps"
        echo "ASC_U_$d" >> "$TS_RT/plan.chains"; echo "ASC_D_$d" >> "$TS_RT/plan.chains"

        # custom entries first (their marking rules come first as well), then the ASN rules in list order
        # (first match wins) - not in the light mode
        if [ -s "$CUSTOM_FILE" ] && [ "$tmode" = "asn" ]; then
            while IFS=':' read -r cid cdest csrc ckind cval; do
                case "$cid" in C[0-9]*) ;; *) continue ;; esac
                [ "$(ts_nd "$cdest")" = "$d" ] || continue
                echo "$sets" | grep -qx "ASNC_$cid" || continue
                ts_plan_row "$d" "$cid" "ASNC_$cid" "$csrc"
            done < "$CUSTOM_FILE" >> "$TS_RT/plan.rules"
        fi
        if [ -f "$ASN_FILE" ] && [ "$tmode" = "asn" ]; then
            while IFS=':' read -r asn rdest src; do
                case "$asn" in ''|*[!0-9]*) continue ;; esac
                [ "$(ts_nd "$rdest")" = "$d" ] || continue
                set_name="ASN_${rdest}_${asn}"
                echo "$sets" | grep -qx "$set_name" || continue
                ts_plan_row "$d" "$asn" "$set_name" "$src"
            done < "$ASN_FILE" >> "$TS_RT/plan.rules"
        fi

        # everything else on this interface = "not assigned to an ASN"
        echo "ASC_U_${d}_${okey}" >> "$TS_RT/plan.chains"; echo "ASC_D_${d}_${okey}" >> "$TS_RT/plan.chains"
        {
            printf 'U|%s|%s|\t-A ASC_U_%s -g ASC_U_%s_%s\n' "$d" "$okey" "$d" "$d" "$okey"
            printf 'D|%s|%s|\t-A ASC_D_%s -g ASC_D_%s_%s\n' "$d" "$okey" "$d" "$d" "$okey"
            for ip in $clients; do
                printf 'U|%s|%s|%s\t-A ASC_U_%s_%s -s %s/32\n' "$d" "$okey" "$ip" "$d" "$okey" "$ip"
                printf 'D|%s|%s|%s\t-A ASC_D_%s_%s -d %s/32\n' "$d" "$okey" "$ip" "$d" "$okey" "$ip"
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
    for s in $(ipset list -n 2>/dev/null | grep '^ASNC_'); do
        grep -q "^${s#ASNC_}:" "$CUSTOM_FILE" 2>/dev/null || ipset destroy "$s" 2>/dev/null
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
        date -r "$CUSTOM_FILE" +%s 2>/dev/null
        ipset list -n 2>/dev/null | grep -E '^ASNC?_' | sort
        ts_client_ips | sort
        for d in $VALID_DESTS; do dev=$(get_ifname "$d"); [ -n "$dev" ] && [ -d "/sys/class/net/$dev" ] && echo "$d=$dev"; done
        ip route show 2>/dev/null | md5sum
        iptables -t mangle -S FORWARD 2>/dev/null | grep -c 'ASC_[UD]_'
        ts_mode
    } | md5sum | cut -d' ' -f1
}

# ---------- persistence ----------
# Writes base + live counters to the USB device - only if the content changed. Returns 1 if there is no USB device.
ts_save() {
    ts_ensure_rt
    ts_saving || return 1
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
    ts_pid_alive "$p" && return 0
    # not more often than every 20 s (a loop that ends at once must not be started in a circle)
    el_now=$(date +%s); el_t=$(cat "$TS_RT/loop.try" 2>/dev/null)
    [ -n "$el_t" ] && [ $((el_now - el_t)) -lt 20 ] && return 0
    echo "$el_now" > "$TS_RT/loop.try"
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
    lp=0; lpid=$(cat "$TS_RT/loop.pid" 2>/dev/null); ts_pid_alive "$lpid" && lp=1
    chn=$(iptables -t mangle -S FORWARD 2>/dev/null | grep -c 'ASC_[UD]_')
    sv=1; store=""
    if ts_saving; then store=$(ts_store_dir 2>/dev/null | tr -cd 'A-Za-z0-9._/ -'); else sv=0; fi
    saved=0; [ -n "$store" ] && saved=$(date -r "$store/$TS_FILE" +%s 2>/dev/null); case "$saved" in ''|*[!0-9]*) saved=0 ;; esac
    [ -f "$TS_RT/nets.txt" ] || ts_net_codes > "$TS_RT/nets.txt"
    nets=$(awk -F'\t' '$2 != "" { printf "%s\"%s\":\"%s\"", (n++ ? "," : ""), $1, $2 }' "$TS_RT/nets.txt" 2>/dev/null)
    if [ "$st" != "enabled" ]; then : > "$TS_RT/live.out"
    elif [ "$1" = "reuse" ] && [ -f "$TS_RT/last_live.txt" ]; then cp "$TS_RT/last_live.txt" "$TS_RT/live.out"   # loop: counters were just read
    else ts_live > "$TS_RT/live.out"; fi
    rf=/dev/null; rok=0
    if [ "$st" = "enabled" ] && [ -f "$TS_RT/rates.txt" ]; then
        rage=$(( $(date +%s) - $(date -r "$TS_RT/rates.txt" +%s 2>/dev/null || echo 0) ))
        [ "$rage" -le $((TS_INTERVAL * 3 + 5)) ] && { rf="$TS_RT/rates.txt"; rok=1; }
    fi
    tm=$(ts_mode)
    if [ "$rf" != "/dev/null" ]; then
        awk -F'\t' -v m="$tm" '{ split($1, k, "|"); if (m == "iface") { if (k[3] != "ALL") next; sub(/\|ALL\|/, "|O|") } else if (k[3] == "ALL") next; print }' "$rf" > "$TS_RT/rates.view" 2>/dev/null; rf="$TS_RT/rates.view"
    fi
    ts_sum "$TS_RT/base.txt" "$TS_RT/live.out" | awk -F'\t' -v m="$tm" '{ split($1, k, "|"); if (m == "iface") { if (k[3] != "ALL") next; sub(/\|ALL\|/, "|O|") } else if (k[3] == "ALL") next; print }' | sort | awk -F'\t' -v mode="$tm" -v ts="$(date +%s)" -v st="$st" -v since="$since" -v saved="$saved" -v store="$store" -v sv="$sv" -v lp="$lp" -v chn="$chn" -v iv="$TS_INTERVAL" -v nets="$nets" -v rok="$rok" '
        FILENAME == ARGV[1] {
            split($1, r, "|"); rid = r[2] "|" r[3]
            if (r[4] == "") { if (r[1] == "U") ru[rid] += $2; else rd[rid] += $2 }
            else { rc = rid "|" r[4]; if (r[1] == "U") cru[rc] += $2; else crd[rc] += $2 }
            next
        }
        {
            split($1, k, "|"); d = k[1]; dest = k[2]; x = k[3]; ip = k[4]
            if (dest !~ /^[A-Z0-9]+$/ || x !~ /^([0-9]+|C[0-9]+|O)$/) next
            id = dest "|" x
            if (!(id in seen)) { seen[id] = 1; order[++n] = id }
            if (ip == "") { if (d == "U") { ub[id] += $3; up[id] += $2 } else { db[id] += $3; dp[id] += $2 } ; next }
            if (ip !~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/) next
            cid = id "|" ip
            if (!(cid in cs)) { cs[cid] = 1; cl[id] = cl[id] " " ip }
            if (d == "U") { cub[cid] += $3; cup[cid] += $2 } else { cdb[cid] += $3; cdp[cid] += $2 }
        }
        END {
            printf "{\"ts\":%s,\"state\":\"%s\",\"since\":%s,\"saved\":%s,\"store\":\"%s\",\"save\":%s,\"loop\":%s,\"chains\":%s,\"mode\":\"%s\",\"interval\":%s,\"rate\":%s,\"nets\":{%s},\"rows\":[", ts, st, since, saved, store, sv, lp, chn, mode, iv, rok, nets
            for (i = 1; i <= n; i++) {
                id = order[i]; split(id, q, "|")
                printf "%s{\"dest\":\"%s\",\"asn\":\"%s\",\"ub\":%.0f,\"up\":%.0f,\"db\":%.0f,\"dp\":%.0f,\"ru\":%.0f,\"rd\":%.0f,\"cl\":[", (i > 1 ? "," : ""), q[1], q[2], ub[id], up[id], db[id], dp[id], ru[id], rd[id]
                m = split(cl[id], ips, " "); f = 0
                for (j = 1; j <= m; j++) {
                    cid = id "|" ips[j]
                    if (cub[cid] + cdb[cid] <= 0) continue
                    printf "%s[\"%s\",%.0f,%.0f,%.0f,%.0f,%.0f,%.0f]", (f++ ? "," : ""), ips[j], cub[cid], cup[cid], cdb[cid], cdp[cid], cru[cid], crd[cid]
                }
                printf "]}"
            }
            printf "]}\n"
        }' "$rf" - > "$WEB_DIR/stats.js.tmp" && mv -f "$WEB_DIR/stats.js.tmp" "$WEB_DIR/stats.js"
    rm -f "$TS_RT/live.out"
}

# ---------- suggestions: where does the traffic without a rule go? ----------
# Every minute the loop reads the kernel's connection table (byte counters per connection, the
# "nf_conntrack_acct" switch is turned on while counting runs), adds the new bytes per destination address
# and device, looks up the ASN of the busiest destinations (asn_of_ip, at most SG_LOOKUPS per minute, cached
# per /24, in the background) and writes suggest.js with the ASNs that are not in the ASN list yet. RAM only.
SG_EVERY=${SG_EVERY:-60}
SG_LOOKUPS=${SG_LOOKUPS:-10}
SG_ACCT=/proc/sys/net/netfilter/nf_conntrack_acct

sg_acct_on() {
    [ -w "$SG_ACCT" ] || return 0
    if [ "$(cat "$SG_ACCT" 2>/dev/null)" = "0" ]; then
        [ -f "$TS_RT/acct_orig" ] || echo 0 > "$TS_RT/acct_orig"
        echo 1 > "$SG_ACCT" 2>/dev/null
    fi
}
sg_acct_restore() {
    [ -f "$TS_RT/acct_orig" ] && [ -w "$SG_ACCT" ] && cat "$TS_RT/acct_orig" > "$SG_ACCT" 2>/dev/null
    rm -f "$TS_RT/acct_orig"
}
sg_clear() {
    rm -f "$TS_RT/ct_prev.txt" "$TS_RT/ct_prev.txt.new" "$TS_RT/ct_add.txt" "$TS_RT/sg_pairs.txt" "$TS_RT/sg_pairs.new" \
          "$TS_RT/sg_asn.txt" "$TS_RT/sg_fail.txt" "$TS_RT/sg_todo.txt" "$TS_RT/sg_since" "$WEB_DIR/suggest.js"
    rm -rf "$TS_RT/sg_lock"
}

# new bytes per "destination|device" since the previous sample (connections that ended in between lose their last minute)
# all IPv4 addresses of the router itself (WAN - also a private one behind another router -, LAN, VPN ...)
sg_own_ips() { ip -4 -o addr show 2>/dev/null | awk '{ split($4, a, "/"); printf "%s ", a[1] }'; }

sg_sample() {
    [ -r /proc/net/nf_conntrack ] || return 0
    awk -v prevf="$TS_RT/ct_prev.txt" -v own="$(sg_own_ips)" '
        BEGIN {
            # no previous sample yet (just enabled): only remember where the counters stand, connections that
            # existed before must not bring their old bytes along
            r = (getline l < prevf); if (r >= 0) have = 1
            while (r > 0) { split(l, a, "\t"); prev[a[1]] = a[2]; r = (getline l < prevf) }
            n = split(own, o, " "); for (i = 1; i <= n; i++) self[o[i]] = 1
        }
        {
            src = ""; dst = ""; sp = ""; dp = ""; id = ""; b1 = -1; b2 = -1; ns = 0
            for (i = 1; i <= NF; i++) {
                if ($i ~ /^src=/) { ns++; if (ns == 1) src = substr($i, 5) }
                else if ($i ~ /^dst=/) { if (dst == "") dst = substr($i, 5) }
                else if ($i ~ /^sport=/) { if (sp == "") sp = substr($i, 7) }
                else if ($i ~ /^dport=/) { if (dp == "") dp = substr($i, 7) }
                else if ($i ~ /^id=/) { if (id == "") id = substr($i, 4) }
                else if ($i ~ /^bytes=/) { if (b1 < 0) b1 = substr($i, 7) + 0; else if (b2 < 0) b2 = substr($i, 7) + 0 }
            }
            if (b1 < 0) next
            if (src !~ /^(10|192\.168|172\.(1[6-9]|2[0-9]|3[01]))\./) next
            if (src in self) next                                   # the router itself, not a device
            if (dst ~ /^(0|10|127|192\.168|169\.254|172\.(1[6-9]|2[0-9]|3[01])|22[4-9]|2[3-5][0-9])\./) next
            if (dst ~ /^100\.(6[4-9]|[7-9][0-9]|1[01][0-9]|12[0-7])\./) next
            key = $3 "|" src "|" dst "|" sp "|" dp "|" id
            tot = b1 + (b2 > 0 ? b2 : 0)
            d = ((key in prev) && tot >= prev[key]) ? tot - prev[key] : tot
            cur[key] = tot
            if (d > 0 && have) add[dst "|" src] += d
        }
        END {
            out = prevf ".new"
            for (k in cur) printf "%s\t%.0f\n", k, cur[k] > out
            for (k in add) printf "%s\t%.0f\n", k, add[k]
        }' /proc/net/nf_conntrack > "$TS_RT/ct_add.txt" 2>/dev/null
    [ -f "$TS_RT/ct_prev.txt.new" ] && mv -f "$TS_RT/ct_prev.txt.new" "$TS_RT/ct_prev.txt" || : > "$TS_RT/ct_prev.txt"
    cat "$TS_RT/sg_pairs.txt" "$TS_RT/ct_add.txt" 2>/dev/null |
        awk -F'\t' '{ s[$1] += $2 } END { for (k in s) printf "%s\t%.0f\n", k, s[k] }' |
        sort -t "$(printf '\t')" -k2,2nr | head -n 3000 > "$TS_RT/sg_pairs.new" && mv -f "$TS_RT/sg_pairs.new" "$TS_RT/sg_pairs.txt"
    rm -f "$TS_RT/ct_add.txt"
}

# looks up the ASN of the busiest destinations that are not known yet (runs in the background, one at a time)
# lock of the background lookup; a lock older than 10 minutes is left over from an interrupted run
sg_lock() {
    mkdir "$TS_RT/sg_lock" 2>/dev/null && return 0
    [ -n "$(find "$TS_RT/sg_lock" -maxdepth 0 -mmin +10 2>/dev/null)" ] || return 1
    rm -rf "$TS_RT/sg_lock"; mkdir "$TS_RT/sg_lock" 2>/dev/null
}

# up to 100 addresses with one request (ip-api batch): prints "ip<TAB>AS<num> <name>" for every answered address
sg_batch() {
    sb_body=$(awk 'BEGIN { printf "[" } NF { printf "%s\"%s\"", (n++ ? "," : ""), $1 } END { printf "]" }' "$1")
    { curl -fsSk --connect-timeout 5 -m 20 -X POST "http://ip-api.com/batch?fields=status,as,query" -d "$sb_body" 2>/dev/null; echo; } |
        sed 's/},{/}\n{/g' | while read -r sb_l; do
            sb_q=$(echo "$sb_l" | sed -n 's/.*"query":"\([0-9.]*\)".*/\1/p')
            sb_a=$(echo "$sb_l" | sed -n 's/.*"as":"\(AS[0-9][^"]*\)".*/\1/p')
            [ -n "$sb_q" ] && [ -n "$sb_a" ] && printf '%s\t%s\n' "$sb_q" "$sb_a"
        done
}

# looks up the ASN of destinations that are not known yet - all of them over time, busiest first:
# one batch request for up to 100 networks, single look-ups (with fallbacks) for what the batch could not answer
sg_resolve() {
    sg_lock || return 0
    touch "$TS_RT/sg_asn.txt" "$TS_RT/sg_fail.txt"
    now=$(date +%s)
    awk -F'\t' '{ split($1, k, "|"); s[k[1]] += $2 } END { for (i in s) printf "%s\t%.0f\n", i, s[i] }' "$TS_RT/sg_pairs.txt" 2>/dev/null |
        sort -t "$(printf '\t')" -k2,2nr |
        awk -F'\t' -v cache="$TS_RT/sg_asn.txt" -v fails="$TS_RT/sg_fail.txt" -v now="$now" '
            BEGIN {
                while ((getline l < cache) > 0) { split(l, c, "\t"); have[c[1]] = 1 }
                while ((getline l < fails) > 0) { split(l, c, "\t"); if (now - c[2] < 3600) have[c[1]] = 1 }
            }
            { split($1, o, "."); net = o[1] "." o[2] "." o[3]; if (!(net in have)) { have[net] = 1; print $1 } }' |
        head -n 100 > "$TS_RT/sg_todo.txt"
    if [ -s "$TS_RT/sg_todo.txt" ]; then
        sg_batch "$TS_RT/sg_todo.txt" > "$TS_RT/sg_got.txt"
        while IFS="$(printf '\t')" read -r sr_ip sr_as; do
            sr_a=$(echo "$sr_as" | sed -n 's/^AS\([0-9][0-9]*\).*/\1/p'); [ -n "$sr_a" ] || continue
            printf '%s\t%s\t%s\n' "${sr_ip%.*}" "$sr_a" "$(echo "$sr_as" | sed 's/^AS[0-9]* *//' | tr -cd 'A-Za-z0-9 .,&()+/_-' | cut -c1-60)" >> "$TS_RT/sg_asn.txt"
        done < "$TS_RT/sg_got.txt"
        # not answered by the batch: single look-ups with fallbacks, a few per run
        awk -F'\t' 'FILENAME == ARGV[1] { got[$1] = 1; next } !($1 in got)' "$TS_RT/sg_got.txt" "$TS_RT/sg_todo.txt" | head -n "$SG_LOOKUPS" |
        while read -r sr_ip; do
            r=$(asn_of_ip "$sr_ip")
            sr_a=$(echo "$r" | sed -n 's/^AS\([0-9][0-9]*\).*/\1/p')
            if [ -n "$sr_a" ]; then
                printf '%s\t%s\t%s\n' "${sr_ip%.*}" "$sr_a" "$(echo "$r" | sed 's/^AS[0-9]* *//' | tr -cd 'A-Za-z0-9 .,&()+/_-' | cut -c1-60)" >> "$TS_RT/sg_asn.txt"
            else
                printf '%s\t%s\n' "${sr_ip%.*}" "$(date +%s)" >> "$TS_RT/sg_fail.txt"     # try again in an hour
            fi
        done
    fi
    rm -f "$TS_RT/sg_todo.txt" "$TS_RT/sg_got.txt"
    sg_export
    rm -rf "$TS_RT/sg_lock"
}

# suggest.js: ASNs (not in the ASN list) by bytes, with the devices that use them most
sg_export() {
    [ -d "$WEB_DIR" ] || return 0
    touch "$TS_RT/sg_asn.txt" "$TS_RT/sg_pairs.txt"
    acct=0; [ "$(cat "$SG_ACCT" 2>/dev/null)" = "1" ] && acct=1
    sg_now=$(date +%s); fails=$(awk -F'\t' -v now="$sg_now" 'now - $2 < 3600' "$TS_RT/sg_fail.txt" 2>/dev/null | wc -l)
    since=$(cat "$TS_RT/sg_since" 2>/dev/null); case "$since" in ''|*[!0-9]*) since=0 ;; esac
    awk -F'\t' -v ts="$(date +%s)" -v acct="$acct" -v since="$since" -v own="$(sg_own_ips)" -v fails="$fails" '
        BEGIN { n = split(own, o, " "); for (i = 1; i <= n; i++) self[o[i]] = 1 }
        FILENAME == ARGV[1] {
            # an ASN for all devices is fully assigned; with a device list only those devices are
            n3 = split($0, a, ":"); if (a[1] !~ /^[0-9]+$/) next
            if (n3 < 3 || a[3] == "") { listed[a[1]] = 1; next }
            on[a[1]] = a[2]; osrc[a[1]] = a[3]
            m3 = split(a[3], ss, ","); for (j = 1; j <= m3; j++) cov[a[1] "|" ss[j]] = 1
            next
        }
        FILENAME == ARGV[2] { asn[$1] = $2; nm[$1] = $3; next }
        {
            split($1, k, "|"); ip = k[1]; cl = k[2]; b = $2
            if (cl in self) next                                    # collected before v2.6.3: the router itself
            split(ip, o, "."); net = o[1] "." o[2] "." o[3]
            if (!(net in asn)) { pend += b; pips[ip] = 1; next }
            a = asn[net]
            if (a in listed) next
            if ((a "|" cl) in cov) next                              # this device already uses the rule
            tot[a] += b; name[a] = nm[net]
            if (!((a "|" ip) in sip)) { sip[a "|" ip] = 1; nip[a]++ }
            if (!((a "|" cl) in scl)) { scl[a "|" cl] = 1; cls[a] = cls[a] " " cl }
            cb[a "|" cl] += b
        }
        END {
            n = 0; for (a in tot) ka[++n] = a
            for (i = 1; i <= n; i++) for (j = i + 1; j <= n; j++) if (tot[ka[j]] > tot[ka[i]]) { t = ka[i]; ka[i] = ka[j]; ka[j] = t }
            np = 0; for (p in pips) np++
            printf "{\"ts\":%s,\"acct\":%s,\"since\":%s,\"pending\":%d,\"pendb\":%.0f,\"fails\":%d,\"total\":%d,\"list\":[", ts, acct, since, np, pend, fails, n
            for (i = 1; i <= n && i <= 100; i++) {
                a = ka[i]
                printf "%s{\"asn\":\"%s\",\"name\":\"%s\",\"b\":%.0f,\"ips\":%d,\"on\":\"%s\",\"osrc\":\"%s\",\"cl\":[", (i > 1 ? "," : ""), a, name[a], tot[a], nip[a], on[a], osrc[a]
                m = split(cls[a], cc, " ")
                for (x = 1; x <= m; x++) for (y = x + 1; y <= m; y++) if (cb[a "|" cc[y]] > cb[a "|" cc[x]]) { t = cc[x]; cc[x] = cc[y]; cc[y] = t }
                for (x = 1; x <= m && x <= 40; x++) printf "%s[\"%s\",%.0f]", (x > 1 ? "," : ""), cc[x], cb[a "|" cc[x]]
                printf "],\"ncl\":%d}", m
            }
            printf "]}\n"
        }' "$ASN_FILE" "$TS_RT/sg_asn.txt" "$TS_RT/sg_pairs.txt" > "$WEB_DIR/suggest.js.tmp" 2>/dev/null && mv -f "$WEB_DIR/suggest.js.tmp" "$WEB_DIR/suggest.js"
}

# ---------- live throughput: bytes/s per counter between two loop cycles (uptime has 1/100 s resolution) ----------
ts_rates() {
    upt=$(cut -d' ' -f1 /proc/uptime 2>/dev/null)
    if [ -n "$upt" ] && [ -f "$TS_RT/rate_prev.txt" ] && [ -f "$TS_RT/last_live.txt" ]; then
        dt=$(awk -v a="$upt" -v b="$(cat "$TS_RT/rate_prev.ts" 2>/dev/null)" 'BEGIN { d = a - b; print (b != "" && d > 0.5 ? d : 0) }')
        awk -F'\t' -v dt="$dt" '
            FILENAME == ARGV[1] { p[$1] = $3; next }
            dt > 0 && ($1 in p) && $3 >= p[$1] { printf "%s\t%.0f\n", $1, ($3 - p[$1]) / dt }' \
            "$TS_RT/rate_prev.txt" "$TS_RT/last_live.txt" > "$TS_RT/rates.new" 2>/dev/null && mv -f "$TS_RT/rates.new" "$TS_RT/rates.txt"
    fi
    [ -f "$TS_RT/last_live.txt" ] && cp -f "$TS_RT/last_live.txt" "$TS_RT/rate_prev.txt" && echo "$upt" > "$TS_RT/rate_prev.ts"
}
ts_rates_clear() { rm -f "$TS_RT/rates.txt" "$TS_RT/rates.new" "$TS_RT/rate_prev.txt" "$TS_RT/rate_prev.ts"; }

# ---------- background loop: follows ASN / client / interface changes, refreshes stats.js, saves hourly ----------
ts_loop() {
    mkdir -p "$TS_RT"
    ts_rates_clear
    sg_acct_on
    [ -s "$TS_RT/sg_since" ] || date +%s > "$TS_RT/sg_since"
    last_sg=0
    echo $$ > "$TS_RT/loop.pid"
    last_save=$(date +%s)
    while [ "$(ts_state)" = "enabled" ] && [ "$(cat "$TS_RT/loop.pid" 2>/dev/null)" = "$$" ]; do
        nvc=$((nvc + 1)); [ $((nvc % 6)) -eq 1 ] && nv_refresh        # the WAN values: now and then a minute (they hardly ever change)
        sig=$(ts_signature)
        if [ "$sig" != "$(cat "$TS_RT/sig" 2>/dev/null)" ]; then
            ts_lock; ts_sync >/dev/null 2>&1 && echo "$sig" > "$TS_RT/sig"; ts_unlock
        else
            ts_live > "$TS_RT/last_live.txt"
        fi
        ts_rates
        ts_export reuse
        cu_learned_js >/dev/null 2>&1
        now=$(date +%s)
        if [ $((now - last_save)) -ge "$TS_SAVE_EVERY" ]; then ts_save; last_save=$now; fi
        if [ $((now - last_sg)) -ge "$SG_EVERY" ]; then
            sg_sample; sg_export
            ( sg_resolve ) >/dev/null 2>&1 &
            last_sg=$now
        fi
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
    ts_lock                      # enable / disable / reset can arrive at the same time (WebUI events run in the background)
    ts_set_state enabled
    [ -s "$TS_RT/since" ] || date +%s > "$TS_RT/since"
    rm -f "$TS_RT/sig"
    ts_hooks_add
    ts_export                    # the page sees "enabled" at once
    # a running rule rebuild is not waited for: the loop sets the counting up as soon as it is finished
    ts_sync; rc=$?
    [ $rc -eq 0 ] && ts_signature > "$TS_RT/sig"
    ts_start_loop
    ts_unlock
    ts_export
    if [ $rc -eq 0 ]; then echo "Traffic statistics enabled."
    elif ts_worker_running; then echo "Traffic statistics enabled - counting starts when the running rule rebuild is finished."
    else echo "Traffic statistics enabled, but the rule setup reported an error (run: ASNmanager.sh stats repair)."; fi
}

ts_disable() {
    ts_ensure_rt; ts_lock
    ts_set_state disabled
    ts_stop_loop
    ts_live | ts_bank            # keep the numbers
    ts_rates_clear
    sg_acct_restore; sg_clear
    ts_remove_rules
    rm -f "$TS_RT/last_live.txt" "$TS_RT/sig"
    ts_hooks_del
    ts_unlock
    if ts_save; then echo "Traffic statistics disabled, numbers kept and saved on the USB device."
    elif ! ts_saving; then echo "Traffic statistics disabled, numbers kept in RAM (saving to the USB device is turned off)."
    else echo "Traffic statistics disabled, numbers kept in RAM (no USB device found: not saved)."; fi
    ts_export
}

ts_reset() {
    ts_ensure_rt; ts_lock
    ts_set_state disabled
    ts_stop_loop
    ts_remove_rules
    rm -f "$TS_RT/base.txt" "$TS_RT/last_live.txt" "$TS_RT/sig" "$TS_RT/since"
    ts_rates_clear
    sg_acct_restore; sg_clear
    d=$(ts_store_dir)
    if [ -n "$d" ]; then
        rm -f "$d/$TS_FILE" "$TS_RT/reset_pending"; : > "$TS_RT/loaded"
    else                                            # stick missing: delete the file as soon as it is back
        : > "$TS_RT/reset_pending"; rm -f "$TS_RT/loaded"
    fi
    rm -rf "$TS_LEGACY"
    ts_hooks_del
    ts_unlock
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
    ts_save && rm -rf "$TS_LEGACY"   # remove the old folder only when the numbers are on the USB device
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

# stats diag: where does the statistics module hang? (one command, no changes)
ts_diag() {
    echo "== ASN Manager traffic statistics - diagnosis"
    td_now=$(date +%s)
    echo "[INFO] router time:      $(date '+%Y-%m-%d %H:%M:%S') (epoch $td_now)"
    echo "[INFO] state / mode:     $(ts_state) / $(ts_mode)"
    td_lp=$(cat "$TS_RT/loop.pid" 2>/dev/null)
    if ts_pid_alive "$td_lp"; then echo "[OK]   counting loop:    running (pid $td_lp)"
    elif [ "$(ts_state)" = "enabled" ]; then echo "[WARN] counting loop:    NOT running although the statistics are on (try: stats repair)"
    else echo "[INFO] counting loop:    not running (statistics are off)"; fi
    if [ -d "$TS_RT/lock" ]; then
        td_lo=$(cat "$TS_RT/lock/pid" 2>/dev/null)
        if ts_pid_alive "$td_lo"; then echo "[WARN] lock:             held by process $td_lo (running) - a step may be stuck: $(tr '\0' ' ' < /proc/$td_lo/cmdline 2>/dev/null | cut -c1-80)"
        else echo "[WARN] lock:             left over (owner ${td_lo:-unknown} is gone) - is removed by the next action (or: rescue)"; fi
    else echo "[OK]   lock:             none"; fi
    td_ts=$(sed -n 's/.*"ts":\([0-9][0-9]*\).*/\1/p' "$WEB_DIR/stats.js" 2>/dev/null | head -n 1)
    if [ -n "$td_ts" ]; then echo "[INFO] stats.js:         written $((td_now - td_ts)) s ago (the page reads this file)"
    else echo "[WARN] stats.js:         missing - the page has nothing to show (try: stats enable / refresh)"; fi
    if ts_worker_running; then echo "[INFO] rule rebuild:     running right now (counting waits for it)"; else echo "[OK]   rule rebuild:     not running"; fi
    echo "[INFO] counting rules:   $(iptables -t mangle -S 2>/dev/null | grep -c '^-A ASC_') (chains in FORWARD: $(iptables -t mangle -S FORWARD 2>/dev/null | grep -c 'ASC_[UD]_'))"
    if grep -q "asnmanager" /jffs/scripts/service-event 2>/dev/null; then echo "[OK]   service-event:    hook present"; else echo "[FAIL] service-event:    hook for the WebUI buttons is missing (try: webui install)"; fi
    td_old=0; td_all=0
    for td_p in $(ps w 2>/dev/null | grep -E 'ASNmanager\.sh|asn-bypass' | grep -v grep | awk '{ print $1 }'); do
        [ "$td_p" = "$$" ] && continue
        [ -d "/proc/$td_p" ] || continue                              # a helper of this command that is already gone
        td_c=$(tr '\0' ' ' 2>/dev/null < /proc/$td_p/cmdline)
        td_a=$(proc_age "$td_p")
        if [ -z "$td_c" ]; then                                        # finished, its parent has not collected it yet
            echo "                        pid $td_p: finished, not yet collected by its parent (harmless)"; continue
        fi
        case "$td_c" in *"ASNmanager.sh ")                                 # the menu in an SSH window
            echo "                        pid $td_p, running $td_a s: an open menu (SSH window) - leave it with [e]"; continue ;; esac
        td_all=$((td_all + 1)); [ "$td_a" -gt 900 ] && td_old=$((td_old + 1))
        echo "                        pid $td_p, running $td_a s: $(echo "$td_c" | cut -c1-70)"
    done
    if [ $td_old -gt 0 ]; then echo "[WARN] processes:        $td_old of $td_all ASN Manager runs take more than 15 minutes (hanging) - cleaned up by the next routing check, or now with: rescue"
    else echo "[OK]   processes:        $td_all ASN Manager run(s) in progress, none hanging"; fi
    echo "[INFO] timing:           the next line shows how long one export of the page data takes"
    td_t0=$(date +%s); ts_export >/dev/null 2>&1; echo "                         $(( $(date +%s) - td_t0 )) s"
}

# Repair: keeps the numbers, throws away every temporary file and set-up of the counting and builds it again
ts_repair() {
    ts_ensure_rt
    ts_lock
    if [ "$(ts_state)" = "enabled" ]; then
        ts_stop_loop
        ts_live | ts_bank                       # keep what was counted so far
        ts_save >/dev/null 2>&1
        ts_remove_rules
    fi
    rm -f /tmp/asn_progress.txt "$TS_RT/sig" "$TS_RT/last_live.txt" "$TS_RT/live.txt" "$TS_RT/live.out" "$TS_RT/loop.try" "$TS_RT"/plan.* \
          "$TS_RT/rates.txt" "$TS_RT/rates.new" "$TS_RT"/rate_prev.* "$TS_RT"/ct_prev.txt* "$TS_RT/saved.tmp" "$TS_RT/base.new"
    rm -rf "$TS_RT"/sg_*
    if [ "$(ts_state)" != "enabled" ]; then
        ts_unlock; ts_export
        echo "Traffic statistics are off - temporary files cleaned."
        return 0
    fi
    ts_worker_running || true
    ts_sync; rc=$?
    [ $rc -eq 0 ] && ts_signature > "$TS_RT/sig"
    ts_start_loop
    ts_unlock
    ts_export
    if [ $rc -eq 0 ]; then echo "Traffic statistics repaired - counting is set up again, the numbers are kept."
    else echo "Traffic statistics repaired - counting starts when the running rule rebuild is finished."; fi
}

# statistics detail: asn (per ASN, per interface and device) | iface (per interface and device only - much cheaper)
ts_set_mode() {
    case "$1" in
        asn)   rm -f "$TS_LIGHT" ;;
        iface) mkdir -p "$ADDON_DIR"; : > "$TS_LIGHT" ;;
        *)     echo "Statistics detail: $(ts_mode)   (usage: stats mode asn | iface)"; return 0 ;;
    esac
    if [ "$(ts_state)" = "enabled" ]; then
        ts_ensure_rt; ts_lock
        ts_sync && ts_signature > "$TS_RT/sig"
        ts_unlock
    fi
    ts_export
    if [ "$1" = "iface" ]; then echo "Statistics: per interface and device only (no counting rule per ASN)."
    else echo "Statistics: per ASN, interface and device."; fi
}

# saving to the USB device: on | off
ts_save_mode() {
    case "$1" in
        off)
            mkdir -p "$ADDON_DIR"; : > "$TS_NOSAVE"
            echo "Saving to the USB device turned off - the numbers are kept in RAM only." ;;
        on)
            rm -f "$TS_NOSAVE"
            ts_ensure_rt; : > "$TS_RT/loaded"          # the current numbers are written now (an older file is replaced)
            if ts_save; then echo "Saving to the USB device turned on - numbers saved."
            else echo "Saving to the USB device turned on - no USB device found yet."; fi ;;
        *)  if ts_saving; then echo "Saving to the USB device: on"; else echo "Saving to the USB device: off"; fi; return 0 ;;
    esac
    ts_export
}

# complete removal (uninstall); the .conf backups on the USB device are left alone
ts_purge() {
    ts_stop_loop
    sg_acct_restore; sg_clear
    ts_remove_rules
    ts_hooks_del
    d=$(ts_store_dir 2>/dev/null); [ -n "$d" ] && rm -f "$d/$TS_FILE"
    rm -rf "$TS_RT" "$TS_LEGACY" "$WEB_DIR/stats.js" "$TS_NOSAVE"
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
    if ! ts_saving; then echo "[INFO] saving to the USB device is turned off - numbers are kept in RAM only"
    elif [ -n "$d" ]; then echo "[OK]   numbers are saved in: $d/$TS_FILE"
    else echo "[WARN] no USB device found - numbers are kept in RAM only and are lost on reboot"; fi
}

# service events from the WebUI (start_asnmanagerstats<action>)
ts_event() {
    case "$1" in
        enable)  ts_enable ;;
        disable) ts_disable ;;
        reset)   ts_reset ;;
        repair)  ts_repair ;;
        refresh) ts_ensure_loop; ts_export ;;
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
        saving)  ts_save_mode "$2" ;;
        diag)    ts_diag ;;
        mode)    ts_set_mode "$2" ;;
        repair)  ts_repair ;;
        boot)    ts_boot ;;
        loop)    ts_loop ;;
        *)       echo "Usage: stats enable | disable | reset | show | unknown | probe | diag | saving on|off | mode asn|iface | repair"; return 1 ;;
    esac
}

# =====================================================================
#  SSH menu: edit, routing check, failover, job status (the same functions as the WebUI / command line)
# =====================================================================
menu_pause() { echo "" && echo -n "Press Enter to return..." && read -r _; }

edit_menu() {
    clear
    echo -e "${YELLOW}--- Edit entry (target / source devices) ---${NC}"
    em_list=/tmp/asnm_edit_list.txt
    { [ -s "$ASN_FILE" ] && cat "$ASN_FILE"; [ -s "$CUSTOM_FILE" ] && awk -F: '{ print $1 ":" $2 ":" $3 }' "$CUSTOM_FILE"; } > "$em_list"
    if [ ! -s "$em_list" ]; then echo "The list is empty."; menu_pause; return; fi
    em_i=0
    while IFS=':' read -r em_a em_d em_s; do
        [ -n "$em_a" ] || continue
        em_i=$((em_i + 1))
        case "$em_a" in C[0-9]*) em_lbl="$em_a $(cu_label "$em_a")" ;; *) em_lbl="AS$em_a" ;; esac
        printf " [%2d] %-30s -> %-5s  %s\\n" "$em_i" "$em_lbl" "$em_d" "${em_s:-(all devices)}"
    done < "$em_list"
    echo " [0]  Cancel"
    echo -n "Select the entry to edit: "; read -r em_n
    case "$em_n" in ''|0|*[!0-9]*) return ;; esac
    em_line=$(sed -n "${em_n}p" "$em_list"); [ -n "$em_line" ] || return
    em_asn=${em_line%%:*}; em_rest=${em_line#*:}; em_dest=${em_rest%%:*}; em_src=${em_rest#*:}
    [ "$em_src" = "$em_rest" ] && em_src=""
    case "$em_asn" in C[0-9]*) em_lbl="$em_asn $(cu_label "$em_asn")" ;; *) em_lbl="AS$em_asn" ;; esac
    echo -e "\\n${em_lbl}: target ${CYAN}${em_dest}${NC}, source devices ${CYAN}${em_src:-all devices}${NC}"
    prompt_destination
    [ "$SELECTED_DEST" = "CANCEL" ] && return
    echo -n "Source IP(s) [Enter = keep '${em_src:-all devices}', '-' = all devices, e.g. 192.168.1.50,192.168.1.60]: "
    read -r em_new
    case "$em_new" in "") em_new=$em_src ;; -) em_new="" ;; esac
    em_new=$(norm_src "$em_new")
    if ! is_valid_src "$em_new"; then echo -e "${RED}Invalid IP format - nothing changed.${NC}"; menu_pause; return; fi
    cli_edit "$em_asn" "$SELECTED_DEST" "$em_new"
    [ -f "$ADDON_DIR/webui_page" ] && web_export >/dev/null 2>&1
    echo "Use [7] to apply the rules."
    menu_pause
}

check_menu() {
    clear
    echo -e "${YELLOW}--- Routing check & tunnel protection ---${NC}"
    echo "Checking every ASN (sample address, marking rule, interface, kernel route) ..."
    echo ""
    rc_print
    ep_list >/dev/null 2>&1
    [ -s "$EP_CACHE" ] || echo "[INFO] no VPN client with a server address found (tunnel protection not needed)"
    menu_pause
}

# chooser for a fallback: sets FO_PICK to a target, BLOCK or "" (none)
fo_pick() {
    echo ""
    echo -e "${YELLOW}$1${NC}"
    echo " [1]  WAN1   [2]  WAN2"
    echo " [3]  OVPN1  [4]  OVPN2  [5]  OVPN3  [6]  OVPN4  [7]  OVPN5"
    echo " [8]  WGC1   [9]  WGC2   [10] WGC3   [11] WGC4   [12] WGC5"
    echo " [b]  Block (kill switch)      [Enter] none"
    echo -n "Choice: "; read -r fp_c
    case "$fp_c" in
        1) FO_PICK=WAN1 ;; 2) FO_PICK=WAN2 ;; 3) FO_PICK=OVPN1 ;; 4) FO_PICK=OVPN2 ;; 5) FO_PICK=OVPN3 ;; 6) FO_PICK=OVPN4 ;; 7) FO_PICK=OVPN5 ;;
        8) FO_PICK=WGC1 ;; 9) FO_PICK=WGC2 ;; 10) FO_PICK=WGC3 ;; 11) FO_PICK=WGC4 ;; 12) FO_PICK=WGC5 ;;
        b|B) FO_PICK=BLOCK ;; *) FO_PICK="" ;;
    esac
}

failover_menu() {
    while true; do
        clear
        echo -e "${YELLOW}--- Failover chains ---${NC}"
        echo "If a target fails (checked every 30 s), its ASNs use the next working fallback."
        echo ""
        fo_show
        echo ""
        echo " [1]  Set or change a chain"
        echo " [2]  Remove a chain"
        echo " [3]  Check all chains now"
        echo " [0]  Back"
        echo -n "Select an option: "; read -r fm_c
        case "$fm_c" in
            1)
                echo -e "\nTarget whose ASNs get a failover:"
                prompt_destination
                [ "$SELECTED_DEST" = "CANCEL" ] && continue
                fm_t=$SELECTED_DEST
                fo_pick "1st fallback for ${fm_t}:"; fm_1=$FO_PICK
                fm_2=""
                if [ -n "$fm_1" ] && [ "$fm_1" != "BLOCK" ]; then fo_pick "2nd fallback for ${fm_t} (optional):"; fm_2=$FO_PICK; fi
                echo ""
                fo_set "$fm_t" "$(echo "${fm_1},${fm_2}" | sed 's/^,//; s/,$//')"
                [ -f "$ADDON_DIR/webui_page" ] && web_export >/dev/null 2>&1
                menu_pause ;;
            2)
                if [ ! -s "$FO_CONF" ]; then echo "No chain configured."; menu_pause; continue; fi
                fm_i=0
                while IFS='=' read -r fm_a fm_b; do fm_i=$((fm_i + 1)); echo " [$fm_i]  $fm_a -> $(echo "$fm_b" | sed 's/,/ -> /g')"; done < "$FO_CONF"
                echo -n "Remove which chain? "; read -r fm_n
                case "$fm_n" in ''|0|*[!0-9]*) continue ;; esac
                fm_t=$(sed -n "${fm_n}p" "$FO_CONF" | cut -d= -f1)
                [ -n "$fm_t" ] && fo_set "$fm_t" ""
                menu_pause ;;
            3)
                echo ""; echo "Checking ..."; fo_round_safe >/dev/null 2>&1; fo_show; menu_pause ;;
            *) return ;;
        esac
    done
}

speed_menu() {
    clear
    echo -e "${YELLOW}--- Speed test of a target interface ---${NC}"
    echo "Measures download, upload and ping through exactly one interface (about 30 seconds, up to ~200 MB download"
    echo "and ~100 MB upload through that interface). The result is also shown in the WebUI."
    echo ""
    echo " [1]  One target"
    echo " [2]  All online targets"
    echo " [0]  Back"
    echo -n "Select an option: "; read -r sm_c
    case "$sm_c" in
        1)
            prompt_destination
            [ "$SELECTED_DEST" = "CANCEL" ] && return
            echo ""; echo "Testing ${SELECTED_DEST} ..."; st_run "$SELECTED_DEST"
            menu_pause ;;
        2)
            echo ""; st_cli all
            menu_pause ;;
    esac
}

job_menu() {
    clear
    echo -e "${YELLOW}--- Job status & rescue ---${NC}"
    cli_job
    echo ""
    echo " [1]  Rescue: stop stuck jobs, remove locks, restart failover and statistics"
    echo " [2]  Remove the job lock only"
    echo " [0]  Back"
    echo -n "Select an option: "; read -r jm_c
    case "$jm_c" in
        1) echo ""; cli_rescue; menu_pause ;;
        2) cli_job clear; menu_pause ;;
    esac
}

# ---------- rescue: stop stuck jobs, remove locks, restart failover and statistics ----------
cli_rescue() {
    echo "Stopping ASN Manager jobs that are still running ..."
    # only processes that execute the script or the worker (not e.g. an editor that has the file open);
    # the statistics loop and this call itself stay
    for rd in /proc/[0-9]*; do
        rp=${rd#/proc/}; [ "$rp" = "$$" ] && continue
        rcl=$(cat "$rd/cmdline" 2>/dev/null | tr '\000' ' ')
        case "$rcl" in *" rescue"*|"") continue ;; esac
        [ "$rp" = "$(cat "$TS_RT/loop.pid" 2>/dev/null)" ] && continue          # the counting loop itself keeps running
        case "$rcl" in */jffs/scripts/ASNmanager.sh\ ) continue ;; esac            # an interactive menu (no arguments)
        case "$rcl" in
            /jffs/scripts/ASNmanager.sh*|/jffs/scripts/asn-bypass-worker.sh*) ;;
            *sh\ /jffs/scripts/ASNmanager.sh*|*sh\ /jffs/scripts/asn-bypass-worker.sh*) ;;
            *) continue ;;
        esac
        kill "$rp" 2>/dev/null && echo "  stopped: $(echo "$rcl" | cut -c1-70)"
    done
    sleep 1
    rm -rf "$LOCK_DIR" "$FO_RT/lock" "$TS_RT/lock" "$ST_RT/lock" /tmp/asn_progress.txt
    st_cleanup 2>/dev/null                                   # temporary rules / route of an interrupted speed test
    echo "Locks removed."
    fo_cron_sync >/dev/null 2>&1; fo_round_safe >/dev/null 2>&1
    ts_ensure_loop >/dev/null 2>&1
    [ -f "$ADDON_DIR/webui_page" ] && web_export >/dev/null 2>&1
    echo "Done. If a rule rebuild was stopped, apply the rules again (menu [7] or WebUI)."
}

# ---------- install (also called by the one-line installer) ----------
cli_install() {
    chmod 755 "$SCRIPT_PATH" 2>/dev/null
    [ -f "$ASN_FILE" ] || : > "$ASN_FILE"
    webui_auto
    echo "ASN Manager v${SCRIPT_VERSION} installed: $SCRIPT_PATH"
    if [ -t 0 ] && [ -t 1 ]; then sleep 1; exec "$SCRIPT_PATH"; fi
    echo "Open the menu with: $SCRIPT_PATH"
}

# ---------- amtm: "amtmupdate check" -> 0 = amtm may update this script; "amtmupdate" -> update, exit 0 / 1 ----------
cli_amtmupdate() {
    echo "  i  Running function amtmupdate"
    au_out=$(cli_update 2>&1); au_rc=$?
    au_ver=$(sed -n 's/^version=//p' "$SCRIPT_PATH" 2>/dev/null | head -n 1)
    if [ $au_rc -eq 0 ]; then
        echo "  ✔  ASN Manager ${au_ver:-$SCRIPT_VERSION} amtmupdate complete"
        return 0
    fi
    echo "  ✖  ASN Manager amtmupdate failed: $(echo "$au_out" | tail -n 1)"
    return 1
}

# =====================================================================
#  Speed test of one target interface (manual). The test traffic is sent from the address of the interface; a
#  temporary routing rule (priority 9860, removed afterwards) makes it leave through exactly that interface.
#  Download and upload each run for ST_SECS seconds with ST_STREAMS parallel connections to speed.cloudflare.com,
#  latency is measured with ping. Results stay in RAM.
# =====================================================================
ST_RT="/tmp/${WEBUI_NS}-speed"
ST_PRIO=9860
ST_DOWN_URL=${ST_DOWN_URL:-"https://speed.cloudflare.com/__down?bytes=50000000"}
ST_UP_URL=${ST_UP_URL:-"https://speed.cloudflare.com/__up"}
ST_PING=${ST_PING:-1.1.1.1}
ST_SECS=${ST_SECS:-8}
ST_STREAMS=${ST_STREAMS:-4}

st_cleanup() {
    while ip rule del prio "$ST_PRIO" 2>/dev/null; do :; done
    while ip rule del prio "$((ST_PRIO + 1))" 2>/dev/null; do :; done
    if [ -f "$ST_RT/route" ]; then
        read -r sc_dev sc_tab < "$ST_RT/route"
        [ -n "$sc_dev" ] && ip route del default dev "$sc_dev" table "$sc_tab" 2>/dev/null
        rm -f "$ST_RT/route"
    fi
    rm -f "$ST_RT/up.bin" "$ST_RT"/s_*
}

# one connection of the test: repeats the request until the time is up, writes "<bytes> <seconds>" lines
st_stream() {
    ss_end=$(( $(date +%s) + ST_SECS ))
    while :; do
        ss_left=$(( ss_end - $(date +%s) )); [ $ss_left -lt 1 ] && break
        if [ "$1" = "d" ]; then
            ss_r=$(curl -s -k --interface "$st_ip" --connect-timeout 5 -m "$ss_left" -o /dev/null -w '%{size_download} %{time_total}' "$ST_DOWN_URL" 2>/dev/null)
        else
            ss_r=$(curl -s -k --interface "$st_ip" --connect-timeout 5 -m "$ss_left" -X POST --data-binary "@$ST_RT/up.bin" -H 'Content-Type: application/octet-stream' -o /dev/null -w '%{size_upload} %{time_total}' "$ST_UP_URL" 2>/dev/null)
        fi
        echo "$ss_r" >> "$ST_RT/s_$1$2"
        case "$ss_r" in ""|"0 "*) break ;; esac
    done
}

# sum over the connections of "bytes / seconds"
st_sum() { for sm_f in "$ST_RT"/s_$1*; do [ -f "$sm_f" ] && awk '{ b += $1; t += $2 } END { if (t > 0) printf "%.0f\n", b / t }' "$sm_f"; done | awk '{ s += $1 } END { printf "%.0f", s }'; }

st_run() {
    st_t=$(norm_dest "$1") || { echo "Invalid target '$1'"; return 1; }
    mkdir -p "$ST_RT"
    if ! mkdir "$ST_RT/lock" 2>/dev/null; then
        [ -n "$(find "$ST_RT/lock" -maxdepth 0 -mmin +3 2>/dev/null)" ] || { echo "A speed test is already running."; return 1; }
        rm -rf "$ST_RT/lock"; mkdir "$ST_RT/lock" 2>/dev/null || return 1
    fi
    st_err=""; st_down=0; st_up=0; st_lat=""; st_ip=""
    check_iface_up "$st_t" || st_err="offline"
    st_dev=$(get_ifname "$st_t")
    if [ -z "$st_err" ]; then
        st_ip=$(ip -4 -o addr show dev "$st_dev" 2>/dev/null | awk '{ split($4, a, "/"); print a[1]; exit }')
        [ -n "$st_ip" ] || st_err="noaddr"
    fi
    if [ -z "$st_err" ]; then
        st_tab=$(fo_tname "$(fo_info "$st_t" | cut -d' ' -f1)")
        st_cleanup
        # a VPN client without ASN rules has no default route in its table yet
        if [ -z "$(ip route show table "$st_tab" 2>/dev/null)" ]; then
            ip route add default dev "$st_dev" table "$st_tab" 2>/dev/null && echo "$st_dev $st_tab" > "$ST_RT/route"
        fi
        ip rule add from "$st_ip/32" lookup "$st_tab" prio "$ST_PRIO" 2>/dev/null || st_err="rule"
        # if that table has no usable route the test must fail - never fall back to another interface
        [ -n "$st_err" ] || ip rule add from "$st_ip/32" unreachable prio "$((ST_PRIO + 1))" 2>/dev/null
    fi
    if [ -z "$st_err" ]; then
        st_via=$(ip route get "$ST_PING" from "$st_ip" 2>/dev/null | sed -n 's/.* dev \([^ ]*\).*/\1/p' | head -n 1)
        [ "$st_via" = "$st_dev" ] || st_err="route"
    fi
    if [ -z "$st_err" ]; then
        st_lat=$(ping -c 4 -W 2 -I "$st_ip" "$ST_PING" 2>/dev/null | sed -n 's/.*= [0-9.]*\/\([0-9.]*\)\/.*/\1/p')
        si=1; while [ $si -le "$ST_STREAMS" ]; do st_stream d $si & si=$((si + 1)); done; wait
        st_down=$(st_sum d)
        head -c 8000000 /dev/urandom > "$ST_RT/up.bin" 2>/dev/null
        si=1; while [ $si -le "$ST_STREAMS" ]; do st_stream u $si & si=$((si + 1)); done; wait
        st_up=$(st_sum u)
        [ "${st_down:-0}" -gt 0 ] || [ "${st_up:-0}" -gt 0 ] || st_err="fail"
    fi
    st_cleanup
    printf '%s %s %s %s %s\n' "${st_down:-0}" "${st_up:-0}" "${st_lat:-0}" "$(date +%s)" "${st_err:--}" > "$ST_RT/res_$st_t"
    rm -rf "$ST_RT/lock"
    st_export
    case "$st_err" in
        "")      echo "$st_t: down $(awk -v b="$st_down" 'BEGIN { printf "%.1f", b * 8 / 1000000 }') Mbit/s, up $(awk -v b="$st_up" 'BEGIN { printf "%.1f", b * 8 / 1000000 }') Mbit/s, ping ${st_lat:--} ms" ;;
        offline) echo "$st_t: the interface is offline - no speed test possible."; return 1 ;;
        noaddr)  echo "$st_t: the interface has no IPv4 address - no speed test possible."; return 1 ;;
        rule)    echo "$st_t: could not set up the temporary routing rule."; return 1 ;;
        route)   echo "$st_t: no usable route through this interface (tunnel down?) - no speed test possible."; return 1 ;;
        *)       echo "$st_t: no data could be transferred through this interface (no internet or the test server is not reachable)."; return 1 ;;
    esac
}

st_export() {
    [ -d "$WEB_DIR" ] || return 0
    {
        printf '{"res":{'
        for sx_f in "$ST_RT"/res_*; do
            [ -f "$sx_f" ] || continue
            read -r sx_d sx_u sx_l sx_ts sx_e < "$sx_f"
            printf '%s"%s":{"d":%s,"u":%s,"l":%s,"ts":%s,"e":"%s"}' "${sx_n:+,}" "${sx_f##*/res_}" "${sx_d:-0}" "${sx_u:-0}" "${sx_l:-0}" "${sx_ts:-0}" "${sx_e:--}"
            sx_n=1
        done
        printf '}}\n'
    } > "$WEB_DIR/speedtest.js.tmp" && mv -f "$WEB_DIR/speedtest.js.tmp" "$WEB_DIR/speedtest.js"
    sx_n=""
}

# speedtest <TARGET|all>
st_cli() {
    [ -n "$1" ] || { echo "Usage: speedtest <TARGET|all>   e.g. speedtest WGC1"; return 1; }
    if [ "$1" = "all" ]; then
        for sa_d in $VALID_DESTS; do check_iface_up "$sa_d" && { st_run "$sa_d"; }; done
        return 0
    fi
    st_run "$1"
}

# =====================================================================
#  Tunnel protection: the server address of every VPN client always uses the normal routing table (WAN).
#  An "ip rule to <server> lookup main" with a higher priority than all ASN rules (and than a failover "Block")
#  keeps a tunnel from being routed into itself, e.g. when an ASN for "all devices" contains the VPN server.
#  Server names are resolved and cached for an hour. Runs after "apply", with the routing check and at the end
#  of every worker run.
# =====================================================================
EP_PRIO=9880
EP_CACHE="/tmp/${WEBUI_NS}-ep.txt"

# "<ip> <client>" for every configured VPN client
ep_list() {
    # the configured servers are read every time (cheap) - a new or changed VPN client is protected right away;
    # only the name resolution is reused for an hour while the configuration stays the same
    ep_raw=$(for ep_u in 1 2 3 4 5; do
        ep_h=$(nvram get "wgc${ep_u}_ep_addr" 2>/dev/null); [ -n "$ep_h" ] && echo "WGC$ep_u $ep_h"
        ep_h=$(nvram get "vpn_client${ep_u}_addr" 2>/dev/null); [ -n "$ep_h" ] && echo "OVPN$ep_u $ep_h"
    done)
    if [ -f "$EP_CACHE" ] && [ "$ep_raw" = "$(cat "$EP_CACHE.src" 2>/dev/null)" ] && [ -z "$(find "$EP_CACHE" -mmin +60 2>/dev/null)" ]; then
        cat "$EP_CACHE"; return 0
    fi
    echo "$ep_raw" | while read -r ep_who ep_h; do
        [ -n "$ep_h" ] || continue
        if is_valid_ip "$ep_h"; then echo "$ep_h $ep_who"
        else
            nsl "$ep_h" 2>/dev/null | awk -v w="$ep_who" '/^Name:/ { n = 1 }
                n && /^Address/ { for (i = 2; i <= NF; i++) if ($i ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/) print $i, w }'
        fi
    done | sort -u > "$EP_CACHE.tmp" && mv -f "$EP_CACHE.tmp" "$EP_CACHE"
    echo "$ep_raw" > "$EP_CACHE.src"
    cat "$EP_CACHE"
}

ep_guard_sync() {
    ep_want=$(ep_list | cut -d' ' -f1 | sort -u)
    ep_have=$(ip rule show 2>/dev/null | awk -v p="$EP_PRIO:" '$1 == p { for (i = 1; i <= NF; i++) if ($i == "to") print $(i + 1) }' | sed 's#/32$##' | sort -u)
    [ "$ep_want" = "$ep_have" ] && return 0
    while ip rule del prio "$EP_PRIO" 2>/dev/null; do :; done
    for ep_ip in $ep_want; do ip rule add to "$ep_ip/32" lookup main prio "$EP_PRIO" 2>/dev/null; done
    return 0
}

ep_show() {
    ep_guard_sync
    [ -s "$EP_CACHE" ] || { echo "No VPN client with a server address found."; return 0; }
    while read -r ep_ip ep_who; do echo "[OK]   VPN server $ep_ip ($ep_who) always goes via WAN"; done < "$EP_CACHE"
}

ep_purge() { while ip rule del prio "$EP_PRIO" 2>/dev/null; do :; done; rm -f "$EP_CACHE" "$EP_CACHE.tmp" "$EP_CACHE.src"; }

# =====================================================================
#  Failover: a chain per target interface, e.g. WGC1=WGC2,WAN1 or WGC1=WGC2,BLOCK.
#  Every 30 s each interface of a chain is probed (address + ping through the interface); after 2 failed probes
#  in a row it counts as down, after 2 good ones as up again. The ip rule of the target's fwmark is pointed at the
#  routing table of the first working member - the ASN sets and marking rules stay untouched. BLOCK = no traffic
#  (kill switch). If nothing in the chain works, the rule stays on the target. Config on /jffs, state in RAM.
# =====================================================================
FO_CONF="$ADDON_DIR/failover.conf"
FO_RT="/tmp/${WEBUI_NS}-fo"
FO_PROBES=${FO_PROBES:-"1.1.1.1 9.9.9.9"}
FO_INTERVAL=${FO_INTERVAL:-30}
FO_HOOK="ASNmanager-Failover"
FO_SELF_PRIO=9870      # "iif lo fwmark X lookup main": the router itself is not blocked (updates, downloads, checks)

fo_info() {   # table fwmark prio - same values as the worker
    case "$1" in
        WAN|WAN1) echo "254 0x8000 9990" ;; WAN2) echo "253 0x8500 9890" ;;
        OVPN1) echo "111 0x1000 9991" ;; OVPN2) echo "112 0x2000 9992" ;; OVPN3) echo "113 0x3000 9993" ;; OVPN4) echo "114 0x4000 9994" ;; OVPN5) echo "115 0x5000 9995" ;;
        WGC1) echo "211 0x6100 9996" ;; WGC2) echo "212 0x6200 9997" ;; WGC3) echo "213 0x6300 9998" ;; WGC4) echo "214 0x6400 9999" ;; WGC5) echo "215 0x6500 10000" ;;
    esac
}
fo_tname() { case "$1" in 254) echo main ;; 253) echo default ;; 255) echo local ;; *) echo "$1" ;; esac; }
fo_chain() { sed -n "s/^$1=//p" "$FO_CONF" 2>/dev/null | head -n 1; }

fo_probe() {
    [ "$1" = "BLOCK" ] && return 0
    check_iface_up "$1" || return 1
    pdev=$(get_ifname "$1"); [ -n "$pdev" ] || return 1
    for pip in $FO_PROBES; do ping -c 1 -W 2 -I "$pdev" "$pip" >/dev/null 2>&1 && return 0; done
    return 1
}

# up / down with hysteresis; counters in $FO_RT/h_<IF>: "<state> <good in a row> <failed in a row>"
fo_health() {
    hf="$FO_RT/h_$1"; hs=""; hok=0; hfl=0
    [ -f "$hf" ] && read -r hs hok hfl < "$hf"
    if fo_probe "$1"; then hok=$((hok + 1)); hfl=0; else hfl=$((hfl + 1)); hok=0; fi
    if [ -z "$hs" ]; then if [ $hok -gt 0 ]; then hs=up; else hs=down; fi
    elif [ "$hs" = "up" ] && [ $hfl -ge 2 ]; then hs=down
    elif [ "$hs" = "down" ] && [ $hok -ge 2 ]; then hs=up; fi
    echo "$hs $hok $hfl" > "$hf"
    echo "$hs"
}

# points the ip rule of target $1 at the table of $2 (or "unreachable" for BLOCK); only touches it if it differs
fo_set_rule() {
    pinfo=$(fo_info "$1"); [ -n "$pinfo" ] || return 1
    ptab=$(echo "$pinfo" | cut -d' ' -f1); pmark=$(echo "$pinfo" | cut -d' ' -f2); pprio=$(echo "$pinfo" | cut -d' ' -f3)
    if [ "$2" = "BLOCK" ]; then fr_want="unreachable"; wtab=""
    else wtab=$ptab; [ "$2" != "$1" ] && wtab=$(fo_info "$2" | cut -d' ' -f1); [ -n "$wtab" ] || return 1; fr_want="lookup $(fo_tname "$wtab")"; fi
    fr_cur=$(ip rule show 2>/dev/null | awk -v p="$pprio:" '$1 == p')
    if [ "$(echo "$fr_cur" | grep -c .)" = "1" ] && echo "$fr_cur" | grep -q "fwmark $pmark/$pmark $fr_want\$"; then return 0; fi
    while ip rule del prio "$pprio" 2>/dev/null; do :; done
    if [ -z "$wtab" ]; then ip rule add fwmark "$pmark/$pmark" prio "$pprio" unreachable
    else ip rule add from all fwmark "$pmark/$pmark" table "$wtab" prio "$pprio"; fi
}

# "Block" stops the devices only; the router's own traffic for this mark goes via WAN
fo_self_rule() {
    pmark=$(fo_info "$1" | cut -d' ' -f2); [ -n "$pmark" ] || return 0
    fs_has=$(ip rule show 2>/dev/null | grep -c "^${FO_SELF_PRIO}:.*iif lo.*fwmark $pmark/$pmark")
    if [ "$2" = "BLOCK" ]; then
        [ "$fs_has" -gt 0 ] || ip rule add iif lo fwmark "$pmark/$pmark" lookup main prio "$FO_SELF_PRIO" 2>/dev/null
    else
        while ip rule del iif lo fwmark "$pmark/$pmark" prio "$FO_SELF_PRIO" 2>/dev/null; do :; done
    fi
    return 0
}

# failover rounds from cron, WebUI and "apply" never run at the same time (waits up to 20 s, stale after 3 min)
fo_lock() {
    mkdir -p "$FO_RT"
    fl_i=0
    while ! mkdir "$FO_RT/lock" 2>/dev/null; do
        if [ -n "$(find "$FO_RT/lock" -maxdepth 0 -mmin +3 2>/dev/null)" ]; then rm -rf "$FO_RT/lock"; continue; fi
        fl_i=$((fl_i + 1)); [ $fl_i -ge 20 ] && return 1
        sleep 1
    done
    return 0
}
fo_unlock() { rmdir "$FO_RT/lock" 2>/dev/null; }
fo_round_safe() { [ -s "$FO_CONF" ] || return 0; fo_lock || return 0; fo_round; fo_unlock; }

# one probe round over all chains
fo_round() {
    [ -s "$FO_CONF" ] || return 0
    mkdir -p "$FO_RT"
    fo_now=$(date +%s); fo_changed=0
    for fo_i in $(sed 's/=/,/' "$FO_CONF" | tr ',' '\n' | grep -v '^$' | sort -u); do echo "$fo_i $(fo_health "$fo_i")"; done > "$FO_RT/health.txt"
    while IFS='=' read -r fo_t fo_ch; do
        [ -n "$(fo_info "$fo_t")" ] || continue
        fo_act=""
        for fo_c in $fo_t $(echo "$fo_ch" | tr ',' ' '); do
            [ "$(awk -v i="$fo_c" '$1 == i { print $2 }' "$FO_RT/health.txt")" = "up" ] && { fo_act=$fo_c; break; }
        done
        [ -n "$fo_act" ] || fo_act=$fo_t
        fo_old=$(cat "$FO_RT/active_$fo_t" 2>/dev/null)
        if [ "$fo_act" != "$fo_old" ]; then
            echo "$fo_act" > "$FO_RT/active_$fo_t"; echo "$fo_now" > "$FO_RT/since_$fo_t"; fo_changed=1
            if [ "$fo_act" = "$fo_t" ]; then [ -n "$fo_old" ] && logger -t ASNmanager "Failover: $fo_t works again - traffic via $fo_t"
            elif [ "$fo_act" = "BLOCK" ]; then logger -t ASNmanager "Failover: $fo_t is down - traffic for its ASNs is blocked"
            else logger -t ASNmanager "Failover: $fo_t is down - traffic for its ASNs goes via $fo_act"; fi
        fi
        fo_set_rule "$fo_t" "$fo_act"
        fo_self_rule "$fo_t" "$fo_act"
    done < "$FO_CONF"
    fo_export
    [ $fo_changed -eq 1 ] && rc_check >/dev/null 2>&1
    return 0
}

# cron (every minute): two rounds, FO_INTERVAL seconds apart
fo_run_cron() {
    [ -s "$FO_CONF" ] || return 0
    nv_refresh
    fo_round_safe; sleep "$FO_INTERVAL"; fo_round_safe
}

fo_export() {
    [ -d "$WEB_DIR" ] || return 0
    {
        printf '{"ts":%s,"interval":%s,"chains":[' "$(date +%s)" "$FO_INTERVAL"
        fe_n=0
        { [ -f "$FO_CONF" ] && cat "$FO_CONF"; } | while IFS='=' read -r fe_t fe_ch; do
            [ -n "$(fo_info "$fe_t")" ] || continue
            [ $fe_n -gt 0 ] && printf ','
            fe_fb=$(echo "$fe_ch" | awk -F, '{ for (i = 1; i <= NF; i++) printf "%s\"%s\"", (i > 1 ? "," : ""), $i }')
            fe_act=$(cat "$FO_RT/active_$fe_t" 2>/dev/null); fe_since=$(cat "$FO_RT/since_$fe_t" 2>/dev/null)
            printf '{"t":"%s","fb":[%s],"active":"%s","since":%s}' "$fe_t" "$fe_fb" "$fe_act" "${fe_since:-0}"
            fe_n=$((fe_n + 1))
        done
        printf '],"health":{'
        awk '{ printf "%s\"%s\":\"%s\"", (NR > 1 ? "," : ""), $1, $2 }' "$FO_RT/health.txt" 2>/dev/null
        printf '}}\n'
    } > "$WEB_DIR/failover.js.tmp" && mv -f "$WEB_DIR/failover.js.tmp" "$WEB_DIR/failover.js"
}

fo_cron_sync() {
    if [ -s "$FO_CONF" ]; then
        cru a ASN_Failover "* * * * * $SCRIPT_PATH failover run" 2>/dev/null
        ensure_script "$SERVICES_START"
        grep -q "# ${FO_HOOK}\$" "$SERVICES_START" 2>/dev/null || echo "$SCRIPT_PATH failover cron >/dev/null 2>&1 # ${FO_HOOK}" >> "$SERVICES_START"
    else
        cru d ASN_Failover 2>/dev/null
        [ -f "$SERVICES_START" ] && sed -i "/# ${FO_HOOK}\$/d" "$SERVICES_START"
        rm -rf "$FO_RT"
    fi
}

# failover set <TARGET> [FALLBACK[,FALLBACK]]  - empty list removes the chain
fo_set() {
    fs_t=$(norm_dest "$1") || { echo "Invalid target '$1'"; return 1; }
    fs_ch=""; fs_cnt=0
    for fs_c in $(echo "$2" | tr ',;' '  '); do
        case "$fs_c" in BLOCK|block|Block) fs_c=BLOCK ;; *) fs_c=$(norm_dest "$fs_c") || { echo "Invalid fallback '$fs_c'"; return 1; } ;; esac
        [ "$fs_c" = "$fs_t" ] && { echo "A fallback cannot be the target itself."; return 1; }
        case ",$fs_ch," in *",$fs_c,"*) continue ;; esac
        case ",$fs_ch," in *",BLOCK,"*) echo "BLOCK must be the last fallback."; return 1 ;; esac
        fs_ch="${fs_ch:+$fs_ch,}$fs_c"; fs_cnt=$((fs_cnt + 1))
    done
    [ $fs_cnt -le 2 ] || { echo "At most two fallbacks."; return 1; }
    mkdir -p "$ADDON_DIR"; touch "$FO_CONF"
    sed -i "/^${fs_t}=/d" "$FO_CONF"
    if [ -n "$fs_ch" ]; then
        echo "${fs_t}=${fs_ch}" >> "$FO_CONF"
        rm -f "$FO_RT/active_$fs_t" "$FO_RT/since_$fs_t"
        fo_cron_sync
        fo_round_safe
        # ASNs of a target that was offline when the rules were applied have no marking rules yet: say so
        # (no automatic "apply" here - it can take minutes and would block every other action meanwhile)
        fs_hint=""
        if grep -qE "^[0-9]+:${fs_t}:" "$ASN_FILE" 2>/dev/null && ! iptables -t mangle -S PREROUTING 2>/dev/null | grep -qE -- "--match-set ASN[UD]?_${fs_t}_"; then
            fs_hint=" Apply the rules once - ${fs_t} has no active rules yet."
        fi
        echo "Failover for ${fs_t} saved: ${fs_t} -> $(echo "$fs_ch" | sed 's/,/ -> /g').${fs_hint}"
    else
        fo_set_rule "$fs_t" "$fs_t"; fo_self_rule "$fs_t" "$fs_t"
        rm -f "$FO_RT/active_$fs_t" "$FO_RT/since_$fs_t"
        [ -s "$FO_CONF" ] || rm -f "$FO_CONF"
        fo_cron_sync
        fo_export
        echo "Failover for ${fs_t} removed."
    fi
}

fo_show() {
    [ -s "$FO_CONF" ] || { echo "No failover configured."; return 0; }
    while IFS='=' read -r fw_t fw_ch; do
        fw_act=$(cat "$FO_RT/active_$fw_t" 2>/dev/null)
        echo "${fw_t} -> $(echo "$fw_ch" | sed 's/,/ -> /g')   active: ${fw_act:-(not checked yet)}"
    done < "$FO_CONF"
    [ -f "$FO_RT/health.txt" ] && sed 's/^/  /' "$FO_RT/health.txt"
}

# complete removal (uninstall): ip rules are removed with the other rules
fo_purge() {
    cru d ASN_Failover 2>/dev/null
    while ip rule del prio "$FO_SELF_PRIO" 2>/dev/null; do :; done
    [ -f "$SERVICES_START" ] && sed -i "/# ${FO_HOOK}\$/d" "$SERVICES_START"
    rm -rf "$FO_RT" "$FO_CONF" "$WEB_DIR/failover.js"
}

# =====================================================================
#  Routing check: does every ASN really leave through its target interface?
#  Per ASN: subnets loaded, MARK rule active, target interface up, and the kernel's own routing
#  decision for a sample address of the ASN with the rule's fwmark (ip route get <ip> mark <mark>).
#  With the traffic statistics on, the bytes counted on the target interface since the last check are
#  added (they can only be counted there if the packets really left through that interface).
#  Runs every 5 minutes (cron, only while the WebUI is installed), after "apply" and on demand.
# =====================================================================
RC_PREV="/tmp/${WEBUI_NS}-check.prev"

rc_info() {   # same fwmarks / tables as the worker
    case "$1" in
        WAN|WAN1) echo "254 0x8000" ;; WAN2) echo "253 0x8500" ;;
        OVPN1) echo "111 0x1000" ;; OVPN2) echo "112 0x2000" ;; OVPN3) echo "113 0x3000" ;; OVPN4) echo "114 0x4000" ;; OVPN5) echo "115 0x5000" ;;
        WGC1) echo "211 0x6100" ;; WGC2) echo "212 0x6200" ;; WGC3) echo "213 0x6300" ;; WGC4) echo "214 0x6400" ;; WGC5) echo "215 0x6500" ;;
    esac
}

# first usable address of the first prefix of the ASN (cache file, else the ipset)
rc_sample() {
    p=$(grep -m 1 '^[0-9]' "/jffs/scripts/asn_cache/${2}.txt" 2>/dev/null)
    [ -z "$p" ] && p=$(ipset list "$1" 2>/dev/null | awk '/^Members:/ { f = 1; next } f && NF { print $1; exit }')
    echo "$p" | awk -F'[./]' 'NF >= 4 {
        len = (NF >= 5) ? $5 + 0 : 32
        n = (($1 * 256 + $2) * 256 + $3) * 256 + $4
        if (len < 31) n = n + 1
        printf "%d.%d.%d.%d\n", int(n / 16777216), int(n / 65536) % 256, int(n / 256) % 256, n % 256 }'
}

# is there a marking rule that covers the sample address of this ASN? (one rule per ASN, or a combined set)
rc_rule_active() {
    echo "$rc_rules" | grep -q -- "--match-set $1 dst" && return 0
    for ru in $(echo "$rc_sets_u" | grep "^ASNU_${2}_"); do
        echo "$rc_rules" | grep -q -- "--match-set $ru dst" && ipset test "$ru" "$3" >/dev/null 2>&1 && return 0
    done
    return 1
}

rc_check() {
    nv_refresh
    ep_guard_sync >/dev/null 2>&1
    [ -d "$(dirname "$WEB_DIR")" ] || return 0
    mkdir -p "$WEB_DIR" 2>/dev/null || return 0
    rc_rules=$(iptables -t mangle -S PREROUTING 2>/dev/null)
    rc_sets=$(ipset list -n 2>/dev/null | grep '^ASN_')
    rc_sets_u=$(ipset list -n 2>/dev/null | grep '^ASNU_')
    rc_now=$(date +%s)
    rc_pts=$(sed -n 's/^#ts=//p' "$RC_PREV" 2>/dev/null); case "$rc_pts" in ''|*[!0-9]*) rc_pts=0 ;; esac
    rc_stats=0
    { echo "#ts=$rc_now"
      if [ "$(ts_state)" = "enabled" ]; then
          ts_live | awk -F'\t' '{ split($1, k, "|"); if (k[4] == "" && k[3] ~ /^[0-9]+$/) b[k[2] "|" k[3]] += $3 } END { for (i in b) printf "%s\t%.0f\n", i, b[i] }'
      fi; } > "$RC_PREV.new"
    [ "$(ts_state)" = "enabled" ] && rc_stats=1
    rc_out="$WEB_DIR/check.js.tmp"
    printf '{"ts":%s,"stats":%s,"window":%s,"results":[' "$rc_now" "$rc_stats" "$([ "$rc_pts" -gt 0 ] && echo $((rc_now - rc_pts)) || echo 0)" > "$rc_out"
    rc_n=0
    while IFS=':' read -r asn rdest src_ip; do
        case "$asn" in ''|*[!0-9]*) continue ;; esac
        d=$(ts_nd "$rdest"); set="ASN_${rdest}_${asn}"
        dev=$(get_ifname "$d"); info=$(rc_info "$d"); mark=${info#* }
        [ -n "$info" ] || continue
        code=ok; got=""; sample=""
        exp=$(cat "$FO_RT/active_$d" 2>/dev/null); [ -n "$exp" ] || exp=$d     # failover active -> the fallback is expected
        xdev=$dev; [ "$exp" != "$d" ] && [ "$exp" != "BLOCK" ] && xdev=$(get_ifname "$exp")
        if ! echo "$rc_sets" | grep -qx "$set"; then code=nosubnets
        else
            sample=$(rc_sample "$set" "$asn")
            if [ -n "$sample" ] && cut -d' ' -f1 "$EP_CACHE" 2>/dev/null | grep -qx "$sample"; then
                sample=$(echo "$sample" | awk -F. '{ printf "%d.%d.%d.%d", $1, $2, $3, ($4 + 1) % 256 }')
            fi
            if [ -z "$sample" ] || ! ipset test "$set" "$sample" >/dev/null 2>&1; then code=nosubnets; sample=""
            elif [ "$exp" != "BLOCK" ] && ! check_iface_up "$exp"; then code=down
            elif ! rc_rule_active "$set" "$d" "$sample"; then code=norule
            elif [ "$exp" = "BLOCK" ]; then code=blocked
            else
                got=$(ip route get "$sample" mark "$mark" 2>/dev/null | head -n 1 | sed -n 's/.* dev \([^ ]*\).*/\1/p')
                if [ -z "$got" ]; then code=noroute
                elif [ "$got" != "$xdev" ]; then code=wrongdev
                elif [ "$exp" != "$d" ]; then code=failover; fi
            fi
        fi
        case "$code" in ok) state=ok ;; nosubnets|norule|failover|blocked) state=warn ;; *) state=fail ;; esac
        recent=-1
        if [ "$rc_stats" -eq 1 ]; then
            cur=$(awk -F'\t' -v k="$d|$asn" '$1 == k { print $2; exit }' "$RC_PREV.new")
            prv=$(awk -F'\t' -v k="$d|$asn" '$1 == k { print $2; exit }' "$RC_PREV" 2>/dev/null)
            if [ -n "$cur" ] && [ -n "$prv" ] && [ "$rc_pts" -gt 0 ]; then
                recent=$(awk -v a="$cur" -v b="$prv" 'BEGIN { d = a - b; printf "%.0f", (d >= 0 ? d : -1) }')
            fi
        fi
        dev=$(get_ifname "$d")                                   # check_iface_up overwrites $dev
        [ $rc_n -gt 0 ] && printf ',' >> "$rc_out"
        printf '{"asn":"%s","dest":"%s","src":"%s","state":"%s","code":"%s","dev":"%s","got":"%s","sample":"%s","recent":%s,"fo":"%s"}' \
            "$asn" "$d" "$(echo "$src_ip" | tr -cd '0-9.,')" "$state" "$code" "$dev" "$got" "$sample" "$recent" "$([ "$exp" != "$d" ] && echo "$exp")" >> "$rc_out"
        rc_n=$((rc_n + 1))
    done < "$ASN_FILE"
    cu_check_rows "$rc_out" "$rc_n"
    printf ']}\n' >> "$rc_out"
    mv -f "$rc_out" "$WEB_DIR/check.js"
    mv -f "$RC_PREV.new" "$RC_PREV"
}

# command line: readable table
rc_print() {
    rc_check
    [ -f "$WEB_DIR/check.js" ] || { echo "No WebUI directory - nothing to check."; return 1; }
    sed 's/},{/}\n{/g' "$WEB_DIR/check.js" | sed -n 's/.*"asn":"\([A-Z0-9]*\)","dest":"\([^"]*\)".*"state":"\([^"]*\)","code":"\([^"]*\)","dev":"\([^"]*\)","got":"\([^"]*\)","sample":"\([^"]*\)".*/\1 \2 \3 \4 \5 \6 \7/p' |
    while read -r asn d st code dev got sample; do
        case "$asn" in C[0-9]*) lbl="$asn" ;; *) lbl="AS$asn" ;; esac
        case "$code" in
            ok)        echo "[OK]   ${lbl} -> ${d}: ${sample} goes via ${got}" ;;
            wrongdev)  echo "[FAIL] ${lbl} -> ${d}: ${sample} goes via ${got} instead of ${dev}" ;;
            down)      echo "[FAIL] ${lbl} -> ${d}: interface ${dev} is offline" ;;
            noroute)   echo "[FAIL] ${lbl} -> ${d}: no route for ${sample}" ;;
            norule)    echo "[WARN] ${lbl} -> ${d}: rule not active (apply rules)" ;;
            failover)  echo "[WARN] ${lbl} -> ${d}: ${d} is down - failover via ${got}" ;;
            blocked)   echo "[WARN] ${lbl} -> ${d}: ${d} is down - traffic blocked (failover)" ;;
            nosubnets) echo "[WARN] ${lbl} -> ${d}: no subnets loaded" ;;
            nolearned) echo "[WARN] ${lbl} -> ${d}: no addresses learned yet (the devices must use the router as DNS server)" ;;
        esac
    done
    [ -s "$EP_CACHE" ] && while read -r ep_ip ep_who; do echo "[INFO] VPN server $ep_ip ($ep_who) always goes via WAN"; done < "$EP_CACHE"
    return 0
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
    # the notice "a new version is available" must go: the stored check result still names the old version
    [ -d "$WEB_DIR" ] && printf '{"ts":%s,"local":"%s","remote":"%s","newer":0,"error":"","notes":"%s"}\n' "$(date +%s)" "$u_rv" "$u_rv" "$UPD_NOTES" > "$WEB_DIR/update.js"
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
        "${WEBUI_NS}backup") backup_export ;;
        "${WEBUI_NS}check") rc_check ;;
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
    cru a ASN_Check "*/5 * * * * $SCRIPT_PATH check run" 2>/dev/null   # routing check (RAM only, renewed on every mount)
    fo_cron_sync >/dev/null 2>&1
    rc_check >/dev/null 2>&1
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
    cru d ASN_Check 2>/dev/null
    rm -rf "$WEB_DIR" "$RC_PREV" "$RC_PREV.new"
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
        if curl -fsSk --connect-timeout 10 -m 60 "$ASP_URL" -o "$WEBUI_SRC.new" && grep -q "$WEBUI_MARK" "$WEBUI_SRC.new"; then
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
        webui_install >/dev/null 2>&1 && echo -e "${GREEN}WebUI installed.${NC}" || echo -e "${RED}WebUI install failed - see menu option [16].${NC}"
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
  add <TARGET> <ENTRY>... [--src IP] add ASN(s), IP/CIDR ranges or domains (AS15169 1.2.3.0/24 *.example.com), TARGET: ${VALID_DESTS}
  preset <1-${PRESET_COUNT}> <TARGET> [--src IP]  add a service preset
  presets                            list service presets
  remove <ENTRY>...                  remove ASN(s) / entries (ASN, C1 ... id from "list", IP/CIDR or domain)
  clear                              remove all ASNs
  apply                              fetch subnets & apply rules
  retry                              rebuild from cache, download only missing/failed ASNs
  edit <ASN|Cn> <TARGET> [SRC-IP]    change target / source IP of an ASN or custom entry
  custom list | apply | early | purge   custom entries (IP/CIDR, domains): list / apply (done by "apply") / purge
  custom learned [ID]                addresses dnsmasq has learned for the domain entries
  import <replace|merge> <ASN:TARGET:SRC>[,...]  import entries
  status                             ipset status
  test <IP|domain>                   check which route a target takes
  lookup <IP|domain>                 find the ASN of a target
  trace <IP|domain>                  traceroute
  ifaces                             public IP / country per interface
  schedule <days> <HH:MM>            auto-refresh schedule
  stats enable | disable | reset     traffic statistics (per ASN and client) on / off / off + delete numbers
  stats show | unknown | probe       print numbers / list addresses without counter rule / self-check
  stats saving on | off              save the numbers hourly on the USB device (default) / keep them in RAM only
  stats mode asn | iface             statistics per ASN (exact) / per interface and device only (cheaper for the CPU)
  rulemode combined | single         marking rules: one combined set per target (fast) / one rule per ASN (apply the rules afterwards)
  stats diag                         where do the statistics hang? (loop, lock, hook, timing)
  stats repair                       statistics do not count: clean temporary files, set up the counting again (numbers are kept)
  update check | install             look for a new version on GitHub / install it (the WebUI offers this as well)
  check                              routing check: does every ASN leave through its target interface? (also every 5 min)
  failover set WGC1 WGC2,WAN1        failover chain for a target (up to 2 fallbacks, BLOCK = block the traffic)
  failover clear WGC1 | show | once  remove a chain / show the state / run one check round now
  guard                              show the VPN servers that always go via WAN (tunnel protection)
  install                            set up ASN Manager (used by the installer)
  job [clear]                        show the running WebUI job / remove a stuck job lock
  speedtest <TARGET|all>             measure download / upload / ping through one target interface
  backup [dir|show]                  write a backup (ASN list, schedule, failover chains, settings) / print it
  restore <file> [--only asn,schedule,failover,settings] [--merge]   restore a backup (all or only the chosen parts)
  rescue                             stop stuck ASN Manager jobs, remove locks, restart failover and statistics
  amtmupdate [check]                 update for amtm (check: exit code 0 = amtm may update)
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
        guard)    ep_show ;;
        job)      cli_job "$1" ;;
        speedtest) st_cli "$1" ;;
        rulemode) rules_set_mode "$1" ;;
        custom)   cli_custom "$@" ;;
        backup)
            case "$1" in
                show) backup_text ;;
                *)    bk_p=$(backup_write "${1:-/jffs}") && echo "Backup created: $bk_p" ;;
            esac ;;
        restore)  cli_restore "$@" ;;
        rescue)   cli_rescue ;;
        install)  cli_install ;;
        amtmupdate)
            [ "$1" = "check" ] && return 0
            cli_amtmupdate ;;
        failover)
            case "$1" in
                run)     fo_run_cron ;;
                once)    fo_round_safe; fo_show ;;
                cron)    fo_cron_sync ;;
                set)     fo_set "$2" "$3" ;;
                clear)   fo_set "$2" "" ;;
                show|"") fo_show ;;
                *)       echo "Usage: failover show | set <TARGET> <FALLBACK>[,<FALLBACK>] | clear <TARGET> | once"; false ;;
            esac ;;
        check)
            case "$1" in
                run) proc_reap; rc_run_once ;;
                *)   rc_print ;;
            esac ;;
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
    case "$cmd" in add|preset|remove|del|clear|apply|retry|edit|import|schedule|restore|custom)
        [ -f "$ADDON_DIR/webui_page" ] && web_export ;;
    esac
    return $rc
}

# Not started as /jffs/scripts/ASNmanager.sh (old one-line installer "sh -c \"$(curl ...)\"" or a copy somewhere
# else): put the script in place first, then install from there - so the installed file is exactly the hosted one.
if { [ $# -eq 0 ] || [ "$1" = "install" ]; } && [ "$0" != "$SCRIPT_PATH" ] && [ "$(readlink -f "$0" 2>/dev/null)" != "$SCRIPT_PATH" ]; then
    mkdir -p "$(dirname "$SCRIPT_PATH")"
    if [ -f "$0" ] && grep -q '^version=' "$0" 2>/dev/null; then
        sed 's/\r$//' "$0" > "$SCRIPT_PATH.new" && mv -f "$SCRIPT_PATH.new" "$SCRIPT_PATH"
    else
        echo "Installing ASN Manager to $SCRIPT_PATH ..."
        if ! curl -fsSk --connect-timeout 10 -m 60 "https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/main/ASNmanager.sh" -o "$SCRIPT_PATH.new" || [ ! -s "$SCRIPT_PATH.new" ]; then
            rm -f "$SCRIPT_PATH.new"; echo "Download failed - nothing installed."; exit 1
        fi
        mv -f "$SCRIPT_PATH.new" "$SCRIPT_PATH"
    fi
    chmod 755 "$SCRIPT_PATH"
    exec "$SCRIPT_PATH" install
fi

[ $# -gt 0 ] && { cli_main "$@"; exit $?; }

webui_auto
ts_ensure_loop

while true; do
    show_menu
    read -r opt
    act=$(menu_action "$opt")
    case $act in
        list)
            clear
            if [ ! -s "$ASN_FILE" ] && [ ! -s "$CUSTOM_FILE" ]; then
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
                cu_print_section
                
                echo -n "Press Enter to return to main menu..."
                read -r _
            fi
            ;;
        add)
            clear
            echo -e "${YELLOW}--- Add ASN(s), IP/CIDR ranges or domains ---${NC}"
            echo "Examples: AS15169  |  181.209.202.0/24  |  *.googlevideo.com (the domain and all its subdomains)"
            echo -n "Enter entries (separated by comma or space): "
            read -r new_asns
            if [ -n "$new_asns" ]; then
                prompt_destination
                if [ "$SELECTED_DEST" != "CANCEL" ]; then
                    prompt_source_ip
                    cli_add "$SELECTED_DEST" "$new_asns" --src "$SELECTED_SRC_IP"
                    echo "$new_asns" | grep -qE '[A-Za-z]{2,}\.[A-Za-z]' && echo -e "${YELLOW}Domains only work for devices that use the router as their DNS server (not with DoH / fixed DNS servers).${NC}"
                fi
            fi
            sleep 2.5
            ;;
        find)
            clear
            echo -n "Enter Domain or IP: "
            read -r target
            if [ -n "$target" ]; then
                clean_target=$(echo "$target" | sed -E 's#https?://##' | cut -d'/' -f1)
                lookup_ip="$clean_target"
                echo "$clean_target" | grep -q '[^0-9.]' && lookup_ip=$(nsl "$clean_target" 2>/dev/null | grep -A 20 "Name:" | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n 1)
                if [ -n "$lookup_ip" ]; then
                    asn_info=$(curl -fsSk --connect-timeout 5 -m 10 "http://ip-api.com/line/$lookup_ip?fields=as")
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
        presets) service_presets ;;
        remove) remove_menu ;;
        apply)
            clear
            echo -e "${YELLOW}--- Rebuilding Worker & Fetching Subnets ---${NC}"
            if rebuild_worker; then
                "$WORKER_SCRIPT" force
                mark_applied
                echo -e "\n${GREEN}Finished! Rules updated.${NC}"
            fi
            echo "" && echo -n "Press Enter to return..." && read -r _
            ;;
        ipset)
            clear
            ipset_status_report
            echo "" && echo -n "Press Enter to return..." && read -r _
            ;;
        test)
            clear
            echo -n "Enter IP or Domain to test: " && read -r target
            [ -n "$target" ] && route_test "$target"
            echo "" && echo -n "Press Enter to return..." && read -r _
            ;;
        ifips) show_interface_ips ;;
        trace)
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
        update) update_self ;;
        schedule) configure_schedule ;;
        backup) backup_restore_menu ;;
        uninstall) uninstall_menu ;;
        webui) webui_menu ;;
        edit) edit_menu ;;
        check) check_menu ;;
        failover) failover_menu ;;
        job) job_menu ;;
        speed) speed_menu ;;
        exit) clear; exit 0 ;;
    esac
done
