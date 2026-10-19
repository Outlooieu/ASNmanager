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
