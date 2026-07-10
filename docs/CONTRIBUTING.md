# Contributing Guide

## 1. Before You Start

Read:

- `README.md`
- `USER_MANUAL.md`
- `DEVELOPER_MANUAL.md`
- `docs/SOFTWARE_REQUIREMENTS_SPECIFICATION.md`
- `docs/ARCHITECTURE.md`

## 2. Development Rules

- Keep UI labels simple for non-technical farm users.
- Keep farm money and personal money separate.
- Do not break offline phone mode.
- Do not double-count same-day milk records.
- Do not commit secrets or generated build output.
- Add or update tests when changing business logic.
- Update documentation when behavior changes.

## 3. Branch And Commit Style

Use clear commit messages:

```text
Add customer due report
Fix same-day milk update
Improve mobile history search
```

## 4. Required Checks Before Commit

Backend changes:

```powershell
cd backend
$env:DEBUG='False'
python manage.py test
```

Frontend changes:

```powershell
cd frontend
flutter analyze
flutter test
```

Android release-related changes:

```powershell
cd frontend
flutter build apk --release
```

## 5. Pull Request Checklist

- Feature or fix is explained.
- Screenshots added for UI changes where useful.
- Tests pass.
- Offline mode checked if farm records changed.
- Backend migrations included if models changed.
- Docs updated if behavior changed.
- No secrets committed.

## 6. Code Style

Flutter:

- Use existing Provider pattern.
- Keep widgets readable and phone-friendly.
- Prefer lazy lists/grids for long content.
- Avoid heavy charts on small phone screens.

Django:

- Keep user-owned querysets filtered by `request.user`.
- Use serializers for API validation.
- Use migrations for model changes.
- Keep financial calculations explicit and tested.

