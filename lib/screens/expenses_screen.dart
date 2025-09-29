import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../utils/app_constants.dart';
import '../utils/date_utils.dart';
import '../utils/validation_utils.dart';

class ExpensesScreen extends StatefulWidget {
  final VoidCallback? onAddExpense;

  const ExpensesScreen({super.key, this.onAddExpense});

  @override
  State<ExpensesScreen> createState() => ExpensesScreenState();
}

class ExpensesScreenState extends State<ExpensesScreen> {
  // Use constants from AppConstants
  List<String> get _expenseCategories => AppConstants.expenseCategories;
  List<String> get _incomeCategories => AppConstants.incomeCategories;

  @override
  void initState() {
    super.initState();
    // No default expenses - start with empty list
  }

  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }

  void addExpense() {
    _showAddOptionsDialog();
  }

  void _showAddOptionsDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Transaction'),
            content: Text(
              'Are you sure you want to delete "${expense.title}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final expenseProvider = Provider.of<ExpenseProvider>(
                    context,
                    listen: false,
                  );
                  expenseProvider.deleteExpense(expense.id);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Transaction deleted successfully'),
                    ),
                  );
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _showExpenseDialog({Expense? expense}) {
    final titleController = TextEditingController(text: expense?.title ?? '');
    final amountController = TextEditingController(
      text: expense?.amount.toString() ?? '',
    );
    final descriptionController = TextEditingController(
      text: expense?.description ?? '',
    );
    String? selectedCategory = expense?.category;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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
                      labelText: 'Category *',
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Select category'),
                    items:
                        _expenseCategories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                    onChanged: (value) {
                      selectedCategory = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a category';
                      }
                      return null;
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

                  if (title.isEmpty ||
                      amountText.isEmpty ||
                      selectedCategory == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill all required fields'),
                      ),
                    );
                    return;
                  }

                  final amountError = ValidationUtils.getAmountError(
                    amountText,
                  );
                  if (amountError != null) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(amountError)));
                    return;
                  }

                  final amount = double.parse(amountText);

                  final expenseProvider = Provider.of<ExpenseProvider>(
                    context,
                    listen: false,
                  );

                  if (expense == null) {
                    // Add new expense
                    final newExpense = Expense(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: title,
                      amount: amount,
                      category: selectedCategory!,
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
                      category: selectedCategory!,
                      description: description,
                    );
                    expenseProvider.updateExpense(updatedExpense);
                  }

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        expense == null
                            ? 'Expense added successfully'
                            : 'Expense updated successfully',
                      ),
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
    final amountController = TextEditingController(
      text: expense?.amount.toString() ?? '',
    );
    final descriptionController = TextEditingController(
      text: expense?.description ?? '',
    );
    String? selectedCategory = expense?.category;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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
                      labelText: 'Category *',
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Select category'),
                    items:
                        _incomeCategories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                    onChanged: (value) {
                      selectedCategory = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a category';
                      }
                      return null;
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

                  if (title.isEmpty ||
                      amountText.isEmpty ||
                      selectedCategory == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill all required fields'),
                      ),
                    );
                    return;
                  }

                  final amountError = ValidationUtils.getAmountError(
                    amountText,
                  );
                  if (amountError != null) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(amountError)));
                    return;
                  }

                  final amount = double.parse(amountText);

                  final expenseProvider = Provider.of<ExpenseProvider>(
                    context,
                    listen: false,
                  );

                  if (expense == null) {
                    // Add new income
                    final newIncome = Expense(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: title,
                      amount: amount,
                      category: selectedCategory!,
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
                      category: selectedCategory!,
                      description: description,
                    );
                    expenseProvider.updateExpense(updatedIncome);
                  }

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        expense == null
                            ? 'Income added successfully'
                            : 'Income updated successfully',
                      ),
                    ),
                  );
                },
                child: Text(expense == null ? 'Add' : 'Update'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final expenses = expenseProvider.expenses;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Expenses',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Summary Row
          Padding(
            padding: const EdgeInsets.all(16),
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
                          'Total Expenses',
                          style: TextStyle(fontSize: 12, color: Colors.red),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${expenseProvider.totalExpenses.toStringAsFixed(2)}',
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
                          'Total Income',
                          style: TextStyle(fontSize: 12, color: Colors.green),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${expenseProvider.totalIncome.toStringAsFixed(2)}',
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

          // Transactions List
          Expanded(
            child:
                expenses.isEmpty
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
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tap the + button to add your first transaction',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: expenses.length,
                      itemBuilder: (context, index) {
                        final expense = expenses[index];
                        return _ExpenseListItem(
                          key: ValueKey(expense.id),
                          expense: expense,
                          onEdit: () => _editExpense(expense),
                          onDelete: () => _deleteExpense(expense),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addExpense,
        backgroundColor: const Color(0xFF667eea),
        child: const Icon(Icons.add, color: Colors.white),
      ),
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

class _ExpenseListItem extends StatelessWidget {
  final Expense expense;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ExpenseListItem({
    super.key,
    required this.expense,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = expense.type == 'income';
    final categoryColor =
        isIncome
            ? Colors.green
            : AppConstants.categoryColors[expense.category] ?? Colors.grey;
    final categoryIcon =
        isIncome
            ? Icons.add_circle
            : AppConstants.categoryIcons[expense.category] ?? Icons.receipt;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        dense: true,
        visualDensity: const VisualDensity(vertical: -2),
        minVerticalPadding: 6,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color.fromRGBO(
              categoryColor.red,
              categoryColor.green,
              categoryColor.blue,
              0.1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(categoryIcon, color: categoryColor),
        ),
        title: Text(
          expense.title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(expense.category),
            if (expense.description.isNotEmpty)
              Text(
                expense.description,
                style: const TextStyle(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            Text(
              AppDateUtils.formatDate(expense.date),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: SizedBox(
          height: 36,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${isIncome ? '+' : '-'}${AppDateUtils.formatCurrency(expense.amount)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isIncome ? Colors.green : Colors.red,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 6),
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                iconSize: 18,
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder:
                    (context) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 16),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
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
      ),
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
