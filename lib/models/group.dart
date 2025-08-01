class Group {
  final String id;
  final String name;
  final String description;
  final List<String> members;
  final String createdBy;
  final DateTime createdAt;
  final double totalAmount;
  final List<GroupExpense> expenses;

  Group({
    required this.id,
    required this.name,
    required this.description,
    required this.members,
    required this.createdBy,
    required this.createdAt,
    this.totalAmount = 0.0,
    this.expenses = const [],
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      members: List<String>.from(json['members']),
      createdBy: json['createdBy'],
      createdAt: DateTime.parse(json['createdAt']),
      totalAmount: json['totalAmount']?.toDouble() ?? 0.0,
      expenses: (json['expenses'] as List?)
          ?.map((e) => GroupExpense.fromJson(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'members': members,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'totalAmount': totalAmount,
      'expenses': expenses.map((e) => e.toJson()).toList(),
    };
  }

  Group copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? members,
    String? createdBy,
    DateTime? createdAt,
    double? totalAmount,
    List<GroupExpense>? expenses,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      members: members ?? this.members,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      totalAmount: totalAmount ?? this.totalAmount,
      expenses: expenses ?? this.expenses,
    );
  }
}

class GroupExpense {
  final String id;
  final String title;
  final double amount;
  final String paidBy;
  final List<String> splitBetween;
  final DateTime date;
  final String groupId;

  GroupExpense({
    required this.id,
    required this.title,
    required this.amount,
    required this.paidBy,
    required this.splitBetween,
    required this.date,
    required this.groupId,
  });

  factory GroupExpense.fromJson(Map<String, dynamic> json) {
    return GroupExpense(
      id: json['id'],
      title: json['title'],
      amount: json['amount'].toDouble(),
      paidBy: json['paidBy'],
      splitBetween: List<String>.from(json['splitBetween']),
      date: DateTime.parse(json['date']),
      groupId: json['groupId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'paidBy': paidBy,
      'splitBetween': splitBetween,
      'date': date.toIso8601String(),
      'groupId': groupId,
    };
  }
} 