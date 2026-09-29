## v2.0.0

- New modern WebUI design: cards, status tiles, modern input fields, badges and a live progress bar
- Theme switch: Dark, Light, Blue (remembered in the browser)
- Language switch: router default / English
- The tab can be shown in the VPN menu (after "Instant Guard") instead of Addons: menu option [15] or `webui location vpn`
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
