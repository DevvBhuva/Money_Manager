import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }
  
  static String formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }
  
  static String formatDateForDisplay(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
  
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }
  
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }
  
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    return date.isAfter(weekStart.subtract(const Duration(days: 1))) && 
           date.isBefore(weekEnd.add(const Duration(days: 1)));
  }
  
  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }
}

