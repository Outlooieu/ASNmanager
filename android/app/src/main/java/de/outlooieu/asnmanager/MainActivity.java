package de.outlooieu.asnmanager;

import android.annotation.SuppressLint;
import android.content.ContentValues;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.Uri;
import android.net.http.SslCertificate;
import android.net.http.SslError;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.provider.MediaStore;
import android.util.Base64;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.webkit.CookieManager;
import android.webkit.JavascriptInterface;
import android.webkit.SslErrorHandler;
import android.webkit.ValueCallback;
import android.webkit.WebChromeClient;
import android.webkit.WebResourceError;
import android.webkit.WebResourceRequest;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Button;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import androidx.activity.OnBackPressedCallback;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;

import org.json.JSONObject;

import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStream;
import java.security.MessageDigest;
import java.security.cert.Certificate;
import java.security.cert.CertificateFactory;
import java.io.ByteArrayInputStream;

/**
 * Shows the ASN Manager page of the router (the same WebUI as in the browser) and signs in by itself:
 * Main_Login.asp -> a form to /login.cgi (same origin, like the login page does) -> the ASN Manager page
 * (userN.asp, found once by looking for its root element and remembered). A sign-out by the router
 * (session timeout, PC signs in) is answered with a new sign-in.
 */
public class MainActivity extends AppCompatActivity {
    private static final int LOGIN = 1, SUBMITTED = 2, SEARCH = 3, READY = 4, LOGOUT = 5;
    private WebView web;
    private View status;
    private TextView statusText;
    private ProgressBar progress;
    private Button retry;
    private int phase = 0, loginTries = 0;
    private long lastLogin = 0;
    private boolean closing = false;
    private ValueCallback<Uri[]> fileCb;

    private final ActivityResultLauncher<Intent> setup = registerForActivityResult(
            new ActivityResultContracts.StartActivityForResult(), r -> {
                if (Prefs.configured(this)) connect(); else finish();
            });
    private final ActivityResultLauncher<Intent> pick = registerForActivityResult(
            new ActivityResultContracts.StartActivityForResult(), r -> {
                Uri[] res = null;
                if (r.getResultCode() == RESULT_OK && r.getData() != null && r.getData().getData() != null) res = new Uri[]{ r.getData().getData() };
                if (fileCb != null) fileCb.onReceiveValue(res);
                fileCb = null;
            });

    @SuppressLint("SetJavaScriptEnabled")
    @Override
    protected void onCreate(Bundle b) {
        super.onCreate(b);
        setContentView(R.layout.activity_main);
        web = findViewById(R.id.web);
        status = findViewById(R.id.status);
        statusText = findViewById(R.id.status_text);
        progress = findViewById(R.id.progress);
        retry = findViewById(R.id.retry);
        retry.setOnClickListener(v -> connect());

        WebSettings s = web.getSettings();
        s.setJavaScriptEnabled(true);
        s.setDomStorageEnabled(true);           // theme, unit, language of the page
        s.setLoadWithOverviewMode(true);
        s.setUseWideViewPort(true);
        s.setBuiltInZoomControls(true);
        s.setDisplayZoomControls(false);
        CookieManager.getInstance().setAcceptCookie(true);
        web.addJavascriptInterface(new Bridge(), "AsnmApp");
        web.setWebViewClient(new Client());
        web.setWebChromeClient(new WebChromeClient() {
            @Override
            public boolean onShowFileChooser(WebView w, ValueCallback<Uri[]> cb, FileChooserParams p) {
                if (fileCb != null) fileCb.onReceiveValue(null);
                fileCb = cb;
                Intent i = new Intent(Intent.ACTION_GET_CONTENT).addCategory(Intent.CATEGORY_OPENABLE).setType("*/*");
                pick.launch(Intent.createChooser(i, null));
                return true;
            }
        });

        getOnBackPressedDispatcher().addCallback(this, new OnBackPressedCallback(true) {
            @Override public void handleOnBackPressed() {
                if (phase == READY && web.canGoBack() && web.getUrl() != null && !web.getUrl().contains(Prefs.get(MainActivity.this).getString(Prefs.PAGE, "#"))) { web.goBack(); return; }
                leave();
            }
        });

        if (Prefs.configured(this)) connect(); else setup.launch(new Intent(this, SetupActivity.class));
    }

    @Override
    public boolean onCreateOptionsMenu(Menu m) { getMenuInflater().inflate(R.menu.main, m); return true; }

