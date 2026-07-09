# Dairy Farm Management System - Quick Start Guide

## Prerequisites

Before you begin, ensure you have the following installed:

### For Backend Development
- Python 3.10 or higher
- PostgreSQL 12 or higher
- pip (Python package manager)
- Git

### For Frontend Development
- Flutter SDK 3.0 or higher
- Android SDK (for Android development)
- Xcode (for iOS development, macOS only)
- VS Code or Android Studio

### Tools
- Postman or Insomnia (for API testing)
- DBeaver or pgAdmin (for database management)

---

## Backend Setup (Django REST API)

### 1. Clone Repository
```bash
git clone <repository-url>
cd dairy_farm_backend
```

### 2. Create Virtual Environment
```bash
python -m venv venv

# On Windows
venv\Scripts\activate

# On macOS/Linux
source venv/bin/activate
```

### 3. Install Dependencies
```bash
pip install -r requirements.txt
```

### 4. Set Up Environment Variables
Create a `.env` file in the project root:

```env
# Database
DB_ENGINE=django.db.backends.postgresql
DB_NAME=dairy_farm_db
DB_USER=postgres
DB_PASSWORD=your_password
DB_HOST=localhost
DB_PORT=5432

# Django
SECRET_KEY=your-secret-key-here
DEBUG=True
ALLOWED_HOSTS=localhost,127.0.0.1,192.168.1.100

# JWT
JWT_SECRET=your-jwt-secret
JWT_ALGORITHM=HS256

# AWS S3 (optional for image storage)
AWS_ACCESS_KEY_ID=your_key
AWS_SECRET_ACCESS_KEY=your_secret
AWS_STORAGE_BUCKET_NAME=dairy-farm-bucket
AWS_S3_REGION_NAME=us-east-1

# Email Configuration
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_HOST_USER=your_email@gmail.com
EMAIL_HOST_PASSWORD=your_app_password

# CORS
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://192.168.1.100:8000
```

### 5. Create PostgreSQL Database
```bash
# Connect to PostgreSQL
psql -U postgres

# Create database
CREATE DATABASE dairy_farm_db;
CREATE USER dairy_user WITH PASSWORD 'secure_password';
ALTER ROLE dairy_user SET client_encoding TO 'utf8';
ALTER ROLE dairy_user SET default_transaction_isolation TO 'read committed';
ALTER ROLE dairy_user SET default_transaction_deferrable TO on;
ALTER ROLE dairy_user SET timezone TO 'UTC';
GRANT ALL PRIVILEGES ON DATABASE dairy_farm_db TO dairy_user;
\q
```

### 6. Run Migrations
```bash
python manage.py makemigrations
python manage.py migrate
python manage.py migrate --run-syncdb
```

### 7. Create Superuser
```bash
python manage.py createsuperuser
# Follow prompts to create admin user
```

### 8. Collect Static Files
```bash
python manage.py collectstatic --noinput
```

### 9. Start Development Server
```bash
python manage.py runserver 0.0.0.0:8000
```

The API will be available at: `http://localhost:8000/api/v1`

### 10. Access Admin Panel
Navigate to: `http://localhost:8000/admin`

---

## Frontend Setup (Flutter)

### 1. Clone Repository
```bash
git clone <repository-url>
cd dairy_farm_app
```

### 2. Get Flutter Dependencies
```bash
flutter pub get
```

### 3. Configure API URL
Edit `lib/config/api_config.dart`:

```dart
class ApiConfig {
  static const String baseUrl = 'http://192.168.1.100:8000/api/v1';
  // ... rest of config
}
```

> **Note**: Use your actual local IP address instead of localhost for testing on physical devices.

### 4. Generate Model Files
```bash
flutter pub run build_runner build
```

### 5. Run on Android Emulator
```bash
# Start emulator first
emulator -avd Pixel_5_API_30 &

# Run app
flutter run -d emulator-5554
```

### 6. Run on Physical Android Device
```bash
# Enable USB debugging on device
adb devices  # Verify device is connected

flutter run
```

### 7. Run on iOS Simulator
```bash
# macOS only
flutter run -d iPhone
```

### 8. Run on Physical iOS Device
```bash
# Requires Apple Developer account
# Configure signing in Xcode first
cd ios
pod install
cd ..
flutter run -d "iPhone Name"
```

