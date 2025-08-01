class Expense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final String description;
  final DateTime date;
  final String userId;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    this.description = '',
    required this.date,
    required this.userId,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      title: json['title'],
      amount: json['amount'].toDouble(),
      category: json['category'],
      description: json['description'] ?? '',
      date: DateTime.parse(json['date']),
      userId: json['userId'],
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
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      description: description ?? this.description,
      date: date ?? this.date,
      userId: userId ?? this.userId,
    );
  }
} 