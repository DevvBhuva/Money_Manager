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
      print('Checking authentication status...');
      await AuthService.debugStoredData(); // Debug stored data
      final isLoggedIn = await AuthService.isLoggedIn();
      print('Is logged in: $isLoggedIn');

      if (isLoggedIn) {
        final user = await AuthService.getCurrentUser();
        print('Current user: ${user?.name} (${user?.email})');

        if (user != null) {
          _currentUser = user;
          _isAuthenticated = true;
          print('User authenticated successfully');
        } else {
          print('User data is null, clearing authentication');
          // User data corrupted, clear authentication
          await AuthService.logout();
          _currentUser = null;
          _isAuthenticated = false;
        }
      } else {
        print('User not logged in');
        _currentUser = null;
        _isAuthenticated = false;
      }
    } catch (e) {
      print('Error in _checkAuthStatus: $e');
      _setError('Failed to check authentication status: ${e.toString()}');
      // Clear authentication on error
      _currentUser = null;
      _isAuthenticated = false;
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      print('Attempting login for: $email');
      final result = await AuthService.login(email, password);
      print('Login result: ${result['success']}');

      if (result['success']) {
        _currentUser = result['user'];
        _isAuthenticated = true;
        print('Login successful for: ${_currentUser?.name}');
      } else {
        print('Login failed: ${result['message']}');
        _setError(result['message'] ?? 'Login failed');
      }

      return result;
    } catch (e) {
      final errorMsg = 'Login failed: ${e.toString()}';
      print('Login error: $errorMsg');
      _setError(errorMsg);
      return {'success': false, 'message': errorMsg};
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
        print('Signup successful for: ${_currentUser?.name}');
      } else {
        print('Signup failed: ${result['message']}');
        _setError(result['message'] ?? 'Signup failed');
      }

      return result;
    } catch (e) {
      final errorMsg = 'Signup failed: ${e.toString()}';
      _setError(errorMsg);
      return {'success': false, 'message': errorMsg};
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> updateUser({
    required String name,
    required String email,
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
      if (_currentUser == null) {
        _setError('No user logged in');
        return {'success': false, 'message': 'No user logged in'};
      }

      final result = await AuthService.updateUser(
        userId: _currentUser!.id,
        name: name,
        email: email,
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
        _setError(result['message'] ?? 'Profile update failed');
      }

      return result;
    } catch (e) {
      final errorMsg = 'Profile update failed: ${e.toString()}';
      _setError(errorMsg);
      return {'success': false, 'message': errorMsg};
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

  // Refresh authentication status (useful for app resume)
  Future<void> refreshAuthStatus() async {
    await _checkAuthStatus();
  }

  // Clear all data and reset app state
  Future<void> clearAllData() async {
    _setLoading(true);
    _clearError();

    try {
      await AuthService.clearAllData();
      _currentUser = null;
      _isAuthenticated = false;
      print('All data cleared and user logged out');
    } catch (e) {
      _setError('Failed to clear data: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Force logout and clear all data (for debugging)
  Future<void> forceLogout() async {
    print('Force logout called');
    await clearAllData();
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
