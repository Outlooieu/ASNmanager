## v3.9.9

- Preset "ZDF Mediathek": the live streams (measured) come from `zdf-hls-15` ... `zdf-hls-19.akamaized.net` (one per channel) and KiKA live from `kika-live.ard-mcdn.de`. Added

## v3.9.8

- Preset "arte": measured while watching - videos come from `arte-cmafhls.akamaized.net` (subtitles `arte-cmafhlssub.akamaized.net`, playlists `manifest-arte.akamaized.net`), the live stream from `artesimulcast.akamaized.net`. Added

## v3.9.7

- Preset "ZDF Mediathek": measured while watching - the ZDF videos come from `zdfvod.akamaized.net`, `zdfvod-pckgr.akamaized.net` and `zdfvod-rwrtr.akamaized.net` (about 85 % of the traffic in the test). Added

## v3.9.6

- Preset "ARD Mediathek": measured on a phone while watching videos and live streams - the ARD now streams through its own multi-CDN domain `ard-mcdn.de` (e.g. `br-vod.ard-mcdn.de`, `tagesschau-live.ard-mcdn.de`, `rbb-live.ard-mcdn.de`, `mdr-live.ard-mcdn.de`) and for the BR through `brvod-pckgr.akamaized.net` / `brvod-rwrtr.akamaized.net`. These are added; without them a large part of the video went past the preset

## v3.9.5

- Two new preset categories:
  - **Smart home & IoT**: Amazon Alexa / Echo, Google Nest, Ring, Philips Hue, tado, Sonos, Shelly, Netatmo, Tuya / Smart Life, eufy, Roborock, SwitchBot, Home Assistant Cloud - such devices often have trouble through a VPN (slow voice commands, failed logins, clouds that block VPN addresses), the usual way is to route them via WAN
  - **Updates & downloads**: Windows Update, Apple software updates, Android / Google Play downloads, Steam, PlayStation, Xbox and Epic game downloads, Debian / Ubuntu - large downloads that need no privacy, via WAN they do not load the tunnel

## v3.9.4

- Service presets checked on a router: every main domain answers, the CDN domains were confirmed through typical subdomains (or public domain databases). Removed what could not be confirmed: `indazn.com` and `dazn-api.com` (DAZN) and `spotifycdn.net` (Spotify)

## v3.9.3

- Service presets: 20 ASNs removed that announce no prefixes at the moment (they would show up as "failed" with 0 subnets): Twitch 46489 / 397153, Blizzard 32163, Ubisoft 8361 / 22634 / 28759, NVIDIA 60977, Meta 149642, OpenAI 401864, Apple 2709 / 1042, Amazon 38895, Google 22859 / 26910 / 36039, Microsoft 8071-8074 / 6584. Twitch, Ubisoft and OpenAI work through their domains

## v3.9.2

- Own presets: a file `presets.txt` in `/jffs/addons/asnmanager/` or in the `ASNmanager` folder of a USB device adds presets of your own (one per line: `category|Name|ASNs and domains|` or `...|wide`). They appear after the built-in ones, in the menu, on the command line and in the WebUI; nothing of it leaves the router
- Country-specific presets (national news sites, banks, public services, regional shops) are no longer built in - they belong in an own presets file. The built-in list has 110 presets in 9 categories

## v3.9.1

