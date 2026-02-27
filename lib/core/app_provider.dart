import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider extends ChangeNotifier {
  // ── Theme Mode (dark / light / system) ─────────────────────────────────────
  String _themeMode = 'light'; // 'light', 'dark', 'system'
  String get themeModeName => _themeMode;

  ThemeMode get themeMode {
    switch (_themeMode) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }

  bool get isDarkMode => _themeMode == 'dark';

  // ── Language ───────────────────────────────────────────────────────────────
  String _language = 'en';
  String get language => _language;
  Locale get locale => Locale(_language);

  // ── Auto Brightness (light sensor) ────────────────────────────────────────
  bool _autoBrightness = false;
  bool get autoBrightness => _autoBrightness;

  // ── Initialize from SharedPreferences ──────────────────────────────────────
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = prefs.getString('theme_mode') ?? 'light';
    _language = prefs.getString('language') ?? 'en';
    _autoBrightness = prefs.getBool('auto_brightness') ?? false;
    notifyListeners();
  }

  // ── Set Theme Mode ────────────────────────────────────────────────────────
  Future<void> setThemeMode(String mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode);
  }

  // ── Toggle Dark Mode (backward compat) ────────────────────────────────────
  Future<void> toggleDarkMode(bool value) async {
    await setThemeMode(value ? 'dark' : 'light');
  }

  // ── Set Language ──────────────────────────────────────────────────────────
  Future<void> setLanguage(String lang) async {
    _language = lang;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
  }

  // ── Toggle Auto Brightness ────────────────────────────────────────────────
  Future<void> toggleAutoBrightness(bool value) async {
    _autoBrightness = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_brightness', value);
  }
}
