# ASNmanager


ASN Manager is a script designed for Asuswrt-Merlin routers, allowing you to easily route specific Autonomous Systems (ASNs) through your primary WAN, secondary WAN, OpenVPN clients, or WireGuard tunnels.

```
================================================================
  _   ___ _  _   __  __   _   _  _   _   ___ ___  ___
 /_\ / __| \| | |  \/  | /_\ | \| | /_\ / __| __|| _ \
/ _ \__ \ .' | | |\/| |/ _ \| .' |/ _ \ (_ | _| |   /
/_/ \_\___/_|\_| |_|  |_/_/ \_\_|\_/_/ \_\___|___||_|_\
              === ASN MANAGER v3.8.5 ===
================================================================
 ASNs
 [1]  Show ASN list & routing targets
 [2]  Add ASN(s), IP/CIDR ranges or domains
 [3]  Find ASN for domain / IP (find, add & delete)
 [4]  Add service presets (AWS, Netflix, Gaming, Streaming ...)
 [5]  Edit ASN (target / source devices)
 [6]  Remove ASN or service preset
 Rules & automation
 [7]  Build & apply routing rules
 [8]  Auto-refresh schedule (every 1d @ 04:30)
 [9]  Failover chains (1 configured)
 Check & diagnose
 [10] Routing check & tunnel protection
 [11] ipset status & subnet count per ASN
 [12] Test routing of an IP or domain
 [13] Traceroute to an IP or domain
 [14] Interface IP addresses & countries
 [15] Speed test of a target interface
 ASN Manager
 [16] WebUI tab (Enabled)
 [17] Backup & restore (internal / USB)
 [18] Update ASN Manager
 [19] Job status & rescue
 [20] Uninstall ASN Manager
 [e]  Exit
----------------------------------------------------------------
Select an option [1-20, e]:

```

Key Features:

Multi-Interface Routing: Assign specific ASNs - and single IPs, CIDR ranges or domains - directly to WAN1, WAN2, OpenVPN clients (tun11–15), or WireGuard clients (wgc1–5), for all devices or only for chosen ones.

Automated IP Subnet Fetching: Automatically queries and aggregates IPv4 prefixes from multiple reliable sources (Amazon IP ranges, IPverse, RIPE Stat, HackerTarget, and BGPView).

Low CPU load: all ASNs of a target share one ipset and one marking rule, so the router checks every packet only once per target. Every target has its own exact firewall mark, and IP / domain entries take precedence over ASNs.

Auto-Refresh Scheduling: Built-in configuration to automatically re-fetch and update IP subnets via cron jobs and persistent startup scripts (services-start).

Interactive Diagnostics: Includes built-in tools to test IP/domain routing, view active ipset counts, check interface public IPs/countries, and run traceroutes through specific target interfaces.

Backup & Restore: Easily export and import your configuration locally to /jffs or to an external USB storage drive.

WebUI: Manage everything from a modern page in the router web interface ("ASN Manager" tab in the VPN menu) - see below.

Quick Installation:

Run the following command in your router's terminal via SSH:
```
curl -k -s -o /jffs/scripts/ASNmanager.sh https://raw.githubusercontent.com/Outlooieu/ASNmanager/main/ASNmanager.sh && chmod 755 /jffs/scripts/ASNmanager.sh && /jffs/scripts/ASNmanager.sh install
```

The file on GitHub is the script itself: the installed `/jffs/scripts/ASNmanager.sh` is byte for byte the hosted file (amtm compares version and MD5 hash). The former one-liner `sh -c "$(curl ...)"` no longer works since v2.6.0 - the script is larger than the 128 KiB a single command argument may have.

Testing a version without GitHub: copy `ASNmanager.sh` to the router (any folder), remove Windows line endings if needed (`sed -i 's/\r$//' <file>`) and run `sh <file>` - it puts itself in `/jffs/scripts/` and installs from there.

Start the script with

```
/jffs/scripts/ASNmanager.sh
```

Here is a short guide for each menu option of the ASN Manager:

**ASNs**

[1] Show ASN list & routing targets: Displays all configured ASNs sorted by their target interface (WAN, OpenVPN or WireGuard).

[2] Add ASN(s), IP/CIDR ranges or domains: Add one or several entries in one go - ASNs (AS15169 or 13335), IP addresses / CIDR ranges (181.209.202.0/24) and domains (*.googlevideo.com) can be mixed. Choose the target interface and, if you like, the source devices (empty = all devices, or one or more IPs separated by commas).