- 76 more service presets (135 in total), three new categories:
  - Streaming: Max / HBO Max, Apple TV+ / Apple Music, SoundCloud, Deezer, TIDAL, Audible, Pluto TV, Plex, Vimeo, Dailymotion, ProSieben / Sat.1 / Kabel Eins, Kick
  - TV & media libraries: funk, ServusTV
  - **News** (new): Spiegel, Zeit, FAZ, Süddeutsche, Welt, Bild, n-tv, t-online, heise / golem, BBC, CNN, New York Times
  - Gaming: Rockstar, Activision / Call of Duty, Minecraft, Roblox, GOG, Bethesda, FACEIT, HoYoverse, Wargaming
  - Social: LinkedIn, Pinterest, Bluesky, Tumblr, Threema; Threads added to Meta
  - Tools & work: Microsoft 365 / Outlook, Slack, Notion, Dropbox, Webex, Gemini, Perplexity, DeepL, Canva, Figma, AnyDesk, TeamViewer, Proton
  - Shopping: Zalando, Otto, AliExpress, Temu, Shein, Etsy, IKEA, Lidl, Booking.com, Klarna
  - **Banks (DE)** (new): Sparkasse, ING, DKB, comdirect, Commerzbank, Deutsche Bank, Postbank, Consorsbank, N26, Trade Republic - banks often block VPN addresses, route them via WAN
  - **Services (DE)** (new): ELSTER, Deutsche Bahn, DHL / Deutsche Post, Telekom
  - Tests: browserleaks.com, ipleak.net, dnsleaktest.com

## v3.9.0

- Service presets with **domains** and **categories**: 59 presets in 8 categories - Streaming (Netflix, YouTube, Disney+, Prime Video, Spotify, Twitch, DAZN, Paramount+, Crunchyroll, WOW / Sky, Joyn, RTL+, Zattoo, waipu.tv), TV & media libraries (ARD with the regional broadcasters, ZDF & 3sat, arte, Deutsche Welle, HbbTV, ORF, SRF), Gaming (Steam, Epic / Fortnite, PlayStation, Xbox Live, Nintendo, Riot, Blizzard, EA, Ubisoft, GeForce NOW, Discord), Social & messaging, Tools & work (Zoom, Teams, ChatGPT, Claude, GitHub, Apple), Shopping & payment, Cloud & CDN (whole networks, marked ⚠) and Tests (speed tests, IP check)
- A preset now holds ASNs and / or domains; the domains become domain entries (covering every subdomain). Services without a network of their own (Disney+, Spotify, Prime Video ...) work through their domains
- WebUI: choose the category first, then the service; below, every ASN and domain of the preset is shown, those already on the list are highlighted ("2 of 5 already on the list")
- SSH menu: the presets are listed by category with the number of ASNs and domains; adding and removing a preset handles the domains as well
- The preset numbers for `preset <n>` changed - see `ASNmanager.sh presets`

## v3.8.7

- Fixed: the main source of the ASN subnets did not answer any more (404) - the ipverse repository was renamed in January 2026 (`asn-ip` -> `as-ip-blocks`) and the files are called `ipv4-aggregated.txt` now. Since then every ASN was loaded from the slower fallbacks (RIPEstat, HackerTarget). The new address is used now
- Removed the fallback api.bgpview.io - the service does not exist any more

## v3.8.6

- Service presets corrected: every ASN was checked against its holder in RIPEstat. Wrong ones are gone (e.g. Microsoft in "Google Services", Vultr in "Telegram", Alibaba in "Spotify", foreign networks in PlayStation, Nintendo, Zoom, OpenAI, NVIDIA, EA, Ubisoft, Epic, GitHub, Microsoft) and the right ones added (Sony Interactive 33353, Nintendo 11278, Zoom 30103, OpenAI 401864, NVIDIA 11414 / 20347 / 60977, Ubisoft 8361 / 22634 / 28759, Apple 6185 / 2709 / 1042, more Google, Microsoft, Amazon, Meta, Twitch, Riot, Blizzard and DigitalOcean networks)
- "Disney+ / Hulu" and "Spotify" removed: they have no network of their own (they stream through CDNs / cloud) - use domain entries. Epic Games and EA are marked "own network only" (their game servers run in the cloud)
- Presets that route a large share of the internet (AWS, Google, Microsoft, Cloudflare, Akamai, Fastly, Hetzner / OVH, DigitalOcean / Linode, Oracle Cloud) are marked with ⚠ (SSH menu: "(!)") and ask before they are added
- Note: the preset numbers on the command line (`preset <n>`) changed with this list - see `ASNmanager.sh presets`

## v3.8.5

- The status data is loaded automatically when the page opens: if the data file of the router is older than 2 minutes, the page asks the router to write it again right away (interfaces online, subnets, devices, last apply ...) - no need to click "Reload data" first (suggested by AvalonOC)

