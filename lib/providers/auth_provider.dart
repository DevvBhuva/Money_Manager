import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    _setLoading(true);
    _clearError();

    try {
      final isLoggedIn = await AuthService.isLoggedIn();
      if (isLoggedIn) {
        _currentUser = await AuthService.getCurrentUser();
        _isAuthenticated = true;
      }
    } catch (e) {
      _setError('Failed to check authentication status: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await AuthService.login(email, password);

      if (result['success']) {
        _currentUser = result['user'];
        _isAuthenticated = true;
      } else {
        _setError(result['message'] ?? 'Login failed');
      }

      return result;
    } catch (e) {
      final errorMsg = 'Login failed: ${e.toString()}';
      _setError(errorMsg);
      return {
        'success': false,
        'message': errorMsg,
      };
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    String? phoneNumber,
    required String roleInFamily,
    required List<FamilyMember> familyMembers,
    required List<Dependency> dependencies,
    required double totalFamilyIncome,
    required List<String> budgetPreferences,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await AuthService.signup(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        phoneNumber: phoneNumber,
        roleInFamily: roleInFamily,
        familyMembers: familyMembers,
        dependencies: dependencies,
        totalFamilyIncome: totalFamilyIncome,
        budgetPreferences: budgetPreferences,
      );

      if (result['success']) {
        _currentUser = result['user'];
        _isAuthenticated = true;
      } else {
        _setError(result['message'] ?? 'Signup failed');
      }

      return result;
    } catch (e) {
      final errorMsg = 'Signup failed: ${e.toString()}';
      _setError(errorMsg);
      return {
        'success': false,
        'message': errorMsg,
      };
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    _clearError();

    try {
      // Clear user data from storage
      if (_currentUser != null) {
        await StorageService.clearUserData(_currentUser!.id);
      }
      
      await AuthService.logout();
      _currentUser = null;
      _isAuthenticated = false;
    } catch (e) {
      _setError('Logout failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods for state management
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  void clearError() {
    _clearError();
  }
} 