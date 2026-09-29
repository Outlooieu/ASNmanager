<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<!-- ASNmanager-WebUI v2.0.0 -->
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="X-UA-Compatible" content="IE=Edge"/>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
<meta http-equiv="Pragma" content="no-cache"/>
<meta http-equiv="Expires" content="-1"/>
<link rel="shortcut icon" href="images/favicon.png"/>
<link rel="icon" href="images/favicon.png"/>
<title>ASN Manager</title>
<link rel="stylesheet" type="text/css" href="index_style.css"/>
<link rel="stylesheet" type="text/css" href="form_style.css"/>
<script language="JavaScript" type="text/javascript" src="/state.js"></script>
<script language="JavaScript" type="text/javascript" src="/general.js"></script>
<script language="JavaScript" type="text/javascript" src="/popup.js"></script>
<script language="JavaScript" type="text/javascript" src="/help.js"></script>
<script language="JavaScript" type="text/javascript" src="/validator.js"></script>
<style>
#asnm, #asnm * { box-sizing: border-box; }

/* ---------- themes ---------- */
#asnm, #asnm[data-theme="dark"] {
  --bg: #14181c; --card: #1d2328; --card2: #232a30; --line: #2e373e; --line2: #262e34;
  --text: #e6ecf0; --text2: #c3ccd3; --muted: #8d9ba5; --placeholder: #5f6f7a;
  --input: #11161a; --input-line: #36424b; --input-hover: #465661;
  --btn: #2a333a; --btn-line: #3a4650; --btn-hover: #333e46; --btn-hover-line: #4a5863;
  --group-hover: #29323a; --row-hover: rgba(255,255,255,.02);
  --output: #0e1215; --output-text: #cfd8de;
  --accent: #3b82f6; --accent-hover: #2f74e6; --accent2: #60a5fa; --accent-ring: rgba(59,130,246,.25);
  --ok: #34d399; --warn: #fbbf24; --bad: #f87171;
  --warn-text: #fde68a; --bad-text: #fecaca; --strong: #ffffff; --shadow: none;
}
#asnm[data-theme="light"] {
  --bg: #eef2f6; --card: #ffffff; --card2: #f5f7fa; --line: #dde3ea; --line2: #eaeef3;
  --text: #1c2833; --text2: #3b4a57; --muted: #6b7a88; --placeholder: #9aa7b3;
  --input: #ffffff; --input-line: #cfd7e0; --input-hover: #aebbc8;
  --btn: #ffffff; --btn-line: #cfd7e0; --btn-hover: #f1f4f8; --btn-hover-line: #b7c3cf;
  --group-hover: #edf1f5; --row-hover: rgba(0,0,0,.02);
  --output: #f7f9fb; --output-text: #24323e;
  --accent: #2563eb; --accent-hover: #1d4ed8; --accent2: #2563eb; --accent-ring: rgba(37,99,235,.2);
  --ok: #059669; --warn: #b45309; --bad: #dc2626;
  --warn-text: #92400e; --bad-text: #991b1b; --strong: #111827; --shadow: 0 1px 2px rgba(16,24,40,.06);
}
#asnm[data-theme="blue"] {
  --bg: #0b1626; --card: #102037; --card2: #142a47; --line: #1f3a5c; --line2: #1a3250;
  --text: #e3eefb; --text2: #b9cde4; --muted: #7f9bbb; --placeholder: #56739a;
  --input: #0a1a2e; --input-line: #264a73; --input-hover: #33608f;
  --btn: #16345a; --btn-line: #24507f; --btn-hover: #1b3f6c; --btn-hover-line: #2f6399;
  --group-hover: #183459; --row-hover: rgba(125,180,255,.04);
  --output: #081322; --output-text: #c9dcf2;
  --accent: #0ea5e9; --accent-hover: #0284c7; --accent2: #38bdf8; --accent-ring: rgba(14,165,233,.3);
  --ok: #34d399; --warn: #fbbf24; --bad: #fb7185;
  --warn-text: #fde68a; --bad-text: #fecdd3; --strong: #ffffff; --shadow: none;
}

#asnm { font-family: -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif; font-size: 13px; color: var(--text);
        background: var(--bg); border-radius: 14px; padding: 18px; width: 760px; line-height: 1.45; text-shadow: none;
        transition: background .2s, color .2s; }
#asnm h3 { margin: 0; font-size: 14px; font-weight: 600; color: var(--text); letter-spacing: .01em; }
#asnm a, #asnm .asnm-link { color: var(--accent2); cursor: pointer; text-decoration: none; }
#asnm .asnm-link:hover { text-decoration: underline; }

/* header */
.asnm-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 16px; gap: 12px; }
.asnm-brand { display: flex; align-items: center; gap: 12px; }
.asnm-logo { width: 42px; height: 42px; border-radius: 12px; display: flex; align-items: center; justify-content: center;
             background: linear-gradient(135deg, #3b82f6, #06b6d4); font-weight: 800; font-size: 15px; color: #fff; letter-spacing: .5px;
             box-shadow: 0 6px 18px rgba(59,130,246,.35); }
.asnm-title { font-size: 20px; font-weight: 700; }
.asnm-sub { color: var(--muted); font-size: 12px; }
.asnm-meta { text-align: right; color: var(--muted); font-size: 11px; }
.asnm-meta-top { display: flex; align-items: center; justify-content: flex-end; gap: 8px; margin-bottom: 5px; }
.asnm-chip { display: inline-block; padding: 3px 10px; border-radius: 999px; background: var(--card2); border: 1px solid var(--line);
             color: var(--text); font-weight: 600; font-size: 11px; }

/* theme switch */
.asnm-seg { display: inline-flex; padding: 3px; gap: 2px; border-radius: 999px; background: var(--card2); border: 1px solid var(--line); }
.asnm-seg span { display: inline-flex; align-items: center; gap: 6px; padding: 3px 10px; border-radius: 999px; cursor: pointer;
                 font-size: 11px; font-weight: 600; color: var(--muted); user-select: none; transition: background .15s, color .15s; }
.asnm-seg span:hover { color: var(--text); }
.asnm-seg span.asnm-on { background: var(--accent); color: #fff; }
.asnm-dot { width: 9px; height: 9px; border-radius: 50%; display: inline-block; box-shadow: 0 0 0 1px rgba(128,128,128,.5) inset; }

/* cards */
.asnm-card { background: var(--card); border: 1px solid var(--line); border-radius: 12px; padding: 16px; margin-bottom: 14px; box-shadow: var(--shadow); }
.asnm-card-head { display: flex; align-items: center; gap: 10px; margin-bottom: 14px; }
.asnm-card-titles { flex: 1; }
.asnm-card-sub { color: var(--muted); font-size: 12px; margin-top: 1px; }
.asnm-ico { width: 18px; height: 18px; color: var(--accent2); flex: none; }
.asnm-grid2 { display: grid; grid-template-columns: minmax(0, 1fr) minmax(0, 1fr); gap: 14px; }
.asnm-grid2 > .asnm-card { margin-bottom: 14px; }

/* stats */
.asnm-stats { display: grid; grid-template-columns: repeat(4, 1fr); gap: 10px; margin-bottom: 14px; }
.asnm-stat { background: var(--card2); border: 1px solid var(--line); border-radius: 10px; padding: 10px 12px; }
.asnm-stat-label { color: var(--muted); font-size: 11px; text-transform: uppercase; letter-spacing: .05em; }
.asnm-stat-value { font-size: 20px; font-weight: 700; margin-top: 2px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.asnm-stat-value.asnm-small { font-size: 13px; font-weight: 600; padding-top: 6px; }
.asnm-row { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }
.asnm-spacer { flex: 1; }
.asnm-kv { color: var(--muted); font-size: 12px; margin-bottom: 12px; }
.asnm-kv b { color: var(--text); font-weight: 600; }

/* fields */
.asnm-form { display: grid; grid-template-columns: 1fr 1fr; gap: 12px 14px; }
.asnm-field { display: flex; flex-direction: column; gap: 5px; min-width: 0; }
.asnm-field.asnm-full { grid-column: 1 / -1; }
.asnm-label { font-size: 12px; font-weight: 600; color: var(--text2); }
.asnm-help { font-size: 11px; color: var(--muted); }
.asnm-inline { display: flex; gap: 8px; align-items: center; }
.asnm-inline > * { min-width: 0; }
.asnm-inline > input[type="text"] { flex: 1 1 auto; }
.asnm-inline > .button_gen { flex: none; }
.asnm-inline > .asnm-muted { white-space: nowrap; font-size: 12px; }
#asnm input[type="text"], #asnm select {
    height: 36px !important; padding: 0 11px !important; width: 100%; max-width: none;
    background-color: var(--input) !important; color: var(--text) !important; border: 1px solid var(--input-line) !important; border-radius: 8px !important;
    font-family: inherit !important; font-size: 13px !important; outline: none; box-shadow: none; transition: border-color .15s, box-shadow .15s; margin: 0; }
#asnm input[type="text"]:hover, #asnm select:hover { border-color: var(--input-hover) !important; }
#asnm input[type="text"]:focus, #asnm select:focus { border-color: var(--accent) !important; box-shadow: 0 0 0 3px var(--accent-ring) !important; }
#asnm input[type="text"]::placeholder { color: var(--placeholder); font-style: normal; opacity: 1; }
#asnm select { -webkit-appearance: none; -moz-appearance: none; appearance: none; padding-right: 32px !important; cursor: pointer;
    background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='%238d9ba5' stroke-width='2.5' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='m6 9 6 6 6-6'/%3E%3C/svg%3E") !important;
    background-repeat: no-repeat !important; background-position: right 11px center !important; }
#asnm select option { background: var(--card); color: var(--text); }
#asnm .input_15_table { width: 170px; }
#asnm .asnm-devsel { width: 100%; margin: 0; }
#asnm .asnm-w-sm { width: 80px !important; }
#asnm .asnm-w-md { width: 110px !important; }
#asnm input[type="checkbox"] { accent-color: var(--accent); width: 15px; height: 15px; cursor: pointer; margin: 0; vertical-align: middle; }

/* buttons: restyle the firmware's button_gen */
#asnm .button_gen {
    background: var(--btn) !important; background-image: none !important; border: 1px solid var(--btn-line) !important; color: var(--text) !important;
    border-radius: 8px !important; height: 36px !important; line-height: 34px !important; padding: 0 14px !important; min-width: 0 !important;
    font-family: inherit !important; font-size: 13px !important; font-weight: 600 !important; text-shadow: none !important; cursor: pointer;
    transition: background .15s, border-color .15s, transform .05s; width: auto; margin: 0; white-space: nowrap; }
#asnm .button_gen:hover { background: var(--btn-hover) !important; border-color: var(--btn-hover-line) !important; }
#asnm .button_gen:active { transform: translateY(1px); }
#asnm .button_gen:disabled { opacity: .45; cursor: not-allowed; transform: none; }
#asnm .button_gen.asnm-primary { background: var(--accent) !important; border-color: var(--accent) !important; color: #fff !important; }
#asnm .button_gen.asnm-primary:hover { background: var(--accent-hover) !important; }
#asnm .button_gen.asnm-danger { background: transparent !important; border-color: var(--bad) !important; color: var(--bad) !important; }
#asnm .button_gen.asnm-danger:hover { background: rgba(248,113,113,.1) !important; }
#asnm .button_gen.asnm-ghost { background: transparent !important; }
#asnm .asnm-small-btn { height: 28px !important; line-height: 26px !important; padding: 0 10px !important; font-size: 12px !important; }

