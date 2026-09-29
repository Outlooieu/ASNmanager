# ASNmanager


ASN Manager is a script designed for Asuswrt-Merlin routers, allowing you to easily route specific Autonomous Systems (ASNs) through your primary WAN, secondary WAN, OpenVPN clients, or WireGuard tunnels.

```
================================================================
  _   ___ _  _   __  __   _   _  _   _   ___ ___  ___
 /_\ / __| \| | |  \/  | /_\ | \| | /_\ / __| __|| _ \
/ _ \__ \ .' | | |\/| |/ _ \| .' |/ _ \ (_ | _| |   /
/_/ \_\___/_|\_| |_|  |_/_/ \_\_|\_/_/ \_\___|___||_|_\
              === ASN MANAGER v2.0.0 ===
================================================================
 [1]  View current ASN list & routing targets
 [2]  Add ASN(s) with Target Interface selection
 [3]  Find ASN for Domain / IP (Find, Add & Delete)
 [4]  Add ASN Service Presets (AWS, Netflix, Gaming, Streaming...)
 [5]  Remove ASN or Service Preset
 [6]  Build & Apply New Routing Rules (Split @ 3000 max)
 [7]  Check ipset Status & Per-ASN Subnet Count
 [8]  Test IP or Domain Routing
 [9]  Show active interface IP addresses & countries
 [10] Run Traceroute to IP or Domain
 [11] Update ASN Manager on GitHub
 [12] Set ASN IP Subnet Auto-Refresh Schedule (Every 1d @ 04:30)
 [13] Backup & Restore Configuration (Internal / USB)
 [14] Uninstall ASN Manager
 [15] WebUI Addons Tab (Enabled)
 [0]  Exit
----------------------------------------------------------------
Select an option [0-15]:

```

Key Features:

Multi-Interface Routing: Assign specific ASNs directly to WAN1, WAN2, OpenVPN clients (tun11–15), or WireGuard clients (wgc1–5).

Automated IP Subnet Fetching: Automatically queries and aggregates IPv4 prefixes from multiple reliable sources (Amazon IP ranges, IPverse, RIPE Stat, HackerTarget, and BGPView).

Chunked Engine: Automatically splits large ASN lists into manageable chunks (max 3,000 entries per ipset table) to maintain high performance and prevent kernel limits.

Auto-Refresh Scheduling: Built-in configuration to automatically re-fetch and update IP subnets via cron jobs and persistent startup scripts (services-start).

Interactive Diagnostics: Includes built-in tools to test IP/domain routing, view active ipset counts, check interface public IPs/countries, and run traceroutes through specific target interfaces.

Backup & Restore: Easily export and import your configuration locally to /jffs or to an external USB storage drive.

WebUI: Manage everything from a modern page in the router web interface ("ASN Manager" tab in the Addons or VPN menu) - see below.

Quick Installation:

Run the following command in your router's terminal via SSH:
```
sh -c "$(curl -k -s https://raw.githubusercontent.com/Outlooieu/ASNmanager/main/ASNmanager.sh)"
```


Start the script with the code above or

```
/jffs/scripts/ASNmanager.sh
```

Here is a short guide for each menu option of the ASN Manager:

[1] View current ASN list & routing targets: Displays all currently configured ASNs clearly sorted by their target interface (WAN, OpenVPN, or WireGuard).

[2] Add ASN(s) with Target Interface selection: Allows you to manually add one or multiple ASN numbers (e.g., AS15169 or 13335) followed by selecting your desired gateway interface.

[3] Find ASN for Domain / IP (Find, Add & Delete): Resolves a domain or IP address, identifies its corresponding ASN, and lets you directly add it to or remove it from the routing list.

[4] Add ASN Service Presets: Provides a list of predefined services (such as Amazon, Netflix, gaming, or streaming) to assign well-known ASNs to an interface in bulk.

[5] Remove ASN or Service Preset: Used to specifically delete individual ASNs, complete service presets, or completely reset the entire ASN list.

[6] Build & Apply New Routing Rules: Fetches all current IP subnets for the configured ASNs, splits them into chunks, and applies the ipset and firewall rules.