[3] Find ASN for domain / IP: Resolves a domain or IP address, identifies its ASN and lets you add it to or remove it from the list.

[4] Add service presets: A list of predefined services (Amazon, Netflix, gaming, streaming ...) to assign well-known ASNs to an interface in one go.

[5] Edit ASN: Change the target interface and the source devices of an entry that is already on the list.

[6] Remove ASN or service preset: Delete single ASNs, complete service presets or reset the whole list (you type DELETE to confirm).

**Rules & automation**

[7] Build & apply routing rules: [1] builds the rules from the saved subnets and downloads only new ASNs (only the IP / domain entries are applied if the ASN list is unchanged); [2] downloads the subnets of every ASN again first.

[8] Auto-refresh schedule: Sets up the cron job that refreshes the IP ranges in the background (every X days at a chosen time).

[9] Failover chains: Shows, sets and removes the fallbacks of a target (for example WGC1 -> WGC2 -> WAN1, "Block" as kill switch) and checks them right away.

**Check & diagnose**

[10] Routing check & tunnel protection: Checks for every ASN whether its traffic really leaves through the target interface and lists the VPN servers that always go via WAN.

[11] ipset status & subnet count per ASN: Shows the ipset tables, whether the interfaces are online and how many subnets were loaded per ASN.

[12] Test routing of an IP or domain: Checks whether an IP or domain is covered by an ASN rule or follows the default route.

[13] Traceroute to an IP or domain: Runs a traceroute, automatically through the correct mapped interface.

[14] Interface IP addresses & countries: Lists the active interfaces with their public IP addresses and countries.

[15] Speed test of a target interface: Measures download, upload and ping through exactly one interface (or all online targets).

**ASN Manager**

[16] WebUI tab: Enables or disables the WebUI tab (enabled by default), reinstalls the page or moves the tab between the Addons and the VPN menu.

[17] Backup & restore (internal / USB): Writes a backup of the whole configuration to /jffs or to a USB device, or restores one - you choose what is restored.

[18] Update ASN Manager: Looks on GitHub for a newer version and installs it (a notice appears behind the entry when one is available).

[19] Job status & rescue: Shows the running WebUI job, stops stuck jobs and removes locks.

[20] Uninstall ASN Manager: Completely removes all created rules, ipsets, cron jobs, script files, the WebUI page, its data folders, the traffic statistics (rules and the saved numbers on the USB device) and the service-event / services-start / services-stop hooks. It asks whether the `.conf` backups should be deleted as well.

## WebUI

ASN Manager adds its own page to the router web interface (Asuswrt-Merlin 384.15+ / 3004.x with Addon API).
It is installed automatically the first time the menu starts. By default the tab appears in the **VPN** menu after "Instant Guard". It can also be moved to the **Addons** menu (next to other addons such as vnStat-on-Merlin, or under **Tools** if no Addons menu exists).

Layout: the **overview** (status tiles, routing check, "Apply rules", notices) is always visible at the top; below it, tabs in the order they are used most:

- **ASNs** - the ASN list and one "Add ASNs" card with three ways: enter ASNs, find them by domain / IP, service presets
- **Traffic** - statistics, live throughput and suggestions (the card opens by itself in this tab)
- **Targets & failover** - interfaces with external IP, speed test and the failover chains
- **Diagnostics** - **Explain** a domain or IP (DNS answer, every entry that contains each address, which rule wins - also for one device -, the interface it leaves through), **Check device** (its rules, its normal way through the VPN Director, its current connections with name, traffic, rule and interface), **Check DNS chain** (port 53 -> dnsmasq -> its servers, with a learning test of a domain entry), route test, traceroute, ipset status, public IPs, and the **diagnostic bundle**: one text file with everything needed to analyse a problem (public addresses, VPN servers and tunnel addresses, MAC addresses, IPv6 and keys masked; notes and VPN Director descriptions left out; the domains of your entries become domain-01.de ... unless you tick "Domains in clear text") - download it and attach it to an issue on GitHub
- **Settings** - display (unit for data rates), performance (marking rules, statistics detail), auto-refresh schedule, backup & restore

The tabs show small counters (number of ASNs, statistics on, active failovers). The page always starts on the ASNs tab.

