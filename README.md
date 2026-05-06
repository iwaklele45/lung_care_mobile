# LungCare+

Mobile app for monitoring pendampingan obat.

## Requirements

- Flutter SDK (stable)
- Dart SDK (see pubspec.yaml)
- Android Studio or Xcode (for emulator/device)

## Setup

```bash
fvm flutter pub get
```

## Run

```bash
fvm flutter run
```

## Project Structure (Clean Architecture)

```
lib/
	features/
		<feature>/
			data/
			domain/
			presentation/
	src/
		core/
			theme/
		presentation/
			bloc/
	gen/
```

## FlutterGen (Assets)

This project uses FlutterGen to generate typed asset accessors.

### Add new asset

1. Put the asset under `assets/` (for example `assets/icons/`).
2. Ensure the folder is listed in `pubspec.yaml` under `flutter/assets`.
3. Run build_runner to regenerate:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Use asset in code

```dart
Assets.icons.lungCareLogo.image(width: 120, height: 120)
```

If you add SVGs, make sure `flutter_svg` is already enabled (it is) and use:

```dart
Assets.icons.logoApp.svg(width: 120, height: 120)
```

## Firebase

Firebase integration will be used for authentication, analytics, and storage.
When adding Firebase:

1. Add `firebase_core` and other required packages.
2. Configure Android/iOS using the official Firebase setup guide.
3. Initialize Firebase in `main.dart` before `runApp`.

## State Management (BLoC)

This project uses `flutter_bloc`.

Guidelines:

- Keep events in `auth_event.dart` and states in `auth_state.dart`.
- Use a dedicated BLoC per feature (Auth, Home, Profile, etc.).
- UI listens to state changes with `BlocBuilder` and handles one-off actions
	with `BlocListener`.

Example usage:

```dart
BlocListener<AuthBloc, AuthState>(
	listener: (context, state) {
		if (state is AuthAuthenticated) {
			context.go('/home');
		}
	},
	child: const SplashPage(),
)
```

## Flutter State Management (Overview)

Flutter state management separates UI rendering from app logic and data flow.
In this project we use BLoC to keep state predictable and testable.

Core ideas:

- UI is a function of state; widgets rebuild when state changes.
- Events trigger logic inside BLoC, which emits new states.
- Side effects (navigation, snackbars) are handled in listeners, not builders.

When to use:

- Use BLoC for feature-level state that is shared by multiple widgets.
- Use local widget state for small, isolated UI interactions.

## Clean Architecture (Overview)

Clean Architecture organizes code by responsibility and dependency direction.
Dependencies should point inward: presentation -> domain -> data.

Layers:

- Presentation: UI, BLoC, pages, widgets.
- Domain: entities, use cases, repository contracts.
- Data: repository implementations, remote/local datasources, models.

Rules of thumb:

- Domain has no Flutter imports.
- Data depends on Domain, not the other way around.
- Presentation depends on Domain and triggers use cases through BLoC.

## Useful Commands

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter pub run build_runner watch --delete-conflicting-outputs
```
