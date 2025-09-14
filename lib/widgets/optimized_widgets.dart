import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../utils/app_constants.dart';
import '../utils/date_utils.dart';

/// Optimized widget for displaying expense summary cards
class ExpenseSummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final IconData icon;

  const ExpenseSummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.all(Radius.circular(AppConstants.radiusMedium)),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: AppConstants.bodySmall.copyWith(color: color),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            AppDateUtils.formatCurrency(amount),
            style: AppConstants.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Optimized widget for displaying recent expenses
class RecentExpensesWidget extends StatelessWidget {
  const RecentExpensesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, child) {
        final recentExpenses = expenseProvider.getRecentExpenses(7);
        
        if (recentExpenses.isEmpty) {
          return const _EmptyExpensesWidget();
        }
        
        return Column(
          children: recentExpenses.take(3).map((expense) {
            return _ExpenseItemWidget(
              key: ValueKey(expense.id),
              expense: expense,
            );
          }).toList(),
        );
      },
    );
  }
}

class _EmptyExpensesWidget extends StatelessWidget {
  const _EmptyExpensesWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: AppConstants.paddingMedium),
          Text(
            'No transactions yet',
            style: AppConstants.bodyLarge,
          ),
          SizedBox(height: AppConstants.paddingSmall),
          Text(
            'Tap the + button to add your first transaction',
            style: AppConstants.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _ExpenseItemWidget extends StatelessWidget {
  final dynamic expense; // Using dynamic to avoid import issues

  const _ExpenseItemWidget({
    super.key,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = expense.type == 'income';
    final categoryColor = isIncome ? Colors.green : AppConstants.categoryColors[expense.category] ?? Colors.grey;
    final categoryIcon = isIncome ? Icons.add_circle : AppConstants.categoryIcons[expense.category] ?? Icons.receipt;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.all(Radius.circular(AppConstants.radiusSmall)),
            ),
            child: Icon(
              categoryIcon,
              color: categoryColor,
            ),
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  style: AppConstants.bodyMedium.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  expense.category,
                  style: AppConstants.bodySmall,
                ),
                Text(
                  AppDateUtils.formatDate(expense.date),
                  style: AppConstants.bodySmall.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}${AppDateUtils.formatCurrency(expense.amount)}',
            style: AppConstants.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: isIncome ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

/// Optimized loading widget
class OptimizedLoadingWidget extends StatelessWidget {
  final String message;
  
  const OptimizedLoadingWidget({
    super.key,
    this.message = 'Loading...',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(
            message,
            style: AppConstants.bodyMedium,
          ),
        ],
      ),
    );
  }
}

/// Optimized error widget
class OptimizedErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  
  const OptimizedErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(
            message,
            style: AppConstants.bodyMedium,
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: AppConstants.paddingMedium),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}
