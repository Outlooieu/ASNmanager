# ASNmanager


ASN Manager is a script designed for Asuswrt-Merlin routers, allowing you to easily route specific Autonomous Systems (ASNs) through your primary WAN, secondary WAN, OpenVPN clients, or WireGuard tunnels.

```
================================================================
  _   ___ _  _   __  __   _   _  _   _   ___ ___  ___
 /_\ / __| \| | |  \/  | /_\ | \| | /_\ / __| __|| _ \
/ _ \__ \ .' | | |\/| |/ _ \| .' |/ _ \ (_ | _| |   /
/_/ \_\___/_|\_| |_|  |_/_/ \_\_|\_/_/ \_\___|___||_|_\
              === ASN MANAGER v1.0.0 ===
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
 [0]  Exit
----------------------------------------------------------------
Select an option [0-14]:

```

Key Features:

Multi-Interface Routing: Assign specific ASNs directly to WAN1, WAN2, OpenVPN clients (tun11–15), or WireGuard clients (wgc1–5).

Automated IP Subnet Fetching: Automatically queries and aggregates IPv4 prefixes from multiple reliable sources (Amazon IP ranges, IPverse, RIPE Stat, HackerTarget, and BGPView).

Chunked Engine: Automatically splits large ASN lists into manageable chunks (max 3,000 entries per ipset table) to maintain high performance and prevent kernel limits.

Auto-Refresh Scheduling: Built-in configuration to automatically re-fetch and update IP subnets via cron jobs and persistent startup scripts (services-start).

Interactive Diagnostics: Includes built-in tools to test IP/domain routing, view active ipset counts, check interface public IPs/countries, and run traceroutes through specific target interfaces.

Backup & Restore: Easily export and import your configuration locally to /jffs or to an external USB storage drive.

Quick Installation:

Run the following command in your router's terminal via SSH:
```
sh -c "$(curl -k -s https://raw.githubusercontent.com/Outlooieu/ASNmanager/main/ASNmanager.sh)"
```


Start the script with the code above or

```
/jffs/scripts/ASNmanager.sh
```

Run this single command in your router's SSH terminal to install, configure persistence hooks, and open the manager menu:

```
bash
curl -f -sS [https://raw.githubusercontent.com/Outlooieu/asuswrt-asn-bypass/main/asn-bypass.sh](https://raw.githubusercontent.com/Outlooieu/asuswrt-asn-bypass/main/asn-bypass.sh) -o /jffs/scripts/asn-bypass.sh && chmod +x /jffs/scripts/asn-bypass.sh && grep -qF "/jffs/scripts/asn-bypass-worker.sh &" /jffs/scripts/nat-start 2>/dev/null || echo "/jffs/scripts/asn-bypass-worker.sh &" >> /jffs/scripts/nat-start && chmod +x /jffs/scripts/nat-start && grep -qF "cru a asn_bypass_update" /jffs/scripts/services-start 2>/dev/null || echo 'cru a asn_bypass_update "30 4 * * * /jffs/scripts/asn-bypass-worker.sh"' >> /jffs/scripts/services-start && chmod +x /jffs/scripts/services-start && cru a asn_bypass_update "30 4 * * * /jffs/scripts/asn-bypass-worker.sh" && /jffs/scripts/asn-bypass.sh
```
bash

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

[14] Uninstall ASN Manager: Completely removes all created rules, ipsets, cron jobs, and script files fr om the router.
