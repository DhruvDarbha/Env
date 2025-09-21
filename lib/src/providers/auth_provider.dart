import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isSupplierAuthenticated = false;
  bool _isConsumerAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;
  bool _hasEverUsedApp = false;

  bool get isSupplierAuthenticated => _isSupplierAuthenticated;
  bool get isConsumerAuthenticated => _isConsumerAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;
  bool get hasExistingAuth => _isSupplierAuthenticated || _isConsumerAuthenticated;
  bool get hasEverUsedApp => _hasEverUsedApp;
  bool get shouldShowSplash => _isInitialized && !_hasEverUsedApp;

  Future<void> initializeAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _isSupplierAuthenticated = prefs.getBool('supplier_authenticated') ?? false;
    _isConsumerAuthenticated = prefs.getBool('consumer_authenticated') ?? false;
    _hasEverUsedApp = prefs.getBool('has_ever_used_app') ?? false;
    _isInitialized = true;
    notifyListeners();
  }

  Future<bool> loginSupplier(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await ApiService.loginSupplier(email, password);

      if (success) {
        _isSupplierAuthenticated = true;
        _hasEverUsedApp = true;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('supplier_authenticated', true);
        await prefs.setBool('has_ever_used_app', true);
      } else {
        _errorMessage = 'Invalid credentials. Try villita@env.com / demo123';
      }
    } catch (e) {
      _errorMessage = 'Login failed. Please try again.';
    }

    _isLoading = false;
    notifyListeners();
    return _isSupplierAuthenticated;
  }

  Future<bool> loginConsumer(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await ApiService.loginConsumer(email, password);

      if (success) {
        _isConsumerAuthenticated = true;
        _hasEverUsedApp = true;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('consumer_authenticated', true);
        await prefs.setBool('has_ever_used_app', true);
      } else {
        _errorMessage = 'Invalid credentials. Try james@env.com / demo123';
      }
    } catch (e) {
      _errorMessage = 'Login failed. Please try again.';
    }

    _isLoading = false;
    notifyListeners();
    return _isConsumerAuthenticated;
  }

  Future<void> logout() async {
    _isSupplierAuthenticated = false;
    _isConsumerAuthenticated = false;
    _errorMessage = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('supplier_authenticated', false);
    await prefs.setBool('consumer_authenticated', false);
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> markAppAsUsed() async {
    if (!_hasEverUsedApp) {
      _hasEverUsedApp = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_ever_used_app', true);
      notifyListeners();
    }
  }
}