SSH menu: the entries are grouped by what you do - ASNs (list, add, find, presets, edit, remove), rules & automation (apply, schedule, failover), check & diagnose (routing check, ipset, route test, traceroute, interface IPs, speed test) and the tool itself (WebUI tab, backup, update, rescue, uninstall).

Features:

- Modern interface with **Dark**, **Light** and **Blue** theme, language switch (router default / English), a small orbit animation around the logo (switched off automatically when the operating system asks for reduced motion)
- Status tiles, "Apply rules" with live progress bar (e.g. `AS13335 -> WGC1 (3 of 12)`), retry for failed ASNs only (0 subnets are highlighted red)
- ASN names next to the numbers (looked up once per ASN), a short note per entry (in "Edit"), and a DNS / DHCP check in the overview that warns when dnsmasq is down (e.g. after a failed AdGuard Home start)
- "Apply rules" builds from the saved subnets and downloads only new ASNs; if only IP / domain entries were added or changed, only those are applied (seconds). "Reload all subnets" downloads every ASN again (the daily schedule does this anyway). Command line: `apply`, `apply full`
- ASN list grouped per interface (collapsible, collapsed by default), edit target / source IP inline, remove single, selected or all entries
- Add ASNs or service presets, source device picker with names: LAN / Wi-Fi clients, WireGuard server peers and connected OpenVPN server clients
- Find the ASN of a domain or IP and add it with one click (ignores 0.0.0.0 answers from ad blockers)
- Target interfaces with state, external IP, country and flag
- Auto-refresh schedule, full backup download and restore with selection of the parts, diagnostics (route test, traceroute, ipset status, public IPs)
- **Traffic statistics** per ASN and per client (collapsed card, off by default) - see below
- **Update from the WebUI**: a banner shows when GitHub has a newer version, one click installs it - see "Updating" below
- **Routing check**: every ASN shows whether its traffic really leaves through the intended interface - see below
- **Failover**: if a target (e.g. WGC1) fails, its ASNs automatically use a fallback (e.g. WGC2, then WAN1) or are blocked - see below
- **Live throughput** per ASN, per interface and per device, in Mbit/s or MB/s
- **Suggestions**: which ASNs - or, optionally, which domains - the traffic without a rule goes to, with a one-click "Add" - see below

Enable / disable / move the tab: menu option **[16]** or

```
/jffs/scripts/ASNmanager.sh webui disable
/jffs/scripts/ASNmanager.sh webui enable
/jffs/scripts/ASNmanager.sh webui location addons   # back to default: vpn
```

Files used by the WebUI: `/jffs/addons/asnmanager/` (page, settings, cached flags), `/www/ext/asnmanager/` (runtime data in RAM), one `userN.asp` slot and one line each in `/jffs/scripts/service-event` and `/jffs/scripts/services-start` (marked `# ASNmanager-WebUI`).

## Back to the router

The header of the page has a "← Router" link to the router's start page.

## Updating

- **WebUI:** when the page is opened (at most every 6 hours) or when you click **Check for updates** in the page header (below the version and "Data refreshed"), the router looks at GitHub. If there is a newer version, a banner offers **Update now** (and a link to the changelog). The page reloads afterwards; ASN list, schedule and statistics are kept.
- **Menu:** option **[18]**. **Command line:** `ASNmanager.sh update check` / `ASNmanager.sh update install`.
- The WebUI update is careful: the downloaded file is syntax-checked before anything is replaced, the previous script is kept as `/jffs/scripts/ASNmanager.sh.bak`, the new file is put in place by renaming (atomic), and if the new version cannot start the old one is restored automatically. The matching WebUI page is fetched and the statistics loop is restarted with the new code.
- Versions before 2.2.0 do not have the button yet: update once with menu option [18] (or the install command), after that the WebUI can do it.
- **"Another ASN Manager job is still running"**: only one WebUI job runs at a time. The page now shows a job that was started earlier (another tab, another device, before a reload) and follows it until it is finished. A lock left behind by a job that no longer runs is cleared automatically. On the command line, `ASNmanager.sh job` shows the running job, `ASNmanager.sh job clear` removes a stuck lock.
- **Traffic statistics do not count?** If the counting is not running (for example after a killed job), the traffic card says so and offers **Repair**; the same on the command line: `ASNmanager.sh stats repair`. It keeps the numbers, cleans all temporary files in RAM and sets the counting up again. Opening the page also restarts a stopped counting process by itself. If the buttons answer "No answer from the statistics module", `ASNmanager.sh stats diag` shows in one go where it hangs (counting loop, lock, hook, how long an export takes, how long each ASN Manager process has been running). Runs of the periodic jobs (routing check, failover, helpers of the counting loop) that hang for more than 15 minutes are stopped by the next routing check; `ASNmanager.sh rescue` does it at once. Every name lookup (`nslookup`) and every download has a time limit, the routing check never runs twice at the same time and is stopped after 4 minutes, and the WAN values from `nvram` are read once per run (every `nvram get` is a process of its own and can be slow on a busy router).
- **Rescue:** if ASN Manager seems stuck, `ASNmanager.sh rescue` stops running jobs (rule rebuilds, failover and check runs - not the statistics), removes all locks and restarts failover and statistics. Apply the rules again afterwards if a rebuild was stopped.
- **amtm:** `ASNmanager.sh amtmupdate check` returns exit code 0 (amtm may update the script), `ASNmanager.sh amtmupdate` updates without questions (same safe update as the WebUI: syntax check, backup, rollback) and returns 0 on success, 1 on failure. The script file contains the line `version=x.y.z` (no quotes) that amtm reads.

