# AGENTS.md

## Quick start
- Use FVM for Flutter commands: `fvm flutter pub get`, `fvm flutter run`.
- Dart SDK constraint: `sdk: ^3.11.5` in `pubspec.yaml` (Flutter SDK >= 3.35.0 from `pubspec.lock`).

## Codegen (FlutterGen)
- Assets live under `assets/` and must be listed in `pubspec.yaml` before regeneration.
- Regenerate typed assets with: `flutter pub run build_runner build --delete-conflicting-outputs`.
- Generated output goes to `lib/gen/`.

## Structure
- Clean Architecture layout under `lib/` with `features/<feature>/{data,domain,presentation}` and shared code in `lib/src/`.
- Ensure all new features from the Roadmap follow this separation of concerns.

## Linting
- Lints come from `analysis_options.yaml` (includes `package:flutter_lints/flutter.yaml`).

---

## Project Roadmap & Backlog (Tugas Akhir)

The AI Agent must reference this roadmap to understand the current context and upcoming features. When generating code, ensure it aligns with the goals of the current active week.

### Week 1: Foundation & Authentication
- **Config**: Project setup, ensure FVM is used on all devices.
- **Firebase Setup**: Initialize Firestore collections (`users`, `medication_logs`, `schedules`, `reservations`).
- **Auth Module**: Integrate Firebase SDK Authentication.
- **UI/UX**: Implement UI for Login, Register, and Forgot Password (placed in `features/auth/presentation`).

### Week 2: Core Patient Features & Notifications
- **Patient Dashboard**: Implement real-time fetching from Firestore to display the medication schedule cards on the Home Page (`features/schedules`).
- **FCM**: Implement Firebase Cloud Messaging for push notifications so the patient's device rings when it's time to take medication.

### Week 3: History, Management & Tracking
- **History & Adherence**: Create a "View All" history page and an adherence calendar UI.
- **Schedule Management**: Implement full CRUD operations for medication schedules.
- **Health Check-in**: Build the Daily Health Check-in (Symptom Tracker) UI and integrate symptom data with Firestore (`features/health_tracking`).

### Week 4: Advanced Integration (GIS & Chatbot)
- **Maps (GIS)**: Implement healthcare facility maps using Google Maps SDK in Flutter.
- **Chatbot**: Integrate a simple chatbot feature using either conversation logic or Gemini/OpenAI API.

### Week 5: Polishing, Deployment & Finalization
- **UI/UX Polish**: Refine padding, colors, and responsiveness (specifically fix the Figma navbar alignment issue).
- **Deployment**: Host Web Admin (via Firebase Hosting) and build the final Flutter APK for demo purposes.
- **Documentation**: Finalize UI for Tugas Akhir slide presentation screenshots.