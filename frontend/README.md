# DairyOps Frontend

Flutter app for dairy farm herd, milk, inventory, and finance management.

## Run Locally

Start the Django backend:

```powershell
Set-Location 'C:/Users/nijjo/Downloads/files/backend'
$env:DEBUG='True'
python manage.py runserver 127.0.0.1:8000
```

Start Flutter:

```powershell
Set-Location 'C:/Users/nijjo/Downloads/files/frontend'
flutter run
```

The default local API URL is:

```text
http://127.0.0.1:8000/api/v1
```

## Offline Phone Mode

The app can also run without a backend. On the first screen, choose:

```text
Use offline on this phone
```

This stores farm records on the device and keeps daily workflows available without internet. Use the online login only when a backend server is available for cloud data.

For a physical Android device during development, pass your computer LAN IP:

```powershell
flutter run --dart-define=API_BASE_URL=http://YOUR-LAN-IP:8000/api/v1
```

## Play Store Release

Use a public HTTPS backend URL:

```powershell
flutter build appbundle --release --dart-define=API_BASE_URL=https://your-domain.com/api/v1
```

Full release instructions are in `PLAY_STORE_RELEASE.md`.