## v3.8.4

- The status line under the buttons no longer shows the last output line of a diagnostic tool (e.g. "[INFO] suggestions by domain: on ..." after "Check DNS chain"). For the tools of the Diagnostics tab and the look-up it now says "<tool>: done - see the result below" or "... failed"; the full output is in the output box as before

## v3.8.3

- The routing check line ("68 OK · 0 warnings · 0 errors", "Check now") moved to Diagnostics as well. The status card shows it only when there are warnings or errors

## v3.8.2

- Status card: only problems. The lines "Auto-refresh of subnets" and "DNS / DHCP" moved to the Diagnostics tab (top of the card); in the status card a line appears only when the cron job of the auto-refresh is missing, and a DNS problem shows as before as a banner above the status card. The routing check line stays

## v3.8.1

- Diagnostic bundle anonymised further: the domains of your entries become `domain-01.de`, `domain-02.com` ... (the same placeholder everywhere in the file, the ending is kept), notes and the descriptions of the VPN Director rules are left out, and the tunnel addresses of the VPN clients are masked as well. A checkbox "Domains in clear text" (`ASNmanager.sh diag full`) keeps the domains for the case that a domain rule is the problem. The page says what is masked and what stays readable (local addresses, ASN numbers, router model)

## v3.8.0

- Fixed: "Download" of the diagnostic bundle failed ("request cannot be completed") - the router's web server does not deliver .txt files from the add-on folder. The page now fetches the bundle like its other data files and hands it to the browser as a download (works on phones as well)
- Version 3.8.0: the suggestions by domain, hidden suggestions, the new diagnostics (explain, device, DNS chain, bundle) and the AdGuard Home checks of the 3.7 releases together

## v3.7.9

- Suggestions by domain: the line "... of traffic went to n addresses without a known name" can be opened - it lists the 15 busiest of these addresses with their network (ASN) and the device that used them most, with a hint: a device with a lot of traffic there probably asks its own DNS server (TV sticks with 8.8.8.8, "Private DNS" on Android, "secure DNS" in browsers). The text now also says that this counts since the collection started, so traffic from before the suggestions by domain were turned on is included

## v3.7.8

- A domain entry learns at once: a device that looked the name up before the entry existed keeps the answer in its cache, so dnsmasq saw no new lookup and the entry stayed at "nothing learned" (and the routing check warned) until the cache ran out. When the suggestions by domain are on, the addresses already looked up under the domain (last 2 days) now go into its sets when the rules are applied - e.g. right after "Add" in the domain suggestions

## v3.7.7

- DNS check: the Merlin AdGuard Home installer copies the domain lines of dnsmasq into its own `ipset_file`, so AdGuard Home fills the sets of the domain entries itself - also when it asks Unbound directly. In that case there is no warning any more (the status line says "AdGuard Home fills the domain sets itself"); "Check DNS chain" notes that the suggestions by domain then miss names, and that every change of a domain entry restarts AdGuard Home (DNS pauses for up to a minute)

## v3.7.6

- The DNS check no longer reports "dnsmasq is not running" when it happens to look while dnsmasq is being restarted (by "Apply rules", another add-on or the router): a problem is checked once more 8 seconds later and only reported if it is still there

## v3.7.5

- Fixed: the traffic numbers were saved on the USB device only one hour after the counting loop started - an update, a repair or turning the statistics on starts the loop again, so on a day with several updates nothing was saved ("last change: never"). The first save now happens 5 minutes after the start, then every hour as before
- A save with nothing counted at that moment no longer deletes the saved file on the USB device - only "Disable & reset" does

## v3.7.4

