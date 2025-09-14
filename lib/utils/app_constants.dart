import 'package:flutter/material.dart';

class AppConstants {
  // Colors
  static const Color primaryColor = Color(0xFF667eea);
  static const Color secondaryColor = Color(0xFF764ba2);
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color backgroundLight = Color(0xFFF7FAFC);
  static const Color shadowColor = Color(0x1A000000);
  static const Color shadowColorLight = Color(0x1F000000);
  
  // Text Styles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );
  
  static const TextStyle headingMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );
  
  static const TextStyle headingSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: textPrimary,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: textPrimary,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: textSecondary,
  );
  
  // Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  
  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  
  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  
  // Expense Categories
  static const List<String> expenseCategories = [
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
  
  static const List<String> incomeCategories = [
    'Salary',
    'Freelance',
    'Investment',
    'Gift',
    'Refund',
    'Other'
  ];
  
  // Category Colors
  static const Map<String, Color> categoryColors = {
    'Food & Dining': Colors.orange,
    'Transportation': Colors.blue,
    'Shopping': Colors.purple,
    'Entertainment': Colors.pink,
    'Healthcare': Colors.red,
    'Education': Colors.green,
    'Utilities': Colors.teal,
    'Rent': Colors.indigo,
    'Insurance': Colors.amber,
    'Other': Colors.grey,
  };
  
  // Category Icons
  static const Map<String, IconData> categoryIcons = {
    'Food & Dining': Icons.restaurant,
    'Transportation': Icons.directions_car,
    'Shopping': Icons.shopping_bag,
    'Entertainment': Icons.movie,
    'Healthcare': Icons.medical_services,
    'Education': Icons.school,
    'Utilities': Icons.power,
    'Rent': Icons.home,
    'Insurance': Icons.security,
    'Other': Icons.receipt,
  };
}
