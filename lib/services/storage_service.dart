import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';
import '../models/group.dart';

class StorageService {
  static const String _expensesKey = 'expenses';
  static const String _groupsKey = 'groups';
  static const String _budgetKey = 'monthly_budget';
  static const String _userExpensesPrefix = 'user_expenses_';
  static const String _userGroupsPrefix = 'user_groups_';
  static const String _userBudgetPrefix = 'user_budget_';

  // Get user-specific key for expenses
  static String _getUserExpensesKey(String userId) => '$_userExpensesPrefix$userId';
  
  // Get user-specific key for groups
  static String _getUserGroupsKey(String userId) => '$_userGroupsPrefix$userId';
  
  // Get user-specific key for budget
  static String _getUserBudgetKey(String userId) => '$_userBudgetPrefix$userId';

  // ========== EXPENSE STORAGE ==========

  /// Save expenses for a specific user
  static Future<void> saveExpenses(String userId, List<Expense> expenses) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expensesJson = expenses.map((e) => e.toJson()).toList();
      await prefs.setString(_getUserExpensesKey(userId), jsonEncode(expensesJson));
    } catch (e) {
      print('Error saving expenses: $e');
    }
  }

  /// Load expenses for a specific user
  static Future<List<Expense>> loadExpenses(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expensesJson = prefs.getString(_getUserExpensesKey(userId));
      
      if (expensesJson != null) {
        final List<dynamic> expensesList = jsonDecode(expensesJson);
        return expensesList.map((json) => Expense.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error loading expenses: $e');
    }
    return [];
  }

  /// Clear expenses for a specific user
  static Future<void> clearExpenses(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_getUserExpensesKey(userId));
    } catch (e) {
      print('Error clearing expenses: $e');
    }
  }

  // ========== GROUP STORAGE ==========

  /// Save groups for a specific user
  static Future<void> saveGroups(String userId, List<Group> groups) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final groupsJson = groups.map((g) => g.toJson()).toList();
      await prefs.setString(_getUserGroupsKey(userId), jsonEncode(groupsJson));
    } catch (e) {
      print('Error saving groups: $e');
    }
  }

  /// Load groups for a specific user
  static Future<List<Group>> loadGroups(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final groupsJson = prefs.getString(_getUserGroupsKey(userId));
      
      if (groupsJson != null) {
        final List<dynamic> groupsList = jsonDecode(groupsJson);
        return groupsList.map((json) => Group.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error loading groups: $e');
    }
    return [];
  }

  /// Clear groups for a specific user
  static Future<void> clearGroups(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_getUserGroupsKey(userId));
    } catch (e) {
      print('Error clearing groups: $e');
    }
  }

  // ========== BUDGET STORAGE ==========

  /// Save monthly budget for a specific user
  static Future<void> saveBudget(String userId, double budget) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_getUserBudgetKey(userId), budget);
    } catch (e) {
      print('Error saving budget: $e');
    }
  }

  /// Load monthly budget for a specific user
  static Future<double> loadBudget(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getDouble(_getUserBudgetKey(userId)) ?? 0.0;
    } catch (e) {
      print('Error loading budget: $e');
      return 0.0;
    }
  }

  /// Clear budget for a specific user
  static Future<void> clearBudget(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_getUserBudgetKey(userId));
    } catch (e) {
      print('Error clearing budget: $e');
    }
  }

  // ========== USER DATA MANAGEMENT ==========

  /// Clear all data for a specific user (useful for logout)
  static Future<void> clearUserData(String userId) async {
    await Future.wait([
      clearExpenses(userId),
      clearGroups(userId),
      clearBudget(userId),
    ]);
  }

  /// Get storage size for debugging
  static Future<Map<String, int>> getStorageInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      int expenseKeys = 0;
      int groupKeys = 0;
      int budgetKeys = 0;
      
      for (final key in keys) {
        if (key.startsWith(_userExpensesPrefix)) expenseKeys++;
        else if (key.startsWith(_userGroupsPrefix)) groupKeys++;
        else if (key.startsWith(_userBudgetPrefix)) budgetKeys++;
      }
      
      return {
        'expense_users': expenseKeys,
        'group_users': groupKeys,
        'budget_users': budgetKeys,
        'total_keys': keys.length,
      };
    } catch (e) {
      print('Error getting storage info: $e');
      return {};
    }
  }

  // ========== MIGRATION HELPERS ==========

  /// Migrate old global data to user-specific data
  static Future<void> migrateToUserSpecific(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Migrate old expenses if they exist
      final oldExpenses = prefs.getString(_expensesKey);
      if (oldExpenses != null) {
        final List<dynamic> expensesList = jsonDecode(oldExpenses);
        final expenses = expensesList.map((json) => Expense.fromJson(json)).toList();
        await saveExpenses(userId, expenses);
        await prefs.remove(_expensesKey);
      }
      
      // Migrate old groups if they exist
      final oldGroups = prefs.getString(_groupsKey);
      if (oldGroups != null) {
        final List<dynamic> groupsList = jsonDecode(oldGroups);
        final groups = groupsList.map((json) => Group.fromJson(json)).toList();
        await saveGroups(userId, groups);
        await prefs.remove(_groupsKey);
      }
      
      // Migrate old budget if it exists
      final oldBudget = prefs.getDouble(_budgetKey);
      if (oldBudget != null) {
        await saveBudget(userId, oldBudget);
        await prefs.remove(_budgetKey);
      }
    } catch (e) {
      print('Error migrating data: $e');
    }
  }
}