- New in Diagnostics: **Explain** a domain or IP - what DNS answers (asked like a device), which domain entry covers the name, and for every address: its network (ASN), every ASN Manager rule that contains it in the order the router checks them, which one wins (for any device or the device chosen below), and the interface the traffic leaves through (with a warning if that is not the target). Command line: `ASNmanager.sh explain <domain|IP> [device IP]`
- New: **Check device** - the rules for all devices, the rules only for this device, its VPN Director rules, its normal way, and its current connections (top 15 by traffic) with name, traffic, winning rule and interface. `ASNmanager.sh device <IP>`
- New: **Check DNS chain** - port 53 -> dnsmasq -> its servers (is something listening?), AdGuard Home upstream check, cache, number of domain lines, and a learning test: one lookup of a domain entry like a device, then the check whether the answer landed in its set. `ASNmanager.sh dnschain`
- New: **Diagnostic bundle** - one text file with version, entries, settings, DNS chain, routing check, ip rules, routing tables, marking rules, set sizes, VPN Director, statistics state and the last ASN Manager messages of the system log. Public IP addresses, VPN servers, MAC addresses, global IPv6 addresses and keys are masked. Download it in the WebUI, "Report on GitHub" opens a new issue with a short template to attach it to. `ASNmanager.sh diag` (writes /tmp/asnmanager-diag.txt)

## v3.7.3

- "Enter ASNs": the help under the field lists every accepted form with an example - ASN (`AS13335` or `13335`), single IP (`1.2.3.4`), range (`181.209.202.0/24`, /8 to /32) and domain (`googlevideo.com` - covers every subdomain, no `*.` needed); several separated by commas or spaces

## v3.7.2

- The DNS check now notices when AdGuard Home sends the lookups straight to another server (e.g. Unbound on 127.0.0.1:53535) instead of to dnsmasq, or shares them between both ("load balancing"). DNS works then, but dnsmasq sees only some lookups: domain entries learn only some addresses and the suggestions by domain stay empty. The status line shows a warning with the fix (upstream in AdGuard Home: 127.0.0.1:<dnsmasq port> - dnsmasq passes the lookups on to its own server); also in `ASNmanager.sh dns` and once in the system log

## v3.7.1

- New: suggestions can be hidden. Every row has a button with a crossed-out eye next to "Add"; a hidden ASN or domain no longer shows up and is not counted. "Show hidden (n)" above the list shows them again (greyed out) with a button to bring a suggestion back. The choice is kept on the router (`/jffs/addons/asnmanager/sg_hidden.txt`), so it is the same in every browser. Command line: `ASNmanager.sh suggest hide|unhide <ASN|domain>...`, `suggest hidden`
- The target and device fields of the suggestions are a little narrower, so the row fits with the new button

## v3.7.0

- New: suggestions **by domain**. A switch above the suggestions changes between "by ASN" and "by domain". The domain view groups the traffic without a rule by the domain the devices looked up (e.g. `zdf.de`, with the names below it such as `nrodl.zdf.de`), with traffic, devices, target, device choice, note and a one-click "Add" (puts the main domain on the list - it covers every subdomain). Domains and ASNs already on the list are hidden
- How it works: when turned on (off by default; in the domain view or `ASNmanager.sh suggest domains on|off`), dnsmasq writes the lookups it answers into a file in RAM; the counting loop reads it once a minute, keeps "address -> name" for 2 days and empties the file. No flash writes, no look-ups on the internet, very little CPU. Other dnsmasq messages (DHCP ...) are passed on to the system log. If another add-on already has dnsmasq write a lookup log (e.g. Diversion), that file is read instead and dnsmasq is left unchanged
- The setting is part of the backup (SG_DOMAINS); uninstalling removes the dnsmasq lines again
- The note "on the list for ..." in the suggestions is a bit narrower, so the table fits better

## v3.6.8

- Fixed: after a VPN client was stopped and started again (e.g. WGC1 switched off and on), its ASNs went out via WAN until "Apply rules" was clicked. Stopping the client removes the route from ASN Manager's table for that target (211 for WGC1 ...) and nothing put it back. The routing check (every 5 minutes, and "Check now") and the failover round now add the route again as soon as the interface is up, and note it in the system log

## v3.6.7

- Fixed: "Show ASN list" in the red routing banner did nothing when the ASN list was already open. It now opens the group of the affected entry, scrolls to it and highlights the row
- The routing banner names the affected entries (e.g. "AS15169 (Google LLC)"), up to three
- A collapsed group shows a red "n routing error(s)" badge in its header, so a failing entry is no longer hidden behind a green "online" group