## Routing check

The ASN list has a **Routing** column, the status card a summary line ("2 OK - 1 warning - 0 errors - checked ...") with **Check now**, and a red banner appears if an ASN is not routed as intended.

For every ASN the router checks: subnets loaded, the marking rule active, the target interface online, and - the actual test - which interface the kernel picks for a sample address of the ASN when it carries the rule's mark (`ip route get <address> mark <fwmark>`). The badge shows the result (for example "✓ wgc1", "✗ eth0" if the traffic would leave through WAN instead of the VPN, "✗ offline", "! not active", "! no subnets"); the tooltip explains it. With the traffic statistics enabled, the tooltip also shows how much traffic was counted on the target interface since the previous check - it can only be counted there if the packets really left through that interface.

The check runs every 5 minutes (cron job `ASN_Check`, only while the WebUI is installed, nothing is written to flash), after "Apply rules", when the page is opened with a result older than 5 minutes, and on demand. Command line: `ASNmanager.sh check`.

## Backup & restore

A backup (`asn_manager_backup_<date>.conf`) contains **everything that is configured**: the ASN list (targets and source devices), the IP / CIDR and domain entries, the notes, the auto-refresh schedule, the failover chains and the settings (traffic statistics on / off, statistics detail, marking rules, USB saving on / off, WebUI tab location). The WebUI download is created by the router, so it is the same file as the one from the SSH menu. If the router does not deliver that file (for example because the script on the router is older than the page), the page saves a **basic backup** itself - ASN list, schedule, failover chains and the statistics settings - and tells you so.

**Restore asks what to restore** - only the parts that are in the file are offered:
- WebUI (Settings tab, "Import"): pick the file, then tick the parts. For the ASN list choose *replace the current list* or *merge into it*; the failover chains of the backup replace the current ones (chains that are not in the backup are removed).
- SSH menu [17] -> [3]: one question per part.
- Command line: `ASNmanager.sh backup [dir]` writes a backup (`backup show` prints it), `ASNmanager.sh restore <file> [--only asn,schedule,failover,settings] [--merge]`.

Older backups (only the ASN list, or list + schedule) still work, also plain lists with Windows line endings; parts a backup does not contain are left alone. Invalid setting values are skipped. After restoring the ASN list, apply the rules.

## IPs, ranges and domains

Besides ASNs the list takes **single IP addresses, CIDR ranges and domains** - for traffic that no ASN rule catches, for example a video server of a cache inside your provider's network (a Google Global Cache in the provider's AS, so `AS15169` does not match it). Type them in the same field as ASNs, mixed and separated by commas: `AS15169, 181.209.202.0/24, *.googlevideo.com`. Target interface and source devices work as for ASNs (also several devices); the entries are shown in sections of their own below the ASNs ("IP / CIDR ranges" and "Domains") and have an ID (`C1`, `C2` ...) for edit and remove. Command line: `ASNmanager.sh add WGC3 181.209.202.0/24 '*.googlevideo.com' --src 192.168.50.30,192.168.50.94`, `ASNmanager.sh custom list`, `ASNmanager.sh remove C1` (or remove by value: `remove googlevideo.com`).

