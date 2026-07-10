# DairyOps Developer Manual

This manual is for developers who will run, maintain, test, release, or extend the DairyOps project.

## 1. Project Overview

DairyOps is a farm operation and transaction management app.

Main parts:

- `frontend/`: Flutter app for Android, web, desktop, and offline phone use.
- `backend/`: Django REST API for online accounts, cloud records, dashboards, and reports.
- `SYSTEM_DESIGN.md`: Product and system design notes.
- `USER_MANUAL.md`: Non-technical usage guide.
- `API_DOCUMENTATION.md`: API reference.

Core domains:

- Animals and herd health
- Milk production
- Sales and customer dues
- Farm expenses
- Personal money
- Owner/investor farm money
- Loans and repayments
- Feed/stock with daily auto-use
- History, search, reports, backup/restore

## 2. Tech Stack

Frontend:

- Flutter
- Dart
- Provider for state management
- SharedPreferences for offline phone storage
- Material 3 UI
- `fl_chart` for larger-screen charts

Backend:

- Python
- Django
- Django REST Framework
- Simple JWT authentication
- SQLite for local development
- PostgreSQL recommended for production

Android:

- Flutter Android project
- Application id: `com.nijjo.dairyops`
- Minimum SDK: API 23
- Target SDK: API 35
- Compile SDK: API 36

## 3. Repository Structure

```text
backend/
  animals/            Animal models, serializers, views
  dashboard/          Dashboard summary API
  financial/          Sales, expenses, withdrawals, stock, loans
  reports/            Reporting APIs
  users/              Auth and user APIs
  manage.py
  requirements.txt

frontend/
  lib/
    models/           Dart data models
    providers/        App state and business actions
    screens/          Flutter screens
    services/         API service and offline store
  android/            Android build project
  test/               Flutter tests
  pubspec.yaml
```

## 4. Local Development Setup

### Backend

From the repo root:

```powershell
cd backend
python -m venv venv
.\venv\Scripts\Activate.ps1
pip install -r requirements.txt
$env:DEBUG='True'
python manage.py migrate
python manage.py runserver 127.0.0.1:8000
```

API base URL:

```text
http://127.0.0.1:8000/api/v1
```

Admin:

```powershell
python manage.py createsuperuser
```

### Frontend

In another terminal:

```powershell
cd frontend
flutter pub get
flutter run
```

For Chrome:

```powershell
flutter run -d chrome
```

For a physical Android phone on the same Wi-Fi network, use the computer LAN IP:

```powershell
flutter run --dart-define=API_BASE_URL=http://YOUR-LAN-IP:8000/api/v1
```

Do not use `127.0.0.1` for a physical phone because that points to the phone itself, not your computer.

## 5. Offline Phone Architecture

The app supports offline mode without the backend.

Important files:

- `frontend/lib/providers/auth_provider.dart`
- `frontend/lib/providers/farm_provider.dart`
- `frontend/lib/services/local_farm_store.dart`

Offline data is stored on the phone using SharedPreferences.

Offline token:

```text
offline-phone-mode
```

When this token is active, `FarmProvider` routes actions to `LocalFarmStore` instead of the REST API.

Offline features include:

- Animals
- Milk production
- Same-day milk update instead of double-counting
- Sales and customer dues
- Farm expenses
- Farm-to-pocket withdrawals
- Personal money
- Owner/investor farm money
- Loans
- Feed/stock
- Daily stock auto-use
- Backup/restore

## 6. Backend Development

Run tests:

```powershell
cd backend
$env:DEBUG='False'
python manage.py test
```

Create migrations after model changes:

```powershell
cd backend
$env:DEBUG='False'
python manage.py makemigrations
python manage.py migrate
```

Check migrations:

```powershell
python manage.py showmigrations
```

Do not commit:

- `backend/.env`
- `backend/db.sqlite3`
- local media files
- private keys

## 7. Frontend Development

Analyze code:

```powershell
cd frontend
flutter analyze
```

Run tests:

```powershell
flutter test
```

Run app:

```powershell
flutter run
```

Build web:

```powershell
flutter build web --no-wasm-dry-run
```

