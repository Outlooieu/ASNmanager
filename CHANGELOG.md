## v3.1.7

- Fixed: the routing check (cron, every 5 minutes) could run for 15 minutes and more, so several runs piled up. On a real router most of the hanging runs were found inside `nvram get wan0_ifname`: the check asked for the WAN interface for every ASN (about 340 calls per run, each one a process of its own). The WAN values from nvram are now read once per run (routing check, failover run, applying the rules; in the counting loop once a minute): 130 -> 14 nvram calls for the routing check and 230 -> 38 for applying the rules in a lab with 60 ASNs
- The routing check never runs twice at the same time (a second start while the first one works does nothing) and is stopped after 4 minutes; a lock left behind by a killed run is ignored
- `stats diag` and the clean-up of hanging runs ignore processes that are already gone (they showed up as "running 786000 s")

## v3.1.6

- `stats diag`: a finished process that its parent has not collected yet and the menu open in an SSH window were reported as "hanging"; now they are shown as what they are, and only real runs are counted

## v3.1.5

- Fixed: hanging processes piled up on the router (dozens of "check run" and "stats loop" processes, constant CPU load, statistics buttons without answer). Cause: BusyBox `nslookup` has no time limit and can wait for ever (the routing check resolves the names of the VPN servers, the suggestions look up addresses). Now every name lookup is limited to 6 seconds and every `curl` has a maximum time (public IP, update check, WebUI page)
- New: the routing check (cron, every 5 minutes) first stops runs of the periodic jobs that are older than 15 minutes, together with what they wait for, and writes it to the syslog ("hanging run ... killed"); `rescue` now also stops the helper processes of old counting loops (never the loop itself)
- `stats diag` lists every ASN Manager process with its running time and warns about hanging ones

## v3.1.4

- Fixed: after an update the notice "A new version is available ... (installed: vOLD)" stayed, because the stored check result is only renewed every 6 hours. The update now writes the result itself, and the page ignores a check result that names another installed version and checks again
- New: `stats diag` - one command that shows where the traffic statistics hang (counting loop, lock and its owner, age of stats.js, running rebuild, service-event hook, processes, how long one export takes)
- The page no longer depends on the router clock matching the PC clock when it waits for the statistics to answer (it also accepts a changed time stamp); the timeout message now says to run `stats diag`

## v3.1.3

- Fixed: after "Update now" in the WebUI the header kept showing the old version (and "Data refreshed" the old time) although the update was installed. The script that is still running at the end of the update is the OLD one and wrote the page data with its own version number. Now the new script writes the data after an update; in addition the page notices data from an older script and asks for fresh data once per session (so it also works when the update is done by an older version)

## v3.1.2

- WebUI: the device picker with checkboxes (several devices, "All devices") is now also used in the service presets and when editing a row of the list; while a row is edited the list frame no longer clips the picker

## v3.1.1

- WebUI: "Add ASNs, IPs or domains" has a device picker with checkboxes like the suggestions - several devices can be ticked, "All devices" clears the choice; the chosen IPs appear in the source field, which can still be typed by hand (the picker follows)

## v3.1.0

- **Custom entries: single IPs, CIDR ranges and domains** (`/8` to `/32` for ranges). Typed in the same field as ASNs ("Add ASNs, IPs or domains", SSH menu [2], `add`), mixed in one go; target interface and source devices as for ASNs; they get an ID (`C1` ...) for edit / remove, which also work by value (`remove googlevideo.com`). Stored in `/jffs/scripts/custom_list.txt`, shown in the list with an "IP" / "Domain" tag, part of backups (new `[CUSTOM]` section; the restore dialog counts them as part of the ASN list), the routing check and `list`; `custom list|apply|early|purge` on the command line
- **IP / CIDR** entries join the combined marking set of their target (or get their own set in the "one rule per ASN" mode) and survive every refresh and re-apply
- **Domains** (`*.googlevideo.com` = the domain and all subdomains): dnsmasq fills an ipset with the addresses it resolves (`ipset=` lines in a marked block of `/jffs/configs/dnsmasq.conf.add`, dnsmasq is restarted only when the block changes); one set per target and device group that is NOT rebuilt by "apply", so learned addresses stay; set up early at boot. Works only for devices that use the router as DNS server (not with DoH / fixed DNS), IPv4 only
- WebUI: link "← Router" in the header; input checks for ASN / IP-CIDR / domain with a note when a domain is typed; the list shows the type and, for domains, how many addresses were learned; the routing check shows "none learned" for a domain without answers yet
- Removing every entry removes the dnsmasq block, the domain sets and their rules; uninstall removes them too
- Not included: separate traffic statistics per custom entry (their traffic counts as "not assigned")

