import 'package:flutter/foundation.dart';
import '../models/expense.dart';

class ExpenseProvider extends ChangeNotifier {
  final List<Expense> _expenses = [];
  double _monthlyBudget = 0.0; // No default monthly budget

  List<Expense> get expenses => List.unmodifiable(_expenses);
  
  double get monthlyBudget => _monthlyBudget;
  
  double get totalExpenses => _expenses
      .where((expense) => expense.type == 'expense')
      .fold(0.0, (sum, expense) => sum + expense.amount);
  
  double get totalIncome => _expenses
      .where((expense) => expense.type == 'income')
      .fold(0.0, (sum, expense) => sum + expense.amount);
  
  double get remainingBudget => _monthlyBudget - totalExpenses + totalIncome;
  
  double get totalAmount => totalExpenses - totalIncome; // Net spending

  void setMonthlyBudget(double budget) {
    _monthlyBudget = budget;
    notifyListeners();
  }

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