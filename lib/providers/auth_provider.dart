import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  bool _isAuthenticated = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;

  AuthProvider() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    final isLoggedIn = await AuthService.isLoggedIn();
    if (isLoggedIn) {
      _currentUser = await AuthService.getCurrentUser();
      _isAuthenticated = true;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final result = await AuthService.login(email, password);

    if (result['success']) {
      _currentUser = result['user'];
      _isAuthenticated = true;
    }

    _isLoading = false;
    notifyListeners();

    return result;
  }

  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    String? phoneNumber,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await AuthService.signup(
      name: name,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      phoneNumber: phoneNumber,
    );

    if (result['success']) {
      _currentUser = result['user'];
      _isAuthenticated = true;
    }

    _isLoading = false;
    notifyListeners();

    return result;
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await AuthService.logout();
    _currentUser = null;
    _isAuthenticated = false;

    _isLoading = false;
    notifyListeners();
  }
} 