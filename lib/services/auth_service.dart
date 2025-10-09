import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _usersDatabaseKey = 'users_database';

  // Simulated user database for demo purposes - now persisted
  static Map<String, Map<String, dynamic>> _users = {};

  // Initialize the users database from storage
  static Future<void> _initializeUsersDatabase() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersDatabaseKey);
      
      if (usersJson != null) {
        final Map<String, dynamic> usersMap = jsonDecode(usersJson);
        _users = usersMap.map((key, value) => MapEntry(key, Map<String, dynamic>.from(value)));
      } else {
        // Initialize with demo user if no database exists
        _users = {
          'demo@example.com': {
            'password': 'password123',
            'name': 'Demo User',
            'id': '1',
            'email': 'demo@example.com',
            'phoneNumber': '+1234567890',
            'createdAt': DateTime.now().toIso8601String(),
            'roleInFamily': 'Individual',
            'familyMembers': [],
            'dependencies': [],
            'totalFamilyIncome': 0.0,
            'budgetPreferences': [],
          },
        };
        await _saveUsersDatabase();
      }
    } catch (e) {
      print('Error initializing users database: $e');
      // Fallback to demo user only
      _users = {
        'demo@example.com': {
          'password': 'password123',
          'name': 'Demo User',
          'id': '1',
          'email': 'demo@example.com',
          'phoneNumber': '+1234567890',
          'createdAt': DateTime.now().toIso8601String(),
          'roleInFamily': 'Individual',
          'familyMembers': [],
          'dependencies': [],
          'totalFamilyIncome': 0.0,
          'budgetPreferences': [],
        },
      };
    }
  }

  // Save the users database to storage
  static Future<void> _saveUsersDatabase() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_usersDatabaseKey, jsonEncode(_users));
    } catch (e) {
      print('Error saving users database: $e');
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      await _initializeUsersDatabase();
      final token = await _secureStorage.read(key: _tokenKey);
      return token != null;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  // Get current user
  static Future<User?> getCurrentUser() async {
    try {
      await _initializeUsersDatabase();
      final userJson = await _secureStorage.read(key: _userKey);
      if (userJson != null) {
        return User.fromJson(jsonDecode(userJson));
      }
      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // Login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // Initialize users database if not already done
      await _initializeUsersDatabase();
      
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
      // Initialize users database if not already done
      await _initializeUsersDatabase();
      
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
      
      // Save the updated database
      await _saveUsersDatabase();

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

  // Update user profile
  static Future<Map<String, dynamic>> updateUser({
    required String userId,
    required String name,
    required String email,
    String? phoneNumber,
    required String roleInFamily,
    required List<FamilyMember> familyMembers,
    required List<Dependency> dependencies,
    required double totalFamilyIncome,
    required List<String> budgetPreferences,
  }) async {
    try {
      // Initialize users database if not already done
      await _initializeUsersDatabase();
      
      // Find the user by ID
      String? userEmail;
      for (final entry in _users.entries) {
        if (entry.value['id'] == userId) {
          userEmail = entry.key;
          break;
        }
      }
      
      if (userEmail == null) {
        return {
          'success': false,
          'message': 'User not found.',
        };
      }

      // Update user data
      final userData = {
        'id': userId,
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'createdAt': _users[userEmail]!['createdAt'], // Keep original creation date
        'password': _users[userEmail]!['password'], // Keep original password
        'roleInFamily': roleInFamily,
        'familyMembers': familyMembers.map((member) => member.toJson()).toList(),
        'dependencies': dependencies.map((dep) => dep.toJson()).toList(),
        'totalFamilyIncome': totalFamilyIncome,
        'budgetPreferences': budgetPreferences,
      };

      // Update in database
      _users[userEmail] = userData;
      
      // If email changed, update the key
      if (userEmail != email) {
        _users[email] = userData;
        _users.remove(userEmail);
      }
      
      // Save the updated database
      await _saveUsersDatabase();

      // Create updated user object
      final user = User.fromJson(userData);

      // Update stored authentication data
      await _secureStorage.write(key: _userKey, value: jsonEncode(user.toJson()));

      return {
        'success': true,
        'message': 'Profile updated successfully!',
        'user': user,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred while updating profile. Please try again.',
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