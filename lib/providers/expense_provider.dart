import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../services/storage_service.dart';

class ExpenseProvider extends ChangeNotifier {
  final List<Expense> _expenses = [];
  double _monthlyBudget = 0.0; // No default monthly budget
  String? _currentUserId;
  bool _isInitialized = false;
  
  // Cache calculated values to avoid repeated computations
  double? _cachedTotalExpenses;
  double? _cachedTotalIncome;
  double? _cachedRemainingBudget;
  double? _cachedTotalAmount;
  bool _isDirty = true;

  List<Expense> get expenses => List.unmodifiable(_expenses);
  
  double get monthlyBudget => _monthlyBudget;
  
  bool get isInitialized => _isInitialized;
  
  double get totalExpenses {
    if (_isDirty || _cachedTotalExpenses == null) {
      double total = 0.0;
      for (final expense in _expenses) {
        if (expense.type == 'expense') {
          total += expense.amount;
        }
      }
      _cachedTotalExpenses = total;
    }
    return _cachedTotalExpenses!;
  }
  
  double get totalIncome {
    if (_isDirty || _cachedTotalIncome == null) {
      double total = 0.0;
      for (final expense in _expenses) {
        if (expense.type == 'income') {
          total += expense.amount;
        }
      }
      _cachedTotalIncome = total;
    }
    return _cachedTotalIncome!;
  }
  
  double get remainingBudget {
    if (_isDirty || _cachedRemainingBudget == null) {
      _cachedRemainingBudget = _monthlyBudget - totalExpenses + totalIncome;
    }
    return _cachedRemainingBudget!;
  }
  
  double get totalAmount {
    if (_isDirty || _cachedTotalAmount == null) {
      _cachedTotalAmount = totalExpenses - totalIncome; // Net spending
    }
    return _cachedTotalAmount!;
  }

  // ========== INITIALIZATION ==========
  
  /// Initialize the provider with user data
  Future<void> initialize(String userId) async {
    if (_currentUserId == userId && _isInitialized) return;
    
    _currentUserId = userId;
    
    try {
      // Load expenses and budget from storage
      final loadedExpenses = await StorageService.loadExpenses(userId);
      final loadedBudget = await StorageService.loadBudget(userId);
      
      _expenses.clear();
      _expenses.addAll(loadedExpenses);
      _monthlyBudget = loadedBudget;
      
      _markDirty();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Error initializing ExpenseProvider: $e');
      _isInitialized = true; // Mark as initialized even if loading failed
    }
  }
  
  /// Clear all data (useful for logout)
  Future<void> clearData() async {
    _expenses.clear();
    _monthlyBudget = 0.0;
    _currentUserId = null;
    _isInitialized = false;
    _markDirty();
    notifyListeners();
  }

  // ========== BUDGET MANAGEMENT ==========

  void setMonthlyBudget(double budget) {
    if (_monthlyBudget != budget) {
      _monthlyBudget = budget;
      _markDirty();
      _saveBudget();
      notifyListeners();
    }
  }
  
  Future<void> _saveBudget() async {
    if (_currentUserId != null) {
      await StorageService.saveBudget(_currentUserId!, _monthlyBudget);
    }
  }

  // ========== EXPENSE MANAGEMENT ==========

  void addExpense(Expense expense) {
    _expenses.insert(0, expense);
    _markDirty();
    _saveExpenses();
    notifyListeners();
  }

  void updateExpense(Expense expense) {
    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _expenses[index] = expense;
      _markDirty();
      _saveExpenses();
      notifyListeners();
    }
  }

  void deleteExpense(String expenseId) {
    final initialLength = _expenses.length;
    _expenses.removeWhere((e) => e.id == expenseId);
    final removed = _expenses.length < initialLength;
    if (removed) {
      _markDirty();
      _saveExpenses();
      notifyListeners();
    }
  }

  void clearExpenses() {
    if (_expenses.isNotEmpty) {
      _expenses.clear();
      _markDirty();
      _saveExpenses();
      notifyListeners();
    }
  }
  
  Future<void> _saveExpenses() async {
    if (_currentUserId != null) {
      await StorageService.saveExpenses(_currentUserId!, _expenses);
    }
  }

  // Helper method to mark cache as dirty
  void _markDirty() {
    _isDirty = true;
    _cachedTotalExpenses = null;
    _cachedTotalIncome = null;
    _cachedRemainingBudget = null;
    _cachedTotalAmount = null;
  }

  // Get expenses by type for better performance
  List<Expense> getExpensesByType(String type) {
    return _expenses.where((expense) => expense.type == type).toList();
  }

  // Get expenses by category for better performance
  List<Expense> getExpensesByCategory(String category) {
    return _expenses.where((expense) => expense.category == category).toList();
  }

  // Get recent expenses (last N days)
  List<Expense> getRecentExpenses(int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return _expenses.where((expense) => expense.date.isAfter(cutoffDate)).toList();
  }
} 