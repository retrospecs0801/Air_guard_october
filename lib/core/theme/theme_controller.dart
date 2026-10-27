import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  static const String _preferenceKey = 'theme_mode';

  final SharedPreferences _preferences;
  ThemeMode _themeMode;

  ThemeController._(this._preferences, this._themeMode);

  ThemeMode get themeMode => _themeMode;

  static Future<ThemeController> load() async {
    final preferences = await SharedPreferences.getInstance();
    final savedMode = preferences.getString(_preferenceKey);
    final mode = ThemeMode.values.firstWhere(
      (candidate) => candidate.name == savedMode,
      orElse: () => ThemeMode.system,
    );
    return ThemeController._(preferences, mode);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
    await _preferences.setString(_preferenceKey, mode.name);
  }
}
