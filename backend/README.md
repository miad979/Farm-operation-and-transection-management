# Dairy Farm Management Backend (Django + DRF)

This is a working backend for the farm management system described in your docs.

## Features Implemented

- JWT authentication (`register`, `login`, `refresh`, `profile`)
- Animal management
- Milk production tracking and reports
- Sales, expenses, withdrawals, loans, and inventory management
- Dashboard endpoints (`today`, `monthly`, `insights`, `cash-flow`)

## Quick Start

1. Create and activate virtual environment

### Windows PowerShell

```powershell
E:/python.exe -m venv venv
.\venv\Scripts\Activate.ps1
```

2. Install dependencies

```powershell
E:/python.exe -m pip install -r requirements.txt
```

3. Copy env file

```powershell
Copy-Item .env.example .env
```

4. Run migrations and create admin

```powershell
E:/python.exe manage.py makemigrations users animals financial dashboard
E:/python.exe manage.py migrate
E:/python.exe manage.py createsuperuser
```

5. Start server

```powershell
E:/python.exe manage.py runserver
```

Base API URL: `http://127.0.0.1:8000/api/v1`

## Main API Paths

- `/api/v1/auth/register/`
- `/api/v1/auth/login/`
- `/api/v1/auth/refresh/`
- `/api/v1/auth/profile/`
- `/api/v1/animals/`
- `/api/v1/milk-production/`
- `/api/v1/sales/`
- `/api/v1/expenses/`
- `/api/v1/withdrawals/`
- `/api/v1/loans/`
- `/api/v1/inventory/`
- `/api/v1/dashboard/today/`
- `/api/v1/dashboard/monthly/`
- `/api/v1/dashboard/insights/`
- `/api/v1/dashboard/cash-flow/`
