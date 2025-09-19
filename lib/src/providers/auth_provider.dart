import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isSupplierAuthenticated = false;
  bool _isConsumerAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isSupplierAuthenticated => _isSupplierAuthenticated;
  bool get isConsumerAuthenticated => _isConsumerAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> loginSupplier(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await ApiService.loginSupplier(email, password);

      if (success) {
        _isSupplierAuthenticated = true;
      } else {
        _errorMessage = 'Invalid credentials. Try supplier@freshtrack.com / demo123';
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
      } else {
        _errorMessage = 'Invalid credentials. Try james@savr.com / demo123';
      }
    } catch (e) {
      _errorMessage = 'Login failed. Please try again.';
    }

    _isLoading = false;
    notifyListeners();
    return _isConsumerAuthenticated;
  }

  void logout() {
    _isSupplierAuthenticated = false;
    _isConsumerAuthenticated = false;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}