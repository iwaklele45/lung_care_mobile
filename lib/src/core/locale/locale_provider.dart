import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A simple ChangeNotifier that persists the user's chosen locale
/// via SharedPreferences and exposes it for MaterialApp.
class LocaleProvider extends ChangeNotifier {
  LocaleProvider() {
    _loadSavedLocale();
  }

  static const _key = 'app_language';

  Locale _locale = const Locale('id');
  Locale get locale => _locale;

  /// Load saved locale from SharedPreferences.
  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key) ?? 'id';
    _locale = Locale(code);
    notifyListeners();
  }

  /// Change locale and persist the choice.
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.languageCode);
  }
}
