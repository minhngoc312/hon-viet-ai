import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalAccount {
  final String name;
  final String email;
  final String phone;
  final String country;
  final String bio;

  const LocalAccount({
    required this.name,
    required this.email,
    this.phone = '',
    this.country = '',
    this.bio = '',
  });
}

class AppSettingsService {
  static const String _themeKey = 'hon_viet_theme_mode';
  static const String _nameKey = 'hon_viet_account_name';
  static const String _emailKey = 'hon_viet_account_email';
  static const String _phoneKey = 'hon_viet_account_phone';
  static const String _countryKey = 'hon_viet_account_country';
  static const String _bioKey = 'hon_viet_account_bio';
  static const String _notificationEnabledKey =
      'hon_viet_notifications_enabled';

  static Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_themeKey);

    switch (saved) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();

    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };

    await prefs.setString(_themeKey, value);
  }

  static Future<LocalAccount?> loadAccount() async {
    final prefs = await SharedPreferences.getInstance();

    final name = prefs.getString(_nameKey)?.trim() ?? '';
    final email = prefs.getString(_emailKey)?.trim() ?? '';

    if (name.isEmpty || email.isEmpty) {
      return null;
    }

    return LocalAccount(
      name: name,
      email: email,
      phone: prefs.getString(_phoneKey)?.trim() ?? '',
      country: prefs.getString(_countryKey)?.trim() ?? '',
      bio: prefs.getString(_bioKey)?.trim() ?? '',
    );
  }

  static Future<void> saveAccount({
    required String name,
    required String email,
    String phone = '',
    String country = '',
    String bio = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_nameKey, name.trim());
    await prefs.setString(_emailKey, email.trim());
    await prefs.setString(_phoneKey, phone.trim());
    await prefs.setString(_countryKey, country.trim());
    await prefs.setString(_bioKey, bio.trim());
  }

  static Future<void> clearAccount() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_nameKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_phoneKey);
    await prefs.remove(_countryKey);
    await prefs.remove(_bioKey);
  }

  static Future<bool> loadNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(_notificationEnabledKey) ?? true;
  }

  static Future<void> saveNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_notificationEnabledKey, enabled);
  }
}
