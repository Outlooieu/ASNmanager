package de.outlooieu.asnmanager;

import android.app.Activity;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

public class SetupActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle b) {
        super.onCreate(b);
        setContentView(R.layout.activity_setup);
        SharedPreferences p = Prefs.get(this);
        EditText url = findViewById(R.id.url), user = findViewById(R.id.user), pass = findViewById(R.id.pass);
        CheckBox logout = findViewById(R.id.logout);
        if (!p.getString(Prefs.URL, "").isEmpty()) url.setText(p.getString(Prefs.URL, ""));
        user.setText(p.getString(Prefs.USER, ""));
        pass.setText(p.getString(Prefs.PASS, ""));
        logout.setChecked(p.getBoolean(Prefs.LOGOUT, true));

        Button save = findViewById(R.id.save);
        save.setOnClickListener(v -> {
            String u = url.getText().toString().trim(), n = user.getText().toString().trim(), w = pass.getText().toString();
            if (u.isEmpty() || n.isEmpty() || w.isEmpty()) { Toast.makeText(this, R.string.setup_need, Toast.LENGTH_LONG).show(); return; }
            if (!u.startsWith("http://") && !u.startsWith("https://")) { Toast.makeText(this, R.string.setup_bad_url, Toast.LENGTH_LONG).show(); return; }
            SharedPreferences.Editor e = p.edit();
            if (!u.equals(p.getString(Prefs.URL, ""))) { e.remove(Prefs.PAGE); e.remove(Prefs.CERT); }   // another router
            e.putString(Prefs.URL, u).putString(Prefs.USER, n).putString(Prefs.PASS, w).putBoolean(Prefs.LOGOUT, logout.isChecked()).apply();
            setResult(Activity.RESULT_OK);
            finish();
        });
        findViewById(R.id.forget).setOnClickListener(v -> {
            p.edit().remove(Prefs.CERT).apply();
            Toast.makeText(this, "OK", Toast.LENGTH_SHORT).show();
        });
    }
}
