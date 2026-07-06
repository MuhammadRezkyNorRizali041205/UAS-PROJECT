# Sistem Informasi Pengumpulan Tugas UAS Poliban

> **UAS Pemrograman Perangkat Bergerak — Politeknik Negeri Banjarmasin**  
> Semester 4 · Teknik Informatika · 2025/2026

Aplikasi fullstack untuk pengelolaan dan pengumpulan tugas ujian akhir semester. Terdiri dari **admin panel berbasis web** (Laravel) untuk manajemen data akademik, dan **aplikasi mobile** (Flutter) untuk mahasiswa mengumpulkan tugas UAS.

---

## Daftar Isi

- [Fitur Utama](#fitur-utama)
- [Tech Stack](#tech-stack)
- [Struktur Proyek](#struktur-proyek)
- [Skema Database](#skema-database)
- [Instalasi Backend](#instalasi-backend)
- [Instalasi Mobile](#instalasi-mobile)
- [API Reference](#api-reference)
- [Admin Panel](#admin-panel)
- [Akun Default](#akun-default)

---

## Fitur Utama

### Admin Panel (Web)
- Login admin dengan session-based authentication
- CRUD Tahun Akademik, Program Studi, Kelas
- CRUD Mata Kuliah, Dosen, Mahasiswa
- Manajemen Kelas Mata Kuliah (penugasan dosen ke kelas)
- Monitoring status pengumpulan tugas seluruh mahasiswa

### Aplikasi Mobile (Mahasiswa)
- Login & registrasi dengan token JWT (Sanctum)
- Dashboard dengan banner akses cepat ke pengumpulan UAS
- **Tugas UAS** — 3 tab:
  - *Mata Kuliah Saya*: daftar mata kuliah di kelas + status pengumpulan
  - *Riwayat Tugas*: histori semua tugas yang sudah dikumpulkan
  - *Profil*: data akademik mahasiswa (NIM, kelas, program studi)
- Form pengumpulan tugas: judul project, link Google Drive, GitHub, YouTube
- Notifikasi real-time & push notification

---

## Tech Stack

| Layer | Teknologi |
|---|---|
| Backend | Laravel 12, PHP 8.3 |
| Database | PostgreSQL 16 |
| Cache / Queue | Redis |
| Auth API | Laravel Sanctum (Bearer Token) |
| Auth Web | Laravel Session Guard |
| Mobile | Flutter 3.22+, Dart 3.3+ |
| State Management | Riverpod 3.0 (`@riverpod` annotation) |
| Routing Mobile | GoRouter (`StatefulShellRoute`) |
| HTTP Client | Dio |
| Containerisasi | Docker + Docker Compose |

---

## Struktur Proyek

```
UAS-PROJECT/
├── backend/                    # Laravel 12 API + Admin Panel
│   ├── app/
│   │   ├── Http/
│   │   │   ├── Controllers/
│   │   │   │   ├── Admin/      # Web controllers (Blade)
│   │   │   │   └── Api/V1/     # REST API controllers
│   │   │   └── Middleware/
│   │   └── Models/
│   ├── database/
│   │   ├── migrations/
│   │   └── seeders/
│   └── routes/
│       ├── api.php             # REST API routes
│       └── web.php             # Admin panel routes
│
└── mobile/                     # Flutter App
    └── lib/
        ├── core/
        │   ├── network/        # Dio client + interceptors
        │   └── router/         # GoRouter config
        ├── features/
        │   ├── auth/           # Login, register, splash
        │   ├── dashboard/      # Halaman utama mahasiswa
        │   ├── tugas_uas/      # Fitur pengumpulan UAS
        │   └── ...             # Fitur lain (jadwal, presensi, dll)
        └── shared/             # Theme, widgets, constants
```

---

## Skema Database

```
tahun_akademiks      program_studis       kelas
─────────────────    ──────────────────   ──────────────────────────
id                   id                   id
nama                 nama_prodi           nama_kelas
status_aktif         kode_prodi (unique)  tahun_akademik_id (FK)
                                          program_studi_id (FK)

mata_kuliahs         dosens               mahasiswas
─────────────────    ──────────────────   ──────────────────────────
id                   id                   id
nama_mk              user_id (unique FK)  user_id (unique FK)
kode_mk (unique)     nip_nidn             nim (unique)
sks                  no_hp                no_hp
                                          kelas_id (nullable FK)

kelas_mata_kuliah                         tugas
─────────────────────────────────────     ─────────────────────────────────────
id                                        id
kelas_id (FK)                             mahasiswa_id (FK)
mata_kuliah_id (FK)                       kelas_mata_kuliah_id (FK)
dosen_id (FK)                             judul_project
unique(kelas_id, mata_kuliah_id)          file_database, file_laporan
                                          link_gdrive, link_github, link_youtube
                                          status (dikumpulkan/terlambat/belum)
                                          submitted_at
                                          unique(mahasiswa_id, kelas_mata_kuliah_id)
```

---

## Instalasi Backend

### Prasyarat
- Docker & Docker Compose
- PHP 8.3+ (jika tanpa Docker)

### Dengan Docker (Direkomendasikan)

```bash
cd backend

# 1. Salin file environment
cp .env.example .env

# 2. Build dan jalankan container
docker-compose up -d --build

# 3. Install dependencies
docker exec smart_campus_app composer install

# 4. Generate application key
docker exec smart_campus_app php artisan key:generate

# 5. Jalankan migrasi
docker exec smart_campus_app php artisan migrate

# 6. Seed data awal (termasuk akun admin & contoh data UAS)
docker exec smart_campus_app php artisan db:seed --class=UasSeeder
```

### Tanpa Docker (Local)

```bash
cd backend
composer install
cp .env.example .env
# Edit .env sesuaikan DB_HOST, DB_DATABASE, dll.
php artisan key:generate
php artisan migrate
php artisan db:seed --class=UasSeeder
php artisan storage:link
php artisan serve
```

### URL Layanan

| Layanan | URL |
|---|---|
| API / Admin Panel | http://localhost:8000 |
| MailHog (Email Testing) | http://localhost:8025 |
| PostgreSQL | localhost:5432 |
| Redis | localhost:6379 |

### Perintah Artisan Berguna

```bash
# Jalankan queue worker
docker exec smart_campus_app php artisan queue:work

# Bersihkan cache
docker exec smart_campus_app php artisan optimize:clear

# Refresh migrasi + seed ulang
docker exec smart_campus_app php artisan migrate:fresh --seed
```

---

## Instalasi Mobile

### Prasyarat
- Flutter 3.22+ (stable channel)
- Dart 3.3+
- Android Studio / VS Code
- Android SDK (API 21+) atau iOS 12+

### Setup

```bash
cd mobile

# 1. Install dependencies
flutter pub get

# 2. Generate kode Riverpod & GoRouter
dart run build_runner build --delete-conflicting-outputs

# 3. Jalankan di emulator/perangkat
flutter run
```

### Konfigurasi URL Backend

```bash
# Android Emulator (localhost → 10.0.2.2)
flutter run --dart-define=BASE_URL=http://10.0.2.2:8000/api/v1

# Perangkat fisik (gunakan IP lokal komputer)
flutter run --dart-define=BASE_URL=http://192.168.x.x:8000/api/v1

# Build release dengan server production
flutter build apk --dart-define=BASE_URL=https://your-domain.com/api/v1
```

---

## API Reference

Semua respons menggunakan format standar:

```json
{
  "success": true,
  "message": "OK",
  "data": {},
  "meta": {}
}
```

Header autentikasi diperlukan untuk semua endpoint (kecuali login/register):
```
Authorization: Bearer <token>
```

### Endpoint Tugas UAS

| Method | Endpoint | Deskripsi |
|---|---|---|
| `GET` | `/api/v1/tugas-uas/mata-kuliah` | Daftar mata kuliah + status pengumpulan |
| `POST` | `/api/v1/tugas-uas` | Kumpulkan / perbarui tugas |
| `GET` | `/api/v1/tugas-uas/riwayat` | Riwayat tugas yang dikumpulkan |
| `GET` | `/api/v1/tugas-uas/profil` | Profil akademik mahasiswa |
| `GET` | `/api/v1/tugas-uas/{id}` | Detail satu tugas |

### Endpoint Autentikasi

| Method | Endpoint | Deskripsi |
|---|---|---|
| `POST` | `/api/v1/auth/login` | Login mahasiswa/dosen |
| `POST` | `/api/v1/auth/register` | Registrasi akun baru |
| `POST` | `/api/v1/auth/logout` | Logout (hapus token) |
| `GET` | `/api/v1/auth/me` | Data user yang sedang login |

---

## Admin Panel

Akses di: **http://localhost:8000/admin/login**

| Halaman | URL |
|---|---|
| Login | `/admin/login` |
| Dashboard | `/admin` |
| Tahun Akademik | `/admin/tahun-akademik` |
| Program Studi | `/admin/program-studi` |
| Mata Kuliah | `/admin/mata-kuliah` |
| Dosen | `/admin/dosen` |
| Kelas | `/admin/kelas` |
| Kelas Mata Kuliah | `/admin/kelas-mata-kuliah` |
| Mahasiswa | `/admin/mahasiswa` |
| Monitoring Tugas | `/admin/tugas` |

---

## Akun Default

> Akun ini dibuat otomatis saat menjalankan `UasSeeder`.

### Admin Panel

| Field | Value |
|---|---|
| Email | `admin@poliban.ac.id` |
| Password | `admin123` |

### Akun Mahasiswa (Mobile)

| Field | Value |
|---|---|
| Email | `c050424037@mahasiswa.poliban.ac.id` |
| Password | `password` |
| NIM | `C050424037` |
| Kelas | `SIKC-4A` |
| Program Studi | `Sistem Informasi Kota Cerdas` |

---

## Pengembang

| Info | Detail |
|---|---|
| Nama | Muhammad Rezky Nor Rizali |
| NIM | C050424037 |
| Program Studi | Sistem Informasi Kota Cerdas |
| Institusi | Politeknik Negeri Banjarmasin |
| Mata Kuliah | Pemrograman Perangkat Bergerak |
| Tahun Akademik | 2025/2026 |

---

<p align="center">
  Dibuat untuk memenuhi tugas UAS Pemrograman Perangkat Bergerak · Poliban 2026
</p>