**IP / CIDR** (`/8` to `/32`): every range has a set and a marking rule of its own, above the ASN rules - a range wins over an ASN that contains it (survives every refresh and re-apply, because the list is the source). **Domains**: `*.example.com` and `example.com` mean the same - the domain and all its subdomains. The router's DNS server (dnsmasq) puts every address it resolves for these names into an ipset of its own (one per target and device group), and the marking rule uses that set. So the addresses follow the DNS answers by themselves, however often they change - nothing to refresh. ASN Manager writes the needed lines into a marked block in `/jffs/configs/dnsmasq.conf.add` (other content stays untouched) and restarts dnsmasq **only when that block changes**; removing the last domain removes the block.

What to know about domains:
- It only works for devices that use the **router as their DNS server**. A browser with "Secure DNS" (DoH), or a device with a fixed DNS server (many TV boxes and streaming devices use 8.8.8.8), asks someone else and the router never sees the answer.
- If **AdGuard Home** (or another DNS server) answers the devices in front of dnsmasq, only names that reach dnsmasq are learned. With the AdGuardHome installer for Asuswrt-Merlin the `ipset=` lines are taken over by AdGuard Home, so the domain entries keep learning; check with `ASNmanager.sh custom learned`. The DNS / DHCP check in the overview shows whether dnsmasq is still running behind it (it moves to port 553).
- dnsmasq only adds an address when it fetches the answer from its upstream server, **not when it answers from its cache**. That is why the cache is emptied when a domain set is created (SIGHUP, dnsmasq keeps running; nothing to do when the cache is off, e.g. behind AdGuard Home): the names are learned at the next lookup. dnsmasq is restarted only when the `ipset=` lines change. Devices have a DNS cache of their own - restarting the app or browser helps.
- IPv4 only. A learned address expires 7 days after its last lookup (each lookup starts the time again, so addresses in use stay). It is not lost by applying the rules, and it survives a router restart: the addresses are saved on the USB device (hourly), on the flash (every 6 hours and at shutdown) and put back at boot. `custom save` saves right away. Connections that were already open before the address was learned stay where they are.
- Each entry has a row of its own in "Traffic per ASN / target" (IP ranges and domains alike; in the light statistics mode everything is counted per interface only). If an address is in a custom entry and in an ASN, the custom entry wins - for the routing as well (since v3.4.0), also when the ASN points to another target: e.g. `*.zdf.de` -> WGC3 for one device while Akamai (AS20940) stays on WAN1.
- **Learned addresses**: click "N learned" in the list to see them (the first 200), or `ASNmanager.sh custom learned [C1]` for all. dnsmasq only stores the addresses, not which subdomain they belong to. The number on the page refreshes every 30 seconds.
- The routing check shows them too (a domain says "none learned" until a device has looked the name up); backups and the restore dialog include them as part of the list; "Remove all" removes them too.

## Performance (CPU load)

The CPU load of the router is mostly decided by what happens to **every forwarded packet**. ASN Manager has two settings for that (Settings tab, card "Performance"; both also in backups):

- **Marking rules** - *Combined* (default): all ASNs that go to the same target interface (and the same source devices) share **one** ipset and **one** marking rule, so a packet is checked once per target, no matter how many ASNs you have. *One rule per ASN* is the earlier way (one set and one rule for every ASN) and uses much more CPU with many ASNs. The routing result is identical; a change takes effect when the rules are applied (the page offers to rebuild from the saved lists straight away). Command line: `ASNmanager.sh rulemode combined|single`. The per-ASN sets stay in both modes (for the statistics, the routing check and the route test).
- **Traffic statistics** - *Per ASN* (default) counts every ASN separately and needs a counting rule per ASN for every packet. *Interface and device only* needs a handful of rules: you still see the traffic per target interface and per device (the table shows one row "All traffic"), but no breakdown by ASN. It takes effect at once and the numbers of each mode are kept. Command line: `ASNmanager.sh stats mode asn|iface`.

How much it saves (lab measurement with 60 ASNs, packets per second one CPU core can forward - more is better): one rule per ASN + statistics per ASN 96,000; combined sets + statistics per ASN 175,000; combined sets + statistics per interface 250,000; no ASN rules at all 329,000. The absolute numbers are lower on a router, the ratio is what matters.

Other things that help: turn the statistics off if you do not need them, keep the ASN list short, and refresh less often (for example every 7 days).

## Speed test

