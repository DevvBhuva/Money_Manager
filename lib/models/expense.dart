class Expense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final String description;
  final DateTime date;
  final String userId;
  final String type; // 'expense' or 'income'

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
    required this.userId,
    required this.type,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      userId: json['userId'] as String,
      type: json['type'] as String? ?? 'expense',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'description': description,
      'date': date.toIso8601String(),
      'userId': userId,
      'type': type,
    };
  }

  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    String? description,
    DateTime? date,
    String? userId,
    String? type,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      description: description ?? this.description,
      date: date ?? this.date,
      userId: userId ?? this.userId,
      type: type ?? this.type,
    );
  }
} 