# VS Code Setup & Development Workflow - Dairy Farm Management System

## Step 1: VS Code Extensions Installation

Open VS Code and install these extensions:

### Backend Development (Python/Django)
1. **Python** - ms-python.python
2. **Pylance** - ms-python.vscode-pylance
3. **Python Debugger** - ms-python.debugpy
4. **Django** - batisteo.vscode-django
5. **PostgreSQL** - cweijan.vscode-postgresql
6. **SQLTools** - mtxr.sqltools
7. **REST Client** - humao.rest-client

### Frontend Development (Flutter)
8. **Dart** - Dart-Code.dart-code
9. **Flutter** - Dart-Code.flutter

### General Development
10. **Git Graph** - mhutchie.git-graph
11. **Thunder Client** - rangav.vscode-thunder-client (or Postman)
12. **Prettier** - esbenp.prettier-vscode
13. **Better Comments** - aaron-bond.better-comments
14. **Markdown Preview** - shd101wyy.markdown-preview-enhanced

---

## Step 2: Project Setup - Backend (Django)

### 2.1 Create Project Folder
```bash
# Create project directory
mkdir dairy_farm_system
cd dairy_farm_system

# Create backend folder
mkdir backend
cd backend
```

### 2.2 Create Virtual Environment
```bash
# On Windows
python -m venv venv
venv\Scripts\activate

# On macOS/Linux
python -m venv venv
source venv/bin/activate
```

### 2.3 Create requirements.txt
Create file `backend/requirements.txt`:

```txt
Django==4.2.7
djangorestframework==3.14.0
djangorestframework-simplejwt==5.3.2
django-cors-headers==4.3.1
psycopg2-binary==2.9.9
python-decouple==3.8
python-dotenv==1.0.0
Pillow==10.1.0
drf-spectacular==0.26.5
```

### 2.4 Install Dependencies
```bash
pip install -r requirements.txt
```

### 2.5 Create Django Project
```bash
django-admin startproject dairy_farm_config .
```

Your structure should look like:
```
backend/
├── venv/
├── dairy_farm_config/
│   ├── __init__.py
│   ├── settings.py
│   ├── urls.py
│   ├── asgi.py
│   └── wsgi.py
├── requirements.txt
└── manage.py
```

### 2.6 Create Django Apps
```bash
python manage.py startapp users
python manage.py startapp animals
python manage.py startapp financial
```

### 2.7 Create .env File
Create `backend/.env`:

```env
# Database
DB_ENGINE=django.db.backends.postgresql
DB_NAME=dairy_farm_db
DB_USER=postgres
DB_PASSWORD=your_postgres_password
DB_HOST=localhost
DB_PORT=5432

# Django
SECRET_KEY=django-insecure-your-secret-key-change-this-in-production
DEBUG=True
ALLOWED_HOSTS=localhost,127.0.0.1,192.168.1.100

# JWT
JWT_ALGORITHM=HS256
JWT_EXPIRATION_HOURS=1

# Email
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_HOST_USER=your_email@gmail.com
EMAIL_HOST_PASSWORD=your_app_password

# CORS
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://192.168.1.100:8000
```

### 2.8 Update settings.py

Open `dairy_farm_config/settings.py` and update:

```python
import os
from pathlib import Path
from decouple import config
from datetime import timedelta

BASE_DIR = Path(__file__).resolve().parent.parent

SECRET_KEY = config('SECRET_KEY', default='django-insecure-change-me')

DEBUG = config('DEBUG', default=True, cast=bool)

ALLOWED_HOSTS = config('ALLOWED_HOSTS', default='localhost,127.0.0.1').split(',')

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    
    # Third party apps
    'rest_framework',
    'rest_framework_simplejwt',
    'corsheaders',
    'drf_spectacular',
    
    # Local apps
    'users.apps.UsersConfig',
    'animals.apps.AnimalsConfig',
    'financial.apps.FinancialConfig',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'corsheaders.middleware.CorsMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'dairy_farm_config.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [BASE_DIR / 'templates'],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'dairy_farm_config.wsgi.application'

DATABASES = {
    'default': {
        'ENGINE': config('DB_ENGINE'),
        'NAME': config('DB_NAME'),
        'USER': config('DB_USER'),
        'PASSWORD': config('DB_PASSWORD'),
        'HOST': config('DB_HOST'),
        'PORT': config('DB_PORT'),
    }
}

AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator'},
    {'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator'},
    {'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator'},
    {'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator'},
]

LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'UTC'
USE_I18N = True
USE_TZ = True

STATIC_URL = '/static/'
STATIC_ROOT = BASE_DIR / 'staticfiles'
MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / 'media'

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# REST Framework Configuration
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ),
    'DEFAULT_PERMISSION_CLASSES': (
        'rest_framework.permissions.IsAuthenticated',
    ),
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 20,
    'DEFAULT_FILTER_BACKENDS': (
        'rest_framework.filters.SearchFilter',
        'rest_framework.filters.OrderingFilter',
    ),
    'DEFAULT_SCHEMA_CLASS': 'drf_spectacular.openapi.AutoSchema',
}

# JWT Configuration
SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(hours=1),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=30),
    'ALGORITHM': 'HS256',
    'SIGNING_KEY': SECRET_KEY,
}

# CORS Configuration
CORS_ALLOWED_ORIGINS = config('CORS_ALLOWED_ORIGINS', default='http://localhost:3000').split(',')
CORS_ALLOW_CREDENTIALS = True

# Email Configuration
EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
EMAIL_HOST = config('EMAIL_HOST', default='smtp.gmail.com')
EMAIL_PORT = config('EMAIL_PORT', default=587, cast=int)
EMAIL_USE_TLS = True
EMAIL_HOST_USER = config('EMAIL_HOST_USER', default='')
EMAIL_HOST_PASSWORD = config('EMAIL_HOST_PASSWORD', default='')
```

