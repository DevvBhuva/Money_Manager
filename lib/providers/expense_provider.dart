import 'package:flutter/foundation.dart';
import '../models/expense.dart';

class ExpenseProvider extends ChangeNotifier {
  final List<Expense> _expenses = [];

  List<Expense> get expenses => List.unmodifiable(_expenses);

  double get totalAmount => _expenses.fold(0.0, (sum, expense) => sum + expense.amount);

  void addExpense(Expense expense) {
    _expenses.insert(0, expense);
    notifyListeners();
  }

  void updateExpense(Expense expense) {
    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _expenses[index] = expense;
      notifyListeners();
    }
  }

  void deleteExpense(String expenseId) {
    _expenses.removeWhere((e) => e.id == expenseId);
    notifyListeners();
  }

  void clearExpenses() {
    _expenses.clear();
    notifyListeners();
  }
} 