import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/group_provider.dart';
import '../models/expense.dart';
import '../utils/app_constants.dart';
import '../utils/validation_utils.dart';
import 'expenses_screen.dart';
import 'groups_screen.dart';
import 'tracker_screen.dart';
import 'login_screen.dart';
import 'settings_screen.dart';
import '../utils/date_utils.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ExpensesScreenState> _expensesKey =
      GlobalKey<ExpensesScreenState>();
  final GlobalKey<GroupsScreenState> _groupsKey =
      GlobalKey<GroupsScreenState>();

  @override
  void initState() {
    super.initState();
    // No need for multiple screens since we're using navigation
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // No need to update screens
  }

  Widget _buildDashboardHome() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          _buildWelcomeSection(),
          const SizedBox(height: 24),

          // Monthly Budget Overview
          _buildMonthlyBudgetSection(),
          const SizedBox(height: 24),

          // Quick Actions
          _buildQuickActionsSection(),
          const SizedBox(height: 24),

          // Recent Expenses
          _buildRecentExpensesSection(),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back, ${user?.name ?? 'User'}!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Let\'s manage your finances together',
                style: TextStyle(fontSize: 16, color: Color(0xCCFFFFFF)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMonthlyBudgetSection() {
    return Consumer2<AuthProvider, ExpenseProvider>(
      builder: (context, authProvider, expenseProvider, child) {
        final user = authProvider.currentUser;
        final totalIncome = user?.totalFamilyIncome ?? 0.0;
        final currentBudget = expenseProvider.monthlyBudget;

        // Get user's budget preference (first preference or default to monthly)
        final budgetPreference =
            user?.budgetPreferences.isNotEmpty == true
                ? user!.budgetPreferences.first
                : 'Monthly Budget';

        // Calculate budget based on preference
        final budgetInfo = _calculateBudgetInfo(
          budgetPreference,
          totalIncome,
          currentBudget,
        );
        final budgetAmount = budgetInfo['amount'];
        final budgetLabel = budgetInfo['label'];
        final periodLabel = budgetInfo['periodLabel'];

        final now = DateTime.now();
        final spentAmount = _calculateSpentAmount(
          expenseProvider.expenses,
          budgetPreference,
          now,
        );
        final budgetProgress =
            budgetAmount > 0
                ? (spentAmount / budgetAmount).clamp(0.0, 1.0)
                : 0.0;
        final isOverBudget = budgetAmount > 0 && spentAmount > budgetAmount;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: Color(0x1A000000),
                spreadRadius: 1,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    budgetLabel,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  IconButton(
                    onPressed:
                        () => _showEditBudgetDialog(
                          context,
                          budgetAmount,
                          budgetPreference,
                        ),
                    icon: const Icon(Icons.edit, color: Color(0xFF667eea)),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Budget Progress
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppDateUtils.formatCurrency(budgetAmount),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF667eea),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Spent $periodLabel: ${AppDateUtils.formatCurrency(spentAmount)} / ${AppDateUtils.formatCurrency(budgetAmount)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF718096),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(6),
                          ),
                          child: LinearProgressIndicator(
                            value: budgetProgress,
                            backgroundColor: const Color(0xFFE2E8F0),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isOverBudget
                                  ? Colors.red
                                  : const Color(0xFF667eea),
                            ),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Color(0x1A667eea),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.account_balance_wallet,
                        color: Color(0xFF667eea),
                        size: 40,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Income Information
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFFF7FAFC),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.trending_up, color: Color(0xFF667eea)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Family Income',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF718096),
                            ),
                          ),
                          Text(
                            AppDateUtils.formatCurrency(totalIncome),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                'Add Expense',
                Icons.add_circle,
                const Color(0xFF667eea),
                () => _navigateToExpensesScreen(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                'View Reports',
                Icons.analytics,
                const Color(0xFF764ba2),
                () => _navigateToTrackerScreen(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                'Create Group',
                Icons.group_add,
                const Color(0xFF48bb78),
                () => _navigateToGroupsScreen(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                'Settings',
                Icons.settings,
                const Color(0xFFed8936),
                () => _navigateToSettingsScreen(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2D3748),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentExpensesSection() {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, child) {
        final recentExpenses = expenseProvider.getRecentExpenses(7);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Expenses',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                TextButton(
                  onPressed: () => _navigateToExpensesScreen(),
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      color: Color(0xFF667eea),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child:
                  recentExpenses.isEmpty
                      ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            'No recent expenses',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ),
                      )
                      : Column(
                        children:
                            recentExpenses.take(3).map((expense) {
                              final isLast =
                                  recentExpenses.indexOf(expense) == 2;
                              return Column(
                                children: [
                                  _buildExpenseItem(
                                    expense.title,
                                    '₹${expense.amount.toStringAsFixed(2)}',
                                    _formatDate(expense.date),
                                    expense.type == 'income'
                                        ? Colors.green
                                        : Colors.red,
                                    expense,
                                  ),
                                  if (!isLast) _buildDivider(),
                                ],
                              );
                            }).toList(),
                      ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExpenseItem(
    String title,
    String amount,
    String date, [
    Color? color,
    Expense? expense,
  ]) {
    final itemColor = color ?? const Color(0xFF667eea);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: () {
          if (expense != null) {
            _showEditExpenseDialog(expense);
          }
        },
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: itemColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                color == Colors.green ? Icons.add_circle : Icons.shopping_cart,
                color: itemColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  Text(
                    date,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Text(
              amount,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: itemColor,
              ),
            ),
          ],
        ),
      ),
    );
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

  void _showEditExpenseDialog(Expense expense) {
    final titleController = TextEditingController(text: expense.title);
    final amountController = TextEditingController(
      text: expense.amount.toString(),
    );
    final descriptionController = TextEditingController(
      text: expense.description,
    );
    String? selectedCategory = expense.category;

    final isIncome = expense.type == 'income';
    final categories =
        isIncome
            ? AppConstants.incomeCategories
            : AppConstants.expenseCategories;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(isIncome ? 'Edit Income' : 'Edit Expense'),
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
                        categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                    onChanged: (value) {
                      selectedCategory = value;
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
                  final updated = expense.copyWith(
                    title: title,
                    amount: amount,
                    category: selectedCategory!,
                    description: description,
                  );
                  expenseProvider.updateExpense(updated);

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Transaction updated')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667eea),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Update'),
              ),
            ],
          ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.grey[300]);
  }

  void _showEditBudgetDialog(
    BuildContext context,
    double currentBudget,
    String budgetPreference,
  ) {
    final TextEditingController budgetController = TextEditingController(
      text: currentBudget.toStringAsFixed(2),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $budgetPreference'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Enter your desired $budgetPreference:'),
              const SizedBox(height: 16),
              TextField(
                controller: budgetController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: '$budgetPreference (₹)',
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newBudget =
                    double.tryParse(budgetController.text) ?? currentBudget;
                final expenseProvider = Provider.of<ExpenseProvider>(
                  context,
                  listen: false,
                );
                expenseProvider.setMonthlyBudget(newBudget);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Budget updated to ₹${newBudget.toStringAsFixed(2)}',
                    ),
                    backgroundColor: const Color(0xFF667eea),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToExpensesScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ExpensesScreen(key: _expensesKey),
      ),
    );
  }

  void _navigateToTrackerScreen() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const TrackerScreen()));
  }

  void _navigateToGroupsScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => GroupsScreen(key: _groupsKey)),
    );
  }

  void _navigateToSettingsScreen() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
  }

  // Helper method to calculate budget information based on preference
  Map<String, dynamic> _calculateBudgetInfo(
    String budgetPreference,
    double totalIncome,
    double currentBudget,
  ) {
    double amount;
    String label;
    String periodLabel;

    switch (budgetPreference) {
      case 'Daily Budget':
        // If user has set a budget, use it; otherwise calculate daily from monthly income
        amount =
            currentBudget > 0
                ? currentBudget
                : (totalIncome / 30) * 0.7; // 70% of daily income
        label = 'Daily Budget';
        periodLabel = 'today';
        break;
      case 'Monthly Budget':
        amount =
            currentBudget > 0
                ? currentBudget
                : totalIncome * 0.7; // 70% of monthly income
        label = 'Monthly Budget';
        periodLabel = 'this month';
        break;
      case 'Quarterly Budget':
        // If user has set a budget, use it; otherwise calculate quarterly from monthly income
        amount =
            currentBudget > 0
                ? currentBudget
                : (totalIncome * 3) * 0.7; // 70% of quarterly income
        label = 'Quarterly Budget';
        periodLabel = 'this quarter';
        break;
      case 'Individual Budget':
        // Individual budget - use the set budget or calculate from income
        amount = currentBudget > 0 ? currentBudget : totalIncome * 0.7;
        label = 'Individual Budget';
        periodLabel = 'this month';
        break;
      default:
        // Default to monthly
        amount = currentBudget > 0 ? currentBudget : totalIncome * 0.7;
        label = 'Monthly Budget';
        periodLabel = 'this month';
    }

    return {'amount': amount, 'label': label, 'periodLabel': periodLabel};
  }

  // Helper method to calculate spent amount based on budget preference
  double _calculateSpentAmount(
    List<Expense> expenses,
    String budgetPreference,
    DateTime now,
  ) {
    List<Expense> filteredExpenses;

    switch (budgetPreference) {
      case 'Daily Budget':
        // Expenses from today
        filteredExpenses =
            expenses
                .where(
                  (e) =>
                      e.type == 'expense' &&
                      e.date.year == now.year &&
                      e.date.month == now.month &&
                      e.date.day == now.day,
                )
                .toList();
        break;
      case 'Monthly Budget':
        // Expenses from this month
        filteredExpenses =
            expenses
                .where(
                  (e) =>
                      e.type == 'expense' &&
                      e.date.year == now.year &&
                      e.date.month == now.month,
                )
                .toList();
        break;
      case 'Quarterly Budget':
        // Expenses from this quarter
        final quarterStartMonth = ((now.month - 1) ~/ 3) * 3 + 1;
        filteredExpenses =
            expenses
                .where(
                  (e) =>
                      e.type == 'expense' &&
                      e.date.year == now.year &&
                      e.date.month >= quarterStartMonth &&
                      e.date.month < quarterStartMonth + 3,
                )
                .toList();
        break;
      case 'Individual Budget':
        // For individual budget, use monthly calculation
        filteredExpenses =
            expenses
                .where(
                  (e) =>
                      e.type == 'expense' &&
                      e.date.year == now.year &&
                      e.date.month == now.month,
                )
                .toList();
        break;
      default:
        // Default to monthly
        filteredExpenses =
            expenses
                .where(
                  (e) =>
                      e.type == 'expense' &&
                      e.date.year == now.year &&
                      e.date.month == now.month,
                )
                .toList();
    }

    return filteredExpenses.fold<double>(0.0, (sum, e) => sum + e.amount);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Money Manager',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final navigator = Navigator.of(context);
              final expenseProvider = Provider.of<ExpenseProvider>(
                context,
                listen: false,
              );
              final groupProvider = Provider.of<GroupProvider>(
                context,
                listen: false,
              );

              // Clear provider data
              await expenseProvider.clearData();
              await groupProvider.clearData();

              await authProvider.logout();
              if (mounted) {
                navigator.pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: _buildDashboardHome(),
    );
  }
}
