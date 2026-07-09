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
