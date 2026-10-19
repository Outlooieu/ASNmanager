# ASNmanager


ASN Manager is a script designed for Asuswrt-Merlin routers, allowing you to easily route specific Autonomous Systems (ASNs) through your primary WAN, secondary WAN, OpenVPN clients, or WireGuard tunnels.

```
================================================================
  _   ___ _  _   __  __   _   _  _   _   ___ ___  ___
 /_\ / __| \| | |  \/  | /_\ | \| | /_\ / __| __|| _ \
/ _ \__ \ .' | | |\/| |/ _ \| .' |/ _ \ (_ | _| |   /
/_/ \_\___/_|\_| |_|  |_/_/ \_\_|\_/_/ \_\___|___||_|_\
              === ASN MANAGER v2.2.1 ===
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
 [15] WebUI Tab (Enabled)
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

WebUI: Manage everything from a modern page in the router web interface ("ASN Manager" tab in the VPN menu) - see below.

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

[14] Uninstall ASN Manager: Completely removes all created rules, ipsets, cron jobs, script files, the WebUI page, its data folders, the traffic statistics (rules and the saved numbers on the USB stick; the `.conf` backups stay) and the service-event / services-start / services-stop hooks from the router. Backups in /jffs are kept.

[15] WebUI Tab: Enables or disables the WebUI tab in the router web interface (enabled by default), reinstalls the page or moves the tab between the Addons and the VPN menu.

## WebUI

ASN Manager adds its own page to the router web interface (Asuswrt-Merlin 384.15+ / 3004.x with Addon API).
It is installed automatically the first time the menu starts. By default the tab appears in the **VPN** menu after "Instant Guard". It can also be moved to the **Addons** menu (next to other addons such as vnStat-on-Merlin, or under **Tools** if no Addons menu exists).

Features:

- Modern interface with **Dark**, **Light** and **Blue** theme, language switch (router default / English), a small orbit animation around the logo (switched off automatically when the operating system asks for reduced motion)
- Status tiles, "Apply rules" with live progress bar (e.g. `AS13335 -> WGC1 (3 of 12)`), retry for failed ASNs only (0 subnets are highlighted red)
- ASN list grouped per interface (collapsible, collapsed by default), edit target / source IP inline, remove single, selected or all entries
- Add ASNs or service presets, source device picker with names: LAN / Wi-Fi clients, WireGuard server peers and connected OpenVPN server clients
- Find the ASN of a domain or IP and add it with one click (ignores 0.0.0.0 answers from ad blockers)
- Target interfaces with state, external IP, country and flag
- Auto-refresh schedule, backup download and restore (compatible with menu backups), diagnostics (route test, traceroute, ipset status, public IPs)
- **Traffic statistics** per ASN and per client (collapsed card, off by default) - see below
- **Update from the WebUI**: a banner shows when GitHub has a newer version, one click installs it - see "Updating" below

Enable / disable / move the tab: menu option **[15]** or

```
/jffs/scripts/ASNmanager.sh webui disable
/jffs/scripts/ASNmanager.sh webui enable
/jffs/scripts/ASNmanager.sh webui location addons   # back to default: vpn
```

Files used by the WebUI: `/jffs/addons/asnmanager/` (page, settings, cached flags), `/www/ext/asnmanager/` (runtime data in RAM), one `userN.asp` slot and one line each in `/jffs/scripts/service-event` and `/jffs/scripts/services-start` (marked `# ASNmanager-WebUI`).

## Updating

- **WebUI:** when the page is opened (at most every 6 hours) or when you click **Check for updates** in the page header (below the version and "Data refreshed"), the router looks at GitHub. If there is a newer version, a banner offers **Update now** (and a link to the changelog). The page reloads afterwards; ASN list, schedule and statistics are kept.
- **Menu:** option **[11]** as before. **Command line:** `ASNmanager.sh update check` / `ASNmanager.sh update install`.
- The WebUI update is careful: the downloaded file is syntax-checked before anything is replaced, the previous script is kept as `/jffs/scripts/ASNmanager.sh.bak`, the new file is put in place by renaming (atomic), and if the new version cannot start the old one is restored automatically. The matching WebUI page is fetched and the statistics loop is restarted with the new code.
- Versions before 2.2.0 do not have the button yet: update once with menu option [11] (or the install command), after that the WebUI can do it.