In the "Target interfaces" table every online interface has a **Test** button (SSH menu [15], command line `ASNmanager.sh speedtest WGC1` or `speedtest all`). It measures download, upload and ping **through exactly this interface**, so you can compare WAN and VPN connections, and see how much a tunnel really delivers. The result stays in the table (in Mbit/s or MB/s, like the live values) until the next test or a reboot.

How it works: the test traffic is sent from the address of the interface, and a temporary routing rule (priority 9860, removed afterwards) makes it leave through exactly that interface. If that interface has no usable route (tunnel down), the test **fails instead of measuring another interface**; nothing is sent through WAN in that case. Download and upload each run for 8 seconds with 4 parallel connections to speed.cloudflare.com (about 30 seconds in total, up to ~200 MB download and ~100 MB upload through that interface - the page asks before it starts), the ping goes to 1.1.1.1. The test needs no ASN rule for the interface. `rescue` also removes the temporary rules of an interrupted test.

## Tunnel protection

The server address of every VPN client (WireGuard `wgcX_ep_addr`, OpenVPN `vpn_clientX_addr`; host names are resolved and cached for an hour) always uses the normal routing table, i.e. WAN. A routing rule with a higher priority than all ASN rules takes care of that. So a tunnel can never be routed into itself - for example when an ASN for "All devices" happens to contain the server of your VPN provider, or while a failover "Block" is active. The routing check lists the protected servers; command line: `ASNmanager.sh guard`.

Note: a rule for **All devices** also covers traffic of the router itself (DNS, time, updates, ...). Rules for single devices do not.

## Failover

In the card "Target interfaces", section **Failover**, every target that has ASNs gets a chain of up to two fallbacks, for example `WGC1 -> WGC2 -> WAN1` or `WGC1 -> WGC2 -> Block`. Command line: `ASNmanager.sh failover set WGC1 WGC2,WAN1`, `failover clear WGC1`, `failover show`.

- Every 30 seconds each member of a chain is checked: the interface must have an address and answer a ping through it (1.1.1.1 or 9.9.9.9). After 2 failed checks in a row it counts as down, after 2 good ones as up again - no flapping.
- The ASNs of a target always use the first working member: the router points the routing rule of the target's mark at that member's routing table. The ASN sets and marking rules stay as they are, so the switch is instant; when the target works again, its ASNs return automatically.
- **Block** (kill switch, only as the last fallback) stops the traffic of your devices instead - nothing leaks through WAN while the VPNs are down. The router itself is not blocked (its own traffic for these ASNs uses WAN), so updates, subnet downloads and checks keep working.
- If no member works, the rule stays on the target (if its VPN client is stopped, that can mean WAN - add "Block" to prevent it).
- Every switch is written to the system log (`ASNmanager: Failover: WGC1 is down - traffic for its ASNs goes via WGC2`). The failover section shows the state (green / red per member, "down - via WGC2 since ..."), the ASN list marks the group ("↪ WGC2") and the routing check shows "↪ wgc2" instead of an error.
- Rules of a target with a chain are created even while the target is offline (so the chain works after a reboot with the VPN still down). Existing connections of the failed target are not moved; apps reconnect through the new path.
- Runs from cron every minute (two checks per minute); the chain is stored in `/jffs/addons/asnmanager/failover.conf`, the state in RAM.

## One rule for several devices

The source of a rule can be empty (all devices), one IP or a **comma separated list** of IPs, for example `192.168.1.50,192.168.1.60` (up to 32). It works everywhere: "Add ASNs, IPs or domains", the service presets and editing a row (a device picker with checkboxes, like in the suggestions: tick as many devices as you like, "All devices" clears the choice; you can also type the IPs), the suggestions (tick several devices), backup / restore and the command line (`ASNmanager.sh add WGC1 2906 --src 192.168.1.50,192.168.1.60`). The router creates one marking rule per device; the traffic statistics count each device separately. Each ASN is still on the list only once - adding it again replaces the earlier rule, so to add a device later, edit the row or add the ASN again with the full device list.

## Suggestions from the traffic without a rule

At the bottom of the "Traffic per ASN" card (while counting is enabled) a list shows the ASNs that receive the most traffic **without** a rule - for example "AS2906 Netflix Streaming Services, 9.8 GB, used by TV box, phone". Pick a target interface and the **devices** - "All devices" or any number of devices (the ones that use this ASN are listed first) - and click **Add**; the ASN is put on the list (then apply the rules).

