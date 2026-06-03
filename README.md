# LungCare+

Aplikasi mobile **monitoring pendampingan pengobatan TBC (Tuberkulosis)** berbasis Flutter. Dibangun sebagai bagian dari Tugas Akhir.

## ✨ Fitur Utama

| Fitur | Deskripsi |
|-------|-----------|
| 🔐 **Autentikasi** | Login/Register dengan Email & Google Sign-In, Forgot Password, Complete Profile |
| 🏠 **Dashboard** | Ringkasan jadwal obat hari ini, progress pengobatan, next dose card |
| 💊 **Jadwal Obat** | CRUD jadwal pengobatan, reminder, check-in dosis harian |
| 📋 **Riwayat Pengobatan** | Histori lengkap pengobatan dan adherence tracking |
| 🤖 **Chatbot Edukasi TBC** | Asisten AI (Gemini 2.5 Flash) untuk edukasi TBC via Firebase AI Logic |
| 🏥 **Fasilitas Kesehatan** | Peta fasilitas kesehatan terdekat (Google Maps) |
| 📝 **Daily Check-in** | Symptom tracker dan health check-in harian |
| 👤 **Profil** | Manajemen profil pengguna dengan edit data |

## 🛠 Tech Stack

- **Framework**: Flutter (Dart SDK ^3.11.5)
- **State Management**: flutter_bloc (BLoC pattern)
- **Routing**: go_router
- **Backend**: Firebase
  - Firebase Authentication (Email/Password + Google Sign-In)
  - Cloud Firestore (database)
  - Firebase AI Logic (Gemini 2.5 Flash — chatbot)
  - Firebase App Check (security, debug mode only)
- **Architecture**: Clean Architecture
- **Version Manager**: FVM (Flutter Version Management)

## 📋 Requirements

- Flutter SDK >= 3.35.0 (stable)
- Dart SDK ^3.11.5
- FVM (recommended)
- Android Studio / Xcode
- `google-services.json` di `android/app/` (Firebase config)

## 🚀 Setup & Run

```bash
# Install dependencies
fvm flutter pub get

# Generate typed assets (FlutterGen)
flutter pub run build_runner build --delete-conflicting-outputs

# Run di device/emulator (debug)
fvm flutter run

# Run di real device (release)
fvm flutter run --release

# Build APK release
fvm flutter build apk --release
```

Output APK: `build/app/outputs/flutter-apk/app-release.apk`

## 📁 Project Structure (Clean Architecture)

```
lib/
├── main.dart                       # Entry point, Firebase init, routing
├── firebase_options.dart           # Firebase configuration (auto-generated)
├── gen/                            # FlutterGen output (typed assets)
└── src/
    ├── core/
    │   └── theme/                  # AppColors, tema aplikasi
    ├── data/
    │   ├── datasource/             # Remote data sources (Firebase)
    │   ├── repositories/           # Repository implementations
    │   └── services/               # Services (TbcChatService, dll)
    ├── domain/
    │   ├── repositories/           # Repository contracts (abstract)
    │   └── usecases/               # Use cases (SignIn, SignOut, dll)
    └── presentation/
        ├── bloc/                   # BLoC (auth, home)
        └── pages/
            ├── auth/               # Login, Register, Forgot Password
            ├── chatbot/            # Chatbot Edukasi TBC (Gemini AI)
            ├── checkin/            # Daily Health Check-in
            ├── facilities/         # Peta Fasilitas Kesehatan
            ├── hamburger/          # Drawer navigation menu
            ├── history/            # Riwayat pengobatan
            ├── home/               # Dashboard + widgets
            ├── meds/               # Tambah obat / medication tracker
            ├── profile/            # Profil pengguna
            └── schedule/           # Jadwal pengobatan
```

## 🔥 Firebase Services

| Service | Kegunaan |
|---------|----------|
| **Firebase Auth** | Autentikasi pengguna (Email + Google) |
| **Cloud Firestore** | Database untuk users, schedules, medication logs |
| **Firebase AI Logic** | Chatbot AI menggunakan Gemini 2.5 Flash |
| **Firebase App Check** | Proteksi API (aktif hanya di debug mode) |

### Chatbot (Firebase AI Logic)

- Model: `gemini-2.5-flash` (free tier: 5 RPM)
- Retry logic otomatis untuk rate limit & server errors
- Status indikator dinamis (Online / Mengetik / Sibuk / Offline)
- App Check di-skip di release mode agar APK sideload berfungsi

### App Check (Release vs Debug)

```
Debug mode  → AndroidDebugProvider (perlu daftarkan debug token di Firebase Console)
Release mode → App Check di-skip (untuk distribusi APK via GitHub/sideload)
```

## 🏗 State Management (BLoC)

- Satu BLoC per fitur utama (Auth, Home)
- Events di `*_event.dart`, States di `*_state.dart`
- UI menggunakan `BlocBuilder` untuk render, `BlocListener` untuk side effects

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
// Image
Assets.icons.lungCareLogo.image(width: 120, height: 120)
// SVG
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
```
