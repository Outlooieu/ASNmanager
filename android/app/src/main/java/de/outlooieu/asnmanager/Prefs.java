package de.outlooieu.asnmanager;

import android.content.Context;
import android.content.SharedPreferences;

import androidx.security.crypto.EncryptedSharedPreferences;
import androidx.security.crypto.MasterKeys;

/** Router address, sign-in and the found ASN Manager page; stored encrypted (Android Keystore). */
final class Prefs {
    static final String URL = "url", USER = "user", PASS = "pass", PAGE = "page", CERT = "cert", LOGOUT = "logout";

    static SharedPreferences get(Context c) {
        try {
            String key = MasterKeys.getOrCreate(MasterKeys.AES256_GCM_SPEC);
            return EncryptedSharedPreferences.create("asnm_secure", key, c,
                    EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
                    EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM);
        } catch (Exception e) {
            // keystore not usable on this device: fall back to private app storage
            return c.getSharedPreferences("asnm_plain", Context.MODE_PRIVATE);
        }
    }

    static boolean configured(Context c) {
        SharedPreferences p = get(c);
        return !p.getString(URL, "").isEmpty() && !p.getString(USER, "").isEmpty() && !p.getString(PASS, "").isEmpty();
    }

    /** "http://192.168.1.1/" -> "http://192.168.1.1" */
    static String base(Context c) {
        String u = get(c).getString(URL, "").trim();
        while (u.endsWith("/")) u = u.substring(0, u.length() - 1);
        return u;
    }

    private Prefs() {}
}
