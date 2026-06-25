# Mobile Remunerasi Application

Aplikasi mobile berbasis **Flutter/Dart** untuk sistem penggajian (remunerasi) restoran. Aplikasi ini merupakan frontend mobile yang terhubung dengan backend REST API Laravel.

> **Repository Backend:** [apiremunerationapplication](https://github.com/farhanfauzanazima/apiremunerationapplication)
> **Repository Mobile:** [mobileremunerationapplication](https://github.com/farhanfauzanazima/mobileremunerationapplication)

---

## Daftar Isi

- [Tentang Proyek](#tentang-proyek)
- [Fitur](#fitur)
- [Teknologi](#teknologi)
- [Struktur Folder](#struktur-folder)
- [Prasyarat](#prasyarat)
- [Instalasi](#instalasi)
- [Konfigurasi](#konfigurasi)
- [Menjalankan Aplikasi](#menjalankan-aplikasi)
- [Role & Akses](#role--akses)
- [Akun Default](#akun-default)
- [Screenshot Fitur](#screenshot-fitur)
- [Git Branch Strategy](#git-branch-strategy)

---

## Tentang Proyek

Aplikasi ini dibangun untuk menyelesaikan masalah penggajian manual di restoran yang sebelumnya memakan waktu 4–6 jam karena admin harus membuat slip gaji satu per satu, mengkonversi ke PDF, lalu mengirim secara manual.

Sistem ini **bukan** sistem payroll/transfer gaji, melainkan:
- ✅ Sistem pencatatan & perhitungan gaji otomatis
- ✅ Sistem generate slip gaji PDF
- ✅ Sistem distribusi slip gaji via Email

---

## Fitur

### Autentikasi
- Login dengan email & password
- Splash screen dengan auto-redirect berdasarkan role
- Logout dengan konfirmasi
- Edit profil & ganti password

### Owner
- Kelola **Kategori Gaji** (CRUD) — gaji pokok, tunjangan, potongan
- Lihat **Data Karyawan**
- Kelola **Periode Penggajian** (Open/Close/Reopen)
- Lihat & buat **Slip Gaji**
- **Dashboard Owner** — summary, tren gaji, statistik email
- **Laporan Rekap Gaji** per periode + export PDF
- **Statistik Tren** 12 periode terakhir
- **Activity Log** semua pengguna

### Kepala Toko/Staf HR (Head)
- Kelola **Data Karyawan** (CRUD + search + filter)
- Kelola **Periode Penggajian**
- Lihat & buat **Slip Gaji**
- **Dashboard Kepala Toko** — ringkasan & slip terbaru
- **Laporan Rekap Gaji** + Statistik

### Admin
- Buat **Slip Gaji** (single & bulk generate)
- **Preview & Generate PDF** slip gaji
- **Kirim Email** slip gaji (single & massal)
- **Riwayat Email** & kirim ulang
- **Dashboard Admin** — aksi cepat & slip terbaru

---

## Teknologi

| Kategori | Teknologi |
|---|---|
| Framework | Flutter 3.x (Dart) |
| State Management | Provider |
| HTTP Client | Dio |
| Local Storage | SharedPreferences |
| PDF Viewer | flutter_pdfview |
| Font | Google Fonts (Poppins) |
| Internationalization | intl |
| File Management | path_provider |

---

## Struktur Folder

```
lib/
├── main.dart
├── app/
│   ├── app.dart                    # MaterialApp, MultiProvider, routes
│   └── routes.dart                 # Named routes konstanta
├── core/
│   ├── constants/
│   │   ├── api_constants.dart      # Base URL & endpoint strings
│   │   └── app_constants.dart      # Storage keys, role constants
│   ├── network/
│   │   └── api_client.dart         # Dio HTTP client + interceptor token
│   ├── storage/
│   │   └── local_storage.dart      # SharedPreferences wrapper
│   └── utils/
│       └── formatters.dart         # Format Rupiah, tanggal, label
├── features/
│   ├── auth/                       # Login, Logout, Profile
│   ├── salary_category/            # Kategori Gaji (Owner)
│   ├── employee/                   # Manajemen Karyawan
│   ├── payroll_period/             # Periode Penggajian
│   ├── salary_slip/                # Slip Gaji + PDF
│   ├── email/                      # Distribusi Email
│   ├── dashboard/                  # Dashboard per Role
│   └── reports/                    # Laporan, Statistik, Activity Log
└── shared/
    ├── theme/
    │   └── app_theme.dart          # Tema, warna, typography
    └── widgets/
        ├── loading_widget.dart
        └── error_widget.dart
```

Setiap feature mengikuti pola **Clean Architecture**:
```
feature/
├── data/
│   ├── models/         # Model dari JSON response API
│   └── repositories/   # Pemanggilan API via Dio
├── presentation/
│   └── screens/        # Halaman UI Flutter
└── providers/          # State management (ChangeNotifier)
```

---

## Prasyarat

Pastikan sudah terinstall:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) >= 3.0.0
- Dart >= 3.0.0
- Android Studio / VS Code
- Android Emulator atau device fisik
- Backend Laravel sudah berjalan (lihat repo backend)

Cek versi Flutter:
```bash
flutter --version
dart --version
```

---

## Instalasi

### 1. Clone Repository

```bash
git clone https://github.com/farhanfauzanazima/mobileremunerationapplication.git
cd mobileremunerationapplication
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Jalankan Backend Laravel

Pastikan backend sudah berjalan. Masuk ke folder backend dan jalankan:

```bash
# Untuk Emulator Android
php artisan serve

# Untuk Device Fisik (ganti dengan IP komputer kamu)
php artisan serve --host=0.0.0.0 --port=8000
```

---

## Konfigurasi

### Base URL API

Buka file `lib/core/constants/api_constants.dart` dan sesuaikan `baseUrl`:

```dart
class ApiConstants {
  // Android Emulator
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Device Fisik (ganti dengan IP komputer kamu)
  // static const String baseUrl = 'http://192.168.X.X:8000/api';

  // Chrome / Web
  // static const String baseUrl = 'http://localhost:8000/api';
}
```

| Environment | Base URL |
|---|---|
| Android Emulator | `http://10.0.2.2:8000/api` |
| Device Fisik | `http://[IP_KOMPUTER]:8000/api` |
| Chrome / Web | `http://localhost:8000/api` |

> **Cara cari IP komputer:** Buka CMD → ketik `ipconfig` → lihat **IPv4 Address** di bagian Wi-Fi

### Cara Cari IP untuk Device Fisik

```bash
# Windows
ipconfig

# Mac / Linux
ifconfig
```

---

## Menjalankan Aplikasi

### Lihat device yang tersedia

```bash
flutter devices
```

### Jalankan di Emulator Android

```bash
flutter run
```

### Jalankan di Device Fisik

```bash
# Pastikan USB Debugging aktif di HP
# Settings → Developer Options → USB Debugging
flutter run
```

### Jalankan di Chrome (Web)

```bash
flutter run -d chrome
```

### Build APK

```bash
flutter build apk --release
```

APK tersimpan di: `build/app/outputs/flutter-apk/app-release.apk`

---

## Role & Akses

| Menu / Fitur | Owner | Head | Admin |
|---|:---:|:---:|:---:|
| Dashboard | ✅ | ✅ | ✅ |
| Kategori Gaji (CRUD) | ✅ | ❌ | ❌ |
| Data Karyawan (CRUD) | ✅ | ✅ | ❌ |
| Periode Penggajian | ✅ | ✅ | ❌ |
| Slip Gaji | ✅ | ✅ | ✅ |
| Bulk Generate Slip | ✅ | ✅ | ✅ |
| Preview & Generate PDF | ✅ | ✅ | ✅ |
| Kirim Email Single | ✅ | ✅ | ✅ |
| Kirim Email Massal | ✅ | ✅ | ✅ |
| Riwayat Email | ✅ | ✅ | ✅ |
| Laporan Rekap Gaji | ✅ | ✅ | ✅ |
| Statistik Tren | ✅ | ✅ | ❌ |
| Activity Log | ✅ | ❌ | ❌ |

---

## Akun Default

Akun ini tersedia setelah menjalankan seeder di backend:

| Role | Email | Password |
|---|---|---|
| Owner | owner@resto.com | password123 |
| Kepala Toko | head@resto.com | password123 |
| Admin | admin@resto.com | password123 |

---

## Git Branch Strategy

Setiap fitur dikerjakan di branch tersendiri lalu di-merge ke `main`:

| Branch | Fitur |
|---|---|
| `main` | Setup awal project |
| `feature/authentication` | Login, Logout, Profile, Ganti Password |
| `feature/salary-category` | Master Kategori Gaji |
| `feature/employee-management` | Manajemen Karyawan |
| `feature/payroll-period` | Periode Penggajian |
| `feature/salary-slip` | Slip Gaji & Kalkulasi |
| `feature/pdf-viewer` | Generate & Preview PDF |
| `feature/email-distribution` | Distribusi Email |
| `feature/dashboard` | Dashboard per Role |
| `feature/reports-activity-log` | Laporan, Statistik & Activity Log |

---

## Formula Perhitungan Gaji

```
Total Gaji Bersih = Gaji Pokok
                  + Tunjangan
                  + Bonus
                  - (Jumlah Terlambat × Potongan per Keterlambatan)
                  - Potongan Tambahan

Catatan: Total tidak boleh negatif (minimum = 0)
```

---

## Relasi dengan Backend

Aplikasi ini mengkonsumsi **±47 endpoint** dari backend Laravel. Setiap request menyertakan:

```
Authorization: Bearer {token}
Accept: application/json
Content-Type: application/json
```

Token disimpan di **SharedPreferences** setelah login dan di-inject otomatis oleh Dio interceptor ke setiap request.

---

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  dio: ^5.4.0                  # HTTP Client
  provider: ^6.1.2             # State Management
  shared_preferences: ^2.2.3   # Local Storage
  flutter_pdfview: ^1.3.2      # PDF Viewer
  google_fonts: ^6.2.1         # Typography
  intl: ^0.19.0                # Formatting & Locale
  url_launcher: ^6.3.0         # Buka URL
  path_provider: ^2.1.3        # Direktori file
  open_file: ^3.3.2            # Buka file lokal
```

---

## Developer

**Farhan Fauzan Azima**
- GitHub: [@farhanfauzanazima](https://github.com/farhanfauzanazima)
- Repository: [mobileremunerationapplication](https://github.com/farhanfauzanazima/mobileremunerationapplication)

---

## Lisensi

Proyek ini dibuat untuk keperluan pengembangan sistem remunerasi restoran.

---

*Dibuat dengan ❤️ menggunakan Laravel 12*