/* badges */
.asnm-badge { display: inline-block; padding: 2px 9px; border-radius: 999px; font-size: 11px; font-weight: 600; line-height: 17px; white-space: nowrap; }
.asnm-badge.asnm-ok { background: rgba(52,211,153,.14); color: var(--ok); }
.asnm-badge.asnm-warn { background: rgba(251,191,36,.15); color: var(--warn); }
.asnm-badge.asnm-bad { background: rgba(248,113,113,.15); color: var(--bad); }
.asnm-muted { color: var(--muted); }
.asnm-dev { color: var(--muted); font-size: 11px; }
.asnm-hint { color: var(--muted); font-size: 11px; }

/* tables */
.asnm-table { width: 100%; border-collapse: collapse; }
.asnm-table th { text-align: left; font-size: 11px; font-weight: 600; text-transform: uppercase; letter-spacing: .05em; color: var(--muted);
                 padding: 8px 10px; border-bottom: 1px solid var(--line); background: transparent; }
.asnm-table td { padding: 8px 10px; border-bottom: 1px solid var(--line2); color: var(--text); vertical-align: middle; background: transparent; }
.asnm-table tr:hover td { background: var(--row-hover); }
.asnm-table tr:last-child td { border-bottom: none; }
.asnm-table td.num { text-align: right; font-variant-numeric: tabular-nums; }
.asnm-table td.asnm-actions { white-space: nowrap; text-align: right; }
.asnm-table td.asnm-actions .button_gen + .button_gen { margin-left: 6px; }
.asnm-table tr.asnm-group td { background: var(--card2); color: var(--text); font-weight: 600; cursor: pointer; user-select: none;
                               border-top: 1px solid var(--line); border-bottom: 1px solid var(--line); }
.asnm-table tr.asnm-group:hover td { background: var(--group-hover); }
.asnm-table tr.asnm-failed td { background: rgba(248,113,113,.07); }
.asnm-table tr.asnm-editing td { background: rgba(59,130,246,.08); }
.asnm-arrow { display: inline-block; width: 0; height: 0; margin: 0 10px 1px 2px; vertical-align: middle; transition: transform .15s;
              border-left: 5px solid var(--muted); border-top: 4px solid transparent; border-bottom: 4px solid transparent; }
.asnm-arrow.asnm-open { transform: rotate(90deg); }
.asnm-gsum { float: right; font-weight: 500; color: var(--muted); font-size: 12px; }
.asnm-gsum .asnm-badge { margin-left: 6px; }
.asnm-table-wrap { border: 1px solid var(--line); border-radius: 10px; overflow: hidden; }
#asnm_list { padding: 0; }
.asnm-flag { vertical-align: -2px; border-radius: 2px; margin-right: 5px; width: 20px; height: 14px; box-shadow: 0 0 0 1px rgba(0,0,0,.3); }
.asnm-flag.asnm-flag-round { width: 18px; height: 18px; border-radius: 50%; vertical-align: -4px; margin-right: 6px; box-shadow: 0 0 0 1.5px var(--card), 0 0 0 2.5px var(--line); }
.asnm-cc { display: inline-block; padding: 0 5px; margin-right: 5px; border-radius: 4px; background: var(--card2); border: 1px solid var(--line); font-size: 10px; font-weight: 700; color: var(--text2); }
.asnm-seg-label { font-size: 11px; font-weight: 600; color: var(--muted); text-transform: uppercase; letter-spacing: .05em; }

/* banners */
.asnm-banner { display: none; align-items: center; gap: 10px; padding: 11px 14px; border-radius: 10px; margin-bottom: 14px;
               border: 1px solid rgba(251,191,36,.4); background: rgba(251,191,36,.09); color: var(--warn-text); }
.asnm-banner::before { content: ""; width: 8px; height: 8px; border-radius: 50%; background: var(--warn); flex: none; box-shadow: 0 0 0 4px rgba(251,191,36,.18); }
.asnm-banner.asnm-banner-bad { border-color: rgba(248,113,113,.45); background: rgba(248,113,113,.08); color: var(--bad-text); }
.asnm-banner.asnm-banner-bad::before { background: var(--bad); box-shadow: 0 0 0 4px rgba(248,113,113,.18); }
.asnm-banner b { color: var(--strong); }

