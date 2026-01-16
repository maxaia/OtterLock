import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service de gestion du thème (dark/light mode)
class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'is_dark_mode';
  
  SharedPreferences? _prefs;
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  /// Initialise le service et charge la préférence sauvegardée
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _isDarkMode = _prefs?.getBool(_themeKey) ?? false;
    notifyListeners();
  }

  /// Bascule entre le mode sombre et clair
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _prefs?.setBool(_themeKey, _isDarkMode);
    notifyListeners();
  }

  /// Définit le mode sombre
  Future<void> setDarkMode(bool value) async {
    if (_isDarkMode == value) return;
    _isDarkMode = value;
    await _prefs?.setBool(_themeKey, _isDarkMode);
    notifyListeners();
  }
}