---

## Database Schema

### Quick Database Setup

```bash
# From backend directory
python manage.py makemigrations users
python manage.py makemigrations animals
python manage.py makemigrations milk_production
python manage.py makemigrations sales
python manage.py makemigrations expenses
python manage.py makemigrations withdrawals
python manage.py makemigrations loans
python manage.py makemigrations inventory
python manage.py migrate
```

---

## Testing the Application

### API Testing with Postman

1. **Import Postman Collection**
   - Import `postman_collection.json` in Postman
   - Set environment variables for base URL and tokens

2. **Test Authentication**
   ```
   POST /api/v1/auth/register/
   {
     "username": "testuser",
     "email": "test@example.com",
     "password": "testpass123",
     "farm_name": "Test Farm"
   }
   ```

3. **Get Access Token**
   ```
   POST /api/v1/auth/login/
   {
     "username": "testuser",
     "password": "testpass123"
   }
   ```

### Flutter Widget Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit_test.dart

# Generate coverage report
flutter test --coverage
```

---

## Development Workflow

### Backend Development

1. **Create Django App** (if needed)
   ```bash
   python manage.py startapp new_feature
   ```

2. **Create Models**
   - Edit `models.py`
   - Run migrations: `python manage.py makemigrations`
   - Apply: `python manage.py migrate`

3. **Create Serializers**
   - Create in `serializers.py`
   - Validate input data

4. **Create Views/ViewSets**
   - Use DRF ModelViewSet for CRUD operations
   - Implement custom filters and pagination

5. **Register URLs**
   - Add to `urls.py`
   - Use DefaultRouter for automatic URL generation

6. **Test with Postman**
   - Test all endpoints
   - Verify error handling
   - Check response format

### Frontend Development

1. **Create New Screen**
   ```bash
   # Create screen file
   lib/presentation/screens/new_feature/new_feature_screen.dart
   ```

2. **Create Models** (if needed)
   ```bash
   # Create model with JSON serialization
   lib/data/models/new_feature_model.dart
   ```

3. **Add API Service Methods**
   - Update `api_service.dart`
   - Add new API calls

4. **Create Provider**
   ```bash
   # State management
   lib/presentation/providers/new_feature_provider.dart
   ```

5. **Build UI**
   - Create widgets
   - Use MetricCard, AppButton, AppTextField
   - Handle loading and error states

6. **Test Widget**
   ```bash
   flutter test test/widget_test.dart
   ```

---

## Environment Variables Reference

### Django Settings
```python
# settings.py structure
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'rest_framework',
    'rest_framework_simplejwt',
    'corsheaders',
    'animals',
    'financial',
]

REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ),
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 20,
}

SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(hours=1),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=30),
}
```

---

## Common Issues & Solutions

### Django Issues

**Issue**: ModuleNotFoundError: No module named 'django'
```bash
# Solution: Install dependencies
pip install -r requirements.txt
```

**Issue**: PostgreSQL connection failed
```bash
# Solution: Check PostgreSQL is running
# Windows: services.msc
# macOS: brew services start postgresql
# Linux: sudo systemctl start postgresql
```

**Issue**: Migration conflicts
```bash
# Solution: Reset migrations (development only)
python manage.py migrate zero
rm -rf */migrations/0*.py
python manage.py makemigrations
python manage.py migrate
```

### Flutter Issues

**Issue**: No devices found
```bash
# Solution: List connected devices
flutter devices

# If emulator: start it manually
emulator -avd Pixel_5_API_30 &
```

**Issue**: Build fails with version conflict
```bash
# Solution: Clean and rebuild
flutter clean
flutter pub get
flutter pub run build_runner build
flutter run
```

**Issue**: Image not loading in app
```dart
// Check if API URL is correct
// Use correct base URL for physical devices
// Don't use localhost, use actual IP: 192.168.x.x
```

**Issue**: JSON serialization error
```bash
# Solution: Regenerate models
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## API Documentation

### Access API Docs (if installed)
```bash
# Install djangorestframework-spectacular
pip install drf-spectacular

# Add to INSTALLED_APPS
# Access at: http://localhost:8000/api/schema/swagger-ui/
```

---

## Deployment Preparation

### Before Deploying to Production