## v3.6.6

- WebUI header back to the earlier layout: title and description next to the logo, language and theme switches in the same row (the layout of 3.6.3 put them on a line of their own and cut them off on narrow screens); the switches are a bit narrower so the German labels fit as well
- The link back to the router is called "Network Map" / "Netzwerkübersicht" (the page it opens) instead of "Router"

## v3.6.5

- Fixed: since the ASN names were added, long names (e.g. "Deutsche Welle Anstalt des Oeffentlichen Rechts") made the first column of "Traffic per ASN / target" so wide that the numbers were pushed out of view on a phone. The name now sits on a second line under the ASN number and is cut with "..." when it is too long (the full name shows on hover)
- ASN names are cleaned up further: a leading RIPE handle is dropped ("DPAG-AS DHL AG" -> "DHL AG", "AS12638 Telefonica ..." -> "Telefonica ...", "netcup-AS netcup GmbH" -> "netcup GmbH")

## v3.6.4

- DNS / DHCP check: dnsmasq is found on any port, not only 53 and 553 (e.g. Pi-hole in front with dnsmasq on 5353 showed "dnsmasq is not running"). The real port is shown ("dnsmasq OK (port 5353, behind Pi-hole)")
- If another DNS server replaces dnsmasq completely and DHCP still answers (e.g. Pi-hole with its own DHCP), the check shows a yellow notice instead of an error: the devices are fine, only the domain entries learn nothing unless that server fills the ipset sets
- Program names are shown as people know them: AdGuard Home, Pi-hole, Unbound ... With Diversion nothing changes - it works inside dnsmasq ("dnsmasq OK")

## v3.6.3

Review of the whole tool:
- SSH menu [7] "Build & apply routing rules" works like the WebUI now: [1] apply from the saved subnets (fast, also when the list has only IP / domain entries - before it refused with "ASN list is empty"), [2] reload all subnets
- SSH menu [6] -> [3] "Clear ALL" asks you to type DELETE and also removes the notes (before it cleared everything at once without asking)
- `list` (command line) shows the ASN names and the notes; `custom list` shows the notes
- WebUI: the header no longer squeezes title and description into a narrow column; the ASN name sits under the ASN number (it was cut at hyphens), the device name under its IP; the note field in "Edit" has a label
- WebUI: the "Subnets" tile counts the subnets of the ASNs only (it disagreed with the list summary because IP ranges were added); dates follow the language of the page
- WebUI: "Remove all" is shown in red as intended; the suggestions table fits again (narrower dropdowns, no wrapped traffic numbers); the schedule hint no longer runs out of its card; the backup text names IP / domain entries and notes; "Via ASN rules" is now "Via rules" (it includes IP / domain entries)
- Unused code removed; README updated (menu, features, IP / domain entries, AdGuard Home, command line)

## v3.6.2

- Suggestions: every row has a note field; the note is saved with the ASN when you click "Add" (Enter in the field adds too). The target dropdown is narrower so the row still fits

## v3.6.1

- WebUI: the sentence form of "Enter ASNs" is laid out as a tidy grid - the words "Route / via / Note" in one column, the fields aligned next to them, target and devices side by side; each hint sits right under its field. On a phone the words become labels above the fields

## v3.6.0

- WebUI: new layout of "Enter ASNs" - it reads like a sentence: "Route [entries] via [target] for [devices]", with the note and the Add button in one line below. Enter in the entries or note field adds right away. Known devices are picked from the list; typing IP addresses is behind the link "type IP addresses" below the sentence. On narrow screens the parts wrap

## v3.5.3

- ASN list: a note is shown as "Note: ..." so it can not be mistaken for a name

## v3.5.2

- "Add ASNs, IPs or domains" has a field for a note: it is saved with the entries right away (with several entries in one go, under each of them). Command line: `add WGC3 '*.zdf.de' --src 192.168.5.41 --note "ZDF Mediathek"`

## v3.5.1

