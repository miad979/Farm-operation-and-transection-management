# DairyOps Play Store Release Guide

## Current Android Setup

- App name: `DairyOps`
- Android application id: `com.nijjo.dairyops`
- Compile SDK: API 36
- Target SDK: Android 15 / API 35
- Minimum SDK: API 23
- Release output: Android App Bundle (`.aab`)

Google Play requires new apps and updates to target Android 15 / API 35 or higher. New apps must also use Play App Signing.

## Production Backend

The app must talk to a public HTTPS backend in production. Do not publish with `127.0.0.1`, `localhost`, or a LAN IP.

Build with your hosted API URL:

```powershell
flutter build appbundle --release --dart-define=API_BASE_URL=https://your-domain.com/api/v1
```

## Create Upload Keystore

Run once and keep the generated files private:

```powershell
keytool -genkey -v -keystore android/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Copy the template:

```powershell
Copy-Item android/key.properties.example android/key.properties
```

Then edit `android/key.properties` with the passwords you used:

```properties
storePassword=your-keystore-password
keyPassword=your-key-password
keyAlias=upload
storeFile=../upload-keystore.jks
```

Do not share or commit `android/key.properties` or `android/upload-keystore.jks`.

## Version Updates

Before every Play Store upload, increase `version` in `pubspec.yaml`:

```yaml
version: 1.0.1+2
```

The part before `+` is the user-visible version. The number after `+` must increase for every upload.

## Build And Verify

Install Android Studio first if this command fails with `No Android SDK found`. After installing, open Android Studio once, install the Android SDK, then run:

```powershell
flutter doctor -v
flutter config --android-sdk C:\Users\YOUR-USER\AppData\Local\Android\Sdk
flutter doctor --android-licenses
```

```powershell
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build appbundle --release --dart-define=API_BASE_URL=https://your-domain.com/api/v1
```

Upload this file in Play Console:

```text
build/app/outputs/bundle/release/app-release.aab
```

## Play Console Items

Prepare these before production release:

- App icon, feature graphic, screenshots for phone and tablet.
- Short description and full description.
- Privacy policy URL.
- Data Safety form for login/account data, farm records, financial records, and diagnostics if enabled.
- App category: Business or Productivity.
- Content rating questionnaire.
- Closed testing track before production.
