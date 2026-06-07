import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lung_care_mobile/src/core/locale/locale_provider.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockPrefs = MockSharedPreferences();
  });

  group('LocaleProvider', () {
    test('defaults to Indonesian locale when no saved preference', () async {
      when(() => mockPrefs.getString(any())).thenReturn(null);

      SharedPreferences.setMockInitialValues({});

      final provider = LocaleProvider();

      // Wait for _loadSavedLocale to complete
      await Future<void>.delayed(Duration.zero);

      expect(provider.locale, const Locale('id'));
    });

    test('loads saved locale from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({'app_language': 'en'});

      final provider = LocaleProvider();

      await Future<void>.delayed(Duration.zero);

      expect(provider.locale, const Locale('en'));
    });

    test('setLocale changes locale and notifies listeners', () async {
      SharedPreferences.setMockInitialValues({});

      final provider = LocaleProvider();
      await Future<void>.delayed(Duration.zero);

      var notified = false;
      provider.addListener(() => notified = true);

      await provider.setLocale(const Locale('en'));

      expect(provider.locale, const Locale('en'));
      expect(notified, true);
    });

    test('setLocale persists to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});

      final provider = LocaleProvider();
      await Future<void>.delayed(Duration.zero);

      final prefs = await SharedPreferences.getInstance();

      await provider.setLocale(const Locale('en'));

      expect(prefs.getString('app_language'), 'en');
    });

    test('setLocale does nothing if locale is same', () async {
      SharedPreferences.setMockInitialValues({'app_language': 'id'});

      final provider = LocaleProvider();
      await Future<void>.delayed(Duration.zero);

      var notified = false;
      provider.addListener(() => notified = true);

      await provider.setLocale(const Locale('id'));

      expect(notified, false);
    });

    test('can change locale multiple times', () async {
      SharedPreferences.setMockInitialValues({});

      final provider = LocaleProvider();
      await Future<void>.delayed(Duration.zero);

      await provider.setLocale(const Locale('en'));
      expect(provider.locale, const Locale('en'));

      await provider.setLocale(const Locale('id'));
      expect(provider.locale, const Locale('id'));

      await provider.setLocale(const Locale('en'));
      expect(provider.locale, const Locale('en'));
    });

    test('initializes with notifyListeners after loading', () async {
      SharedPreferences.setMockInitialValues({'app_language': 'en'});

      var notified = false;
      final provider = LocaleProvider();
      provider.addListener(() => notified = true);

      await Future<void>.delayed(Duration.zero);

      expect(notified, true);
    });
  });
}
