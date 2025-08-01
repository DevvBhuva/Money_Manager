import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../providers/auth_provider.dart';
import '../providers/expense_provider.dart';

class ExpensesScreen extends StatefulWidget {
  final VoidCallback? onAddExpense;
  
  const ExpensesScreen({super.key, this.onAddExpense});

  @override
  State<ExpensesScreen> createState() => ExpensesScreenState();
}

class ExpensesScreenState extends State<ExpensesScreen> {
  final List<String> _expenseCategories = [
    'Food & Dining',
    'Transportation',
    'Shopping',
    'Entertainment',
    'Healthcare',
    'Education',
    'Utilities',
    'Rent',
    'Insurance',
    'Other'
  ];

  final List<String> _incomeCategories = [
    'Salary',
    'Freelance',
    'Investment',
    'Gift',
    'Refund',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    // No default expenses - start with empty list
  }

  void addExpense() {
    _showAddOptionsDialog();
  }

  void _showAddOptionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Transaction'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.remove_circle, color: Colors.red),
              title: const Text('Add Expense'),
              subtitle: const Text('Money spent'),
              onTap: () {
                Navigator.pop(context);
                _showExpenseDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_circle, color: Colors.green),
              title: const Text('Add Income'),
              subtitle: const Text('Money received'),
              onTap: () {
                Navigator.pop(context);
                _showIncomeDialog();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _editExpense(Expense expense) {
    if (expense.type == 'income') {
      _showIncomeDialog(expense: expense);
    } else {
      _showExpenseDialog(expense: expense);
    }
  }

  void _deleteExpense(Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: Text('Are you sure you want to delete "${expense.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
              expenseProvider.deleteExpense(expense.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Transaction deleted successfully')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showExpenseDialog({Expense? expense}) {
    final titleController = TextEditingController(text: expense?.title ?? '');
    final amountController = TextEditingController(text: expense?.amount.toString() ?? '');
    final descriptionController = TextEditingController(text: expense?.description ?? '');
    String selectedCategory = expense?.category ?? _expenseCategories[0];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(expense == null ? 'Add Expense' : 'Edit Expense'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                  prefixText: '₹',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _expenseCategories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedCategory = value!;
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              final amountText = amountController.text.trim();
              final description = descriptionController.text.trim();

              if (title.isEmpty || amountText.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all required fields')),
                );
                return;
              }

              final amount = double.tryParse(amountText);
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid amount')),
                );
                return;
              }

              final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);

              if (expense == null) {
                // Add new expense
                final newExpense = Expense(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: title,
                  amount: amount,
                  category: selectedCategory,
                  description: description,
                  date: DateTime.now(),
                  userId: '1',
                  type: 'expense',
                );
                expenseProvider.addExpense(newExpense);
              } else {
                // Edit existing expense
                final updatedExpense = expense.copyWith(
                  title: title,
                  amount: amount,
                  category: selectedCategory,
                  description: description,
                );
                expenseProvider.updateExpense(updatedExpense);
              }

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(expense == null ? 'Expense added successfully' : 'Expense updated successfully'),
                ),
              );
            },
            child: Text(expense == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _showIncomeDialog({Expense? expense}) {
    final titleController = TextEditingController(text: expense?.title ?? '');
    final amountController = TextEditingController(text: expense?.amount.toString() ?? '');
    final descriptionController = TextEditingController(text: expense?.description ?? '');
    String selectedCategory = expense?.category ?? _incomeCategories[0];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(expense == null ? 'Add Income' : 'Edit Income'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                  prefixText: '₹',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _incomeCategories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedCategory = value!;
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              final amountText = amountController.text.trim();
              final description = descriptionController.text.trim();

              if (title.isEmpty || amountText.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all required fields')),
                );
                return;
              }

              final amount = double.tryParse(amountText);
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid amount')),
                );
                return;
              }

              final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);

              if (expense == null) {
                // Add new income
                final newIncome = Expense(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: title,
                  amount: amount,
                  category: selectedCategory,
                  description: description,
                  date: DateTime.now(),
                  userId: '1',
                  type: 'income',
                );
                expenseProvider.addExpense(newIncome);
              } else {
                // Edit existing income
                final updatedIncome = expense.copyWith(
                  title: title,
                  amount: amount,
                  category: selectedCategory,
                  description: description,
                );
                expenseProvider.updateExpense(updatedIncome);
              }

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(expense == null ? 'Income added successfully' : 'Income updated successfully'),
                ),
              );
            },
            child: Text(expense == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _showBudgetDialog() {
    final budgetController = TextEditingController(
      text: Provider.of<ExpenseProvider>(context, listen: false).monthlyBudget.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Monthly Budget'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: budgetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Monthly Budget',
                border: OutlineInputBorder(),
                prefixText: '₹',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final budgetText = budgetController.text.trim();
              final budget = double.tryParse(budgetText);

              if (budget == null || budget <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid budget amount')),
                );
                return;
              }

              final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
              expenseProvider.setMonthlyBudget(budget);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Monthly budget updated successfully')),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final user = authProvider.currentUser;
    final expenses = expenseProvider.expenses;
    final monthlyBudget = expenseProvider.monthlyBudget;
    final totalExpenses = expenseProvider.totalExpenses;
    final totalIncome = expenseProvider.totalIncome;
    final remainingBudget = expenseProvider.remainingBudget;

    return Column(
      children: [
        // Budget Cards
        Container(
          margin: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Monthly Budget Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Monthly Budget',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${monthlyBudget.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _showBudgetDialog,
                      icon: const Icon(Icons.edit, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Balance Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: remainingBudget >= 0 
                        ? [Colors.green.shade400, Colors.green.shade600]
                        : [Colors.red.shade400, Colors.red.shade600],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Remaining Budget',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${remainingBudget.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        remainingBudget >= 0 ? Icons.trending_up : Icons.trending_down,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Summary Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Column(
                    children: [
                                             const Text(
                         'Debit',
                         style: TextStyle(
                           fontSize: 12,
                           color: Colors.red,
                         ),
                       ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${totalExpenses.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    children: [
                                             const Text(
                         'Credit',
                         style: TextStyle(
                           fontSize: 12,
                           color: Colors.green,
                         ),
                       ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${totalIncome.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Transactions List
        Expanded(
          child: expenses.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No transactions yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tap the + button to add your first transaction',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    final isIncome = expense.type == 'income';
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: (isIncome ? Colors.green : _getCategoryColor(expense.category)).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isIncome ? Icons.add_circle : _getCategoryIcon(expense.category),
                            color: isIncome ? Colors.green : _getCategoryColor(expense.category),
                          ),
                        ),
                        title: Text(
                          expense.title,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(expense.category),
                            if (expense.description.isNotEmpty)
                              Text(
                                expense.description,
                                style: const TextStyle(fontSize: 12),
                              ),
                            Text(
                              _formatDate(expense.date),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${isIncome ? '+' : '-'}₹${expense.amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isIncome ? Colors.green : Colors.red,
                                fontSize: 16,
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _editExpense(expense);
                                } else if (value == 'delete') {
                                  _deleteExpense(expense);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 16),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, size: 16, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Delete', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food & Dining':
        return Colors.orange;
      case 'Transportation':
        return Colors.blue;
      case 'Shopping':
        return Colors.purple;
      case 'Entertainment':
        return Colors.pink;
      case 'Healthcare':
        return Colors.red;
      case 'Education':
        return Colors.green;
      case 'Utilities':
        return Colors.teal;
      case 'Rent':
        return Colors.indigo;
      case 'Insurance':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food & Dining':
        return Icons.restaurant;
      case 'Transportation':
        return Icons.directions_car;
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Entertainment':
        return Icons.movie;
      case 'Healthcare':
        return Icons.medical_services;
      case 'Education':
        return Icons.school;
      case 'Utilities':
        return Icons.power;
      case 'Rent':
        return Icons.home;
      case 'Insurance':
        return Icons.security;
      default:
        return Icons.receipt;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
} 