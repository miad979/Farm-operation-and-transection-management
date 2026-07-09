# Farm Operation and Transaction Management

A cross-platform dairy farm management system built with Flutter, Django REST Framework, and JWT authentication. The app is designed for daily farm operators who need simple control over animals, milk production, farm cash flow, personal money, feed stock, loans, and warnings from one clean workspace.

## What It Does

- Manage animals, health status, vaccination, pregnancy, and notes
- Record daily milk production by animal
- Track farm sales, business expenses, cow sales, and monthly profit
- Separate farm cash flow from personal money management
- Move money from farm to personal pocket and track personal expenses
- Add investor or owner capital contributions
- Manage feed and stock with automatic daily usage reduction
- Monitor loans, repayments, low stock, vaccination, pregnancy, and health warnings
- View dashboard summaries, history, reports, and Bangla-friendly UI labels
- Build for Android, web, and other Flutter-supported platforms

## Tech Stack

- Frontend: Flutter, Dart, Material 3
- Backend: Django, Django REST Framework
- Authentication: JWT
- Database: SQLite for local development, PostgreSQL recommended for production
- API: REST endpoints under `/api/v1`

## Project Structure

```text
backend/    Django REST API, database models, auth, dashboard, reports
frontend/   Flutter app for mobile, web, and desktop targets
docs        System design, API docs, roadmap, setup guides
```

## Run Locally

Start the backend:

```powershell
cd backend
python -m venv venv
.\venv\Scripts\Activate.ps1
pip install -r requirements.txt
Copy-Item .env.example .env
python manage.py migrate
python manage.py runserver 127.0.0.1:8000
```

Start the frontend:

```powershell
cd frontend
flutter pub get
flutter run
```

For a physical Android device, use your computer LAN IP:

```powershell
flutter run --dart-define=API_BASE_URL=http://YOUR-LAN-IP:8000/api/v1
```

## Testing

Backend:

```powershell
cd backend
$env:DEBUG='False'
python manage.py test
```

Frontend:

```powershell
cd frontend
flutter analyze
flutter test
```

Web build:

```powershell
cd frontend
flutter build web --no-wasm-dry-run
```

## Play Store Build

Use a deployed HTTPS backend URL for release builds:

```powershell
cd frontend
flutter build appbundle --release --dart-define=API_BASE_URL=https://your-domain.com/api/v1
```

See `frontend/PLAY_STORE_RELEASE.md` for Android signing and publishing notes.

## Security Notes

Do not commit private local files such as:

- `backend/.env`
- `backend/db.sqlite3`
- Android keystore files
- `frontend/android/key.properties`
- Build folders and local logs

The repository `.gitignore` is configured to keep these files out of GitHub.

## License

This project is licensed under the MIT License.

Copyright (c) 2026 Md Miadul Islam Nizzan