## v3.0.0

- **Much less CPU per packet.** Marking rules: all ASNs of the same target (and the same source devices) now share ONE ipset and ONE rule instead of one set and one rule per ASN. With 60 ASNs the router checks 4 rules instead of 68 for every forwarded packet; routing results are identical (checked per interface with real traffic, source-device rules, overlapping prefixes of two ASNs, failover, routing check). The per-ASN sets stay (statistics, routing check, route test). Setting "Marking rules": *combined* (default) or *one rule per ASN* (the old way, as a way back); command line `rulemode combined|single`
- **Traffic statistics per interface and device only** (new option, default stays "per ASN"): about 24 counting rules instead of 500; the traffic card shows one row "All traffic" with the breakdown by interface and device. Command line `stats mode asn|iface`; the counters of each mode are kept apart, so switching back and forth loses nothing
- Settings tab: new card "Performance" for both options (switching the marking rules asks first and rebuilds the rules from the saved lists); both settings are part of backups and of the restore dialog
- Rebuilding the rules sets up the routing rule and route of a target once per target instead of once per ASN
- Routing check, failover hint, ipset status, cleanup and uninstall know the combined sets
- Lab measurement (60 ASNs, packets per second per CPU core): before 96,000; combined sets + statistics per ASN 175,000; combined sets + statistics per interface 250,000; without ASN rules 329,000

## v2.9.4

- Fixed: the backup download in the WebUI failed with "The backup could not be prepared". The router's web server does not deliver every file type: the backup was written as `backup.txt`, now `backup.js` like all other data files
- If the router still does not deliver the full backup, the page now saves a basic backup itself (ASN list, schedule, failover chains, statistics settings) after 15 seconds and says why, instead of an error

## v2.9.3

- SSH menu tidied up and put in a sensible order: the entries are grouped by what you do - **ASNs** (list, add, find, presets, edit, remove), **Rules & automation** (apply, schedule, failover), **Check & diagnose** (routing check, ipset status, route test, traceroute, interface IPs, speed test) and **ASN Manager** (WebUI tab, backup, update, rescue, uninstall); shorter, consistent wording
- **The numbers changed.** Old -> new: [1] -> [1], [2] -> [2], [3] -> [3], [4] -> [4], [5] remove -> [6], [6] apply -> [7], [7] ipset -> [11], [8] test routing -> [12], [9] interface IPs -> [14], [10] traceroute -> [13], [11] update -> [18], [12] schedule -> [8], [13] backup -> [17], [14] uninstall -> [20], [15] WebUI tab -> [16], [16] edit -> [5], [17] routing check -> [10], [18] failover -> [9], [19] job & rescue -> [19], [20] speed test -> [15]; exit is `e` (`0` still works)
- Messages that name a menu number ("Run option [7] to apply the rules" ...) follow the new numbers; invalid input only redraws the menu

## v2.9.2

- Settings tab: new card "Display" with the unit for data rates (Mbit/s or MB/s); it applies to the whole page - live throughput, interface table, speed test results, summaries and the status message after a speed test; the switch in the traffic card is replaced by a link to the setting
- The page always starts on the ASNs tab (the last tab is no longer remembered)

## v2.9.1

- Backup contains everything: ASN list (with source devices), auto-refresh schedule, failover chains and settings (traffic statistics on / off, USB saving, WebUI tab location); the WebUI download is created by the router and is the same file as the one from the SSH menu (the SSH menu only saved the ASN list before, and restoring did not bring back the schedule)
- Restore asks what to restore: tick boxes in the WebUI, one question per part in the SSH menu; ASN list: replace or merge; old backups (list only, list + schedule, plain lists) still work and parts a backup does not contain are left alone
- New: command line `backup [dir|show]` and `restore <file> [--only asn,schedule,failover,settings] [--merge]`
- A setting restored from a backup reports what it did; invalid values are skipped

## v2.9.0

- New: **speed test per target interface** (manual): download, upload and ping through exactly one interface (temporary routing rule, fails instead of measuring another interface), result per interface in the "Target interfaces" table; WebUI button "Test" (asks first, the test takes about 30 seconds), SSH menu [20], command line `speedtest <TARGET|all>`
- Rescue and uninstall also remove the temporary rules of a speed test

