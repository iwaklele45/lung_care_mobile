# LungCare+

Aplikasi mobile **monitoring pendampingan pengobatan TBC (Tuberkulosis)** berbasis Flutter. Dibangun sebagai bagian dari Tugas Akhir.

## ✨ Fitur Utama

| Fitur | Deskripsi |
|-------|-----------|
| 🔐 **Autentikasi** | Login/Register dengan Email & Google Sign-In, Reset Password via OTP Email |
| 🏠 **Dashboard** | Ringkasan jadwal obat hari ini, progress pengobatan, next dose card |
| 💊 **Jadwal Obat** | CRUD jadwal pengobatan, medication tracker, check-in dosis harian |
| 📋 **Riwayat Pengobatan** | Histori lengkap pengobatan dan adherence tracking |
| 🤖 **Chatbot Edukasi TBC** | Asisten AI (Gemini 2.5 Flash) untuk edukasi TBC via Firebase AI Logic |
| 🏥 **Fasilitas Kesehatan** | Peta fasilitas kesehatan terdekat (Google Maps) |
| 📝 **Daily Check-in** | Symptom tracker dan health check-in harian dengan streak |
| 👤 **Profil & Pengaturan** | Manajemen profil, pengaturan notifikasi, bahasa |
| 🔔 **Notifikasi** | Pengingat obat otomatis, pengaturan suara/getar/tunda |
| 🌐 **Multi-bahasa** | Mendukung Bahasa Indonesia dan English |

## 🛠 Tech Stack

- **Framework**: Flutter (Dart SDK ^3.11.5)
- **State Management**: flutter_bloc (BLoC pattern) + Provider (i18n)
- **Routing**: go_router
- **Backend**: Firebase
  - Firebase Authentication (Email/Password + Google Sign-In)
  - Cloud Firestore (database)
  - Cloud Functions (password reset OTP via email)
  - Firebase AI Logic (Gemini 2.5 Flash — chatbot)
  - Firebase Cloud Messaging (push notifications)
- **Email**: Nodemailer + Gmail SMTP (untuk OTP reset password)
- **Architecture**: Clean Architecture
- **Version Manager**: FVM (Flutter Version Management)

## 📋 Requirements

- Flutter SDK >= 3.35.0 (stable)
- Dart SDK ^3.11.5
- FVM (recommended)
- Node.js >= 20 (untuk Cloud Functions)
- Android Studio / Xcode
- `google-services.json` di `android/app/` (Firebase config)

## 🚀 Setup & Run

### Flutter App

```bash
# Install dependencies
fvm flutter pub get

# Generate typed assets (FlutterGen)
flutter pub run build_runner build --delete-conflicting-outputs

# Run di device/emulator (debug)
fvm flutter run

# Build APK release
fvm flutter build apk --release
```

Output APK: `build/app/outputs/flutter-apk/app-release.apk`

### Cloud Functions

```bash
cd functions

# Install dependencies
bun install  # atau: npm install

# Set environment variables (buat file .env)
cp .env.example .env
# Edit .env dengan Gmail credentials

# Deploy
cd ..
firebase deploy --only functions
```

### Konfigurasi Email SMTP

Cloud Functions memerlukan Gmail App Password untuk mengirim OTP:

1. Aktifkan **2-Step Verification** di akun Gmail
2. Buat **App Password** di https://myaccount.google.com/apppasswords
3. Isi `functions/.env`:
   ```
   GMAIL_EMAIL=email_pengirim@gmail.com
   GMAIL_PASSWORD=app_password_16_karakter
   ```
4. Deploy: `firebase deploy --only functions`

> **⚠️ Penting**: Jangan commit file `functions/.env` ke repository. File ini sudah ada di `.gitignore`.

## 📁 Project Structure

```
lung_care_mobile/
├── lib/
│   ├── main.dart                       # Entry point, Firebase init, GoRouter routes
│   ├── firebase_options.dart           # Firebase configuration (auto-generated)
│   ├── gen/                            # FlutterGen output (typed assets)
│   ├── l10n/                           # Internationalization (ID & EN)
│   │   ├── app_en.arb                  # English strings
│   │   ├── app_id.arb                  # Indonesian strings
│   │   ├── app_localizations.dart      # Generated l10n base class
│   │   ├── app_localizations_en.dart   # Generated English
│   │   └── app_localizations_id.dart   # Generated Indonesian
│   └── src/
│       ├── core/
│       │   ├── locale/                 # LocaleProvider (i18n ChangeNotifier)
│       │   ├── notifications/          # NotificationService, preferences, reminders
│       │   └── theme/                  # AppColors, tema aplikasi
│       ├── data/
│       │   ├── datasource/             # Remote data sources (Firebase)
│       │   │   ├── auth_remote_data_source.dart
│       │   │   ├── check_in_remote_data_source.dart
│       │   │   ├── dose_check_in_data_source.dart
│       │   │   └── schedule_remote_data_source.dart
│       │   ├── repositories/           # Repository implementations
│       │   └── services/               # ProfileStorageService, TbcChatService
│       ├── domain/
│       │   ├── entities/               # Domain models (PasswordResetResult, dll)
│       │   ├── repositories/           # Repository contracts (abstract)
│       │   └── usecases/               # Use cases (SignIn, ResetPassword, dll)
│       └── presentation/
│           ├── bloc/                   # BLoC (auth, home, history)
│           └── pages/
│               ├── auth/               # Login, Register, Forgot Password, OTP Verify
│               ├── chatbot/            # Chatbot Edukasi TBC (Gemini AI)
│               ├── checkin/            # Daily Health Check-in + Streak
│               ├── facilities/         # Peta Fasilitas Kesehatan
│               ├── hamburger/          # Drawer navigation menu
│               ├── history/            # Riwayat pengobatan
│               ├── home/               # Dashboard + widgets (NextDoseCard, dll)
│               ├── meds/               # Medication tracker, tambah/edit obat
│               ├── notifications/      # Notification center
│               ├── profile/            # Profil pengguna + Settings
│               └── schedule/           # Jadwal pengobatan harian
├── functions/
│   ├── index.js                        # Cloud Functions (password reset OTP)
│   ├── .env                            # Gmail SMTP credentials (tidak di-commit)
│   ├── .env.example                    # Template environment variables
│   └── package.json                    # Node.js dependencies
├── test/
│   └── widget_test.dart                # Widget tests
└── assets/                             # Gambar, ikon, animasi
```

