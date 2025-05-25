import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    loadThemeMode();
  }

  void loadThemeMode() async {
    final box = await Hive.openBox('settings');
    String mode = box.get('themeMode', defaultValue: 'system');
    _themeMode = _stringToThemeMode(mode);
    notifyListeners();
  }

  void toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    final box = await Hive.openBox('settings');
    await box.put('themeMode', isDark ? 'dark' : 'light');
    notifyListeners();
  }

  ThemeMode _stringToThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
