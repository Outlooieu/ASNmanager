# ASN Manager - Android app

A small app that opens the ASN Manager WebUI of your router and signs in for you - the same page as in the browser, so every new feature of the WebUI is in the app as well.

- Enter the router address once (e.g. `http://192.168.1.1` or `https://192.168.1.1:8443`), user name and password. They are stored encrypted on the phone only (Android Keystore).
- The app finds the ASN Manager page by itself (it is one of the add-on pages `user1.asp` ... `user20.asp`) and signs in again when the router signed you out.
- HTTPS with the router's own certificate: shown once with its SHA-256 fingerprint to trust; the app warns if it ever changes.
- Downloads of the page (backup, own presets, diagnostic bundle) are saved in *Downloads*; restore and "Add presets" open the file picker.
- The router allows one administrator at a time: by default the app signs out when you leave it (back button), so your PC can sign in again. Menu: Reload, Open in browser, Sign out, Router settings.
- From outside your home only through a VPN (e.g. the WireGuard server of the router). Do not open the router page to the internet.

## Install

Download `ASNManager-<version>.apk` from the [releases](https://github.com/Outlooieu/ASNmanager/releases) and open it on the phone (allow installing apps from this source). Android 8 or newer.

## Build

GitHub Actions builds it (`.github/workflows/android-app.yml`): every change in `android/` builds an APK (workflow artifact), a tag `app-v1.2.3` makes a release. With the repository secrets `KEYSTORE_B64`, `KEYSTORE_PASSWORD` and `KEY_ALIAS` the APK is signed with the same key every time (updates install over the old version); without them it is a debug build.