## 🔥 Firebase Services

| Service | Kegunaan |
|---------|----------|
| **Firebase Auth** | Autentikasi pengguna (Email + Google Sign-In) |
| **Cloud Firestore** | Database (users, schedules, dose_check_ins, daily_check_ins, medication_logs) |
| **Cloud Functions** | Password reset OTP (generate, verify, resend, confirm) |
| **Firebase AI Logic** | Chatbot AI menggunakan Gemini 2.5 Flash |
| **Cloud Messaging** | Push notification untuk pengingat obat |

### Cloud Functions — Password Reset

4 Cloud Functions untuk alur reset password via OTP email:

| Function | Deskripsi |
|----------|-----------|
| `requestPasswordReset` | Generate OTP 6 digit, simpan ke Firestore, kirim email via Gmail SMTP |
| `resendPasswordResetCode` | Kirim ulang OTP baru (cooldown 60 detik) |
| `verifyPasswordResetCode` | Verifikasi OTP, return reset token (max 5 percobaan) |
| `confirmPasswordReset` | Reset password user menggunakan reset token |

### Chatbot (Firebase AI Logic)

- Model: `gemini-2.5-flash` (free tier: 5 RPM)
- Retry logic otomatis untuk rate limit & server errors
- Status indikator dinamis (Online / Mengetik / Sibuk / Offline)

### App Check

```
Debug mode  → AndroidDebugProvider (perlu daftarkan debug token di Firebase Console)
Release mode → App Check di-skip (untuk distribusi APK via GitHub/sideload)
```

> **Catatan**: App Check sengaja dinonaktifkan di release mode agar APK sideloaded untuk Tugas Akhir tetap berfungsi.

## 🏗 State Management

### BLoC (flutter_bloc)
- `AuthBloc` — Autentikasi, login/register, password reset
- `HomeBloc` — Dashboard, jadwal obat, next dose, check-in
- `HistoryBloc` — Riwayat pengobatan

### Provider
- `LocaleProvider` — Pengaturan bahasa (ID/EN) via `ChangeNotifierProvider`

## 🌐 Internationalization (i18n)

Mendukung 2 bahasa:
- 🇮🇩 **Bahasa Indonesia** (default)
- 🇬🇧 **English**

```dart
// Penggunaan di widget
final l = AppLocalizations.of(context)!;
Text(l.greetingMorning);  // "Selamat pagi" / "Good morning"
```

String disimpan di `lib/l10n/app_id.arb` dan `lib/l10n/app_en.arb`.

## 🔔 Notifikasi

- **Pengingat obat** otomatis berdasarkan jadwal
- Pengaturan **suara**, **getar**, dan **durasi tunda** (snooze)
- **Alarm presisi** (exact alarm) untuk jadwal yang tepat waktu
- **Full-screen intent** untuk popup saat layar terkunci
- Konfigurasi via halaman **Settings**

## 📦 FlutterGen (Typed Assets)

```bash
# Tambah asset baru:
# 1. Letakkan file di assets/ (contoh: assets/icons/)
# 2. Pastikan folder terdaftar di pubspec.yaml → flutter → assets
# 3. Regenerate:
flutter pub run build_runner build --delete-conflicting-outputs
```

Penggunaan:
```dart
Assets.icons.lungCareLogo.image(width: 120, height: 120)
Assets.icons.logoApp.svg(width: 120, height: 120)
```

## 📱 Build & Distribution

```bash
# Build APK release
fvm flutter build apk --release

# Build App Bundle (untuk Play Store)
fvm flutter build appbundle --release
```

> **Catatan**: Release build saat ini menggunakan debug signing key. Untuk distribusi ke Play Store, perlu membuat release keystore terpisah.

## ⚙️ Useful Commands

```bash
# Install dependencies
fvm flutter pub get

# Generate assets
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate)
flutter pub run build_runner watch --delete-conflicting-outputs

# Analyze code
fvm flutter analyze

# Run tests
fvm flutter test

# Deploy Cloud Functions
firebase deploy --only functions
```