### 2.9 Update urls.py

Edit `dairy_farm_config/urls.py`:

```python
from django.contrib import admin
from django.urls import path, include
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView

urlpatterns = [
    path('admin/', admin.site.urls),
    
    # API Documentation
    path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
    path('api/docs/', SpectacularSwaggerView.as_view(url_name='schema')),
    
    # API v1
    path('api/v1/', include('api.urls')),
]
```

### 2.10 Create API URLs

Create `backend/api/urls.py`:

```python
from django.urls import path, include
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

urlpatterns = [
    # Authentication
    path('auth/login/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('auth/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    
    # Apps
    path('users/', include('users.urls')),
    path('animals/', include('animals.urls')),
    path('financial/', include('financial.urls')),
]
```

---

## Step 3: Database Setup

### 3.1 Create PostgreSQL Database

Open terminal and connect to PostgreSQL:

```bash
# Windows/macOS/Linux
psql -U postgres

# Inside psql shell
CREATE DATABASE dairy_farm_db;
CREATE USER dairy_user WITH PASSWORD 'dairy_password_123';
ALTER ROLE dairy_user SET client_encoding TO 'utf8';
ALTER ROLE dairy_user SET default_transaction_isolation TO 'read committed';
ALTER ROLE dairy_user SET timezone TO 'UTC';
GRANT ALL PRIVILEGES ON DATABASE dairy_farm_db TO dairy_user;
\q
```

### 3.2 Run Migrations

```bash
cd backend
python manage.py makemigrations
python manage.py migrate
```

### 3.3 Create Superuser

```bash
python manage.py createsuperuser
# Follow prompts
```

### 3.4 Verify Database

In VS Code, open Terminal → Python:

```bash
python manage.py dbshell
\dt  # List tables
\q   # Exit
```

---

## Step 4: Create First Model (Animals)

### 4.1 Create Animal Model

Edit `animals/models.py`:

```python
from django.db import models
from django.contrib.auth.models import User

class Animal(models.Model):
    TYPE_CHOICES = [
        ('Cow', 'Cow'),
        ('Ox', 'Ox'),
        ('Buffalo', 'Buffalo'),
        ('Calf', 'Calf'),
        ('Heifer', 'Heifer'),
        ('Bull', 'Bull'),
    ]
    
    HEALTH_CHOICES = [
        ('Healthy', 'Healthy'),
        ('Sick', 'Sick'),
        ('Treatment', 'Treatment'),
        ('Pregnant', 'Pregnant'),
    ]
    
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='animals')
    animal_id_number = models.CharField(max_length=50, unique=True)
    name = models.CharField(max_length=100)
    type = models.CharField(max_length=20, choices=TYPE_CHOICES)
    breed = models.CharField(max_length=100)
    gender = models.CharField(max_length=10)
    purchase_date = models.DateField()
    purchase_price = models.DecimalField(max_digits=10, decimal_places=2)
    current_value = models.DecimalField(max_digits=10, decimal_places=2)
    health_status = models.CharField(max_length=50, choices=HEALTH_CHOICES, default='Healthy')
    vaccinated = models.BooleanField(default=False)
    vaccination_date = models.DateField(null=True, blank=True)
    last_vaccination_type = models.CharField(max_length=100, null=True, blank=True)
    pregnancy_status = models.CharField(max_length=50, default='Not Pregnant')
    expected_delivery_date = models.DateField(null=True, blank=True)
    notes = models.TextField(null=True, blank=True)
    image_url = models.URLField(null=True, blank=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['-created_at']
        verbose_name_plural = 'Animals'
    
    def __str__(self):
        return f"{self.name} ({self.type})"
```