- Fixed: ASN names that were looked up in the background only showed up after "Reload data". The page data is now written again as soon as new names arrive (up to 12 per routing check). `names` also refreshes the page data and lists every ASN with its name, or says that none was found

## v3.5.0

- **Names of the ASNs**: the list shows who an ASN belongs to ("AS14061 DigitalOcean, LLC", hover for the full RIPE name), the traffic statistics too. The names are looked up once per ASN (RIPEstat, at most 8 per routing check; a new ASN right after adding it; known names from the suggestions and from "Find by domain / IP" are taken over) and kept in `/jffs/addons/asnmanager/asn_names.txt`. Command line: `names` looks up all missing names now
- **Notes per entry**: "Edit" has a field for a short note (up to 60 characters, e.g. "ZDF Mediathek"); it is shown under the entry. ASNs keep their note by number, IP / domain entries by their value, so notes survive a restore; they are part of backups (`[NOTES]`) and go when the entry is removed. Command line: `note <ASN|C1> [text]`
- **DNS / DHCP check**: the overview shows whether dnsmasq runs, who answers DNS on port 53 (e.g. "dnsmasq OK (port 553, behind AdGuardHome)") and whether DHCP answers. Checked every 5 minutes with the routing check and on every refresh; if dnsmasq is down, nothing answers on port 53 or DHCP is silent, a red notice with the fix appears at the top and the change is written to the syslog. Command line: `dns`
- "Remove all" asks you to type DELETE / LÖSCHEN and says how many ASNs, IP ranges and domains would go; the button moved to the right and is less prominent

## v3.4.1

- WebUI: the "ASNs" status tile also shows the other entries below the number of ASNs ("+ 1 IP · 4 Domains")

## v3.4.0

- **Fixed: traffic could leave through the wrong target.** The marks of the targets overlapped: the routing rule of WGC1 (`0x6100/0x6100`) also matched the mark of WGC3 (`0x6300`), WGC2 matched it as well, WAN1 matched WAN2 (`0x8500`), OVPN1/OVPN2 matched OVPN3 and others. Whenever such a pair was in use, traffic meant for one target could go through another. Every target now has one exact value in the mark field `0xff00`; marks are set and the routing rules match with this mask (checked with test packets: the old WGC1 form matched every WGC3 packet, the new one none)
- **Fixed: custom entries now really win over ASNs.** An address in a domain or IP entry and in an ASN of another target got both marks, and the target with the lower routing priority won - WAN1 always. Now a marking rule only marks a packet that has no target yet, so the first matching rule wins; custom entries are above the ASN rules. Example: ZDF on WGC3 for one device while Akamai (AS20940) stays on WAN1 for everyone else
- IP / CIDR entries mark through their own set `ASNC_<id>` (no longer the combined set of their target), so a range wins over an ASN that contains it; removing or changing a range no longer needs a rebuild
- Overlapping ASNs of two targets keep the old precedence (WAN2, WAN1, OVPN1-5, WGC1-5): the rules are built in that order
- The routing rules of the old form are removed by the first rebuild after the update ("Apply rules" rebuilds once, even when nothing else changed); failover rules (including "Block") use the new form as well

## v3.3.1

- Suggestions: "+N more" in the "Used by" column can be clicked - it shows every device with the traffic it caused to this ASN, one per line; "show less" folds the list again. Hovering over the column lists all devices too

## v3.3.0

- New: learned domain addresses expire **7 days after their last lookup**. Every time a device looks the name up again, dnsmasq adds the address anew and the time starts again, so addresses in use stay; servers a service no longer uses drop out. Existing sets are rebuilt with their addresses kept (no gap in the routing)
- New: learned domain addresses **survive a router restart**. They are saved on the USB device (hourly, only when they changed), on the flash every 6 hours and at shutdown (`services-stop`, only while there are domain entries); at boot they are put back with their remaining time before the devices look anything up. Routing is right again from the first second, also for VPN targets. Command line: `custom save`
- `custom learned` shows for each address when it expires

## v3.2.6

