import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import '../utils/app_constants.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  String _selectedCategory = 'All Categories';
  // Data for the pie chart (always based on all categories)
  List<Map<String, dynamic>> _pieData = [];
  // Data for category list respecting the filter
  List<Map<String, dynamic>> _categoryData = [];
  // Concrete expenses for the selected category
  List<Expense> _filteredExpenses = [];

  double get _totalSpending =>
      _pieData.fold(0.0, (sum, item) => sum + (item['amount'] as double));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _recomputeData();
  }

  Widget _buildExpensesList() {
    return Container(
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
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _filteredExpenses.length,
        separatorBuilder:
            (_, __) => Divider(height: 1, color: Colors.grey[200]),
        itemBuilder: (context, index) {
          final e = _filteredExpenses[index];
          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (AppConstants.categoryColors[e.category] ?? Colors.grey)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                AppConstants.categoryIcons[e.category] ?? Icons.receipt,
                color: AppConstants.categoryColors[e.category] ?? Colors.grey,
                size: 20,
              ),
            ),
            title: Text(e.title),
            subtitle: Text(
              '${e.category} • ${e.date.day}/${e.date.month}/${e.date.year}',
            ),
            trailing: Text(
              '₹${e.amount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }

  void _recomputeData() {
    final expenseProvider = Provider.of<ExpenseProvider>(
      context,
      listen: false,
    );
    final expenses =
        expenseProvider.expenses.where((e) => e.type == 'expense').toList();

    // Build ALL category totals for the pie chart (ignores current filter)
    final Map<String, double> allCategoryTotals = {};
    for (final expense in expenses) {
      final key = expense.category;
      allCategoryTotals[key] = (allCategoryTotals[key] ?? 0.0) + expense.amount;
    }
    _pieData =
        allCategoryTotals.entries.map((e) {
            final color = AppConstants.categoryColors[e.key] ?? Colors.grey;
            return {'category': e.key, 'amount': e.value, 'color': color};
          }).toList()
          ..sort(
            (a, b) => (b['amount'] as double).compareTo(a['amount'] as double),
          );

    // Build FILTERED category totals for the list
    final Map<String, double> filteredTotals = {};
    for (final expense in expenses) {
      if (_selectedCategory != 'All Categories' &&
          expense.category != _selectedCategory)
        continue;
      final key = expense.category;
      filteredTotals[key] = (filteredTotals[key] ?? 0.0) + expense.amount;
    }
    _categoryData =
        filteredTotals.entries.map((e) {
            final color = AppConstants.categoryColors[e.key] ?? Colors.grey;
            return {'category': e.key, 'amount': e.value, 'color': color};
          }).toList()
          ..sort(
            (a, b) => (b['amount'] as double).compareTo(a['amount'] as double),
          );

    // Build concrete expense list when a category is selected
    _filteredExpenses =
        _selectedCategory == 'All Categories'
            ? []
            : expenses.where((e) => e.category == _selectedCategory).toList();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['All Categories', ...AppConstants.expenseCategories];
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reports',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filters
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Filter by Category',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.filter_list),
                    ),
                    items:
                        categories
                            .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _selectedCategory = value);
                      _recomputeData();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Pie chart (always based on all categories)
            _buildSectionTitle('Spending Breakdown'),
            const SizedBox(height: 16),
            _buildPieChart(),
            const SizedBox(height: 24),

            // Summary
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Total Spending',
                    '₹${_totalSpending.toStringAsFixed(0)}',
                    Icons.trending_down,
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (_categoryData.isNotEmpty) ...[
              _buildSectionTitle('Category Breakdown'),
              const SizedBox(height: 16),
              _buildCategoryList(),
              const SizedBox(height: 24),

              if (_selectedCategory != 'All Categories') ...[
                _buildSectionTitle('Expenses in ' + _selectedCategory),
                const SizedBox(height: 16),
                _buildExpensesList(),
              ],
            ] else ...[
              _buildEmptyState(
                'No spending data yet',
                'Add expenses to see your spending breakdown',
                Icons.analytics,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(32),
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
          Icon(icon, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String amount,
    IconData icon,
    Color color,
  ) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2D3748),
      ),
    );
  }

  Widget _buildPieChart() {
    return Container(
      height: 200,
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
          Expanded(
            child: CustomPaint(
              size: const Size(150, 150),
              painter: PieChartPainter(_pieData, _totalSpending),
            ),
          ),
          const SizedBox(height: 16),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children:
          _pieData.map((item) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: item['color'],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(item['category'], style: const TextStyle(fontSize: 12)),
              ],
            );
          }).toList(),
    );
  }

  Widget _buildCategoryList() {
    return Container(
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
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _categoryData.length,
        itemBuilder: (context, index) {
          final item = _categoryData[index];
          final percentage = (item['amount'] / _totalSpending * 100)
              .toStringAsFixed(1);

          return ListTile(
            leading: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: item['color'],
                shape: BoxShape.circle,
              ),
            ),
            title: Text(item['category']),
            subtitle: LinearProgressIndicator(
              value: item['amount'] / _totalSpending,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(item['color']),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${item['amount'].toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '$percentage%',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Bar chart removed per requirement
}

class PieChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final double total;

  PieChartPainter(this.data, this.total);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.8;

    double startAngle = 0;

    for (final item in data) {
      final sweepAngle = (item['amount'] / total) * 2 * 3.14159;

      final paint =
          Paint()
            ..color = item['color']
            ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Bar chart painter removed
