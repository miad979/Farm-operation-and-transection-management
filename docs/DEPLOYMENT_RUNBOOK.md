# Deployment Runbook

## 1. Purpose

This runbook explains how to deploy and release DairyOps.

## 2. Backend Deployment

Production backend requirements:

- HTTPS domain
- Python runtime
- PostgreSQL database
- Environment variables
- Static/media handling
- CORS configured for frontend domains

Required environment variables:

```env
SECRET_KEY=change-me
DEBUG=False
ALLOWED_HOSTS=your-domain.com
DB_ENGINE=django.db.backends.postgresql
DB_NAME=dairyops
DB_USER=dairyops_user
DB_PASSWORD=secure-password
DB_HOST=your-db-host
DB_PORT=5432
CORS_ALLOWED_ORIGINS=https://your-frontend-domain.com
```

Deployment steps:

```powershell
cd backend
pip install -r requirements.txt
$env:DEBUG='False'
python manage.py migrate
python manage.py collectstatic --noinput
```

Start with a production WSGI/ASGI server such as Gunicorn/Uvicorn behind Nginx or the hosting provider's runtime.

Health checks:

- `/admin/` loads.
- `/api/v1/auth/login/` responds.
- Authenticated dashboard endpoint responds.

## 3. Frontend Web Deployment

Build:

```powershell
cd frontend
flutter build web --no-wasm-dry-run --dart-define=API_BASE_URL=https://your-domain.com/api/v1
```

Deploy contents of:

```text
frontend/build/web
```

## 4. Android APK Build

APK is useful for direct testing.

```powershell
cd frontend
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

Output:

```text
frontend/build/app/outputs/flutter-apk/app-release.apk
```

## 5. Play Store AAB Build

Before building:

- Confirm `frontend/pubspec.yaml` version increased.
- Confirm API URL is HTTPS.
- Confirm Android signing is configured.

Build:

```powershell
cd frontend
flutter build appbundle --release --dart-define=API_BASE_URL=https://your-domain.com/api/v1
```

Output:

```text
frontend/build/app/outputs/bundle/release/app-release.aab
```

Upload the AAB to Google Play Console.

## 6. Android Signing

Generate once:

```powershell
cd frontend
keytool -genkey -v -keystore android/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Create `frontend/android/key.properties`:

```properties
storePassword=your-keystore-password
keyPassword=your-key-password
keyAlias=upload
storeFile=../upload-keystore.jks
```

Never commit:

- `android/upload-keystore.jks`
- `android/key.properties`

## 7. Rollback

Backend rollback:

1. Restore previous code version.
2. Restore database backup if migration changed data incorrectly.
3. Restart service.
4. Verify login and dashboard.

Android rollback:

1. Use Play Console release management.
2. Halt rollout if needed.
3. Publish a fixed version with higher build number.

## 8. Post-Deployment Checks

- Register/login works.
- Offline mode still works.
- Dashboard loads.
- Add animal works.
- Add milk works.
- Add sale with partial payment works.
- History search works.
- Backup/restore works offline.
- No localhost API URL in release app.