### 4.2 Create Serializer

Create `animals/serializers.py`:

```python
from rest_framework import serializers
from .models import Animal

class AnimalSerializer(serializers.ModelSerializer):
    class Meta:
        model = Animal
        fields = '__all__'
        read_only_fields = ['created_at', 'updated_at']
```

### 4.3 Create ViewSet

Edit `animals/views.py`:

```python
from rest_framework import viewsets, permissions
from rest_framework.decorators import action
from rest_framework.response import Response
from .models import Animal
from .serializers import AnimalSerializer

class AnimalViewSet(viewsets.ModelViewSet):
    serializer_class = AnimalSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        return Animal.objects.filter(user=self.request.user)
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)
    
    @action(detail=True, methods=['post'])
    def vaccinate(self, request, pk=None):
        animal = self.get_object()
        animal.vaccinated = True
        animal.vaccination_date = request.data.get('vaccination_date')
        animal.last_vaccination_type = request.data.get('vaccination_type')
        animal.save()
        return Response({'status': 'Vaccination recorded'})
```

### 4.4 Register URLs

Create `animals/urls.py`:

```python
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import AnimalViewSet

router = DefaultRouter()
router.register(r'', AnimalViewSet, basename='animal')

urlpatterns = [
    path('', include(router.urls)),
]
```

### 4.5 Run Migrations Again

```bash
python manage.py makemigrations
python manage.py migrate
```

---

## Step 5: Test Backend with REST Client in VS Code

### 5.1 Create API Test File

Create `backend/test_api.rest`:

```rest
### Variables
@baseUrl = http://localhost:8000/api/v1
@token = your_access_token_here

### 1. Get Admin Token
POST http://localhost:8000/api/token/
Content-Type: application/json

{
  "username": "admin",
  "password": "admin_password"
}

### 2. Get All Animals
GET {{baseUrl}}/animals/
Authorization: Bearer {{token}}

### 3. Create Animal
POST {{baseUrl}}/animals/
Authorization: Bearer {{token}}
Content-Type: application/json

{
  "animal_id_number": "LF001",
  "name": "Lakshmi",
  "type": "Cow",
  "breed": "Holstein",
  "gender": "Female",
  "purchase_date": "2023-01-15",
  "purchase_price": 45000.00,
  "current_value": 48000.00,
  "health_status": "Healthy",
  "vaccinated": false,
  "notes": "High milk producer"
}

### 4. Get Animal Detail
GET {{baseUrl}}/animals/1/
Authorization: Bearer {{token}}

### 5. Update Animal
PUT {{baseUrl}}/animals/1/
Authorization: Bearer {{token}}
Content-Type: application/json

{
  "health_status": "Healthy",
  "notes": "Updated notes"
}
```

### 5.2 Use REST Client

1. Click "Send Request" above any endpoint
2. View response in side panel
3. Copy token from login response
4. Update `@token` variable
5. Test other endpoints

---

## Step 6: Start Development Server

### 6.1 Run Server
```bash
python manage.py runserver
```

Server runs at: `http://localhost:8000`
Admin at: `http://localhost:8000/admin`
API Docs: `http://localhost:8000/api/docs/`

### 6.2 Keep Terminal Open
Leave one terminal running the server. Open another terminal for other commands.

---

## Step 7: Frontend Setup (Flutter)

### 7.1 Create Flutter Project

```bash
cd ..  # Go to dairy_farm_system directory
flutter create frontend
cd frontend
```

### 7.2 Update pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.0
  http: ^1.1.0
  dio: ^5.0.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  intl: ^0.18.0
  image_picker: ^0.8.7
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  json_serializable: ^6.5.0
  build_runner: ^2.3.0
```

### 7.3 Get Dependencies

```bash
flutter pub get
```

### 7.4 Update API Config

Create `lib/config/api_config.dart`:

```dart
class ApiConfig {
  // Use your local IP, not localhost
  static const String baseUrl = 'http://192.168.1.100:8000/api/v1';
  
