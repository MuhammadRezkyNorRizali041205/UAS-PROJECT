# Smart Campus Assistant - Setup Guide

## Backend (Laravel 12 + Docker)

### Quick Start

```bash
cd backend

# 1. Copy env
cp .env.example .env

# 2. Build & start containers
docker-compose up -d --build

# 3. Install dependencies (inside container)
docker exec smart_campus_app composer install

# 4. Generate app key
docker exec smart_campus_app php artisan key:generate

# 5. Run migrations
docker exec smart_campus_app php artisan migrate

# 6. (Optional) Seed database
docker exec smart_campus_app php artisan db:seed
```

### Services
| Service   | URL                      |
|-----------|--------------------------|
| API       | http://localhost:8000    |
| MailHog   | http://localhost:8025    |
| Postgres  | localhost:5432           |
| Redis     | localhost:6379           |

### Artisan Commands
```bash
# Run queue worker
docker exec smart_campus_app php artisan queue:work

# Clear cache
docker exec smart_campus_app php artisan optimize:clear
```

---

## Mobile (Flutter)

### Requirements
- Flutter 3.22+ (stable)
- Dart 3.3+
- Android Studio / VS Code

### Quick Start

```bash
cd mobile

# 1. Install dependencies
flutter pub get

# 2. Generate Riverpod/Freezed code
dart run build_runner build --delete-conflicting-outputs

# 3. Run on emulator/device
flutter run
```

### Build Variants
```bash
# Debug (uses 10.0.2.2 for Android emulator → localhost)
flutter run --dart-define=BASE_URL=http://10.0.2.2:8000/api/v1

# Release with real server URL
flutter build apk --dart-define=BASE_URL=https://your-domain.com/api/v1
```

---

## API Docs

All responses follow this format:
```json
{
  "success": true,
  "message": "OK",
  "data": {},
  "meta": { ... }
}
```

Auth endpoints require `Authorization: Bearer <token>` header.
