# Architecture Document

## 1. High-Level Architecture

DairyOps has two operating modes.

Online mode:

```text
Flutter App -> ApiService -> Django REST API -> Database
```

Offline phone mode:

```text
Flutter App -> FarmProvider -> LocalFarmStore -> SharedPreferences
```

The same screens and providers are used for both modes. `FarmProvider` decides whether to call the backend API or the local offline store.

## 2. Frontend Architecture

Important frontend files:

- `frontend/lib/main.dart`: App entry point and provider setup.
- `frontend/lib/providers/auth_provider.dart`: Login, register, offline mode, logout.
- `frontend/lib/providers/farm_provider.dart`: Farm business actions and data loading.
- `frontend/lib/providers/language_provider.dart`: English/Bangla toggle.
- `frontend/lib/services/api_service.dart`: REST API client.
- `frontend/lib/services/local_farm_store.dart`: Offline storage and calculations.
- `frontend/lib/screens/dashboard_screen.dart`: Main dashboard and quick records.
- `frontend/lib/screens/animals_screen.dart`: Animal management and search.
- `frontend/lib/screens/history_screen.dart`: History, search, edit forms, ledger.
- `frontend/lib/screens/personal_money_screen.dart`: Personal money management.
- `frontend/lib/screens/reports_screen.dart`: Reports and summaries.

State flow:

```text
Screen -> Provider method -> ApiService or LocalFarmStore -> Provider reload -> UI refresh
```

## 3. Backend Architecture

Important backend apps:

- `users`: Custom user model and auth/profile APIs.
- `animals`: Animals, milk production, milk rates, milk audit.
- `financial`: Sales, expenses, withdrawals, personal transactions, capital, loans, inventory.
- `dashboard`: Today/monthly/cash-flow/insight/notification/report APIs.
- `dairy_farm_config`: Django settings and URL routing.

Backend API root:

```text
/api/v1/
```

Authentication:

- JWT access and refresh tokens
- Protected endpoints require `Authorization: Bearer <token>`

Ownership model:

- Most records have a `user` foreign key.
- Querysets filter by `request.user`.
- Users should not see another user's farm data.

## 4. Offline Architecture

Offline mode uses `LocalFarmStore`.

Main responsibilities:

- Persist records using SharedPreferences.
- Generate local IDs.
- Load a full snapshot for the app.
- Calculate dashboard, monthly, cash flow, personal money, and stock summaries.
- Preserve records across app restart.
- Export/import backup JSON text.

Offline mode is not currently synced to the backend. Backup/restore is manual.

## 5. Data Flow Examples

### Add Sale

```text
Dashboard/History form
  -> FarmProvider.addSale()
    -> online: ApiService.createSale()
    -> offline: LocalFarmStore.createSale()
  -> FarmProvider.loadAll()
  -> dashboard/history refresh
```

### Take Money To Pocket

```text
User records withdrawal
  -> FamilyWithdrawal is created
  -> PersonalTransaction with farm_transfer is created
  -> Farm cash decreases
  -> Personal balance increases
```

### Record Milk

```text
User selects cow and daily milk
  -> System checks cow + date
  -> Existing same-day record is updated
  -> New record is created only if no same-day record exists
  -> Audit record is kept for create/update/delete
```

## 6. UI Architecture Notes

The app favors:

- Simple action labels over accounting terms
- Phone-first layouts
- Lazy lists/grids for smoother scrolling
- Lightweight dashboard summaries on small phones
- Charts on larger screens
- Search in high-volume areas like animals and history

## 7. Extension Points

Future improvements can add:

- Cloud sync for offline records
- Multi-role farm teams
- Customer ledger screen
- Notification scheduling
- Receipt image upload
- PDF export polish
- Real-time backup