[7] Check ipset Status & Per-ASN Subnet Count: Shows the status of the ipset tables, whether the interfaces are online, and how many subnets were loaded per ASN.

[8] Test IP or Domain Routing: Checks a specific IP or domain to see if it is currently covered by an ASN rule or if it follows default routing.

[9] Show active interface IP addresses & countries: Lists all active router interfaces along with their current public IP addresses and associated countries.

[10] Run Traceroute to IP or Domain: Runs a traceroute to a target IP or domain, automatically using the correct mapped interface.

[11] Update ASN Manager on GitHub: Checks the GitHub repository for a newer script version and updates the ASN Manager automatically if available.

[12] Set ASN IP Subnet Auto-Refresh Schedule: Configures an automatic cron job that refreshes the IP ranges of the ASNs in the background at custom intervals (e.g., every X days).

[13] Backup & Restore Configuration (Internal / USB): Creates backups of your configuration in the internal /jffs directory or on external USB storage, or restores them.

[14] Uninstall ASN Manager: Completely removes all created rules, ipsets, cron jobs, script files, the WebUI page, its data folders and the service-event / services-start hooks from the router. Backups in /jffs are kept.

[15] WebUI Addons Tab: Enables or disables the WebUI tab in the router web interface (enabled by default), reinstalls the page or moves the tab between the Addons and the VPN menu.

## WebUI

ASN Manager adds its own page to the router web interface (Asuswrt-Merlin 384.15+ / 3004.x with Addon API).
It is installed automatically the first time the menu starts. By default the tab appears under **Addons** (next to other addons such as vnStat-on-Merlin, or under **Tools** if no Addons menu exists). It can also be shown in the **VPN** menu after "Instant Guard".

Features:

- Modern interface with **Dark**, **Light** and **Blue** theme, language switch (router default / English)
- Status tiles, "Apply rules" with live progress bar (e.g. `AS13335 -> WGC1 (3 of 12)`), retry for failed ASNs only (0 subnets are highlighted red)
- ASN list grouped per interface (collapsible, collapsed by default), edit target / source IP inline, remove single, selected or all entries
- Add ASNs or service presets, source device picker with names: LAN / Wi-Fi clients, WireGuard server peers and connected OpenVPN server clients
- Find the ASN of a domain or IP and add it with one click (ignores 0.0.0.0 answers from ad blockers)
- Target interfaces with state, external IP, country and flag
- Auto-refresh schedule, backup download and restore (compatible with menu backups), diagnostics (route test, traceroute, ipset status, public IPs)

Enable / disable / move the tab: menu option **[15]** or

```
/jffs/scripts/ASNmanager.sh webui disable
/jffs/scripts/ASNmanager.sh webui enable
/jffs/scripts/ASNmanager.sh webui location vpn      # or: addons
```

Files used by the WebUI: `/jffs/addons/asnmanager/` (page, settings, cached flags), `/www/ext/asnmanager/` (runtime data in RAM), one `userN.asp` slot and one line each in `/jffs/scripts/service-event` and `/jffs/scripts/services-start` (marked `# ASNmanager-WebUI`).

## Command line

All functions can also be used without the menu, e.g. for your own scripts:

```
ASNmanager.sh list
ASNmanager.sh add WGC1 AS13335 15169 --src 192.168.1.50
ASNmanager.sh preset 4 OVPN1
ASNmanager.sh edit 13335 WAN2
ASNmanager.sh remove 13335
ASNmanager.sh apply
ASNmanager.sh retry
ASNmanager.sh lookup netflix.com
ASNmanager.sh test netflix.com
ASNmanager.sh schedule 1 04:30
ASNmanager.sh webui location vpn
ASNmanager.sh help
```

Without arguments the interactive menu starts.

## Credits

- Round country flags: [circle-flags](https://github.com/HatScripts/circle-flags) by HatScripts, MIT License (downloaded once per country by the router)
- IP geolocation / ASN lookup: ip-api.com, with ipinfo.io and RIPEstat as fallback