An ASN that is on the list only for some devices stays suggested for the other devices that use it ("on the list for: Laptop (WGC1)"); **Add** then extends the device list of that rule instead of replacing it. The busiest destinations are looked up first with one batch request for up to 100 networks per minute (ip-api.com), so even hundreds of destinations are resolved within a few minutes; the notice shows how much traffic is still waiting and whether look-ups currently fail.

Filters above the list: how many ASNs to show (10 / 20 / 50 / 100, the router keeps the 100 largest), a **device** (shows only ASNs this device uses, with its own traffic, and preselects it) and a **search** for ASN number or name. A counter shows "x of y ASNs". Like the traffic table, the suggestions are a collapsible section of the traffic card and start collapsed; the section headers show how many entries they hold. ASNs that are already on the list are hidden. A suggestion you are not interested in can be hidden with the crossed-out eye next to **Add**; **Show hidden (n)** lists those again, each with a button to bring it back (kept on the router, also from the command line: `ASNmanager.sh suggest hide 32934` / `suggest unhide 32934`, domains likewise).

How it works: every minute the router reads its connection table (`/proc/net/nf_conntrack`) and adds up the new bytes per destination address and device. For this the kernel switch `nf_conntrack_acct` is turned on while counting runs (and restored when it is turned off). The busiest destination addresses are looked up via ip-api.com (fallbacks: ipinfo.io, RIPEstat) - at most 10 per minute, cached per /24 network, in the background. Everything stays in RAM and starts over after a reboot or when counting is turned off.

It is an estimate: very short connections that start and end within the same minute, and the last minute of a connection, can be missed. Only connections from local devices (LAN, guest networks, VPN server clients) to public addresses are taken into account. Traffic of the router itself is left out - also when the router sits behind another router (for example a FritzBox) and its WAN address is a private one.

### Suggestions by domain (optional)

The switch **by ASN | by domain** above the suggestions shows the same traffic grouped by the **domain** a device looked up, for example `zdf.de` with the names below it (`nrodl.zdf.de`, `www.zdf.de` ...). **Add** puts the main domain on the list as a domain entry - it covers every subdomain. Domains and ASNs that are already on the list are hidden; a domain that is on the list only for some devices stays suggested for the others.

It is off by default. When you turn it on (in the domain view, or `ASNmanager.sh suggest domains on`), dnsmasq writes every lookup it answers into a file in RAM (`log-queries=extra`, `log-facility=/tmp/asnmanager-dnsq.log`). Once a minute the counting loop reads the new lines, notes which name belongs to which address (kept 2 days, in RAM) and empties the file again - nothing is written to the flash memory and nothing is looked up on the internet. The CPU cost is very small (a few hundred lines per minute in a normal home). Messages of dnsmasq that are not lookups (DHCP, start-up) are passed on to the system log, so the log looks as before. Turning it on or off restarts dnsmasq once. If another add-on (for example Diversion) already has dnsmasq write such a log, that file is only read and dnsmasq is left as it is.

With AdGuard Home in front of dnsmasq, its upstream should be dnsmasq (`127.0.0.1:553`), not Unbound or another server directly - otherwise dnsmasq sees almost no lookups and this view stays nearly empty. The domain entries themselves still learn when the AdGuard Home installer copies the dnsmasq domain lines into its own `ipset_file` (it does by default); without that copy they learn only through dnsmasq, and the DNS check in the status warns. Note: with that copy, every change of a domain entry restarts AdGuard Home (DNS pauses for up to a minute).

Limits: traffic to an address whose name was looked up before the collection started, answered from a cache in front of dnsmasq (AdGuard Home), or not through the router at all ("secure DNS" in a browser, a device with a fixed DNS server) has no name - the page shows how much that is. Large networks (CDNs) serve many names from one address; the most recent lookup counts.

## Traffic statistics

The card **Traffic per ASN** (above "Diagnostics", collapsed by default - click the header or the dashed bar "Show details", which also shows the total and the number of ASNs) shows how much traffic goes through each ASN rule. It is **off by default** - click **Enable** to start counting.

What you get:

