# Security And Privacy Document

## 1. Data Types

DairyOps can store:

- User account information
- Farm name and owner details
- Animal records
- Milk production records
- Sales and customer due records
- Farm expenses
- Personal money records
- Loans
- Feed/stock data
- Offline backup text

## 2. Security Principles

- Online records must be scoped to the authenticated user.
- Production API must use HTTPS.
- Passwords must be handled by Django authentication, never stored manually in plain text.
- JWT tokens must not be logged.
- Secrets and keystores must not be committed.
- Offline backups should be treated as private data.

## 3. Files That Must Not Be Committed

- `backend/.env`
- `backend/db.sqlite3`
- `frontend/android/key.properties`
- `frontend/android/upload-keystore.jks`
- generated build folders
- private logs containing user data

## 4. Offline Mode Privacy

Offline mode stores records on the user's phone. The app does not upload offline records unless future sync is implemented.

Risks:

- Data can be lost if the phone is reset.
- Anyone with phone access may see records.
- Backup text contains farm data and must be stored safely.

Recommended user guidance:

- Use phone lock.
- Copy backups regularly.
- Store backups in a trusted private place.
- Do not share backup text publicly.

## 5. Play Store Data Safety Notes

When publishing, disclose any collected data honestly.

Likely data categories:

- Account info if online login is used
- Financial info because farm and personal money records are stored
- User-generated farm records
- App diagnostics only if analytics/crash tools are added later

If the app is offline-only and no analytics are added, disclose that data stays on device.

## 6. Production Checklist

- `DEBUG=False`
- Strong `SECRET_KEY`
- HTTPS enabled
- Restricted `ALLOWED_HOSTS`
- Correct CORS origins
- Database backups enabled
- Admin account protected with strong password
- Keystore stored securely
- Privacy policy published before Play Store release

