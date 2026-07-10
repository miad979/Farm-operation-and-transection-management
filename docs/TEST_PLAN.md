# Test Plan

## 1. Purpose

This document defines how DairyOps should be tested before development commits, APK builds, and Play Store releases.

## 2. Test Levels

### Backend Unit/API Tests

Command:

```powershell
cd backend
$env:DEBUG='False'
python manage.py test
```

Must cover:

- Auth and protected APIs
- Animal creation/update
- Milk record create/update/delete with audit
- Sales and customer dues
- Expenses
- Farm-to-pocket withdrawals
- Personal transactions
- Capital contributions
- Loans and payments
- Inventory auto-use
- Dashboard/report calculations

### Flutter Static Analysis

Command:

```powershell
cd frontend
flutter analyze
```

Must pass with no issues before release.

### Flutter Tests

Command:

```powershell
cd frontend
flutter test
```

Must cover:

- Login screen loads without token
- Offline data persists after restart
- Farm-to-pocket transfer rules
- Customer due and backup restore
- Normal cow milk auto-production
- Same-day milk update instead of double-counting
- Milk delete with reason

## 3. Manual Smoke Test

Run on a real Android phone before release.

Offline mode:

1. Open app.
2. Tap **Use offline on this phone**.
3. Add animal.
4. Set normal daily milk.
5. Check dashboard milk total.
6. Change same-day milk production.
7. Confirm milk does not double-count.
8. Add milk sale with partial payment.
9. Confirm customer due appears.
10. Add farm expense.
11. Take money to pocket.
12. Add personal expense.
13. Add feed stock with daily use.
14. Open history and search by amount/name/date.
15. Copy backup.
16. Close app and reopen.
17. Confirm data remains.

Online mode:

1. Start backend or use hosted API.
2. Register user.
3. Login.
4. Add animal.
5. Add milk, sale, expense, stock.
6. Refresh dashboard.
7. Confirm records are visible after logout/login.

## 4. Regression Test Checklist

Run this after touching core business logic:

- Milk record same cow/date updates instead of duplicate.
- Sale due = bill amount minus paid amount.
- Cattle sale marks animal inactive.
- Farm expense reduces farm cash.
- Farm-to-pocket transfer increases personal balance.
- Personal expense does not reduce farm cash again.
- Capital contribution increases farm cash.
- Inventory daily use reduces stock.
- Backup export can restore records.
- Search works in Animals and History.

## 5. Build Verification

APK:

```powershell
cd frontend
flutter build apk --release
```

AAB:

```powershell
flutter build appbundle --release --dart-define=API_BASE_URL=https://your-domain.com/api/v1
```

Verify:

- APK installs on Android.
- App starts without blank screen.
- Offline mode works without internet.
- Production build does not point to localhost.

## 6. Exit Criteria

A release is ready when:

- Backend tests pass.
- Flutter analyze passes.
- Flutter tests pass.
- APK/AAB builds successfully.
- Real phone smoke test passes.
- Version number is increased.
- Release notes are updated.