- Fewer dnsmasq restarts: a restart is only done when the `ipset=` lines in `dnsmasq.conf.add` change (dnsmasq reads them only at start). When just a domain set is new (new entry with the same lines, or the sets after a reboot), the DNS cache is emptied with SIGHUP instead - dnsmasq keeps running, DNS does not drop out. With the cache off (`cache-size=0`, e.g. when AdGuard Home answers in front of dnsmasq) nothing is done at all. Each restart also sets off the start-up of other DNS add-ons (AdGuard Home moves dnsmasq to port 553), which is now avoided where possible

## v3.2.5

- "Apply rules" is much faster: the rules are rebuilt from the saved subnets and only ASNs that are not cached yet are downloaded. If the ASN list has not changed since the last build and no IP range was removed or changed, only the IP / domain entries are applied (a few seconds, the ASN rules stay as they are). No confirmation needed any more
- New button "Reload all subnets" (command line `apply full` or `reload`): downloads the subnets of every ASN again and rebuilds everything - what "Apply rules" did until now. The daily schedule keeps doing this anyway
- Command line: `apply` works like the button, `apply full` / `reload` like before; the menu entry still downloads everything

## v3.2.4

- WebUI: no empty strip and no extra line between the sections of the ASN list any more; the header bar of each section separates them

## v3.2.3

- WebUI: the three sections of the ASN list stand out more - a header bar with an icon, a larger title and the number of entries as a badge (grey when empty), and a dividing line between the sections

## v3.2.2

- Fixed: the routing test (menu [12], `test <IP|domain>`, WebUI) only looked at the ASN sets, so an address of an IP / CIDR or domain entry was shown as "DEFAULT ROUTE" although it is routed. It now checks the custom entries first and names the entry (e.g. "custom entry C3: 181.209.202.0/24")

## v3.2.1

- WebUI: the ASN list has three sections - **ASNs**, **IP / CIDR ranges** and **Domains** - each with the columns entry, source device, subnets (for domains: learned addresses), state and routing, grouped by target. IP and domain entries no longer get lost between the ASNs; the sections are shown even when empty, with a hint how to add entries
- Domains: the "learned" number is its own column; a click shows the learned addresses. Every section has its own "select all" box; each target group opens and closes per section

## v3.2.0

- `stats diag`: the counting loop was reported as a "hanging" run once it had been running for more than 15 minutes. It is meant to run all the time and is now listed as the counting loop; the clean-up of hanging runs already left it alone

## v3.1.9

- Fixed: dnsmasq adds an address to the domain set only when it fetches the answer from its upstream server, not when it answers from its cache. Names the devices had looked up before the domain entry was made were therefore learned only after their cache entry expired - until then such connections bypassed the rule (for a VPN target: past the VPN). Now dnsmasq is restarted once (about 2 seconds without DNS, the cache is emptied) when a domain set is created: a new domain entry, or the sets after a reboot. Applying the rules again does not restart it
- New: IP / CIDR and domain entries have their own rows in "Traffic per ASN / target" (before, they were counted under "Not assigned to an ASN"). Every entry gets a small set of its own (`ASNC_<id>`) that is used only for counting; the dnsmasq lines are written per domain (`ipset=/domain/<group set>,ASNC_<id>`), so the "learned" number belongs to exactly this domain
- New: click "N learned" in the list to see the learned addresses (the first 200); command line `ASNmanager.sh custom learned [ID]`, and `custom list` shows the numbers. The number on the page refreshes every 30 seconds (from the statistics loop while counting runs)
- The "learned" number is read from the entry's own set (the group set of the target is the fallback), no longer through a helper file in RAM
- IDs of custom entries are never given out twice (the statistics keep their numbers under the ID)

## v3.1.8

- Fixed: a domain entry could show "none learned" (and count as a warning) although the list already said "4 learned": the routing check only runs every 5 minutes. The page now treats such an outdated "none learned" as "being checked" and starts a new check (once a minute at most); if really nothing was learned the warning stays
- The hint for "none learned" names the cases that are not covered (other DNS server, DoH, AdGuard Home answering without dnsmasq)

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