- A total bar (download, upload, total, packets) and the split between "via ASN rules" and "not assigned to an ASN"
- Download, upload, **live throughput**, packets and share (bar and percentage) per ASN; the row **Not assigned to an ASN** shows everything else, split by interface (WAN / VPN)
- Click a row to see what is behind it: an ASN shows the traffic **per client** (name, IP and the network: LAN / Wi-Fi, Guest 2.4 / 5 GHz, WireGuard / OpenVPN server); "Not assigned" shows its interfaces, and a click on an interface shows the devices connected through it. Rows have a framed arrow and a device counter, a hint line above the table explains it, and "expand all / collapse all" opens everything at once
- The percentage is the share of the total traffic; in expanded rows it is the share of the row above
- **Live throughput**: the current rate per ASN, interface and device (measured between two counter readings, every 10 seconds), shown in the traffic table, as a total under the summary tiles and per interface in the "Target interfaces" table. Choose **Mbit/s** or **MB/s** once in the **Settings** tab ("Display"); the choice applies to the whole page - live values, interface table, speed test results, summaries and status messages - and is remembered in the browser (data amounts such as GB are not affected). Live values need the statistics to be enabled.
- Buttons in the card header: **Disable** (numbers are kept), **Disable & reset** (numbers are deleted), **Enable**

How it works:

- Counting is done by the router's firewall in its own chains (`ASC_*` in the `mangle` table, `FORWARD` chain). The routing rules of ASN Manager are not touched. Disabling the statistics removes all counting rules, so there is no load while it is off. While it is on, a small background loop (every 10 seconds) refreshes the page data and follows changes of ASNs, devices and interfaces.
- Clients are found automatically (WebUI device list, ARP table of every LAN / guest / VPN-server interface, DHCP leases; up to 96 private addresses). A device that just connected gets its own counter within about 10 seconds; its very first packets appear under "Other addresses (no counter rule)". `ASNmanager.sh stats unknown` lists addresses that have no counter rule (e.g. devices behind a second router).
- Numbers survive rule rebuilds (Apply, daily refresh), added / removed ASNs and firewall restarts. Removed ASNs keep their numbers until you reset.
- Numbers also survive a **reboot**. They are saved on the **USB device**, in the `ASNmanager` folder next to the `.conf` backups (file `asn_manager_traffic_stats.txt`) - nothing is written to the router's flash (`/jffs`). Saving happens at most once per hour, only if something changed, when you disable the statistics and on shutdown (`services-stop`). A power loss costs at most the last hour. After a boot, counting resumes automatically once the ASN rules are loaded; if the USB device is mounted later than that, the saved numbers are merged in as soon as it appears. The folder is the one where the numbers already are, else the one holding your `.conf` backups, else `ASNmanager` on the first mounted USB partition (the default of the backup menu).
- **Without a USB device** the statistics still count, but the numbers only live in RAM and are lost on a reboot; the card shows a warning, and nothing is saved until a USB device is connected.
- **Saving can be turned off**: the link "Turn saving off" next to the storage line in the traffic card (or `ASNmanager.sh stats saving off`). Then nothing is written to or read from the USB device; the numbers live in RAM only and start over after a reboot. "Turn saving on" writes the current numbers right away. The switch is a small marker file in `/jffs/addons/asnmanager/` (written only when you switch).
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
ASNmanager.sh add WGC3 '*.zdf.de' 181.209.202.0/24 --note "ZDF Mediathek"
ASNmanager.sh note 13335 Cloudflare via VPN
ASNmanager.sh custom list
ASNmanager.sh custom learned
ASNmanager.sh preset 4 OVPN1
ASNmanager.sh edit 13335 WAN2
ASNmanager.sh remove 13335
ASNmanager.sh apply
ASNmanager.sh apply full
ASNmanager.sh retry
ASNmanager.sh lookup netflix.com
ASNmanager.sh test netflix.com
ASNmanager.sh explain zdf.de 192.168.1.20
ASNmanager.sh device 192.168.1.20
ASNmanager.sh dnschain
ASNmanager.sh diag
ASNmanager.sh schedule 1 04:30
ASNmanager.sh stats enable
ASNmanager.sh stats show
ASNmanager.sh stats mode iface
ASNmanager.sh rulemode combined
ASNmanager.sh suggest domains on
ASNmanager.sh webui location vpn
ASNmanager.sh names
ASNmanager.sh dns
ASNmanager.sh rescue
ASNmanager.sh help
```

Without arguments the interactive menu starts.

## Credits

- Round country flags: [circle-flags](https://github.com/HatScripts/circle-flags) by HatScripts, MIT License (downloaded once per country by the router)
- IP geolocation / ASN lookup: ip-api.com, with ipinfo.io and RIPEstat as fallback
- ASN names (holders): RIPEstat (looked up once per ASN)