    @Override
    public boolean onOptionsItemSelected(MenuItem i) {
        int id = i.getItemId();
        if (id == R.id.m_reload) { if (phase == READY) web.reload(); else connect(); return true; }
        if (id == R.id.m_settings) { setup.launch(new Intent(this, SetupActivity.class)); return true; }
        if (id == R.id.m_logout) { logout(false); return true; }
        if (id == R.id.m_browser) {
            String page = Prefs.get(this).getString(Prefs.PAGE, "");
            startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse(Prefs.base(this) + "/" + page)));
            return true;
        }
        return super.onOptionsItemSelected(i);
    }

    // ---------- sign-in ----------
    private void show(int text, boolean busy) {
        status.setVisibility(View.VISIBLE);
        statusText.setText(text);
        progress.setVisibility(busy ? View.VISIBLE : View.GONE);
        retry.setVisibility(busy ? View.GONE : View.VISIBLE);
    }

    private void connect() {
        loginTries = 0;
        login();
    }

    private void login() {
        phase = LOGIN; lastLogin = System.currentTimeMillis();
        show(R.string.st_login, true);
        web.loadUrl(Prefs.base(this) + "/Main_Login.asp");
    }

    /** the same form the login page sends (same origin, so the router sees its own page as referrer) */
    private void submitLogin() {
        SharedPreferences p = Prefs.get(this);
        String next = p.getString(Prefs.PAGE, "");
        if (next.isEmpty()) next = "index.asp";
        String js = "(function(){var u=" + JSONObject.quote(p.getString(Prefs.USER, "")) + ",w=" + JSONObject.quote(p.getString(Prefs.PASS, "")) + ";"
                + "var f=document.createElement('form');f.method='post';f.action='/login.cgi';"
                + "var v={group_id:'',action_mode:'',action_script:'',action_wait:'5',current_page:'Main_Login.asp',next_page:" + JSONObject.quote(next) + ","
                + "login_authorization:btoa(unescape(encodeURIComponent(u+':'+w)))};"
                + "for(var k in v){var i=document.createElement('input');i.type='hidden';i.name=k;i.value=v[k];f.appendChild(i);}"
                + "document.body.appendChild(f);f.submit();})();";
        phase = SUBMITTED;
        web.evaluateJavascript(js, null);
    }

    /** the ASN Manager page is one of the add-on pages user1.asp ... user20.asp */
    private void searchPage() {
        phase = SEARCH;
        show(R.string.st_search, true);
        web.evaluateJavascript("(async function(){for(var i=1;i<=20;i++){try{var r=await fetch('/user'+i+'.asp',{credentials:'same-origin'});"
                + "if(r.ok){var t=await r.text();if(t.indexOf('id=\"asnm\"')>=0){AsnmApp.found(i);return;}}}catch(e){}}AsnmApp.found(0);})();", null);
    }

    private void logout(boolean thenFinish) {
        closing = thenFinish;
        phase = LOGOUT;
        web.loadUrl(Prefs.base(this) + "/Logout.asp");
        if (!thenFinish) show(R.string.menu_logout, false);
    }

    private void leave() {
        if (Prefs.get(this).getBoolean(Prefs.LOGOUT, true) && phase == READY) logout(true); else finish();
    }

    private boolean ours(Uri u) {
        Uri b = Uri.parse(Prefs.base(this));
        return u != null && u.getHost() != null && u.getHost().equalsIgnoreCase(b.getHost());
    }

    private class Client extends WebViewClient {
        @Override
        public boolean shouldOverrideUrlLoading(WebView v, WebResourceRequest r) {
            Uri u = r.getUrl();
            if (ours(u) || "blob".equals(u.getScheme()) || "data".equals(u.getScheme())) return false;
            try { startActivity(new Intent(Intent.ACTION_VIEW, u)); } catch (Exception e) { /* no app for it */ }
            return true;                                            // changelog, GitHub ... in the browser
        }

        @Override
        public void onPageFinished(WebView v, String url) {
            if (phase == LOGOUT) { if (closing) finish(); return; }
            boolean loginPage = url.contains("Main_Login.asp") || url.contains("login.cgi");
            String page = Prefs.get(MainActivity.this).getString(Prefs.PAGE, "");
            if (phase == LOGIN) {
                if (loginPage) { submitLogin(); return; }
                phase = SUBMITTED;                                  // still signed in: the router went on by itself
            }
            if (phase == SUBMITTED) {
                if (loginPage) {
                    if (++loginTries < 2) { login(); return; }
                    show(R.string.st_loginfail, false); phase = 0; return;
                }
                if (page.isEmpty()) { searchPage(); return; }
                phase = READY;
                if (!url.contains("/" + page)) { v.loadUrl(Prefs.base(MainActivity.this) + "/" + page); return; }
            }
            if (phase == READY) {
                if (loginPage) {                                    // signed out by the router
                    if (System.currentTimeMillis() - lastLogin > 20000) { loginTries = 0; login(); }
                    else show(R.string.st_loginfail, false);
                    return;
                }
                // downloads of the page (backup, presets, diagnostic bundle) are blob links: hand them to the app
                v.evaluateJavascript("(function(){if(window.__asnmDl)return;window.__asnmDl=1;var oc=HTMLAnchorElement.prototype.click;"
                        + "HTMLAnchorElement.prototype.click=function(){if(this.download&&/^(blob:|data:)/.test(this.href)){var n=this.download;"
                        + "fetch(this.href).then(function(r){return r.blob();}).then(function(b){var fr=new FileReader();fr.onload=function(){"
                        + "AsnmApp.save(n,b.type||'text/plain',String(fr.result).split(',')[1]);};fr.readAsDataURL(b);});return;}"
                        + "return oc.apply(this,arguments);};})();", null);
                if (url.endsWith("/" + page) || url.contains("/" + page + "?")) {
                    v.evaluateJavascript("document.getElementById('asnm')?1:0", r -> {
                        if ("0".equals(r)) { Prefs.get(MainActivity.this).edit().remove(Prefs.PAGE).apply(); searchPage(); }   // page number changed
                        else status.setVisibility(View.GONE);
                    });
                } else status.setVisibility(View.GONE);
            }
        }

        @Override
        public void onReceivedError(WebView v, WebResourceRequest r, WebResourceError e) {
            if (r.isForMainFrame() && phase != LOGOUT) {
                statusText.post(() -> {
                    show(R.string.st_login, false);
                    statusText.setText(getString(R.string.st_neterr, String.valueOf(e.getDescription())));
                });
            }
        }

        /** the router has its own certificate: trust it once (shown with its fingerprint), warn if it changes */
        @Override
        public void onReceivedSslError(WebView v, SslErrorHandler h, SslError err) {
            if (!ours(Uri.parse(err.getUrl()))) { h.cancel(); return; }
            String fp = fingerprint(err.getCertificate());
            String known = Prefs.get(MainActivity.this).getString(Prefs.CERT, "");
            if (fp != null && fp.equals(known)) { h.proceed(); return; }
            new AlertDialog.Builder(MainActivity.this)
                    .setTitle(R.string.cert_title)
                    .setMessage(getString(known.isEmpty() ? R.string.cert_new : R.string.cert_changed, fp == null ? "?" : fp))
                    .setCancelable(false)
                    .setPositiveButton(R.string.cert_trust, (d, w) -> {
                        if (fp != null) Prefs.get(MainActivity.this).edit().putString(Prefs.CERT, fp).apply();
                        h.proceed();
                    })
                    .setNegativeButton(R.string.cancel, (d, w) -> { h.cancel(); show(R.string.st_loginfail, false); })
                    .show();
        }
    }

    private static String fingerprint(SslCertificate c) {
        try {
            byte[] der;
            if (Build.VERSION.SDK_INT >= 29 && c.getX509Certificate() != null) der = c.getX509Certificate().getEncoded();
            else {
                byte[] raw = SslCertificate.saveState(c).getByteArray("x509-certificate");
                Certificate x = CertificateFactory.getInstance("X.509").generateCertificate(new ByteArrayInputStream(raw));
                der = x.getEncoded();
            }
            byte[] d = MessageDigest.getInstance("SHA-256").digest(der);
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < d.length; i++) { if (i > 0) sb.append(i % 8 == 0 ? "\n" : ":"); sb.append(String.format("%02X", d[i])); }
            return sb.toString();
        } catch (Exception e) {
            return null;
        }
    }

    private class Bridge {
        @JavascriptInterface
        public void found(int n) {
            runOnUiThread(() -> {
                if (n <= 0) { phase = 0; show(R.string.st_notfound, false); return; }
                String page = "user" + n + ".asp";
                Prefs.get(MainActivity.this).edit().putString(Prefs.PAGE, page).apply();
                phase = READY;
                web.loadUrl(Prefs.base(MainActivity.this) + "/" + page);
            });
        }

        /** a download of the page: saved in Downloads */
        @JavascriptInterface
        public void save(String name, String mime, String b64) {
            String n = name == null || name.isEmpty() ? "asnmanager.txt" : name.replaceAll("[\\\\/:*?\"<>|]", "_");
            try {
                byte[] data = Base64.decode(b64, Base64.DEFAULT);
                if (Build.VERSION.SDK_INT >= 29) {
                    ContentValues cv = new ContentValues();
                    cv.put(MediaStore.Downloads.DISPLAY_NAME, n);
                    cv.put(MediaStore.Downloads.MIME_TYPE, mime == null || mime.isEmpty() ? "text/plain" : mime.split(";")[0]);
                    Uri u = getContentResolver().insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, cv);
                    try (OutputStream o = getContentResolver().openOutputStream(u)) { o.write(data); }
                } else {
                    File dir = getExternalFilesDir(Environment.DIRECTORY_DOWNLOADS);
                    try (FileOutputStream o = new FileOutputStream(new File(dir, n))) { o.write(data); }
                }
                runOnUiThread(() -> Toast.makeText(MainActivity.this, getString(R.string.saved, n), Toast.LENGTH_LONG).show());
            } catch (Exception e) {
                runOnUiThread(() -> Toast.makeText(MainActivity.this, String.valueOf(e.getMessage()), Toast.LENGTH_LONG).show());
            }
        }
    }
}