/* status + progress */
.asnm-status { display: block; margin-top: 10px; color: var(--muted); font-size: 12px; min-height: 16px; }
.asnm-status-err { color: var(--bad); }
.asnm-progress { display: none; margin-top: 12px; }
.asnm-progress-track { height: 8px; background: var(--input); border-radius: 999px; overflow: hidden; border: 1px solid var(--line); }
.asnm-progress-bar { height: 100%; width: 0; border-radius: 999px; transition: width .6s ease;
    background: linear-gradient(90deg, var(--accent), #06b6d4, var(--accent)); background-size: 200% 100%; animation: asnm-flow 2s linear infinite; }
@keyframes asnm-flow { 0% { background-position: 0 0; } 100% { background-position: -200% 0; } }
.asnm-progress-text { margin-top: 6px; color: var(--text2); font-size: 12px; font-variant-numeric: tabular-nums; }
.asnm-busy .asnm-status::before { content: ""; display: inline-block; width: 10px; height: 10px; margin-right: 7px; vertical-align: -1px;
    border: 2px solid var(--accent-ring); border-top-color: var(--accent2); border-radius: 50%; animation: asnm-spin .8s linear infinite; }
@keyframes asnm-spin { to { transform: rotate(360deg); } }

/* output, import, lookup */
.asnm-output { background: var(--output); color: var(--output-text); font-family: ui-monospace, Consolas, "Lucida Console", monospace; font-size: 12px;
               padding: 12px; min-height: 70px; max-height: 320px; overflow: auto; white-space: pre-wrap; margin: 12px 0 0; border-radius: 8px; border: 1px solid var(--line); }
#asnm_import_panel { display: none; margin-top: 12px; padding: 12px; border: 1px solid var(--line); border-radius: 10px; background: var(--card2); }
#asnm_lookup_result { display: none; margin-top: 12px; }
.asnm-divider { height: 1px; background: var(--line); margin: 14px 0; }
.asnm-footer { text-align: center; color: var(--muted); opacity: .7; font-size: 11px; margin-top: 4px; }
</style>
<script>
var ASNM_NS = 'asnmanager';
var ASNM_FORCE_LANG = '';

/* ============================ i18n ============================ */
var ASNM_I18N = {
  en: {
    subtitle: 'Route whole Autonomous Systems through WAN, OpenVPN or WireGuard.',
    data_refreshed: 'Data refreshed:',
    banner_pending: 'The ASN list has changed since the last apply. Click <b>Apply rules</b> to activate the changes.',
    banner_failed: '{n} ASN(s) could not be loaded (0 subnets). They are marked red below - use <b>Retry failed</b>.',
    dev_lan: 'LAN / Wi-Fi devices', dev_wg: 'WireGuard server peers', dev_ovpn: 'OpenVPN server clients', wg_peer: 'WireGuard peer', ovpn_client: 'OpenVPN client',
    lang_label: 'Language', lang_default: 'Default', lang_en: 'English', theme_label: 'Theme', theme_dark: 'Dark', theme_light: 'Light', theme_blue: 'Blue',
    stat_asns: 'ASNs', stat_subnets: 'Subnets', stat_ifaces: 'Interfaces online', stat_last: 'Last applied',
    card_add_sub: 'Route an Autonomous System through a WAN or VPN interface', card_list_sub: 'Click a group to expand or collapse it',
    status: 'Status', version: 'Version', last_applied: 'Rules last applied', auto_refresh: 'Auto-refresh of subnets', actions: 'Actions',
    btn_apply: 'Apply rules', btn_reload: 'Reload data', btn_retry: 'Retry failed',
    add_asns: 'Add ASNs', asns: 'ASN(s)', target: 'Target interface', src_ip: 'Source device IP', src_empty: 'empty = all devices',
    btn_add: 'Add', presets: 'Service presets', preset: 'Preset', btn_add_preset: 'Add preset',
    lookup_title: 'Find ASN for a domain or IP', domain_ip: 'Domain / IP', btn_lookup: 'Look up', th_ip: 'IP', th_holder: 'Owner',
    btn_take: 'Add to form', btn_take_all: 'Add all to form', in_list: 'in list: {d}', lookup_err: 'lookup failed', lookup_running: 'Looking up...',
    th_pubip: 'External IP', btn_pubip_refresh: 'Refresh IPs', pubip_loading: 'checking...', pubip_none: '-',
    expand_all: 'expand all', collapse_all: 'collapse all', group_sum: '{n} ASN(s), {s} subnets', group_failed: '{f} failed',
    list_title: 'ASN list', btn_remove_sel: 'Remove selected', btn_remove_all: 'Remove all',
    th_asn: 'ASN', th_src: 'Source device', th_subnets: 'Subnets', th_state: 'State', th_target: 'Target', th_device: 'Device', th_asns: 'ASNs',
    ifaces_title: 'Target interfaces', schedule_title: 'Auto-refresh schedule', refresh_every: 'Refresh every', days: 'day(s)', days_range: '(1-30)',
    at_time: 'At time', time_fmt: '(HH:MM, 24h)', btn_save_schedule: 'Save schedule',
    diag_title: 'Diagnostics', btn_test: 'Test route', btn_trace: 'Traceroute', router_checks: 'Router checks',
    btn_ipset: 'ipset status', btn_pubip: 'Public IPs', output_default: 'Output of apply, tests and checks appears here.',
    backup_title: 'Backup & restore', backup_export: 'Export', backup_export_desc: 'Download ASN list and schedule as .conf file',
    btn_export: 'Download backup', backup_import: 'Import', backup_import_desc: 'Compatible with backups from the terminal menu',
    btn_import: 'Choose file...', import_found: '{n} valid entries found in {file}{bad}.', import_bad: ', {n} invalid lines ignored',
    import_sched: ' Schedule: every {i} day(s) at {t}.', btn_replace: 'Replace list', btn_merge: 'Merge into list', btn_cancel: 'Cancel',
    import_none: 'No valid ASN entries found in this file.',
    st_active: 'active', st_down: 'loaded, interface down', st_not_applied: 'not applied', st_failed: 'failed - 0 subnets', st_new: 'new - not applied yet',
    online: 'online', offline: 'offline', not_configured: 'not configured', all_devices: 'all devices', never: 'never',
    every: 'Every {n} day(s) at {t}', cron_on: '(cron active)', cron_off: '(cron not active - apply rules once)',
    btn_edit: 'Edit', btn_remove: 'Remove', btn_save: 'Save',
    pick_device: '- select device -', no_asns: 'No ASNs configured yet.', summary: '{n} ASN(s), {s} subnets loaded',
    hint_multi: 'multiple: comma separated', hint_optional: 'optional',
    ph_asns: 'e.g. AS13335, 15169', ph_ip: 'e.g. 192.168.1.50', ph_domain: 'e.g. netflix.com', ph_diag: 'e.g. one.one.one.one',
    working: 'Working...', applying: 'Applying rules - this can take a few minutes for many ASNs...', retrying: 'Rebuilding from cache, downloading only failed ASNs...',
    progress: 'AS{asn} -> {dest}  ({d} of {t})', running_x: 'Running {a}...',
    timeout: 'No answer from the router (timeout). Check that the service-event hook is installed.',
    no_data: 'No data from router. Is ASN Manager installed?', parse_err: 'Could not read data from router.',
    done: 'Done.', failed: 'Failed.', no_output: '(no output)',
    c_apply: 'Fetch current subnets for all ASNs and rebuild the routing rules now?',
    c_remove_one: 'Remove AS{asn} from the list?', c_remove_n: 'Remove {n} ASNs from the list?',
    c_clear: 'Remove ALL ASNs from the list?\nActive routing stays until you click "Apply rules".',
    c_replace: 'Replace the current list ({n} entries) with {m} entries from the backup?',
    a_asns: 'Please enter one or more ASNs, e.g. AS13335, 15169', a_ip: 'Source IP must be an IPv4 address or empty.',
    a_nothing: 'Nothing selected.', a_interval: 'Interval must be between 1 and 30 days.', a_time: 'Time must be HH:MM (24h).',
    a_host: 'Please enter a valid domain or IPv4 address.', footer: 'ASN Manager for Asuswrt-Merlin'
  },
  de: {
    subtitle: 'Leitet komplette Autonome Systeme über WAN, OpenVPN oder WireGuard.',
    data_refreshed: 'Daten aktualisiert:',
    banner_pending: 'Die ASN-Liste wurde seit dem letzten Anwenden geändert. Klicke auf <b>Regeln anwenden</b>, um die Änderungen zu aktivieren.',
    banner_failed: '{n} ASN(s) konnten nicht geladen werden (0 Subnetze). Sie sind unten rot markiert - nutze <b>Fehlgeschlagene wiederholen</b>.',
    dev_lan: 'LAN- / WLAN-Geräte', dev_wg: 'WireGuard-Server-Peers', dev_ovpn: 'OpenVPN-Server-Clients', wg_peer: 'WireGuard-Peer', ovpn_client: 'OpenVPN-Client',
    lang_label: 'Sprache', lang_default: 'Standard', lang_en: 'English', theme_label: 'Design', theme_dark: 'Dunkel', theme_light: 'Hell', theme_blue: 'Blau',
    stat_asns: 'ASNs', stat_subnets: 'Subnetze', stat_ifaces: 'Interfaces online', stat_last: 'Zuletzt angewendet',
    card_add_sub: 'Ein Autonomes System über ein WAN- oder VPN-Interface leiten', card_list_sub: 'Gruppe anklicken zum Auf- oder Zuklappen',
    status: 'Status', version: 'Version', last_applied: 'Regeln zuletzt angewendet', auto_refresh: 'Automatische Aktualisierung', actions: 'Aktionen',
    btn_apply: 'Regeln anwenden', btn_reload: 'Daten neu laden', btn_retry: 'Fehlgeschlagene wiederholen',
    add_asns: 'ASNs hinzufügen', asns: 'ASN(s)', target: 'Ziel-Interface', src_ip: 'Quell-IP des Geräts', src_empty: 'leer = alle Geräte',
    btn_add: 'Hinzufügen', presets: 'Dienst-Vorlagen', preset: 'Vorlage', btn_add_preset: 'Vorlage hinzufügen',
    lookup_title: 'ASN zu Domain oder IP finden', domain_ip: 'Domain / IP', btn_lookup: 'Suchen', th_ip: 'IP', th_holder: 'Inhaber',
    btn_take: 'Übernehmen', btn_take_all: 'Alle übernehmen', in_list: 'in Liste: {d}', lookup_err: 'Abfrage fehlgeschlagen', lookup_running: 'Suche läuft...',
    th_pubip: 'Externe IP', btn_pubip_refresh: 'IPs aktualisieren', pubip_loading: 'wird ermittelt...', pubip_none: '-',
    expand_all: 'alle aufklappen', collapse_all: 'alle zuklappen', group_sum: '{n} ASN(s), {s} Subnetze', group_failed: '{f} fehlgeschlagen',
    list_title: 'ASN-Liste', btn_remove_sel: 'Auswahl entfernen', btn_remove_all: 'Alle entfernen',
    th_asn: 'ASN', th_src: 'Quellgerät', th_subnets: 'Subnetze', th_state: 'Status', th_target: 'Ziel', th_device: 'Gerät', th_asns: 'ASNs',
    ifaces_title: 'Ziel-Interfaces', schedule_title: 'Zeitplan für Aktualisierung', refresh_every: 'Aktualisieren alle', days: 'Tag(e)', days_range: '(1-30)',
    at_time: 'Um', time_fmt: '(HH:MM, 24h)', btn_save_schedule: 'Zeitplan speichern',
    diag_title: 'Diagnose', btn_test: 'Route testen', btn_trace: 'Traceroute', router_checks: 'Router-Prüfungen',
    btn_ipset: 'ipset-Status', btn_pubip: 'Öffentliche IPs', output_default: 'Hier erscheint die Ausgabe von Anwenden, Tests und Prüfungen.',
    backup_title: 'Sicherung & Wiederherstellung', backup_export: 'Export', backup_export_desc: 'ASN-Liste und Zeitplan als .conf-Datei herunterladen',
    btn_export: 'Sicherung herunterladen', backup_import: 'Import', backup_import_desc: 'Kompatibel mit Sicherungen aus dem Terminal-Menü',
    btn_import: 'Datei wählen...', import_found: '{n} gültige Einträge in {file} gefunden{bad}.', import_bad: ', {n} ungültige Zeilen ignoriert',
    import_sched: ' Zeitplan: alle {i} Tag(e) um {t}.', btn_replace: 'Liste ersetzen', btn_merge: 'Zur Liste hinzufügen', btn_cancel: 'Abbrechen',
    import_none: 'In dieser Datei wurden keine gültigen ASN-Einträge gefunden.',
    st_active: 'aktiv', st_down: 'geladen, Interface offline', st_not_applied: 'nicht angewendet', st_failed: 'fehlgeschlagen - 0 Subnetze', st_new: 'neu - noch nicht angewendet',
    online: 'online', offline: 'offline', not_configured: 'nicht eingerichtet', all_devices: 'alle Geräte', never: 'noch nie',
    every: 'Alle {n} Tag(e) um {t}', cron_on: '(Cron aktiv)', cron_off: '(Cron nicht aktiv - einmal Regeln anwenden)',
    btn_edit: 'Bearbeiten', btn_remove: 'Entfernen', btn_save: 'Speichern',
    pick_device: '- Gerät auswählen -', no_asns: 'Noch keine ASNs eingetragen.', summary: '{n} ASN(s), {s} Subnetze geladen',
    hint_multi: 'mehrere: mit Komma trennen', hint_optional: 'optional',
    ph_asns: 'z. B. AS13335, 15169', ph_ip: 'z. B. 192.168.1.50', ph_domain: 'z. B. netflix.com', ph_diag: 'z. B. one.one.one.one',
    working: 'Wird ausgeführt...', applying: 'Regeln werden angewendet - bei vielen ASNs kann das einige Minuten dauern...', retrying: 'Neuaufbau aus dem Cache, nur fehlgeschlagene ASNs werden geladen...',
    progress: 'AS{asn} -> {dest}  ({d} von {t})', running_x: '{a} läuft...',
    timeout: 'Keine Antwort vom Router (Zeitüberschreitung). Prüfe, ob der service-event-Hook installiert ist.',
    no_data: 'Keine Daten vom Router. Ist ASN Manager installiert?', parse_err: 'Daten vom Router konnten nicht gelesen werden.',
    done: 'Fertig.', failed: 'Fehlgeschlagen.', no_output: '(keine Ausgabe)',
    c_apply: 'Aktuelle Subnetze für alle ASNs laden und die Routing-Regeln jetzt neu aufbauen?',
    c_remove_one: 'AS{asn} aus der Liste entfernen?', c_remove_n: '{n} ASNs aus der Liste entfernen?',
    c_clear: 'ALLE ASNs aus der Liste entfernen?\nDas aktive Routing bleibt bestehen, bis du "Regeln anwenden" klickst.',
    c_replace: 'Die aktuelle Liste ({n} Einträge) durch {m} Einträge aus der Sicherung ersetzen?',
    a_asns: 'Bitte eine oder mehrere ASNs eingeben, z. B. AS13335, 15169', a_ip: 'Die Quell-IP muss eine IPv4-Adresse sein oder leer bleiben.',
    a_nothing: 'Nichts ausgewählt.', a_interval: 'Das Intervall muss zwischen 1 und 30 Tagen liegen.', a_time: 'Die Uhrzeit muss im Format HH:MM (24h) sein.',
    a_host: 'Bitte eine gültige Domain oder IPv4-Adresse eingeben.', footer: 'ASN Manager für Asuswrt-Merlin'
  }
};
var ASNM_LANG = 'en';

// Router messages are English -> translate the known ones
var ASNM_MSG_DE = [
  [/^Saved (\d+) ASN\(s\) -> (\S+)(.*)\. Apply rules to activate\.$/, '$1 ASN(s) gespeichert -> $2$3. Zum Aktivieren "Regeln anwenden" klicken.'],
  [/^Updated AS(\d+) -> (\S+)(.*)\. Apply rules to activate\.$/, 'AS$1 geändert -> $2$3. Zum Aktivieren "Regeln anwenden" klicken.'],
  [/^Removed (\d+) ASN\(s\)\. Apply rules to activate\.$/, '$1 ASN(s) entfernt. Zum Aktivieren "Regeln anwenden" klicken.'],
  [/^All ASNs cleared\..*$/, 'Alle ASNs entfernt. Das aktive Routing bleibt bis "Regeln anwenden" bestehen.'],
  [/^Imported (\d+) ASN\(s\) \((replace|merge)\)(?:, (\d+) invalid entries skipped)?\. Apply rules to activate\.$/, function (m, n, mode, bad) {
      return n + ' ASN(s) importiert (' + (mode === 'replace' ? 'ersetzt' : 'hinzugefügt') + ')' + (bad ? ', ' + bad + ' ungültige übersprungen' : '') + '. Zum Aktivieren "Regeln anwenden" klicken.'; }],
  [/^Rules applied: (\d+) OK, (\d+) failed\.$/, 'Regeln angewendet: $1 OK, $2 fehlgeschlagen.'],
  [/^ASN list is empty - all ASN routing rules removed\.$/, 'ASN-Liste ist leer - alle ASN-Routing-Regeln wurden entfernt.'],
  [/^Auto-refresh set: every (\d+) day\(s\) at (\S+)\.$/, 'Automatische Aktualisierung: alle $1 Tag(e) um $2.'],
  [/^Data refreshed\.$/, 'Daten aktualisiert.'],
  [/^Another ASN Manager job is still running\.$/, 'Es läuft noch ein anderer ASN-Manager-Auftrag.'],
  [/^AS(\d+) is not in the list\.$/, 'AS$1 ist nicht in der Liste.'],
  [/^Invalid source IP '(.*)'$/, "Ungültige Quell-IP '$1'"],
  [/^Invalid target '(.*)'.*$/, "Ungültiges Ziel '$1'"],
  [/^Invalid domain or IP$/, 'Ungültige Domain oder IP'],
  [/^No valid ASN given\.$/, 'Keine gültige ASN angegeben.'],
  [/^Could not resolve (.*)$/, '$1 konnte nicht aufgelöst werden'],
  [/^Lookup failed for (.*)$/, 'Abfrage für $1 fehlgeschlagen'],
  [/^Result: (.*)$/, 'Ergebnis: $1']
];

function t(key, vars) {
    var s = (ASNM_I18N[ASNM_LANG] && ASNM_I18N[ASNM_LANG][key]) || ASNM_I18N.en[key] || key;
    if (vars) for (var k in vars) s = s.split('{' + k + '}').join(vars[k]);
    return s;
}

function asnmTrMsg(msg) {
    if (ASNM_LANG !== 'de' || !msg) return msg;
    for (var i = 0; i < ASNM_MSG_DE.length; i++) if (ASNM_MSG_DE[i][0].test(msg)) return msg.replace(ASNM_MSG_DE[i][0], ASNM_MSG_DE[i][1]);
    return msg;
}

function asnmApplyI18n() {
    // Router language; ?lang=de / ?lang=en in the URL overrides it for testing
    var lang = (document.getElementById('preferred_lang').value || '').toUpperCase() === 'DE' ? 'de' : 'en';
    ASNM_ROUTER_LANG = lang;
    if (asnmLangMode() === 'en') lang = 'en';
    if (ASNM_FORCE_LANG) lang = ASNM_FORCE_LANG;
    var m = /[?&]lang=(de|en)\b/i.exec(window.location.search);
    if (m) lang = m[1].toLowerCase();
    ASNM_LANG = lang;
    var els = document.querySelectorAll('[data-i18n]');
    for (var i = 0; i < els.length; i++) els[i].textContent = t(els[i].getAttribute('data-i18n'));
    els = document.querySelectorAll('[data-i18n-html]');
    for (i = 0; i < els.length; i++) els[i].innerHTML = t(els[i].getAttribute('data-i18n-html'));
    els = document.querySelectorAll('[data-i18n-value]');
    for (i = 0; i < els.length; i++) els[i].value = t(els[i].getAttribute('data-i18n-value'));
    els = document.querySelectorAll('[data-i18n-ph]');
    for (i = 0; i < els.length; i++) els[i].setAttribute('placeholder', t(els[i].getAttribute('data-i18n-ph')));
}

/* ============================ state ============================ */
var ASNM = {
    web: '/ext/' + ASNM_NS + '/',
    data: null, busy: false, jobId: null, jobAction: null, jobStart: 0, jobTimeout: 60000, pollTimer: null,
    queue: [], editing: null, importData: null, collapsed: {}, pubip: null, pubipBusy: false, pubipSince: 0,
    labels: {
        WAN1: 'WAN / WAN1', WAN2: 'WAN2 (Dual-WAN)',
        OVPN1: 'OpenVPN Client 1', OVPN2: 'OpenVPN Client 2', OVPN3: 'OpenVPN Client 3', OVPN4: 'OpenVPN Client 4', OVPN5: 'OpenVPN Client 5',
        WGC1: 'WireGuard Client 1', WGC2: 'WireGuard Client 2', WGC3: 'WireGuard Client 3', WGC4: 'WireGuard Client 4', WGC5: 'WireGuard Client 5'
    },
    order: ['WAN', 'WAN1', 'WAN2', 'OVPN1', 'OVPN2', 'OVPN3', 'OVPN4', 'OVPN5', 'WGC1', 'WGC2', 'WGC3', 'WGC4', 'WGC5'],
    timeouts: { apply: 1800000, retry: 1800000, trace: 90000, ifaces: 90000, lookup: 30000 },
    reIp: /^((25[0-5]|2[0-4]\d|1?\d?\d)\.){3}(25[0-5]|2[0-4]\d|1?\d?\d)$/,
    reHost: /^[A-Za-z0-9][A-Za-z0-9.-]{0,252}$/,
    reEntry: /^(\d{1,10}):(WAN|WAN1|WAN2|OVPN[1-5]|WGC[1-5]):?((?:\d{1,3}\.){3}\d{1,3})?$/,
    chunkChars: 1800
};

function asnmEsc(s) {
    return String(s == null ? '' : s).replace(/[&<>"']/g, function (c) {
        return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c];
    });
}

function asnmGet(file, ok, fail) {
    var xhr = new XMLHttpRequest();
    xhr.open('GET', ASNM.web + file + '?_=' + Date.now(), true);
    xhr.onreadystatechange = function () {
        if (xhr.readyState !== 4) return;
        if (xhr.status === 200) ok(xhr.responseText); else if (fail) fail(xhr.status);
    };
    xhr.send(null);
}

function asnmFmtTime(ts) {
    if (!ts) return t('never');
    var d = new Date(ts * 1000);
    return d.toLocaleDateString() + ' ' + d.toLocaleTimeString();
}

function asnmNormDest(id) { return id === 'WAN' ? 'WAN1' : id; }
function asnmDestLabel(id) { id = asnmNormDest(id); return (ASNM.labels[id] || id) + ' (' + id + ')'; }

function asnmIface(id) {
    if (!ASNM.data) return null;
    id = asnmNormDest(id);
    for (var i = 0; i < ASNM.data.ifaces.length; i++) if (ASNM.data.ifaces[i].id === id) return ASNM.data.ifaces[i];
    return null;
}

function asnmDeviceName(ip) {
    if (!ASNM.data || !ASNM.data.devices || !ip) return '';
    for (var i = 0; i < ASNM.data.devices.length; i++) if (ASNM.data.devices[i].ip === ip) return asnmDevLabel(ASNM.data.devices[i]);
    return '';
}

/* ============================ data / rendering ============================ */
function asnmLoadData(first) {
    asnmGet('data.js', function (txt) {
        try { ASNM.data = JSON.parse(txt); } catch (e) { asnmSetStatus(t('parse_err'), true); return; }
        if (!ASNM.data.devices) ASNM.data.devices = [];
        ASNM.data.devices.sort(function (a, b) {
            var x = a.ip.split('.'), y = b.ip.split('.');
            for (var i = 0; i < 4; i++) if (+x[i] !== +y[i]) return +x[i] - +y[i];
            return 0;
        });
        asnmRender();
    }, function () {
        if (first) asnmSend('refresh', []);
        else asnmSetStatus(t('no_data'), true);
    });
}

function asnmRender() {
    var d = ASNM.data;
    document.getElementById('asnm_version').textContent = 'v' + d.version;
    document.getElementById('asnm_last_apply').textContent = asnmFmtTime(d.last_apply);
    document.getElementById('asnm_generated').textContent = asnmFmtTime(d.generated);
    document.getElementById('asnm_banner').style.display = d.pending ? 'flex' : 'none';
    var subs = 0, up = 0, used = 0;
    for (var si = 0; si < d.entries.length; si++) if (d.entries[si].subnets > 0) subs += d.entries[si].subnets;
    for (var sj = 0; sj < d.ifaces.length; sj++) if (d.ifaces[sj].up) up++;
    for (var sk = 0; sk < d.ifaces.length; sk++) if (d.ifaces[sk].exists) used++;
    document.getElementById('asnm_stat_asns').textContent = d.entries.length;
    document.getElementById('asnm_stat_subnets').textContent = subs.toLocaleString();
    document.getElementById('asnm_stat_ifaces').textContent = up + ' / ' + used;

    var failed = asnmFailed();
    var fb = document.getElementById('asnm_banner_failed');
    fb.style.display = failed.length ? 'flex' : 'none';
    fb.innerHTML = '<span>' + t('banner_failed', { n: failed.length }) + '</span>';
    var rb = document.getElementById('asnm_btn_retry');
    rb.style.display = failed.length ? '' : 'none';
    rb.value = t('btn_retry') + ' (' + failed.length + ')';

    document.getElementById('asnm_schedule_info').innerHTML = asnmEsc(t('every', { n: d.schedule.interval, t: d.schedule.time })) + ' ' +
        (d.cron ? '<span class="asnm-badge asnm-ok">' + asnmEsc(t('cron_on')) + '</span>' : '<span class="asnm-badge asnm-warn">' + asnmEsc(t('cron_off')) + '</span>');
    document.getElementById('asnm_sched_int').value = d.schedule.interval;
    document.getElementById('asnm_sched_time').value = d.schedule.time;

    asnmFillTargets(document.getElementById('asnm_add_dest'));
    asnmFillTargets(document.getElementById('asnm_preset_dest'));
    asnmFillDevices(document.getElementById('asnm_add_dev'));
    asnmFillDevices(document.getElementById('asnm_preset_dev'));
    asnmRenderPresets();
    asnmRenderList();
    asnmRenderIfaces();
}

function asnmFailed() {
    var l = [];
    if (!ASNM.data) return l;
    for (var i = 0; i < ASNM.data.entries.length; i++) if (ASNM.data.entries[i].failed) l.push(ASNM.data.entries[i].asn);
    return l;
}

function asnmTargetOptions(selected) {
    var html = '';
    for (var i = 0; i < ASNM.data.ifaces.length; i++) {
        var f = ASNM.data.ifaces[i];
        var st = f.up ? t('online') : (f.exists ? t('offline') : t('not_configured'));
        html += '<option value="' + f.id + '"' + (f.id === selected ? ' selected="selected"' : '') + '>' + asnmEsc(asnmDestLabel(f.id)) + ' - ' + asnmEsc(st) + '</option>';
    }
    return html;
}

function asnmFillTargets(sel) {
    var keep = sel.value;
    sel.innerHTML = asnmTargetOptions(keep);
    if (keep) sel.value = keep;
}

function asnmDeviceOptions(selectedIp) {
    var html = '<option value="">' + asnmEsc(t('pick_device')) + '</option>';
    var groups = [['lan', t('dev_lan')], ['wg', t('dev_wg')], ['ovpn', t('dev_ovpn')]];
    for (var g = 0; g < groups.length; g++) {
        var part = '';
        for (var i = 0; i < ASNM.data.devices.length; i++) {
            var dv = ASNM.data.devices[i];
            if ((dv.kind || 'lan') !== groups[g][0]) continue;
            var nm = asnmDevLabel(dv);
            part += '<option value="' + asnmEsc(dv.ip) + '"' + (dv.ip === selectedIp ? ' selected="selected"' : '') + '>' +
                    asnmEsc((nm ? nm + ' - ' : '') + dv.ip) + '</option>';
        }
        if (part) html += '<optgroup label="' + asnmEsc(groups[g][1]) + '">' + part + '</optgroup>';
    }
    return html;
}

function asnmDevLabel(dv) {
    return dv.name || (dv.kind === 'wg' ? t('wg_peer') : (dv.kind === 'ovpn' ? t('ovpn_client') : ''));
}

function asnmFillDevices(sel) { sel.innerHTML = asnmDeviceOptions(''); }

function asnmPickDevice(sel, inputId) {
    if (sel.value) document.getElementById(inputId).value = sel.value;
    sel.selectedIndex = 0;
}

function asnmRenderPresets() {
    var sel = document.getElementById('asnm_preset'), keep = sel.value, html = '';
    for (var i = 0; i < ASNM.data.presets.length; i++) {
        var p = ASNM.data.presets[i];
        html += '<option value="' + (i + 1) + '">' + asnmEsc(p.name) + ' (AS' + asnmEsc(p.asns.split(' ').join(', AS')) + ')</option>';
    }
    sel.innerHTML = html;
    if (keep) sel.value = keep;
}

function asnmSrcCell(ip) {
    if (!ip) return '<span class="asnm-muted">' + asnmEsc(t('all_devices')) + '</span>';
    var n = asnmDeviceName(ip);
    return asnmEsc(ip) + (n ? ' <span class="asnm-dev">' + asnmEsc(n) + '</span>' : '');
}

function asnmRenderList() {
    var entries = ASNM.data.entries.slice(0);
    entries.sort(function (a, b) {
        var o = ASNM.order.indexOf(a.dest) - ASNM.order.indexOf(b.dest);
        return o !== 0 ? o : (parseInt(a.asn, 10) - parseInt(b.asn, 10));
    });

    var html = '<table class="asnm-table"><tr><th style="width:24px;"><input type="checkbox" onclick="asnmToggleAll(this.checked)"/></th>' +
               '<th>' + t('th_asn') + '</th><th>' + t('th_src') + '</th><th style="text-align:right;">' + t('th_subnets') + '</th>' +
               '<th>' + t('th_state') + '</th><th></th></tr>';
    if (!entries.length) html += '<tr><td colspan="6" class="asnm-muted" style="text-align:center;padding:12px;">' + asnmEsc(t('no_asns')) + '</td></tr>';

    // per-target totals for the group headers
    var groups = {};
    for (var g = 0; g < entries.length; g++) {
        var ge = entries[g], gs = groups[ge.dest] || (groups[ge.dest] = { n: 0, s: 0, f: 0 });
        gs.n++; if (ge.subnets > 0) gs.s += ge.subnets; if (ge.failed) gs.f++;
    }

    var lastDest = null, total = 0;
    for (var i = 0; i < entries.length; i++) {
        var e = entries[i], a = asnmEsc(e.asn);
        if (e.subnets > 0) total += e.subnets;
        var closed = asnmIsClosed(e.dest, groups[e.dest]);
        if (e.dest !== lastDest) {
            var f = asnmIface(e.dest), gi = groups[e.dest];
            var st = f ? (f.up ? '<span class="asnm-badge asnm-ok">' + t('online') + '</span>' : '<span class="asnm-badge asnm-bad">' + t('offline') + '</span>') : '';
            html += '<tr class="asnm-group" onclick="asnmToggleGroup(\'' + asnmEsc(e.dest) + '\')"><td colspan="6">' +
                    '<span class="asnm-arrow' + (closed ? '' : ' asnm-open') + '"></span>' +
                    asnmEsc(asnmDestLabel(e.dest)) + (f && f.dev ? ' - ' + asnmEsc(f.dev) : '') + ' &nbsp; ' + st +
                    '<span class="asnm-gsum">' + asnmEsc(t('group_sum', { n: gi.n, s: gi.s })) +
                    (gi.f ? '<span class="asnm-badge asnm-bad">' + asnmEsc(t('group_failed', { f: gi.f })) + '</span>' : '') + '</span></td></tr>';
            lastDest = e.dest;
        }
        if (closed) continue;

        if (ASNM.editing === e.asn) {
            html += '<tr class="asnm-editing"><td></td><td>AS' + a + '</td>' +
                '<td colspan="3"><select id="asnm_edit_dest" class="input_option">' + asnmTargetOptions(asnmNormDest(e.dest)) + '</select><br/>' +
                '<input type="text" id="asnm_edit_src" class="input_15_table" maxlength="15" style="margin-top:6px;width:150px;" value="' + asnmEsc(e.src) + '" placeholder="' + asnmEsc(t('src_empty')) + '"/>' +
                '<select class="input_option asnm-devsel" style="width:210px;margin:6px 0 0 6px;" onchange="asnmPickDevice(this,\'asnm_edit_src\')">' + asnmDeviceOptions('') + '</select></td>' +
                '<td><input type="button" class="button_gen asnm-small-btn asnm-btn asnm-primary" value="' + asnmEsc(t('btn_save')) + '" onclick="asnmEditSave(\'' + a + '\')"/> ' +
                '<input type="button" class="button_gen asnm-small-btn" value="' + asnmEsc(t('btn_cancel')) + '" onclick="asnmEdit(null)"/></td></tr>';
            continue;
        }

        var iface = asnmIface(e.dest), state, rowCls = '';
        if (e.failed) { state = '<span class="asnm-badge asnm-bad">' + t('st_failed') + '</span>'; rowCls = ' class="asnm-failed"'; }
        else if (e['new'] && !e.loaded) state = '<span class="asnm-badge asnm-warn">' + t('st_new') + '</span>';
        else if (e.loaded && iface && iface.up) state = '<span class="asnm-badge asnm-ok">' + t('st_active') + '</span>';
        else if (e.loaded) state = '<span class="asnm-badge asnm-warn">' + t('st_down') + '</span>';
        else state = '<span class="asnm-muted">' + t('st_not_applied') + '</span>';

        html += '<tr' + rowCls + '><td><input type="checkbox" class="asnm-chk" value="' + a + '"/></td>' +
                '<td>AS' + a + '</td><td>' + asnmSrcCell(e.src) + '</td>' +
                '<td class="num">' + (e.subnets >= 0 ? e.subnets : '<span class="asnm-muted">-</span>') + '</td>' +
                '<td>' + state + '</td>' +
                '<td class="asnm-actions"><input type="button" class="button_gen asnm-small-btn asnm-btn" value="' + asnmEsc(t('btn_edit')) + '" onclick="asnmEdit(\'' + a + '\')"/> ' +
                '<input type="button" class="button_gen asnm-small-btn asnm-btn" value="' + asnmEsc(t('btn_remove')) + '" onclick="asnmRemove([\'' + a + '\'])"/></td></tr>';
    }
    html += '</table>';
    document.getElementById('asnm_list').innerHTML = html;
    document.getElementById('asnm_list_summary').textContent = t('summary', { n: entries.length, s: total });
    asnmApplyBusy();
}

function asnmRenderIfaces() {
    var html = '<table class="asnm-table"><tr><th>' + t('th_target') + '</th><th>' + t('th_device') + '</th><th>' + t('th_state') + '</th>' +
               '<th>' + t('th_pubip') + '</th><th style="text-align:right;">' + t('th_asns') + '</th></tr>';
    var ips = (ASNM.pubip && ASNM.pubip.ips) || {};
    for (var i = 0; i < ASNM.data.ifaces.length; i++) {
        var f = ASNM.data.ifaces[i], n = 0;
        for (var j = 0; j < ASNM.data.entries.length; j++) if (asnmNormDest(ASNM.data.entries[j].dest) === f.id) n++;
        if (!f.exists && !n) continue;
        var st = f.up ? '<span class="asnm-badge asnm-ok">' + t('online') + '</span>' : (f.exists ? '<span class="asnm-badge asnm-bad">' + t('offline') + '</span>' : '<span class="asnm-muted">' + t('not_configured') + '</span>');
        var p = ips[f.id], pub;
        if (p) pub = asnmEsc(p.ip) + (p.cc ? '<br/>' + asnmFlag(p.cc, p.flag, p.svg) + ' <span class="asnm-dev">' + asnmEsc(asnmCountryName(p.cc, p.country)) + '</span>' : '');
        else if (f.up && ASNM.pubipBusy) pub = '<span class="asnm-muted">' + asnmEsc(t('pubip_loading')) + '</span>';
        else pub = '<span class="asnm-muted">' + t('pubip_none') + '</span>';
        html += '<tr><td>' + asnmEsc(asnmDestLabel(f.id)) + '</td><td>' + asnmEsc(f.dev || '-') + '</td><td>' + st + '</td><td>' + pub + '</td><td class="num">' + n + '</td></tr>';
    }
    document.getElementById('asnm_ifaces').innerHTML = html + '</table>';
}

function asnmCountryName(cc, fallback) {
    try {
        if (window.Intl && Intl.DisplayNames) {
            var n = new Intl.DisplayNames([ASNM_LANG], { type: 'region' }).of(cc);
            if (n && n !== cc) return n;
        }
    } catch (e) {}
    return fallback || cc;
}

// Flag image served by the router (/ext/asnmanager/flags/xx.png); country code as fallback
function asnmFlag(cc, hasFlag, svg) {
    if (!/^[A-Z]{2}$/.test(cc)) return '';
    if (svg && /^<svg[\s>]/.test(svg)) {
        return '<img class="asnm-flag asnm-flag-round" src="data:image/svg+xml;charset=utf-8,' + encodeURIComponent(svg) +
               '" alt="' + cc + '" title="' + cc + '"/>';
    }
    if (!hasFlag) return '<span class="asnm-cc">' + cc + '</span>';
    return '<img class="asnm-flag" src="' + ASNM.web + 'flags/' + cc.toLowerCase() + '.png" width="20" height="14" alt="' + cc + '" title="' + cc +
           '" onerror="this.outerHTML=\'<span class=asnm-cc>' + cc + '</span>\'"/>';
}

function asnmLoadPubip(autoRefresh) {
    asnmGet('pubip.js', function (txt) {
        try { ASNM.pubip = JSON.parse(txt); } catch (e) { ASNM.pubip = null; }
        if (ASNM.data) asnmRenderIfaces();
        var age = ASNM.pubip ? Date.now() / 1000 - ASNM.pubip.ts : 1e9;
        if (autoRefresh && age > 900) asnmRefreshPubip();
    }, function () { if (autoRefresh) asnmRefreshPubip(); });
}

function asnmRefreshPubip() {
    if (ASNM.pubipBusy) return;
    ASNM.pubipBusy = true;
    ASNM.pubipSince = Math.floor(Date.now() / 1000) - 5;
    document.getElementById('asnm_pubip_btn').disabled = true;
    var f = document.formAsnmPubip, page = document.formAsnm.elements['current_page'].value;
    f.elements['action_script'].value = 'start_' + ASNM_NS + 'pubip';
    f.elements['current_page'].value = page;
    f.elements['next_page'].value = page;
    asnmPost(f);
    if (ASNM.data) asnmRenderIfaces();
    var started = Date.now();
    function again() { if (Date.now() - started > 45000) asnmPubipDone(); else setTimeout(poll, 2000); }
    function poll() {
        asnmGet('pubip.js', function (txt) {
            var d = null;
            try { d = JSON.parse(txt); } catch (e) {}
            if (d && d.ts >= ASNM.pubipSince) { ASNM.pubip = d; asnmPubipDone(); return; }
            again();
        }, again);
    }
    setTimeout(poll, 2000);
}

function asnmPubipDone() {
    ASNM.pubipBusy = false;
    document.getElementById('asnm_pubip_btn').disabled = false;
    if (ASNM.data) asnmRenderIfaces();
}

function asnmIsClosed(dest, gi) {
    if (ASNM.collapsed.hasOwnProperty(dest)) return !!ASNM.collapsed[dest];
    return !(gi && gi.f > 0);
}

function asnmToggleGroup(dest) {
    var gi = { f: 0 };
    if (ASNM.data) for (var i = 0; i < ASNM.data.entries.length; i++)
        if (ASNM.data.entries[i].dest === dest && ASNM.data.entries[i].failed) gi.f++;
    ASNM.collapsed[dest] = !asnmIsClosed(dest, gi);
    asnmSaveCollapsed();
    asnmRenderList();
}

function asnmCollapseAll(on) {
    if (!ASNM.data) return;
    for (var i = 0; i < ASNM.data.entries.length; i++) ASNM.collapsed[ASNM.data.entries[i].dest] = on;
    asnmSaveCollapsed();
    asnmRenderList();
}

function asnmSaveCollapsed() { try { localStorage.setItem('asnm_collapsed_' + ASNM_NS, JSON.stringify(ASNM.collapsed)); } catch (e) {} }
function asnmLoadCollapsed() { try { ASNM.collapsed = JSON.parse(localStorage.getItem('asnm_collapsed_' + ASNM_NS) || '{}') || {}; } catch (e) { ASNM.collapsed = {}; } }

function asnmToggleAll(on) {
    var c = document.getElementsByClassName('asnm-chk');
    for (var i = 0; i < c.length; i++) c[i].checked = on;
}

/* ============================ commands / jobs ============================ */
// POST a form to /start_apply.htm in the background. The response page (which would show the
// firmware's loading overlay and reload the page) is ignored on purpose.
function asnmPost(form, done) {
    var parts = [];
    for (var i = 0; i < form.elements.length; i++) {
        var el = form.elements[i];
        if (el.name) parts.push(encodeURIComponent(el.name) + '=' + encodeURIComponent(el.value));
    }
    var xhr = new XMLHttpRequest();
    xhr.open('POST', '/start_apply.htm', true);
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    xhr.onreadystatechange = function () { if (xhr.readyState === 4 && done) done(xhr.status); };
    xhr.send(parts.join('&'));
}

function asnmClean(v) { return String(v == null ? '' : v).replace(/[|\s]+/g, ''); }

function asnmSend(action, args) {
    if (ASNM.busy) return false;
    var id = String(Date.now());
    var parts = [id, action];
    for (var i = 0; i < args.length; i++) parts.push(asnmClean(args[i]));
    var f = document.formAsnm;
    var cmd = {}; cmd[ASNM_NS + '_cmd'] = parts.join('|');
    f.elements['amng_custom'].value = JSON.stringify(cmd);
    f.elements['action_script'].value = 'start_' + ASNM_NS + 'cmd';
    asnmPost(f);

    ASNM.jobId = id; ASNM.jobAction = action; ASNM.jobStart = Date.now();
    ASNM.jobTimeout = ASNM.timeouts[action] || 60000;
    asnmSetBusy(true, action);
    clearTimeout(ASNM.pollTimer);
    ASNM.pollTimer = setTimeout(asnmPoll, 1500);
    return true;
}

// Several jobs in a row (import in chunks), stops at the first error
function asnmSendQueue(jobs) {
    if (ASNM.busy || !jobs.length) return;
    ASNM.queue = jobs.slice(1);
    asnmSend(jobs[0][0], jobs[0][1]);
}

function asnmPoll() {
    asnmGet('job.js', function (txt) {
        var job = null;
        try { job = JSON.parse(txt); } catch (e) {}
        if (job && job.id === ASNM.jobId) {
            if (job.state !== 'running') { asnmJobDone(job); return; }
            if (job.total > 0) asnmShowProgress(job);
        }
        asnmPollAgain();
    }, asnmPollAgain);
}

function asnmPollAgain() {
    if (Date.now() - ASNM.jobStart > ASNM.jobTimeout) {
        ASNM.queue = [];
        asnmSetBusy(false);
        asnmSetStatus(t('timeout'), true);
        return;
    }
    ASNM.pollTimer = setTimeout(asnmPoll, 1500);
}

function asnmShowProgress(job) {
    var box = document.getElementById('asnm_progress');
    box.style.display = 'block';
    box.className = 'asnm-progress';
    var pct = Math.min(100, Math.round((job.done - 0.5) / job.total * 100));
    document.getElementById('asnm_progress_bar').style.width = Math.max(pct, 3) + '%';
    var m = /^AS(\d+) -> (\S+)/.exec(job.msg || '');
    var secs = Math.round((Date.now() - ASNM.jobStart) / 1000);
    document.getElementById('asnm_progress_text').textContent =
        (m ? t('progress', { asn: m[1], dest: m[2], d: job.done, t: job.total }) : job.done + ' / ' + job.total) + '   ' + secs + 's';
}

function asnmHideProgress() {
    document.getElementById('asnm_progress').style.display = 'none';
    document.getElementById('asnm_progress_bar').style.width = '0';
}

function asnmJobDone(job) {
    var ok = job.state === 'done';
    asnmSetBusy(false);
    asnmHideProgress();
    asnmSetStatus(asnmTrMsg(job.msg) || (ok ? t('done') : t('failed')), !ok);

    if (['apply', 'retry', 'test', 'trace', 'lookup', 'ifaces', 'status'].indexOf(job.action) >= 0) {
        asnmGet('output.htm', function (txt) { document.getElementById('asnm_output').textContent = txt || t('no_output'); });
    }
    if (job.action === 'lookup') {
        asnmGet('output.htm', function (txt) { asnmRenderLookup(txt, ok, job.msg); },
                function () { asnmRenderLookup('', false, job.msg); });
    }
    if (job.action === 'edit' && ok) ASNM.editing = null;

    if (ok && ASNM.queue.length) {
        var next = ASNM.queue.shift();
        asnmSend(next[0], next[1]);
        return;
    }
    ASNM.queue = [];
    asnmLoadData(false);
}

function asnmSetBusy(on, action) {
    ASNM.busy = on;
    asnmApplyBusy();
    if (on) asnmSetStatus(action === 'apply' ? t('applying') : (action === 'retry' ? t('retrying') : t('working')));
}

function asnmApplyBusy() {
    var b = document.getElementsByClassName('asnm-btn');
    for (var i = 0; i < b.length; i++) b[i].disabled = ASNM.busy;
    document.getElementById('asnm').className = ASNM.busy ? 'asnm-busy' : '';
}

function asnmSetStatus(msg, isErr) {
    var el = document.getElementById('asnm_status');
    el.textContent = msg || '';
    el.className = 'asnm-status' + (isErr ? ' asnm-status-err' : '');
}

/* ============================ UI actions ============================ */
function asnmValidIp(v) { return !v || ASNM.reIp.test(v); }

function asnmAdd() {
    var asns = document.getElementById('asnm_add_asns').value.replace(/[;\s]+/g, ',').replace(/,+/g, ',').replace(/^,|,$/g, '');
    var src = document.getElementById('asnm_add_src').value.trim();
    if (!asns || !/^((AS|as)?\d{1,10})(,(AS|as)?\d{1,10})*$/.test(asns)) { alert(t('a_asns')); return; }
    if (!asnmValidIp(src)) { alert(t('a_ip')); return; }
    if (asnmSend('add', [document.getElementById('asnm_add_dest').value, src, asns])) document.getElementById('asnm_add_asns').value = '';
}

function asnmAddPreset() {
    var src = document.getElementById('asnm_preset_src').value.trim();
    if (!asnmValidIp(src)) { alert(t('a_ip')); return; }
    asnmSend('preset', [document.getElementById('asnm_preset').value, document.getElementById('asnm_preset_dest').value, src]);
}

function asnmEdit(asn) {
    if (ASNM.busy) return;
    ASNM.editing = asn;
    if (asn && ASNM.data) for (var i = 0; i < ASNM.data.entries.length; i++)
        if (ASNM.data.entries[i].asn === asn) ASNM.collapsed[ASNM.data.entries[i].dest] = false;
    asnmRenderList();
}

function asnmEditSave(asn) {
    var dest = document.getElementById('asnm_edit_dest').value;
    var src = document.getElementById('asnm_edit_src').value.trim();
    if (!asnmValidIp(src)) { alert(t('a_ip')); return; }
    asnmSend('edit', [asn, dest, src]);
}

function asnmRemove(list) {
    if (!list.length) { alert(t('a_nothing')); return; }
    if (!confirm(list.length === 1 ? t('c_remove_one', { asn: list[0] }) : t('c_remove_n', { n: list.length }))) return;
    asnmSend('remove', [list.join(',')]);
}

function asnmRemoveSelected() {
    var c = document.getElementsByClassName('asnm-chk'), l = [];
    for (var i = 0; i < c.length; i++) if (c[i].checked) l.push(c[i].value);
    asnmRemove(l);
}

function asnmClearAll() { if (confirm(t('c_clear'))) asnmSend('clear', []); }
function asnmApply() { if (confirm(t('c_apply'))) asnmSend('apply', []); }
function asnmRetry() { asnmSend('retry', []); }

function asnmSaveSchedule() {
    var n = parseInt(document.getElementById('asnm_sched_int').value, 10);
    var tm = document.getElementById('asnm_sched_time').value.trim();
    if (!(n >= 1 && n <= 30)) { alert(t('a_interval')); return; }
    if (!/^([01]?\d|2[0-3]):[0-5]\d$/.test(tm)) { alert(t('a_time')); return; }
    asnmSend('schedule', [String(n), tm]);
}

function asnmTool(action, fieldId) {
    var v = fieldId ? document.getElementById(fieldId).value.trim().replace(/^https?:\/\//, '').split('/')[0] : '';
    if (fieldId && !ASNM.reHost.test(v)) { alert(t('a_host')); return; }
    document.getElementById('asnm_output').textContent = t('running_x', { a: action });
    asnmSend(action, fieldId ? [v] : []);
}

function asnmLookup() {
    var v = document.getElementById('asnm_lookup').value.trim().replace(/^https?:\/\//, '').split('/')[0].split(':')[0];
    if (!ASNM.reHost.test(v)) { alert(t('a_host')); return; }
    if (!asnmSend('lookup', [v])) return;
    var box = document.getElementById('asnm_lookup_result');
    box.style.display = 'block';
    box.innerHTML = '<span class="asnm-badge asnm-warn">' + asnmEsc(t('lookup_running')) + '</span>';
}

function asnmRenderLookup(txt, ok, msg) {
    var box = document.getElementById('asnm_lookup_result');
    box.style.display = 'block';
    var rows = [], lines = String(txt || '').split('\n');
    for (var i = 0; i < lines.length; i++) {
        var m = /^(\S+) -> AS(\d+) ?(.*?)(?: \[in list: (\S+)\])?$/.exec(lines[i]);
        if (m) rows.push({ ip: m[1], asn: m[2], holder: m[3], inList: m[4] || '' });
        else if (/^\S+ -> lookup failed$/.test(lines[i])) rows.push({ ip: lines[i].split(' ')[0], asn: '', holder: '', inList: '' });
    }
    if (!ok || !rows.length) {
        box.innerHTML = '<span class="asnm-badge asnm-bad">' + asnmEsc(asnmTrMsg(msg) || t('failed')) + '</span>';
        return;
    }
    var html = '<div class="asnm-table-wrap"><table class="asnm-table"><tr><th>' + t('th_ip') + '</th><th>' + t('th_asn') + '</th><th>' + t('th_holder') + '</th><th></th></tr>';
    var addable = [], seen = {};
    for (var r = 0; r < rows.length; r++) {
        var x = rows[r], act;
        if (!x.asn) act = '<span class="asnm-badge asnm-bad">' + asnmEsc(t('lookup_err')) + '</span>';
        else if (x.inList) act = '<span class="asnm-badge asnm-ok">' + asnmEsc(t('in_list', { d: x.inList })) + '</span>';
        else {
            act = '<input type="button" class="button_gen asnm-small-btn" value="' + asnmEsc(t('btn_take')) + '" onclick="asnmTakeAsn([\'' + x.asn + '\'])"/>';
            if (!seen[x.asn]) { seen[x.asn] = 1; addable.push(x.asn); }
        }
        html += '<tr><td>' + asnmEsc(x.ip) + '</td><td>' + (x.asn ? 'AS' + asnmEsc(x.asn) : '-') + '</td><td>' + asnmEsc(x.holder) + '</td><td class="asnm-actions">' + act + '</td></tr>';
    }
    html += '</table></div>';
    if (addable.length > 1) html += '<div style="margin-top:10px;"><input type="button" class="button_gen asnm-small-btn" value="' + asnmEsc(t('btn_take_all')) +
        '" onclick="asnmTakeAsn([\'' + addable.join("','") + '\'])"/></div>';
    box.innerHTML = html;
}

function asnmTakeAsn(list) {
    var f = document.getElementById('asnm_add_asns');
    var cur = f.value.split(/[,;\s]+/).filter(function (v) { return v; });
    for (var i = 0; i < list.length; i++) if (cur.indexOf('AS' + list[i]) < 0 && cur.indexOf(list[i]) < 0) cur.push('AS' + list[i]);
    f.value = cur.join(', ');
    if (f.scrollIntoView) f.scrollIntoView({ block: 'center' });
    f.focus();
}

/* ============================ backup / restore ============================ */
function asnmPad(n) { return (n < 10 ? '0' : '') + n; }

function asnmExport() {
    if (!ASNM.data) return;
    var lines = ['# ASN Manager Backup', '[ASN_LIST]'];
    for (var i = 0; i < ASNM.data.entries.length; i++) {
        var e = ASNM.data.entries[i];
        lines.push(e.asn + ':' + e.dest + ':' + (e.src || ''));
    }
    lines.push('[SCHEDULE]', 'INTERVAL=' + ASNM.data.schedule.interval, 'TIME=' + ASNM.data.schedule.time, '');
    var d = new Date();
    var name = 'asn_manager_backup_' + d.getFullYear() + asnmPad(d.getMonth() + 1) + asnmPad(d.getDate()) + '_' +
               asnmPad(d.getHours()) + asnmPad(d.getMinutes()) + asnmPad(d.getSeconds()) + '.conf';
    var blob = new Blob([lines.join('\n')], { type: 'text/plain' });
    var a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = name;
    document.body.appendChild(a);
    a.click();
    setTimeout(function () { URL.revokeObjectURL(a.href); a.parentNode.removeChild(a); }, 1000);
}

function asnmParseBackup(txt) {
    var lines = txt.replace(/\r/g, '').split('\n'), section = null, hasSections = /^\[ASN_LIST\]/m.test(txt);
    var res = { entries: [], bad: 0, interval: null, time: null };
    for (var i = 0; i < lines.length; i++) {
        var l = lines[i].trim();
        if (!l || l.charAt(0) === '#') continue;
        if (/^\[.*\]$/.test(l)) { section = l; continue; }
        if (section === '[SCHEDULE]') {
            var m = /^INTERVAL=(\d{1,2})$/.exec(l); if (m) res.interval = m[1];
            m = /^TIME=(([01]?\d|2[0-3]):[0-5]\d)$/.exec(l); if (m) res.time = m[1];
            continue;
        }
        if (hasSections && section !== '[ASN_LIST]') continue;
        var e = ASNM.reEntry.exec(l);
        if (e && (!e[3] || ASNM.reIp.test(e[3]))) res.entries.push(e[1] + ':' + (e[2] === 'WAN' ? 'WAN1' : e[2]) + ':' + (e[3] || ''));
        else res.bad++;
    }
    return res;
}

function asnmImportFile(input) {
    var file = input.files && input.files[0];
    input.value = '';
    if (!file) return;
    var reader = new FileReader();
    reader.onload = function () {
        var r = asnmParseBackup(String(reader.result || ''));
        var panel = document.getElementById('asnm_import_panel');
        if (!r.entries.length) {
            ASNM.importData = null;
            panel.style.display = 'block';
            document.getElementById('asnm_import_info').textContent = t('import_none');
            document.getElementById('asnm_import_btns').style.display = 'none';
            return;
        }
        ASNM.importData = r;
        var info = t('import_found', { n: r.entries.length, file: file.name, bad: r.bad ? t('import_bad', { n: r.bad }) : '' });
        if (r.interval && r.time) info += t('import_sched', { i: r.interval, t: r.time });
        document.getElementById('asnm_import_info').textContent = info;
        document.getElementById('asnm_import_btns').style.display = '';
        panel.style.display = 'block';
    };
    reader.readAsText(file);
}

function asnmImportRun(mode) {
    var r = ASNM.importData;
    if (!r) return;
    if (mode === 'replace' && ASNM.data && ASNM.data.entries.length &&
        !confirm(t('c_replace', { n: ASNM.data.entries.length, m: r.entries.length }))) return;

    // amng_custom values are size limited -> send the list in chunks
    var jobs = [], chunk = [], len = 0;
    for (var i = 0; i < r.entries.length; i++) {
        if (len + r.entries[i].length + 1 > ASNM.chunkChars && chunk.length) {
            jobs.push(['import', [jobs.length ? 'merge' : mode, chunk.join(',')]]);
            chunk = []; len = 0;
        }
        chunk.push(r.entries[i]); len += r.entries[i].length + 1;
    }
    if (chunk.length) jobs.push(['import', [jobs.length ? 'merge' : mode, chunk.join(',')]]);
    if (r.interval && r.time && +r.interval >= 1 && +r.interval <= 30) jobs.push(['schedule', [r.interval, r.time]]);

    asnmImportCancel();
    asnmSendQueue(jobs);
}

function asnmImportCancel() {
    ASNM.importData = null;
    document.getElementById('asnm_import_panel').style.display = 'none';
}

var ASNM_ROUTER_LANG = 'en';

function asnmLangMode() {
    try { return localStorage.getItem('asnm_lang_mode') === 'en' ? 'en' : 'default'; } catch (e) { return 'default'; }
}

function asnmRenderLangSwitch() {
    var mode = asnmLangMode(), html = '';
    var opts = [['default', t('lang_default')], ['en', t('lang_en')]];
    for (var i = 0; i < opts.length; i++)
        html += '<span class="' + (opts[i][0] === mode ? 'asnm-on' : '') + '" onclick="asnmSetLangMode(\'' + opts[i][0] + '\')">' + asnmEsc(opts[i][1]) + '</span>';
    document.getElementById('asnm_lang').innerHTML = html;
}

function asnmSetLangMode(mode) {
    if (mode === asnmLangMode()) return;
    try { if (mode === 'en') localStorage.setItem('asnm_lang_mode', 'en'); else localStorage.removeItem('asnm_lang_mode'); } catch (e) {}
    window.location.reload();
}

var ASNM_THEMES = { dark: '#1d2328', light: '#ffffff', blue: '#14528a' };

function asnmSetTheme(name, noSave) {
    if (!ASNM_THEMES[name]) name = 'dark';
    document.getElementById('asnm').setAttribute('data-theme', name);
    var seg = document.getElementById('asnm_theme'), html = '';
    for (var k in ASNM_THEMES) html += '<span class="' + (k === name ? 'asnm-on' : '') + '" onclick="asnmSetTheme(\'' + k + '\')">' +
        '<i class="asnm-dot" style="background:' + ASNM_THEMES[k] + '"></i>' + asnmEsc(t('theme_' + k)) + '</span>';
    seg.innerHTML = html;
    if (!noSave) { try { localStorage.setItem('asnm_theme', name); } catch (e) {} }
}

function asnmLoadTheme() {
    var n = 'dark';
    try { n = localStorage.getItem('asnm_theme') || 'dark'; } catch (e) {}
    asnmSetTheme(n, true);
}

function initial() {
    var page = window.location.pathname.substring(1);
    document.formAsnm.elements['current_page'].value = page;
    document.formAsnm.elements['next_page'].value = page;
    asnmApplyI18n();
    asnmRenderLangSwitch();
    asnmLoadTheme();
    asnmLoadCollapsed();
    show_menu();
    asnmLoadData(true);
    asnmLoadPubip(true);
}
</script>
</head>
<body onload="initial();" class="bg">
<div id="TopBanner"></div>
<div id="Loading" class="popup_bg"></div>
<form method="post" name="formAsnm" action="/start_apply.htm" onsubmit="return false;">
<input type="hidden" name="current_page" value=""/>
<input type="hidden" name="next_page" value=""/>
<input type="hidden" name="modified" value="0"/>
<input type="hidden" name="action_mode" value="apply"/>
<input type="hidden" name="action_wait" value="0"/>
<input type="hidden" name="first_time" value=""/>
<input type="hidden" name="action_script" value=""/>
<input type="hidden" name="preferred_lang" id="preferred_lang" value="<% nvram_get("preferred_lang"); %>"/>
<input type="hidden" name="firmver" value="<% nvram_get("firmver"); %>"/>
<input type="hidden" name="amng_custom" id="amng_custom" value=""/>
</form>
<form method="post" name="formAsnmPubip" action="/start_apply.htm" onsubmit="return false;">
<input type="hidden" name="current_page" value=""/>
<input type="hidden" name="next_page" value=""/>
<input type="hidden" name="modified" value="0"/>
<input type="hidden" name="action_mode" value="apply"/>
<input type="hidden" name="action_wait" value="0"/>
<input type="hidden" name="action_script" value=""/>
</form>

<table class="content" align="center" cellpadding="0" cellspacing="0">
<tr>
<td width="17">&nbsp;</td>
<td valign="top" width="202">
  <div id="mainMenu"></div>
  <div id="subMenu"></div>
</td>
<td valign="top">
<div id="tabMenu" class="submenuBlock"></div>
<table width="98%" border="0" align="left" cellpadding="0" cellspacing="0">
<tr><td align="left" valign="top">

<div id="asnm">
  <div class="asnm-header">
    <div class="asnm-brand">
      <div class="asnm-logo">AS</div>
      <div><div class="asnm-title">ASN Manager</div><div class="asnm-sub" data-i18n="subtitle"></div></div>
    </div>
    <div class="asnm-meta">
      <div class="asnm-meta-top"><span class="asnm-seg-label" data-i18n="lang_label"></span><div class="asnm-seg" id="asnm_lang"></div>
        <span class="asnm-seg-label" style="margin-left:6px;" data-i18n="theme_label"></span><div class="asnm-seg" id="asnm_theme"></div></div>
      <span class="asnm-chip" id="asnm_version">-</span>&nbsp; <span data-i18n="data_refreshed"></span> <span id="asnm_generated">-</span></div>
  </div>

  <div id="asnm_banner" class="asnm-banner"><span data-i18n-html="banner_pending"></span></div>
  <div id="asnm_banner_failed" class="asnm-banner asnm-banner-bad"></div>

  <div class="asnm-card">
    <div class="asnm-card-head"><svg class="asnm-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 12h4l3 8 4-16 3 8h4"/></svg><div class="asnm-card-titles"><h3 data-i18n="status"></h3></div></div>
    <div class="asnm-stats">
      <div class="asnm-stat"><div class="asnm-stat-label" data-i18n="stat_asns"></div><div class="asnm-stat-value" id="asnm_stat_asns">-</div></div>
      <div class="asnm-stat"><div class="asnm-stat-label" data-i18n="stat_subnets"></div><div class="asnm-stat-value" id="asnm_stat_subnets">-</div></div>
      <div class="asnm-stat"><div class="asnm-stat-label" data-i18n="stat_ifaces"></div><div class="asnm-stat-value" id="asnm_stat_ifaces">-</div></div>
      <div class="asnm-stat"><div class="asnm-stat-label" data-i18n="stat_last"></div><div class="asnm-stat-value asnm-small" id="asnm_last_apply">-</div></div>
    </div>
    <div class="asnm-kv"><span data-i18n="auto_refresh"></span>: <b id="asnm_schedule_info">-</b></div>
    <div class="asnm-row">
      <input type="button" class="button_gen asnm-btn asnm-primary" data-i18n-value="btn_apply" onclick="asnmApply();"/>
      <input type="button" id="asnm_btn_retry" class="button_gen asnm-btn asnm-danger" style="display:none;" value="" onclick="asnmRetry();"/>
      <span class="asnm-spacer"></span>
      <input type="button" class="button_gen asnm-btn asnm-ghost" data-i18n-value="btn_reload" onclick="asnmSend('refresh', []);"/>
    </div>
    <span id="asnm_status" class="asnm-status"></span>
    <div id="asnm_progress" class="asnm-progress">
      <div class="asnm-progress-track"><div id="asnm_progress_bar" class="asnm-progress-bar"></div></div>
      <div id="asnm_progress_text" class="asnm-progress-text"></div>
    </div>
  </div>

  <div class="asnm-card">
    <div class="asnm-card-head"><svg class="asnm-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="3" width="20" height="8" rx="2"/><rect x="2" y="13" width="20" height="8" rx="2"/><path d="M6 7h.01M6 17h.01"/></svg><div class="asnm-card-titles"><h3 data-i18n="ifaces_title"></h3></div><input type="button" id="asnm_pubip_btn" class="button_gen asnm-small-btn asnm-ghost" data-i18n-value="btn_pubip_refresh" onclick="asnmRefreshPubip();"/></div>
    <div class="asnm-table-wrap"><div id="asnm_ifaces"></div></div>
  </div>

  <div class="asnm-grid2">
    <div class="asnm-card">
      <div class="asnm-card-head"><svg class="asnm-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></svg><div class="asnm-card-titles"><h3 data-i18n="schedule_title"></h3></div></div>
      <div class="asnm-form">
        <div class="asnm-field"><span class="asnm-label" data-i18n="refresh_every"></span>
          <div class="asnm-inline"><input type="text" id="asnm_sched_int" class="asnm-w-sm" maxlength="2"/><span class="asnm-muted"><span data-i18n="days"></span> <span data-i18n="days_range"></span></span></div></div>
        <div class="asnm-field"><span class="asnm-label" data-i18n="at_time"></span>
          <div class="asnm-inline"><input type="text" id="asnm_sched_time" class="asnm-w-md" maxlength="5" placeholder="04:30"/><span class="asnm-muted" data-i18n="time_fmt"></span></div></div>
      </div>
      <div class="asnm-row" style="margin-top:14px;"><input type="button" class="button_gen asnm-btn" data-i18n-value="btn_save_schedule" onclick="asnmSaveSchedule();"/></div>
    </div>
    <div class="asnm-card">
      <div class="asnm-card-head"><svg class="asnm-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 8v13H3V8M1 3h22v5H1zM10 12h4"/></svg><div class="asnm-card-titles"><h3 data-i18n="backup_title"></h3></div></div>
      <div class="asnm-field"><span class="asnm-label" data-i18n="backup_export"></span><span class="asnm-help" data-i18n="backup_export_desc"></span>
        <div class="asnm-row" style="margin-top:4px;"><input type="button" class="button_gen asnm-btn" data-i18n-value="btn_export" onclick="asnmExport();"/></div></div>
      <div class="asnm-divider"></div>
      <div class="asnm-field"><span class="asnm-label" data-i18n="backup_import"></span><span class="asnm-help" data-i18n="backup_import_desc"></span>
        <input type="file" id="asnm_import_file" accept=".conf,.txt" style="display:none;" onchange="asnmImportFile(this);"/>
        <div class="asnm-row" style="margin-top:4px;"><input type="button" class="button_gen asnm-btn" data-i18n-value="btn_import" onclick="document.getElementById('asnm_import_file').click();"/></div></div>
      <div id="asnm_import_panel">
        <div id="asnm_import_info"></div>
        <div id="asnm_import_btns" class="asnm-row" style="margin-top:10px;">
          <input type="button" class="button_gen asnm-btn asnm-primary asnm-small-btn" data-i18n-value="btn_replace" onclick="asnmImportRun('replace');"/>
          <input type="button" class="button_gen asnm-btn asnm-small-btn" data-i18n-value="btn_merge" onclick="asnmImportRun('merge');"/>
          <input type="button" class="button_gen asnm-ghost asnm-small-btn" data-i18n-value="btn_cancel" onclick="asnmImportCancel();"/>
        </div>
      </div>
    </div>
  </div>

  <div class="asnm-card">
    <div class="asnm-card-head"><svg class="asnm-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14.7 6.3a4 4 0 0 0-5.4 5.4L3 18l3 3 6.3-6.3a4 4 0 0 0 5.4-5.4l-2.5 2.5-2.4-.6-.6-2.4z"/></svg><div class="asnm-card-titles"><h3 data-i18n="diag_title"></h3></div></div>
    <div class="asnm-form">
      <div class="asnm-field asnm-full"><span class="asnm-label" data-i18n="domain_ip"></span>
        <div class="asnm-inline">
          <input type="text" id="asnm_diag" maxlength="253" data-i18n-ph="ph_diag" autocomplete="off"/>
          <input type="button" class="button_gen asnm-btn" data-i18n-value="btn_test" onclick="asnmTool('test','asnm_diag');"/>
          <input type="button" class="button_gen asnm-btn" data-i18n-value="btn_trace" onclick="asnmTool('trace','asnm_diag');"/>
        </div></div>
      <div class="asnm-field asnm-full"><span class="asnm-label" data-i18n="router_checks"></span>
        <div class="asnm-row">
          <input type="button" class="button_gen asnm-btn" data-i18n-value="btn_ipset" onclick="asnmTool('status');"/>
          <input type="button" class="button_gen asnm-btn" data-i18n-value="btn_pubip" onclick="asnmTool('ifaces');"/>
        </div></div>
    </div>
    <pre id="asnm_output" class="asnm-output" data-i18n="output_default"></pre>
  </div>

  <div class="asnm-card">
    <div class="asnm-card-head"><svg class="asnm-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="M12 8v8M8 12h8"/></svg><div class="asnm-card-titles"><h3 data-i18n="add_asns"></h3><div class="asnm-card-sub" data-i18n="card_add_sub"></div></div></div>
    <div class="asnm-form">
      <div class="asnm-field asnm-full"><span class="asnm-label" data-i18n="asns"></span>
        <input type="text" id="asnm_add_asns" maxlength="400" data-i18n-ph="ph_asns" autocomplete="off"/>
        <span class="asnm-help" data-i18n="hint_multi"></span></div>
      <div class="asnm-field"><span class="asnm-label" data-i18n="target"></span><select id="asnm_add_dest"></select></div>
      <div class="asnm-field"><span class="asnm-label" data-i18n="src_ip"></span>
        <div class="asnm-inline"><input type="text" id="asnm_add_src" maxlength="15" data-i18n-ph="ph_ip" autocomplete="off" style="flex:0 0 150px;"/>
          <select id="asnm_add_dev" class="asnm-devsel" onchange="asnmPickDevice(this,'asnm_add_src')"></select></div>
        <span class="asnm-help" data-i18n="src_empty"></span></div>
    </div>
    <div class="asnm-row" style="margin-top:14px;"><input type="button" class="button_gen asnm-btn asnm-primary" data-i18n-value="btn_add" onclick="asnmAdd();"/></div>
  </div>

  <div class="asnm-card">
    <div class="asnm-card-head"><svg class="asnm-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="7"/><path d="m21 21-4.3-4.3"/></svg><div class="asnm-card-titles"><h3 data-i18n="lookup_title"></h3></div></div>
    <div class="asnm-field"><span class="asnm-label" data-i18n="domain_ip"></span>
      <div class="asnm-inline">
        <input type="text" id="asnm_lookup" maxlength="253" data-i18n-ph="ph_domain" autocomplete="off" onkeydown="if (event.keyCode === 13) { asnmLookup(); return false; }"/>
        <input type="button" class="button_gen asnm-btn asnm-primary" data-i18n-value="btn_lookup" onclick="asnmLookup();"/>
      </div></div>
    <div id="asnm_lookup_result"></div>
  </div>

  <div class="asnm-card">
    <div class="asnm-card-head"><svg class="asnm-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2 2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/></svg><div class="asnm-card-titles"><h3 data-i18n="presets"></h3></div></div>
    <div class="asnm-form">
      <div class="asnm-field asnm-full"><span class="asnm-label" data-i18n="preset"></span><select id="asnm_preset"></select></div>
      <div class="asnm-field"><span class="asnm-label" data-i18n="target"></span><select id="asnm_preset_dest"></select></div>
      <div class="asnm-field"><span class="asnm-label" data-i18n="src_ip"></span>
        <div class="asnm-inline"><input type="text" id="asnm_preset_src" maxlength="15" data-i18n-ph="ph_ip" autocomplete="off" style="flex:0 0 150px;"/>
          <select id="asnm_preset_dev" class="asnm-devsel" onchange="asnmPickDevice(this,'asnm_preset_src')"></select></div></div>
    </div>
    <div class="asnm-row" style="margin-top:14px;"><input type="button" class="button_gen asnm-btn" data-i18n-value="btn_add_preset" onclick="asnmAddPreset();"/></div>
  </div>

  <div class="asnm-card">
    <div class="asnm-card-head"><svg class="asnm-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M8 6h13M8 12h13M8 18h13M3 6h.01M3 12h.01M3 18h.01"/></svg><div class="asnm-card-titles"><h3 data-i18n="list_title"></h3><div class="asnm-card-sub" data-i18n="card_list_sub"></div></div><span class="asnm-muted" id="asnm_list_summary" style="font-size:12px;margin-right:6px;"></span><span class="asnm-link" data-i18n="expand_all" onclick="asnmCollapseAll(false);" style="font-size:12px;margin-left:8px;"></span><span class="asnm-link" data-i18n="collapse_all" onclick="asnmCollapseAll(true);" style="font-size:12px;margin-left:10px;"></span></div>
    <div class="asnm-table-wrap"><div id="asnm_list" class="asnm-muted"><div style="padding:14px;">...</div></div></div>
    <div class="asnm-row" style="margin-top:14px;">
      <input type="button" class="button_gen asnm-btn" data-i18n-value="btn_remove_sel" onclick="asnmRemoveSelected();"/>
      <input type="button" class="button_gen asnm-btn asnm-danger" data-i18n-value="btn_remove_all" onclick="asnmClearAll();"/>
    </div>
  </div>

  <div class="asnm-footer" data-i18n="footer"></div>
</div>

</td></tr>
</table>
</td>
<td width="10" align="center" valign="top">&nbsp;</td>
</tr>
</table>
<div id="footer"></div>
</body>
</html>