Build Android APK:

```powershell
flutter build apk --release
```

APK output:

```text
frontend/build/app/outputs/flutter-apk/app-release.apk
```

Build Android App Bundle for Play Store:

```powershell
flutter build appbundle --release --dart-define=API_BASE_URL=https://your-domain.com/api/v1
```

AAB output:

```text
frontend/build/app/outputs/bundle/release/app-release.aab
```

## 8. Release Checklist

Before release:

1. Update `version` in `frontend/pubspec.yaml`.
2. Run backend tests.
3. Run Flutter analyze.
4. Run Flutter tests.
5. Build release APK for manual testing.
6. Build AAB for Play Store.
7. Test offline mode on a real phone.
8. Test online mode with the production API URL.
9. Check login, register, add animal, milk, sale, expense, personal money, stock, history search, backup/restore.
10. Push final code to GitHub.

Commands:

```powershell
cd backend
$env:DEBUG='False'
python manage.py test

cd ../frontend
flutter analyze
flutter test
flutter build apk --release
flutter build appbundle --release --dart-define=API_BASE_URL=https://your-domain.com/api/v1
```

## 9. Android Signing

For Play Store release, create an upload keystore once:

```powershell
cd frontend
keytool -genkey -v -keystore android/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Copy key properties template:

```powershell
Copy-Item android/key.properties.example android/key.properties
```

Edit `frontend/android/key.properties`:

```properties
storePassword=your-keystore-password
keyPassword=your-key-password
keyAlias=upload
storeFile=../upload-keystore.jks
```

Never commit:

- `frontend/android/key.properties`
- `frontend/android/upload-keystore.jks`

## 10. API Configuration

Flutter reads the API URL from `API_BASE_URL`.

Development default:

```text
http://127.0.0.1:8000/api/v1
```

Production build:

```powershell
flutter build appbundle --release --dart-define=API_BASE_URL=https://your-domain.com/api/v1
```

The production API must be HTTPS for Play Store quality and real phone use.

## 11. Data Rules Developers Must Preserve

Milk:

- One milk record per cow per day.
- If the user records milk again for the same cow and day, update the old value.
- Deleted milk records require a reason and should be auditable.

Sales:

- `total_amount` is the full bill.
- `paid_amount` is what the customer paid.
- `due_amount` is calculated as bill minus paid.
- Existing sales should not become unpaid after migrations.

Farm and personal money:

- Farm expenses reduce farm cash.
- Farm-to-pocket withdrawals reduce farm cash and add personal income.
- Personal expenses reduce personal money only.
- Owner/investor farm money increases farm cash but is not a sale.

Feed/stock:

- Stock can have daily usage.
- Auto-deduct must not make stock negative.
- Users can manually add or reduce stock when needed.

## 12. Common Troubleshooting

Backend says token invalid:

- Log out and log in again.
- In offline mode, use **Use offline on this phone**.

Phone cannot connect to backend:

- Do not use `127.0.0.1` on a physical phone.
- Use your computer LAN IP or a hosted HTTPS backend.
- Check Windows Firewall.

Flutter cannot find Android SDK:

```powershell
flutter doctor -v
flutter config --android-sdk C:\Users\YOUR-USER\AppData\Local\Android\Sdk
flutter doctor --android-licenses
```

APK size looks large:

- Flutter APK includes Flutter engine and native runtime.
- Play Store AAB delivery is usually smaller for users because Google splits by device.

## 13. Git Workflow

Check status:

```powershell
git status --short
```

Commit:

```powershell
git add .
git commit -m "Describe change"
```

Push:

```powershell
git push origin main
```

Avoid committing generated build output unless intentionally publishing artifacts through GitHub Releases.

## 14. Documentation To Keep Updated

Update these files when behavior changes:

- `README.md`
- `USER_MANUAL.md`
- `DEVELOPER_MANUAL.md`
- `SYSTEM_DESIGN.md`
- `API_DOCUMENTATION.md`
- `frontend/PLAY_STORE_RELEASE.md`
- `frontend/PLAY_STORE_LISTING_DRAFT.md`