1. **Security Checklist**
   - [ ] Change SECRET_KEY in Django
   - [ ] Set DEBUG = False
   - [ ] Configure ALLOWED_HOSTS properly
   - [ ] Use environment variables for sensitive data
   - [ ] Enable HTTPS
   - [ ] Set up CORS properly
   - [ ] Implement rate limiting
   - [ ] Add authentication to all endpoints

2. **Database Checklist**
   - [ ] Use PostgreSQL in production
   - [ ] Set up database backups
   - [ ] Create database indexes
   - [ ] Test database recovery

3. **Server Checklist**
   - [ ] Use Gunicorn/uWSGI for Django
   - [ ] Set up Nginx as reverse proxy
   - [ ] Configure firewall
   - [ ] Set up SSL certificates
   - [ ] Monitor server logs
   - [ ] Set up error tracking (Sentry)

4. **Mobile App Checklist**
   - [ ] Update API URL to production
   - [ ] Build signed APK/AAB for Android
   - [ ] Configure iOS provisioning profiles
   - [ ] Test on real devices
   - [ ] Prepare app store listings

---

## Continuous Integration/Deployment

### GitHub Actions Example

```yaml
name: Build and Test

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v2
    
    - name: Set up Python
      uses: actions/setup-python@v2
      with:
        python-version: '3.10'
    
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -r requirements.txt
    
    - name: Run tests
      run: python manage.py test
    
    - name: Deploy
      if: github.ref == 'refs/heads/main'
      run: |
        # Add deployment commands here
```

---

## Useful Commands Reference

### Django Commands
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

# Collect static files
python manage.py collectstatic

# Shell
python manage.py shell

# Database reset
python manage.py flush
```

### Flutter Commands
```bash
# Get dependencies
flutter pub get

# Run app
flutter run

# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release

# Build iOS
flutter build ios --release

# Clean
flutter clean

# Analyze code
flutter analyze

# Format code
flutter format lib/

# Generate code
flutter pub run build_runner build
```

### PostgreSQL Commands
```bash
# Connect to database
psql -U postgres -d dairy_farm_db

# List databases
\l

# List tables
\dt

# Describe table
\d table_name

# Backup database
pg_dump dairy_farm_db > backup.sql

# Restore database
psql dairy_farm_db < backup.sql
```

---

## Performance Monitoring

### Backend Performance
```python
# Add django-silk for profiling
pip install django-silk

# Add to INSTALLED_APPS: 'silk'
# Access at: http://localhost:8000/silk/
```

### Frontend Performance
```dart
// Use DevTools to monitor performance
flutter pub global activate devtools
devtools
```

---

## Support & Resources

### Official Documentation
- [Django REST Framework](https://www.django-rest-framework.org/)
- [Flutter Docs](https://flutter.dev/docs)
- [PostgreSQL Docs](https://www.postgresql.org/docs/)

### Community
- Stack Overflow
- GitHub Issues
- Discord Communities

### Getting Help
1. Check existing issues and documentation
2. Search Stack Overflow
3. Ask on GitHub Discussions
4. Join community Discord servers

---

## Version Management

### Current Versions
- Django: 4.2+
- Django REST Framework: 3.14+
- Flutter: 3.0+
- Python: 3.10+
- PostgreSQL: 12+

### Checking Installed Versions
```bash
# Django
python -m django --version

# Python
python --version

# Flutter
flutter --version

# PostgreSQL
psql --version
```

---

## Next Steps

After setup:

1. **Explore the Dashboard**: Test all features
2. **Read the Documentation**: Review API docs
3. **Run Tests**: Ensure everything works
4. **Customize**: Add your farm-specific features
5. **Deploy**: Move to staging then production

---

## Troubleshooting Checklist

- [ ] All dependencies installed
- [ ] Environment variables configured
- [ ] Database migrated successfully
- [ ] API server running
- [ ] Flutter can reach API
- [ ] Test endpoints with Postman
- [ ] Check logs for errors
- [ ] Verify network connectivity
- [ ] Clear app cache if needed

---

**You're all set! Start developing your dairy farm management system.**

For questions or issues, refer to the comprehensive documentation files:
- `SYSTEM_DESIGN.md` - Overall architecture
- `API_DOCUMENTATION.md` - Detailed API endpoints
- `FLUTTER_IMPLEMENTATION_GUIDE.md` - Mobile app development
