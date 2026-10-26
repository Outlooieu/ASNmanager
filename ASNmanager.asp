<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<!-- ASNmanager-WebUI v3.9.23 -->
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
<script type="text/javascript" src="/ext/asnmanager/lang.js"></script>
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
/* orbit animation around the logo: two dashed paths with glowing dots, drawn behind the logo */
.asnm-logo-wrap { position: relative; width: 42px; height: 42px; flex: none; margin: 0 16px 0 8px; }
.asnm-logo-wrap .asnm-logo { position: relative; z-index: 1; }
.asnm-orb { position: absolute; border-radius: 50%; border: 1px dashed var(--accent-ring); pointer-events: none; animation: asnm-spin 8s linear infinite; }
.asnm-orb.o1 { left: -9px; top: -9px; right: -9px; bottom: -9px; }
.asnm-orb.o2 { left: -17px; top: -17px; right: -17px; bottom: -17px; border-color: rgba(6,182,212,.28); animation-duration: 13s; animation-direction: reverse; }
.asnm-orb i { position: absolute; top: -4px; left: 50%; margin-left: -4px; width: 8px; height: 8px; border-radius: 50%; background: var(--accent); box-shadow: 0 0 10px var(--accent); }
.asnm-orb i.b { top: auto; bottom: -4px; }
.asnm-orb i.c { background: #06b6d4; box-shadow: 0 0 10px #06b6d4; }
#asnm[data-theme="light"] .asnm-orb i { box-shadow: 0 0 5px var(--accent); }
#asnm[data-theme="light"] .asnm-orb i.c { box-shadow: 0 0 5px #06b6d4; }
@keyframes asnm-spin { to { transform: rotate(360deg); } }
@media (prefers-reduced-motion: reduce) { .asnm-orb { animation: none; } }
.asnm-logo { width: 42px; height: 42px; border-radius: 12px; display: flex; align-items: center; justify-content: center;
             background: linear-gradient(135deg, #3b82f6, #06b6d4); font-weight: 800; font-size: 15px; color: #fff; letter-spacing: .5px;
             box-shadow: 0 6px 18px rgba(59,130,246,.35); }
.asnm-title { font-size: 20px; font-weight: 700; }
.asnm-sub { color: var(--muted); font-size: 12px; }
.asnm-meta { text-align: right; color: var(--muted); font-size: 11px; }
.asnm-meta-top { display: flex; align-items: center; justify-content: flex-end; gap: 6px; margin-bottom: 5px; }
.asnm-chip { display: inline-block; padding: 3px 10px; border-radius: 999px; background: var(--card2); border: 1px solid var(--line);
             color: var(--text); font-weight: 600; font-size: 11px; }

/* theme switch */
.asnm-seg { display: inline-flex; padding: 3px; gap: 2px; border-radius: 999px; background: var(--card2); border: 1px solid var(--line); }
.asnm-seg span { display: inline-flex; align-items: center; gap: 5px; padding: 3px 8px; border-radius: 999px; cursor: pointer;
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
.asnm-asname { color: var(--text2); font-weight: 500; margin-left: 4px; }
#asnm_list .asnm-asname { display: block; margin: 1px 0 0; font-size: 12px; color: var(--muted); max-width: 240px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
#asnm_list .asnm-src-list .asnm-dev { display: block; }
.asnm-note { margin-top: 3px; font-size: 11px; color: var(--muted); font-style: italic; max-width: 260px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.asnm-note-lbl { font-style: normal; font-weight: 600; }
.asnm-note-in { width: 200px; }
.asnm-edit-lbl { display: block; margin: 8px 0 4px; font-size: 11px; font-weight: 600; color: var(--muted); text-transform: uppercase; letter-spacing: .04em; }
#asnm .button_gen.asnm-danger-text { color: var(--bad) !important; }
.asnm-stat-sub { display: block; margin-top: 2px; font-size: 11px; font-weight: 600; color: var(--muted); white-space: normal; }
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
#asnm input[type="text"], #asnm input[type="password"], #asnm select {
    height: 36px !important; padding: 0 11px !important; width: 100%; max-width: none;
    background-color: var(--input) !important; color: var(--text) !important; border: 1px solid var(--input-line) !important; border-radius: 8px !important;
    font-family: inherit !important; font-size: 13px !important; outline: none; box-shadow: none; transition: border-color .15s, box-shadow .15s; margin: 0; }
#asnm input[type="text"]:hover, #asnm input[type="password"]:hover, #asnm select:hover { border-color: var(--input-hover) !important; }
#asnm input[type="text"]:focus, #asnm input[type="password"]:focus, #asnm select:focus { border-color: var(--accent) !important; box-shadow: 0 0 0 3px var(--accent-ring) !important; }
#asnm input[type="text"]::placeholder, #asnm input[type="password"]::placeholder { color: var(--placeholder); font-style: normal; opacity: 1; }
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
.asnm-table tr.asnm-flash td { animation: asnm-flash 1.2s ease-in-out 3; }
@keyframes asnm-flash { 50% { background: rgba(220, 38, 38, .18); } }
.asnm-grc .asnm-badge { margin-left: 6px; }
.asnm-table tr.asnm-failed td { background: rgba(248,113,113,.07); }
.asnm-table tr.asnm-editing td { background: rgba(59,130,246,.08); }
.asnm-arrow { display: inline-block; width: 0; height: 0; margin: 0 10px 1px 2px; vertical-align: middle; transition: transform .15s;
              border-left: 5px solid var(--muted); border-top: 4px solid transparent; border-bottom: 4px solid transparent; }
.asnm-arrow.asnm-open { transform: rotate(90deg); }
.asnm-gsum { float: right; font-weight: 500; color: var(--muted); font-size: 12px; }
.asnm-gsum .asnm-badge { margin-left: 6px; }
.asnm-table-wrap { border: 1px solid var(--line); border-radius: 10px; overflow: hidden; }
#asnm_list { padding: 0; }
.asnm-lsec + .asnm-lsec { margin-top: 0; padding-top: 0; border-top: 0; }
.asnm-lsec-head { display: flex; align-items: center; gap: 9px; margin: 0 0 4px; padding: 8px 12px; background: var(--card2); border: 1px solid var(--line); border-left: 4px solid var(--accent); border-radius: 8px; }
.asnm-lsec-ico { width: 18px; height: 18px; color: var(--accent2); flex: none; }
.asnm-lsec-title { font-size: 15px; font-weight: 700; color: var(--strong); letter-spacing: .01em; }
.asnm-lsec-cnt { min-width: 20px; padding: 0 8px; border-radius: 999px; background: var(--accent); color: #fff; font-size: 11px; font-weight: 700; line-height: 20px; text-align: center; }
.asnm-lsec-cnt.asnm-zero { background: var(--btn); color: var(--muted); border: 1px solid var(--line); line-height: 18px; }
.asnm-cid { font-size: 11px; margin-left: 4px; }
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

/* traffic statistics */
.asnm-tr-head { cursor: pointer; user-select: none; margin-bottom: 0; }
.asnm-tr-head .asnm-arrow { margin: 0 2px 0 0; }
#asnm_tr_card.asnm-tr-open .asnm-tr-head { margin-bottom: 14px; }
.asnm-tr-btns { display: flex; gap: 6px; flex-wrap: wrap; justify-content: flex-end; }
.asnm-tr-row { cursor: pointer; }
.asnm-tr-row td:first-child { white-space: nowrap; }
.asnm-tr-other td { background: var(--card2); }
.asnm-tr-sub td { background: var(--row-hover); font-size: 12px; padding-top: 6px; padding-bottom: 6px; }
.asnm-tr-sub td:first-child { padding-left: 34px; }
.asnm-tr-subhead td { color: var(--muted); font-size: 11px; text-transform: uppercase; letter-spacing: .05em; padding-top: 8px; }
.asnm-bar { height: 6px; width: 90px; background: var(--input); border: 1px solid var(--line); border-radius: 999px; overflow: hidden; display: inline-block; vertical-align: middle; }
.asnm-bar > i { display: block; height: 100%; background: linear-gradient(90deg, var(--accent), #06b6d4); border-radius: 999px; }
.asnm-tr-note { margin-top: 10px; font-size: 11px; color: var(--muted); }
.asnm-tr-warn { margin-top: 8px; font-size: 12px; color: var(--warn); }
.asnm-mail-warn { color: var(--warn); }
.asnm-split { height: 8px; background: var(--line); border-radius: 999px; overflow: hidden; margin: 2px 0 6px; }
.asnm-split > i { display: block; height: 100%; background: linear-gradient(90deg, var(--accent), #06b6d4); border-radius: 999px; }
.asnm-split-legend { display: flex; justify-content: space-between; font-size: 11px; color: var(--muted); margin-bottom: 14px; }
.asnm-split-legend b { color: var(--text2); font-weight: 600; }
.asnm-net { display: inline-block; margin-left: 6px; padding: 0 8px; border-radius: 999px; font-size: 10px; font-weight: 600; line-height: 16px;
            background: var(--card2); border: 1px solid var(--line); color: var(--text2); vertical-align: 1px; white-space: nowrap; }
.asnm-net-g { color: var(--warn); border-color: rgba(251,191,36,.45); }
.asnm-net-v { color: var(--accent2); border-color: rgba(96,165,250,.45); }
/* expandable rows of the traffic table */
.asnm-tgl { display: inline-flex; align-items: center; justify-content: center; width: 20px; height: 20px; margin-right: 10px; flex: none; border-radius: 6px;
            border: 1px solid var(--line); background: var(--card2); vertical-align: middle; transition: background .15s, border-color .15s; }
.asnm-tgl::before { content: ""; width: 0; height: 0; margin-left: 1px; border-left: 5px solid var(--accent2); border-top: 4px solid transparent; border-bottom: 4px solid transparent; transition: transform .15s; }
.asnm-tr-row.open .asnm-tgl { border-color: var(--accent); }
.asnm-tr-row.open .asnm-tgl::before { transform: rotate(90deg); margin-left: 0; }
.asnm-tr-row:hover td { background: var(--group-hover); }
.asnm-tr-row:hover .asnm-tgl { border-color: var(--accent); background: var(--accent-ring); }
.asnm-tr-cnt { display: inline-block; margin-left: 8px; padding: 0 8px; border-radius: 999px; font-size: 10px; font-weight: 600; line-height: 16px;
               background: var(--card2); border: 1px solid var(--line); color: var(--muted); vertical-align: 1px; white-space: nowrap; }
.asnm-tr-sub.asnm-tr-row td:first-child { padding-left: 34px; }
.asnm-tr-sub.asnm-lv2 td:first-child { padding-left: 62px; }
.asnm-tr-hint { display: flex; align-items: center; gap: 4px; margin: 0 0 10px; font-size: 12px; color: var(--muted); flex-wrap: wrap; }
.asnm-tr-hint .asnm-tgl { margin-right: 6px; cursor: default; }
.asnm-tr-hint .asnm-link { margin-left: 10px; }
.asnm-share { white-space: nowrap; }
.asnm-share .asnm-bar { width: 48px; }
.asnm-pct { display: inline-block; min-width: 40px; margin-left: 6px; text-align: right; font-size: 12px; font-variant-numeric: tabular-nums; color: var(--text2); }
/* collapsed traffic card: make clear that it can be opened */
.asnm-tr-head { padding: 3px 6px 3px 3px; border-radius: 10px; transition: background .15s; }
.asnm-tr-head:hover { background: var(--row-hover); }
.asnm-tr-head:focus-visible, .asnm-tr-bar:focus-visible { outline: 2px solid var(--accent); outline-offset: 2px; }
.asnm-tr-head > .asnm-tgl { width: 26px; height: 26px; border-radius: 8px; margin-right: 0; }
.asnm-tr-head > .asnm-tgl::before { border-left-width: 6px; border-top-width: 5px; border-bottom-width: 5px; }
.asnm-tr-head:hover > .asnm-tgl { border-color: var(--accent); background: var(--accent-ring); }
#asnm_tr_card.asnm-tr-open .asnm-tr-head > .asnm-tgl { border-color: var(--accent); }
#asnm_tr_card.asnm-tr-open .asnm-tr-head > .asnm-tgl::before { transform: rotate(90deg); margin-left: 0; }
.asnm-tr-bar { display: flex; align-items: center; justify-content: center; gap: 10px; margin-top: 12px; padding: 9px 12px; border: 1px dashed var(--input-line); border-radius: 10px;
               font-size: 12px; font-weight: 600; color: var(--accent2); cursor: pointer; user-select: none; flex-wrap: wrap; transition: background .15s, border-color .15s; }
.asnm-tr-bar:hover { background: var(--accent-ring); border-color: var(--accent); border-style: solid; }
.asnm-tr-bar .asnm-tgl { width: 18px; height: 18px; margin-right: 0; border-radius: 5px; }
.asnm-tr-bar .asnm-tgl::before { transform: rotate(90deg); margin-left: 0; }
.asnm-tr-sum { color: var(--muted); font-weight: 500; }
#asnm_tr_card.asnm-tr-open .asnm-tr-bar { display: none; }
.asnm-banner.asnm-banner-info { flex-wrap: wrap; border-color: rgba(59,130,246,.5); background: rgba(59,130,246,.1); color: var(--text); }
.asnm-banner.asnm-banner-info::before { background: var(--accent); box-shadow: 0 0 0 4px var(--accent-ring); }
.asnm-upd-line { margin-top: 5px; line-height: 1.5; }
#asnm_upd_state { color: var(--text2); font-weight: 600; }
#asnm_upd_state.asnm-upd-new { color: var(--accent2); }
#asnm_upd_state.asnm-upd-warn { color: var(--warn); }
.asnm-upd-line .asnm-link { margin-left: 6px; white-space: nowrap; }
.asnm-rc-ok, .asnm-kv b.asnm-rc-ok { color: var(--ok); } .asnm-rc-warn, .asnm-kv b.asnm-rc-warn { color: var(--warn); } .asnm-rc-bad, .asnm-kv b.asnm-rc-bad { color: var(--bad); }
#asnm_tr_table .asnm-table th:not(:first-child), #asnm_tr_table .asnm-table td:not(:first-child) { padding-left: 7px; padding-right: 7px; }
#asnm_tr_table td.num { white-space: nowrap; }
.asnm-live { white-space: nowrap; font-variant-numeric: tabular-nums; }
.asnm-live .asnm-ru, .asnm-iflive .asnm-ru { color: var(--muted); margin-left: 8px; }
.asnm-iflive { white-space: nowrap; font-variant-numeric: tabular-nums; text-align: right; }
.asnm-tr-live { display: flex; align-items: center; gap: 12px; margin: 10px 0 14px; font-size: 12px; color: var(--text2); flex-wrap: wrap; }
.asnm-tr-live b { color: var(--strong); font-variant-numeric: tabular-nums; }
.asnm-tr-live .asnm-unit { margin-left: auto; font-size: 11px; }
.asnm-sg { margin-top: 18px; padding-top: 14px; border-top: 1px solid var(--line); }
.asnm-sg-head { display: flex; align-items: baseline; gap: 10px; flex-wrap: wrap; margin-bottom: 10px; }
.asnm-sg-title { font-weight: 700; font-size: 13px; color: var(--strong); }
.asnm-sg-name { display: block; max-width: 120px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.asnm-sg-on { font-size: 11px; color: var(--warn); max-width: 120px; line-height: 1.35; margin-top: 2px; }
.asnm-sg-cl { font-size: 12px; color: var(--text2); max-width: 170px; }
.asnm-sg-clrow { display: flex; justify-content: space-between; gap: 8px; line-height: 18px; }
.asnm-sg-clrow span:first-child { overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
#asnm_sg .asnm-table th:not(:first-child), #asnm_sg .asnm-table td:not(:first-child) { padding-left: 6px; padding-right: 6px; }
#asnm .asnm-sg-sel { width: 88px; }
#asnm .asnm-sg-note { width: 130px; height: 32px !important; }
#asnm_sg_tbl th { white-space: nowrap; }
#asnm_sg_tbl td.num { white-space: nowrap; }
#asnm_sg_tbl .asnm-ms-btn { width: 108px; }
.asnm-sg-foot { margin-top: 8px; font-size: 11px; color: var(--muted); line-height: 1.5; }
/* collapsible sections inside the traffic card */
.asnm-sec { margin-top: 12px; border-top: 1px solid var(--line); }
.asnm-sec-head { display: flex; align-items: center; gap: 10px; padding: 11px 6px 11px 2px; cursor: pointer; user-select: none; border-radius: 8px; transition: background .15s; }
.asnm-sec-head:hover { background: var(--row-hover); }
.asnm-sec-head .asnm-tgl { margin-right: 0; }
.asnm-sec-head:hover .asnm-tgl { border-color: var(--accent); background: var(--accent-ring); }
.asnm-sec-head.open .asnm-tgl { border-color: var(--accent); }
.asnm-sec-head.open .asnm-tgl::before { transform: rotate(90deg); margin-left: 0; }
.asnm-sec-head:focus-visible { outline: 2px solid var(--accent); outline-offset: 2px; }
.asnm-sec-title { font-weight: 700; font-size: 13px; color: var(--strong); }
.asnm-sec-body { padding: 2px 0 8px; }
/* suggestions: filter bar and multi-device selection */
.asnm-sg-since { font-size: 11px; color: var(--muted); margin: 0 0 8px; }
.asnm-ex { font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace; font-size: 11px; padding: 1px 5px; border-radius: 5px;
    background: var(--card2); border: 1px solid var(--line); color: var(--text); white-space: nowrap; }
.asnm-s-formats { line-height: 1.9; }
.asnm-preset-items { line-height: 2; margin: 2px 0 4px; }
.asnm-preset-own { font-size: 12px; font-weight: 600; color: var(--accent); line-height: 1.5; }
#asnm option.asnm-opt-own { font-weight: 600; }
.asnm-ex.asnm-ex-on { border-color: var(--ok); color: var(--ok); }
.asnm-dp-text { font-size: 12px; color: var(--text2); line-height: 1.55; margin: 0 0 12px; max-width: 760px; }
.asnm-dp-row { align-items: center; gap: 12px; }
#asnm .asnm-diag-dev { width: 260px; }
.asnm-sg-none { margin-top: 6px; }
.asnm-sg-amb { font-size: 11px; color: var(--warn); max-width: 120px; line-height: 1.35; margin-top: 2px; }
.asnm-diag-sys { margin: 0 0 14px; padding: 0 0 10px; border-bottom: 1px solid var(--line); }
.asnm-dp-full { display: inline-flex; align-items: center; gap: 6px; font-size: 12px; color: var(--text2); cursor: pointer; }
.asnm-sg-x { display: inline-flex; align-items: center; justify-content: center; width: 26px; height: 28px; margin-left: 3px; padding: 0;
    vertical-align: middle; border: 1px solid var(--line); border-radius: 8px; background: transparent; color: var(--muted); cursor: pointer; }
.asnm-sg-x:hover { color: var(--text); border-color: var(--muted); }
.asnm-sg-x svg { width: 15px; height: 15px; }
.asnm-table tr.asnm-sg-hid td { opacity: .5; }
.asnm-table tr.asnm-sg-hid td:last-child { opacity: 1; }
.asnm-sg-showhid { cursor: pointer; }
.asnm-nowrap { white-space: nowrap; }
.asnm-sg-top { display: flex; flex-wrap: wrap; align-items: center; gap: 6px 10px; margin: 0 0 10px; }
.asnm-sg-top .asnm-sg-since { margin: 0 0 0 auto; }
.asnm-sg-domoff { font-size: 12px; color: var(--text2); line-height: 1.55; max-width: 720px; }
.asnm-sg-domoff div { margin-top: 10px; }
.asnm-sg-filter { display: flex; flex-wrap: wrap; align-items: center; gap: 8px 14px; margin: 0 0 10px; font-size: 12px; color: var(--text2); }
.asnm-sg-filter label { display: inline-flex; align-items: center; gap: 6px; }
.asnm-sg-filter select { width: auto; }
#asnm .asnm-sg-filter input.asnm-sg-q { width: 180px; flex: 0 0 180px; }
.asnm-sg-count { margin-left: auto; color: var(--muted); }
.asnm-ms { position: relative; display: inline-block; }
.asnm-sentence { display: grid; grid-template-columns: max-content minmax(0, 1fr); column-gap: 14px; row-gap: 12px; align-items: center; }
.asnm-sentence .asnm-sw { color: var(--text2); font-size: 14px; white-space: nowrap; text-align: right; }
.asnm-sentence > .asnm-s-help, .asnm-sentence > .asnm-s-src, .asnm-sentence > .asnm-s-dom { grid-column: 2; }
.asnm-s-row { display: flex; align-items: center; gap: 12px; min-width: 0; }
#asnm .asnm-s-row select { width: 280px; flex: 0 1 280px; min-width: 0; }
#asnm .asnm-s-row input[type="text"] { flex: 1 1 auto; min-width: 0; }
.asnm-s-row .button_gen { flex: none; }
#asnm .asnm-s-row .asnm-ms-btn { height: 36px; width: 180px; box-sizing: border-box; font-size: 13px; }
.asnm-s-help { margin-top: -6px; font-size: 12px; color: var(--muted); }
.asnm-s-src { display: flex; flex-direction: column; gap: 5px; max-width: 420px; }
@media (max-width: 560px) {
  .asnm-sentence { grid-template-columns: minmax(0, 1fr); row-gap: 6px; }
  .asnm-sentence > .asnm-sw { text-align: left; font-size: 12px; margin-top: 8px; }
  .asnm-s-help { margin-top: 0; }
  .asnm-sentence > .asnm-s-help, .asnm-sentence > .asnm-s-src, .asnm-sentence > .asnm-s-dom { grid-column: 1; }
  .asnm-s-row { flex-wrap: wrap; }
  #asnm .asnm-s-row select { flex: 1 1 100%; width: 100%; }
}
.asnm-ms-btn { display: inline-flex; align-items: center; justify-content: space-between; gap: 8px; width: 132px; padding: 6px 10px; border-radius: 8px; cursor: pointer;
               background: var(--input); border: 1px solid var(--input-line); color: var(--text); font: inherit; font-size: 12px; text-align: left; }
.asnm-ms-btn span { overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.asnm-ms-btn i { flex: none; width: 0; height: 0; border-top: 5px solid var(--muted); border-left: 4px solid transparent; border-right: 4px solid transparent; }
.asnm-ms-btn:hover, .asnm-ms.open .asnm-ms-btn { border-color: var(--accent); }
.asnm-ms-pop { display: none; position: absolute; right: 0; top: calc(100% + 4px); z-index: 60; min-width: 250px; max-height: 300px; overflow-y: auto;
               background: var(--card); border: 1px solid var(--line); border-radius: 10px; box-shadow: var(--shadow); padding: 6px; }
.asnm-ms.open .asnm-ms-pop { display: block; }
.asnm-ms-item { display: flex; align-items: center; gap: 8px; padding: 5px 8px; border-radius: 6px; font-size: 12px; cursor: pointer; white-space: nowrap; color: var(--text); }
.asnm-ms-item:hover { background: var(--row-hover); }
.asnm-ms-all { font-weight: 600; border-bottom: 1px solid var(--line); border-radius: 6px 6px 0 0; margin-bottom: 2px; }
.asnm-ms-grp { font-size: 10px; font-weight: 700; text-transform: uppercase; letter-spacing: .05em; color: var(--muted); padding: 8px 8px 3px; }
.asnm-src-list { line-height: 1.5; }
/* failover */
.asnm-fo { margin-top: 16px; padding-top: 12px; border-top: 1px solid var(--line); }
.asnm-fo-head { display: flex; gap: 10px; align-items: baseline; flex-wrap: wrap; margin-bottom: 10px; }
.asnm-fo-sel { width: 175px; }
.asnm-fo-chain { font-size: 11px; margin-top: 4px; color: var(--muted); white-space: nowrap; }
.asnm-fo-m { white-space: nowrap; }
/* keep the font sizes fixed on phones (no automatic text enlargement) */
#asnm { -webkit-text-size-adjust: 100%; text-size-adjust: 100%; }
.asnm-dw-row { display: flex; gap: 18px; align-items: center; justify-content: space-between; padding: 14px 0; border-top: 1px solid var(--line2); }
#asnm_dw_intro { margin-bottom: 8px; line-height: 1.55; }
.asnm-dw-txt { flex: 1 1 auto; min-width: 0; }
.asnm-dw-txt .asnm-label { display: block; margin-bottom: 3px; }
.asnm-dw-row .asnm-seg { flex: none; }
@media (max-width: 560px) { .asnm-dw-row { flex-direction: column; align-items: flex-start; gap: 8px; } }
#asnm_dw_now { margin-top: 6px; }
#asnm_dw_now h4 { margin: 14px 0 6px; font-size: 13px; color: var(--text); }
#asnm_dw_now .asnm-dw-src { display: block; color: var(--muted); font-size: 11px; }
#asnm_dw_now .asnm-dw-edit { display: inline-block; margin-top: 3px; font-size: 11px; color: var(--accent2); }
.asnm-dw-ed { display: flex; flex-wrap: wrap; gap: 8px; align-items: center; }
#asnm .asnm-dw-ed input[type="text"], #asnm .asnm-dw-ed input[type="password"] { width: 150px; }
#asnm_dw_now .asnm-dw-ok { color: var(--ok); } #asnm_dw_now .asnm-dw-no { color: var(--warn); }
.asnm-dw-more { margin-top: 12px; font-size: 12px; color: var(--text2); }
.asnm-dw-more summary { cursor: pointer; color: var(--accent2); }
.asnm-dw-more ul { margin: 8px 0 0 18px; padding: 0; line-height: 1.55; }
.asnm-dw-more li { margin-bottom: 4px; }
.asnm-oe-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; margin-bottom: 8px; }
@media (max-width: 520px) { .asnm-oe-grid { grid-template-columns: 1fr; } }
#asnm .asnm-oe-ta { width: 100%; margin: 4px 0 8px; padding: 8px 11px; background: var(--input); color: var(--text); border: 1px solid var(--input-line); border-radius: 8px;
    font: 12px/1.5 ui-monospace, SFMono-Regular, Menlo, Consolas, monospace; resize: vertical; outline: none; }
#asnm .asnm-oe-ta:focus { border-color: var(--accent); box-shadow: 0 0 0 3px var(--accent-ring); }
.asnm-oe-row { display: flex; align-items: center; gap: 8px; padding: 6px 0; border-bottom: 1px solid var(--line2); font-size: 12px; }
.asnm-oe-row .asnm-oe-n { flex: 1 1 auto; min-width: 0; color: var(--text); }
.asnm-oe-row .asnm-oe-n > span { display: block; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.asnm-oe-row .asnm-oe-m { color: var(--muted); font-size: 11px; }
#asnm .asnm-oe-row .button_gen { flex: none; width: auto !important; min-width: 0 !important; }
#asnm_oe_form .asnm-label { display: block; margin-bottom: 4px; }
#asnm_oe_form .asnm-help { display: block; }
/* Chrome on Android enlarges ("font boosting") long text blocks on desktop pages; a max-height turns that off (zero specificity, so own max-heights still win) */
:where(#asnm, #asnm *) { max-height: 1000000px; }
#asnm .asnm-kv, #asnm .asnm-tr-note, #asnm .asnm-sg-foot, #asnm .asnm-help { max-height: 100000px; }
/* tabs below the overview */
.asnm-tabs { display: flex; gap: 6px; margin: 4px 0 0; padding: 0 2px; border-bottom: 2px solid var(--accent); overflow-x: auto; scrollbar-width: none; }
.asnm-tabs::-webkit-scrollbar { display: none; }
.asnm-tab { flex: 1 1 0; min-width: 0; display: inline-flex; align-items: center; justify-content: center; gap: 7px; padding: 11px 12px 10px;
            border: 1px solid var(--line); border-bottom: 0; border-radius: 10px 10px 0 0; background: var(--card2); color: var(--text2);
            font: inherit; font-size: 13px; font-weight: 600; cursor: pointer; white-space: nowrap; position: relative; top: 2px;
            box-shadow: inset 0 -6px 8px -8px rgba(0,0,0,.35); transition: background .15s, color .15s, border-color .15s; }
.asnm-tab:hover { background: var(--row-hover); color: var(--text); border-color: var(--accent); }
.asnm-tab.on { background: var(--accent); border-color: var(--accent); color: #fff; box-shadow: none; padding-bottom: 12px; }
.asnm-tab:focus-visible { outline: 2px solid var(--accent); outline-offset: -2px; }
.asnm-tabpanel { margin-top: 16px; }
.asnm-tab-badge:empty { display: none; }
.asnm-tab-badge { font-size: 10px; font-weight: 700; line-height: 16px; padding: 0 7px; border-radius: 999px; background: var(--card); color: var(--muted); border: 1px solid var(--line); }
.asnm-tab.on .asnm-tab-badge { background: rgba(255,255,255,.25); color: #fff; border-color: transparent; }
.asnm-tab-badge.ok { background: #16a34a; color: #fff; }
.asnm-tab-badge.warn { background: var(--warn); color: #1b1b1b; border-color: transparent; }
.asnm-tab-badge.ok { background: var(--ok); color: #fff; border-color: transparent; }
.asnm-subtabs { display: flex; gap: 6px; flex-wrap: wrap; margin: 0 0 16px; }
.asnm-subtab { padding: 6px 13px; border: 1px solid var(--line); border-radius: 999px; background: transparent; color: var(--text2); font: inherit; font-size: 12px; font-weight: 600; cursor: pointer; }
.asnm-subtab:hover { border-color: var(--accent); color: var(--text); }
.asnm-subtab.on { border-color: var(--accent); background: var(--accent-ring); color: var(--accent2); }
.asnm-sp-res { margin-top: 5px; font-size: 11px; line-height: 1.45; color: var(--text2); font-variant-numeric: tabular-nums; }
.asnm-sp { white-space: nowrap; }
.asnm-rs-title { font-weight: 700; margin: 0 0 4px; color: var(--strong); }
.asnm-rs-list { margin: 10px 0 0; display: flex; flex-direction: column; gap: 8px; }
.asnm-rs-item { display: flex; align-items: flex-start; gap: 9px; font-size: 13px; color: var(--text); cursor: pointer; }
.asnm-rs-item input { margin-top: 2px; }
.asnm-rs-sub { margin: -2px 0 0 26px; font-size: 12px; color: var(--text2); display: flex; gap: 16px; flex-wrap: wrap; }
.asnm-rs-sub label { display: inline-flex; align-items: center; gap: 5px; cursor: pointer; }
.asnm-rs-det { margin-left: 26px; font-size: 11px; color: var(--muted); line-height: 1.5; }
.asnm-back { display: inline-block; text-align: center; max-width: 112px; hyphens: manual; margin-right: 4px; padding: 3px 11px; border: 1px solid var(--line); border-radius: 999px; color: var(--text2); font-size: 12px; font-weight: 600; text-decoration: none; }
.asnm-back:hover { border-color: var(--accent); color: var(--text); }
.asnm-lr td { font-size: 12px; }
.asnm-lr-list { margin: 6px 0; line-height: 22px; max-height: 180px; overflow-y: auto; }
.asnm-lr-list code { display: inline-block; padding: 0 6px; margin: 0 4px 4px 0; border: 1px solid var(--line); border-radius: 6px; font-size: 11px; }
.asnm-kind { display: inline-block; padding: 0 7px; margin-right: 4px; border: 1px solid var(--line); border-radius: 999px; font-size: 10px; font-weight: 700; line-height: 16px; color: var(--muted); text-transform: uppercase; letter-spacing: .03em; }
#asnm_add_domnote { color: var(--warn); }
#asnm_add_ms .asnm-ms-btn, #asnm_preset_ms .asnm-ms-btn { width: 165px; }
#asnm_edit_ms .asnm-ms-btn { width: 200px; }
.asnm-tr-dest { color: var(--muted); font-size: 11px; margin-left: 6px; }
.asnm-tr-name { display: block; margin: 2px 0 0 26px; max-width: 280px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; font-size: 12px; color: var(--muted); }
.asnm-tr-gone { color: var(--muted); font-size: 11px; margin-left: 6px; font-style: italic; }
</style>
<script>
var ASNM_NS = 'asnmanager';
var ASNM_PAGE_VER = '3.9.23';     // the version of this page (same as the marker at the top)
var ASNM_FORCE_LANG = '';

/* ============================ i18n ============================ */
var ASNM_I18N = {
  en: {
    subtitle: 'Route whole Autonomous Systems through WAN, OpenVPN or WireGuard.',
    data_refreshed: 'Data refreshed:',
    banner_pending: 'The ASN list has changed since the last apply. Click <b>Apply rules</b> to activate the changes.',
    banner_failed: '{n} ASN(s) could not be loaded (0 subnets). They are marked red below - use <b>Retry failed</b>.',
    traffic_title: 'Traffic per ASN', tr_sub_on: 'Counting since {t}', tr_sub_off: 'Counting is off', tr_sub_none: 'Statistics module not installed',
    tr_on: 'active', tr_off: 'off', tr_btn_disable: 'Disable', tr_btn_reset: 'Disable & reset', tr_btn_enable: 'Enable',
    tr_th_name: 'ASN / target', tr_th_down: 'Download', tr_th_up: 'Upload', tr_th_pk: 'Packets', tr_th_share: 'Share', tr_show: 'Show details', tr_hide: 'Hide details', tr_sum: 'Total {b} · {n} ASN(s)', tr_toggle_tip: 'Click to expand or collapse', tr_th_share_tip: 'Share of the total traffic. In expanded rows: share of the row above.',
    tr_hint: 'Click a row to see the interfaces and devices behind it', tr_dev_1: '1 device', tr_dev_n: '{n} devices',
    tr_other: 'No rule (normal way)', tr_by_iface: 'By interface', tr_by_client: 'By client (all interfaces)', tr_unknown: 'Other addresses (no counter rule)', tr_unknown_hint: 'Traffic from IP addresses that have no counter rule of their own, e.g. a device that connected a moment ago or sits behind another router. Show them on the router with: asnstats.sh unknown', tr_total: 'Total', tr_split_asn: 'Via rules', tr_split_other: 'No rule',
    tr_no_clients: 'No client traffic yet', tr_empty: 'No traffic counted yet.', tr_off_hint: 'Counting is off. Click "Enable" to start.',
    tr_gone: 'removed from list', tr_c_reset: 'Disable counting and delete all statistics?', tr_working: 'Applying...',
    tr_note: 'IPv4, forwarded traffic only (no router own traffic). Updates every {s} s.', tr_saved_usb: 'Counts survive a reboot - saved hourly on the USB device: {p} (last change: {t})', tr_no_usb: 'No USB device found - the numbers are only kept in RAM and are lost on a reboot. Connect a USB device (folder ASNmanager) or turn saving off.',
    tr_broken: 'Counting is not running properly ({why}). Live values, new devices and suggestions are not updated.', tr_why_loop: 'background process stopped', tr_why_rules: 'counting rules missing',
    tr_repair: 'Repair', tr_repairing: 'Repairing - the numbers are kept...',
    tr_save_off: 'Saving to the USB device is turned off - the numbers are only kept in RAM and start over after a reboot.', tr_save_turn_off: 'Turn saving off', tr_save_turn_on: 'Turn saving on',
    tr_save_confirm: 'Turn off saving to the USB device?\nThe numbers are then only kept in RAM and start over after a reboot. Nothing is written to the USB device any more.', net_lan: 'LAN / Wi-Fi', net_g24: 'Guest 2.4 GHz', net_g5: 'Guest 5 GHz', net_g6: 'Guest 6 GHz', net_wgs: 'WireGuard server', net_ovs: 'OpenVPN server', tr_timeout: 'No answer from the statistics module. If this repeats, run "/jffs/scripts/ASNmanager.sh stats diag" on the router (SSH).',
    dev_lan: 'LAN / Wi-Fi devices', dev_wg: 'WireGuard server peers', dev_ovpn: 'OpenVPN server clients', wg_peer: 'WireGuard peer', ovpn_client: 'OpenVPN client',
    upd_label: 'Update', upd_check: 'Check for updates', upd_checking: 'Checking GitHub...', upd_current: 'Up to date (v{v})', upd_checked: 'checked {t}',
    upd_available: 'v{r} available', upd_error: 'GitHub not reachable', upd_install: 'Update now', upd_notes: 'What is new?', upd_running: 'Updating - please wait, the page reloads afterwards...',
    banner_update: 'A new version is available: ASN Manager v{r} (installed: v{l}).',
    upd_confirm: 'Install ASN Manager v{r} now?\nThe page reloads afterwards. ASN list, schedule and statistics are kept.',
    rc_title: 'Routing check', rc_now: 'Check now', rc_checking: 'Checking...', rc_summary: '{ok} OK · {warn} warnings · {fail} errors', rc_checked: 'checked {t}',
    rc_none: 'no ASNs', rc_th: 'Routing', rc_down: 'offline', rc_noroute: 'no route', rc_norule: 'not active', rc_nosub: 'no subnets',
    rc_tip_ok: 'Sample address {ip} goes via {dev} as intended.', rc_tip_wrong: 'Sample address {ip} goes via {got} instead of {dev}!',
    rc_tip_down: 'Target interface {dev} is offline.', rc_tip_noroute: 'No route found for {ip}.', rc_tip_norule: 'The rule is not active - click "Apply rules".',
    rc_tip_nosub: 'No subnets are loaded for this ASN.', rc_tip_seen: 'Traffic via {dev} since the previous check: {b}',
    banner_rc: 'Not routed as intended ({n}):',
    tr_live: 'Live', tr_live_tip: 'Current throughput, measured over the last ~{s} s', tr_live_off: 'only while counting is enabled', tr_live_wait: 'measuring...',
    sg_title: 'Suggestions: top destinations without a rule', sg_since: 'collected since {t}', sg_off: 'Suggestions need active counting.',
    sg_wait: 'Collecting data - the first evaluation appears after about a minute.', sg_empty: 'No destinations without a rule found yet.',
    sg_pending: '{n} destination address(es) with {b} of traffic are still being looked up...', sg_fails: 'Look-ups for {n} network(s) failed (ip-api.com, ipinfo.io and RIPEstat not reachable from the router?) - they are retried after an hour.',
    sg_on_list: 'on the list for: {d} ({t}) - Add extends the devices of this rule', sg_noacct: 'The byte counters for connections could not be switched on - no suggestions possible.',
    sg_th_asn: 'ASN', sg_th_b: 'Traffic', sg_th_cl: 'Used by', sg_th_t: 'Target', sg_th_dev: 'Device', sg_all: 'All devices', sg_grp_used: 'Uses this ASN', sg_add: 'Add', sg_more: '+{n} more', sg_less: 'show less',
    sgv_label: 'View', sgv_asn: 'by ASN', sgv_dom: 'by domain', sgd_th_dom: 'Domain', sgd_f_q: 'Search domain', sgd_subs_more: '+{n} more',
    sgd_off_text: 'Suggestions by domain are off. When turned on, dnsmasq writes every lookup it answers into a file in the RAM of the router. ASN Manager reads it once a minute, notes which name belongs to which address and empties the file again - nothing is written to the flash memory and nothing is looked up on the internet. Turning it on or off restarts dnsmasq once (DNS pauses for a few seconds).',
    sgd_turn_on: 'Turn on suggestions by domain', sgd_turn_off: 'Turn off suggestions by domain',
    sgd_off_confirm: 'Turn off suggestions by domain?\ndnsmasq is restarted once and the collected names are deleted.',
    sgd_empty: 'No names collected yet - domains show up about a minute after a device looked them up.',
    sgd_none: '{b} of traffic (since the collection started) went to {n} address(es) without a known name (looked up before the suggestions by domain were turned on, answered from a cache, or not through the router - e.g. "secure DNS" in a browser).',
    sgd_amb: '{b} via shared servers - also: {d}', sgd_amb_tip: 'These servers also answered lookups for other domains (CDN). The traffic is counted under this domain because it was the latest lookup - it may belong to one of the others.',
    sgd_none_show: 'Show the largest', sgd_none_hide: 'Hide', sgd_none_ip: 'Address', sgd_none_net: 'Network', sgd_none_dev: 'Used most by',
    sgd_none_tip: 'A device with a lot of traffic here probably asks its own DNS server (e.g. 8.8.8.8 on many TV sticks, "Private DNS" on Android, "secure DNS" in Chrome / Firefox). Traffic counted before the suggestions by domain were turned on has no names either - it leaves this list over time.',
    sgd_ext: 'The lookup log of another add-on (e.g. Diversion) is read, dnsmasq is left as it is.',
    sgd_note: 'Names from the lookups dnsmasq answered (and from the query log of AdGuard Home, written in batches), evaluated every minute. Suggested is the main domain (zdf.de) - it covers every subdomain; the names below it were looked up. Large networks (CDNs) serve many names from one address: the latest lookup counts. Domains and ASNs already in the list are hidden. "Add" puts the domain on the list - then apply the rules.',
    sg_note: 'Estimate from the connection table of the router, evaluated every minute (very short connections can be missed). Destination addresses are looked up via ip-api.com (at most 10 per minute). ASNs that are already in the list are hidden. "Add" puts the ASN on the list - then apply the rules.',
    sec_tbl: 'Traffic per ASN / target', sec_cnt: '{n} entry(ies)', sg_f_show: 'Show', sg_f_dev: 'Device', sg_f_q: 'Search ASN or name',
    sg_f_count: '{x} of {y} ASN(s)', sgd_f_count: '{x} of {y} domain(s)', sgd_nomatch: 'No domain matches the filter.', sg_f_total: ' - {n} found in total, the 100 largest are listed', sg_n_dev: '{n} devices', sg_nomatch: 'No ASN matches the filter.',
    sg_all_dev_f: 'All devices', sg_th_b_dev: 'Traffic of this device',
    fo_title: 'Failover', fo_sub: 'If a target fails, its ASNs use the next working fallback.', fo_th_t: 'Target', fo_th_1: '1st fallback', fo_th_2: '2nd fallback',
    fo_th_state: 'State', fo_none: '- none -', fo_block_opt: 'Block (kill switch)', fo_block_s: 'Block', fo_save: 'Save', fo_off: 'no failover',
    fo_pending: 'checking...', fo_ok: 'via {i}', fo_via: 'down - via {i}', fo_blocked: 'down - blocked', fo_since: 'since {t}',
    fo_dup: 'Please choose two different fallbacks.', fo_blocklast: '"Block" can only be the last fallback.', fo_noasn: 'No ASNs in the list yet.',
    fo_note: 'Checked every {s} s with a ping through the interface. A target counts as failed after 2 failed checks in a row and as back after 2 good ones, then its ASNs return automatically. If no member of the chain works, the traffic stays on the target - if its VPN client is stopped, that can mean WAN. Use "Block" as the last fallback to prevent that.',
    rc_tip_fo: 'Target {dev} is down - failover: sample address {ip} goes via {got}.', rc_blocked: 'blocked', rc_tip_blocked: 'Target {d} is down - the traffic is blocked (failover "Block").',
    job_busy: 'Another job is still running ({a}). The page shows it until it is finished - then please repeat your action.',
    job_running: 'A job started earlier is still running ({a}) - the page shows it until it is finished.',
    act_apply: 'Apply rules', act_reload: 'Reload all subnets', act_retry: 'Retry failed ASNs', act_update: 'Update', act_import: 'Restore', act_add: 'Add entries', act_preset: 'Add preset',
    fo_vd: 'VPN Director follows the failover', fo_vd_desc: 'When a line fails, the devices the VPN Director sends over it (and the router itself, e.g. Unbound) go over its fallback as well - with the DNS of that line. The list of the VPN Director is not changed; when the line works again, everything is as before. Off: only the entries of ASN Manager follow the failover, the VPN Director handles its devices itself (kill switch or WAN).', fo_vd_n: '+ {n} VPN Director rule(s)', fo_vd_moved: '{n} VPN Director rule(s) use a fallback right now', fo_vd_c_on: 'Let the VPN Director follow the failover? When a line fails, its devices go over the fallback you set here (with "Block": they are blocked).',
    dw_fo: 'down - looked up through the DNS of {a} (failover)', dw_fo_block: 'down - lookups blocked (failover: block)', act_aghlogin: 'AdGuard Home login', agh_title: 'AdGuard Home login', agh_desc: 'Optional: with the login of the AdGuard Home web interface, "DNS per device" changes its clients through AdGuard Home itself - no restart, DNS keeps running. Kept on the router only (readable by root only, not in backups). Without it AdGuard Home is restarted as before.', agh_user: 'User name', agh_pass: 'Password', agh_change: 'Change', agh_remove: 'Remove login', agh_none: 'No login saved - client changes restart AdGuard Home.', agh_saved: 'Login saved - used at the next client change.', agh_ok: 'Login saved and working - client changes without a restart.', agh_err: 'Login saved, but the last change failed ({e}) - AdGuard Home was restarted instead.', agh_refused: 'AdGuard Home refused the saved login (password changed?) - it is no longer used. Please enter it again.', agh_need: 'Please enter user name and password.', agh_c_off: 'Remove the AdGuard Home login? Client changes restart AdGuard Home again.',
    act_remove: 'Remove', act_clear: 'Clear list', act_edit: 'Edit', act_schedule: 'Schedule', act_failover: 'Failover', act_statssave: 'USB saving', act_pimport: 'Add own presets', dw_set_vpn: 'Enter the DNS of the VPN provider', dw_ip2: 'second (optional)', dw_auto: 'Automatic', dw_bad_ip: '"{v}" is not an IPv4 address.', dw_need_ip: 'Please enter at least one address.', dw_vpn_why: 'Enter the DNS of your VPN provider for {t} here (the line DNS = ... of its WireGuard file) - not in the VPN client of the router: there the router sends the lookups of the devices straight to the provider, past AdGuard Home and its filters. Here they go through AdGuard Home first and then through the tunnel.', act_dnsfsrv: 'DNS of the VPN line', dw_title: 'DNS fitting the line', dw_sub: 'A lookup takes the same line as the traffic after it', dw_intro: 'Normally the router looks up every name one way (here: {b}). A site that ASN Manager sends over WAN would then still be looked up through a VPN - location, CDN servers and leak tests do not fit together. These three switches fix that.', dw_base_unknown: 'your normal DNS', dw_f_title: 'Sites of ASN Manager', dw_f_desc: 'Domains and ASNs on your list are looked up through their target - a site on WAN asks a DNS server over WAN, a site on WGC3 one through WGC3.', dw_d_title: 'Every device by the VPN Director', dw_d_desc: 'All other sites: each device looks them up through the line the VPN Director gives it. Needs AdGuard Home (restarted when the VPN Director or your domains change).', dw_t_title: 'Encrypt lookups over WAN', dw_t_desc: 'What is looked up over WAN goes out as DNS over TLS - your provider no longer sees the names. Lookups through a VPN are protected by the tunnel anyway.', dw_now: 'How it runs now', dw_th_line: 'Line', dw_th_dns: 'DNS server', dw_th_prot: 'Protected', dw_th_for: 'Used for', dw_normal: 'normal DNS', dw_unbound: 'Unbound (resolves itself)', dw_router_dns: 'DNS of the router', dw_for_rest: 'everything else', dw_devs: '{n} device(s)', dw_other_devs: 'devices not in the VPN Director', dw_doms: '{n} domains', dw_names: '{n} learned names', mail_title: 'E-mail on new versions', mail_sub: 'A notice only - nothing is installed', mail_desc: 'Uses the e-mail settings of amtm. ASN Manager looks once a day (from 9:00); you get at most one e-mail per new version and per day or week - several releases on one day come as one e-mail with all their changes.', mail_off: 'Off', mail_daily: 'Daily', mail_weekly: 'Weekly', mail_test: 'Send test e-mail', mail_noamtm: 'amtm has no e-mail settings yet - set them up in amtm first (SSH: amtm, then em).', mail_last: 'Last e-mail: v{v} ({t})', mail_err: 'Last error: {e}', act_mailtest: 'Test e-mail', dw_ddoms: '{n} domain(s) for single devices', dw_src_router_wan: 'from the WAN settings of the router', dw_src_router: 'from the VPN client of the router (bypasses AdGuard Home - better enter it here)', dw_src_auto: 'chosen automatically (public DNS through the tunnel)', dw_src_auto_wan: 'chosen automatically (no WAN DNS set)', dw_src_own: 'DNS of the VPN provider (entered here)', dw_src_own_wan: 'own setting (dns_follow.conf)', dw_p_tunnel: 'VPN tunnel', dw_p_on: 'encrypted (TLS)', dw_p_fw: 'encrypted (firmware TLS)', dw_p_dc: 'encrypted (dnscrypt-proxy)', dw_p_dcfw: 'encrypted (dnscrypt-proxy; firmware DoT is on too - one is enough)', dw_p_off: 'not encrypted', dw_p_ub: 'not encrypted (Unbound asks the name servers)', dw_ub_hint: 'Unbound resolves over WAN and asks the name servers itself - that is always unencrypted. Two ways: send Unbound through a VPN (outgoing-interface: 192.168.1.1 in unbound.conf plus the router 192.168.1.1 in the VPN Director, or the VPN option of unbound_manager) - then the tunnel protects it; or turn on DNS over TLS forwarding in Unbound (e.g. to Quad9) - then everything is encrypted, but Unbound no longer resolves by itself.', dw_p_plain: 'not encrypted - turn on WAN > DNS Privacy Protocol', dw_p_agh: 'devices only', dw_p_noubc: 'devices only (Unbound does not answer)', dw_p_nofw: 'devices only', dw_p_unknown: 'not encrypted (server without TLS)', dw_more: 'How does it work?', dw_more_1: 'For every DNS server of a line ASN Manager sets a routing rule, so the lookup of the router really goes through that line. If a VPN is down, its lookups are blocked instead of going over WAN.', dw_more_2: 'DNS servers: for WAN the ones set in the router under WAN; for a VPN the DNS of the provider you enter here, otherwise a free public one through the tunnel. Do not enter the DNS in the VPN client of the router - the router would then send the lookups past AdGuard Home. The same DNS of a provider can be entered for several of its VPN lines - each line asks its own server at the end of its tunnel.', dw_more_3: 'Sites of ASN Manager: domain entries for all devices and the names seen for your ASN entries (needs suggestions by domain). Entries for single devices are left out - DNS is the same for all devices.', dw_more_4: 'Every device: AdGuard Home gets one client per device of the VPN Director, named "<device> (ASNM <line>)". Your filters stay, other clients are not touched, a backup is made before every change.', dw_more_5: 'Encryption: with Unbound it forwards the WAN names over TLS (port 853); without Unbound the normal DNS usually goes over WAN anyway - turn on DNS over TLS in the router (WAN > DNS Privacy Protocol) or use dnscrypt-proxy (DoH / DNSCrypt) behind dnsmasq.', dw_more_6: 'Turning a switch off removes everything it set up again.', dnst_title: 'Encrypted DNS for WAN', dnst_desc: 'The lookups that go over WAN are sent encrypted (DNS over TLS, port 853) - your provider no longer sees which names you look up. With Unbound it does this for the names, AdGuard Home for the devices on WAN. Without Unbound the normal DNS usually goes over WAN anyway - then the firmware encrypts it (WAN > DNS Privacy Protocol > DNS-over-TLS). Lookups through a VPN are encrypted by the tunnel anyway.', dnst_on: '{t}: encrypted (DNS over TLS)', dnst_agh: '{t}: encrypted for devices only (no Unbound for the names)', dnst_noubc: '{t}: encrypted for devices only - unbound-control does not answer (see dnsfollow status)', dnst_nofw: '{t}: encrypted for devices only - for the names the DNS over TLS of the firmware cannot be used here', dnst_b_tunnel: 'Normal DNS ({b}): encrypted by the VPN tunnel', dnst_b_fw: 'Normal DNS ({b}): encrypted by the firmware (DNS over TLS)', dnst_b_ub: 'Normal DNS ({b}): Unbound asks the name servers itself - not encrypted', dnst_b_plain: 'Normal DNS ({b}): NOT encrypted - turn on WAN > Internet Connection > DNS Privacy Protocol > DNS-over-TLS', dnst_unknown: '{t}: not encrypted - no TLS name known for its DNS server (set a known one, e.g. 9.9.9.11)', dnsd_title: 'DNS per device (AdGuard Home)', dnsd_desc: 'Every device also gets the DNS of the target the VPN Director sends it to (devices not in the VPN Director: WAN). AdGuard Home gets a client "ASNM <target>" per target; local names and the domains of ASN Manager still go to dnsmasq, filters stay as they are. AdGuard Home is restarted when the VPN Director or the domain entries change.', dnsd_row: 'Devices on {t} (VPN Director, {n}): DNS {s}', dnsd_rest: 'Other devices ({l}): WAN, DNS {s}', dnsd_normal: 'as before (normal DNS)', dnsd_confirm: 'Turn on "DNS per device"? ASN Manager writes clients "... (ASNM ...)" into the AdGuard Home configuration (a backup is kept) and restarts AdGuard Home - DNS stops for a few seconds. "DNS follows the route" is turned on as well.', dnsd_confirm_off: 'Turn off "DNS per device"? The "... (ASNM ...)" clients are removed from AdGuard Home and AdGuard Home is restarted.', dnsf_title: 'DNS follows the route', dnsf_sub: 'Look up a name through the same way it is routed', dnsf_desc: 'Names routed to another target than your normal DNS are also looked up through that target - e.g. a site on WAN asks a DNS server over WAN, so IP address and DNS fit together. Covers domain entries (for all devices) and the names learned for ASN entries (needs "suggestions by domain"). Your normal DNS stays as it is.', dnsf_off: 'Off', dnsf_on: 'On', dnsf_base: 'Normal DNS: {m} via {b} (unchanged)', dnsf_row: '{t}: DNS {s} - {d} domain entries, {l} learned names', dnsf_none: 'No names to another target yet.', dnsf_confirm: 'Turn on "DNS follows the route"? dnsmasq is restarted once. Turning it off removes everything again.', act_pedit: 'Own preset', oe_open: 'Edit own presets', oe_new: '+ New preset', oe_del: 'Delete', oe_name: 'Name', oe_items: 'ASNs and domains', oe_items_help: 'One per line (or separated by spaces). A domain covers all its subdomains; ASNs as 13335 or AS13335.', oe_file: 'Save in', oe_wide: 'whole cloud / CDN network (⚠)', oe_save: 'Save', oe_usb: 'USB device {n}', oe_jffs: 'Router (/jffs)', oe_count: '{n} entries', oe_count1: '1 entry', oe_need_name: 'Please enter a name.', oe_need_items: 'Please enter at least one ASN or domain.', oe_bad: 'These are neither an ASN nor a domain and are left out:\n{l}\n\nSave anyway?', oe_c_del: 'Delete the own preset "{n}" ({f})?', own_title: 'Own presets', own_sub: 'Download as a .txt file to share, or add a presets file from someone else.', own_dl: 'Download presets', own_add: 'Add presets', own_replace: 'replace instead of adding', own_count: '{n} own preset(s) (★).', own_none: 'No own presets yet.', own_bad_file: 'The file holds no preset lines (category|Name|ASNs and domains|).', own_c_add: 'Add {n} preset(s)? Lines with the same category and name replace the earlier ones. {b} line(s) are skipped (wrong form).', own_c_replace: 'Replace your own presets on the router with {n} preset(s)? {b} line(s) are skipped (wrong form). A presets.txt on a USB device stays as it is.', own_help: 'The file holds one preset per line: category|Name|ASNs and domains| (wide at the end for a whole cloud / CDN network), e.g. stream|My service|example.com cdn.example.net|. Categories: stream, tvde, news, gaming, social, work, shop, bank, services, smarthome, updates, cloud, test. Added presets are kept in /jffs/addons/asnmanager/presets.txt; the download holds all own presets, also those from a USB device.', preset_cat: 'Category', preset_on: 'already on the list -> {t}', preset_have: '{n} of {m} already on the list (highlighted) - adding them again moves them to the chosen target', preset_own_s: 'own', preset_own: 'Your own preset (presets.txt on the router / USB device)', pcat_stream: 'Streaming', pcat_tvde: 'TV & media libraries (DE / AT / CH)', pcat_news: 'News', pcat_bank: 'Banks (DE)', pcat_services: 'Services (DE)', pcat_smarthome: 'Smart home & IoT', pcat_updates: 'Updates & downloads', pcat_gaming: 'Gaming', pcat_social: 'Social & messaging', pcat_work: 'Tools & work', pcat_shop: 'Shopping & payment', pcat_cloud: 'Cloud & CDN (whole networks)', pcat_test: 'Tests & IP check', preset_legend: 'A preset adds ASNs and / or domains (a domain covers every subdomain). ⚠ = cloud, CDN or hosting: a large share of the internet runs through these networks, routing them moves far more than this one service.', preset_wide: '"{n}": a large share of the internet runs through these networks (cloud / CDN / hosting).\nRouting them moves the traffic of many other services and websites as well - not only this one.\n\nAdd anyway?', tool_done: '{a}: done - see the result below', tool_failed: '{a}: failed - see the output below', act_test: 'Test route', act_trace: 'Traceroute', act_ifaces: 'Public IPs', act_status: 'ipset status', act_lookup: 'Look-up', act_sghide: 'Hide suggestion', sg_hide: 'Hide this suggestion', sg_unhide: 'Show this suggestion again', sg_showhid: 'Show hidden ({n})',
    tab_asns: 'ASNs', tab_traffic: 'Traffic', tab_targets: 'Targets & failover', tab_diag: 'Diagnostics', tab_settings: 'Settings',
    sub_manual: 'Enter ASNs', sub_lookup: 'Find by domain / IP', sub_presets: 'Service presets', rc_to_list: 'Show ASN list',
    sp_th: 'Speed test', sp_btn: 'Test', sp_running: 'Speed test running - about 30 seconds...',
    sp_confirm: 'Run a speed test through {i}?\nIt takes about 30 seconds and uses up to ~200 MB download and ~100 MB upload (sent through this interface).',
    sp_ping: 'ping {l} ms', sp_err_offline: 'offline', sp_err_noaddr: 'no address', sp_err_route: 'no usable route', sp_err_rule: 'no routing rule', sp_err_fail: 'no data (no internet?)',
    act_speedtest: 'Speed test',
    bk_preparing: 'Preparing the backup...', bk_failed: 'The backup could not be prepared - please try again.',
    bk_fallback: 'The router did not deliver the full backup - a basic backup was saved (ASN list, schedule, failover chains, statistics settings). If the script on the router is older than this page, please update it (SSH menu, update).',
    rs_title: 'What do you want to restore?', rs_asn: 'ASN list ({n} entries)', rs_replace: 'Replace the current list', rs_merge: 'Merge into the current list',
    rs_sched: 'Auto-refresh schedule (every {i} day(s) at {t})', rs_fo: 'Failover chains ({n}; chains that are not in the backup are removed)', rs_set: 'Settings',
    rs_s_stats: 'Traffic statistics', rs_s_saving: 'USB saving', rs_s_loc: 'WebUI tab', rs_loc_vpn: 'VPN menu', rs_loc_addons: 'Addons menu',
    rs_run: 'Restore selected', rs_nosel: 'Nothing selected.',
    pr_on: 'on', pr_off: 'off',
    disp_title: 'Display', disp_sub: 'Applies to the whole page in this browser', disp_unit: 'Unit for data rates',
    disp_unit_desc: 'Used for the live throughput, the speed test and the summaries. 1 MB/s = 8 Mbit/s. Data amounts (for example 1.2 GB) are not affected.',
    disp_change: 'Change unit',
    perf_title: 'Performance', perf_sub: 'Reduce the CPU load of the router',
    perf_rules: 'Marking rules', perf_rules_desc: 'Combined: all ASNs of a target share one set and one rule, so the router checks each packet only once per target (far less CPU with many ASNs). One per ASN: the old way, for comparison or if something behaves differently.',
    perf_rules_comb: 'Combined (fast)', perf_rules_single: 'One per ASN',
    perf_rules_confirm: 'Switch the marking rules to "{m}" and rebuild the rules now? (a few seconds, the saved ASN lists are used)',
    perf_stats: 'Traffic statistics', perf_stats_desc: 'Per ASN: every ASN is counted separately (one counting rule per ASN). Per interface: only per interface and device are counted - almost no CPU load, but no ASN breakdown.',
    perf_stats_asn: 'Per ASN (exact)', perf_stats_iface: 'Per interface (light)',
    tr_all: 'All traffic', tr_mode_iface: 'Counting per interface and device only (no ASN breakdown) - saves CPU.', tr_mode_change: 'Change',
    rs_s_smode: 'Statistics detail', rs_s_rules: 'Marking rules', rs_v_asn: 'per ASN', rs_v_iface: 'per interface', rs_v_comb: 'combined', rs_v_single: 'one per ASN',
    back_router: '← Network Map', add_entries: 'Entries', kind_ip: 'IP', kind_dom: 'Domain', st_learned: '{n} learned', lr_tip: 'Show the learned addresses', lr_head: 'Addresses learned for *.{d}', lr_more: '... and {n} more (all of them: ASNmanager.sh custom learned {id})', lr_none: 'No address learned yet.', lr_note: 'dnsmasq only stores the addresses, not which subdomain they belong to. An address is removed 7 days after its last lookup; the addresses are saved and put back after a router restart.',
    add_domnote: 'A domain also covers all its subdomains. It only works for devices that use the router as their DNS server (not with DoH or fixed DNS servers; IPv4 only). The router learns the addresses when a device looks the name up.',
    rc_nolearned: 'none learned', rc_tip_nolearned: 'No address has been learned for this domain yet. A device has to look the name up through the router\'s DNS server (dnsmasq). Not covered: devices with another DNS server or DoH, and names that an AdGuard Home in front answers without passing through dnsmasq.',
    lang_label: 'Language', lang_default: 'Default', lang_en: 'English', theme_label: 'Theme', theme_dark: 'Dark', theme_light: 'Light', theme_blue: 'Blue',
    stat_asns: 'ASNs', stat_more: '+ {i} IP · {d} domains',
    note_ph: 'Note, e.g. ZDF Mediathek', note_lbl: 'Note', add_note_lbl: 'Note (optional)', add_s1: 'Route', add_s2: 'via', add_s3: 'for', add_note_ph: 'optional, e.g. ZDF Mediathek', add_src_type: 'type IP addresses', add_src_hide: 'hide IP field', add_note_help: 'Shown under the entry - with several entries in one go, under each of them',
    c_clear_type: 'Remove ALL entries ({a} ASNs, {i} IP ranges, {d} domains) from the list?\nActive routing stays until you click "Apply rules".\n\nType {w} to confirm:', clear_word: 'DELETE', clear_wrong: 'Not removed - the word did not match.',
    dns_lbl: 'DNS / DHCP', dns_ok: 'dnsmasq OK', dns_ok_agh: 'dnsmasq OK (port {port}, behind {p})', dns_other: '{p} answers DNS instead of dnsmasq', dns_other_long: '{p} answers DNS (and DHCP) instead of dnsmasq. The devices are fine, but the domain entries learn nothing unless {p} fills the ipset sets of the dnsmasq ipset= lines. IP and ASN entries are not affected.', dns_dhcp_ok: 'DHCP OK', dns_dhcp_off: 'DHCP off in the router',
    sched_err: 'the cron job is missing - the subnets are not refreshed (apply the rules once)',
    dns_agh: '{p} bypasses dnsmasq (asks {up})', dns_mirror: '{p} fills the domain sets itself',
    dns_agh_long: '{p} sends the lookups straight to {up} instead of dnsmasq (port {port}). DNS works, but the domain entries learn (almost) nothing and the suggestions by domain stay empty. Fix: in {p} -> Settings -> DNS settings -> Upstream DNS servers, replace {up} with 127.0.0.1:{port} (dnsmasq passes the lookups on to the same server).',
    dns_agh_partly_long: '{p} shares the lookups between dnsmasq (port {port}) and {up}. DNS works, but the domain entries learn only the addresses of the lookups that happen to go through dnsmasq. Fix: in {p} -> Settings -> DNS settings -> Upstream DNS servers, keep only 127.0.0.1:{port} (dnsmasq passes the lookups on to {up}).',
    dns_bad_nodnsmasq: 'dnsmasq is not running: devices get no new addresses (DHCP) and the domain entries learn nothing. Fix (SSH): service restart_dnsmasq - with AdGuard Home in front: /opt/etc/init.d/S99AdGuardHome restart',
    dns_bad_no53: 'Nothing answers DNS on port 53 (dnsmasq runs on port {port}). Is AdGuard Home stopped? Fix (SSH): /opt/etc/init.d/S99AdGuardHome restart',
    dns_bad_nodhcp: 'DHCP is on in the router, but nothing answers (port 67): devices get no new addresses. Fix (SSH): service restart_dnsmasq',
    dns_checked: 'checked {t}', stat_subnets: 'Subnets', stat_ifaces: 'Interfaces online', stat_last: 'Last applied',
    card_add_sub: 'Route an Autonomous System, an IP range or a domain through a WAN or VPN interface', card_list_sub: 'Click a group to expand or collapse it',
    status: 'Status', version: 'Version', last_applied: 'Rules last applied', auto_refresh: 'Auto-refresh of subnets', actions: 'Actions',
    btn_apply: 'Apply rules', btn_full: 'Reload all subnets', btn_full_tip: 'Download the subnets of every ASN again and rebuild all rules (the daily schedule does this anyway)', btn_reload: 'Reload data', btn_retry: 'Retry failed',
    add_asns: 'Add ASNs, IPs or domains', asns: 'ASN(s)', target: 'Target interface', src_ip: 'Source device IP', src_empty: 'empty = all devices',
    btn_add: 'Add', presets: 'Service presets', preset: 'Preset', btn_add_preset: 'Add preset',
    lookup_title: 'Find ASN for a domain or IP', domain_ip: 'Domain / IP', btn_lookup: 'Look up', th_ip: 'IP', th_holder: 'Owner',
    btn_take: 'Add to form', btn_take_all: 'Add all to form', in_list: 'in list: {d}', lookup_err: 'lookup failed', lookup_running: 'Looking up...',
    th_pubip: 'External IP', btn_pubip_refresh: 'Refresh IPs', pubip_loading: 'checking...', pubip_none: '-',
    expand_all: 'expand all', collapse_all: 'collapse all', group_sum: '{n} ASN(s), {s} subnets', group_failed: '{f} failed', group_rc: '{n} routing error(s)',
    list_title: 'ASN list', btn_remove_sel: 'Remove selected', btn_remove_all: 'Remove all',
    ls_asn: 'ASNs', ls_ip: 'IP / CIDR ranges', ls_dom: 'Domains', ls_th_asn: 'ASN', ls_th_ip: 'IP / range', ls_th_dom: 'Domain', ls_th_learned: 'Learned',
    ls_empty_asn: 'No ASNs configured yet.', ls_empty_ip: 'No IP addresses or ranges yet - add them like ASNs, e.g. 181.209.202.0/24.', ls_empty_dom: 'No domains yet - add them like ASNs, e.g. *.googlevideo.com.',
    ls_gsum_asn: '{n} ASN(s), {s} subnets', ls_gsum_ip: '{n} range(s)', ls_gsum_dom: '{n} domain(s), {l} addresses learned',
    th_asn: 'ASN', th_src: 'Source device', th_subnets: 'Subnets', th_state: 'State', th_target: 'Target', th_device: 'Device', th_asns: 'ASNs',
    ifaces_title: 'Target interfaces', schedule_title: 'Auto-refresh schedule', refresh_every: 'Refresh every', days: 'day(s)', days_range: '(1-30)',
    at_time: 'At time', time_fmt: '(HH:MM, 24h)', btn_save_schedule: 'Save schedule',
    diag_title: 'Diagnostics', btn_test: 'Test route', btn_trace: 'Traceroute', router_checks: 'Router checks',
    btn_explain: 'Explain', explain_help: 'Explain: what DNS answers, which entries contain each address, which rule wins (for the device chosen below) and which interface the traffic leaves through.',
    diag_dev: 'Device', diag_dev_any: '- any device -', btn_device: 'Check device', a_dev: 'Please choose a device.',
    diag_dev_help: 'Check device: the rules for this device, its normal way (VPN Director) and its current connections with name, traffic, rule and interface.',
    btn_dnschain: 'Check DNS chain', act_explain: 'Explain', act_device: 'Check device', act_dnschain: 'DNS chain', act_diagpack: 'Diagnostic bundle',
    dp_title: 'Diagnostic bundle', dp_sub: 'Everything needed to analyse a problem, in one text file',
    dp_text: 'Collects version, entries, settings, DNS chain, routing check, ip rules, routing tables, marking rules, set sizes, VPN Director and the last messages of ASN Manager in the system log. Masked: public IP addresses, VPN servers and tunnel addresses, MAC addresses, IPv6 addresses and keys; notes and VPN Director descriptions are left out, and the domains of your entries become domain-01.de, domain-02.com ... (the same name everywhere in the file). Left in: local addresses (192.168.x.x), ASN numbers and the router model. Please look over the file before you share it. To report a problem: download it and attach it to a new issue on GitHub (drag it into the text field).',
    dp_full: 'Domains in clear text (only if a domain rule is the problem)',
    btn_dp: 'Create bundle', dp_missing: 'The bundle was not found on the router - please create it again.', dp_download: 'Download', dp_github: 'Report on GitHub',
    dp_issue_title: 'Problem: ', dp_issue_body: 'ASN Manager v{v}\n\nWhat does not work / what did you expect?\n\n\nPlease attach the diagnostic bundle ({f}) here: drag the file into this text field.',
    btn_devices: 'Devices & DNS', act_devices: 'Devices & DNS', btn_ipset: 'ipset status', btn_pubip: 'Public IPs', output_default: 'Output of apply, tests and checks appears here.',
    backup_title: 'Backup & restore', backup_export: 'Export', backup_export_desc: 'Download the list (ASNs, IP ranges, domains, notes), schedule, failover chains and settings as .conf file',
    btn_export: 'Download backup', backup_import: 'Import', backup_import_desc: 'You choose what is restored. Compatible with backups from the terminal menu',
    btn_import: 'Choose file...', import_found: '{n} valid entries found in {file}{bad}.', import_bad: ', {n} invalid lines ignored',
    import_sched: ' Schedule: every {i} day(s) at {t}.', btn_replace: 'Replace list', btn_merge: 'Merge into list', btn_cancel: 'Cancel',
    import_none: 'No valid ASN entries found in this file.',
    st_active: 'active', st_down: 'loaded, interface down', st_not_applied: 'not applied', st_failed: 'failed - 0 subnets', st_new: 'new - not applied yet',
    online: 'online', offline: 'offline', not_configured: 'not configured', all_devices: 'all devices', never: 'never',
    every: 'Every {n} day(s) at {t}', cron_on: '(cron active)', cron_off: '(cron not active - apply rules once)',
    btn_edit: 'Edit', btn_remove: 'Remove', btn_save: 'Save',
    pick_device: '- select device -', no_asns: 'No ASNs configured yet.', summary: '{n} ASN(s), {s} subnets loaded',
    hint_multi: 'ASN, IP / CIDR range (/8 to /32) or domain - several: separated by commas', hint_formats: '<b>ASN</b> <span class="asnm-ex">AS13335</span> or <span class="asnm-ex">13335</span> &middot; <b>IP</b> <span class="asnm-ex">1.2.3.4</span> &middot; <b>range</b> <span class="asnm-ex">181.209.202.0/24</span> (/8 to /32) &middot; <b>domain</b> <span class="asnm-ex">googlevideo.com</span> - covers every subdomain, no <span class="asnm-ex">*.</span> needed &middot; several: separated by commas or spaces', hint_optional: 'optional',
    ph_asns: 'e.g. AS13335, 1.2.3.4, 181.209.202.0/24, googlevideo.com', ph_ip: 'e.g. 192.168.1.50 or 192.168.1.50,192.168.1.60', ph_domain: 'e.g. netflix.com', ph_diag: 'e.g. one.one.one.one',
    working: 'Working...', applying: 'Applying rules - from the saved subnets, only new ASNs are downloaded...', reloading: 'Downloading the subnets of all ASNs - this can take a few minutes...', retrying: 'Rebuilding from cache, downloading only failed ASNs...',
    progress: 'AS{asn} -> {dest}  ({d} of {t})', running_x: 'Running {a}...',
    timeout: 'No answer from the router (timeout). Check that the service-event hook is installed.',
    no_data: 'No data from router. Is ASN Manager installed?', parse_err: 'Could not read data from router.',
    done: 'Done.', failed: 'Failed.', no_output: '(no output)',
    c_apply: 'Fetch current subnets for all ASNs and rebuild the routing rules now?', c_full: 'Download the subnets of all ASNs again and rebuild every rule? This takes a few minutes; "Apply rules" is enough for normal changes.',
    c_remove_one: 'Remove {asn} from the list?', c_remove_n: 'Remove {n} entries from the list?',
    c_clear: 'Remove ALL ASNs from the list?\nActive routing stays until you click "Apply rules".',
    c_replace: 'Replace the current list ({n} entries) with {m} entries from the backup?',
    a_asns: 'Please enter ASNs, IP/CIDR ranges (/8 to /32) or domains, e.g. AS13335, 181.209.202.0/24, *.googlevideo.com', a_ip: 'Source IP must be an IPv4 address or empty.',
    a_nothing: 'Nothing selected.', a_interval: 'Interval must be between 1 and 30 days.', a_time: 'Time must be HH:MM (24h).',
    a_host: 'Please enter a valid domain or IPv4 address.', footer: 'ASN Manager for Asuswrt-Merlin'
  },
  de: {
    subtitle: 'Leitet komplette Autonome Systeme über WAN, OpenVPN oder WireGuard.',
    data_refreshed: 'Daten aktualisiert:',
    banner_pending: 'Die ASN-Liste wurde seit dem letzten Anwenden geändert. Klicke auf <b>Regeln anwenden</b>, um die Änderungen zu aktivieren.',
    banner_failed: '{n} ASN(s) konnten nicht geladen werden (0 Subnetze). Sie sind unten rot markiert - nutze <b>Fehlgeschlagene wiederholen</b>.',
    traffic_title: 'Traffic pro ASN', tr_sub_on: 'Zählung seit {t}', tr_sub_off: 'Zählung ist aus', tr_sub_none: 'Statistik-Modul nicht installiert',
    tr_on: 'aktiv', tr_off: 'aus', tr_btn_disable: 'Deaktivieren', tr_btn_reset: 'Deaktivieren und zurücksetzen', tr_btn_enable: 'Aktivieren',
    tr_th_name: 'ASN / Ziel', tr_th_down: 'Download', tr_th_up: 'Upload', tr_th_pk: 'Pakete', tr_th_share: 'Anteil', tr_show: 'Details anzeigen', tr_hide: 'Details ausblenden', tr_sum: 'Gesamt {b} · {n} ASN(s)', tr_toggle_tip: 'Klicken zum Auf- oder Zuklappen', tr_th_share_tip: 'Anteil am Gesamt-Traffic. In aufgeklappten Zeilen: Anteil der übergeordneten Zeile.',
    tr_hint: 'Zeile anklicken, um die Interfaces und Geräte dahinter zu sehen', tr_dev_1: '1 Gerät', tr_dev_n: '{n} Geräte',
    tr_other: 'Ohne Regel (normaler Weg)', tr_by_iface: 'Nach Interface', tr_by_client: 'Nach Client (alle Interfaces)', tr_unknown: 'Sonstige Adressen (ohne eigene Zählregel)', tr_unknown_hint: 'Traffic von IP-Adressen ohne eigene Zählregel, z. B. ein Gerät, das sich gerade erst verbunden hat oder hinter einem anderen Router hängt. Anzeige auf dem Router mit: asnstats.sh unknown', tr_total: 'Gesamt', tr_split_asn: 'Über Regeln', tr_split_other: 'Ohne Regel',
    tr_no_clients: 'Noch kein Client-Traffic', tr_empty: 'Noch kein Traffic gezählt.', tr_off_hint: 'Die Zählung ist aus. Mit "Aktivieren" starten.',
    tr_gone: 'aus Liste entfernt', tr_c_reset: 'Zählung deaktivieren und alle Statistikdaten löschen?', tr_working: 'Wird umgesetzt...',
    tr_note: 'Nur IPv4 und weitergeleiteter Traffic (ohne Router-Eigenverkehr). Aktualisiert alle {s} s.', tr_saved_usb: 'Die Zählstände überleben einen Neustart - stündlich gesichert auf dem USB-Gerät: {p} (letzte Änderung: {t})', tr_no_usb: 'Kein USB-Gerät gefunden - die Zahlen liegen nur im Arbeitsspeicher und gehen bei einem Neustart verloren. USB-Gerät anschließen (Ordner ASNmanager) oder die Sicherung ausschalten.',
    tr_broken: 'Die Zählung läuft nicht richtig ({why}). Live-Werte, neue Geräte und Vorschläge werden nicht aktualisiert.', tr_why_loop: 'Hintergrundprozess gestoppt', tr_why_rules: 'Zähl-Regeln fehlen',
    tr_repair: 'Reparieren', tr_repairing: 'Reparatur läuft - die Zahlen bleiben erhalten...',
    tr_save_off: 'Die Sicherung auf dem USB-Gerät ist ausgeschaltet - die Zahlen liegen nur im Arbeitsspeicher und beginnen nach einem Neustart von vorn.', tr_save_turn_off: 'Sicherung ausschalten', tr_save_turn_on: 'Sicherung einschalten',
    tr_save_confirm: 'Sicherung auf dem USB-Gerät ausschalten?\nDie Zahlen liegen dann nur im Arbeitsspeicher und beginnen nach einem Neustart von vorn. Auf das USB-Gerät wird nichts mehr geschrieben.', net_lan: 'LAN / WLAN', net_g24: 'Gast 2,4 GHz', net_g5: 'Gast 5 GHz', net_g6: 'Gast 6 GHz', net_wgs: 'WireGuard-Server', net_ovs: 'OpenVPN-Server', tr_timeout: 'Keine Antwort vom Statistik-Modul. Wenn das wiederholt auftritt: auf dem Router per SSH "/jffs/scripts/ASNmanager.sh stats diag" ausführen.',
    dev_lan: 'LAN- / WLAN-Geräte', dev_wg: 'WireGuard-Server-Peers', dev_ovpn: 'OpenVPN-Server-Clients', wg_peer: 'WireGuard-Peer', ovpn_client: 'OpenVPN-Client',
    upd_label: 'Update', upd_check: 'Nach Updates suchen', upd_checking: 'GitHub wird geprüft...', upd_current: 'Aktuell (v{v})', upd_checked: 'geprüft {t}',
    upd_available: 'v{r} verfügbar', upd_error: 'GitHub nicht erreichbar', upd_install: 'Jetzt aktualisieren', upd_notes: 'Was ist neu?', upd_running: 'Update läuft - bitte warten, danach lädt die Seite neu...',
    banner_update: 'Neue Version verfügbar: ASN Manager v{r} (installiert: v{l}).',
    upd_confirm: 'ASN Manager v{r} jetzt installieren?\nDanach lädt die Seite neu. ASN-Liste, Zeitplan und Statistik bleiben erhalten.',
    rc_title: 'Routing-Prüfung', rc_now: 'Jetzt prüfen', rc_checking: 'Wird geprüft...', rc_summary: '{ok} OK · {warn} Warnungen · {fail} Fehler', rc_checked: 'geprüft {t}',
    rc_none: 'keine ASNs', rc_th: 'Routing', rc_down: 'offline', rc_noroute: 'keine Route', rc_norule: 'nicht aktiv', rc_nosub: 'keine Subnetze',
    rc_tip_ok: 'Beispiel-Adresse {ip} geht wie geplant über {dev}.', rc_tip_wrong: 'Beispiel-Adresse {ip} geht über {got} statt über {dev}!',
    rc_tip_down: 'Ziel-Interface {dev} ist offline.', rc_tip_noroute: 'Für {ip} wurde keine Route gefunden.', rc_tip_norule: 'Die Regel ist nicht aktiv - "Regeln anwenden" klicken.',
    rc_tip_nosub: 'Für dieses ASN sind keine Subnetze geladen.', rc_tip_seen: 'Verkehr über {dev} seit der vorherigen Prüfung: {b}',
    banner_rc: 'Nicht wie geplant geroutet ({n}):',
    tr_live: 'Live', tr_live_tip: 'Aktueller Durchsatz, gemessen über die letzten ~{s} s', tr_live_off: 'nur bei aktiver Zählung', tr_live_wait: 'wird gemessen...',
    sg_title: 'Vorschläge: häufigste Ziele ohne Regel', sg_since: 'gesammelt seit {t}', sg_off: 'Vorschläge benötigen eine aktive Zählung.',
    sg_wait: 'Daten werden gesammelt - die erste Auswertung erscheint nach etwa einer Minute.', sg_empty: 'Noch keine Ziele ohne Regel gefunden.',
    sg_pending: '{n} Ziel-Adresse(n) mit {b} Traffic werden noch zugeordnet...', sg_fails: 'Zuordnung für {n} Netz(e) fehlgeschlagen (ip-api.com, ipinfo.io und RIPEstat vom Router aus nicht erreichbar?) - neuer Versuch nach einer Stunde.',
    sg_on_list: 'auf der Liste für: {d} ({t}) - Hinzufügen ergänzt die Geräte dieser Regel', sg_noacct: 'Die Byte-Zähler für Verbindungen ließen sich nicht einschalten - keine Vorschläge möglich.',
    sg_th_asn: 'ASN', sg_th_b: 'Traffic', sg_th_cl: 'Genutzt von', sg_th_t: 'Ziel', sg_th_dev: 'Gerät', sg_all: 'Alle Geräte', sg_grp_used: 'Nutzt dieses ASN', sg_add: 'Hinzufügen', sg_more: '+{n} weitere', sg_less: 'weniger anzeigen',
    sgv_label: 'Ansicht', sgv_asn: 'nach ASN', sgv_dom: 'nach Domain', sgd_th_dom: 'Domain', sgd_f_q: 'Domain suchen', sgd_subs_more: '+{n} weitere',
    sgd_off_text: 'Vorschläge nach Domain sind aus. Eingeschaltet schreibt dnsmasq jede beantwortete Anfrage in eine Datei im Arbeitsspeicher des Routers. ASN Manager liest sie jede Minute, merkt sich, welcher Name zu welcher Adresse gehört, und leert die Datei wieder - es wird nichts in den Flash-Speicher geschrieben und nichts im Internet abgefragt. Ein- und Ausschalten startet dnsmasq einmal neu (DNS pausiert ein paar Sekunden).',
    sgd_turn_on: 'Vorschläge nach Domain einschalten', sgd_turn_off: 'Vorschläge nach Domain ausschalten',
    sgd_off_confirm: 'Vorschläge nach Domain ausschalten?\ndnsmasq wird einmal neu gestartet, die gesammelten Namen werden gelöscht.',
    sgd_empty: 'Noch keine Namen gesammelt - Domains erscheinen etwa eine Minute, nachdem ein Gerät sie abgefragt hat.',
    sgd_none: '{b} Traffic (seit Beginn der Sammlung) gingen an {n} Adresse(n) ohne bekannten Namen (abgefragt, bevor die Vorschläge nach Domain eingeschaltet waren, aus einem Zwischenspeicher beantwortet oder nicht über den Router - z. B. "Sicheres DNS" im Browser).',
    sgd_amb: '{b} über geteilte Server - auch: {d}', sgd_amb_tip: 'Diese Server haben auch Anfragen für andere Domains beantwortet (CDN). Der Traffic ist dieser Domain zugeordnet, weil sie zuletzt abgefragt wurde - er kann auch zu einer der anderen gehören.',
    sgd_none_show: 'Die größten anzeigen', sgd_none_hide: 'Ausblenden', sgd_none_ip: 'Adresse', sgd_none_net: 'Netz', sgd_none_dev: 'Am meisten genutzt von',
    sgd_none_tip: 'Ein Gerät mit viel Traffic hier fragt wahrscheinlich einen eigenen DNS-Server (z. B. 8.8.8.8 bei vielen TV-Sticks, "Privates DNS" bei Android, "Sicheres DNS" in Chrome / Firefox). Traffic, der gezählt wurde, bevor die Vorschläge nach Domain eingeschaltet waren, hat ebenfalls keine Namen - er verschwindet mit der Zeit aus dieser Liste.',
    sgd_ext: 'Gelesen wird das Abfrage-Protokoll eines anderen Add-ons (z. B. Diversion), dnsmasq bleibt unverändert.',
    sgd_note: 'Namen aus den Anfragen, die dnsmasq beantwortet hat (und aus dem Abfrageprotokoll von AdGuard Home, das in Schüben geschrieben wird), jede Minute ausgewertet. Vorgeschlagen wird die Hauptdomain (zdf.de) - sie deckt alle Unterdomains ab; darunter die abgefragten Namen. Große Netze (CDNs) liefern viele Namen von einer Adresse: es zählt die letzte Abfrage. Domains und ASNs, die schon in der Liste stehen, sind ausgeblendet. "Hinzufügen" setzt die Domain auf die Liste - danach die Regeln anwenden.',
    sg_note: 'Schätzung aus der Verbindungstabelle des Routers, jede Minute ausgewertet (sehr kurze Verbindungen können fehlen). Die Ziel-Adressen werden über ip-api.com zugeordnet (höchstens 10 pro Minute). ASNs, die schon in der Liste stehen, sind ausgeblendet. "Hinzufügen" setzt das ASN auf die Liste - danach die Regeln anwenden.',
    sec_tbl: 'Traffic nach ASN / Ziel', sec_cnt: '{n} Einträge', sg_f_show: 'Anzeigen', sg_f_dev: 'Gerät', sg_f_q: 'ASN oder Name suchen',
    sg_f_count: '{x} von {y} ASN(s)', sgd_f_count: '{x} von {y} Domain(s)', sgd_nomatch: 'Keine Domain passt zum Filter.', sg_f_total: ' - insgesamt {n} gefunden, die 100 größten sind aufgeführt', sg_n_dev: '{n} Geräte', sg_nomatch: 'Kein ASN passt zum Filter.',
    sg_all_dev_f: 'Alle Geräte', sg_th_b_dev: 'Traffic dieses Geräts',
    fo_title: 'Ausweich-Ziele (Failover)', fo_sub: 'Fällt ein Ziel aus, nutzen seine ASNs das nächste funktionierende Ausweich-Ziel.', fo_th_t: 'Ziel', fo_th_1: '1. Ausweich', fo_th_2: '2. Ausweich',
    fo_th_state: 'Zustand', fo_none: '- keines -', fo_block_opt: 'Sperren (Kill-Switch)', fo_block_s: 'Sperren', fo_save: 'Speichern', fo_off: 'kein Ausweich',
    fo_pending: 'wird geprüft...', fo_ok: 'über {i}', fo_via: 'ausgefallen - über {i}', fo_blocked: 'ausgefallen - gesperrt', fo_since: 'seit {t}',
    fo_dup: 'Bitte zwei verschiedene Ausweich-Ziele wählen.', fo_blocklast: '"Sperren" kann nur das letzte Ausweich-Ziel sein.', fo_noasn: 'Noch keine ASNs in der Liste.',
    fo_note: 'Geprüft alle {s} s per Ping über das Interface. Ein Ziel gilt nach 2 Fehlschlägen hintereinander als ausgefallen und nach 2 Erfolgen wieder als verfügbar, dann kehren seine ASNs automatisch zurück. Funktioniert kein Glied der Kette, bleibt der Verkehr auf dem Ziel - ist dessen VPN-Client gestoppt, kann das WAN bedeuten. Mit "Sperren" als letztem Ausweich-Ziel lässt sich das verhindern.',
    rc_tip_fo: 'Ziel {dev} ist ausgefallen - Ausweich: Beispiel-Adresse {ip} geht über {got}.', rc_blocked: 'gesperrt', rc_tip_blocked: 'Ziel {d} ist ausgefallen - der Verkehr ist gesperrt (Ausweich "Sperren").',
    job_busy: 'Es läuft noch ein anderer Auftrag ({a}). Die Seite zeigt ihn an, bis er fertig ist - danach bitte deine Aktion wiederholen.',
    job_running: 'Ein vorher gestarteter Auftrag läuft noch ({a}) - die Seite zeigt ihn an, bis er fertig ist.',
    act_apply: 'Regeln anwenden', act_reload: 'Alle Subnetze neu laden', act_retry: 'Fehlgeschlagene wiederholen', act_update: 'Update', act_import: 'Wiederherstellen', act_add: 'Einträge hinzufügen', act_preset: 'Vorlage hinzufügen',
    fo_vd: 'VPN Director folgt dem Failover', fo_vd_desc: 'Fällt eine Leitung aus, gehen auch die Geräte, die der VPN Director über sie schickt (und der Router selbst, z. B. Unbound), über die Ausweich-Leitung - mit deren DNS. Die Liste des VPN Directors bleibt unverändert; läuft die Leitung wieder, ist alles wie vorher. Aus: nur die Einträge von ASN Manager folgen dem Failover, um seine Geräte kümmert sich der VPN Director selbst (Kill Switch oder WAN).', fo_vd_n: '+ {n} VPN-Director-Regel(n)', fo_vd_moved: '{n} VPN-Director-Regel(n) laufen gerade über eine Ausweich-Leitung', fo_vd_c_on: 'VPN Director dem Failover folgen lassen? Fällt eine Leitung aus, gehen ihre Geräte über die hier eingestellte Ausweich-Leitung (bei "Blockieren": gesperrt).',
    dw_fo: 'ausgefallen - Abfragen über den DNS von {a} (Failover)', dw_fo_block: 'ausgefallen - Abfragen gesperrt (Failover: blockieren)', act_aghlogin: 'AdGuard-Home-Login', agh_title: 'AdGuard-Home-Login', agh_desc: 'Optional: Mit dem Login der AdGuard-Home-Weboberfläche ändert "DNS pro Gerät" die Clients über AdGuard Home selbst - kein Neustart, DNS läuft weiter. Liegt nur auf dem Router (nur für root lesbar, nicht in Sicherungen). Ohne Login wird AdGuard Home wie bisher neu gestartet.', agh_user: 'Benutzername', agh_pass: 'Passwort', agh_change: 'Ändern', agh_remove: 'Login entfernen', agh_none: 'Kein Login gespeichert - Client-Änderungen starten AdGuard Home neu.', agh_saved: 'Login gespeichert - wird bei der nächsten Client-Änderung genutzt.', agh_ok: 'Login gespeichert und funktioniert - Client-Änderungen ohne Neustart.', agh_err: 'Login gespeichert, aber die letzte Änderung ging schief ({e}) - AdGuard Home wurde stattdessen neu gestartet.', agh_refused: 'AdGuard Home hat den gespeicherten Login abgelehnt (Passwort geändert?) - er wird nicht mehr benutzt. Bitte neu eingeben.', agh_need: 'Bitte Benutzername und Passwort eingeben.', agh_c_off: 'AdGuard-Home-Login entfernen? Client-Änderungen starten AdGuard Home dann wieder neu.',
    act_remove: 'Entfernen', act_clear: 'Liste leeren', act_edit: 'Bearbeiten', act_schedule: 'Zeitplan', act_failover: 'Failover', act_statssave: 'USB-Sicherung', act_pimport: 'Eigene Vorlagen hinzufügen', dw_set_vpn: 'DNS des VPN-Anbieters eintragen', dw_ip2: 'zweiter (optional)', dw_auto: 'Automatisch', dw_bad_ip: '"{v}" ist keine IPv4-Adresse.', dw_need_ip: 'Bitte mindestens eine Adresse eingeben.', dw_vpn_why: 'Trag den DNS deines VPN-Anbieters für {t} hier ein (die Zeile DNS = ... seiner WireGuard-Datei) - nicht im VPN-Client des Routers: dort eingetragen schickt der Router die Abfragen der Geräte direkt zum Anbieter, an AdGuard Home und seinen Filtern vorbei. Hier laufen sie erst durch AdGuard Home und dann durch den Tunnel.', act_dnsfsrv: 'DNS der VPN-Leitung', dw_title: 'DNS passend zur Leitung', dw_sub: 'Jede Abfrage nimmt dieselbe Leitung wie der Verkehr danach', dw_intro: 'Normalerweise fragt der Router alle Namen über einen Weg ab (hier: {b}). Eine Seite, die ASN Manager über WAN schickt, würde dann trotzdem über ein VPN aufgelöst - Standort, CDN-Server und Leak-Tests passen nicht zusammen. Diese drei Schalter bringen das in Ordnung.', dw_base_unknown: 'dein normales DNS', dw_f_title: 'Seiten aus ASN Manager', dw_f_desc: 'Domains und ASNs aus deiner Liste werden über ihr Ziel aufgelöst - eine Seite auf WAN fragt einen DNS-Server über WAN, eine Seite auf WGC3 einen durch WGC3.', dw_d_title: 'Jedes Gerät nach VPN Director', dw_d_desc: 'Alle übrigen Seiten löst jedes Gerät über die Leitung auf, die der VPN Director ihm gibt. Braucht AdGuard Home (wird neu gestartet, wenn sich VPN Director oder Domains ändern).', dw_t_title: 'Abfragen über WAN verschlüsseln', dw_t_desc: 'Was über WAN abgefragt wird, geht per DNS over TLS raus - dein Provider sieht die Namen nicht mehr. Abfragen durch ein VPN schützt ohnehin der Tunnel.', dw_now: 'So läuft es gerade', dw_th_line: 'Leitung', dw_th_dns: 'DNS-Server', dw_th_prot: 'Geschützt', dw_th_for: 'Wofür', dw_normal: 'normales DNS', dw_unbound: 'Unbound (löst selbst auf)', dw_router_dns: 'DNS des Routers', dw_for_rest: 'alles andere', dw_devs: '{n} Gerät(e)', dw_other_devs: 'Geräte ohne VPN-Director-Eintrag', dw_doms: '{n} Domains', dw_names: '{n} gelernte Namen', mail_title: 'E-Mail bei neuer Version', mail_sub: 'Nur ein Hinweis - es wird nichts installiert', mail_desc: 'Nutzt die E-Mail-Einstellungen von amtm. ASN Manager schaut einmal am Tag nach (ab 9:00); du bekommst höchstens eine E-Mail pro neuer Version und pro Tag oder Woche - mehrere Versionen an einem Tag kommen als eine E-Mail mit allen Änderungen.', mail_off: 'Aus', mail_daily: 'Täglich', mail_weekly: 'Wöchentlich', mail_test: 'Test-E-Mail senden', mail_noamtm: 'amtm hat noch keine E-Mail-Einstellungen - richte sie zuerst in amtm ein (SSH: amtm, dann em).', mail_last: 'Letzte E-Mail: v{v} ({t})', mail_err: 'Letzter Fehler: {e}', act_mailtest: 'Test-E-Mail', dw_ddoms: '{n} Domain(s) nur für einzelne Geräte', dw_src_router_wan: 'aus den WAN-Einstellungen des Routers', dw_src_router: 'aus dem VPN-Client des Routers (umgeht AdGuard Home - besser hier eintragen)', dw_src_auto: 'automatisch gewählt (öffentlicher DNS durch den Tunnel)', dw_src_auto_wan: 'automatisch gewählt (kein WAN-DNS eingetragen)', dw_src_own: 'DNS des VPN-Anbieters (hier eingetragen)', dw_src_own_wan: 'eigene Angabe (dns_follow.conf)', dw_p_tunnel: 'VPN-Tunnel', dw_p_on: 'verschlüsselt (TLS)', dw_p_fw: 'verschlüsselt (Firmware-TLS)', dw_p_dc: 'verschlüsselt (dnscrypt-proxy)', dw_p_dcfw: 'verschlüsselt (dnscrypt-proxy; Firmware-DoT ist auch an - eins reicht)', dw_p_off: 'nicht verschlüsselt', dw_p_ub: 'nicht verschlüsselt (Unbound fragt die Nameserver)', dw_ub_hint: 'Unbound löst über WAN auf und fragt die Nameserver selbst - das ist immer unverschlüsselt. Zwei Wege: Unbound durch ein VPN schicken (outgoing-interface: 192.168.1.1 in unbound.conf plus den Router 192.168.1.1 im VPN Director, oder die VPN-Option von unbound_manager) - dann schützt der Tunnel; oder in Unbound die Weiterleitung per DNS over TLS einschalten (z. B. zu Quad9) - dann ist alles verschlüsselt, aber Unbound löst nicht mehr selbst auf.', dw_p_plain: 'nicht verschlüsselt - WAN > DNS Privacy Protocol einschalten', dw_p_agh: 'nur Geräte', dw_p_noubc: 'nur Geräte (Unbound antwortet nicht)', dw_p_nofw: 'nur Geräte', dw_p_unknown: 'nicht verschlüsselt (Server ohne TLS)', dw_more: 'Wie funktioniert das?', dw_more_1: 'Für jeden DNS-Server einer Leitung legt ASN Manager eine Routing-Regel an, damit die Abfrage des Routers wirklich durch diese Leitung geht. Fällt ein VPN aus, werden seine Abfragen blockiert, statt über WAN zu laufen.', dw_more_2: 'DNS-Server: bei WAN die im Router unter WAN eingetragenen; bei einem VPN der DNS des Anbieters, den du hier einträgst, sonst ein freier öffentlicher durch den Tunnel. Den DNS nicht im VPN-Client des Routers eintragen - der Router schickt die Abfragen dann an AdGuard Home vorbei. Denselben DNS eines Anbieters kannst du bei mehreren seiner VPN-Leitungen eintragen - jede Leitung fragt dann den Server an ihrem eigenen Tunnel-Ende.', dw_more_3: 'Seiten aus ASN Manager: Domain-Einträge für alle Geräte und die Namen, die zu deinen ASN-Einträgen gesehen wurden (braucht Vorschläge nach Domain). Einträge nur für einzelne Geräte bleiben außen vor - DNS ist für alle Geräte gleich.', dw_more_4: 'Jedes Gerät: AdGuard Home bekommt für jedes Gerät aus dem VPN Director einen Client "<Gerät> (ASNM <Leitung>)". Deine Filter bleiben, andere Clients werden nicht angefasst, vor jeder Änderung gibt es eine Sicherung.', dw_more_5: 'Verschlüsselung: Mit Unbound leitet dieser die WAN-Namen per TLS weiter (Port 853); ohne Unbound läuft das normale DNS meist ohnehin über WAN - dann DNS over TLS im Router einschalten (WAN > DNS Privacy Protocol) oder dnscrypt-proxy (DoH / DNSCrypt) hinter dnsmasq nutzen.', dw_more_6: 'Ein Schalter auf Aus entfernt wieder alles, was er eingerichtet hat.', dnst_title: 'WAN-DNS verschlüsseln', dnst_desc: 'Abfragen, die über WAN gehen, werden verschlüsselt gesendet (DNS over TLS, Port 853) - dein Provider sieht nicht mehr, welche Namen du abfragst. Für die Namen erledigt das Unbound, für die Geräte auf WAN AdGuard Home. Ohne Unbound läuft das normale DNS meist ohnehin über WAN - dann verschlüsselt es die Firmware (WAN > DNS Privacy Protocol > DNS-over-TLS). Abfragen durch ein VPN verschlüsselt ohnehin der Tunnel.', dnst_on: '{t}: verschlüsselt (DNS over TLS)', dnst_agh: '{t}: nur für Geräte verschlüsselt (kein Unbound für die Namen)', dnst_noubc: '{t}: nur für Geräte verschlüsselt - unbound-control antwortet nicht (siehe dnsfollow status)', dnst_nofw: '{t}: nur für Geräte verschlüsselt - für die Namen lässt sich das DNS over TLS der Firmware hier nicht nutzen', dnst_b_tunnel: 'Normales DNS ({b}): durch den VPN-Tunnel verschlüsselt', dnst_b_fw: 'Normales DNS ({b}): durch die Firmware verschlüsselt (DNS over TLS)', dnst_b_ub: 'Normales DNS ({b}): Unbound fragt die Nameserver selbst - nicht verschlüsselt', dnst_b_plain: 'Normales DNS ({b}): NICHT verschlüsselt - WAN > Internetverbindung > DNS Privacy Protocol > DNS-over-TLS einschalten', dnst_unknown: '{t}: nicht verschlüsselt - für diesen DNS-Server ist kein TLS-Name bekannt (einen bekannten eintragen, z. B. 9.9.9.11)', dnsd_title: 'DNS pro Gerät (AdGuard Home)', dnsd_desc: 'Jedes Gerät bekommt zusätzlich den DNS des Ziels, über das der VPN Director es schickt (Geräte, die dort nicht stehen: WAN). AdGuard Home bekommt dafür pro Ziel einen Client "ASNM <Ziel>"; lokale Namen und die Domains von ASN Manager gehen weiter an dnsmasq, Filter bleiben wie sie sind. AdGuard Home wird neu gestartet, wenn sich der VPN Director oder die Domain-Einträge ändern.', dnsd_row: 'Geräte auf {t} (VPN Director, {n}): DNS {s}', dnsd_rest: 'Übrige Geräte ({l}): WAN, DNS {s}', dnsd_normal: 'wie bisher (normales DNS)', dnsd_confirm: '"DNS pro Gerät" einschalten? ASN Manager schreibt Clients "... (ASNM ...)" in die AdGuard-Home-Konfiguration (mit Sicherung) und startet AdGuard Home neu - DNS ist ein paar Sekunden weg. "DNS über dasselbe Ziel" wird mit eingeschaltet.', dnsd_confirm_off: '"DNS pro Gerät" ausschalten? Die Clients "... (ASNM ...)" werden aus AdGuard Home entfernt und AdGuard Home neu gestartet.', dnsf_title: 'DNS über dasselbe Ziel', dnsf_sub: 'Namen über denselben Weg auflösen, über den sie geleitet werden', dnsf_desc: 'Namen, die über ein anderes Ziel laufen als dein normales DNS, werden auch über dieses Ziel aufgelöst - z. B. fragt eine Seite auf WAN einen DNS-Server über WAN, IP-Adresse und DNS passen dann zusammen. Gilt für Domain-Einträge (für alle Geräte) und die gelernten Namen der ASN-Einträge (braucht "Vorschläge nach Domain"). Dein normales DNS bleibt unverändert.', dnsf_off: 'Aus', dnsf_on: 'An', dnsf_base: 'Normales DNS: {m} über {b} (unverändert)', dnsf_row: '{t}: DNS {s} - {d} Domain-Einträge, {l} gelernte Namen', dnsf_none: 'Noch keine Namen mit anderem Ziel.', dnsf_confirm: '"DNS über dasselbe Ziel" einschalten? dnsmasq wird einmal neu gestartet. Ausschalten entfernt alles wieder.', act_pedit: 'Eigene Vorlage', oe_open: 'Eigene Vorlagen bearbeiten', oe_new: '+ Neue Vorlage', oe_del: 'Löschen', oe_name: 'Name', oe_items: 'ASNs und Domains', oe_items_help: 'Einer pro Zeile (oder mit Leerzeichen getrennt). Eine Domain gilt für alle Unterdomains; ASNs als 13335 oder AS13335.', oe_file: 'Speichern in', oe_wide: 'ganzes Cloud- / CDN-Netz (⚠)', oe_save: 'Speichern', oe_usb: 'USB-Stick {n}', oe_jffs: 'Router (/jffs)', oe_count: '{n} Einträge', oe_count1: '1 Eintrag', oe_need_name: 'Bitte einen Namen eingeben.', oe_need_items: 'Bitte mindestens eine ASN oder Domain eingeben.', oe_bad: 'Das sind weder ASNs noch Domains und werden weggelassen:\n{l}\n\nTrotzdem speichern?', oe_c_del: 'Eigene Vorlage "{n}" ({f}) löschen?', own_title: 'Eigene Vorlagen', own_sub: 'Als .txt-Datei zum Teilen herunterladen oder eine Vorlagen-Datei von jemand anderem hinzufügen.', own_dl: 'Vorlagen herunterladen', own_add: 'Vorlagen hinzufügen', own_replace: 'ersetzen statt ergänzen', own_count: '{n} eigene Vorlage(n) (★).', own_none: 'Noch keine eigenen Vorlagen.', own_bad_file: 'Die Datei enthält keine Vorlagen-Zeilen (kategorie|Name|ASNs und Domains|).', own_c_add: '{n} Vorlage(n) hinzufügen? Zeilen mit gleicher Kategorie und gleichem Namen ersetzen die bisherigen. {b} Zeile(n) werden übersprungen (falsches Format).', own_c_replace: 'Deine eigenen Vorlagen auf dem Router durch {n} Vorlage(n) ersetzen? {b} Zeile(n) werden übersprungen (falsches Format). Eine presets.txt auf einem USB-Stick bleibt unverändert.', own_help: 'Die Datei enthält eine Vorlage pro Zeile: kategorie|Name|ASNs und Domains| (wide am Ende für ein ganzes Cloud- / CDN-Netz), z. B. stream|Mein Dienst|example.com cdn.example.net|. Kategorien: stream, tvde, news, gaming, social, work, shop, bank, services, smarthome, updates, cloud, test. Hinzugefügte Vorlagen liegen in /jffs/addons/asnmanager/presets.txt; der Download enthält alle eigenen Vorlagen, auch die vom USB-Stick.', preset_cat: 'Kategorie', preset_on: 'schon in der Liste -> {t}', preset_have: '{n} von {m} schon in der Liste (markiert) - erneutes Hinzufügen setzt sie auf das gewählte Ziel', preset_own_s: 'eigene', preset_own: 'Deine eigene Vorlage (presets.txt auf dem Router / USB-Stick)', pcat_stream: 'Streaming', pcat_tvde: 'TV & Mediatheken (DE / AT / CH)', pcat_news: 'Nachrichten', pcat_bank: 'Banken (DE)', pcat_services: 'Dienste & Behörden (DE)', pcat_smarthome: 'Smart Home & IoT', pcat_updates: 'Updates & Downloads', pcat_gaming: 'Gaming', pcat_social: 'Social & Messenger', pcat_work: 'Tools & Arbeit', pcat_shop: 'Shopping & Bezahlen', pcat_cloud: 'Cloud & CDN (ganze Netze)', pcat_test: 'Tests & IP-Check', preset_legend: 'Eine Vorlage fügt ASNs und / oder Domains hinzu (eine Domain gilt für alle Unterdomains). ⚠ = Cloud, CDN oder Hosting: über diese Netze läuft ein großer Teil des Internets, wer sie umleitet, leitet weit mehr als diesen einen Dienst um.', preset_wide: '"{n}": Über diese Netze läuft ein großer Teil des Internets (Cloud / CDN / Hosting).\nWer sie umleitet, leitet auch den Verkehr vieler anderer Dienste und Webseiten mit um - nicht nur diesen einen.\n\nTrotzdem hinzufügen?', tool_done: '{a}: fertig - Ergebnis siehe unten', tool_failed: '{a}: fehlgeschlagen - siehe Ausgabe unten', act_test: 'Route testen', act_trace: 'Traceroute', act_ifaces: 'Öffentliche IPs', act_status: 'ipset-Status', act_lookup: 'Suche', act_sghide: 'Vorschlag ausblenden', sg_hide: 'Diesen Vorschlag ausblenden', sg_unhide: 'Wieder einblenden', sg_showhid: 'Ausgeblendete zeigen ({n})',
    tab_asns: 'ASNs', tab_traffic: 'Traffic', tab_targets: 'Ziele & Failover', tab_diag: 'Diagnose', tab_settings: 'Einstellungen',
    sub_manual: 'ASNs eingeben', sub_lookup: 'Per Domain / IP suchen', sub_presets: 'Dienst-Vorlagen', rc_to_list: 'Zur ASN-Liste',
    sp_th: 'Speedtest', sp_btn: 'Test', sp_running: 'Speedtest läuft - etwa 30 Sekunden...',
    sp_confirm: 'Speedtest über {i} starten?\nEr dauert etwa 30 Sekunden und verbraucht bis zu ~200 MB Download und ~100 MB Upload (über dieses Interface).',
    sp_ping: 'Ping {l} ms', sp_err_offline: 'offline', sp_err_noaddr: 'keine Adresse', sp_err_route: 'keine nutzbare Route', sp_err_rule: 'keine Routing-Regel', sp_err_fail: 'keine Daten (kein Internet?)',
    act_speedtest: 'Speedtest',
    bk_preparing: 'Sicherung wird vorbereitet...', bk_failed: 'Die Sicherung konnte nicht erstellt werden - bitte noch einmal versuchen.',
    bk_fallback: 'Der Router hat die vollständige Sicherung nicht geliefert - es wurde eine Basis-Sicherung gespeichert (ASN-Liste, Zeitplan, Failover-Ketten, Statistik-Einstellungen). Ist das Skript auf dem Router älter als diese Seite, bitte aktualisieren (SSH-Menü, Update).',
    rs_title: 'Was soll wiederhergestellt werden?', rs_asn: 'ASN-Liste ({n} Einträge)', rs_replace: 'Aktuelle Liste ersetzen', rs_merge: 'In die aktuelle Liste einfügen',
    rs_sched: 'Zeitplan für die automatische Aktualisierung (alle {i} Tage um {t})', rs_fo: 'Failover-Ketten ({n}; Ketten, die nicht in der Sicherung stehen, werden entfernt)', rs_set: 'Einstellungen',
    rs_s_stats: 'Traffic-Statistik', rs_s_saving: 'USB-Sicherung', rs_s_loc: 'WebUI-Tab', rs_loc_vpn: 'VPN-Menü', rs_loc_addons: 'Addons-Menü',
    rs_run: 'Auswahl wiederherstellen', rs_nosel: 'Nichts ausgewählt.',
    pr_on: 'an', pr_off: 'aus',
    disp_title: 'Anzeige', disp_sub: 'Gilt für die ganze Seite in diesem Browser', disp_unit: 'Einheit für Datenraten',
    disp_unit_desc: 'Wird für den Live-Durchsatz, den Speedtest und die Zusammenfassungen verwendet. 1 MB/s = 8 Mbit/s. Datenmengen (zum Beispiel 1,2 GB) bleiben unverändert.',
    disp_change: 'Einheit ändern',
    perf_title: 'Leistung', perf_sub: 'CPU-Last des Routers verringern',
    perf_rules: 'Marker-Regeln', perf_rules_desc: 'Zusammengefasst: Alle ASNs eines Ziels teilen sich eine Menge und eine Regel, der Router prüft jedes Paket nur einmal pro Ziel (mit vielen ASNs deutlich weniger CPU). Einzeln: eine Regel pro ASN wie früher, zum Vergleichen oder wenn sich etwas anders verhält.',
    perf_rules_comb: 'Zusammengefasst (schnell)', perf_rules_single: 'Einzeln pro ASN',
    perf_rules_confirm: 'Marker-Regeln auf "{m}" umstellen und die Regeln jetzt neu aufbauen? (einige Sekunden, die gespeicherten ASN-Listen werden genutzt)',
    perf_stats: 'Traffic-Statistik', perf_stats_desc: 'Pro ASN: jedes ASN wird einzeln gezählt (eine Zählregel pro ASN). Pro Interface: gezählt wird nur pro Interface und Gerät - kaum CPU-Last, aber keine ASN-Aufteilung.',
    perf_stats_asn: 'Pro ASN (genau)', perf_stats_iface: 'Pro Interface (leicht)',
    tr_all: 'Gesamter Verkehr', tr_mode_iface: 'Gezählt wird nur pro Interface und Gerät (ohne ASN-Aufteilung) - spart CPU.', tr_mode_change: 'Ändern',
    rs_s_smode: 'Statistik-Detail', rs_s_rules: 'Marker-Regeln', rs_v_asn: 'pro ASN', rs_v_iface: 'pro Interface', rs_v_comb: 'zusammengefasst', rs_v_single: 'einzeln pro ASN',
    back_router: '← Netzwerk\u00adübersicht', add_entries: 'Einträge', kind_ip: 'IP', kind_dom: 'Domain', st_learned: '{n} gelernt', lr_tip: 'Gelernte Adressen anzeigen', lr_head: 'Für *.{d} gelernte Adressen', lr_more: '... und {n} weitere (alle: ASNmanager.sh custom learned {id})', lr_none: 'Noch keine Adresse gelernt.', lr_note: 'dnsmasq speichert nur die Adressen, nicht zu welcher Subdomain sie gehören. Eine Adresse wird 7 Tage nach ihrer letzten Abfrage entfernt; die Adressen werden gesichert und nach einem Router-Neustart wiederhergestellt.',
    add_domnote: 'Eine Domain gilt auch für alle Subdomains. Sie wirkt nur für Geräte, die den Router als DNS-Server nutzen (nicht bei DoH oder fest eingestelltem DNS; nur IPv4). Der Router lernt die Adressen, wenn ein Gerät den Namen auflöst.',
    rc_nolearned: 'nichts gelernt', rc_tip_nolearned: 'Für diese Domain wurde noch keine Adresse gelernt. Ein Gerät muss den Namen über den DNS-Server des Routers (dnsmasq) auflösen. Nicht erfasst werden Geräte mit anderem DNS-Server oder DoH und Namen, die ein davorgeschalteter AdGuard Home beantwortet, ohne dass sie über dnsmasq laufen.',
    lang_label: 'Sprache', lang_default: 'Standard', lang_en: 'English', theme_label: 'Design', theme_dark: 'Dunkel', theme_light: 'Hell', theme_blue: 'Blau',
    stat_asns: 'ASNs', stat_more: '+ {i} IP · {d} Domains',
    note_ph: 'Notiz, z. B. ZDF Mediathek', note_lbl: 'Notiz', add_note_lbl: 'Notiz (optional)', add_s1: 'Leite', add_s2: 'über', add_s3: 'für', add_note_ph: 'optional, z. B. ZDF Mediathek', add_src_type: 'IP-Adressen eintippen', add_src_hide: 'IP-Feld ausblenden', add_note_help: 'Steht unter dem Eintrag - bei mehreren Einträgen auf einmal unter jedem davon',
    c_clear_type: 'ALLE Einträge ({a} ASNs, {i} IP-Bereiche, {d} Domains) aus der Liste entfernen?\nDas aktive Routing bleibt bestehen, bis du "Regeln anwenden" klickst.\n\nZum Bestätigen {w} eintippen:', clear_word: 'LÖSCHEN', clear_wrong: 'Nicht entfernt - das Wort stimmte nicht.',
    dns_lbl: 'DNS / DHCP', dns_ok: 'dnsmasq OK', dns_ok_agh: 'dnsmasq OK (Port {port}, hinter {p})', dns_other: '{p} beantwortet DNS statt dnsmasq', dns_other_long: '{p} beantwortet DNS (und DHCP) statt dnsmasq. Die Geräte funktionieren, aber die Domain-Einträge lernen nichts, solange {p} die ipset-Mengen der dnsmasq-Zeilen nicht selbst füllt. IP- und ASN-Einträge sind nicht betroffen.', dns_dhcp_ok: 'DHCP OK', dns_dhcp_off: 'DHCP im Router aus',
    sched_err: 'der Cron-Eintrag fehlt - die Subnetze werden nicht aktualisiert (einmal Regeln anwenden)',
    dns_agh: '{p} umgeht dnsmasq (fragt {up})', dns_mirror: '{p} füllt die Domain-Listen selbst',
    dns_agh_long: '{p} schickt die Anfragen direkt an {up} statt an dnsmasq (Port {port}). DNS funktioniert, aber die Domain-Einträge lernen (fast) nichts, und die Vorschläge nach Domain bleiben leer. Abhilfe: in {p} -> Einstellungen -> DNS-Einstellungen -> Upstream-DNS-Server {up} durch 127.0.0.1:{port} ersetzen (dnsmasq gibt die Anfragen an denselben Server weiter).',
    dns_agh_partly_long: '{p} verteilt die Anfragen auf dnsmasq (Port {port}) und {up}. DNS funktioniert, aber die Domain-Einträge lernen nur die Adressen der Anfragen, die zufällig über dnsmasq laufen. Abhilfe: in {p} -> Einstellungen -> DNS-Einstellungen -> Upstream-DNS-Server nur 127.0.0.1:{port} stehen lassen (dnsmasq gibt die Anfragen an {up} weiter).',
    dns_bad_nodnsmasq: 'dnsmasq läuft nicht: Geräte bekommen keine neuen Adressen (DHCP), und die Domain-Einträge lernen nichts. Abhilfe (SSH): service restart_dnsmasq - mit AdGuard Home davor: /opt/etc/init.d/S99AdGuardHome restart',
    dns_bad_no53: 'Niemand beantwortet DNS auf Port 53 (dnsmasq läuft auf Port {port}). Ist AdGuard Home gestoppt? Abhilfe (SSH): /opt/etc/init.d/S99AdGuardHome restart',
    dns_bad_nodhcp: 'DHCP ist im Router an, aber niemand antwortet (Port 67): Geräte bekommen keine neuen Adressen. Abhilfe (SSH): service restart_dnsmasq',
    dns_checked: 'geprüft {t}', stat_subnets: 'Subnetze', stat_ifaces: 'Interfaces online', stat_last: 'Zuletzt angewendet',
    card_add_sub: 'Ein Autonomes System, einen IP-Bereich oder eine Domain über ein WAN- oder VPN-Interface leiten', card_list_sub: 'Gruppe anklicken zum Auf- oder Zuklappen',
    status: 'Status', version: 'Version', last_applied: 'Regeln zuletzt angewendet', auto_refresh: 'Automatische Aktualisierung', actions: 'Aktionen',
    btn_apply: 'Regeln anwenden', btn_full: 'Alle neu laden', btn_full_tip: 'Die Subnetze aller ASNs neu herunterladen und alle Regeln neu aufbauen (der tägliche Zeitplan macht das ohnehin)', btn_reload: 'Daten neu laden', btn_retry: 'Fehlgeschlagene wiederholen',
    add_asns: 'ASNs, IPs oder Domains hinzufügen', asns: 'ASN(s)', target: 'Ziel-Interface', src_ip: 'Quell-IP des Geräts', src_empty: 'leer = alle Geräte',
    btn_add: 'Hinzufügen', presets: 'Dienst-Vorlagen', preset: 'Vorlage', btn_add_preset: 'Vorlage hinzufügen',
    lookup_title: 'ASN zu Domain oder IP finden', domain_ip: 'Domain / IP', btn_lookup: 'Suchen', th_ip: 'IP', th_holder: 'Inhaber',
    btn_take: 'Übernehmen', btn_take_all: 'Alle übernehmen', in_list: 'in Liste: {d}', lookup_err: 'Abfrage fehlgeschlagen', lookup_running: 'Suche läuft...',
    th_pubip: 'Externe IP', btn_pubip_refresh: 'IPs aktualisieren', pubip_loading: 'wird ermittelt...', pubip_none: '-',
    expand_all: 'alle aufklappen', collapse_all: 'alle zuklappen', group_sum: '{n} ASN(s), {s} Subnetze', group_failed: '{f} fehlgeschlagen', group_rc: '{n} Routing-Fehler',
    list_title: 'ASN-Liste', btn_remove_sel: 'Auswahl entfernen', btn_remove_all: 'Alle entfernen',
    ls_asn: 'ASNs', ls_ip: 'IP / CIDR-Bereiche', ls_dom: 'Domains', ls_th_asn: 'ASN', ls_th_ip: 'IP / Bereich', ls_th_dom: 'Domain', ls_th_learned: 'Gelernt',
    ls_empty_asn: 'Noch keine ASNs eingetragen.', ls_empty_ip: 'Noch keine IP-Adressen oder Bereiche - sie werden wie ASNs hinzugefügt, z. B. 181.209.202.0/24.', ls_empty_dom: 'Noch keine Domains - sie werden wie ASNs hinzugefügt, z. B. *.googlevideo.com.',
    ls_gsum_asn: '{n} ASN(s), {s} Subnetze', ls_gsum_ip: '{n} Bereich(e)', ls_gsum_dom: '{n} Domain(s), {l} Adressen gelernt',
    th_asn: 'ASN', th_src: 'Quellgerät', th_subnets: 'Subnetze', th_state: 'Status', th_target: 'Ziel', th_device: 'Gerät', th_asns: 'ASNs',
    ifaces_title: 'Ziel-Interfaces', schedule_title: 'Zeitplan für Aktualisierung', refresh_every: 'Aktualisieren alle', days: 'Tag(e)', days_range: '(1-30)',
    at_time: 'Um', time_fmt: '(HH:MM, 24h)', btn_save_schedule: 'Zeitplan speichern',
    diag_title: 'Diagnose', btn_test: 'Route testen', btn_trace: 'Traceroute', router_checks: 'Router-Prüfungen',
    btn_explain: 'Erklären', explain_help: 'Erklären: was DNS antwortet, welche Einträge jede Adresse enthalten, welche Regel gewinnt (für das unten gewählte Gerät) und über welches Interface der Verkehr hinausgeht.',
    diag_dev: 'Gerät', diag_dev_any: '- beliebiges Gerät -', btn_device: 'Gerät prüfen', a_dev: 'Bitte ein Gerät wählen.',
    diag_dev_help: 'Gerät prüfen: die Regeln für dieses Gerät, sein normaler Weg (VPN Director) und seine aktuellen Verbindungen mit Name, Traffic, Regel und Interface.',
    btn_dnschain: 'DNS-Kette prüfen', act_explain: 'Erklären', act_device: 'Gerät prüfen', act_dnschain: 'DNS-Kette', act_diagpack: 'Diagnose-Paket',
    dp_title: 'Diagnose-Paket', dp_sub: 'Alles zur Analyse eines Problems in einer Textdatei',
    dp_text: 'Sammelt Version, Einträge, Einstellungen, DNS-Kette, Routing-Prüfung, ip rules, Routing-Tabellen, Markierungsregeln, Set-Größen, VPN Director und die letzten Meldungen von ASN Manager im Systemprotokoll. Unkenntlich gemacht: öffentliche IP-Adressen, VPN-Server und Tunnel-Adressen, MAC-Adressen, IPv6-Adressen und Schlüssel; Notizen und VPN-Director-Beschreibungen fehlen, und die Domains deiner Einträge werden zu domain-01.de, domain-02.com ... (in der ganzen Datei derselbe Name). Lesbar bleiben: lokale Adressen (192.168.x.x), ASN-Nummern und das Routermodell. Bitte die Datei vor dem Weitergeben ansehen. Um ein Problem zu melden: herunterladen und an ein neues Issue auf GitHub anhängen (Datei in das Textfeld ziehen).',
    dp_full: 'Domains im Klartext (nur wenn eine Domain-Regel das Problem ist)',
    btn_dp: 'Paket erstellen', dp_missing: 'Das Paket wurde auf dem Router nicht gefunden - bitte neu erstellen.', dp_download: 'Herunterladen', dp_github: 'Auf GitHub melden',
    dp_issue_title: 'Problem: ', dp_issue_body: 'ASN Manager v{v}\n\nWas funktioniert nicht / was hast du erwartet?\n\n\nBitte hier das Diagnose-Paket ({f}) anhängen: die Datei in dieses Textfeld ziehen.',
    btn_devices: 'Geräte & DNS', act_devices: 'Geräte & DNS', btn_ipset: 'ipset-Status', btn_pubip: 'Öffentliche IPs', output_default: 'Hier erscheint die Ausgabe von Anwenden, Tests und Prüfungen.',
    backup_title: 'Sicherung & Wiederherstellung', backup_export: 'Export', backup_export_desc: 'Liste (ASNs, IP-Bereiche, Domains, Notizen), Zeitplan, Failover-Ketten und Einstellungen als .conf-Datei herunterladen',
    btn_export: 'Sicherung herunterladen', backup_import: 'Import', backup_import_desc: 'Du wählst, was wiederhergestellt wird. Kompatibel mit Sicherungen aus dem Terminal-Menü',
    btn_import: 'Datei wählen...', import_found: '{n} gültige Einträge in {file} gefunden{bad}.', import_bad: ', {n} ungültige Zeilen ignoriert',
    import_sched: ' Zeitplan: alle {i} Tag(e) um {t}.', btn_replace: 'Liste ersetzen', btn_merge: 'Zur Liste hinzufügen', btn_cancel: 'Abbrechen',
    import_none: 'In dieser Datei wurden keine gültigen ASN-Einträge gefunden.',
    st_active: 'aktiv', st_down: 'geladen, Interface offline', st_not_applied: 'nicht angewendet', st_failed: 'fehlgeschlagen - 0 Subnetze', st_new: 'neu - noch nicht angewendet',
    online: 'online', offline: 'offline', not_configured: 'nicht eingerichtet', all_devices: 'alle Geräte', never: 'noch nie',
    every: 'Alle {n} Tag(e) um {t}', cron_on: '(Cron aktiv)', cron_off: '(Cron nicht aktiv - einmal Regeln anwenden)',
    btn_edit: 'Bearbeiten', btn_remove: 'Entfernen', btn_save: 'Speichern',
    pick_device: '- Gerät auswählen -', no_asns: 'Noch keine ASNs eingetragen.', summary: '{n} ASN(s), {s} Subnetze geladen',
    hint_multi: 'ASN, IP-/CIDR-Bereich (/8 bis /32) oder Domain - mehrere: mit Komma trennen', hint_formats: '<b>ASN</b> <span class="asnm-ex">AS13335</span> oder <span class="asnm-ex">13335</span> &middot; <b>IP</b> <span class="asnm-ex">1.2.3.4</span> &middot; <b>Bereich</b> <span class="asnm-ex">181.209.202.0/24</span> (/8 bis /32) &middot; <b>Domain</b> <span class="asnm-ex">googlevideo.com</span> - gilt für alle Unterdomains, kein <span class="asnm-ex">*.</span> nötig &middot; mehrere: mit Komma oder Leerzeichen trennen', hint_optional: 'optional',
    ph_asns: 'z. B. AS13335, 1.2.3.4, 181.209.202.0/24, googlevideo.com', ph_ip: 'z. B. 192.168.1.50 oder 192.168.1.50,192.168.1.60', ph_domain: 'z. B. netflix.com', ph_diag: 'z. B. one.one.one.one',
    working: 'Wird ausgeführt...', applying: 'Regeln werden angewendet - aus den gespeicherten Subnetzen, nur neue ASNs werden geladen...', reloading: 'Subnetze aller ASNs werden geladen - das kann einige Minuten dauern...', retrying: 'Neuaufbau aus dem Cache, nur fehlgeschlagene ASNs werden geladen...',
    progress: 'AS{asn} -> {dest}  ({d} von {t})', running_x: '{a} läuft...',
    timeout: 'Keine Antwort vom Router (Zeitüberschreitung). Prüfe, ob der service-event-Hook installiert ist.',
    no_data: 'Keine Daten vom Router. Ist ASN Manager installiert?', parse_err: 'Daten vom Router konnten nicht gelesen werden.',
    done: 'Fertig.', failed: 'Fehlgeschlagen.', no_output: '(keine Ausgabe)',
    c_apply: 'Aktuelle Subnetze für alle ASNs laden und die Routing-Regeln jetzt neu aufbauen?', c_full: 'Die Subnetze aller ASNs neu herunterladen und alle Regeln neu aufbauen? Das dauert einige Minuten; für normale Änderungen reicht "Regeln anwenden".',
    c_remove_one: '{asn} aus der Liste entfernen?', c_remove_n: '{n} Einträge aus der Liste entfernen?',
    c_clear: 'ALLE ASNs aus der Liste entfernen?\nDas aktive Routing bleibt bestehen, bis du "Regeln anwenden" klickst.',
    c_replace: 'Die aktuelle Liste ({n} Einträge) durch {m} Einträge aus der Sicherung ersetzen?',
    a_asns: 'Bitte ASNs, IP-/CIDR-Bereiche (/8 bis /32) oder Domains eingeben, z. B. AS13335, 181.209.202.0/24, *.googlevideo.com', a_ip: 'Die Quell-IP muss eine IPv4-Adresse sein oder leer bleiben.',
    a_nothing: 'Nichts ausgewählt.', a_interval: 'Das Intervall muss zwischen 1 und 30 Tagen liegen.', a_time: 'Die Uhrzeit muss im Format HH:MM (24h) sein.',
    a_host: 'Bitte eine gültige Domain oder IPv4-Adresse eingeben.', footer: 'ASN Manager für Asuswrt-Merlin'
  }
};
// a language pack of the router language (lang.js, written by the router for FR, IT, ES, NL, PL, BR): missing texts stay English
var ASNM_LOCALES = { en: 'en-US', de: 'de-DE' };
if (window.ASNM_LANGPACK && ASNM_LANGPACK.code && ASNM_LANGPACK.t && !ASNM_I18N[ASNM_LANGPACK.code]) {
    ASNM_I18N[ASNM_LANGPACK.code] = ASNM_LANGPACK.t;
    ASNM_LOCALES[ASNM_LANGPACK.code] = ASNM_LANGPACK.locale || 'en-US';
}
function asnmLocale() { return ASNM_LOCALES[ASNM_LANG] || 'en-US'; }
var ASNM_LANG = 'en';

// Router messages are English -> translate the known ones
var ASNM_MSG_DE = [
  [/^Saved (\d+) ASN\(s\) -> (\S+)(.*)\. Apply rules to activate\.$/, '$1 ASN(s) gespeichert -> $2$3. Zum Aktivieren "Regeln anwenden" klicken.'],
  [/^Saved (\d+) IP\/domain entry\(ies\) -> (\S+)(.*)\. Apply rules to activate\.$/, '$1 Eintrag/Einträge (IP/Domain) gespeichert -> $2$3. Zum Aktivieren "Regeln anwenden" klicken.'],
  [/^Saved (\d+) ASN\(s\) and (\d+) IP\/domain entry\(ies\) -> (\S+)(.*)\. Apply rules to activate\.$/, '$1 ASN(s) und $2 Eintrag/Einträge (IP/Domain) gespeichert -> $3$4. Zum Aktivieren "Regeln anwenden" klicken.'],
  [/^Removed (\d+) ASN\(s\) and (\d+) IP\/domain entry\(ies\)\. Apply rules to activate\.$/, '$1 ASN(s) und $2 Eintrag/Einträge (IP/Domain) entfernt. Zum Aktivieren "Regeln anwenden" klicken.'],
  [/^Updated (C\d+) -> (\S+)(.*)\. Apply rules to activate\.$/, '$1 geändert -> $2$3. Zum Aktivieren "Regeln anwenden" klicken.'],
  [/^Imported (\d+) custom entry\(ies\) \((replace|merge)\)(?:, (\d+) invalid entries skipped)?\. Apply rules to activate\.$/, function (m, n, mode, bad) {
      return n + ' eigene Einträge importiert (' + (mode === 'replace' ? 'ersetzt' : 'ergänzt') + ')' + (bad ? ', ' + bad + ' ungültige übersprungen' : '') + '. Zum Aktivieren "Regeln anwenden" klicken.'; }],
  [/^Skipping invalid entry '(.*)'$/, 'Ungültiger Eintrag übersprungen: $1'],
  [/^No valid ASN, IP\/CIDR or domain given\.$/, 'Weder eine gültige ASN noch ein IP-Bereich oder eine Domain angegeben.'],
  [/^No ASNs in the list - ASN rules removed, custom entries applied\.$/, 'Keine ASNs in der Liste - ASN-Regeln entfernt, eigene Einträge angewendet.'],
  [/^Updated AS(\d+) -> (\S+)(.*)\. Apply rules to activate\.$/, 'AS$1 geändert -> $2$3. Zum Aktivieren "Regeln anwenden" klicken.'],
  [/^Removed (\d+) ASN\(s\)\. Apply rules to activate\.$/, '$1 ASN(s) entfernt. Zum Aktivieren "Regeln anwenden" klicken.'],
  [/^All ASNs cleared\..*$/, 'Alle ASNs entfernt. Das aktive Routing bleibt bis "Regeln anwenden" bestehen.'],
  [/^Imported (\d+) ASN\(s\) \((replace|merge)\)(?:, (\d+) invalid entries skipped)?\. Apply rules to activate\.$/, function (m, n, mode, bad) {
      return n + ' ASN(s) importiert (' + (mode === 'replace' ? 'ersetzt' : 'hinzugefügt') + ')' + (bad ? ', ' + bad + ' ungültige übersprungen' : '') + '. Zum Aktivieren "Regeln anwenden" klicken.'; }],
  [/^Rules applied: (\d+) OK, (\d+) failed\.$/, 'Regeln angewendet: $1 OK, $2 fehlgeschlagen.'],
  [/^Rules applied: ASN rules kept, custom entries applied\.$/, 'Regeln angewendet: ASN-Regeln unverändert, IP- und Domain-Einträge angewendet.'],
  [/^ASN list is empty - all ASN routing rules removed\.$/, 'ASN-Liste ist leer - alle ASN-Routing-Regeln wurden entfernt.'],
  [/^Auto-refresh set: every (\d+) day\(s\) at (\S+)\.$/, 'Automatische Aktualisierung: alle $1 Tag(e) um $2.'],
  [/^Data refreshed\.$/, 'Daten aktualisiert.'],
  [/^Statistics: per interface and device only.*$/, 'Statistik: nur pro Interface und Gerät (keine Zählregel pro ASN).'],
  [/^Statistics: per ASN, interface and device\.$/, 'Statistik: pro ASN, Interface und Gerät.'],
  [/^Marking rules: combined\..*$/, 'Marker-Regeln: zusammengefasst. Regeln einmal neu aufbauen, damit es wirkt.'],
  [/^Marking rules: single\..*$/, 'Marker-Regeln: einzeln pro ASN. Regeln einmal neu aufbauen, damit es wirkt.'],
  [/^Setting applied: ([A-Z_]+) = (.*)\.$/, 'Einstellung übernommen: $1 = $2.'],
  [/^Invalid value '(.*)' for ([A-Z_]+) skipped\.$/, 'Ungültiger Wert \'$1\' für $2 übersprungen.'],
  [/^Unknown setting '(.*)' skipped\.$/, 'Unbekannte Einstellung \'$1\' übersprungen.'],
  [/^([A-Z0-9]+): down ([0-9.]+) Mbit\/s, up ([0-9.]+) Mbit\/s, ping ([0-9.-]+) ms$/, '$1: Download $2 Mbit/s, Upload $3 Mbit/s, Ping $4 ms'],
  [/^([A-Z0-9]+): the interface is offline.*$/, '$1: Das Interface ist offline - kein Speedtest möglich.'],
  [/^([A-Z0-9]+): no usable route through this interface.*$/, '$1: Keine nutzbare Route über dieses Interface (Tunnel getrennt?) - kein Speedtest möglich.'],
  [/^([A-Z0-9]+): no data could be transferred.*$/, '$1: Über dieses Interface konnten keine Daten übertragen werden (kein Internet oder Testserver nicht erreichbar).'],
  [/^A speed test is already running\.$/, 'Es läuft schon ein Speedtest.'],
  [/^Another ASN Manager job is still running: ([a-z]+) \(since ([0-9:]+)\)\.$/, 'Es läuft noch ein anderer ASN-Manager-Auftrag: $1 (seit $2).'],
  [/^Another ASN Manager job is still running(.*)$/, 'Es läuft noch ein anderer ASN-Manager-Auftrag$1'],
  [/^Updated to v([0-9.]+)\..*$/, 'Auf v$1 aktualisiert. Die Seite lädt neu.'],
  [/^Already up to date \(v([0-9.]+)\)\.$/, 'Bereits aktuell (v$1).'],
  [/^Could not reach GitHub.*$/, 'GitHub nicht erreichbar oder die Datei ist nicht vom ASN Manager - nichts wurde geändert.'],
  [/^Downloaded file is damaged.*$/, 'Die heruntergeladene Datei ist beschädigt - nichts wurde geändert.'],
  [/^The new version did not start.*$/, 'Die neue Version startete nicht - die alte wurde wiederhergestellt.'],
  [/^Could not write the new script.*$/, 'Das neue Skript konnte nicht geschrieben werden - nichts wurde geändert.'],
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
    if (!msg) return msg;
    // "WAN1: down 94.4 Mbit/s, up 16.8 Mbit/s, ping 9.4 ms" - the script always reports Mbit/s; show it in the chosen unit
    var sp = /^([A-Z0-9]+): down ([0-9.]+) Mbit\/s, up ([0-9.]+) Mbit\/s, ping ([0-9.-]+) ms$/.exec(msg);
    if (sp) {
        var loc = asnmLocale(), u = asnmUnitLabel(), pg = (+sp[4]).toLocaleString(loc, { maximumFractionDigits: 1 });
        var dn = asnmFmtRate(+sp[2] * 125000), up = asnmFmtRate(+sp[3] * 125000);
        return ASNM_LANG === 'de' ? sp[1] + ': Download ' + dn + ' ' + u + ', Upload ' + up + ' ' + u + ', Ping ' + pg + ' ms'
                                  : sp[1] + ': down ' + dn + ' ' + u + ', up ' + up + ' ' + u + ', ping ' + pg + ' ms';
    }
    if (ASNM_LANG !== 'de') return msg;
    for (var i = 0; i < ASNM_MSG_DE.length; i++) if (ASNM_MSG_DE[i][0].test(msg)) return msg.replace(ASNM_MSG_DE[i][0], ASNM_MSG_DE[i][1]);
    return msg;
}

function asnmApplyI18n() {
    // Router language; ?lang=de / ?lang=en in the URL overrides it for testing
    var rl = (document.getElementById('preferred_lang').value || '').toLowerCase(), lang = ASNM_I18N[rl] ? rl : 'en';
    ASNM_ROUTER_LANG = lang;
    if (asnmLangMode() === 'en') lang = 'en';
    if (ASNM_FORCE_LANG) lang = ASNM_FORCE_LANG;
    var m = /[?&]lang=([a-z]{2})\b/i.exec(window.location.search);
    if (m && !ASNM_I18N[m[1].toLowerCase()]) m = null;
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
    els = document.querySelectorAll('[data-i18n-title]');
    for (i = 0; i < els.length; i++) els[i].setAttribute('title', t(els[i].getAttribute('data-i18n-title')));
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
    timeouts: { devices: 120000, setting: 360000, mailtest: 90000, dnsfsrv: 360000, speedtest: 150000, update: 240000, apply: 1800000, reload: 1800000, retry: 1800000, trace: 90000, ifaces: 90000, lookup: 30000 },
    reIp: /^((25[0-5]|2[0-4]\d|1?\d?\d)\.){3}(25[0-5]|2[0-4]\d|1?\d?\d)$/,
    reHost: /^[A-Za-z0-9][A-Za-z0-9.-]{0,252}$/,
    reEntry: /^(\d{1,10}):(WAN|WAN1|WAN2|OVPN[1-5]|WGC[1-5]):?([0-9.,\s]*)$/,
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
    var d = new Date(ts * 1000), loc = asnmLocale();
    return d.toLocaleDateString(loc) + ' ' + d.toLocaleTimeString(loc);
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
        if (typeof asnmPerfMark === 'function') asnmPerfMark();
        if (ASNM.data.custom) for (var ci = 0; ci < ASNM.data.custom.length; ci++) {
            var cc = ASNM.data.custom[ci];
            ASNM.data.entries.push({ asn: cc.id, dest: cc.dest, src: cc.src, subnets: cc.kind === 'ip' ? 1 : -1, loaded: cc.loaded, failed: 0, 'new': cc['new'], kind: cc.kind, value: cc.value, learned: cc.learned, ips: cc.ips || [], note: cc.note || '' });
        }
        ASNM.data.devices.sort(function (a, b) {
            var x = a.ip.split('.'), y = b.ip.split('.');
            for (var i = 0; i < 4; i++) if (+x[i] !== +y[i]) return +x[i] - +y[i];
            return 0;
        });
        asnmRender();
        // the data file is written when something changes - when the page opens and it is older than 2 minutes, the router
        // writes it again (interfaces online, subnets, devices ...), so nobody has to click "Reload data" first
        if (first && ASNM.data.generated && Date.now() / 1000 - ASNM.data.generated > 120)
            setTimeout(function () { if (!ASNM.busy) asnmSend('refresh', []); }, 1500);
    }, function () {
        if (first) asnmSend('refresh', []);
        else asnmSetStatus(t('no_data'), true);
    });
}

// the data file was written by an older script (e.g. the old script that finished an update): ask for fresh data once per session
function asnmVersionFix(v) {
    if (!v || v === ASNM_PAGE_VER) return;
    var k = 'asnm_vfix_' + ASNM_NS + '_' + ASNM_PAGE_VER;
    try { if (sessionStorage.getItem(k)) return; sessionStorage.setItem(k, '1'); } catch (e) { return; }
    asnmSend('refresh', []);
}

function asnmRender() {
    var d = ASNM.data;
    asnmVersionFix(d.version);
    document.getElementById('asnm_version').textContent = 'v' + d.version;
    document.getElementById('asnm_last_apply').textContent = asnmFmtTime(d.last_apply);
    document.getElementById('asnm_generated').textContent = asnmFmtTime(d.generated);
    document.getElementById('asnm_banner').style.display = d.pending ? 'flex' : 'none';
    var subs = 0, up = 0, used = 0;
    for (var si = 0; si < d.entries.length; si++) if (!d.entries[si].kind && d.entries[si].subnets > 0) subs += d.entries[si].subnets;
    for (var sj = 0; sj < d.ifaces.length; sj++) if (d.ifaces[sj].up) up++;
    for (var sk = 0; sk < d.ifaces.length; sk++) if (d.ifaces[sk].exists) used++;
    // ASN tile: number of ASNs, below it the IP / CIDR and domain entries
    var nA = 0, nI = 0, nD = 0;
    for (var se = 0; se < d.entries.length; se++) { var sk2 = d.entries[se].kind; if (!sk2) nA++; else if (sk2 === 'ip') nI++; else if (sk2 === 'dom') nD++; }
    document.getElementById('asnm_stat_asns').innerHTML = nA +
        '<span class="asnm-stat-sub">' + asnmEsc(t('stat_more', { i: nI, d: nD })) + '</span>';
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
    // the status card shows it only when something is wrong (the full line is in Diagnostics)
    document.getElementById('asnm_sched_err').style.display = d.cron ? 'none' : '';
    document.getElementById('asnm_sched_int').value = d.schedule.interval;
    document.getElementById('asnm_sched_time').value = d.schedule.time;

    asnmFillTargets(document.getElementById('asnm_add_dest'));
    asnmFillTargets(document.getElementById('asnm_preset_dest'));
    asnmDevMsRender('asnm_add_ms', 'asnm_add_src');
    asnmDevMsRender('asnm_preset_ms', 'asnm_preset_src');
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

/* ---------- device picker with checkboxes (several devices), writes the IPs into a text field ---------- */
function asnmDevMsIps(inputId) {
    var v = asnmNormSrc(document.getElementById(inputId).value);
    return v ? v.split(',') : [];
}

function asnmDevMsLabel(inputId) {
    var s = asnmDevMsIps(inputId);
    if (!s.length) return t('sg_all');
    if (s.length === 1) return asnmDeviceName(s[0]) || s[0];
    return t('sg_n_dev', { n: s.length });
}

function asnmDevMsRender(boxId, inputId) {
    var box = document.getElementById(boxId);
    if (!box || !ASNM.data) return;
    var wasOpen = / open/.test(' ' + box.className), pop = box.querySelector('.asnm-ms-pop'), top = pop ? pop.scrollTop : 0;
    var s = asnmDevMsIps(inputId), on = {}, i, h, args = "'" + boxId + "','" + inputId + "'";
    for (i = 0; i < s.length; i++) on[s[i]] = 1;
    function item(ip, label) {
        return '<label class="asnm-ms-item"><input type="checkbox" value="' + asnmEsc(ip) + '"' + (on[ip] ? ' checked="checked"' : '') +
               ' onchange="asnmDevMsChange(this, ' + args + ');"/>' + asnmEsc(label) + '</label>';
    }
    h = '<button type="button" class="asnm-ms-btn" onclick="asnmDevMsToggle(event, \'' + boxId + '\');"><span>' + asnmEsc(asnmDevMsLabel(inputId)) + '</span><i></i></button>' +
        '<div class="asnm-ms-pop" onclick="event.stopPropagation();">' +
        '<label class="asnm-ms-item asnm-ms-all"><input type="checkbox"' + (s.length ? '' : ' checked="checked"') + ' onchange="asnmDevMsAll(' + args + ');"/>' + asnmEsc(t('sg_all')) + '</label>';
    var devs = ASNM.data.devices || [], groups = [['lan', t('dev_lan')], ['wg', t('dev_wg')], ['ovpn', t('dev_ovpn')]];
    for (var g = 0; g < groups.length; g++) {
        var part = '';
        for (i = 0; i < devs.length; i++) {
            if ((devs[i].kind || 'lan') !== groups[g][0]) continue;
            var nm = asnmDevLabel(devs[i]);
            part += item(devs[i].ip, (nm ? nm + ' - ' : '') + devs[i].ip);
        }
        if (part) h += '<div class="asnm-ms-grp">' + asnmEsc(groups[g][1]) + '</div>' + part;
    }
    box.innerHTML = h + '</div>';
    box.className = 'asnm-ms' + (wasOpen ? ' open' : '');
    pop = box.querySelector('.asnm-ms-pop'); if (pop) pop.scrollTop = top;
}

function asnmDevMsToggle(ev, boxId) {
    if (ev) ev.stopPropagation();
    var b = document.getElementById(boxId);
    b.className = / open/.test(' ' + b.className) ? 'asnm-ms' : 'asnm-ms open';
}

function asnmDevMsChange(cb, boxId, inputId) {
    var s = asnmDevMsIps(inputId), k = s.indexOf(cb.value);
    if (cb.checked && k < 0) s.push(cb.value);
    if (!cb.checked && k >= 0) s.splice(k, 1);
    document.getElementById(inputId).value = asnmNormSrc(s.join(','));
    asnmDevMsRender(boxId, inputId);
}

function asnmDevMsAll(boxId, inputId) {
    document.getElementById(inputId).value = '';
    asnmDevMsRender(boxId, inputId);
}

function asnmPickDevice(sel, inputId) {
    var inp = document.getElementById(inputId);
    if (sel.value) inp.value = asnmNormSrc((inp.value ? inp.value + ',' : '') + sel.value);
    sel.selectedIndex = 0;
}

// presets: first the category, then the service; below, what it adds (ASNs and domains) and what is already on the list
var ASNM_PCATS = ['stream', 'tvde', 'news', 'gaming', 'social', 'work', 'shop', 'bank', 'services', 'smarthome', 'updates', 'cloud', 'test'];
function asnmPresetCatSel() {
    var c = 'stream';
    try { c = localStorage.getItem('asnm_preset_cat') || 'stream'; } catch (e) {}
    return ASNM_PCATS.indexOf(c) >= 0 ? c : 'stream';
}
function asnmRenderPresets() {
    var cs = document.getElementById('asnm_preset_cat'), cur = cs.value || asnmPresetCatSel(), h = '', n = {}, i;
    var own = {};
    for (i = 0; i < ASNM.data.presets.length; i++) { n[ASNM.data.presets[i].cat] = (n[ASNM.data.presets[i].cat] || 0) + 1; if (ASNM.data.presets[i].own) own[ASNM.data.presets[i].cat] = (own[ASNM.data.presets[i].cat] || 0) + 1; }
    for (i = 0; i < ASNM_PCATS.length; i++) if (n[ASNM_PCATS[i]])
        h += '<option value="' + ASNM_PCATS[i] + '"' + (ASNM_PCATS[i] === cur ? ' selected="selected"' : '') + '>' + asnmEsc(t('pcat_' + ASNM_PCATS[i])) + ' (' + n[ASNM_PCATS[i]] + (own[ASNM_PCATS[i]] ? ', ★ ' + own[ASNM_PCATS[i]] : '') + ')</option>';
    cs.innerHTML = h;
    asnmPresetCat(cs.value, true);
    asnmOwnRender();
    if (document.getElementById('asnm_oe').style.display !== 'none' && document.getElementById('asnm_oe_form').style.display === 'none') asnmOeRender();
}
function asnmPresetCat(cat, keep) {
    try { localStorage.setItem('asnm_preset_cat', cat); } catch (e) {}
    var sel = document.getElementById('asnm_preset'), old = keep ? sel.value : '', html = '';
    for (var i = 0; i < ASNM.data.presets.length; i++) {
        var p = ASNM.data.presets[i];
        if (p.cat !== cat) continue;
        html += '<option value="' + (i + 1) + '"' + (p.own ? ' class="asnm-opt-own"' : '') + '>' + (p.own ? '★ ' : '') + (p.wide ? '⚠ ' : '') + asnmEsc(p.name) + (p.own ? ' (' + asnmEsc(t('preset_own_s')) + ')' : '') + '</option>';
    }
    sel.innerHTML = html;
    if (old && sel.querySelector('option[value="' + old + '"]')) sel.value = old;
    asnmPresetShow();
}
function asnmPresetShow() {
    var box = document.getElementById('asnm_preset_items'), p = ASNM.data.presets[+document.getElementById('asnm_preset').value - 1];
    if (!p) { box.innerHTML = ''; return; }
    var have = {}, en = ASNM.data.entries || [], i, it = String(p.items).split(' '), h = [], on = 0;
    for (i = 0; i < en.length; i++) have[en[i].kind === 'dom' ? 'd:' + en[i].value : (en[i].kind ? '' : 'a:' + en[i].asn)] = asnmNormDest(en[i].dest);
    for (i = 0; i < it.length; i++) {
        if (!it[i]) continue;
        var isA = /^\d+$/.test(it[i]), k = (isA ? 'a:' : 'd:') + it[i], tg = have[k];
        if (tg) on++;
        h.push('<span class="asnm-ex' + (tg ? ' asnm-ex-on' : '') + '"' + (tg ? ' title="' + asnmEsc(t('preset_on', { t: tg })) + '"' : '') + '>' + asnmEsc(isA ? 'AS' + it[i] : it[i]) + '</span>');
    }
    box.innerHTML = (p.own ? '<div class="asnm-preset-own">★ ' + asnmEsc(t('preset_own')) + '</div>' : '') +
                    h.join(' ') + (on ? ' <span class="asnm-muted">' + asnmEsc(t('preset_have', { n: on, m: h.length })) + '</span>' : '');
}

function asnmSrcCell(src) {
    if (!src) return '<span class="asnm-muted">' + asnmEsc(t('all_devices')) + '</span>';
    var p = String(src).split(','), out = [];
    for (var i = 0; i < p.length; i++) {
        var n = asnmDeviceName(p[i]);
        out.push(asnmEsc(p[i]) + (n ? ' <span class="asnm-dev">' + asnmEsc(n) + '</span>' : ''));
    }
    return '<div class="asnm-src-list">' + out.join('<br/>') + '</div>';
}

// the list in three sections: ASNs, IP / CIDR ranges, domains - each grouped by target
var ASNM_SECS = [
    { k: 'asn', test: function (e) { return !e.kind; } },
    { k: 'ip',  test: function (e) { return e.kind === 'ip'; } },
    { k: 'dom', test: function (e) { return e.kind === 'dom'; } }
];

function asnmRenderList() {
    var all = ASNM.data.entries.slice(0);
    all.sort(function (a, b) {
        var o = ASNM.order.indexOf(a.dest) - ASNM.order.indexOf(b.dest);
        return o !== 0 ? o : (asnmEntryNum(a.asn) - asnmEntryNum(b.asn));
    });
    var rcMap = asnmRcMap(), html = '', total = 0, nAsn = 0;
    for (var q = 0; q < ASNM_SECS.length; q++) {
        var sec = ASNM_SECS[q], list = all.filter(sec.test);
        if (sec.k === 'asn') nAsn = list.length;
        html += asnmListSection(sec.k, list, rcMap);
        for (var z = 0; z < list.length; z++) if (!list[z].kind && list[z].subnets > 0) total += list[z].subnets;
    }
    document.getElementById('asnm_list').innerHTML = html;
    document.getElementById('asnm_list_summary').textContent = t('summary', { n: nAsn, s: total });
    // while a row is edited the list's frame must not clip the device picker
    document.getElementById('asnm_list').parentNode.style.overflow = ASNM.editing ? 'visible' : '';
    if (ASNM.editing) asnmDevMsRender('asnm_edit_ms', 'asnm_edit_src');
    asnmApplyBusy();
}

function asnmListSection(sec, entries, rcMap) {
    var ico = {
        asn: '<circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3a14 14 0 0 1 0 18M12 3a14 14 0 0 0 0 18"/>',
        ip:  '<rect x="3" y="4" width="18" height="6" rx="1.5"/><rect x="3" y="14" width="18" height="6" rx="1.5"/><path d="M7 7h.01M7 17h.01"/>',
        dom: '<path d="M10 14a4 4 0 0 0 5.66 0l3-3a4 4 0 0 0-5.66-5.66l-1 1"/><path d="M14 10a4 4 0 0 0-5.66 0l-3 3a4 4 0 0 0 5.66 5.66l1-1"/>'
    }[sec];
    var html = '<div class="asnm-lsec"><div class="asnm-lsec-head">' +
               '<svg class="asnm-lsec-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">' + ico + '</svg>' +
               '<span class="asnm-lsec-title">' + asnmEsc(t('ls_' + sec)) + '</span>' +
               '<span class="asnm-lsec-cnt' + (entries.length ? '' : ' asnm-zero') + '">' + entries.length + '</span></div>' +
               '<table class="asnm-table"><tr><th style="width:24px;"><input type="checkbox" onclick="asnmToggleAll(this.checked, \'' + sec + '\')"/></th>' +
               '<th>' + t('ls_th_' + sec) + '</th><th>' + t('th_src') + '</th><th style="text-align:right;">' + t(sec === 'dom' ? 'ls_th_learned' : 'th_subnets') + '</th>' +
               '<th>' + t('th_state') + '</th><th>' + t('rc_th') + '</th><th></th></tr>';
    if (!entries.length) html += '<tr><td colspan="7" class="asnm-muted" style="text-align:center;padding:12px;">' + asnmEsc(t('ls_empty_' + sec)) + '</td></tr>';

    // per-target totals for the group headers
    var groups = {};
    for (var g = 0; g < entries.length; g++) {
        var ge = entries[g], gs = groups[ge.dest] || (groups[ge.dest] = { n: 0, s: 0, f: 0, l: 0 });
        gs.n++; if (ge.subnets > 0) gs.s += ge.subnets; if (ge.failed) gs.f++; gs.l += ge.learned || 0;
    }

    var lastDest = null;
    for (var i = 0; i < entries.length; i++) {
        var e = entries[i], a = asnmEsc(e.asn), gk = (sec === 'asn' ? '' : sec + '|') + e.dest;
        var closed = asnmIsClosed(gk, groups[e.dest]);
        if (e.dest !== lastDest) {
            var f = asnmIface(e.dest), gi = groups[e.dest];
            var st = f ? (f.up ? '<span class="asnm-badge asnm-ok">' + t('online') + '</span>' : '<span class="asnm-badge asnm-bad">' + t('offline') + '</span>') : '';
            html += '<tr class="asnm-group" onclick="asnmToggleGroup(\'' + asnmEsc(gk) + '\')"><td colspan="7">' +
                    '<span class="asnm-arrow' + (closed ? '' : ' asnm-open') + '"></span>' +
                    asnmEsc(asnmDestLabel(e.dest)) + (f && f.dev ? ' - ' + asnmEsc(f.dev) : '') + ' &nbsp; ' + st + asnmFoBadge(e.dest) +
                    '<span class="asnm-gsum">' + asnmEsc(t('ls_gsum_' + sec, { n: gi.n, s: gi.s, l: gi.l })) +
                    (gi.f ? '<span class="asnm-badge asnm-bad">' + asnmEsc(t('group_failed', { f: gi.f })) + '</span>' : '') +
                    '<span class="asnm-grc" data-grc="' + asnmEsc(gk) + '">' + asnmGroupRcHtml(gk, rcMap) + '</span></span></td></tr>';
            lastDest = e.dest;
        }
        if (closed) continue;

        if (ASNM.editing === e.asn) {
            html += '<tr class="asnm-editing"><td></td><td>' + asnmEntryCell(e) +
                '<label class="asnm-edit-lbl" for="asnm_edit_note">' + asnmEsc(t('note_lbl')) + '</label><input type="text" id="asnm_edit_note" class="input_15_table asnm-note-in" maxlength="60" value="' + asnmEsc(e.note || '') + '" placeholder="' + asnmEsc(t('note_ph')) + '"/></td>' +
                '<td colspan="4"><select id="asnm_edit_dest" class="input_option">' + asnmTargetOptions(asnmNormDest(e.dest)) + '</select><br/>' +
                '<input type="text" id="asnm_edit_src" class="input_15_table" maxlength="600" style="margin-top:6px;width:230px;" oninput="asnmDevMsRender(\'asnm_edit_ms\',\'asnm_edit_src\');" value="' + asnmEsc(e.src) + '" placeholder="' + asnmEsc(t('src_empty')) + '"/>' +
                '<div class="asnm-ms" id="asnm_edit_ms" style="margin:6px 0 0 6px;vertical-align:top;"></div></td>' +
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

        var num;
        if (sec === 'dom') num = '<span class="asnm-link" id="asnm_lr_' + a + '" title="' + asnmEsc(t('lr_tip')) + '" onclick="asnmLrToggle(\'' + a + '\');">' + (e.learned || 0) + '</span>';
        else num = e.subnets >= 0 ? e.subnets : '<span class="asnm-muted">-</span>';

        html += '<tr' + rowCls + '><td><input type="checkbox" class="asnm-chk asnm-chk-' + sec + '" value="' + a + '"/></td>' +
                '<td>' + (sec === 'asn' ? asnmEntryCell(e) : asnmEsc(sec === 'dom' ? '*.' + e.value : e.value) + ' <span class="asnm-muted asnm-cid">' + a + '</span>') + asnmNoteHtml(e) + '</td><td>' + asnmSrcCell(e.src) + '</td>' +
                '<td class="num">' + num + '</td>' +
                '<td>' + state + '</td>' +
                '<td id="asnm_rc_' + a + '">' + asnmRcBadge(e, rcMap) + '</td>' +
                '<td class="asnm-actions"><input type="button" class="button_gen asnm-small-btn asnm-btn" value="' + asnmEsc(t('btn_edit')) + '" onclick="asnmEdit(\'' + a + '\')"/> ' +
                '<input type="button" class="button_gen asnm-small-btn asnm-btn" value="' + asnmEsc(t('btn_remove')) + '" onclick="asnmRemove([\'' + a + '\'])"/></td></tr>';
        if (sec === 'dom' && ASNM.lrOpen === e.asn) html += asnmLrRow(e);
    }
    return html + '</table></div>';
}

/* ---------- speed test ---------- */
var ASNM_SP = { data: null };

function asnmSpLoad() {
    asnmGet('speedtest.js', function (txt) {
        try { ASNM_SP.data = JSON.parse(txt); } catch (e) { ASNM_SP.data = null; }
        if (ASNM.data) asnmRenderIfaces();
    }, function () { ASNM_SP.data = null; });
}

function asnmSpCell(f) {
    var r = ASNM_SP.data && ASNM_SP.data.res && ASNM_SP.data.res[f.id], h;
    h = '<input type="button" class="button_gen asnm-small-btn asnm-btn" value="' + asnmEsc(t('sp_btn')) + '"' + (f.up ? '' : ' disabled="disabled"') + ' onclick="asnmSpStart(\'' + f.id + '\');"/>';
    if (r) {
        var when = new Date(r.ts * 1000).toLocaleTimeString();
        if (r.e && r.e !== '-') h += '<div class="asnm-sp-res asnm-rc-bad">' + asnmEsc(t('sp_err_' + r.e) === 'sp_err_' + r.e ? t('sp_err_fail') : t('sp_err_' + r.e)) + ' · ' + asnmEsc(when) + '</div>';
        else h += '<div class="asnm-sp-res">↓ <b>' + asnmFmtRate(r.d) + '</b> ↑ <b>' + asnmFmtRate(r.u) + '</b> ' + asnmUnitLabel() + '<br/>' +
                  asnmEsc(t('sp_ping', { l: (+r.l).toLocaleString(asnmLocale(), { maximumFractionDigits: 1 }) })) + ' · ' + asnmEsc(when) + '</div>';
    }
    return h;
}

function asnmSpStart(id) {
    if (ASNM.busy) return;
    if (!confirm(t('sp_confirm', { i: id }))) return;
    asnmSend('speedtest', [id]);
}

function asnmRenderIfaces() {
    var html = '<table class="asnm-table"><tr><th>' + t('th_target') + '</th><th>' + t('th_device') + '</th><th>' + t('th_state') + '</th>' +
               '<th>' + t('th_pubip') + '</th><th style="text-align:right;">' + t('tr_live') + ' (' + asnmUnitLabel() + ')</th><th>' + t('sp_th') + '</th><th style="text-align:right;">' + t('th_asns') + '</th></tr>';
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
        html += '<tr><td>' + asnmEsc(asnmDestLabel(f.id)) + '</td><td>' + asnmEsc(f.dev || '-') + '</td><td>' + st + '</td><td>' + pub + '</td><td class="asnm-iflive">' + asnmIfaceLive(f.id) + '</td><td class="asnm-sp">' + asnmSpCell(f) + '</td><td class="num">' + n + '</td></tr>';
        if (i === ASNM.data.ifaces.length - 1) setTimeout(asnmFoRender, 0);
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

function asnmSecOf(e) { return e.kind === 'ip' ? 'ip' : (e.kind === 'dom' ? 'dom' : 'asn'); }
function asnmGroupKey(e) { var s = asnmSecOf(e); return (s === 'asn' ? '' : s + '|') + e.dest; }

function asnmToggleGroup(key) {
    var gi = { f: 0 };
    if (ASNM.data) for (var i = 0; i < ASNM.data.entries.length; i++)
        if (asnmGroupKey(ASNM.data.entries[i]) === key && ASNM.data.entries[i].failed) gi.f++;
    ASNM.collapsed[key] = !asnmIsClosed(key, gi);
    asnmSaveCollapsed();
    asnmRenderList();
}

function asnmCollapseAll(on) {
    if (!ASNM.data) return;
    for (var i = 0; i < ASNM.data.entries.length; i++) ASNM.collapsed[asnmGroupKey(ASNM.data.entries[i])] = on;
    asnmSaveCollapsed();
    asnmRenderList();
}

function asnmSaveCollapsed() { try { localStorage.setItem('asnm_collapsed_' + ASNM_NS, JSON.stringify(ASNM.collapsed)); } catch (e) {} }
function asnmLoadCollapsed() { try { ASNM.collapsed = JSON.parse(localStorage.getItem('asnm_collapsed_' + ASNM_NS) || '{}') || {}; } catch (e) { ASNM.collapsed = {}; } }

function asnmToggleAll(on, sec) {
    var c = document.getElementsByClassName(sec ? 'asnm-chk-' + sec : 'asnm-chk');
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

function asnmActLabel(a) { var k = 'act_' + a, v = t(k); return v === k ? a : v; }

// follow a job the page did not start itself (started earlier, from another tab / device)
function asnmFollowJob(id, action, rejected) {
    ASNM.queue = [];
    ASNM.jobId = String(id); ASNM.jobAction = action; ASNM.jobStart = Date.now();
    ASNM.jobTimeout = ASNM.timeouts[action] || 60000;
    asnmSetBusy(true, action);
    asnmSetStatus(t(rejected ? 'job_busy' : 'job_running', { a: asnmActLabel(action) }), false);
    clearTimeout(ASNM.pollTimer);
    ASNM.pollTimer = setTimeout(asnmPoll, 1500);
}

// on page load: a job that still runs is shown and blocks the buttons until it is finished
function asnmAdoptJob() {
    asnmGet('job.js', function (txt) {
        var job = null;
        try { job = JSON.parse(txt); } catch (e) {}
        if (!job || job.state !== 'running' || ASNM.busy) return;
        if (Date.now() / 1000 - job.ts > 3600) return;             // left over from a job that never finished
        asnmFollowJob(job.id, job.action, false);
    });
}

function asnmPoll() {
    asnmGet('job.js', function (txt) {
        var job = null;
        try { job = JSON.parse(txt); } catch (e) {}
        if (job && job.id === ASNM.jobId) {
            // refused because another job runs: follow that one instead
            if (job.state === 'error' && job.busyid && job.busyid !== ASNM.jobId) { asnmFollowJob(job.busyid, job.busy, true); return; }
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
    // tools of the Diagnostics tab: their last output line means nothing on its own - the result is in the output box there
    var tools = ['test', 'trace', 'ifaces', 'status', 'explain', 'device', 'devices', 'dnschain', 'diagpack', 'lookup'];
    if (tools.indexOf(job.action) >= 0) asnmSetStatus(t(ok ? 'tool_done' : 'tool_failed', { a: asnmActLabel(job.action) }), !ok);
    else asnmSetStatus(asnmTrMsg(job.msg) || (ok ? t('done') : t('failed')), !ok);

    if (['apply', 'reload', 'retry', 'test', 'trace', 'lookup', 'ifaces', 'status', 'explain', 'device', 'devices', 'dnschain', 'diagpack'].indexOf(job.action) >= 0) {
        asnmGet('output.htm', function (txt) { document.getElementById('asnm_output').textContent = txt || t('no_output'); });
    }
    if (job.action === 'lookup') {
        asnmGet('output.htm', function (txt) { asnmRenderLookup(txt, ok, job.msg); },
                function () { asnmRenderLookup('', false, job.msg); });
    }
    if ((job.action === 'edit' || job.action === 'note') && ok) ASNM.editing = null;
    if (job.action === 'speedtest') asnmSpLoad();
    asnmDnsLoad();
    if (job.action === 'setting') { asnmTrLoad(); asnmSgLoad(); setTimeout(asnmPerfMark, 1500); }
    if (job.action === 'update') {
        if (ok && /^Updated to/.test(job.msg || '')) { setTimeout(function () { ASNM_UPD.reload(); }, 2500); return; }   // new script + page are in place
        asnmUpdCheck(false);                                                                                          // refresh the notice
    }
    if (job.action === 'statssave') asnmTrLoad();
    if (job.action === 'sghide') asnmSgLoad();
    if (job.action === 'diagpack' && ok) asnmDiagPackReady();
    asnmRcLoad(false);                                                                                                // "apply" runs a routing check
    asnmFoLoad();

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
    if (on) asnmSetStatus(action === 'apply' ? t('applying') : action === 'reload' ? t('reloading') : (action === 'retry' ? t('retrying') : (action === 'update' ? t('upd_running') : (action === 'speedtest' ? t('sp_running') : t('working')))));
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
// source devices: empty = all devices, one IP or a comma separated list (max. 32)
function asnmNormSrc(v) {
    var out = [], seen = {}, p = String(v || '').split(',');
    for (var i = 0; i < p.length; i++) { var x = p[i].replace(/\s+/g, ''); if (x && !seen[x]) { seen[x] = 1; out.push(x); } }
    return out.join(',');
}
function asnmValidSrc(v) {
    v = asnmNormSrc(v);
    if (!v) return true;
    var p = v.split(',');
    if (p.length > 32) return false;
    for (var i = 0; i < p.length; i++) if (!ASNM.reIp.test(p[i])) return false;
    return true;
}

/* ---------- entries: ASN, IP/CIDR range or domain ---------- */
function asnmEntryKind(tok) {
    if (/^(AS|as)?\d{1,10}$/.test(tok)) return 'asn';
    var m = /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})(?:\/(\d{1,2}))?$/.exec(tok);
    if (m) {
        for (var i = 1; i <= 4; i++) if (+m[i] > 255) return '';
        if (m[5] !== undefined && (+m[5] < 8 || +m[5] > 32)) return '';
        return 'ip';
    }
    if (/^(\*\.|\.)?([A-Za-z0-9]([A-Za-z0-9-]{0,61}[A-Za-z0-9])?\.)+[A-Za-z][A-Za-z0-9-]{0,61}\.?$/.test(tok)) return 'dom';
    return '';
}

function asnmParseEntries(str) {
    var toks = String(str || '').split(/[\s,;]+/), ok = [], bad = [], dom = false;
    for (var i = 0; i < toks.length; i++) {
        if (!toks[i]) continue;
        var k = asnmEntryKind(toks[i]);
        if (!k) { bad.push(toks[i]); continue; }
        if (k === 'dom') { dom = true; ok.push(toks[i].replace(/^(\*\.|\.)/, '').replace(/\.$/, '')); } else ok.push(toks[i]);
    }
    return { ok: ok, bad: bad, dom: dom };
}

function asnmAddHint() {
    var el = document.getElementById('asnm_add_domnote');
    if (el) el.style.display = asnmParseEntries(document.getElementById('asnm_add_asns').value).dom ? 'block' : 'none';
}

// sentence form: the device picker covers known devices; typing IPs is behind a link
function asnmAddSrcToggle(force) {
    var box = document.getElementById('asnm_add_srcbox'), on = force !== undefined ? force : box.style.display === 'none';
    box.style.display = on ? 'flex' : 'none';
    document.getElementById('asnm_add_srclink').textContent = t(on ? 'add_src_hide' : 'add_src_type');
}

function asnmAdd() {
    var p = asnmParseEntries(document.getElementById('asnm_add_asns').value);
    var src = asnmNormSrc(document.getElementById('asnm_add_src').value);
    if (!p.ok.length || p.bad.length) { alert(t('a_asns') + (p.bad.length ? '\n\n' + p.bad.slice(0, 5).join(', ') : '')); return; }
    if (!asnmValidSrc(src)) { alert(t('a_ip')); return; }
    var note = document.getElementById('asnm_add_note').value.replace(/[\u0000-\u001f"\\|<>]/g, '').trim().slice(0, 60);
    if (asnmSend('add', [document.getElementById('asnm_add_dest').value, src, p.ok.join(','), encodeURIComponent(note)])) {
        document.getElementById('asnm_add_asns').value = '';
        document.getElementById('asnm_add_note').value = '';
        asnmAddHint();
    }
}

// list rows: ASN, IP range or domain
function asnmEntryNum(id) { return /^C/.test(id) ? 1e12 + parseInt(String(id).slice(1), 10) : parseInt(id, 10); }
function asnmEntryLabel(e) { return e.kind === 'ip' ? 'IP ' + e.value : (e.kind === 'dom' ? '*.' + e.value : 'AS' + e.asn); }
function asnmLabelById(id) {
    var en = (ASNM.data && ASNM.data.entries) || [];
    for (var i = 0; i < en.length; i++) if (en[i].asn === id) return asnmEntryLabel(en[i]);
    return 'AS' + id;
}
// learned addresses of a domain entry (data.js carries the first 200)
function asnmLrRow(e) {
    var ips = e.ips || [], h = '<tr class="asnm-lr"><td></td><td colspan="6"><b>' + asnmEsc(t('lr_head', { d: e.value })) + '</b><div class="asnm-lr-list">';
    if (!ips.length) h += '<span class="asnm-muted">' + asnmEsc(t('lr_none')) + '</span>';
    for (var i = 0; i < ips.length; i++) h += '<code>' + asnmEsc(ips[i]) + '</code> ';
    h += '</div>';
    if ((e.learned || 0) > ips.length) h += '<div class="asnm-muted">' + asnmEsc(t('lr_more', { n: e.learned - ips.length, id: e.asn })) + '</div>';
    return h + '<div class="asnm-muted">' + asnmEsc(t('lr_note')) + '</div></td></tr>';
}
function asnmLrToggle(id) {
    ASNM.lrOpen = ASNM.lrOpen === id ? null : id;
    asnmRender();
    // the list in data.js may be older than the number: fetch fresh data once when opening
    if (ASNM.lrOpen && !ASNM.busy) asnmSend('refresh', []);
}
// live numbers: learned.js is rewritten by the statistics loop (every few seconds while counting runs) and on every refresh
function asnmLrLoad() {
    if (!ASNM.data || !ASNM.data.entries || ASNM.editing) return;
    var any = false;
    for (var i = 0; i < ASNM.data.entries.length; i++) if (ASNM.data.entries[i].kind === 'dom') { any = true; break; }
    if (!any) return;
    asnmGet('learned.js', function (txt) {
        var d = null; try { d = JSON.parse(txt); } catch (e) { return; }
        if (!d || !d.c || !ASNM.data) return;
        for (var j = 0; j < ASNM.data.entries.length; j++) {
            var e = ASNM.data.entries[j];
            if (e.kind !== 'dom' || d.c[e.asn] === undefined || d.c[e.asn] === e.learned) continue;
            e.learned = d.c[e.asn];
            var el = document.getElementById('asnm_lr_' + e.asn);
            if (el) el.textContent = e.learned;
        }
    });
}

// stats row name: ASN, or the custom entry (IP range / domain) behind an id like "C3"
function asnmTrRowLabel(r) {
    if (/^C\d+$/.test(r.asn) && ASNM.data && ASNM.data.entries)
        for (var i = 0; i < ASNM.data.entries.length; i++) {
            var e = ASNM.data.entries[i];
            if (e.asn === r.asn && e.kind) return asnmEntryCell(e);
        }
    // a removed IP / domain entry: what it was (remembered on removal)
    var g = ASNM.data && ASNM.data.removed && ASNM.data.removed[r.asn];
    if (g) return asnmEntryCell({ kind: g[0], value: g[1] }) + ' <span class="asnm-muted asnm-cid">' + asnmEsc(r.asn) + '</span>';
    return /^C\d+$/.test(r.asn) ? asnmEsc(r.asn) : 'AS' + asnmEsc(r.asn);
}
// second line of a stats row: the ASN name (cut with "..." so long names do not push the numbers out of view)
function asnmTrNameLine(r) {
    if (/^C\d+$/.test(r.asn)) return '';
    var nm = asnmNameOf(r.asn);
    return nm ? '<span class="asnm-tr-name" title="' + asnmEsc(nm) + '">' + asnmEsc(nm) + '</span>' : '';
}

// holder as RIPE gives it ("DIGITALOCEAN-ASN - DigitalOcean, LLC") -> the readable part ("DigitalOcean, LLC")
function asnmAsName(n) {
    n = String(n || '');
    var k = n.indexOf(' - ');
    if (k > 0 && k < n.length - 3) n = n.slice(k + 3);
    else {
        // leading RIPE handle: "DPAG-AS DHL AG", "netcup-AS netcup GmbH", "NORIS-NETWORK noris network AG"
        var m = /^(\S+)\s+(.{2,})$/.exec(n);
        if (m && (/(^AS\d|-AS\d*$|^AS-|-ASN\d*$)/i.test(m[1]) || (/^[A-Z0-9][A-Z0-9_.-]*$/.test(m[1]) && /[a-z]/.test(m[2])))) n = m[2];
    }
    return n.replace(/,\s*[A-Z]{2}$/, '').trim();
}
function asnmNameOf(asn) {
    var en = (ASNM.data && ASNM.data.entries) || [];
    for (var i = 0; i < en.length; i++) if (en[i].asn === String(asn) && en[i].name) return asnmAsName(en[i].name);
    return '';
}
function asnmNoteHtml(e) { return e.note ? '<div class="asnm-note"><span class="asnm-note-lbl">' + asnmEsc(t('note_lbl')) + ':</span> ' + asnmEsc(e.note) + '</div>' : ''; }

function asnmEntryCell(e) {
    if (e.kind === 'ip') return '<span class="asnm-kind">' + asnmEsc(t('kind_ip')) + '</span> ' + asnmEsc(e.value);
    if (e.kind === 'dom') return '<span class="asnm-kind">' + asnmEsc(t('kind_dom')) + '</span> *.' + asnmEsc(e.value);
    var nm = asnmAsName(e.name);
    return 'AS' + asnmEsc(e.asn) + (nm ? ' <span class="asnm-asname" title="' + asnmEsc(e.name) + '">' + asnmEsc(nm) + '</span>' : '');
}

function asnmAddPreset() {
    var src = asnmNormSrc(document.getElementById('asnm_preset_src').value);
    if (!asnmValidSrc(src)) { alert(t('a_ip')); return; }
    var pi = +document.getElementById('asnm_preset').value - 1, pr = ASNM.data.presets[pi];
    if (pr && pr.wide && !confirm(t('preset_wide', { n: pr.name }))) return;
    asnmSend('preset', [document.getElementById('asnm_preset').value, document.getElementById('asnm_preset_dest').value, src]);
}

function asnmEdit(asn) {
    if (ASNM.busy) return;
    ASNM.editing = asn;
    if (asn && ASNM.data) for (var i = 0; i < ASNM.data.entries.length; i++)
        if (ASNM.data.entries[i].asn === asn) ASNM.collapsed[asnmGroupKey(ASNM.data.entries[i])] = false;
    asnmRenderList();
}

function asnmEditSave(asn) {
    var dest = document.getElementById('asnm_edit_dest').value;
    var src = asnmNormSrc(document.getElementById('asnm_edit_src').value);
    if (!asnmValidSrc(src)) { alert(t('a_ip')); return; }
    var nEl = document.getElementById('asnm_edit_note'), note = nEl ? nEl.value.replace(/[\u0000-\u001f"\\|<>]/g, '').trim().slice(0, 60) : null, old = '', e0 = null;
    for (var i = 0; i < ASNM.data.entries.length; i++) if (ASNM.data.entries[i].asn === asn) { e0 = ASNM.data.entries[i]; old = e0.note || ''; }
    var jobs = [];
    if (!e0 || asnmNormDest(e0.dest) !== dest || asnmNormSrc(e0.src) !== src) jobs.push(['edit', [asn, dest, src]]);
    if (note !== null && note !== old) jobs.push(['note', [asn, encodeURIComponent(note)]]);
    if (!jobs.length) { asnmEdit(null); return; }
    asnmSendQueue(jobs);
}

function asnmRemove(list) {
    if (!list.length) { alert(t('a_nothing')); return; }
    if (!confirm(list.length === 1 ? t('c_remove_one', { asn: asnmLabelById(list[0]) }) : t('c_remove_n', { n: list.length }))) return;
    asnmSend('remove', [list.join(',')]);
}

function asnmRemoveSelected() {
    var c = document.getElementsByClassName('asnm-chk'), l = [];
    for (var i = 0; i < c.length; i++) if (c[i].checked) l.push(c[i].value);
    asnmRemove(l);
}

function asnmClearAll() {
    var a = 0, ip = 0, dm = 0, en = (ASNM.data && ASNM.data.entries) || [];
    for (var i = 0; i < en.length; i++) { if (!en[i].kind) a++; else if (en[i].kind === 'ip') ip++; else dm++; }
    if (!en.length) { alert(t('no_asns')); return; }
    var w = t('clear_word'), v = prompt(t('c_clear_type', { a: a, i: ip, d: dm, w: w }), '');
    if (v === null) return;
    if (v.trim().toUpperCase() !== w.toUpperCase()) { alert(t('clear_wrong')); return; }
    asnmSend('clear', []);
}
function asnmApply() { asnmSend('apply', []); }
function asnmApplyFull() { if (confirm(t('c_full'))) asnmSend('reload', []); }
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

// diagnostics: explain a destination (optionally for the chosen device), check a device, diagnostic bundle
function asnmExplain() {
    var v = document.getElementById('asnm_diag').value.trim().replace(/^https?:\/\//, '').split('/')[0].split(':')[0];
    if (!ASNM.reHost.test(v)) { alert(t('a_host')); return; }
    document.getElementById('asnm_output').textContent = t('running_x', { a: t('btn_explain') });
    asnmSend('explain', [v, document.getElementById('asnm_diag_dev').value]);
}
function asnmDevCheck() {
    var ip = document.getElementById('asnm_diag_dev').value;
    if (!ip) { alert(t('a_dev')); return; }
    document.getElementById('asnm_output').textContent = t('running_x', { a: t('btn_device') });
    asnmSend('device', [ip]);
}
function asnmDiagDevFill() {
    var sel = document.getElementById('asnm_diag_dev');
    if (!sel) return;
    var cur = sel.value, devs = (ASNM.data && ASNM.data.devices) || [], h = '<option value="">' + asnmEsc(t('diag_dev_any')) + '</option>';
    for (var i = 0; i < devs.length; i++) {
        var n = asnmDevLabel(devs[i]);
        h += '<option value="' + asnmEsc(devs[i].ip) + '"' + (devs[i].ip === cur ? ' selected="selected"' : '') + '>' + asnmEsc((n ? n + ' - ' : '') + devs[i].ip) + '</option>';
    }
    sel.innerHTML = h;
}
function asnmDiagPackReady() {
    var d = new Date(), z = function (x) { return (x < 10 ? '0' : '') + x; };
    var name = 'asnmanager-diag-' + d.getFullYear() + z(d.getMonth() + 1) + z(d.getDate()) + '-' + z(d.getHours()) + z(d.getMinutes()) + '.txt';
    var dl = document.getElementById('asnm_dp_dl');
    dl.href = '#'; dl.removeAttribute('download');
    dl.onclick = function (ev) { ev.preventDefault(); asnmDiagDownload(name); };
    var body = t('dp_issue_body', { f: name, v: ASNM_PAGE_VER });
    document.getElementById('asnm_dp_gh').href = 'https://github.com/Outlooieu/ASNmanager/issues/new?title=' + encodeURIComponent(t('dp_issue_title')) + '&body=' + encodeURIComponent(body);
    document.getElementById('asnm_dp_links').style.display = '';
}

// the file is fetched like the other data files and handed to the browser as a download (works on phones too)
// own presets: download them as presets.txt (to share), add a presets.txt from someone else
function asnmOwnRender() {
    var el = document.getElementById('asnm_own_info');
    if (!el || !ASNM.data) return;
    var n = 0, p = ASNM.data.presets || [];
    for (var i = 0; i < p.length; i++) if (p[i].own) n++;
    el.textContent = n ? t('own_count', { n: n }) : t('own_none');
}
function asnmOwnDownload() {
    var p = (ASNM.data && ASNM.data.presets) || [], out = ['# ASN Manager - own presets (category|Name|ASNs and domains|wide)'], i;
    for (i = 0; i < p.length; i++) if (p[i].own) out.push(p[i].cat + '|' + p[i].name + '|' + p[i].items + '|' + (p[i].wide ? 'wide' : ''));
    if (out.length < 2) { alert(t('own_none')); return; }
    var url = URL.createObjectURL(new Blob([out.join('\n') + '\n'], { type: 'text/plain;charset=utf-8' })), a = document.createElement('a');
    a.href = url; a.download = 'asnmanager-presets.txt'; a.style.display = 'none';
    document.body.appendChild(a); a.click();
    setTimeout(function () { URL.revokeObjectURL(url); a.parentNode.removeChild(a); }, 2000);
}
function asnmOwnFile(inp) {
    var f = inp.files && inp.files[0];
    if (!f) return;
    var rd = new FileReader();
    rd.onload = function () {
        inp.value = '';
        var lines = String(rd.result || '').split(/\r?\n/), ok = [], bad = 0, i;
        for (i = 0; i < lines.length; i++) {
            var l = lines[i].replace(/^\s+|\s+$/g, '');
            if (!l || l.charAt(0) === '#') continue;
            if (/^[a-z]+\|[^|]+\|[^|]+\|(wide)?$/.test(l)) ok.push(l); else bad++;
        }
        if (!ok.length) { alert(t('own_bad_file')); return; }
        var rep = document.getElementById('asnm_own_replace').checked;
        if (!confirm(t(rep ? 'own_c_replace' : 'own_c_add', { n: ok.length, b: bad }))) return;
        // amng_custom values are size limited -> chunks; each line %XX-encoded (keeps "|" and spaces)
        var jobs = [], chunk = [], len = 0, first = true;
        for (i = 0; i < ok.length; i++) {
            var e = encodeURIComponent(ok[i]);
            if (len + e.length + 1 > ASNM.chunkChars && chunk.length) { jobs.push(['pimport', [first && rep ? 'replace' : 'merge', chunk.join(';')]]); first = false; chunk = []; len = 0; }
            chunk.push(e); len += e.length + 1;
        }
        if (chunk.length) jobs.push(['pimport', [first && rep ? 'replace' : 'merge', chunk.join(';')]]);
        asnmSendQueue(jobs);
    };
    rd.readAsText(f);
}

// editor for own presets: new / edit / delete, written to the file the preset comes from (/jffs or USB device)
ASNM.oe = { idx: -1 };
function asnmOeToggle() {
    var el = document.getElementById('asnm_oe');
    el.style.display = el.style.display === 'none' ? '' : 'none';
    asnmOeEdit(-2);
}
function asnmOeFileLabel(f) {
    var m = /^\/tmp\/mnt\/([^\/]+)\//.exec(f || '');
    return m ? t('oe_usb', { n: m[1] }) : t('oe_jffs');
}
function asnmOeRender() {
    var box = document.getElementById('asnm_oe_list');
    if (!box || !ASNM.data) return;
    var p = ASNM.data.presets || [], h = '', i, n = 0;
    for (i = 0; i < p.length; i++) {
        if (!p[i].own) continue;
        n++;
        var c = String(p[i].items).split(' ').length;
        h += '<div class="asnm-oe-row"><span class="asnm-oe-n"><span>★ ' + asnmEsc(p[i].name) + '</span><span class="asnm-oe-m">' + asnmEsc(t('pcat_' + p[i].cat)) + ' · ' + t(c === 1 ? 'oe_count1' : 'oe_count', { n: c }) + ' · ' + asnmEsc(asnmOeFileLabel(p[i].file)) + '</span></span>' +
             '<input type="button" class="button_gen asnm-ghost asnm-small-btn" value="' + asnmEsc(t('act_edit')) + '" onclick="asnmOeEdit(' + i + ');"/>' +
             '<input type="button" class="button_gen asnm-ghost asnm-small-btn" value="' + asnmEsc(t('oe_del')) + '" onclick="asnmOeDel(' + i + ');"/></div>';
    }
    if (!n) h = '<div class="asnm-help">' + asnmEsc(t('own_none')) + '</div>';
    h += '<div class="asnm-row" style="margin-top:8px;"><input type="button" class="button_gen asnm-btn asnm-small-btn" value="' + asnmEsc(t('oe_new')) + '" onclick="asnmOeEdit(-1);"/></div>';
    box.innerHTML = h;
}
// i = index in ASNM.data.presets, -1 = new preset, -2 = close the form
function asnmOeEdit(i) {
    var form = document.getElementById('asnm_oe_form');
    ASNM.oe.idx = i;
    asnmOeRender();
    if (i === -2) { form.style.display = 'none'; return; }
    var p = i >= 0 ? ASNM.data.presets[i] : null, cs = document.getElementById('asnm_oe_cat'), fs = document.getElementById('asnm_oe_file'), h = '', k;
    for (k = 0; k < ASNM_PCATS.length; k++) h += '<option value="' + ASNM_PCATS[k] + '">' + asnmEsc(t('pcat_' + ASNM_PCATS[k])) + '</option>';
    cs.innerHTML = h;
    var files = ASNM.data.pfiles || ['/jffs/addons/asnmanager/presets.txt'];
    h = '';
    for (k = 0; k < files.length; k++) h += '<option value="' + asnmEsc(files[k]) + '">' + asnmEsc(asnmOeFileLabel(files[k])) + '</option>';
    fs.innerHTML = h;
    if (!p && files.length > 1) fs.value = files[1];                       // new presets go to the USB device when there is one
    document.getElementById('asnm_oe_file_w').style.display = p ? 'none' : '';
    cs.value = p ? p.cat : (document.getElementById('asnm_preset_cat').value || 'stream');
    document.getElementById('asnm_oe_name').value = p ? p.name : '';
    document.getElementById('asnm_oe_items').value = p ? String(p.items).split(' ').join('\n') : '';
    document.getElementById('asnm_oe_wide').checked = !!(p && p.wide);
    form.style.display = '';
    document.getElementById('asnm_oe_name').focus();
}
function asnmOeSave() {
    var i = ASNM.oe.idx, p = i >= 0 ? ASNM.data.presets[i] : null;
    var name = document.getElementById('asnm_oe_name').value.replace(/[|"\\<>]/g, '').replace(/^\s+|\s+$/g, '');
    var cat = document.getElementById('asnm_oe_cat').value;
    var raw = document.getElementById('asnm_oe_items').value.split(/[\s,;]+/), items = [], bad = [], seen = {}, k;
    for (k = 0; k < raw.length; k++) {
        var w = raw[k].toLowerCase().replace(/^https?:\/\//, '').replace(/\/.*$/, '').replace(/^\*\./, '');
        if (!w) continue;
        if (/^as\d+$/.test(w)) w = w.substr(2);
        if (!/^\d+$/.test(w) && !/^[a-z0-9_-]+(\.[a-z0-9_-]+)+$/.test(w)) { bad.push(raw[k]); continue; }
        if (!seen[w]) { seen[w] = 1; items.push(w); }
    }
    if (!name) { alert(t('oe_need_name')); return; }
    if (!items.length) { alert(t('oe_need_items')); return; }
    if (bad.length && !confirm(t('oe_bad', { l: bad.join(', ') }))) return;
    var file = p ? p.file : document.getElementById('asnm_oe_file').value;
    var old = p ? p.cat + '|' + p.name : '', wide = document.getElementById('asnm_oe_wide').checked ? '1' : '0';
    // amng_custom values are size limited: the first job writes the line, further jobs add the rest of the entries
    var jobs = [], chunk = [], len = 0, mode = 'save';
    for (k = 0; k < items.length; k++) {
        if (len + items[k].length + 1 > 1200 && chunk.length) {
            jobs.push(['pedit', [mode, encodeURIComponent(file), encodeURIComponent(old), cat, encodeURIComponent(name), wide, chunk.join(',')]]);
            mode = 'more'; chunk = []; len = 0;
        }
        chunk.push(items[k]); len += items[k].length + 1;
    }
    jobs.push(['pedit', [mode, encodeURIComponent(file), encodeURIComponent(old), cat, encodeURIComponent(name), wide, chunk.join(',')]]);
    document.getElementById('asnm_oe_form').style.display = 'none';
    asnmSendQueue(jobs);
}
function asnmOeDel(i) {
    var p = ASNM.data.presets[i];
    if (!p || !confirm(t('oe_c_del', { n: p.name, f: asnmOeFileLabel(p.file) }))) return;
    asnmSend('pedit', ['del', encodeURIComponent(p.file), encodeURIComponent(p.cat + '|' + p.name)]);
}

function asnmDiagPack() {
    document.getElementById('asnm_output').textContent = t('running_x', { a: t('btn_dp') });
    asnmSend('diagpack', [document.getElementById('asnm_dp_full').checked ? 'full' : '']);
}
function asnmDiagDownload(name) {
    asnmGet('diag.htm', function (txt) {
        try {
            var url = URL.createObjectURL(new Blob([txt], { type: 'text/plain;charset=utf-8' })), a = document.createElement('a');
            a.href = url; a.download = name; a.style.display = 'none';
            document.body.appendChild(a); a.click();
            setTimeout(function () { URL.revokeObjectURL(url); a.parentNode.removeChild(a); }, 2000);
        } catch (e) { document.getElementById('asnm_output').textContent = txt; }
    }, function () { alert(t('dp_missing')); });
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
    asnmSubTab('manual');
    var f = document.getElementById('asnm_add_asns');
    var cur = f.value.split(/[,;\s]+/).filter(function (v) { return v; });
    for (var i = 0; i < list.length; i++) if (cur.indexOf('AS' + list[i]) < 0 && cur.indexOf(list[i]) < 0) cur.push('AS' + list[i]);
    f.value = cur.join(', ');
    if (f.scrollIntoView) f.scrollIntoView({ block: 'center' });
    f.focus();
}

/* ============================ backup / restore ============================ */
function asnmPad(n) { return (n < 10 ? '0' : '') + n; }

// Basic backup made by the page itself (ASN list, schedule, failover chains, statistics settings): used when the router does not deliver the full file
function asnmBackupLocal() {
    var L = ['# ASN Manager Backup', '# created=' + Math.floor(Date.now() / 1000), '[ASN_LIST]'], d = ASNM.data, i;
    var cus = [];
    for (i = 0; i < d.entries.length; i++) {
        var en = d.entries[i];
        if (en.kind) cus.push(en.dest + ':' + (en.src || '') + ':' + en.kind + ':' + en.value);
        else L.push(en.asn + ':' + en.dest + ':' + (en.src || ''));
    }
    L.push('[CUSTOM]');
    for (i = 0; i < cus.length; i++) L.push(cus[i]);
    L.push('[NOTES]');
    for (i = 0; i < d.entries.length; i++) if (d.entries[i].note)
        L.push((d.entries[i].kind ? d.entries[i].kind + ':' + d.entries[i].value : d.entries[i].asn) + '\t' + d.entries[i].note);
    if (d.schedule) L.push('[SCHEDULE]', 'INTERVAL=' + d.schedule.interval, 'TIME=' + d.schedule.time);
    var fo = ASNM_FO.data;
    if (fo && fo.chains && fo.chains.length) {
        L.push('[FAILOVER]');
        for (i = 0; i < fo.chains.length; i++) L.push(fo.chains[i].t + '=' + fo.chains[i].fb.join(','));
    }
    var tr = ASNM_TR.data;
    if (tr && (tr.state === 'enabled' || tr.state === 'disabled')) {
        L.push('[SETTINGS]', 'STATS=' + tr.state);
        if (tr.save === 0 || tr.save === 1) L.push('STATS_SAVING=' + (tr.save ? 'on' : 'off'));
    }
    return L.join('\n') + '\n';
}

function asnmExport() {
    if (!ASNM.data || ASNM.exporting) return;
    ASNM.exporting = true;
    asnmSetStatus(t('bk_preparing'), false);
    function gen(txt) { var m = /^# generated=(\S+)/.exec(txt || ''); return m ? m[1] : ''; }
    function go(prev) {
        var f = document.formAsnmStats, page = document.formAsnm.elements['current_page'].value;
        f.elements['current_page'].value = page;
        f.elements['next_page'].value = page;
        f.elements['action_script'].value = 'start_' + ASNM_NS + 'backup';
        asnmPost(f);
        var started = Date.now();
        function again() {
            if (Date.now() - started > 15000) {
                // the router did not deliver: give the user a basic backup anyway and say why
                asnmExportDone(asnmBackupLocal(), t('bk_fallback'));
            } else setTimeout(poll, 1200);
        }
        function poll() {
            asnmGet('backup.js', function (txt) {
                if (gen(txt) && gen(txt) !== prev) { asnmExportDone(txt); return; }
                again();
            }, again);
        }
        setTimeout(poll, 1500);
    }
    asnmGet('backup.js', function (old) { go(gen(old)); }, function () { go(''); });
}

function asnmExportDone(txt, note) {
    ASNM.exporting = false;
    asnmSetStatus(note || '', !!note);
    var d = new Date();
    var name = 'asn_manager_backup_' + d.getFullYear() + asnmPad(d.getMonth() + 1) + asnmPad(d.getDate()) + '_' +
               asnmPad(d.getHours()) + asnmPad(d.getMinutes()) + asnmPad(d.getSeconds()) + '.conf';
    var blob = new Blob([txt.replace(/^# generated=.*\n/, '')], { type: 'text/plain' });
    var a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = name;
    document.body.appendChild(a);
    a.click();
    setTimeout(function () { URL.revokeObjectURL(a.href); a.parentNode.removeChild(a); }, 1000);
}
var ASNM_SET_OK = { MAIL_NOTIFY: /^(off|daily|weekly)$/, STATS: /^(enabled|disabled)$/, STATS_SAVING: /^(on|off)$/, STATS_MODE: /^(asn|iface)$/, RULES_MODE: /^(combined|single)$/, WEBUI_LOCATION: /^(vpn|addons)$/, SG_DOMAINS: /^(on|off)$/, DNS_FOLLOW: /^(on|off)$/, DNS_DEVICE: /^(on|off)$/, DNS_TLS: /^(on|off)$/ };

function asnmParseBackup(txt) {
    var lines = txt.replace(/\r/g, '').split('\n'), section = null, hasSections = /^\[(ASN_LIST|CUSTOM)\]/m.test(txt);
    var res = { notes: [], entries: [], custom: [], bad: 0, interval: null, time: null, hasAsn: false, failover: [], hasFo: false, settings: {}, nset: 0, version: '' };
    var tg = '(?:WAN1|WAN2|OVPN[1-5]|WGC[1-5])', reFo = new RegExp('^(WAN|' + tg + ')=(' + tg + '|BLOCK)(?:,(' + tg + '|BLOCK))?$');
    for (var i = 0; i < lines.length; i++) {
        var l = lines[i].trim();
        if (!l) continue;
        if (l.charAt(0) === '#') { var mv = /^# version=(\S+)/.exec(l); if (mv) res.version = mv[1]; continue; }
        if (/^\[.*\]$/.test(l)) { section = l; if (l === '[ASN_LIST]') res.hasAsn = true; if (l === '[FAILOVER]') res.hasFo = true; continue; }
        if (section === '[SCHEDULE]') {
            var m = /^INTERVAL=(\d{1,2})$/.exec(l); if (m) res.interval = m[1];
            m = /^TIME=(([01]?\d|2[0-3]):[0-5]\d)$/.exec(l); if (m) res.time = m[1];
            continue;
        }
        if (section === '[FAILOVER]') {
            var fm = reFo.exec(l);
            if (fm) res.failover.push([fm[1] === 'WAN' ? 'WAN1' : fm[1], fm[3] ? fm[2] + ',' + fm[3] : fm[2]]);
            continue;
        }
        if (section === '[SETTINGS]') {
            var sm = /^([A-Z_]+)=([a-z]+)$/.exec(l);
            if (sm && ASNM_SET_OK[sm[1]] && ASNM_SET_OK[sm[1]].test(sm[2])) { res.settings[sm[1]] = sm[2]; res.nset++; }
            continue;
        }
        if (section === '[NOTES]') {
            var nmx = /^(\d+|ip:[0-9.\/]+|dom:[A-Za-z0-9.-]+)\t+(.+)$/.exec(lines[i].replace(/\r$/, ''));
            if (nmx) res.notes.push(nmx[1] + '=' + encodeURIComponent(nmx[2].trim().slice(0, 60)));
            continue;
        }
        if (section === '[CUSTOM]') {
            var cm = /^(WAN|WAN1|WAN2|OVPN[1-5]|WGC[1-5]):([0-9.,\s]*):(ip|dom):([A-Za-z0-9.\/-]+)$/.exec(l);
            if (cm && asnmValidSrc(cm[2]) && asnmEntryKind(cm[4]) === cm[3]) res.custom.push((cm[1] === 'WAN' ? 'WAN1' : cm[1]) + ':' + asnmNormSrc(cm[2]) + ':' + cm[3] + ':' + cm[4]);
            else res.bad++;
            continue;
        }
        if (hasSections && section !== '[ASN_LIST]') continue;
        var e = ASNM.reEntry.exec(l);
        if (e && asnmValidSrc(e[3])) res.entries.push(e[1] + ':' + (e[2] === 'WAN' ? 'WAN1' : e[2]) + ':' + asnmNormSrc(e[3]));
        else res.bad++;
    }
    if (!hasSections && res.entries.length) res.hasAsn = true;
    if (res.custom.length) res.hasAsn = true;
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
        panel.style.display = 'block';
        if (!(r.hasAsn || (r.interval && r.time) || r.hasFo || r.nset)) {
            ASNM.importData = null;
            document.getElementById('asnm_import_info').textContent = t('import_none');
            document.getElementById('asnm_import_btns').style.display = 'none';
            return;
        }
        ASNM.importData = r;
        var sel = function (id, label, det, on) {
            return '<label class="asnm-rs-item"><input type="checkbox" id="' + id + '"' + (on === false ? '' : ' checked="checked"') + '/><span>' + asnmEsc(label) + '</span></label>' + (det || '');
        };
        var h = '<div class="asnm-rs-title">' + asnmEsc(t('rs_title')) + '</div><div class="asnm-dev">' + asnmEsc(file.name + (r.version ? ' (v' + r.version + ')' : '')) +
                (r.bad ? ' - ' + asnmEsc(t('import_bad', { n: r.bad }).replace(/^, /, '')) : '') + '</div><div class="asnm-rs-list">';
        if (r.hasAsn) h += sel('asnm_rs_asn', t('rs_asn', { n: r.entries.length + r.custom.length }),
            '<div class="asnm-rs-sub"><label><input type="radio" name="asnm_rs_mode" value="replace" checked="checked"/>' + asnmEsc(t('rs_replace')) + '</label>' +
            '<label><input type="radio" name="asnm_rs_mode" value="merge"/>' + asnmEsc(t('rs_merge')) + '</label></div>');
        if (r.interval && r.time) h += sel('asnm_rs_sched', t('rs_sched', { i: r.interval, t: r.time }));
        if (r.hasFo) {
            var fo = []; for (var i = 0; i < r.failover.length; i++) fo.push(r.failover[i][0] + ' → ' + r.failover[i][1].split(',').join(' → '));
            h += sel('asnm_rs_fo', t('rs_fo', { n: r.failover.length }), fo.length ? '<div class="asnm-rs-det">' + asnmEsc(fo.join(' · ')) + '</div>' : '');
        }
        if (r.nset) {
            var st = [];
            if (r.settings.STATS) st.push(t('rs_s_stats') + ': ' + t(r.settings.STATS === 'enabled' ? 'pr_on' : 'pr_off'));
            if (r.settings.STATS_SAVING) st.push(t('rs_s_saving') + ': ' + t(r.settings.STATS_SAVING === 'on' ? 'pr_on' : 'pr_off'));
            if (r.settings.STATS_MODE) st.push(t('rs_s_smode') + ': ' + t(r.settings.STATS_MODE === 'iface' ? 'rs_v_iface' : 'rs_v_asn'));
            if (r.settings.RULES_MODE) st.push(t('rs_s_rules') + ': ' + t(r.settings.RULES_MODE === 'single' ? 'rs_v_single' : 'rs_v_comb'));
            if (r.settings.WEBUI_LOCATION) st.push(t('rs_s_loc') + ': ' + (r.settings.WEBUI_LOCATION === 'vpn' ? t('rs_loc_vpn') : t('rs_loc_addons')));
            h += sel('asnm_rs_set', t('rs_set'), '<div class="asnm-rs-det">' + asnmEsc(st.join(' · ')) + '</div>');
        }
        document.getElementById('asnm_import_info').innerHTML = h + '</div>';
        document.getElementById('asnm_import_btns').style.display = '';
    };
    reader.readAsText(file);
}

function asnmImportRun() {
    var r = ASNM.importData;
    if (!r) return;
    var chk = function (id) { var e = document.getElementById(id); return !!(e && e.checked); };
    var jobs = [], mode = 'replace', rr = document.getElementsByName('asnm_rs_mode'), i;
    for (i = 0; i < rr.length; i++) if (rr[i].checked) mode = rr[i].value;
    if (chk('asnm_rs_asn')) {
        if (mode === 'replace' && ASNM.data && ASNM.data.entries.length &&
            !confirm(t('c_replace', { n: ASNM.data.entries.length, m: r.entries.length + r.custom.length }))) return;
        // amng_custom values are size limited -> send the list in chunks
        var chunk = [], len = 0, first = true;
        for (i = 0; i < r.entries.length; i++) {
            if (len + r.entries[i].length + 1 > ASNM.chunkChars && chunk.length) {
                jobs.push(['import', [first ? mode : 'merge', chunk.join(';')]]); first = false;
                chunk = []; len = 0;
            }
            chunk.push(r.entries[i]); len += r.entries[i].length + 1;
        }
        if (chunk.length) jobs.push(['import', [first ? mode : 'merge', chunk.join(';')]]);
        else if (mode === 'replace') jobs.push(['import', ['replace', '']]);
        var cchunk = [], clen = 0, cfirst = true;
        for (i = 0; i < r.custom.length; i++) {
            if (clen + r.custom[i].length + 1 > ASNM.chunkChars && cchunk.length) {
                jobs.push(['cimport', [cfirst ? mode : 'merge', cchunk.join(';')]]); cfirst = false;
                cchunk = []; clen = 0;
            }
            cchunk.push(r.custom[i]); clen += r.custom[i].length + 1;
        }
        if (cchunk.length) jobs.push(['cimport', [cfirst ? mode : 'merge', cchunk.join(';')]]);
        else if (mode === 'replace') jobs.push(['cimport', ['replace', '']]);
        var nchunk = [], nlen = 0, nfirst = true;
        for (i = 0; i < r.notes.length; i++) {
            if (nlen + r.notes[i].length + 1 > ASNM.chunkChars && nchunk.length) {
                jobs.push(['nimport', [nfirst ? mode : 'merge', nchunk.join(';')]]); nfirst = false;
                nchunk = []; nlen = 0;
            }
            nchunk.push(r.notes[i]); nlen += r.notes[i].length + 1;
        }
        if (nchunk.length) jobs.push(['nimport', [nfirst ? mode : 'merge', nchunk.join(';')]]);
    }
    if (chk('asnm_rs_sched') && r.interval && r.time && +r.interval >= 1 && +r.interval <= 30) jobs.push(['schedule', [r.interval, r.time]]);
    if (chk('asnm_rs_fo')) {
        var keep = {}, cur = (ASNM_FO.data && ASNM_FO.data.chains) || [];
        for (i = 0; i < r.failover.length; i++) keep[r.failover[i][0]] = 1;
        for (i = 0; i < cur.length; i++) if (!keep[cur[i].t]) jobs.push(['failover', [cur[i].t, '', '']]);      // chains that are not in the backup are removed
        for (i = 0; i < r.failover.length; i++) { var p = r.failover[i][1].split(','); jobs.push(['failover', [r.failover[i][0], p[0] || '', p[1] || '']]); }
    }
    if (chk('asnm_rs_set')) {
        var order = ['STATS_SAVING', 'STATS_MODE', 'RULES_MODE', 'WEBUI_LOCATION', 'SG_DOMAINS', 'DNS_FOLLOW', 'DNS_DEVICE', 'DNS_TLS', 'MAIL_NOTIFY', 'STATS'];
        for (i = 0; i < order.length; i++) if (r.settings[order[i]]) jobs.push(['setting', [order[i], r.settings[order[i]]]]);
    }
    if (!jobs.length) { alert(t('rs_nosel')); return; }
    asnmImportCancel();
    asnmSendQueue(jobs);
}

function asnmImportCancel() {
    ASNM.importData = null;
    document.getElementById('asnm_import_panel').style.display = 'none';
}

var ASNM_ROUTER_LANG = 'en';

function asnmLangMode() {
    try { return localStorage.getItem('asnm_lang_mode_' + ASNM_NS) === 'en' ? 'en' : 'default'; } catch (e) { return 'default'; }
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
    try { if (mode === 'en') localStorage.setItem('asnm_lang_mode_' + ASNM_NS, 'en'); else localStorage.removeItem('asnm_lang_mode_' + ASNM_NS); } catch (e) {}
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


/* ============================ traffic statistics ============================ */
var ASNM_TR = { unknownAny: false, open: false, data: null, missing: false, expanded: {}, timer: null, pending: null };

function asnmFmtBytes(n) {
    n = +n || 0;
    var u = ['B', 'KB', 'MB', 'GB', 'TB'], i = 0;
    while (n >= 1024 && i < u.length - 1) { n /= 1024; i++; }
    var d = i === 0 ? 0 : (n < 10 ? 2 : (n < 100 ? 1 : 0));
    return n.toLocaleString(asnmLocale(), { minimumFractionDigits: d, maximumFractionDigits: d }) + ' ' + u[i];
}

function asnmFmtNum(n) { return (+n || 0).toLocaleString(asnmLocale()); }

// Enter / Space on the header, the bar and the collapse link work like a click (but not on the buttons inside the header)
function asnmTrKey(ev) {
    if (ev.target !== ev.currentTarget) return;
    if (ev.key === 'Enter' || ev.key === ' ') { ev.preventDefault(); asnmTrToggle(); }
}

function asnmTrToggle() {
    ASNM_TR.open = !ASNM_TR.open;
    document.getElementById('asnm_tr_body').style.display = ASNM_TR.open ? 'block' : 'none';
    document.getElementById('asnm_tr_head').setAttribute('aria-expanded', ASNM_TR.open ? 'true' : 'false');
    document.getElementById('asnm_tr_card').className = 'asnm-card' + (ASNM_TR.open ? ' asnm-tr-open' : '');
    clearTimeout(ASNM_TR.timer);
    if (ASNM_TR.open) asnmTrLoad();
}

function asnmTrLoad(done) {
    asnmGet('stats.js', function (txt) {
        var d = null;
        try { d = JSON.parse(txt); } catch (e) {}
        ASNM_TR.missing = !d;
        if (d) ASNM_TR.data = d;
        asnmTrRender();
        if (ASNM.data) asnmRenderIfaces();
        if (ASNM_TR.open) asnmSgLoad();
        if (done) done(d);
        asnmTrSchedule();
    }, function () {
        ASNM_TR.missing = false;
        if (!ASNM_TR.data) ASNM_TR.data = { ts: 0, state: 'disabled', since: 0, saved: 0, interval: 10, nets: {}, rows: [] };
        asnmTrRender();
        if (done) done(null);
    });
}

function asnmTrSchedule() {
    clearTimeout(ASNM_TR.timer);
    var d = ASNM_TR.data;
    if (!ASNM_TR.pending && d && d.state === 'enabled')
        ASNM_TR.timer = setTimeout(function () { asnmTrLoad(); }, Math.max(5, d.interval || 10) * 1000);
}

function asnmTrCmd(act) {
    if (ASNM_TR.pending) return;
    if (act === 'reset' && !confirm(t('tr_c_reset'))) return;
    var f = document.formAsnmStats, page = document.formAsnm.elements['current_page'].value;
    f.elements['current_page'].value = page;
    f.elements['next_page'].value = page;
    f.elements['action_script'].value = 'start_asnmanagerstats' + act;
    asnmPost(f);
    ASNM_TR.pending = { act: act, since: Math.floor(Date.now() / 1000) - 2, start: Date.now(), ts0: ASNM_TR.data ? ASNM_TR.data.ts : 0 };
    asnmTrRender();
    var want = (act === 'disable' || act === 'reset') ? 'disabled' : 'enabled';
    (function poll() {
        asnmTrLoad(function (d) {
            var p = ASNM_TR.pending;
            if (!p) return;
            if (d && (d.ts >= p.since || d.ts !== p.ts0) && d.state === want && (act !== 'repair' || d.loop === 1)) { ASNM_TR.pending = null; asnmTrRender(); asnmTrSchedule(); return; }
            if (Date.now() - p.start > 90000) { ASNM_TR.pending = null; asnmTrRender(); alert(t('tr_timeout')); return; }
            setTimeout(poll, 1500);
        });
    })();
}

function asnmTrExpand(key) {
    ASNM_TR.expanded[key] = !ASNM_TR.expanded[key];
    asnmTrRender();
}

function asnmNetBadge(ip) {
    var code = ASNM_TR.data && ASNM_TR.data.nets ? ASNM_TR.data.nets[ip] : '';
    if (!code) return '';
    var label = ({ lan: 'net_lan', g24: 'net_g24', g5: 'net_g5', g6: 'net_g6', wgs: 'net_wgs', ovs: 'net_ovs' })[code];
    var cls = code.charAt(0) === 'g' ? ' asnm-net-g' : (code === 'wgs' || code === 'ovs' ? ' asnm-net-v' : '');
    return ' <span class="asnm-net' + cls + '">' + asnmEsc(label ? t(label) : code.replace(/^dev:/, '')) + '</span>';
}

function asnmTrClientLabel(ip) {
    var n = asnmDeviceName(ip);
    return (n ? asnmEsc(n) + ' <span class="asnm-dev">' + asnmEsc(ip) + '</span>' : asnmEsc(ip)) + asnmNetBadge(ip);
}

function asnmFmtPct(p) {
    var loc = asnmLocale();
    if (!(p > 0)) return '0 %';
    if (p < 0.1) return '<' + (0.1).toLocaleString(loc, { minimumFractionDigits: 1 }) + ' %';
    if (p < 10) return p.toLocaleString(loc, { minimumFractionDigits: 1, maximumFractionDigits: 1 }) + ' %';
    return Math.round(p).toLocaleString(loc) + ' %';
}

function asnmDevCount(n) {
    if (!(n > 0)) return '';
    return '<span class="asnm-tr-cnt">' + asnmEsc(n === 1 ? t('tr_dev_1') : t('tr_dev_n', { n: n })) + '</span>';
}

/* ---------- live throughput ---------- */
function asnmUnitLabel() { return ASNM_TR.unit === 'mbyte' ? 'MB/s' : 'Mbit/s'; }

function asnmFmtRate(bps) {
    var loc = asnmLocale(), v = ASNM_TR.unit === 'mbyte' ? bps / 1e6 : bps * 8 / 1e6;
    if (!(bps > 0)) return '0';
    if (v < 0.01) return '<' + (0.01).toLocaleString(loc);
    var dg = v < 1 ? 2 : (v < 100 ? 1 : 0);
    return v.toLocaleString(loc, { minimumFractionDigits: dg, maximumFractionDigits: dg });
}

// e-mail on new versions (amtm settings)
function asnmMailRender() {
    var m = (ASNM.data && ASNM.data.mail) || { mode: 'off', amtm: 0 }, k, e, l = [];
    for (k in { off: 1, daily: 1, weekly: 1 }) { e = document.getElementById('asnm_mail_' + k); if (e) e.className = m.mode === k ? 'asnm-on' : ''; }
    e = document.getElementById('asnm_mail_testbtn'); if (e) e.style.display = m.amtm ? '' : 'none';
    if (!m.amtm) l.push('<span class="asnm-mail-warn">' + asnmEsc(t('mail_noamtm')) + '</span>');
    if (m.sent) l.push(asnmEsc(t('mail_last', { v: m.sent, t: m.sts ? asnmFmtTime(+m.sts) : '-' })));
    if (m.err && m.mode !== 'off') l.push('<span class="asnm-mail-warn">' + asnmEsc(t('mail_err', { e: m.err })) + '</span>');
    e = document.getElementById('asnm_mail_info'); if (e) e.innerHTML = l.join('<br>');
}
function asnmMailSet(mode) {
    var cur = (ASNM.data && ASNM.data.mail && ASNM.data.mail.mode) || 'off';
    if (mode === cur || ASNM.busy) return;
    asnmSend('setting', ['MAIL_NOTIFY', mode]);
}
function asnmMailTest() { if (!ASNM.busy) asnmSend('mailtest', []); }

function asnmPerfMark() {
    var rm = (ASNM.data && ASNM.data.rules) || 'combined', sm = (ASNM_TR.data && ASNM_TR.data.mode) || 'asn';
    var m = { asnm_rm_combined: rm !== 'single', asnm_rm_single: rm === 'single', asnm_sm_asn: sm !== 'iface', asnm_sm_iface: sm === 'iface' };
    for (var id in m) { var e = document.getElementById(id); if (e) e.className = m[id] ? 'asnm-on' : ''; }
    asnmDnsfRender();
    asnmMailRender();
}

// "DNS fitting the line": three switches + an overview of which DNS each line uses
var ASNM_DNS_NAMES = { '9.9.9.11': 'Quad9 (ECS)', '149.112.112.11': 'Quad9 (ECS)', '9.9.9.9': 'Quad9', '149.112.112.112': 'Quad9', '9.9.9.10': 'Quad9', '1.1.1.1': 'Cloudflare', '1.0.0.1': 'Cloudflare',
    '1.1.1.2': 'Cloudflare', '8.8.8.8': 'Google', '8.8.4.4': 'Google', '94.140.14.140': 'AdGuard DNS', '94.140.14.141': 'AdGuard DNS', '94.140.14.14': 'AdGuard DNS', '94.140.15.15': 'AdGuard DNS',
    '185.222.222.222': 'DNS.SB', '45.11.45.11': 'DNS.SB', '76.76.2.0': 'Control D', '76.76.10.0': 'Control D', '208.67.222.222': 'OpenDNS', '208.67.220.220': 'OpenDNS' };
function asnmDnsProvider(ips) {
    var l = String(ips || '').split(' '), n = [], k;
    for (k = 0; k < l.length; k++) if (l[k] && ASNM_DNS_NAMES[l[k]] && n.indexOf(ASNM_DNS_NAMES[l[k]]) < 0) n.push(ASNM_DNS_NAMES[l[k]]);
    return n.join(', ');
}
function asnmDnsfRender() {
    var f = (ASNM.data && ASNM.data.dnsf) || { on: 0 }, k, h, sw = { dnsf: f.on, dnst: f.tls, dnsd: f.dev };
    for (k in sw) {
        var a = document.getElementById('asnm_' + k + '_on'), b = document.getElementById('asnm_' + k + '_off');
        if (a) { a.className = sw[k] ? 'asnm-on' : ''; b.className = sw[k] ? '' : 'asnm-on'; }
    }
    var w = document.getElementById('asnm_dnsd_wrap'); if (w) w.style.display = (f.agh || f.dev) ? '' : 'none';
    asnmAghRender(f);
    var intro = document.getElementById('asnm_dw_intro');
    if (intro) intro.textContent = t('dw_intro', { b: f.base || t('dw_base_unknown') });
    var more = document.getElementById('asnm_dw_more_list');
    if (more && !more.innerHTML) { h = ''; for (k = 1; k <= 6; k++) h += '<li>' + asnmEsc(t('dw_more_' + k)) + '</li>'; more.innerHTML = h; }
    var box = document.getElementById('asnm_dw_now');
    if (!box) return;
    if (!f.on && !f.dev) { box.innerHTML = ''; return; }
    // encryption per line ("WAN1:on base:tunnel")
    var tl = {}, st = String(f.tlsst || '').split(' ');
    for (k = 0; k < st.length; k++) { var kv = st[k].split(':'); if (kv.length === 2 && kv[1]) tl[kv[0]] = kv[1]; }
    var devs = f.devs || {}, l = f.list || [];
    function prot(tg, isBase) {
        if (!/^WAN/.test(tg)) return '<span class="asnm-dw-ok">' + asnmEsc(t('dw_p_tunnel')) + '</span>';
        var c = isBase ? tl.base : tl[tg];
        if (!f.tls) return '<span class="asnm-dw-no">' + asnmEsc(t('dw_p_off')) + '</span>';
        if (c === 'on' || c === 'fw' || c === 'dc' || c === 'dcfw') return '<span class="asnm-dw-ok">' + asnmEsc(t('dw_p_' + c)) + '</span>';
        return '<span class="asnm-dw-no">' + asnmEsc(t('dw_p_' + (c || 'off'))) + '</span>';
    }
    h = '<h4>' + asnmEsc(t('dw_now')) + '</h4><div class="asnm-table-wrap"><table class="asnm-table"><tr><th>' + asnmEsc(t('dw_th_line')) + '</th><th>' + asnmEsc(t('dw_th_dns')) +
        '</th><th>' + asnmEsc(t('dw_th_prot')) + '</th><th>' + asnmEsc(t('dw_th_for')) + '</th></tr>';
    var bdev = devs[f.base] ? t('dw_devs', { n: devs[f.base] }) : '';
    h += '<tr><td><b>' + asnmEsc(f.base || '?') + '</b><span class="asnm-dw-src">' + asnmEsc(t('dw_normal')) + '</span></td><td>' +
         asnmEsc(f.mode === 'unbound' ? t('dw_unbound') : (f.mode === 'dnscrypt' ? 'dnscrypt-proxy' : t('dw_router_dns'))) + '</td><td>' + prot(f.base || '', true) + '</td><td>' +
         asnmEsc(t('dw_for_rest') + (bdev ? ', ' + bdev : '')) + '</td></tr>';
    for (k = 0; k < l.length; k++) {
        var r = l[k], nm = asnmDnsProvider(r.dns), use = [];
        if (r.d) use.push(t('dw_doms', { n: r.d }));
        if (r.l) use.push(t('dw_names', { n: r.l }));
        if (r.dd) use.push(t('dw_ddoms', { n: r.dd }));
        if (f.dev && devs[r.t]) use.push(t('dw_devs', { n: devs[r.t] }));
        if (f.dev && r.t === 'WAN1' && f.base !== 'WAN1') use.push(t('dw_other_devs'));
        var vpn = !/^WAN/.test(r.t);
        h += '<tr><td><b>' + asnmEsc(r.t) + '</b>' + (r.fo ? '<span class="asnm-dw-src asnm-dw-no">' + asnmEsc(t(r.fo === 'BLOCK' ? 'dw_fo_block' : 'dw_fo', { a: r.fo })) + '</span>' : '') + '</td><td>' + (nm ? asnmEsc(nm) + ' · ' : '') + asnmEsc(r.dns) +
             '<span class="asnm-dw-src">' + asnmEsc(t('dw_src_' + (r.src || 'router') + (vpn ? '' : '_wan'))) + '</span>' +
             (vpn ? '<a href="javascript:void(0)" class="asnm-dw-edit" onclick="asnmDwEdit(\'' + r.t + '\');">' + asnmEsc(t('dw_set_vpn')) + '</a>' : '') +
             '</td><td>' + prot(r.t, false) + '</td><td>' + asnmEsc(use.length ? use.join(', ') : '–') + '</td></tr>';
        if (vpn && ASNM.dwEdit === r.t) {
            var cur = r.src === 'own' ? String(r.dns).split(' ') : [];
            h += '<tr class="asnm-dw-edrow"><td colspan="4"><div class="asnm-help" style="margin-bottom:8px;">' + asnmEsc(t('dw_vpn_why', { t: r.t })) + '</div>' +
                 '<div class="asnm-dw-ed"><input type="text" id="asnm_dw_ip1" maxlength="15" placeholder="10.2.0.1" value="' + asnmEsc(cur[0] || '') + '"/>' +
                 '<input type="text" id="asnm_dw_ip2" maxlength="15" placeholder="' + asnmEsc(t('dw_ip2')) + '" value="' + asnmEsc(cur[1] || '') + '"/>' +
                 '<input type="button" class="button_gen asnm-btn asnm-primary asnm-small-btn" value="' + asnmEsc(t('oe_save')) + '" onclick="asnmDwSave(\'' + r.t + '\', 0);"/>' +
                 (r.src === 'own' ? '<input type="button" class="button_gen asnm-ghost asnm-small-btn" value="' + asnmEsc(t('dw_auto')) + '" onclick="asnmDwSave(\'' + r.t + '\', 1);"/>' : '') +
                 '<input type="button" class="button_gen asnm-ghost asnm-small-btn" value="' + asnmEsc(t('btn_cancel')) + '" onclick="asnmDwEdit(\'\');"/></div></td></tr>';
        }
    }
    h += '</table></div>';
    if (f.tls && tl.base === 'ub') h += '<div class="asnm-help" style="margin-top:8px;">' + asnmEsc(t('dw_ub_hint')) + '</div>';
    if (f.derr) h += '<div class="asnm-status-err" style="margin-top:8px;">' + asnmEsc(f.derr) + '</div>';
    box.innerHTML = h;
}
function asnmDwEdit(tg) { ASNM.dwEdit = ASNM.dwEdit === tg ? '' : tg; asnmDnsfRender(); }
function asnmDwSave(tg, auto) {
    var ips = [], k, v;
    if (!auto) for (k = 1; k <= 2; k++) {
        v = document.getElementById('asnm_dw_ip' + k).value.replace(/\s+/g, '');
        if (!v) continue;
        if (!/^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/.test(v) || v.split('.').some(function (o) { return +o > 255; })) { alert(t('dw_bad_ip', { v: v })); return; }
        ips.push(v);
    }
    if (!auto && !ips.length) { alert(t('dw_need_ip')); return; }
    ASNM.dwEdit = '';
    asnmSend('dnsfsrv', [tg, ips.join(',')]);
}
function asnmDnstSet(on) {
    var cur = ASNM.data && ASNM.data.dnsf && ASNM.data.dnsf.tls ? 1 : 0;
    if (on === cur || ASNM.busy) return;
    asnmSend('setting', ['DNS_TLS', on ? 'on' : 'off']);
}
// login of AdGuard Home: "DNS per device" then changes its clients through its API, without restarting it
function asnmAghRender(f) {
    var w = document.getElementById('asnm_agh_wrap'); if (!w) return;
    w.style.display = f.agh ? '' : 'none';
    var info = document.getElementById('asnm_agh_info'), s;
    if (f.aghlogin) s = f.aghapi === 'ok' ? '<span class="asnm-dw-ok">' + asnmEsc(t('agh_ok')) + '</span>'
        : (f.aghapi ? '<span class="asnm-dw-no">' + asnmEsc(t('agh_err', { e: String(f.aghapi).replace(/^error: /, '') })) + '</span>' : asnmEsc(t('agh_saved')));
    else if (f.aghrefused) s = '<span class="asnm-dw-no">' + asnmEsc(t('agh_refused')) + '</span>';
    else s = asnmEsc(t('agh_none'));
    if (info) info.innerHTML = s;
    var b = document.getElementById('asnm_agh_savebtn'); if (b) b.value = t(f.aghlogin ? 'agh_change' : 'oe_save');
    var o = document.getElementById('asnm_agh_off'); if (o) o.style.display = f.aghlogin ? '' : 'none';
}
function asnmAghSave() {
    var u = document.getElementById('asnm_agh_user'), p = document.getElementById('asnm_agh_pass');
    if (ASNM.busy) return;
    if (!u.value || !p.value) { alert(t('agh_need')); return; }
    var b = btoa(unescape(encodeURIComponent(u.value + ':' + p.value)));
    p.value = '';
    asnmSend('aghlogin', [b]);
}
function asnmAghOff() { if (!ASNM.busy && confirm(t('agh_c_off'))) asnmSend('aghlogin', ['off']); }
function asnmDnsdSet(on) {
    var cur = ASNM.data && ASNM.data.dnsf && ASNM.data.dnsf.dev ? 1 : 0;
    if (on === cur || ASNM.busy) return;
    if (!confirm(t(on ? 'dnsd_confirm' : 'dnsd_confirm_off'))) return;
    asnmSend('setting', ['DNS_DEVICE', on ? 'on' : 'off']);
}
function asnmDnsfSet(on) {
    var cur = ASNM.data && ASNM.data.dnsf && ASNM.data.dnsf.on ? 1 : 0;
    if (on === cur || ASNM.busy) return;
    if (on && !confirm(t('dnsf_confirm'))) return;
    asnmSend('setting', ['DNS_FOLLOW', on ? 'on' : 'off']);
}

// the marking rules take effect after a rebuild: switch and rebuild in one go (from the saved lists, no download)
function asnmSetRules(m) {
    var cur = (ASNM.data && ASNM.data.rules) || 'combined';
    if (m === cur || ASNM.busy) return;
    if (!confirm(t('perf_rules_confirm', { m: t(m === 'combined' ? 'perf_rules_comb' : 'perf_rules_single') }))) return;
    asnmSendQueue([['setting', ['RULES_MODE', m]], ['retry', []]]);
}

function asnmSetStatsMode(m) {
    var cur = (ASNM_TR.data && ASNM_TR.data.mode) || 'asn';
    if (m === cur || ASNM.busy) return;
    asnmSend('setting', ['STATS_MODE', m]);
}

function asnmUnitMark() {
    var a = document.getElementById('asnm_unit_mbit'), b = document.getElementById('asnm_unit_mbyte');
    if (a) a.className = ASNM_TR.unit === 'mbyte' ? '' : 'asnm-on';
    if (b) b.className = ASNM_TR.unit === 'mbyte' ? 'asnm-on' : '';
}

// the unit applies to the whole page: live values, interface table, speed test, summaries, status messages
function asnmSetUnit(u) {
    ASNM_TR.unit = u === 'mbyte' ? 'mbyte' : 'mbit';
    try { localStorage.setItem('asnm_rate_unit', ASNM_TR.unit); } catch (e) {}
    asnmUnitMark();
    asnmPerfMark();
    asnmTrRender();
    if (ASNM.data) asnmRenderIfaces();
}

function asnmLiveCell(rd, ru) {
    if (!ASNM_TR.rateOk) return '<td class="num asnm-live"><span class="asnm-muted">-</span></td>';
    if (!(rd > 0) && !(ru > 0)) return '<td class="num asnm-live"><span class="asnm-muted">0</span></td>';
    return '<td class="num asnm-live">↓ ' + asnmFmtRate(rd) + '<span class="asnm-ru">↑ ' + asnmFmtRate(ru) + '</span></td>';
}

function asnmTrLiveLine(d, rd, ru) {
    var u = ASNM_TR.unit, txt;
    if (d.state !== 'enabled') txt = '<span class="asnm-muted">' + asnmEsc(t('tr_live_off')) + '</span>';
    else if (!ASNM_TR.rateOk) txt = '<span class="asnm-muted">' + asnmEsc(t('tr_live_wait')) + '</span>';
    else txt = '↓ <b>' + asnmFmtRate(rd) + '</b> &nbsp; ↑ <b>' + asnmFmtRate(ru) + '</b> ' + asnmUnitLabel();
    return '<div class="asnm-tr-live" title="' + asnmEsc(t('tr_live_tip', { s: d.interval || 10 })) + '"><span class="asnm-seg-label">' + asnmEsc(t('tr_live')) + '</span><span>' + txt + '</span>' +
           '<span class="asnm-link asnm-unit" onclick="asnmTab(\'settings\');">' + asnmEsc(t('disp_change')) + '</span></div>';
}

function asnmIfaceLive(id) {
    var d = ASNM_TR.data;
    if (!d || !ASNM_TR.rateOk) return '<span class="asnm-muted">-</span>';
    var rd = 0, ru = 0;
    for (var i = 0; i < d.rows.length; i++) if (d.rows[i].dest === id) { rd += d.rows[i].rd || 0; ru += d.rows[i].ru || 0; }
    return '↓ ' + asnmFmtRate(rd) + '<span class="asnm-ru">↑ ' + asnmFmtRate(ru) + '</span>';
}

// base = bytes of the row above (= 100 %): the grand total for top-level rows, the parent row for expanded rows
function asnmTrCells(db, ub, pk, base, rd, ru) {
    var tot = db + ub, p = base > 0 ? Math.min(100, tot / base * 100) : 0;
    var w = tot > 0 ? Math.max(2, Math.round(p)) : 0;
    return '<td class="num">' + asnmFmtBytes(db) + '</td><td class="num">' + asnmFmtBytes(ub) + '</td>' + asnmLiveCell(rd, ru) +
           '<td class="num">' + asnmFmtNum(pk) + '</td>' +
           '<td class="asnm-share"><span class="asnm-bar"><i style="width:' + w + '%"></i></span><span class="asnm-pct">' + asnmFmtPct(p) + '</span></td>';
}

function asnmTrExpandAll(on) {
    var d = ASNM_TR.data;
    ASNM_TR.expanded = {};
    if (on && d) {
        ASNM_TR.expanded['O'] = true;
        for (var i = 0; i < d.rows.length; i++) {
            var r = d.rows[i];
            ASNM_TR.expanded[r.asn === 'O' ? 'O|' + r.dest : r.dest + '|' + r.asn] = true;
        }
    }
    asnmTrRender();
}

// list: [[ip, ub, up, db, dp], ...]   total: {db, ub, pk} of the row above   level: 2 = indented one more step
function asnmTrClientRows(list, total, level) {
    ASNM_TR.unknownSeen = false;
    var cls = 'asnm-tr-sub' + (level === 2 ? ' asnm-lv2' : '');
    var rows = list.slice(0).sort(function (a, b) { return (b[1] + b[3]) - (a[1] + a[3]); });
    var base = total.db + total.ub, html = '', sdb = 0, sub = 0, spk = 0, srd = 0, sru = 0;
    for (var i = 0; i < rows.length; i++) {
        var r = rows[i];
        sdb += r[3]; sub += r[1]; spk += r[2] + r[4]; srd += r[6] || 0; sru += r[5] || 0;
        html += '<tr class="' + cls + '"><td>' + asnmTrClientLabel(r[0]) + '</td>' + asnmTrCells(r[3], r[1], r[2] + r[4], base, r[6] || 0, r[5] || 0) + '</tr>';
    }
    var odb = total.db - sdb, oub = total.ub - sub, opk = total.pk - spk;
    if (odb > 0 || oub > 0) {
        ASNM_TR.unknownSeen = true; ASNM_TR.unknownAny = true;
        html += '<tr class="' + cls + '" title="' + asnmEsc(t('tr_unknown_hint')) + '"><td class="asnm-muted">' + asnmEsc(t('tr_unknown')) + '</td>' +
                asnmTrCells(Math.max(odb, 0), Math.max(oub, 0), Math.max(opk, 0), base, Math.max((total.rd || 0) - srd, 0), Math.max((total.ru || 0) - sru, 0)) + '</tr>';
    }
    if (!html) html = '<tr class="' + cls + '"><td colspan="6" class="asnm-muted">' + asnmEsc(t('tr_no_clients')) + '</td></tr>';
    return html;
}

function asnmTrRender() {
    var d = ASNM_TR.data, st = d ? d.state : '';
    ASNM_TR.rateOk = !!(d && d.state === 'enabled' && d.rate === 1);
    var badge = document.getElementById('asnm_tr_state'), sub = document.getElementById('asnm_tr_sub');
    if (ASNM_TR.missing || !d) {
        badge.className = 'asnm-badge asnm-bad'; badge.textContent = t('tr_off');
        sub.textContent = t('tr_sub_none');
    } else {
        badge.className = 'asnm-badge ' + (st === 'enabled' ? 'asnm-ok' : 'asnm-warn');
        badge.textContent = st === 'enabled' ? t('tr_on') : t('tr_off');
        sub.textContent = st === 'enabled' ? t('tr_sub_on', { t: asnmFmtTime(d.since) }) : t('tr_sub_off');
    }
    var busy = !!ASNM_TR.pending, none = ASNM_TR.missing || !d;
    document.getElementById('asnm_tr_btn_enable').disabled = busy || none || st === 'enabled';
    document.getElementById('asnm_tr_btn_disable').disabled = busy || none || st !== 'enabled';
    document.getElementById('asnm_tr_btn_reset').disabled = busy || none;
    if (busy) sub.textContent = t('tr_working');

    // collapsed card: the bar under the header invites to open it and shows a one-line summary
    document.getElementById('asnm_tr_head').title = t('tr_toggle_tip');
    document.getElementById('asnm_tr_bar_text').textContent = t('tr_show');
    var sumTxt = '';
    if (d && d.rows) {
        var sb = 0, sn = 0;
        for (var q = 0; q < d.rows.length; q++) { sb += d.rows[q].db + d.rows[q].ub; if (d.rows[q].asn !== 'O') sn++; }
        if (sb > 0) sumTxt = t('tr_sum', { b: asnmFmtBytes(sb), n: sn });
        if (ASNM_TR.rateOk) {
            var lrd = 0, lru = 0;
            for (q = 0; q < d.rows.length; q++) { lrd += d.rows[q].rd || 0; lru += d.rows[q].ru || 0; }
            if (lrd + lru > 0) sumTxt += ' · ' + t('tr_live') + ' ↓ ' + asnmFmtRate(lrd) + ' ↑ ' + asnmFmtRate(lru) + ' ' + asnmUnitLabel();
        }
    }
    document.getElementById('asnm_tr_bar_sum').textContent = sumTxt;
    if (!ASNM_TR.open) return;

    var body = document.getElementById('asnm_tr_table'), note = document.getElementById('asnm_tr_note'), totBox = document.getElementById('asnm_tr_total');
    ASNM_TR.unknownAny = false;
    if (none) { totBox.innerHTML = ''; body.innerHTML = '<div class="asnm-muted" style="padding:14px;">' + asnmEsc(t('tr_sub_none')) + '</div>'; note.innerHTML = ''; return; }

    // aggregate "not assigned" over all interfaces, collect ASN rows
    var other = { db: 0, ub: 0, pk: 0, rd: 0, ru: 0, ifaces: [], clients: {} }, asns = [], max = 0, listed = {};
    if (ASNM.data && ASNM.data.entries) for (var e = 0; e < ASNM.data.entries.length; e++)
        listed[asnmNormDest(ASNM.data.entries[e].dest) + '|' + ASNM.data.entries[e].asn] = 1;
    for (var i = 0; i < d.rows.length; i++) {
        var r = d.rows[i], pk = r.up + r.dp;
        if (r.asn === 'O') {
            other.db += r.db; other.ub += r.ub; other.pk += pk; other.rd += r.rd || 0; other.ru += r.ru || 0;
            if (r.db + r.ub > 0) other.ifaces.push(r);
            for (var c = 0; c < r.cl.length; c++) {
                var x = r.cl[c], o = other.clients[x[0]] || (other.clients[x[0]] = [x[0], 0, 0, 0, 0, 0, 0]);
                o[1] += x[1]; o[2] += x[2]; o[3] += x[3]; o[4] += x[4]; o[5] += x[5] || 0; o[6] += x[6] || 0;
            }
        } else {
            asns.push(r);
        }
    }
    asns.sort(function (a, b) { return (b.db + b.ub) - (a.db + a.ub); });
    document.getElementById('asnm_sec_tbl_cnt').textContent = d.mode === 'iface' ? '' : t('sec_cnt', { n: asns.length });
    document.getElementById('asnm_sec_tbl_cnt').style.display = d.mode === 'iface' ? 'none' : '';

    // total bar above the table: everything that was counted, split into "via ASN rules" and "not assigned"
    var tDb = other.db, tUb = other.ub, tPk = other.pk, aDb = 0, aUb = 0;
    for (i = 0; i < asns.length; i++) { tDb += asns[i].db; tUb += asns[i].ub; tPk += asns[i].up + asns[i].dp; aDb += asns[i].db; aUb += asns[i].ub; }
    var light = d.mode === 'iface';
    var tAll = tDb + tUb, pA = tAll > 0 ? Math.round((aDb + aUb) / tAll * 100) : 0;
    var tRd = other.rd, tRu = other.ru;
    for (i = 0; i < asns.length; i++) { tRd += asns[i].rd || 0; tRu += asns[i].ru || 0; }
    totBox.innerHTML = '<div class="asnm-stats">' +
        '<div class="asnm-stat"><div class="asnm-stat-label">' + asnmEsc(t('tr_th_down')) + '</div><div class="asnm-stat-value">' + asnmFmtBytes(tDb) + '</div></div>' +
        '<div class="asnm-stat"><div class="asnm-stat-label">' + asnmEsc(t('tr_th_up')) + '</div><div class="asnm-stat-value">' + asnmFmtBytes(tUb) + '</div></div>' +
        '<div class="asnm-stat"><div class="asnm-stat-label">' + asnmEsc(t('tr_total')) + '</div><div class="asnm-stat-value">' + asnmFmtBytes(tAll) + '</div></div>' +
        '<div class="asnm-stat"><div class="asnm-stat-label">' + asnmEsc(t('tr_th_pk')) + '</div><div class="asnm-stat-value">' + asnmFmtNum(tPk) + '</div></div></div>' +
        (light ? '' : '<div class="asnm-split"><i style="width:' + pA + '%"></i></div>' +
        '<div class="asnm-split-legend"><span>' + asnmEsc(t('tr_split_asn')) + ': <b>' + pA + ' %</b> (' + asnmFmtBytes(aDb + aUb) + ')</span>' +
        '<span>' + asnmEsc(t('tr_split_other')) + ': <b>' + (tAll > 0 ? 100 - pA : 0) + ' %</b> (' + asnmFmtBytes(other.db + other.ub) + ')</span></div>') +
        asnmTrLiveLine(d, tRd, tRu);

    var html = '<table class="asnm-table"><tr><th>' + t('tr_th_name') + '</th><th style="text-align:right;">' + t('tr_th_down') + '</th>' +
               '<th style="text-align:right;">' + t('tr_th_up') + '</th>' +
               '<th style="text-align:right;" title="' + asnmEsc(t('tr_live_tip', { s: d.interval || 10 }) + ' (' + asnmUnitLabel() + ')') + '">' + t('tr_live') + '</th>' +
               '<th style="text-align:right;">' + t('tr_th_pk') + '</th>' +
               '<th title="' + asnmEsc(t('tr_th_share_tip')) + '">' + t('tr_th_share') + '</th></tr>';

    var oTot = other.db + other.ub, ko = ASNM_TR.expanded['O'];
    html += '<tr class="asnm-tr-row asnm-tr-other' + (ko ? ' open' : '') + '" onclick="asnmTrExpand(\'O\')"><td><span class="asnm-tgl"></span>' +
            asnmEsc(t(light ? 'tr_all' : 'tr_other')) + asnmDevCount(Object.keys(other.clients).length) + '</td>' + asnmTrCells(other.db, other.ub, other.pk, tAll, other.rd, other.ru) + '</tr>';
    if (ko) {
        html += '<tr class="asnm-tr-sub asnm-tr-subhead"><td colspan="6">' + asnmEsc(t('tr_by_iface')) + '</td></tr>';
        other.ifaces.sort(function (a, b) { return (b.db + b.ub) - (a.db + a.ub); });
        for (i = 0; i < other.ifaces.length; i++) {
            var f = other.ifaces[i], ikey = 'O|' + f.dest, io = ASNM_TR.expanded[ikey];
            html += '<tr class="asnm-tr-sub asnm-tr-row' + (io ? ' open' : '') + '" onclick="asnmTrExpand(\'' + asnmEsc(ikey) + '\')"><td><span class="asnm-tgl"></span>' +
                    asnmEsc(asnmDestLabel(f.dest)) + asnmDevCount(f.cl.length) + '</td>' + asnmTrCells(f.db, f.ub, f.up + f.dp, oTot, f.rd || 0, f.ru || 0) + '</tr>';
            if (io) html += asnmTrClientRows(f.cl, { db: f.db, ub: f.ub, pk: f.up + f.dp, rd: f.rd || 0, ru: f.ru || 0 }, 2);
        }
        html += '<tr class="asnm-tr-sub asnm-tr-subhead"><td colspan="6">' + asnmEsc(t('tr_by_client')) + '</td></tr>';
        var ol = [];
        for (var ip in other.clients) ol.push(other.clients[ip]);
        html += asnmTrClientRows(ol, other, 1);
    }

    for (i = 0; i < asns.length; i++) {
        var a = asns[i], key = a.dest + '|' + a.asn, open = ASNM_TR.expanded[key];
        html += '<tr class="asnm-tr-row' + (open ? ' open' : '') + '" onclick="asnmTrExpand(\'' + asnmEsc(key) + '\')"><td><span class="asnm-tgl"></span>' +
                asnmTrRowLabel(a) + '<span class="asnm-tr-dest">' + asnmEsc(asnmNormDest(a.dest)) + '</span>' +
                (listed[asnmNormDest(a.dest) + '|' + a.asn] ? '' : '<span class="asnm-tr-gone">' + asnmEsc(t('tr_gone')) + '</span>') +
                asnmDevCount(a.cl.length) + asnmTrNameLine(a) + '</td>' + asnmTrCells(a.db, a.ub, a.up + a.dp, tAll, a.rd || 0, a.ru || 0) + '</tr>';
        if (open) html += asnmTrClientRows(a.cl, { db: a.db, ub: a.ub, pk: a.up + a.dp, rd: a.rd || 0, ru: a.ru || 0 }, 1);
    }
    if (!asns.length && other.db + other.ub === 0)
        html += '<tr><td colspan="6" class="asnm-muted" style="text-align:center;padding:12px;">' + asnmEsc(st === 'enabled' ? t('tr_empty') : t('tr_off_hint')) + '</td></tr>';
    body.innerHTML = html + '</table>';

    var n = asnmEsc(t('tr_note', { s: d.interval || 10 }));
    if (ASNM_TR.unknownAny) n += '<div>' + asnmEsc(t('tr_unknown_hint')) + '</div>';
    // counting broken (killed process, left-over files): say so and offer the repair
    if (d.state === 'enabled' && ASNM.data && ASNM.data.entries && ASNM.data.entries.length) {
        var why = d.loop === 0 ? t('tr_why_loop') : (d.chains === 0 ? t('tr_why_rules') : '');
        if (why) n += '<div class="asnm-tr-warn">' + asnmEsc(t('tr_broken', { why: why })) + ' <span class="asnm-link" onclick="asnmTrRepair();">' + asnmEsc(t('tr_repair')) + '</span></div>';
    }
    if (d.mode === 'iface') n += '<div>' + asnmEsc(t('tr_mode_iface')) + ' <span class="asnm-link" onclick="asnmTab(\'settings\');">' + asnmEsc(t('tr_mode_change')) + '</span></div>';
    // saving to the USB device: state + switch
    var swOff = ' <span class="asnm-link" onclick="asnmTrSaveMode(\'off\');">' + asnmEsc(t('tr_save_turn_off')) + '</span>';
    if (d.save === 0) n += '<div>' + asnmEsc(t('tr_save_off')) + ' <span class="asnm-link" onclick="asnmTrSaveMode(\'on\');">' + asnmEsc(t('tr_save_turn_on')) + '</span></div>';
    else if (d.store) n += '<div>' + asnmEsc(t('tr_saved_usb', { p: d.store, t: d.saved ? asnmFmtTime(d.saved) : t('never') })) + swOff + '</div>';
    else if (d.state === 'enabled' || (d.rows && d.rows.length)) n += '<div class="asnm-tr-warn">' + asnmEsc(t('tr_no_usb')) + swOff + '</div>';
    note.innerHTML = n;
    asnmSgRender(false);
}

function asnmTrRepair() {
    asnmSetStatus(t('tr_repairing'), false);
    asnmTrCmd('repair');
}

function asnmTrSaveMode(mode) {
    if (mode === 'off' && !confirm(t('tr_save_confirm'))) return;
    asnmSend('statssave', [mode]);
}

/* ---------- suggestions from the traffic without a rule ---------- */
var ASNM_SG = { data: null, added: {}, sel: {}, auto: {}, tgt: {}, f: { n: 10, dev: '', q: '' }, sig: '', fsig: '', open: '', dirty: false, clOpen: {}, note: {}, view: 'asn', loc: {}, showHid: false };
try { if (localStorage.getItem('asnm_sgview_' + ASNM_NS) === 'dom') ASNM_SG.view = 'dom'; } catch (e) {}

// suggestions by ASN or by domain; a domain row is keyed "d:<domain>" (selection, target, note, "added")
function asnmSgSetView(v) {
    ASNM_SG.view = v === 'dom' ? 'dom' : 'asn';
    try { localStorage.setItem('asnm_sgview_' + ASNM_NS, ASNM_SG.view); } catch (e) {}
    ASNM_SG.f.dev = ''; ASNM_SG.f.q = ''; ASNM_SG.fsig = ''; ASNM_SG.open = '';
    asnmSgRender(true);
}
function asnmSgDomSet(on) {
    if (!on && !confirm(t('sgd_off_confirm'))) return;
    asnmSend('setting', ['SG_DOMAINS', on ? 'on' : 'off']);
}
function asnmSgList(d) { return !d ? [] : (ASNM_SG.view === 'dom' ? (d.dlist || []) : (d.list || [])); }
function asnmSgKey(r) { return r.d !== undefined ? 'd:' + r.d : r.asn; }
function asnmSgHidden(r, listed) { return r.d !== undefined ? !!ASNM_SG.added['d:' + r.d] : !!((listed[r.asn] && !r.on) || ASNM_SG.added[r.asn]); }
// hidden suggestions: kept on the router ("hidden" in suggest.js); loc = a click that the router has not confirmed yet
function asnmSgHidKey(r) { return r.d !== undefined ? 'dom:' + r.d : 'asn:' + r.asn; }
function asnmSgIsHid(r) {
    var k = asnmSgHidKey(r);
    if (ASNM_SG.loc.hasOwnProperty(k)) return ASNM_SG.loc[k];
    return ((ASNM_SG.data && ASNM_SG.data.hidden) || []).indexOf(k) >= 0;
}
function asnmSgHide(key, on) {
    var r = asnmSgRow(key);
    if (!r) return;
    var k = asnmSgHidKey(r);
    if (asnmSend('sghide', [on ? 'hide' : 'unhide', k])) { ASNM_SG.loc[k] = on; ASNM_SG.open = ''; asnmSgRender(true); }
}
function asnmSgViewSeg() {
    var v = ASNM_SG.view;
    return '<span class="asnm-seg-label">' + asnmEsc(t('sgv_label')) + '</span><div class="asnm-seg">' +
           '<span class="' + (v === 'asn' ? 'asnm-on' : '') + '" onclick="asnmSgSetView(\'asn\');">' + asnmEsc(t('sgv_asn')) + '</span>' +
           '<span class="' + (v === 'dom' ? 'asnm-on' : '') + '" onclick="asnmSgSetView(\'dom\');">' + asnmEsc(t('sgv_dom')) + '</span></div>';
}

// "+N more" in the "Used by" column: show every device of this ASN (with its traffic), or fold the list again
function asnmSgClToggle(asn) {
    if (ASNM_SG.clOpen[asn]) delete ASNM_SG.clOpen[asn]; else ASNM_SG.clOpen[asn] = 1;
    asnmSgRender(true);
}

function asnmSgSetDev(ip) {
    for (var a in ASNM_SG.auto) { delete ASNM_SG.sel[a]; }
    ASNM_SG.auto = {};
    ASNM_SG.f.dev = ip;
    asnmSgRender(true);
}

function asnmSgLoad() {
    asnmGet('suggest.js', function (txt) {
        var d = null;
        try { d = JSON.parse(txt); } catch (e) {}
        ASNM_SG.data = d;
        if (d) for (var k in ASNM_SG.loc) if (((d.hidden || []).indexOf(k) >= 0) === ASNM_SG.loc[k]) delete ASNM_SG.loc[k];
        asnmSgRender(false);
    }, function () { ASNM_SG.data = null; asnmSgRender(false); });
}

// default target: the first VPN client that is online, else the first interface
function asnmSgDefaultTarget() {
    var f = (ASNM.data && ASNM.data.ifaces) || [], i;
    for (i = 0; i < f.length; i++) if (f[i].up && /^(WGC|OVPN)/.test(f[i].id)) return f[i].id;
    for (i = 0; i < f.length; i++) if (f[i].up) return f[i].id;
    return f.length ? f[0].id : '';
}

// the table and the suggestions are collapsed by default
function asnmSecToggle(id) {
    ASNM_TR.sec = ASNM_TR.sec || {};
    var on = ASNM_TR.sec[id] = !ASNM_TR.sec[id];
    document.getElementById('asnm_sec_' + id + '_body').style.display = on ? 'block' : 'none';
    var h = document.getElementById('asnm_sec_' + id + '_head');
    h.className = 'asnm-sec-head' + (on ? ' open' : '');
    h.setAttribute('aria-expanded', on ? 'true' : 'false');
    if (id === 'sg' && on) { ASNM_SG.fsig = ''; asnmSgRender(true); }
}
function asnmSecKey(ev, id) {
    if (ev.target !== ev.currentTarget) return;
    if (ev.key === 'Enter' || ev.key === ' ') { ev.preventDefault(); asnmSecToggle(id); }
}

function asnmSgListed() {
    var m = {};
    if (ASNM.data && ASNM.data.entries) for (var i = 0; i < ASNM.data.entries.length; i++) m[ASNM.data.entries[i].asn] = 1;
    return m;
}

// suggestions after the device and text filter, sorted by traffic (of the chosen device)
function asnmSgRows() {
    var d = ASNM_SG.data, f = ASNM_SG.f, listed = asnmSgListed(), q = f.q.replace(/^\s+|\s+$/g, '').toLowerCase(), out = [], list = asnmSgList(d);
    for (var i = 0; i < list.length; i++) {
        var r = list[i], b = r.b, txt;
        if (asnmSgHidden(r, listed)) continue;
        var hid = asnmSgIsHid(r);
        if (hid && !ASNM_SG.showHid) continue;
        if (f.dev) { b = 0; for (var c = 0; c < r.cl.length; c++) if (r.cl[c][0] === f.dev) b = r.cl[c][1]; if (!b) continue; }
        if (r.d !== undefined) { txt = r.d; for (var k = 0; k < (r.subs || []).length; k++) txt += ' ' + r.subs[k][0]; }
        else txt = 'as' + r.asn + ' ' + (r.name || '');
        if (q && txt.toLowerCase().indexOf(q) < 0) continue;
        out.push({ r: r, b: b, hid: hid });
    }
    out.sort(function (x, y) { return y.b - x.b; });
    return out;
}

// short target names for the narrow column ("WGC1", "WAN1", full name as tooltip); offline / not set up is marked
function asnmSgTargetOptions(selected) {
    var html = '';
    for (var i = 0; i < ASNM.data.ifaces.length; i++) {
        var f = ASNM.data.ifaces[i], id = f.id, lbl = id;
        if (!f.up) lbl += ' (' + (f.exists ? t('offline') : t('not_configured')) + ')';
        html += '<option value="' + id + '"' + (id === selected ? ' selected="selected"' : '') + ' title="' + asnmEsc(asnmDestLabel(id)) + '">' + asnmEsc(lbl) + '</option>';
    }
    return html;
}

function asnmSgDevLabel(ip) { var n = asnmDeviceName(ip); return (n ? n + ' - ' : '') + ip; }

function asnmSgFilterBar(d) {
    var f = ASNM_SG.f, tot = {}, ips = [], i, c, h, list = asnmSgList(d), listed = asnmSgListed(), nh = 0;
    for (i = 0; i < list.length; i++) if (!asnmSgHidden(list[i], listed) && asnmSgIsHid(list[i])) nh++;
    for (i = 0; i < list.length; i++) for (c = 0; c < list[i].cl.length; c++) {
        var ip = list[i].cl[c][0];
        if (!(ip in tot)) { tot[ip] = 0; ips.push(ip); }
        tot[ip] += list[i].cl[c][1];
    }
    ips.sort(function (x, y) { return tot[y] - tot[x]; });
    h = '<label>' + asnmEsc(t('sg_f_show')) + ' <select class="input_option" style="width:72px;" onchange="ASNM_SG.f.n = +this.value; asnmSgRender(true);">';
    var counts = [10, 20, 50, 100];
    for (i = 0; i < counts.length; i++) h += '<option value="' + counts[i] + '"' + (f.n === counts[i] ? ' selected="selected"' : '') + '>' + counts[i] + '</option>';
    h += '</select></label><label>' + asnmEsc(t('sg_f_dev')) + ' <select class="input_option" style="width:200px;" onchange="asnmSgSetDev(this.value);">' +
         '<option value="">' + asnmEsc(t('sg_all_dev_f')) + '</option>';
    for (i = 0; i < ips.length; i++) h += '<option value="' + asnmEsc(ips[i]) + '"' + (f.dev === ips[i] ? ' selected="selected"' : '') + '>' + asnmEsc(asnmSgDevLabel(ips[i])) + '</option>';
    h += '</select></label><input type="text" class="asnm-sg-q" autocomplete="off" placeholder="' + asnmEsc(t(ASNM_SG.view === 'dom' ? 'sgd_f_q' : 'sg_f_q')) + '" value="' + asnmEsc(f.q) + '" ' +
         'oninput="ASNM_SG.f.q = this.value; asnmSgRender(true);"/>';
    if (nh) h += '<label class="asnm-sg-showhid"><input type="checkbox"' + (ASNM_SG.showHid ? ' checked="checked"' : '') +
                 ' onchange="ASNM_SG.showHid = this.checked; asnmSgRender(true);"/>' + asnmEsc(t('sg_showhid', { n: nh })) + '</label>';
    h += '<span class="asnm-sg-count" id="asnm_sg_count"></span>';
    return { html: h, sig: ips.join(',') + '|' + ASNM_LANG + '|' + ASNM_SG.view + '|' + nh + '|' + ASNM_SG.showHid };
}

function asnmMsLabel(asn) {
    var s = ASNM_SG.sel[asn] || [];
    if (!s.length) return t('sg_all');
    if (s.length === 1) return asnmDeviceName(s[0]) || s[0];
    return t('sg_n_dev', { n: s.length });
}

// device selection with checkboxes: "All devices" or any number of devices
function asnmMsHtml(r) {
    var asn = asnmEsc(r.asn), s = ASNM_SG.sel[r.asn] || [], on = {}, i, used = {};
    for (i = 0; i < s.length; i++) on[s[i]] = 1;
    function item(ip, label, extra) {
        return '<label class="asnm-ms-item"><input type="checkbox" value="' + asnmEsc(ip) + '"' + (on[ip] ? ' checked="checked"' : '') +
               ' onchange="asnmMsChange(\'' + asn + '\', this);"/>' + asnmEsc(label) + (extra ? ' <span class="asnm-muted">' + extra + '</span>' : '') + '</label>';
    }
    var h = '<div class="asnm-ms' + (ASNM_SG.open === r.asn ? ' open' : '') + '" id="asnm_ms_' + asn + '">' +
            '<button type="button" class="asnm-ms-btn" onclick="asnmMsToggle(\'' + asn + '\', event);"><span>' + asnmEsc(asnmMsLabel(r.asn)) + '</span><i></i></button>' +
            '<div class="asnm-ms-pop" onclick="event.stopPropagation();">' +
            '<label class="asnm-ms-item asnm-ms-all"><input type="checkbox"' + (s.length ? '' : ' checked="checked"') + ' onchange="asnmMsAll(\'' + asn + '\');"/>' + asnmEsc(t('sg_all')) + '</label>';
    if (r.cl.length) {
        h += '<div class="asnm-ms-grp">' + asnmEsc(t('sg_grp_used')) + '</div>';
        for (i = 0; i < r.cl.length; i++) { used[r.cl[i][0]] = 1; h += item(r.cl[i][0], asnmSgDevLabel(r.cl[i][0]), asnmFmtBytes(r.cl[i][1])); }
    }
    var devs = (ASNM.data && ASNM.data.devices) || [], groups = [['lan', t('dev_lan')], ['wg', t('dev_wg')], ['ovpn', t('dev_ovpn')]];
    for (var g = 0; g < groups.length; g++) {
        var part = '';
        for (i = 0; i < devs.length; i++) {
            var dv = devs[i];
            if ((dv.kind || 'lan') !== groups[g][0] || used[dv.ip]) continue;
            var dn = asnmDevLabel(dv);
            part += item(dv.ip, (dn ? dn + ' - ' : '') + dv.ip, '');
        }
        if (part) h += '<div class="asnm-ms-grp">' + asnmEsc(groups[g][1]) + '</div>' + part;
    }
    return h + '</div></div>';
}

function asnmMsUpdate(asn) {
    var box = document.getElementById('asnm_ms_' + asn);
    if (!box) return;
    var s = ASNM_SG.sel[asn] || [];
    box.querySelector('.asnm-ms-btn span').textContent = asnmMsLabel(asn);
    box.querySelector('.asnm-ms-all input').checked = !s.length;
    var cbs = box.querySelectorAll('.asnm-ms-item input[value]');
    for (var i = 0; i < cbs.length; i++) cbs[i].checked = s.indexOf(cbs[i].value) >= 0;
}
function asnmMsChange(asn, cb) {
    var s = (ASNM_SG.sel[asn] || []).slice(0), k = s.indexOf(cb.value);
    if (cb.checked && k < 0) s.push(cb.value);
    if (!cb.checked && k >= 0) s.splice(k, 1);
    ASNM_SG.sel[asn] = s;
    delete ASNM_SG.auto[asn];
    asnmMsUpdate(asn);
}
function asnmMsAll(asn) { ASNM_SG.sel[asn] = []; delete ASNM_SG.auto[asn]; asnmMsUpdate(asn); }
function asnmMsToggle(asn, ev) {
    if (ev) ev.stopPropagation();
    ASNM_SG.open = ASNM_SG.open === asn ? '' : asn;
    var all = document.querySelectorAll('#asnm_sg .asnm-ms');
    for (var i = 0; i < all.length; i++) all[i].className = 'asnm-ms' + (all[i].id === 'asnm_ms_' + ASNM_SG.open ? ' open' : '');
    if (!ASNM_SG.open) asnmSgFlush();
}
// a click anywhere else closes the device list
document.addEventListener('click', function () { if (ASNM_SG.open) asnmMsToggle(ASNM_SG.open, null); });
// renders what arrived while the user was choosing something
function asnmSgFlush() { if (ASNM_SG.dirty) setTimeout(function () { asnmSgRender(false); }, 0); }

function asnmSgRender(force) {
    var box = document.getElementById('asnm_sg'), cnt = document.getElementById('asnm_sec_sg_cnt');
    if (!box) return;
    var tr = ASNM_TR.data, d = ASNM_SG.data, listed = asnmSgListed(), n = 0, i, dom = ASNM_SG.view === 'dom', list = asnmSgList(d);
    for (i = 0; i < list.length; i++) if (!asnmSgHidden(list[i], listed) && !asnmSgIsHid(list[i])) n++;
    cnt.textContent = (tr && tr.state === 'enabled' && d && d.acct) ? t('sec_cnt', { n: n }) : '';
    cnt.style.display = cnt.textContent ? '' : 'none';
    if (!ASNM_TR.open || !(ASNM_TR.sec && ASNM_TR.sec.sg)) return;
    // do not disturb while a dropdown, the search field or a device list is in use
    var ae = document.activeElement;
    if (!force && (ASNM_SG.open || (ae && box.contains(ae) && (ae.tagName === 'SELECT' || ae.tagName === 'INPUT')))) { ASNM_SG.dirty = true; return; }
    var sig = JSON.stringify(d ? [d.list, d.dlist, d.dlog, d.dnone, d.pending, d.acct, d.since] : null) + '|' + (tr ? tr.state : '') + '|' + JSON.stringify(ASNM_SG.f) + '|' +
              JSON.stringify(ASNM_SG.added) + '|' + JSON.stringify(listed) + '|' + ASNM_LANG + '|' + ASNM_SG.view + '|' +
              JSON.stringify(d ? d.hidden : null) + JSON.stringify(ASNM_SG.loc) + ASNM_SG.showHid + ASNM_SG.noneOpen;
    if (!force && sig === ASNM_SG.sig) return;
    ASNM_SG.sig = sig; ASNM_SG.dirty = false;
    var msg = '';
    if (!tr || tr.state !== 'enabled') msg = '<div class="asnm-muted">' + asnmEsc(t('sg_off')) + '</div>';
    else if (!d) msg = '<div class="asnm-muted">' + asnmEsc(t('sg_wait')) + '</div>';
    else if (!d.acct) msg = '<div class="asnm-tr-warn">' + asnmEsc(t('sg_noacct')) + '</div>';
    if (msg) { ASNM_SG.fsig = ''; box.innerHTML = msg; return; }

    var top = '<div class="asnm-sg-top">' + asnmSgViewSeg() + '<span class="asnm-sg-since" id="asnm_sg_since"></span></div>';
    // by domain, but the lookup log is off: what it does, and the switch
    if (dom && (!d.dlog || d.dlog === 'off')) {
        ASNM_SG.fsig = '';
        box.innerHTML = top + '<div class="asnm-sg-domoff">' + asnmEsc(t('sgd_off_text')) + '<div><input type="button" class="button_gen asnm-btn asnm-primary" value="' +
                        asnmEsc(t('sgd_turn_on')) + '" onclick="asnmSgDomSet(true);"/></div></div>';
        asnmApplyBusy();
        return;
    }
    // filter bar: built once (and when the device list or the view changes), so the search field keeps the focus
    var fb = asnmSgFilterBar(d);
    if (ASNM_SG.fsig !== fb.sig || !document.getElementById('asnm_sg_tbl')) {
        var foot = dom ? asnmEsc(t('sgd_note')) + (d.dlog === 'ext' ? ' ' + asnmEsc(t('sgd_ext')) : '') +
                         ' <span class="asnm-link" onclick="asnmSgDomSet(false);">' + asnmEsc(t('sgd_turn_off')) + '</span>'
                       : asnmEsc(t('sg_note'));
        box.innerHTML = top + '<div class="asnm-sg-filter">' + fb.html + '</div>' +
                        '<div id="asnm_sg_tbl"></div><div class="asnm-sg-foot">' + foot + '</div>';
        ASNM_SG.fsig = fb.sig;
    }
    document.getElementById('asnm_sg_since').textContent = d.since ? t('sg_since', { t: asnmFmtTime(d.since) }) : '';

    var rows = asnmSgRows(), shown = rows.slice(0, ASNM_SG.f.n), def = asnmSgDefaultTarget(), html = '', tot = dom ? d.dtotal : d.total;
    document.getElementById('asnm_sg_count').textContent = t(dom ? 'sgd_f_count' : 'sg_f_count', { x: shown.length, y: rows.length }) +
        (tot > list.length ? t('sg_f_total', { n: tot }) : '');
    if (!shown.length) {
        if (n || ASNM_SG.showHid) html = t(dom ? 'sgd_nomatch' : 'sg_nomatch');
        else if (dom) html = list.length ? t('sg_empty') : t('sgd_empty');
        else html = d.pending ? asnmSgPendingText(d) : t('sg_empty');
        html = '<div class="asnm-muted">' + asnmEsc(html) + '</div>';
    } else {
        html = '<table class="asnm-table"><tr><th>' + t(dom ? 'sgd_th_dom' : 'sg_th_asn') + '</th><th style="text-align:right;">' + (ASNM_SG.f.dev ? t('sg_th_b_dev') : t('sg_th_b')) + '</th>' +
               '<th>' + t('sg_th_cl') + '</th><th>' + t('sg_th_t') + '</th><th>' + t('sg_th_dev') + '</th><th>' + t('note_lbl') + '</th><th></th></tr>';
        for (i = 0; i < shown.length; i++) {
            var r = shown[i].r, key = asnmSgKey(r), a = asnmEsc(key), who = [];
            if (ASNM_SG.f.dev && ASNM_SG.sel[key] === undefined) { ASNM_SG.sel[key] = [ASNM_SG.f.dev]; ASNM_SG.auto[key] = 1; }   // filter by device -> preselect it
            var clOpen = !!ASNM_SG.clOpen[key], allNames = [];
            for (var c = 0; c < r.cl.length; c++) allNames.push((asnmDeviceName(r.cl[c][0]) || r.cl[c][0]) + ' (' + asnmFmtBytes(r.cl[c][1]) + ')');
            if (clOpen) {
                // every device on its own line with its traffic, a click closes the list again
                for (c = 0; c < r.cl.length; c++)
                    who.push('<div class="asnm-sg-clrow"><span>' + asnmEsc(asnmDeviceName(r.cl[c][0]) || r.cl[c][0]) + '</span><span class="asnm-muted">' + asnmFmtBytes(r.cl[c][1]) + '</span></div>');
                if (r.cl.length > 2) who.push('<span class="asnm-link" onclick="asnmSgClToggle(\'' + a + '\');">' + asnmEsc(t('sg_less')) + '</span>');
            } else {
                for (c = 0; c < r.cl.length && c < 2; c++) who.push(asnmEsc(asnmDeviceName(r.cl[c][0]) || r.cl[c][0]));
                if (r.cl.length > 2) who.push('<span class="asnm-link" title="' + asnmEsc(allNames.join('\n')) + '" onclick="asnmSgClToggle(\'' + a + '\');">' + asnmEsc(t('sg_more', { n: r.cl.length - 2 })) + '</span>');
            }
            var onTxt = '';
            if (r.on) {
                var od = String(r.osrc).split(','), on = [];
                for (var k = 0; k < od.length; k++) on.push(asnmDeviceName(od[k]) || od[k]);
                onTxt = '<div class="asnm-sg-on">' + asnmEsc(t('sg_on_list', { d: on.join(', '), t: r.on })) + '</div>';
                if (!ASNM_SG.tgt[key]) ASNM_SG.tgt[key] = r.on;
            }
            var first;
            if (dom) {
                // the names that were looked up under this domain (busiest first)
                var subs = r.subs || [], sh = [], tip = [];
                for (k = 0; k < subs.length; k++) { tip.push(subs[k][0] + ' (' + asnmFmtBytes(subs[k][1]) + ')'); if (sh.length < 2 && subs[k][0] !== r.d) sh.push(subs[k][0]); }
                var more = (r.nsub || subs.length) - sh.length - (subs.length && subs[0][0] === r.d ? 1 : 0);
                first = '<b>' + asnmEsc(r.d) + '</b><span class="asnm-sg-name asnm-dev" title="' + asnmEsc(tip.join('\n')) + '">' +
                        asnmEsc(sh.join(', ') + (more > 0 ? (sh.length ? ' ' : '') + t('sgd_subs_more', { n: more }) : '')) + '</span>';
                // traffic of servers that also answered for other domains (CDN): counted here, but not certain
                if (r.amb > 0 && (r.alt || []).length)
                    first += '<div class="asnm-sg-amb" title="' + asnmEsc(t('sgd_amb_tip')) + '">⚠ ' + asnmEsc(t('sgd_amb', { b: asnmFmtBytes(r.amb), d: r.alt.join(', ') })) + '</div>';
            } else {
                first = '<b>AS' + a + '</b><span class="asnm-sg-name asnm-dev" title="' + asnmEsc(r.name) + '">' + asnmEsc(r.name || '-') + '</span>';
            }
            var hidBtn = shown[i].hid
                ? '<button type="button" class="asnm-sg-x" title="' + asnmEsc(t('sg_unhide')) + '" aria-label="' + asnmEsc(t('sg_unhide')) + '" onclick="asnmSgHide(\'' + a + '\', false);">' +
                  '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12z"/><circle cx="12" cy="12" r="3"/></svg></button>'
                : '<button type="button" class="asnm-sg-x" title="' + asnmEsc(t('sg_hide')) + '" aria-label="' + asnmEsc(t('sg_hide')) + '" onclick="asnmSgHide(\'' + a + '\', true);">' +
                  '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17.94 17.94A10.1 10.1 0 0 1 12 19c-6.5 0-10-7-10-7a18.4 18.4 0 0 1 5.06-5.94M9.9 4.24A9.1 9.1 0 0 1 12 4c6.5 0 10 7 10 7a18.5 18.5 0 0 1-2.16 3.19M14.12 14.12a3 3 0 1 1-4.24-4.24"/><path d="M2 2l20 20"/></svg></button>';
            html += '<tr' + (shown[i].hid ? ' class="asnm-sg-hid"' : '') + '><td>' + first + onTxt + '</td>' +
                    '<td class="num">' + asnmFmtBytes(shown[i].b) + '</td><td class="asnm-sg-cl" title="' + asnmEsc(allNames.join('\n')) + '">' + (clOpen ? who.join('') : who.join(', ')) + '</td>' +
                    '<td><select id="asnm_sg_t_' + a + '" class="input_option asnm-sg-sel" onchange="ASNM_SG.tgt[\'' + a + '\'] = this.value;" onblur="asnmSgFlush();">' +
                    asnmSgTargetOptions(ASNM_SG.tgt[key] || def) + '</select></td>' +
                    '<td>' + asnmMsHtml({ asn: key, cl: r.cl }) + '</td>' +
                    '<td><input type="text" id="asnm_sg_n_' + a + '" class="asnm-sg-note" maxlength="60" value="' + asnmEsc(ASNM_SG.note[key] || '') + '" placeholder="' + asnmEsc(t('hint_optional')) + '" oninput="ASNM_SG.note[\'' + a + '\'] = this.value;" onblur="asnmSgFlush();" onkeydown="if (event.keyCode === 13) { asnmSgAdd(\'' + a + '\'); return false; }"/></td>' +
                    '<td class="asnm-nowrap"><input type="button" class="button_gen asnm-small-btn asnm-btn asnm-primary" value="' + asnmEsc(t('sg_add')) + '" onclick="asnmSgAdd(\'' + a + '\');"/>' + hidBtn + '</td></tr>';
        }
        html += '</table>';
        if (!dom && d.pending) html += '<div class="asnm-sg-foot">' + asnmEsc(asnmSgPendingText(d)) + '</div>';
    }
    if (dom && d.dnone > 0) {
        // addresses without a name: a click shows the busiest with network and device (helps to find a device with its own DNS)
        var nl = d.dnolist || [];
        html += '<div class="asnm-sg-foot">' + asnmEsc(t('sgd_none', { b: asnmFmtBytes(d.dnone), n: d.dnoneips || 0 })) +
                (nl.length ? ' <span class="asnm-link" onclick="ASNM_SG.noneOpen = !ASNM_SG.noneOpen; asnmSgRender(true);">' + asnmEsc(t(ASNM_SG.noneOpen ? 'sgd_none_hide' : 'sgd_none_show')) + '</span>' : '') + '</div>';
        if (ASNM_SG.noneOpen && nl.length) {
            html += '<table class="asnm-table asnm-sg-none"><tr><th>' + t('sgd_none_ip') + '</th><th style="text-align:right;">' + t('sg_th_b') + '</th><th>' + t('sgd_none_net') + '</th><th>' + t('sgd_none_dev') + '</th></tr>';
            for (i = 0; i < nl.length; i++) {
                var u = nl[i];
                html += '<tr><td>' + asnmEsc(u[0]) + '</td><td class="num">' + asnmFmtBytes(u[1]) + '</td><td>' + (u[2] ? 'AS' + asnmEsc(u[2]) + ' <span class="asnm-muted">' + asnmEsc(u[3] || '') + '</span>' : '<span class="asnm-muted">-</span>') +
                        '</td><td>' + asnmEsc(asnmDeviceName(u[4]) || u[4] || '-') + '</td></tr>';
            }
            html += '</table><div class="asnm-sg-foot">' + asnmEsc(t('sgd_none_tip')) + '</div>';
        }
    }
    document.getElementById('asnm_sg_tbl').innerHTML = html;
    asnmApplyBusy();
}

function asnmSgPendingText(d) {
    var s = t('sg_pending', { n: d.pending, b: asnmFmtBytes(d.pendb || 0) });
    if (d.fails) s += ' ' + t('sg_fails', { n: d.fails });
    return s;
}

function asnmSgRow(key) {
    var d = ASNM_SG.data, i;
    if (!d) return null;
    if (key.indexOf('d:') === 0) { for (i = 0; i < (d.dlist || []).length; i++) if ('d:' + d.dlist[i].d === key) return d.dlist[i]; return null; }
    if (d.list) for (i = 0; i < d.list.length; i++) if (d.list[i].asn === key) return d.list[i];
    return null;
}

function asnmSgAdd(asn) {
    var sel = document.getElementById('asnm_sg_t_' + asn), r = asnmSgRow(asn), pick = ASNM_SG.sel[asn] || [], src = pick.join(',');
    if (!sel || !sel.value) return;
    // ASN already on the list for some devices: add the chosen devices to that rule (empty = all devices)
    if (r && r.on && pick.length) src = asnmNormSrc(r.osrc + ',' + src);
    var note = String(ASNM_SG.note[asn] || '').replace(/[\u0000-\u001f"\\|<>]/g, '').trim().slice(0, 60);
    var val = asn.indexOf('d:') === 0 ? asn.slice(2) : asn;
    if (asnmSend('add', [sel.value, src, val, encodeURIComponent(note)])) { ASNM_SG.added[asn] = 1; ASNM_SG.open = ''; delete ASNM_SG.note[asn]; asnmSgRender(true); }
}

/* ============================ failover ============================ */
var ASNM_FO = { data: null, edit: {}, sig: '' };

function asnmFoChain(tg) {
    var d = ASNM_FO.data;
    if (d && d.chains) for (var i = 0; i < d.chains.length; i++) if (d.chains[i].t === tg) return d.chains[i];
    return null;
}
function asnmFoBadge(dest) {
    var c = asnmFoChain(asnmNormDest(dest));
    if (!c || !c.active || c.active === c.t) return '';
    return ' <span class="asnm-badge asnm-warn">↪ ' + asnmEsc(c.active === 'BLOCK' ? t('fo_block_s') : c.active) + '</span>';
}

function asnmFoLoad() {
    asnmGet('failover.js', function (txt) {
        var d = null;
        try { d = JSON.parse(txt); } catch (e) {}
        ASNM_FO.data = d;
        asnmFoAfterLoad();
    }, function () { ASNM_FO.data = null; asnmFoAfterLoad(); });
}
function asnmFoAfterLoad() {
    asnmFoRender();
    // the ASN list only needs a redraw when a failover started or ended
    var sig = '', d = ASNM_FO.data;
    if (d && d.chains) for (var i = 0; i < d.chains.length; i++) sig += d.chains[i].t + ':' + d.chains[i].active + ';';
    if (sig !== ASNM_FO.sig) { ASNM_FO.sig = sig; if (ASNM.data && !ASNM.editing) asnmRenderList(); }
}

function asnmFoOptions(tg, sel) {
    var html = '<option value="">' + asnmEsc(t('fo_none')) + '</option>';
    for (var i = 0; i < ASNM.data.ifaces.length; i++) {
        var f = ASNM.data.ifaces[i];
        if (f.id === tg) continue;
        var st = f.up ? '' : ' (' + (f.exists ? t('offline') : t('not_configured')) + ')';
        html += '<option value="' + f.id + '"' + (f.id === sel ? ' selected="selected"' : '') + ' title="' + asnmEsc(asnmDestLabel(f.id)) + '">' + asnmEsc(f.id + st) + '</option>';
    }
    return html + '<option value="BLOCK"' + (sel === 'BLOCK' ? ' selected="selected"' : '') + '>' + asnmEsc(t('fo_block_opt')) + '</option>';
}

function asnmFoState(tg, c) {
    if (!c) return '<span class="asnm-muted">' + asnmEsc(t('fo_off')) + '</span>';
    var hl = (ASNM_FO.data && ASNM_FO.data.health) || {}, m = [tg].concat(c.fb), parts = [], st;
    for (var i = 0; i < m.length; i++) {
        if (m[i] === 'BLOCK') { parts.push('<span class="asnm-fo-m">' + asnmEsc(t('fo_block_s')) + '</span>'); continue; }
        var h = hl[m[i]];
        parts.push('<span class="asnm-fo-m ' + (h === 'up' ? 'asnm-rc-ok' : (h === 'down' ? 'asnm-rc-bad' : 'asnm-muted')) + '">' +
                   asnmEsc(m[i]) + (h === 'up' ? ' ✓' : (h === 'down' ? ' ✗' : '')) + '</span>');
    }
    if (!c.active) st = '<span class="asnm-muted">' + asnmEsc(t('fo_pending')) + '</span>';
    else if (c.active === tg) st = '<span class="asnm-badge asnm-ok">' + asnmEsc(t('fo_ok', { i: tg })) + '</span>';
    else if (c.active === 'BLOCK') st = '<span class="asnm-badge asnm-bad">' + asnmEsc(t('fo_blocked')) + '</span>';
    else st = '<span class="asnm-badge asnm-warn">' + asnmEsc(t('fo_via', { i: c.active })) + '</span>';
    if (c.active && c.active !== tg && c.since) st += '<div class="asnm-dev">' + asnmEsc(t('fo_since', { t: asnmFmtTime(c.since) })) + '</div>';
    return st + '<div class="asnm-fo-chain">' + parts.join(' → ') + '</div>';
}

function asnmFoRender() {
    var box = document.getElementById('asnm_fo');
    if (!box || !ASNM.data) return;
    var ae = document.activeElement;
    if (ae && box.contains(ae) && ae.tagName === 'SELECT') return;          // the user is choosing
    var tgs = [], seen = {}, i, d = ASNM_FO.data;
    for (i = 0; i < ASNM.data.ifaces.length; i++) {
        var id = ASNM.data.ifaces[i].id, used = !!asnmFoChain(id);
        for (var e = 0; e < ASNM.data.entries.length && !used; e++) if (asnmNormDest(ASNM.data.entries[e].dest) === id) used = true;
        if (!used && d && d.vpnd && d.vd && d.vd[id]) used = true;               // lines of the VPN Director
        if (used && !seen[id]) { seen[id] = 1; tgs.push(id); }
    }
    var vd = d && d.vpnd ? 1 : 0;
    var h = '<div class="asnm-fo-head"><span class="asnm-sec-title">' + asnmEsc(t('fo_title')) + '</span><span class="asnm-dev">' + asnmEsc(t('fo_sub')) + '</span></div>' +
        '<div class="asnm-dw-row" style="border-top:0;padding-top:0;"><div class="asnm-dw-txt"><span class="asnm-label">' + asnmEsc(t('fo_vd')) + '</span><span class="asnm-help">' + asnmEsc(t('fo_vd_desc')) + '</span>' +
        (d && d.vdmoved ? '<div class="asnm-help"><span class="asnm-dw-no">' + asnmEsc(t('fo_vd_moved', { n: d.vdmoved })) + '</span></div>' : '') + '</div>' +
        '<div class="asnm-seg"><span class="' + (vd ? '' : 'asnm-on') + '" onclick="asnmFoVd(0);">' + asnmEsc(t('dnsf_off')) + '</span><span class="' + (vd ? 'asnm-on' : '') + '" onclick="asnmFoVd(1);">' + asnmEsc(t('dnsf_on')) + '</span></div></div>';
    if (!tgs.length) { box.innerHTML = h + '<div class="asnm-muted">' + asnmEsc(t('fo_noasn')) + '</div>'; return; }
    h += '<table class="asnm-table"><tr><th>' + t('fo_th_t') + '</th><th>' + t('fo_th_1') + '</th><th>' + t('fo_th_2') + '</th><th>' + t('fo_th_state') + '</th><th></th></tr>';
    for (i = 0; i < tgs.length; i++) {
        var tg = tgs[i], c = asnmFoChain(tg), ed = ASNM_FO.edit[tg] || (c ? [c.fb[0] || '', c.fb[1] || ''] : ['', '']);
        h += '<tr><td><b>' + asnmEsc(tg) + '</b><div class="asnm-dev">' + asnmEsc(asnmDestLabel(tg)) + '</div>' +
             (vd && d.vd && d.vd[tg] ? '<div class="asnm-dev">' + asnmEsc(t('fo_vd_n', { n: d.vd[tg] })) + '</div>' : '') + '</td>' +
             '<td><select id="asnm_fo1_' + tg + '" class="input_option asnm-fo-sel" onchange="asnmFoEdit(\'' + tg + '\');">' + asnmFoOptions(tg, ed[0]) + '</select></td>' +
             '<td><select id="asnm_fo2_' + tg + '" class="input_option asnm-fo-sel" onchange="asnmFoEdit(\'' + tg + '\');">' + asnmFoOptions(tg, ed[1]) + '</select></td>' +
             '<td>' + asnmFoState(tg, c) + '</td>' +
             '<td><input type="button" class="button_gen asnm-small-btn asnm-btn asnm-primary" value="' + asnmEsc(t('fo_save')) + '" onclick="asnmFoSave(\'' + tg + '\');"/></td></tr>';
    }
    box.innerHTML = h + '</table><div class="asnm-sg-foot">' + asnmEsc(t('fo_note', { s: (d && d.interval) || 30 })) + '</div>';
    asnmApplyBusy();
}

function asnmFoVd(on) {
    var cur = ASNM_FO.data && ASNM_FO.data.vpnd ? 1 : 0;
    if (on === cur || ASNM.busy) return;
    if (on && !confirm(t('fo_vd_c_on'))) return;
    asnmSend('setting', ['FO_VPND', on ? 'on' : 'off']);
}
function asnmFoEdit(tg) {
    ASNM_FO.edit[tg] = [document.getElementById('asnm_fo1_' + tg).value, document.getElementById('asnm_fo2_' + tg).value];
}

function asnmFoSave(tg) {
    var a = document.getElementById('asnm_fo1_' + tg).value, b = document.getElementById('asnm_fo2_' + tg).value;
    if (!a && b) { a = b; b = ''; }
    if (a && a === b) { alert(t('fo_dup')); return; }
    if (a === 'BLOCK' && b) { alert(t('fo_blocklast')); return; }
    if (asnmSend('failover', [tg, a, b])) delete ASNM_FO.edit[tg];
}

/* ============================ routing check ============================ */
var ASNM_RC = { recheck: false, data: null, checking: false };

function asnmRcMap() {
    var m = {}, d = ASNM_RC.data;
    if (d && d.results) for (var i = 0; i < d.results.length; i++) m[d.results[i].dest + '|' + d.results[i].asn] = d.results[i];
    return m;
}

function asnmRcBadge(e, map) {
    var r = (map || asnmRcMap())[asnmNormDest(e.dest) + '|' + e.asn];
    if (!r) return '<span class="asnm-muted">-</span>';
    var x = asnmRcInfo(r);
    return '<span class="asnm-badge ' + x.cls + '" title="' + asnmEsc(x.tip) + '">' + asnmEsc(x.txt) + '</span>';
}
function asnmRcInfo(r) {
    var cls, txt, tip;
    switch (r.code) {
        case 'ok':       cls = 'asnm-ok';   txt = '✓ ' + r.got;           tip = t('rc_tip_ok', { ip: r.sample, dev: r.got }); break;
        case 'wrongdev': cls = 'asnm-bad';  txt = '✗ ' + r.got;           tip = t('rc_tip_wrong', { ip: r.sample, got: r.got, dev: r.dev }); break;
        case 'down':     cls = 'asnm-bad';  txt = '✗ ' + t('rc_down');    tip = t('rc_tip_down', { dev: r.dev }); break;
        case 'noroute':  cls = 'asnm-bad';  txt = '✗ ' + t('rc_noroute'); tip = t('rc_tip_noroute', { ip: r.sample }); break;
        case 'norule':   cls = 'asnm-warn'; txt = '! ' + t('rc_norule');  tip = t('rc_tip_norule'); break;
        case 'failover': cls = 'asnm-warn'; txt = '↪ ' + r.got;           tip = t('rc_tip_fo', { dev: r.dev, ip: r.sample, got: r.got }); break;
        case 'blocked':  cls = 'asnm-warn'; txt = '⛔ ' + t('rc_blocked'); tip = t('rc_tip_blocked', { d: r.dest }); break;
        case 'pending':  cls = '';          txt = '… ' + t('rc_checking'); tip = t('rc_checking'); break;
        case 'nolearned': cls = 'asnm-warn'; txt = '! ' + t('rc_nolearned'); tip = t('rc_tip_nolearned'); break;
        default:         cls = 'asnm-warn'; txt = '! ' + t('rc_nosub');   tip = t('rc_tip_nosub');
    }
    if (r.recent >= 0) tip += '\n' + t('rc_tip_seen', { dev: r.dev, b: asnmFmtBytes(r.recent) });
    return { cls: cls, txt: txt, tip: tip };
}
// the entries with a warning or an error, as "label - reason" lines (shown below the summary)
function asnmRcIssues() {
    var d = ASNM_RC.data, out = [], i, k, e, lab;
    if (!d || !d.results) return out;
    for (i = 0; i < d.results.length; i++) {
        var r = d.results[i];
        if (r.state === 'ok' || r.state === 'pending') continue;
        lab = 'AS' + r.asn;
        if (/^C\d+$/.test(r.asn)) {                         // own entry (domain / IP): its id
            lab = r.asn;
            var cl = (ASNM.data && ASNM.data.custom) || [];
            for (k = 0; k < cl.length; k++) if (cl[k].id === r.asn) { lab = (cl[k].kind === 'dom' ? '*.' : '') + cl[k].value; break; }
        } else if (ASNM.data && ASNM.data.entries) for (k = 0; k < ASNM.data.entries.length; k++) {
            e = ASNM.data.entries[k];
            if (String(e.asn) === String(r.asn) && asnmNormDest(e.dest) === r.dest) { lab = asnmRcLabel(e); break; }
        }
        var x = asnmRcInfo(r);
        out.push({ bad: r.state !== 'warn', html: '<span class="asnm-badge ' + x.cls + '">' + asnmEsc(x.txt) + '</span> <b>' + asnmEsc(lab) + '</b> → ' + asnmEsc(r.dest) +
            '<div class="asnm-dev">' + asnmEsc(x.tip).replace(/\n/g, '<br>') + '</div>' });
    }
    return out;
}

function asnmRcFailed(r) { return r && r.state !== 'ok' && r.state !== 'warn' && r.state !== 'pending'; }

// entries of the list whose routing check failed, in list order
function asnmRcFailedEntries(map) {
    var out = [], en = (ASNM.data && ASNM.data.entries) || [];
    map = map || asnmRcMap();
    for (var i = 0; i < en.length; i++) if (asnmRcFailed(map[asnmNormDest(en[i].dest) + '|' + en[i].asn])) out.push(en[i]);
    return out;
}

function asnmRcLabel(e) {
    if (e.kind === 'dom') return '*.' + e.value;
    if (e.kind === 'ip') return e.value;
    var n = e.name ? asnmAsName(e.name) : '';
    return 'AS' + e.asn + (n ? ' (' + n + ')' : '');
}

// red badge in a group header: how many entries of the group fail the routing check
function asnmGroupRcHtml(gk, map) {
    var f = asnmRcFailedEntries(map), n = 0;
    for (var i = 0; i < f.length; i++) if (asnmGroupKey(f[i]) === gk) n++;
    return n ? '<span class="asnm-badge asnm-bad">✗ ' + asnmEsc(t('group_rc', { n: n })) + '</span>' : '';
}

// banner link: open the group of the first failing entry, scroll to it and highlight it
function asnmRcGoto() {
    asnmTab('asns');
    var f = asnmRcFailedEntries();
    if (!f.length) return;
    for (var i = 0; i < f.length; i++) ASNM.collapsed[asnmGroupKey(f[i])] = false;
    asnmSaveCollapsed();
    asnmRenderList();
    var first = null;
    for (i = 0; i < f.length; i++) {
        var td = document.getElementById('asnm_rc_' + f[i].asn), tr = td && td.parentNode;
        if (!tr) continue;
        if (!first) first = tr;
        tr.className = (tr.className ? tr.className + ' ' : '') + 'asnm-flash';
        (function (row) { setTimeout(function () { row.className = row.className.replace(/\s*asnm-flash/, ''); }, 4000); })(tr);
    }
    if (first && first.scrollIntoView) first.scrollIntoView({ behavior: 'smooth', block: 'center' });
}

function asnmRcRender() {
    var d = ASNM_RC.data, st = document.getElementById('asnm_rc_state'), ban = document.getElementById('asnm_banner_rc');
    var ok = 0, warn = 0, fail = 0, i;
    if (d && d.results) for (i = 0; i < d.results.length; i++) { var x = d.results[i].state; if (x === 'ok') ok++; else if (x === 'warn') warn++; else if (x !== 'pending') fail++; }
    st.className = '';
    if (ASNM_RC.checking) st.textContent = t('rc_checking');
    else if (!d) st.textContent = '-';
    else if (!d.results.length) st.textContent = t('rc_none');
    else {
        st.textContent = t('rc_summary', { ok: ok, warn: warn, fail: fail }) + ' · ' + t('rc_checked', { t: asnmFmtTime(d.ts) });
        st.className = fail ? 'asnm-rc-bad' : (warn ? 'asnm-rc-warn' : 'asnm-rc-ok');
    }
    ban.style.display = (d && fail) ? 'flex' : 'none';
    // the status card shows the routing check only with warnings or errors (or while it runs after "Check now" there)
    var se = document.getElementById('asnm_rc_err');
    if (se) {
        var show = !!(d && d.results && (warn || fail)) && !ASNM_RC.checking;
        se.style.display = show ? '' : 'none';
        if (show) { var stx = document.getElementById('asnm_rc_err_txt'); stx.textContent = st.textContent; stx.className = st.className; }
    }
    // which entries: listed below the summary (status card and diagnostics)
    var iss = (d && !ASNM_RC.checking) ? asnmRcIssues() : [], ih = '';
    for (i = 0; i < iss.length; i++) ih += '<div style="margin:4px 0 0 0;">' + iss[i].html + '</div>';
    ['asnm_rc_err_list', 'asnm_rc_state_list'].forEach(function (id) { var el = document.getElementById(id); if (el) { el.innerHTML = ih; el.style.display = ih ? '' : 'none'; } });
    if (fail) {
        var fl = asnmRcFailedEntries(), names = [];
        for (i = 0; i < fl.length && i < 3; i++) names.push(asnmRcLabel(fl[i]));
        if (fl.length > 3) names.push('…');
        document.getElementById('asnm_rc_banner_text').textContent = t('banner_rc', { n: fail }) + (names.length ? ' ' + names.join(', ') : '');
    }
    // badges in the ASN list are updated in place (keeps ticked checkboxes and an open edit row)
    if (ASNM.data && ASNM.data.entries) {
        var map = asnmRcMap();
        for (i = 0; i < ASNM.data.entries.length; i++) {
            var el = document.getElementById('asnm_rc_' + ASNM.data.entries[i].asn);
            if (el) el.innerHTML = asnmRcBadge(ASNM.data.entries[i], map);
        }
        var gb = document.querySelectorAll('[data-grc]');
        for (i = 0; i < gb.length; i++) gb[i].innerHTML = asnmGroupRcHtml(gb[i].getAttribute('data-grc'), map);
    }
}

// reads the last result; asks the router for a new check if it is missing or older than 5 minutes
// "none learned" in an older check, but the list says addresses were learned since: not a warning (any more) - check again, once a minute at most
function asnmRcStale(d) {
    if (!d || !d.results || !ASNM.data || !ASNM.data.entries) return;
    var stale = false, q, z;
    for (q = 0; q < d.results.length; q++) {
        if (d.results[q].code !== 'nolearned') continue;
        for (z = 0; z < ASNM.data.entries.length; z++)
            if (ASNM.data.entries[z].asn === d.results[q].asn && ASNM.data.entries[z].learned > 0) { d.results[q].code = 'pending'; d.results[q].state = 'pending'; stale = true; }
    }
    if (stale && !ASNM_RC.checking && !ASNM_RC.recheck) {
        ASNM_RC.recheck = true; setTimeout(function () { ASNM_RC.recheck = false; }, 60000);
        setTimeout(asnmRcCheck, 300);
    }
}

/* ---------- DNS / DHCP health (dns.js: written by the routing check every 5 minutes and on every refresh) ---------- */
// program names as netstat shows them -> as people know them
function asnmDnsName(p) {
    var m = { AdGuardHome: 'AdGuard Home', 'pihole-FTL': 'Pi-hole', unbound: 'Unbound', 'dnscrypt-proxy': 'dnscrypt-proxy', stubby: 'Stubby', dnsmasq: 'dnsmasq' };
    return m[p] || p || '?';
}
function asnmDnsLoad() {
    asnmGet('dns.js', function (txt) {
        var d = null; try { d = JSON.parse(txt); } catch (e) {}
        asnmDnsRender(d);
    }, function () { asnmDnsRender(null); });
}
function asnmDnsRender(d) {
    var st = document.getElementById('asnm_dns_state'), bn = document.getElementById('asnm_dns_banner_text');
    if (!st || !bn) return;
    if (!d) { st.textContent = '-'; bn.parentNode.style.display = 'none'; return; }
    var when = ' <span class="asnm-muted" style="font-weight:400;">' + asnmEsc(t('dns_checked', { t: asnmFmtTime(d.ts) })) + '</span>';
    if (d.state === 'ok') {
        var a = d.port && d.port !== 53 ? t('dns_ok_agh', { p: asnmDnsName(d.p53), port: d.port }) : t('dns_ok');
        if (/^mirror:/.test(d.up || '')) a += ' · ' + t('dns_mirror', { p: asnmDnsName(d.p53) });
        st.innerHTML = '<span class="asnm-rc-ok">✓ ' + asnmEsc(a) + ' · ' + asnmEsc(d.dhcp_on ? t('dns_dhcp_ok') : t('dns_dhcp_off')) + '</span>' + when;
        bn.parentNode.style.display = 'none';
    } else if (d.state === 'warn' && /^agh_/.test(d.code)) {
        // AdGuard Home asks another server directly: dnsmasq sees only some lookups
        var ap = { p: asnmDnsName(d.p53), up: d.up || '?', port: d.port };
        st.innerHTML = '<span class="asnm-rc-warn">! ' + asnmEsc(t('dns_agh', ap)) + '</span>' + when;
        bn.textContent = t(d.code === 'agh_partly' ? 'dns_agh_partly_long' : 'dns_agh_long', ap);
        bn.parentNode.className = 'asnm-banner';
        bn.parentNode.style.display = 'flex';
    } else if (d.state === 'warn') {
        st.innerHTML = '<span class="asnm-rc-warn">! ' + asnmEsc(t('dns_other', { p: asnmDnsName(d.p53) })) + '</span>' + when;
        bn.textContent = t('dns_other_long', { p: asnmDnsName(d.p53) });
        bn.parentNode.className = 'asnm-banner';
        bn.parentNode.style.display = 'flex';
    } else {
        var m = t('dns_bad_' + d.code, { port: d.port });
        st.innerHTML = '<span class="asnm-rc-bad">✗ ' + asnmEsc(m.split(':')[0]) + '</span>' + when;
        bn.parentNode.className = 'asnm-banner asnm-banner-bad';
        bn.textContent = m;
        bn.parentNode.style.display = 'flex';
    }
}

function asnmRcLoad(auto) {
    asnmGet('check.js', function (txt) {
        var d = null;
        try { d = JSON.parse(txt); } catch (e) {}
        if (d) { asnmRcStale(d); ASNM_RC.data = d; }
        asnmRcRender();
        if (auto && (!d || Date.now() / 1000 - d.ts > 300)) asnmRcCheck();
    }, function () { asnmRcRender(); if (auto) asnmRcCheck(); });
}

function asnmRcCheck() {
    if (ASNM_RC.checking) return;
    ASNM_RC.checking = true; asnmRcRender();
    var prev = ASNM_RC.data ? ASNM_RC.data.ts : 0, started = Date.now();
    var f = document.formAsnmStats, page = document.formAsnm.elements['current_page'].value;
    f.elements['current_page'].value = page;
    f.elements['next_page'].value = page;
    f.elements['action_script'].value = 'start_' + ASNM_NS + 'check';
    asnmPost(f);
    function done() { ASNM_RC.checking = false; asnmRcRender(); }
    function again() { if (Date.now() - started > 30000) done(); else setTimeout(poll, 1500); }
    function poll() {
        asnmGet('check.js', function (txt) {
            var d = null;
            try { d = JSON.parse(txt); } catch (e) {}
            if (d && d.ts !== prev) { asnmRcStale(d); ASNM_RC.data = d; done(); return; }
            again();
        }, again);
    }
    setTimeout(poll, 1500);
}

/* ============================ updates ============================ */
var ASNM_UPD = { data: null, checking: false, stale: false, reload: function () { window.location.reload(); } };

function asnmUpdRender() {
    var d = ASNM_UPD.data, st = document.getElementById('asnm_upd_state'), ban = document.getElementById('asnm_banner_update');
    st.className = '';
    if (ASNM_UPD.checking) st.textContent = t('upd_checking');
    else if (!d) st.textContent = '-';
    else if (d.error) { st.textContent = t('upd_error'); st.className = 'asnm-upd-warn'; }
    else if (d.newer) { st.textContent = t('upd_available', { r: d.remote }); st.className = 'asnm-upd-new'; }
    else st.textContent = t('upd_current', { v: d.local }) + ' · ' + t('upd_checked', { t: asnmFmtTime(d.ts) });
    var show = !!(d && d.newer && !d.error);
    ban.style.display = show ? 'flex' : 'none';
    if (show) {
        document.getElementById('asnm_upd_text').textContent = t('banner_update', { r: d.remote, l: d.local });
        var a = document.getElementById('asnm_upd_notes');
        if (/^https:\/\/github\.com\//.test(d.notes || '')) a.setAttribute('href', d.notes); else a.removeAttribute('href');
    }
}

// reads the last result; every time the page opens it looks at GitHub again (not when the last look is less than a
// minute old - a quick reload)
function asnmUpdLoad(auto) {
    asnmGet('update.js', function (txt) {
        try { ASNM_UPD.data = JSON.parse(txt); } catch (e) { ASNM_UPD.data = null; }
        // the stored check result names another installed version (it is from before an update): do not show it, check again
        if (ASNM_UPD.data && ASNM_UPD.data.local && ASNM_UPD.data.local !== ASNM_PAGE_VER && !ASNM_UPD.stale) {
            ASNM_UPD.stale = true; ASNM_UPD.data = null; asnmUpdRender(); asnmUpdCheck(false); return;
        }
        asnmUpdRender();
        var age = ASNM_UPD.data ? Date.now() / 1000 - ASNM_UPD.data.ts : 1e9;
        if (auto && age > 60) asnmUpdCheck(false);
    }, function () { asnmUpdRender(); if (auto) asnmUpdCheck(false); });
}

function asnmUpdCheck(manual) {
    if (ASNM_UPD.checking) return;
    ASNM_UPD.checking = true; asnmUpdRender();
    var prev = ASNM_UPD.data ? ASNM_UPD.data.ts : 0, started = Date.now();
    var f = document.formAsnmStats, page = document.formAsnm.elements['current_page'].value;
    f.elements['current_page'].value = page;
    f.elements['next_page'].value = page;
    f.elements['action_script'].value = 'start_' + ASNM_NS + 'updatecheck';
    asnmPost(f);
    function done() { ASNM_UPD.checking = false; asnmUpdRender(); }
    function again() { if (Date.now() - started > 45000) done(); else setTimeout(poll, 2000); }
    function poll() {
        asnmGet('update.js', function (txt) {
            var d = null;
            try { d = JSON.parse(txt); } catch (e) {}
            if (d && d.ts !== prev) { ASNM_UPD.data = d; done(); return; }      // a new result (independent of clock differences)
            again();
        }, again);
    }
    setTimeout(poll, 2500);
}

function asnmUpdate() {
    var d = ASNM_UPD.data;
    if (!d || !d.newer || ASNM.busy) return;
    if (!confirm(t('upd_confirm', { r: d.remote }))) return;
    asnmSend('update', []);
}

/* ============================ tabs ============================ */
var ASNM_TABS = ['asns', 'traffic', 'targets', 'diag', 'settings'];

function asnmTab(id) {
    if (ASNM_TABS.indexOf(id) < 0) id = 'asns';
    for (var i = 0; i < ASNM_TABS.length; i++) {
        var on = ASNM_TABS[i] === id, p = document.getElementById('asnm_tab_' + ASNM_TABS[i]), b = document.getElementById('asnm_tabbtn_' + ASNM_TABS[i]);
        if (p) p.style.display = on ? 'block' : 'none';
        if (b) { b.className = 'asnm-tab' + (on ? ' on' : ''); b.setAttribute('aria-selected', on ? 'true' : 'false'); }
    }
    asnmTabBadges();
    if (id === 'settings') asnmPerfMark();
    if (id === 'diag') asnmDiagDevFill();
    // inside its own tab the traffic card does not need to be opened first
    if (id === 'traffic' && typeof ASNM_TR !== 'undefined' && !ASNM_TR.open) asnmTrToggle();
}

function asnmSubTab(id) {
    var ids = ['manual', 'lookup', 'presets'];
    if (ids.indexOf(id) < 0) id = 'manual';
    for (var i = 0; i < ids.length; i++) {
        var on = ids[i] === id;
        document.getElementById('asnm_sub_' + ids[i]).style.display = on ? 'block' : 'none';
        document.getElementById('asnm_subbtn_' + ids[i]).className = 'asnm-subtab' + (on ? ' on' : '');
    }
    try { localStorage.setItem('asnm_subtab', id); } catch (e) {}
}

// small counters / signals in the tab bar
function asnmTabBadges() {
    if (typeof ASNM_TR === 'undefined' || typeof ASNM_FO === 'undefined') return;
    var b = document.getElementById('asnm_tabbadge_asns');
    if (b && ASNM.data && ASNM.data.entries) b.textContent = ASNM.data.entries.length;
    b = document.getElementById('asnm_tabbadge_traffic');
    if (b) { var on = ASNM_TR.data && ASNM_TR.data.state === 'enabled'; b.textContent = on ? '●' : ''; b.className = 'asnm-tab-badge' + (on ? ' ok' : ''); }
    b = document.getElementById('asnm_tabbadge_targets');
    if (b) {
        var fo = 0, d = ASNM_FO.data;
        if (d && d.chains) for (var i = 0; i < d.chains.length; i++) if (d.chains[i].active && d.chains[i].active !== d.chains[i].t) fo++;
        b.textContent = fo ? '↪ ' + fo : ''; b.className = 'asnm-tab-badge' + (fo ? ' warn' : '');
    }
}

function initial() {
    document.addEventListener('click', function () {
        var ids = ['asnm_add_ms', 'asnm_preset_ms', 'asnm_edit_ms'];
        for (var i = 0; i < ids.length; i++) { var b = document.getElementById(ids[i]); if (b) b.className = 'asnm-ms'; }
    });
    try { ASNM_TR.unit = localStorage.getItem('asnm_rate_unit') === 'mbyte' ? 'mbyte' : 'mbit'; } catch (e) { ASNM_TR.unit = 'mbit'; }
    asnmUnitMark();
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
    asnmUpdLoad(true);
    asnmSpLoad();
    asnmAdoptJob();
    var subStart = 'manual';
    try { subStart = localStorage.getItem('asnm_subtab') || 'manual'; } catch (e) {}
    asnmSubTab(subStart);
    asnmTab('asns');                       // the page always starts on the ASNs tab
    setTimeout(asnmTabBadges, 800); setTimeout(asnmTabBadges, 2000);
    setInterval(asnmTabBadges, 3000);
    asnmRcLoad(true);
    setInterval(function () { asnmRcLoad(false); }, 60000);
    asnmDnsLoad();
    setInterval(asnmDnsLoad, 60000);
    asnmFoLoad();
    setInterval(asnmFoLoad, 30000);
    setInterval(asnmLrLoad, 30000);
    asnmTrLoad();
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
<form method="post" name="formAsnmStats" action="/start_apply.htm" onsubmit="return false;">
<input type="hidden" name="current_page" value=""/>
<input type="hidden" name="next_page" value=""/>
<input type="hidden" name="modified" value="0"/>
<input type="hidden" name="action_mode" value="apply"/>
<input type="hidden" name="action_wait" value="0"/>
<input type="hidden" name="action_script" value=""/>
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
      <div class="asnm-logo-wrap">
        <span class="asnm-orb o1" aria-hidden="true"><i></i><i class="b"></i></span>
        <span class="asnm-orb o2" aria-hidden="true"><i class="c"></i></span>
        <div class="asnm-logo">AS</div>
      </div>
      <div><div class="asnm-title">ASN Manager</div><div class="asnm-sub" data-i18n="subtitle"></div></div>
    </div>
    <div class="asnm-meta">
      <div class="asnm-meta-top"><a class="asnm-back" href="/index.asp" data-i18n="back_router"></a><span class="asnm-seg-label" data-i18n="lang_label"></span><div class="asnm-seg" id="asnm_lang"></div>
        <span class="asnm-seg-label" style="margin-left:6px;" data-i18n="theme_label"></span><div class="asnm-seg" id="asnm_theme"></div></div>
      <span class="asnm-chip" id="asnm_version">-</span>&nbsp; <span data-i18n="data_refreshed"></span> <span id="asnm_generated">-</span>
      <div class="asnm-upd-line"><span id="asnm_upd_state">-</span><span class="asnm-link" id="asnm_upd_btn" data-i18n="upd_check" onclick="asnmUpdCheck(true);"></span></div></div>
  </div>
  <div id="asnm_banner_update" class="asnm-banner asnm-banner-info"><span id="asnm_upd_text"></span><span class="asnm-spacer"></span>
    <a id="asnm_upd_notes" class="asnm-link" target="_blank" rel="noopener" data-i18n="upd_notes"></a>
    <input type="button" class="button_gen asnm-btn asnm-primary asnm-small-btn" data-i18n-value="upd_install" onclick="asnmUpdate();"/></div>
  <div id="asnm_banner_dns" class="asnm-banner asnm-banner-bad"><span id="asnm_dns_banner_text"></span></div>
  <div id="asnm_banner_rc" class="asnm-banner asnm-banner-bad"><span id="asnm_rc_banner_text"></span><span class="asnm-spacer"></span><span class="asnm-link" data-i18n="rc_to_list" onclick="asnmRcGoto();"></span></div>
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
    <div class="asnm-kv" id="asnm_sched_err" style="display:none;"><span data-i18n="auto_refresh"></span>: <b class="asnm-rc-warn" data-i18n="sched_err"></b></div>
    <div class="asnm-kv" id="asnm_rc_err" style="display:none;"><span data-i18n="rc_title"></span>: <b id="asnm_rc_err_txt"></b>
      <span class="asnm-link" style="margin-left: 8px;" data-i18n="rc_now" onclick="asnmRcCheck();"></span>
      <div id="asnm_rc_err_list" class="asnm-help" style="display:none;"></div></div>
    <div class="asnm-row">
      <input type="button" class="button_gen asnm-btn asnm-primary" data-i18n-value="btn_apply" onclick="asnmApply();"/>
      <input type="button" class="button_gen asnm-btn" data-i18n-value="btn_full" data-i18n-title="btn_full_tip" onclick="asnmApplyFull();"/>
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
  <div class="asnm-tabs" role="tablist">
    <button type="button" class="asnm-tab" id="asnm_tabbtn_asns" role="tab" onclick="asnmTab('asns');"><span data-i18n="tab_asns"></span><span class="asnm-tab-badge" id="asnm_tabbadge_asns"></span></button>
    <button type="button" class="asnm-tab" id="asnm_tabbtn_traffic" role="tab" onclick="asnmTab('traffic');"><span data-i18n="tab_traffic"></span><span class="asnm-tab-badge" id="asnm_tabbadge_traffic"></span></button>
    <button type="button" class="asnm-tab" id="asnm_tabbtn_targets" role="tab" onclick="asnmTab('targets');"><span data-i18n="tab_targets"></span><span class="asnm-tab-badge" id="asnm_tabbadge_targets"></span></button>
    <button type="button" class="asnm-tab" id="asnm_tabbtn_diag" role="tab" onclick="asnmTab('diag');"><span data-i18n="tab_diag"></span></button>
    <button type="button" class="asnm-tab" id="asnm_tabbtn_settings" role="tab" onclick="asnmTab('settings');"><span data-i18n="tab_settings"></span></button>
  </div>
  <div class="asnm-tabpanel" id="asnm_tab_asns" role="tabpanel" style="display:none;">
  <div class="asnm-card">
    <div class="asnm-card-head"><svg class="asnm-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M8 6h13M8 12h13M8 18h13M3 6h.01M3 12h.01M3 18h.01"/></svg><div class="asnm-card-titles"><h3 data-i18n="list_title"></h3><div class="asnm-card-sub" data-i18n="card_list_sub"></div></div><span class="asnm-muted" id="asnm_list_summary" style="font-size:12px;margin-right:6px;"></span><span class="asnm-link" data-i18n="expand_all" onclick="asnmCollapseAll(false);" style="font-size:12px;margin-left:8px;"></span><span class="asnm-link" data-i18n="collapse_all" onclick="asnmCollapseAll(true);" style="font-size:12px;margin-left:10px;"></span></div>
    <div class="asnm-table-wrap"><div id="asnm_list" class="asnm-muted"><div style="padding:14px;">...</div></div></div>
    <div class="asnm-row" style="margin-top:14px;">
      <input type="button" class="button_gen asnm-btn" data-i18n-value="btn_remove_sel" onclick="asnmRemoveSelected();"/>
      <span class="asnm-spacer"></span>
      <input type="button" class="button_gen asnm-btn asnm-ghost asnm-danger-text" data-i18n-value="btn_remove_all" onclick="asnmClearAll();"/>
    </div>
  </div>
  <div class="asnm-card" id="asnm_add_card">
    <div class="asnm-card-head"><svg class="asnm-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="M12 8v8M8 12h8"/></svg><div class="asnm-card-titles"><h3 data-i18n="add_asns"></h3><div class="asnm-card-sub" data-i18n="card_add_sub"></div></div></div>
    <div class="asnm-subtabs" role="tablist">
      <button type="button" class="asnm-subtab" id="asnm_subbtn_manual" onclick="asnmSubTab('manual');" data-i18n="sub_manual"></button>
      <button type="button" class="asnm-subtab" id="asnm_subbtn_lookup" onclick="asnmSubTab('lookup');" data-i18n="sub_lookup"></button>
      <button type="button" class="asnm-subtab" id="asnm_subbtn_presets" onclick="asnmSubTab('presets');" data-i18n="sub_presets"></button>
    </div>
    <div class="asnm-subpanel" id="asnm_sub_manual">
    <div class="asnm-sentence">
      <span class="asnm-sw" data-i18n="add_s1"></span>
      <input type="text" id="asnm_add_asns" maxlength="400" data-i18n-ph="ph_asns" autocomplete="off" oninput="asnmAddHint();" onkeydown="if (event.keyCode === 13) { asnmAdd(); return false; }"/>
      <div class="asnm-s-help asnm-s-formats" data-i18n-html="hint_formats"></div>
      <span class="asnm-help asnm-s-dom" id="asnm_add_domnote" data-i18n="add_domnote" style="display:none;"></span>
      <span class="asnm-sw" data-i18n="add_s2"></span>
      <div class="asnm-s-row"><select id="asnm_add_dest"></select><span class="asnm-sw" data-i18n="add_s3"></span><div class="asnm-ms" id="asnm_add_ms"></div></div>
      <div class="asnm-s-help"><span class="asnm-link" id="asnm_add_srclink" data-i18n="add_src_type" onclick="asnmAddSrcToggle();"></span></div>
      <div class="asnm-s-src" id="asnm_add_srcbox" style="display:none;">
        <input type="text" id="asnm_add_src" maxlength="600" data-i18n-ph="ph_ip" autocomplete="off" oninput="asnmDevMsRender('asnm_add_ms','asnm_add_src');"/>
        <span class="asnm-help" data-i18n="src_empty"></span></div>
      <span class="asnm-sw" data-i18n="note_lbl"></span>
      <div class="asnm-s-row"><input type="text" id="asnm_add_note" maxlength="60" data-i18n-ph="add_note_ph" autocomplete="off" onkeydown="if (event.keyCode === 13) { asnmAdd(); return false; }"/>
        <input type="button" class="button_gen asnm-btn asnm-primary" data-i18n-value="btn_add" onclick="asnmAdd();"/></div>
    </div>
  </div>
    <div class="asnm-subpanel" id="asnm_sub_lookup" style="display:none;">
    <div class="asnm-field"><span class="asnm-label" data-i18n="domain_ip"></span>
      <div class="asnm-inline">
        <input type="text" id="asnm_lookup" maxlength="253" data-i18n-ph="ph_domain" autocomplete="off" onkeydown="if (event.keyCode === 13) { asnmLookup(); return false; }"/>
        <input type="button" class="button_gen asnm-btn asnm-primary" data-i18n-value="btn_lookup" onclick="asnmLookup();"/>
      </div></div>
    <div id="asnm_lookup_result"></div>
  </div>
    <div class="asnm-subpanel" id="asnm_sub_presets" style="display:none;">
    <div class="asnm-form">
      <div class="asnm-field"><span class="asnm-label" data-i18n="preset_cat"></span><select id="asnm_preset_cat" onchange="asnmPresetCat(this.value);"></select></div>
      <div class="asnm-field"><span class="asnm-label" data-i18n="preset"></span><select id="asnm_preset" onchange="asnmPresetShow();"></select></div>
      <div class="asnm-field asnm-full"><div class="asnm-preset-items" id="asnm_preset_items"></div><span class="asnm-help" data-i18n="preset_legend"></span></div>
      <div class="asnm-field"><span class="asnm-label" data-i18n="target"></span><select id="asnm_preset_dest"></select></div>
      <div class="asnm-field"><span class="asnm-label" data-i18n="src_ip"></span>
        <div class="asnm-inline"><input type="text" id="asnm_preset_src" maxlength="600" data-i18n-ph="ph_ip" autocomplete="off" style="flex:1 1 150px; min-width:0;" oninput="asnmDevMsRender('asnm_preset_ms','asnm_preset_src');"/>
          <div class="asnm-ms" id="asnm_preset_ms"></div></div></div>
    </div>
    <div class="asnm-row" style="margin-top:14px;"><input type="button" class="button_gen asnm-btn" data-i18n-value="btn_add_preset" onclick="asnmAddPreset();"/></div>
  </div>
  </div>
  </div>
  <div class="asnm-tabpanel" id="asnm_tab_traffic" role="tabpanel" style="display:none;">
  <div class="asnm-card" id="asnm_tr_card">
    <div class="asnm-card-head asnm-tr-head" id="asnm_tr_head" role="button" tabindex="0" aria-expanded="false" onclick="asnmTrToggle();" onkeydown="asnmTrKey(event);">
      <span class="asnm-tgl" id="asnm_tr_arrow" aria-hidden="true"></span>
      <svg class="asnm-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 3v18h18"/><path d="M7 15l4-4 3 3 5-6"/></svg>
      <div class="asnm-card-titles"><h3 data-i18n="traffic_title"></h3><div class="asnm-card-sub" id="asnm_tr_sub"></div></div>
      <span class="asnm-badge" id="asnm_tr_state"></span>
      <div class="asnm-tr-btns" onclick="event.stopPropagation();">
        <input type="button" id="asnm_tr_btn_disable" class="button_gen asnm-small-btn" data-i18n-value="tr_btn_disable" onclick="asnmTrCmd('disable');"/>
        <input type="button" id="asnm_tr_btn_reset" class="button_gen asnm-small-btn asnm-danger" data-i18n-value="tr_btn_reset" onclick="asnmTrCmd('reset');"/>
        <input type="button" id="asnm_tr_btn_enable" class="button_gen asnm-small-btn asnm-primary" data-i18n-value="tr_btn_enable" onclick="asnmTrCmd('enable');"/>
      </div>
    </div>
    <div class="asnm-tr-bar" id="asnm_tr_bar" role="button" tabindex="0" onclick="asnmTrToggle();" onkeydown="asnmTrKey(event);">
      <span class="asnm-tgl" aria-hidden="true"></span><span id="asnm_tr_bar_text"></span><span class="asnm-tr-sum" id="asnm_tr_bar_sum"></span>
    </div>
    <div id="asnm_tr_body" style="display:none;">
      <div id="asnm_tr_total"></div>
      <div class="asnm-sec">
        <div class="asnm-sec-head" id="asnm_sec_tbl_head" role="button" tabindex="0" aria-expanded="false" onclick="asnmSecToggle('tbl');" onkeydown="asnmSecKey(event, 'tbl');">
          <span class="asnm-tgl" aria-hidden="true"></span><span class="asnm-sec-title" data-i18n="sec_tbl"></span><span class="asnm-tr-cnt" id="asnm_sec_tbl_cnt"></span></div>
        <div class="asnm-sec-body" id="asnm_sec_tbl_body" style="display:none;">
          <div class="asnm-tr-hint"><span class="asnm-tgl" aria-hidden="true"></span><span data-i18n="tr_hint"></span>
            <span class="asnm-link" data-i18n="expand_all" onclick="asnmTrExpandAll(true);"></span>
            <span class="asnm-link" data-i18n="collapse_all" onclick="asnmTrExpandAll(false);"></span></div>
          <div class="asnm-table-wrap"><div id="asnm_tr_table"></div></div>
        </div>
      </div>
      <div class="asnm-sec">
        <div class="asnm-sec-head" id="asnm_sec_sg_head" role="button" tabindex="0" aria-expanded="false" onclick="asnmSecToggle('sg');" onkeydown="asnmSecKey(event, 'sg');">
          <span class="asnm-tgl" aria-hidden="true"></span><span class="asnm-sec-title" data-i18n="sg_title"></span><span class="asnm-tr-cnt" id="asnm_sec_sg_cnt" style="display:none;"></span></div>
        <div class="asnm-sec-body" id="asnm_sec_sg_body" style="display:none;"><div id="asnm_sg"></div></div>
      </div>
      <div class="asnm-tr-note" id="asnm_tr_note"></div>
    </div>
  </div>
  </div>
  <div class="asnm-tabpanel" id="asnm_tab_targets" role="tabpanel" style="display:none;">
  <div class="asnm-card">
    <div class="asnm-card-head"><svg class="asnm-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="3" width="20" height="8" rx="2"/><rect x="2" y="13" width="20" height="8" rx="2"/><path d="M6 7h.01M6 17h.01"/></svg><div class="asnm-card-titles"><h3 data-i18n="ifaces_title"></h3></div><input type="button" id="asnm_pubip_btn" class="button_gen asnm-small-btn asnm-ghost" data-i18n-value="btn_pubip_refresh" onclick="asnmRefreshPubip();"/></div>
    <div class="asnm-table-wrap"><div id="asnm_ifaces"></div></div>
    <div id="asnm_fo" class="asnm-fo"></div>
  </div>
  </div>
  <div class="asnm-tabpanel" id="asnm_tab_diag" role="tabpanel" style="display:none;">
  <div class="asnm-card">
    <div class="asnm-card-head"><svg class="asnm-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14.7 6.3a4 4 0 0 0-5.4 5.4L3 18l3 3 6.3-6.3a4 4 0 0 0 5.4-5.4l-2.5 2.5-2.4-.6-.6-2.4z"/></svg><div class="asnm-card-titles"><h3 data-i18n="diag_title"></h3></div></div>
    <div class="asnm-diag-sys">
      <div class="asnm-kv"><span data-i18n="dns_lbl"></span>: <b id="asnm_dns_state">-</b></div>
      <div class="asnm-kv"><span data-i18n="auto_refresh"></span>: <b id="asnm_schedule_info">-</b></div>
      <div class="asnm-kv"><span data-i18n="rc_title"></span>: <b id="asnm_rc_state">-</b>
        <span class="asnm-link" style="margin-left: 8px;" data-i18n="rc_now" onclick="asnmRcCheck();"></span>
        <div id="asnm_rc_state_list" class="asnm-help" style="display:none;"></div></div>
    </div>
    <div class="asnm-form">
      <div class="asnm-field asnm-full"><span class="asnm-label" data-i18n="domain_ip"></span>
        <div class="asnm-inline">
          <input type="text" id="asnm_diag" maxlength="253" data-i18n-ph="ph_diag" autocomplete="off" onkeydown="if (event.keyCode === 13) { asnmExplain(); return false; }"/>
          <input type="button" class="button_gen asnm-btn asnm-primary" data-i18n-value="btn_explain" onclick="asnmExplain();"/>
          <input type="button" class="button_gen asnm-btn" data-i18n-value="btn_test" onclick="asnmTool('test','asnm_diag');"/>
          <input type="button" class="button_gen asnm-btn" data-i18n-value="btn_trace" onclick="asnmTool('trace','asnm_diag');"/>
        </div><span class="asnm-help" data-i18n="explain_help"></span></div>
      <div class="asnm-field asnm-full"><span class="asnm-label" data-i18n="diag_dev"></span>
        <div class="asnm-inline">
          <select id="asnm_diag_dev" class="input_option asnm-diag-dev"></select>
          <input type="button" class="button_gen asnm-btn" data-i18n-value="btn_device" onclick="asnmDevCheck();"/>
        </div><span class="asnm-help" data-i18n="diag_dev_help"></span></div>
      <div class="asnm-field asnm-full"><span class="asnm-label" data-i18n="router_checks"></span>
        <div class="asnm-row">
          <input type="button" class="button_gen asnm-btn" data-i18n-value="btn_dnschain" onclick="asnmTool('dnschain');"/>
          <input type="button" class="button_gen asnm-btn" data-i18n-value="btn_ipset" onclick="asnmTool('status');"/>
          <input type="button" class="button_gen asnm-btn" data-i18n-value="btn_pubip" onclick="asnmTool('ifaces');"/>
          <input type="button" class="button_gen asnm-btn" data-i18n-value="btn_devices" onclick="asnmTool('devices');"/>
        </div></div>
    </div>
    <pre id="asnm_output" class="asnm-output" data-i18n="output_default"></pre>
  </div>
  <div class="asnm-card" id="asnm_dp_card">
    <div class="asnm-card-head"><svg class="asnm-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 3H7a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V8z"/><path d="M14 3v5h5M9 13h6M9 17h6"/></svg><div class="asnm-card-titles"><h3 data-i18n="dp_title"></h3><div class="asnm-card-sub" data-i18n="dp_sub"></div></div></div>
    <div class="asnm-dp-text" data-i18n="dp_text"></div>
    <div class="asnm-row asnm-dp-row">
      <input type="button" class="button_gen asnm-btn asnm-primary" data-i18n-value="btn_dp" onclick="asnmDiagPack();"/>
      <label class="asnm-dp-full"><input type="checkbox" id="asnm_dp_full"/><span data-i18n="dp_full"></span></label>
      <span id="asnm_dp_links" style="display:none;"><a class="asnm-link" id="asnm_dp_dl" href="#" data-i18n="dp_download"></a> &middot;
        <a class="asnm-link" id="asnm_dp_gh" href="#" target="_blank" rel="noopener" data-i18n="dp_github"></a></span>
    </div>
  </div>
  </div>
  <div class="asnm-tabpanel" id="asnm_tab_settings" role="tabpanel" style="display:none;">
  <div class="asnm-card" id="asnm_display_card">
    <div class="asnm-card-head"><svg class="asnm-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 21v-7M4 10V3M12 21v-9M12 8V3M20 21v-5M20 12V3M1 14h6M9 8h6M17 16h6"/></svg><div class="asnm-card-titles"><h3 data-i18n="disp_title"></h3><div class="asnm-card-sub" data-i18n="disp_sub"></div></div></div>
    <div class="asnm-field"><span class="asnm-label" data-i18n="disp_unit"></span><span class="asnm-help" data-i18n="disp_unit_desc"></span>
      <div class="asnm-row" style="margin-top:8px;"><div class="asnm-seg" id="asnm_unit_seg"><span id="asnm_unit_mbit" onclick="asnmSetUnit('mbit');">Mbit/s</span><span id="asnm_unit_mbyte" onclick="asnmSetUnit('mbyte');">MB/s</span></div></div>
    </div>
  </div>
  <div class="asnm-card" id="asnm_mail_card">
    <div class="asnm-card-head"><svg class="asnm-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="5" width="18" height="14" rx="2"/><path d="M3 7l9 6 9-6"/></svg><div class="asnm-card-titles"><h3 data-i18n="mail_title"></h3><div class="asnm-card-sub" data-i18n="mail_sub"></div></div></div>
    <div class="asnm-field"><span class="asnm-help" data-i18n="mail_desc"></span>
      <div class="asnm-row" style="margin-top:8px;"><div class="asnm-seg"><span id="asnm_mail_off" onclick="asnmMailSet('off');" data-i18n="mail_off"></span><span id="asnm_mail_daily" onclick="asnmMailSet('daily');" data-i18n="mail_daily"></span><span id="asnm_mail_weekly" onclick="asnmMailSet('weekly');" data-i18n="mail_weekly"></span></div>
        <span class="asnm-link" id="asnm_mail_testbtn" style="margin-left:12px;" data-i18n="mail_test" onclick="asnmMailTest();"></span></div>
      <div class="asnm-help" id="asnm_mail_info" style="margin-top:8px;"></div>
    </div>
  </div>
  <div class="asnm-card" id="asnm_perf_card">
    <div class="asnm-card-head"><svg class="asnm-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M13 2L4 14h7l-1 8 9-12h-7z"/></svg><div class="asnm-card-titles"><h3 data-i18n="perf_title"></h3><div class="asnm-card-sub" data-i18n="perf_sub"></div></div></div>
    <div class="asnm-field"><span class="asnm-label" data-i18n="perf_rules"></span><span class="asnm-help" data-i18n="perf_rules_desc"></span>
      <div class="asnm-row" style="margin-top:8px;"><div class="asnm-seg"><span id="asnm_rm_combined" onclick="asnmSetRules('combined');" data-i18n="perf_rules_comb"></span><span id="asnm_rm_single" onclick="asnmSetRules('single');" data-i18n="perf_rules_single"></span></div></div>
    </div>
    <div class="asnm-divider"></div>
    <div class="asnm-field"><span class="asnm-label" data-i18n="perf_stats"></span><span class="asnm-help" data-i18n="perf_stats_desc"></span>
      <div class="asnm-row" style="margin-top:8px;"><div class="asnm-seg"><span id="asnm_sm_asn" onclick="asnmSetStatsMode('asn');" data-i18n="perf_stats_asn"></span><span id="asnm_sm_iface" onclick="asnmSetStatsMode('iface');" data-i18n="perf_stats_iface"></span></div></div>
    </div>
  </div>
  <div class="asnm-card" id="asnm_dnsf_card">
    <div class="asnm-card-head"><svg class="asnm-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3a14 14 0 0 1 0 18M12 3a14 14 0 0 0 0 18"/></svg><div class="asnm-card-titles"><h3 data-i18n="dw_title"></h3><div class="asnm-card-sub" data-i18n="dw_sub"></div></div></div>
    <div class="asnm-help" id="asnm_dw_intro"></div>
    <div class="asnm-dw-row">
      <div class="asnm-dw-txt"><span class="asnm-label" data-i18n="dw_f_title"></span><span class="asnm-help" data-i18n="dw_f_desc"></span></div>
      <div class="asnm-seg"><span id="asnm_dnsf_off" onclick="asnmDnsfSet(0);" data-i18n="dnsf_off"></span><span id="asnm_dnsf_on" onclick="asnmDnsfSet(1);" data-i18n="dnsf_on"></span></div>
    </div>
    <div class="asnm-dw-row" id="asnm_dnsd_wrap" style="display:none;">
      <div class="asnm-dw-txt"><span class="asnm-label" data-i18n="dw_d_title"></span><span class="asnm-help" data-i18n="dw_d_desc"></span></div>
      <div class="asnm-seg"><span id="asnm_dnsd_off" onclick="asnmDnsdSet(0);" data-i18n="dnsf_off"></span><span id="asnm_dnsd_on" onclick="asnmDnsdSet(1);" data-i18n="dnsf_on"></span></div>
    </div>
    <div class="asnm-dw-row" id="asnm_agh_wrap" style="display:none;">
      <div class="asnm-dw-txt"><span class="asnm-label" data-i18n="agh_title"></span><span class="asnm-help" data-i18n="agh_desc"></span>
        <div class="asnm-help" id="asnm_agh_info" style="margin-top:6px;"></div>
        <div class="asnm-dw-ed" style="margin-top:8px;">
          <input type="text" id="asnm_agh_user" maxlength="64" autocomplete="off" autocapitalize="off" spellcheck="false" data-i18n-ph="agh_user"/>
          <input type="password" id="asnm_agh_pass" maxlength="128" autocomplete="new-password" data-i18n-ph="agh_pass" onkeydown="if (event.key === 'Enter') { event.preventDefault(); asnmAghSave(); }"/>
          <input type="button" class="button_gen asnm-btn asnm-primary asnm-small-btn" id="asnm_agh_savebtn" onclick="asnmAghSave();"/>
          <span class="asnm-link" id="asnm_agh_off" style="display:none;" data-i18n="agh_remove" onclick="asnmAghOff();"></span>
        </div></div>
    </div>
    <div class="asnm-dw-row">
      <div class="asnm-dw-txt"><span class="asnm-label" data-i18n="dw_t_title"></span><span class="asnm-help" data-i18n="dw_t_desc"></span></div>
      <div class="asnm-seg"><span id="asnm_dnst_off" onclick="asnmDnstSet(0);" data-i18n="dnsf_off"></span><span id="asnm_dnst_on" onclick="asnmDnstSet(1);" data-i18n="dnsf_on"></span></div>
    </div>
    <div id="asnm_dw_now"></div>
    <details class="asnm-dw-more"><summary data-i18n="dw_more"></summary><ul id="asnm_dw_more_list"></ul></details>
  </div>
  <div class="asnm-grid2">
    <div class="asnm-card">
      <div class="asnm-card-head"><svg class="asnm-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></svg><div class="asnm-card-titles"><h3 data-i18n="schedule_title"></h3></div></div>
      <div class="asnm-form">
        <div class="asnm-field"><span class="asnm-label" data-i18n="refresh_every"></span>
          <div class="asnm-inline"><input type="text" id="asnm_sched_int" class="asnm-w-sm" maxlength="2"/><span class="asnm-muted"><span data-i18n="days"></span> <span data-i18n="days_range"></span></span></div></div>
        <div class="asnm-field"><span class="asnm-label" data-i18n="at_time"></span>
          <input type="text" id="asnm_sched_time" class="asnm-w-md" maxlength="5" placeholder="04:30"/><span class="asnm-help" data-i18n="time_fmt"></span></div>
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
          <input type="button" class="button_gen asnm-btn asnm-primary asnm-small-btn" data-i18n-value="rs_run" onclick="asnmImportRun();"/>
          <input type="button" class="button_gen asnm-ghost asnm-small-btn" data-i18n-value="btn_cancel" onclick="asnmImportCancel();"/>
        </div>
      </div>
      <div class="asnm-divider"></div>
      <div class="asnm-field" id="asnm_own_card"><span class="asnm-label" data-i18n="own_title"></span><span class="asnm-help"><span id="asnm_own_info"></span> <span data-i18n="own_sub"></span></span>
        <input type="file" id="asnm_own_file" accept=".txt,text/plain" style="display:none;" onchange="asnmOwnFile(this);"/>
        <div class="asnm-row" style="margin-top:4px;">
          <input type="button" class="button_gen asnm-btn" data-i18n-value="own_dl" onclick="asnmOwnDownload();"/>
          <input type="button" class="button_gen asnm-btn" data-i18n-value="own_add" data-i18n-title="own_help" onclick="document.getElementById('asnm_own_file').click();"/>
          <label class="asnm-help"><input type="checkbox" id="asnm_own_replace"/> <span data-i18n="own_replace"></span></label>
        </div>
        <div class="asnm-row" style="margin-top:6px;">
          <input type="button" class="button_gen asnm-btn" data-i18n-value="oe_open" onclick="asnmOeToggle();"/>
        </div>
        <div id="asnm_oe" style="display:none;margin-top:10px;">
          <div id="asnm_oe_list"></div>
          <div id="asnm_oe_form" style="display:none;">
            <div class="asnm-oe-grid">
              <label><span class="asnm-label" data-i18n="oe_name"></span><input type="text" id="asnm_oe_name" maxlength="60"/></label>
              <label><span class="asnm-label" data-i18n="preset_cat"></span><select id="asnm_oe_cat"></select></label>
            </div>
            <label><span class="asnm-label" data-i18n="oe_items"></span><span class="asnm-help" data-i18n="oe_items_help"></span>
              <textarea id="asnm_oe_items" class="asnm-oe-ta" rows="5" spellcheck="false" autocapitalize="off" autocomplete="off"></textarea></label>
            <div class="asnm-oe-grid">
              <label id="asnm_oe_file_w"><span class="asnm-label" data-i18n="oe_file"></span><select id="asnm_oe_file"></select></label>
              <label class="asnm-help" style="align-self:end;padding-bottom:8px;display:flex;gap:6px;align-items:center;"><input type="checkbox" id="asnm_oe_wide"/> <span data-i18n="oe_wide"></span></label>
            </div>
            <div class="asnm-row" style="margin-top:8px;">
              <input type="button" class="button_gen asnm-btn asnm-primary asnm-small-btn" data-i18n-value="oe_save" onclick="asnmOeSave();"/>
              <input type="button" class="button_gen asnm-ghost asnm-small-btn" data-i18n-value="btn_cancel" onclick="asnmOeEdit(-2);"/>
            </div>
          </div>
        </div></div>
    </div>
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
