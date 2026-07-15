# Sistem Informasi Pengumpulan Tugas UAS Poliban

> **UAS Pemrograman Perangkat Bergerak — Politeknik Negeri Banjarmasin**  
> Semester 4 · Sistem Informasi Kota Cerdas · 2025/2026

Aplikasi fullstack untuk pengelolaan dan pengumpulan tugas ujian akhir semester. Terdiri dari **admin panel berbasis web** (Laravel) untuk manajemen data akademik, dan **aplikasi mobile** (Flutter) untuk mahasiswa mengumpulkan tugas UAS secara real-time.

---

## Daftar Isi

- [Fitur Utama](#fitur-utama)
- [Tech Stack](#tech-stack)
- [Struktur Proyek](#struktur-proyek)
- [Skema Database](#skema-database)
- [Arsitektur Notifikasi SSE](#arsitektur-notifikasi-sse)
- [Instalasi Backend](#instalasi-backend)
- [Instalasi Mobile](#instalasi-mobile)
- [API Reference](#api-reference)
- [Admin Panel](#admin-panel)
- [Akun Default](#akun-default)
- [Pengembang](#pengembang)

---

## Fitur Utama

### Admin Panel (Web)
- Login admin dengan session-based authentication
- CRUD Tahun Akademik, Program Studi, Kelas
- CRUD Mata Kuliah, Dosen, Mahasiswa
- Manajemen Kelas Mata Kuliah — penugasan dosen beserta **deadline pengumpulan**
- Monitoring status pengumpulan tugas seluruh mahasiswa

### Aplikasi Mobile (Mahasiswa)
- Login & registrasi dengan token JWT (Sanctum)
- Dashboard dengan banner akses cepat ke pengumpulan UAS
- **Tugas UAS** — 3 tab:
  - *Mata Kuliah Saya*: daftar mata kuliah di kelas + status pengumpulan
  - *Riwayat Tugas*: histori semua tugas yang sudah dikumpulkan
  - *Profil*: data akademik mahasiswa (NIM, kelas, program studi)
- Form pengumpulan tugas: judul project, link Google Drive, GitHub, YouTube
- **Notifikasi real-time via SSE** (Server-Sent Events):
  - Pemberitahuan saat dosen membuka pengumpulan tugas baru
  - Pengingat otomatis saat deadline kurang dari 24 jam
  - Local notification muncul di notif bar perangkat

---

## Tech Stack

| Layer | Teknologi |
|---|---|
| Backend | Laravel 12, PHP 8.3 |
| Database | PostgreSQL 16 |
| Cache / Queue | Redis |
| Real-time | **Server-Sent Events (SSE)** via Laravel `StreamedResponse` |
| Auth API | Laravel Sanctum (Bearer Token) |
| Auth Web | Laravel Session Guard |
| Mobile | Flutter 3.22+, Dart 3.3+ |
| State Management | Riverpod 3.0 (`@riverpod` annotation) |
| Routing Mobile | GoRouter (`StatefulShellRoute`) |
| HTTP Client | Dio (SSE: `ResponseType.stream`) |
| Local Notification | `flutter_local_notifications` |
| Containerisasi | Docker + Docker Compose |

---

## Struktur Proyek

```
UAS-PROJECT/
├── backend/
│   ├── app/
│   │   ├── Console/Commands/
│   │   │   └── SendDeadlineReminders.php   # Scheduler pengingat deadline
│   │   ├── Http/Controllers/
│   │   │   ├── Admin/                      # Web controllers (Blade)
│   │   │   └── Api/V1/
│   │   │       ├── NotificationController.php  # + SSE stream endpoint
│   │   │       └── TugasController.php
│   │   ├── Models/
│   │   └── Observers/
│   │       └── KelasMataKuliahObserver.php  # Auto-notifikasi saat assignment dibuat
│   ├── database/migrations/
│   └── routes/
│       ├── api.php
│       └── web.php
│
└── mobile/lib/
    ├── core/
    │   ├── network/                         # Dio client + interceptors
    │   ├── router/                          # GoRouter config
    │   └── services/
    │       ├── sse_service.dart             # SSE client (Dio stream + auto-reconnect)
    │       ├── sse_notification_provider.dart  # Riverpod SSE listener
    │       └── local_notification_service.dart # flutter_local_notifications wrapper
    ├── features/
    │   ├── auth/
    │   ├── dashboard/                       # Banner Tugas UAS
    │   ├── notification/                    # Notification feed
    │   └── tugas_uas/                       # Fitur pengumpulan UAS
    └── shared/
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
──────────────────────────────────────    ─────────────────────────────────────
id                                        id
kelas_id (FK)                             mahasiswa_id (FK)
mata_kuliah_id (FK)                       kelas_mata_kuliah_id (FK)
dosen_id (FK)                             judul_project
deadline                    ← baru        file_database, file_laporan
judul_tugas                 ← baru        link_gdrive, link_github, link_youtube
unique(kelas_id, mk_id)                   status (dikumpulkan/terlambat/belum)
                                          submitted_at
                                          unique(mahasiswa_id, kelas_mk_id)

notification_logs
────────────────────────────────────────
id
user_id (FK)
type  (new_assignment | deadline_reminder | deadline_updated | ...)
title, body
data  (JSON: kelas_mata_kuliah_id, nama_mk, deadline, ...)
sent_at, read_at
```

---

## Arsitektur Notifikasi SSE

```
Admin buat/update kelas_mata_kuliah
         │
         ▼
KelasMataKuliahObserver (Laravel)
         │  insert NotificationLog untuk setiap mahasiswa di kelas
         ▼
notification_logs (database)
         │
         ├──── SSE Stream (polling tiap 2 detik)
         │     GET /api/v1/notifications/stream
         │     ↳ kirim event ke client yang sedang terhubung
         │
         └──── Scheduler (tiap jam)
               php artisan notifications:send-deadline-reminders
               ↳ insert NotificationLog untuk mahasiswa yg belum kumpul
                 dan deadlinenya < 24 jam

Flutter (SseService)
  ├── Koneksi Dio ResponseType.stream
  ├── Auto-reconnect 5 detik jika putus
  ├── Kirim Last-Event-ID saat reconnect (tidak dapat duplikat)
  └── Event masuk → LocalNotificationService.show()
                  → ref.invalidate(notificationUnreadCountProvider)
```

**Tipe Event SSE:**

| Event | Kapan dikirim |
|---|---|
| `connected` | Saat koneksi pertama kali berhasil |
| `notification` | Saat ada `NotificationLog` baru yang belum dibaca |
| `: heartbeat` | Tiap 30 detik untuk menjaga koneksi |

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

# 6. Seed data awal (akun admin, mahasiswa, & contoh data UAS)
docker exec smart_campus_app php artisan db:seed --class=UasSeeder
```

### Tanpa Docker (Local)

```bash
cd backend
composer install
cp .env.example .env
# Edit .env: DB_HOST, DB_DATABASE, DB_USERNAME, DB_PASSWORD
php artisan key:generate
php artisan migrate
php artisan db:seed --class=UasSeeder
php artisan storage:link
php artisan serve
```

### Aktifkan Scheduler (Pengingat Deadline)

```bash
# Jalankan Laravel scheduler — wajib agar reminder otomatis berfungsi
docker exec smart_campus_app php artisan schedule:work

# Atau test manual sekali jalan
php artisan notifications:send-deadline-reminders
```

### URL Layanan

| Layanan | URL |
|---|---|
| API / Admin Panel | http://localhost:8000 |
| SSE Endpoint | http://localhost:8000/api/v1/notifications/stream |
| MailHog (Email Testing) | http://localhost:8025 |
| PostgreSQL | localhost:5432 |
| Redis | localhost:6379 |

### Perintah Artisan Berguna

```bash
# Jalankan queue worker
docker exec smart_campus_app php artisan queue:work

# Bersihkan cache
docker exec smart_campus_app php artisan optimize:clear

# Test kirim reminder deadline manual
docker exec smart_campus_app php artisan notifications:send-deadline-reminders

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

# Build release APK
flutter build apk --dart-define=BASE_URL=https://your-domain.com/api/v1
```

> APK hasil build tersimpan di `mobile/build/app/outputs/flutter-apk/app-release.apk`

### Izin Notifikasi (Android)

Izin `POST_NOTIFICATIONS` sudah dikonfigurasi di `AndroidManifest.xml`. Di Android 13+, dialog izin akan muncul otomatis saat aplikasi pertama kali dibuka.

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

### Endpoint Notifikasi

| Method | Endpoint | Deskripsi |
|---|---|---|
| `GET` | `/api/v1/notifications/stream` | **SSE stream** notifikasi real-time |
| `GET` | `/api/v1/notifications` | Daftar notifikasi (paginasi) |
| `GET` | `/api/v1/notifications/unread-count` | Jumlah notifikasi belum dibaca |
| `PATCH` | `/api/v1/notifications/{id}/read` | Tandai satu notifikasi dibaca |
| `PATCH` | `/api/v1/notifications/read-all` | Tandai semua notifikasi dibaca |
| `DELETE` | `/api/v1/notifications/{id}` | Hapus notifikasi |

#### Format SSE Stream

Koneksi: `GET /api/v1/notifications/stream`  
Header: `Accept: text/event-stream`, `Authorization: Bearer <token>`  
Reconnect: gunakan header `Last-Event-ID: <id>` agar tidak terima duplikat.

```
event: connected
data: {"message":"SSE connected"}

id: 42
event: notification
data: {"id":42,"type":"new_assignment","title":"Tugas Baru: Pemrograman Mobile Flutter","body":"Dosen Budi Hartono membuka pengumpulan...","sent_at":"2026-07-06T10:00:00Z"}

: heartbeat
```

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
| Kelas Mata Kuliah + Deadline | `/admin/kelas-mata-kuliah` |
| Mahasiswa | `/admin/mahasiswa` |
| Monitoring Tugas | `/admin/tugas` |

> Saat admin menyimpan **Kelas Mata Kuliah** dengan deadline, sistem otomatis mengirim notifikasi ke seluruh mahasiswa di kelas tersebut.

---

## Akun Default

> Dibuat otomatis saat menjalankan `UasSeeder`.

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