## Traffic statistics

The card **Traffic per ASN** (above "Diagnostics", collapsed by default - click the header or the dashed bar "Show details", which also shows the total and the number of ASNs) shows how much traffic goes through each ASN rule. It is **off by default** - click **Enable** to start counting.

What you get:

- A total bar (download, upload, total, packets) and the split between "via ASN rules" and "not assigned to an ASN"
- Download, upload, packets and share (bar and percentage) per ASN; the row **Not assigned to an ASN** shows everything else, split by interface (WAN / VPN)
- Click a row to see what is behind it: an ASN shows the traffic **per client** (name, IP and the network: LAN / Wi-Fi, Guest 2.4 / 5 GHz, WireGuard / OpenVPN server); "Not assigned" shows its interfaces, and a click on an interface shows the devices connected through it. Rows have a framed arrow and a device counter, a hint line above the table explains it, and "expand all / collapse all" opens everything at once
- The percentage is the share of the total traffic; in expanded rows it is the share of the row above
- Buttons in the card header: **Disable** (numbers are kept), **Disable & reset** (numbers are deleted), **Enable**

How it works:

- Counting is done by the router's firewall in its own chains (`ASC_*` in the `mangle` table, `FORWARD` chain). The routing rules of ASN Manager are not touched. Disabling the statistics removes all counting rules, so there is no load while it is off. While it is on, a small background loop (every 10 seconds) refreshes the page data and follows changes of ASNs, devices and interfaces.
- Clients are found automatically (WebUI device list, ARP table of every LAN / guest / VPN-server interface, DHCP leases; up to 96 private addresses). A device that just connected gets its own counter within about 10 seconds; its very first packets appear under "Other addresses (no counter rule)". `ASNmanager.sh stats unknown` lists addresses that have no counter rule (e.g. devices behind a second router).
- Numbers survive rule rebuilds (Apply, daily refresh), added / removed ASNs and firewall restarts. Removed ASNs keep their numbers until you reset.
- Numbers also survive a **reboot**. They are saved on the **USB stick**, in the `ASNmanager` folder next to the `.conf` backups (file `asn_manager_traffic_stats.txt`) - nothing is written to the router's flash (`/jffs`). Saving happens at most once per hour, only if something changed, when you disable the statistics and on shutdown (`services-stop`). A power loss costs at most the last hour. After a boot, counting resumes automatically once the ASN rules are loaded; if the USB stick is mounted later than that, the saved numbers are merged in as soon as it appears. The folder is the one where the numbers already are, else the one holding your `.conf` backups, else `ASNmanager` on the first mounted USB partition (the default of the backup menu).
- **Without a USB stick** the statistics still count, but the numbers only live in RAM and are lost on a reboot; the card shows a warning, and nothing is saved until a stick is plugged in.
- Only IPv4 and forwarded traffic (LAN / Wi-Fi / VPN-server clients <-> internet) is counted, not traffic of the router itself.
- Tested on an RT-AX86U with Flow Cache present: a 100 MB download was counted almost exactly. Behaviour of hardware-accelerated flows may differ on other models.

Command line:

```
ASNmanager.sh stats enable | disable | reset
ASNmanager.sh stats show
ASNmanager.sh stats unknown
```

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
ASNmanager.sh stats enable
ASNmanager.sh stats show
ASNmanager.sh webui location vpn
ASNmanager.sh help
```

Without arguments the interactive menu starts.

## Credits

- Round country flags: [circle-flags](https://github.com/HatScripts/circle-flags) by HatScripts, MIT License (downloaded once per country by the router)
- IP geolocation / ASN lookup: ip-api.com, with ipinfo.io and RIPEstat as fallback