## v2.8.2

- Fixed: traffic statistics did not count after a rule rebuild had been aborted. A progress file in /tmp that a killed worker leaves behind made the statistics believe a rebuild was still running: "Enable" waited up to 4 minutes, the counting rules were never created, and the loop did not try again. Now only a really running worker counts, enabling does not wait for it (counting starts when the rebuild is finished) and "in sync" is only noted after a successful set-up
- Fixed: a lock of the statistics left by a killed job is recognised at once (owner process gone) instead of after 40 seconds
- New: a stopped counting process is started again when the page asks for data; the traffic card shows a notice with a **Repair** button if the counting is not running properly; command line `stats repair` (keeps the numbers, cleans temporary files, sets up the counting again); `rescue` also removes the lock of the statistics
- WebUI: the tabs are now clearly separate tab buttons (own border, folder look, blue base line, active tab filled)
- WebUI: removed "Hide details" from the traffic card

## v2.8.1

- Fixed: suggestions showed "N destination address(es) are still being looked up" forever - only the 100 busiest destinations were ever looked up; now all are, busiest first
- Fixed: an ASN on the list for some devices was hidden completely, so traffic of other devices to it (e.g. the TV box) was never suggested; such ASNs are now suggested for the other devices, marked "on the list for ...", and "Add" extends the device list of the existing rule
- Faster look-ups: one ip-api batch request resolves up to 100 networks per minute (single look-ups with fallbacks only for what the batch could not answer)
- The look-up lock expires after 10 minutes (an interrupted run could stop all look-ups)
- The notice shows the traffic still waiting for a look-up and whether look-ups currently fail

## v2.8.0

- WebUI: new layout - the overview (status, routing check, "Apply rules", notices) stays at the top, everything else is in tabs ordered by use: ASNs, Traffic, Targets & failover, Diagnostics, Settings; counters in the tabs (ASNs, statistics on, active failovers), the last tab is remembered
- WebUI: "Add ASNs", "Find ASN for a domain or IP" and "Service presets" are one card with three sub-tabs, directly below the ASN list; taking an ASN from the search switches to "Enter ASNs"
- WebUI: the traffic card opens by itself in its tab; the routing-check notice links to the ASN list
- SSH menu: [16] Edit ASN (target / source devices), [17] Routing check & tunnel protection, [18] Failover chains (show, set incl. Block, remove, check now), [19] Job status & rescue; existing option numbers stay the same
- Rescue no longer stops an interactive menu open in another SSH window
- Tunnel protection: a new or changed VPN client server is protected right away (only the name resolution is cached for an hour)

## v2.7.2

- Fixed: ASN Manager could hang for many minutes after changing failover chains. With "Block" active, the router's own traffic (connectivity check, subnet downloads, GitHub update) was blocked as well, so "Apply rules" waited up to 4.5 minutes for the internet and every other action was refused meanwhile
  - "Block" now stops the devices only; the router's own traffic for these ASNs uses WAN
  - saving a failover chain no longer starts "Apply rules" (it only says when rules are missing)
  - "Apply rules" started from the WebUI or the menu waits at most about 30 s for the internet (the long wait stays for the boot)
  - failover runs from cron, WebUI and "Apply rules" no longer run at the same time
- New: `rescue` on the command line - stops stuck jobs, removes locks, restarts failover and statistics

## v2.7.1

- Fixed: "Another ASN Manager job is still running" without a visible job - the page now shows a job that is still running when it is opened (started in another tab, on another device or before a reload) and follows it; a refused action follows the running job and names it
- Job lock: a job counts as running only if its process is still ASN Manager and younger than 60 minutes (a lock left by a killed job is cleared even if its process id was reused); the message names the running job and its start time
- New: `job` / `job clear` on the command line

## v2.7.0 - amtm ready

- The file on GitHub is now the script itself (no installer wrapper): the installed file is byte for byte the hosted one, so amtm's version and MD5 checks match. New install command: `curl ... -o /jffs/scripts/ASNmanager.sh && ... ASNmanager.sh install` (the old `sh -c "$(curl ...)"` one-liner cannot work any more since v2.6.0: the script is larger than the 128 KiB limit for a single command argument). Older installations update normally via menu option [11] or the WebUI.
- `version=x.y.z` line (no quotes) at the top for amtm; `SCRIPT_VERSION` stays for older updaters
- Main menu: exit with `e` (0 still works)
- New: `amtmupdate check` (exit code 0 = amtm may update) and `amtmupdate` (update without questions, two lines of output, exit code 0 / 1)
- New: `install` command; a copy of the script started from another folder puts itself into /jffs/scripts and installs from there
- Uninstall: asks whether the .conf backups in /jffs and on USB devices should be deleted too; also removes all files in RAM and empty ASNmanager folders on USB devices
- Fixed: started without a terminal (e.g. by an automated install), the script ended at once while trying to read from /dev/tty

