import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';

class AuthService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Simulated user database for demo purposes
  static final Map<String, Map<String, dynamic>> _users = {
    'demo@example.com': {
      'password': 'password123',
      'name': 'Demo User',
      'id': '1',
      'email': 'demo@example.com',
      'phoneNumber': '+1234567890',
      'createdAt': DateTime.now().toIso8601String(),
    },
  };

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await _secureStorage.read(key: _tokenKey);
    return token != null;
  }

  // Get current user
  static Future<User?> getCurrentUser() async {
    final userJson = await _secureStorage.read(key: _userKey);
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  // Login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));

      // Check if user exists
      if (!_users.containsKey(email)) {
        return {
          'success': false,
          'message': 'User not found. Please check your email.',
        };
      }

      final userData = _users[email]!;
      if (userData['password'] != password) {
        return {
          'success': false,
          'message': 'Invalid password. Please try again.',
        };
      }

      // Create user object
      final user = User.fromJson(userData);

      // Store authentication data
      final token = _generateToken();
      await _secureStorage.write(key: _tokenKey, value: token);
      await _secureStorage.write(key: _userKey, value: jsonEncode(user.toJson()));

      return {
        'success': true,
        'message': 'Login successful!',
        'user': user,
        'token': token,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred. Please try again.',
      };
    }
  }

  // Signup
  static Future<Map<String, dynamic>> signup({
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
    try {
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));

      // Check if user already exists
      if (_users.containsKey(email)) {
        return {
          'success': false,
          'message': 'User with this email already exists.',
        };
      }

      // Validate password confirmation
      if (password != confirmPassword) {
        return {
          'success': false,
          'message': 'Passwords do not match.',
        };
      }

      // Create new user
      final userId = DateTime.now().millisecondsSinceEpoch.toString();
      final userData = {
        'id': userId,
        'name': name,
        'email': email,
        'password': password,
        'phoneNumber': phoneNumber,
        'createdAt': DateTime.now().toIso8601String(),
        'roleInFamily': roleInFamily,
        'familyMembers': familyMembers.map((member) => member.toJson()).toList(),
        'dependencies': dependencies.map((dep) => dep.toJson()).toList(),
        'totalFamilyIncome': totalFamilyIncome,
        'budgetPreferences': budgetPreferences,
      };

      // Add to simulated database
      _users[email] = userData;

      // Create user object
      final user = User.fromJson(userData);

      // Store authentication data
      final token = _generateToken();
      await _secureStorage.write(key: _tokenKey, value: token);
      await _secureStorage.write(key: _userKey, value: jsonEncode(user.toJson()));

      return {
        'success': true,
        'message': 'Account created successfully!',
        'user': user,
        'token': token,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred. Please try again.',
      };
    }
  }

  // Logout
  static Future<void> logout() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _userKey);
  }

  // Generate a simple token (in real app, this would be from server)
  static String _generateToken() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Validate email format
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Validate password strength
  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  // Validate name
  static bool isValidName(String name) {
    return name.trim().length >= 2;
  }
} 