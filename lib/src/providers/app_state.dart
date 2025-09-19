import 'package:flutter/material.dart';

enum AppView { home, consumer, supplier, supplierLogin, chat }

class AppState extends ChangeNotifier {
  AppView _currentView = AppView.home;
  ThemeMode _themeMode = ThemeMode.system;

  AppView get currentView => _currentView;
  ThemeMode get themeMode => _themeMode;

  void setCurrentView(AppView view) {
    _currentView = view;
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}