## v2.6.3

- New: **tunnel protection** - the server address of every VPN client always goes via WAN (routing rule with priority over all ASN rules and a failover "Block"), so a tunnel can never be routed into itself; shown in the routing check, command line `guard`
- Fixed: suggestions listed traffic of the router itself as a device when the router sits behind another router (private WAN address, e.g. behind a FritzBox) - all addresses of the router are now left out, also in data collected before

## v2.6.2

- "Auto-refresh schedule" and "Backup & restore" moved to the bottom of the page
- Fixed: on phones some lines (e.g. the routing check summary) were shown in a much larger font - Chrome's automatic text enlargement is now switched off for the page

## v2.6.1

- Wording: "USB stick" is now "USB device" everywhere
- Traffic statistics: saving to the USB device can be turned off ("Turn saving off" / "Turn saving on" in the traffic card, command line `stats saving on|off`); when off, nothing is written to or read from the USB device and the numbers are kept in RAM only

## v2.6.0

- New: **failover** - a chain of up to two fallbacks per target (e.g. WGC1 -> WGC2 -> WAN1, or "Block" as kill switch); checked every 30 s with a ping through the interface (down after 2 failed checks, back after 2 good ones); the routing rule of the target is pointed at the first working member, its ASNs return automatically; switches are logged to syslog
- Failover section in the "Target interfaces" card with state per member, badge in the ASN list group header, routing check shows "↪ wgc2" / "blocked" instead of an error
- Marking rules of a target with a failover chain are created even while it is offline
- Command line: `failover set | clear | show | once`

## v2.5.0

- New: **one rule for several devices** - the source of a rule can be a comma separated list of IPs (up to 32): "Add ASNs", edit, suggestions, backup / restore and command line; one marking rule and separate traffic counting per device; the device picker adds to the list instead of replacing it
- Suggestions: tick several devices per ASN ("All devices" or any selection), devices that use the ASN are listed first
- Suggestions: filter bar - number of ASNs (10 / 20 / 50 / 100), device (shows its own traffic and preselects it), search for ASN or name, counter "x of y"
- Traffic card: "Traffic per ASN / target" and the suggestions are collapsible sections, collapsed by default, with a counter in the header
- The suggestion list keeps the chosen target and devices while new data arrives and does not redraw while a list is open
- Backup restore sends entries separated by ";" (comma separated device lists inside an entry); the old format with "," between entries is still understood

## v2.4.1

- Suggestions: new "Device" column next to "Target" - add the rule for all devices (default), for one of the devices that use this ASN, or for any other known device (LAN / Wi-Fi, WireGuard and OpenVPN server peers)

## v2.4.0

- New: **suggestions from the traffic without a rule** - the traffic card lists the ASNs that receive the most traffic without a rule (bytes, devices that use them) with a target selection and "Add"; based on the connection table (sampled every minute, byte counters switched on while counting runs), destination addresses looked up via ip-api.com (max. 10 per minute, cached per /24), RAM only
- Fixed: enabling, disabling and resetting the statistics now change the state only inside the lock - an "enable" arriving while a "disable" was still running could leave the counting off

## v2.3.0