  static const String login = '/auth/login/';
  static const String register = '/auth/register/';
  static const String animals = '/animals/';
}
```

### 7.5 Test Flutter App

```bash
flutter run
```

---

## Step 8: VS Code Workspace Setup

### 8.1 Create Workspace File

Create `dairy_farm.code-workspace`:

```json
{
  "folders": [
    {
      "path": "backend",
      "name": "Django Backend"
    },
    {
      "path": "frontend",
      "name": "Flutter Frontend"
    }
  ],
  "settings": {
    "python.linting.enabled": true,
    "python.linting.pylintEnabled": true,
    "python.formatting.provider": "black",
    "python.defaultInterpreterPath": "${workspaceFolder:Django Backend}/venv/bin/python",
    "[python]": {
      "editor.formatOnSave": true,
      "editor.defaultFormatter": "ms-python.python"
    },
    "[dart]": {
      "editor.formatOnSave": true
    }
  }
}
```

### 8.2 Open Workspace

In VS Code: File → Open Workspace from File → Select `dairy_farm.code-workspace`

Now you can work on both backend and frontend in one workspace!

---

## Step 9: Debug Configuration

### 9.1 Python Debugging

Create `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Django",
      "type": "python",
      "request": "launch",
      "program": "${workspaceFolder:Django Backend}/manage.py",
      "args": ["runserver"],
      "django": true,
      "jinja": true,
      "console": "integratedTerminal"
    }
  ]
}
```

Now you can debug by pressing F5!

---

## Step 10: Development Workflow

### Terminal 1: Backend
```bash
cd backend
source venv/bin/activate  # Windows: venv\Scripts\activate
python manage.py runserver
```

### Terminal 2: Flutter
```bash
cd frontend
flutter run
```

### Terminal 3: Database/Git/Admin
```bash
# Run any additional commands here
```

---

## Quick Reference Commands

### Backend (Django)
```bash
# Create app
python manage.py startapp app_name

# Make migrations
python manage.py makemigrations

# Apply migrations
python manage.py migrate

# Create superuser
python manage.py createsuperuser

# Run tests
python manage.py test

# Run server
python manage.py runserver

# Access shell
python manage.py shell
```

### Frontend (Flutter)
```bash
# Get dependencies
flutter pub get

# Run app
flutter run

# Clean build
flutter clean

# Generate code
flutter pub run build_runner build

# Build APK
flutter build apk --release
```

### Database (PostgreSQL)
```bash
# Connect to database
psql -U postgres

# Inside psql:
\l              # List databases
\c dairy_farm_db  # Connect to database
\dt             # List tables
\q              # Quit
```

---

## Useful VS Code Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl + ~` | Toggle terminal |
| `Ctrl + K + W` | Close all tabs |
| `Ctrl + Shift + P` | Command palette |
| `Ctrl + F` | Find |
| `Ctrl + H` | Find & Replace |
| `F5` | Debug |
| `Shift + F10` | Run (Flutter) |
| `Alt + Up/Down` | Move line |
| `Ctrl + D` | Select word |
| `Ctrl + ,` | Settings |

---

## File Structure After Setup

```
dairy_farm_system/
├── backend/
│   ├── venv/
│   ├── dairy_farm_config/
│   │   ├── settings.py
│   │   ├── urls.py
│   │   ├── asgi.py
│   │   └── wsgi.py
│   ├── animals/
│   │   ├── models.py
│   │   ├── serializers.py
│   │   ├── views.py
│   │   └── urls.py
│   ├── financial/
│   ├── users/
│   ├── .env
│   ├── requirements.txt
│   ├── manage.py
│   └── test_api.rest
├── frontend/
│   ├── lib/
│   │   ├── config/
│   │   ├── screens/
│   │   ├── models/
│   │   ├── providers/
│   │   ├── services/
│   │   ├── widgets/
│   │   └── main.dart
│   ├── pubspec.yaml
│   └── pubspec.lock
├── .vscode/
│   └── launch.json
└── dairy_farm.code-workspace
```

---

## Troubleshooting

### Python not found
```bash
# Check installation
python --version

# Or use python3
python3 --version
```

### PostgreSQL connection error
```bash
# Make sure PostgreSQL is running
# Windows: Check Services app
# macOS: brew services start postgresql
# Linux: sudo systemctl start postgresql

# Test connection
psql -U postgres
```

### Django migrations failed
```bash
# Reset (development only!)
python manage.py migrate zero
python manage.py makemigrations
python manage.py migrate
```

### Flutter run fails
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

### Port already in use
```bash
# Run on different port
python manage.py runserver 8001
```

---

## Next Steps

1. ✅ Install VS Code extensions
2. ✅ Set up backend (Django)
3. ✅ Create database (PostgreSQL)
4. ✅ Create first model (Animal)
5. ✅ Test API with REST Client
6. ✅ Set up frontend (Flutter)
7. 📝 **NEXT**: Create more models (Milk, Sales, Expenses)
8. 📝 Create remaining views and serializers
9. 📝 Build Flutter UI screens
10. 📝 Connect Flutter to Django API
11. 📝 Test complete flow
12. 📝 Deploy to production

---

## Resources

- [Django Documentation](https://docs.djangoproject.com/)
- [Django REST Framework](https://www.django-rest-framework.org/)
- [Flutter Documentation](https://flutter.dev/docs)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [VS Code Python Extension](https://marketplace.visualstudio.com/items?itemName=ms-python.python)
- [VS Code Flutter Extension](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter)

---

**You're ready to start coding! Open VS Code and begin with the Backend setup above.**
