param(
    [Parameter(Mandatory = $true)]
    [string] $ApiBaseUrl
)

$ErrorActionPreference = "Stop"

if (-not $env:ANDROID_HOME -and -not $env:ANDROID_SDK_ROOT) {
    throw "Android SDK is not configured. Install Android Studio, then run: flutter config --android-sdk <SDK_PATH>"
}

if (-not (Test-Path "android/key.properties")) {
    throw "Missing android/key.properties. Copy android/key.properties.example and fill in your upload keystore passwords."
}

if ($ApiBaseUrl -notmatch "^https://") {
    throw "Play Store release builds must use a public HTTPS API URL."
}

flutter clean
flutter pub get
flutter analyze
flutter test
flutter build appbundle --release --dart-define="API_BASE_URL=$ApiBaseUrl"

Write-Host "Ready to upload: build/app/outputs/bundle/release/app-release.aab"