- New: **routing check** - a "Routing" column in the ASN list shows for every ASN whether a sample address really leaves through the target interface (kernel decision with the rule's fwmark), plus checks for loaded subnets, active rule and interface state; summary line with "Check now" in the status card, red banner on errors; traffic seen on the target interface since the previous check in the tooltip (with statistics on); runs every 5 minutes, after "Apply rules" and on demand; command line `check`
- New: **live throughput** per ASN, interface and device in the traffic table, as a total under the summary tiles and per interface in the "Target interfaces" table; switch between Mbit/s and MB/s (remembered in the browser)
- The page keeps the statistics up to date while the traffic card is closed (needed for the live column of the interfaces)
- Traffic table made more compact so the new column fits

## v2.2.1

- The update status ("Up to date (v2.2.1) - checked ..." / "v2.x.y available" / "GitHub not reachable") and the "Check for updates" link moved from the status card into the page header, below the version and "Data refreshed"

## v2.2.0

- New: **update from the WebUI** - the status card shows the installed version and checks GitHub (on opening the page at most every 6 hours, or on demand); a banner offers "Update now" with a link to the changelog; the page reloads after the update
- The update is safe: syntax check before replacing, previous script kept as `ASNmanager.sh.bak`, atomic replacement, automatic rollback if the new version does not start, matching page and statistics loop are updated
- Command line: `update check` and `update install`
- Uninstall also removes `ASNmanager.sh.bak`

## v2.1.4

- Traffic card: clearer that it can be opened - bigger framed arrow, hover highlight, a dashed bar "Show details" under the header with a one-line summary (total traffic, number of ASNs), a "Hide details" link at the bottom, keyboard support (Tab, Enter, Space)

## v2.1.3

- Traffic card: the share column shows the percentage next to the bar (share of the total, in expanded rows share of the row above)
- Traffic card: in "Not assigned to an ASN" every interface can be clicked to show the devices connected through it
- Traffic card: clearer that rows can be expanded - framed arrow, device counter per row, hint line above the table, "expand all / collapse all", stronger hover

## v2.1.2

- New: orbit animation around the logo in the page header (two dashed paths with glowing dots, follows the selected theme, stops when "reduce motion" is set in the operating system)

## v2.1.1

- Traffic statistics: the numbers are now saved on the **USB stick** (folder `ASNmanager`, next to the `.conf` backups, file `asn_manager_traffic_stats.txt`) instead of the router's flash (`/jffs`)
  - written at most hourly, only if something changed, on disable and on shutdown
  - without a stick the numbers stay in RAM only; the card shows a warning
  - a stick that is mounted after the boot is picked up automatically (saved numbers are merged, never overwritten)
  - nothing is written to the leftover mount-point directory of an unplugged stick
  - "counting is on" is now remembered by the hook line in `services-start` (no state file on flash)
  - numbers and state of v2.1.0 (`/jffs/addons/asnmanager/stats`) are taken over once and the old folder is removed
  - uninstall removes the statistics file on the stick, the `.conf` backups stay

## v2.1.0

- New: **traffic statistics** per ASN and per client (card "Traffic per ASN" in the WebUI, collapsed and off by default)
  - total bar, download / upload / packets / share per ASN, "not assigned" row split by WAN / VPN interface
  - click an ASN for the traffic per client, with the network of each client (LAN / Wi-Fi, guest 2.4 / 5 GHz, WireGuard / OpenVPN server)
  - buttons: Disable, Disable & reset, Enable
  - counting in own firewall chains, routing rules are not touched; no load while disabled
  - numbers survive Apply / daily refresh, ASN changes, firewall restarts and reboots (saved hourly, only when changed, plus on disable and shutdown)
  - command line: `stats enable | disable | reset | show | unknown | probe`
- Menu option [14] (uninstall) also removes the statistics (rules, saved numbers, hooks)

## v2.0.0

- New modern WebUI design: cards, status tiles, modern input fields, badges and a live progress bar
- Theme switch: Dark, Light, Blue (remembered in the browser)
- Language switch: router default / English
- The tab now appears in the VPN menu (after "Instant Guard") by default; move it to Addons via menu option [15] or `webui location addons`
- Source device picker now also lists WireGuard server peers and connected OpenVPN server clients
- Round country flags (circle-flags, MIT) for the external IPs, fallback to rectangular flags or the country code
- ASN lookup result shown in a full-width table with "Add to form"
- Fix: the WebUI no longer removes other menu entries with the same tab name
- Fix: country code and name were swapped for external IPs

## v1.3.0

- New WebUI page in the router web interface (Addons tab), enabled by default, can be disabled via menu option [15]
- Live progress while applying rules, failed ASNs highlighted with "retry failed"
- Edit target / source IP of existing entries, source device picker from the DHCP client list
- Backup download / restore in the WebUI (same format as the menu backup)
- Domain/IP ASN lookup: ignores 0.0.0.0 answers from ad blockers, retries with public DNS, falls back to ipinfo.io / RIPEstat
- Command line interface (`ASNmanager.sh help`)
- "Apply" with an empty list now removes all ASN routing rules
- Service presets defined once (menu + WebUI)
- Fix: updater copied the installer wrapper line into the installed script
- Fix: hook scripts created without `#!/bin/sh`
- Uninstall also removes WebUI files, folders, hooks and temporary files
