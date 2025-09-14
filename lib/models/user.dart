class User {
  final String id;
  final String email;
  final String name;
  final String? phoneNumber;
  final DateTime createdAt;
  
  // Family details
  final String roleInFamily; // son, daughter, husband, wife, father, mother, etc.
  final List<FamilyMember> familyMembers;
  final List<Dependency> dependencies;
  final double totalFamilyIncome;
  final List<String> budgetPreferences; // daily, monthly, quarterly, individual

  User({
    required this.id,
    required this.email,
    required this.name,
    this.phoneNumber,
    required this.createdAt,
    required this.roleInFamily,
    required this.familyMembers,
    required this.dependencies,
    required this.totalFamilyIncome,
    required this.budgetPreferences,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      roleInFamily: json['roleInFamily'] as String? ?? 'Individual',
      familyMembers: (json['familyMembers'] as List<dynamic>?)
          ?.map((member) => FamilyMember.fromJson(member as Map<String, dynamic>))
          .toList() ?? [],
      dependencies: (json['dependencies'] as List<dynamic>?)
          ?.map((dep) => Dependency.fromJson(dep as Map<String, dynamic>))
          .toList() ?? [],
      totalFamilyIncome: (json['totalFamilyIncome'] as num?)?.toDouble() ?? 0.0,
      budgetPreferences: (json['budgetPreferences'] as List<dynamic>?)
          ?.map((pref) => pref.toString())
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt.toIso8601String(),
      'roleInFamily': roleInFamily,
      'familyMembers': familyMembers.map((member) => member.toJson()).toList(),
      'dependencies': dependencies.map((dep) => dep.toJson()).toList(),
      'totalFamilyIncome': totalFamilyIncome,
      'budgetPreferences': budgetPreferences,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? phoneNumber,
    DateTime? createdAt,
    String? roleInFamily,
    List<FamilyMember>? familyMembers,
    List<Dependency>? dependencies,
    double? totalFamilyIncome,
    List<String>? budgetPreferences,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      roleInFamily: roleInFamily ?? this.roleInFamily,
      familyMembers: familyMembers ?? this.familyMembers,
      dependencies: dependencies ?? this.dependencies,
      totalFamilyIncome: totalFamilyIncome ?? this.totalFamilyIncome,
      budgetPreferences: budgetPreferences ?? this.budgetPreferences,
    );
  }
}

class FamilyMember {
  final String name;
  final String relationship; // son, daughter, husband, wife, father, mother, etc.
  final double? monthlyIncome;
  final String? occupation;

  FamilyMember({
    required this.name,
    required this.relationship,
    this.monthlyIncome,
    this.occupation,
  });

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      name: json['name'] as String,
      relationship: json['relationship'] as String,
      monthlyIncome: (json['monthlyIncome'] as num?)?.toDouble(),
      occupation: json['occupation'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'relationship': relationship,
      'monthlyIncome': monthlyIncome,
      'occupation': occupation,
    };
  }
}

class Dependency {
  final String name;
  final String type; // housewife, elder parent, child, etc.
  final String? relationship;
  final int? age;
  final String? specialNeeds;

  Dependency({
    required this.name,
    required this.type,
    this.relationship,
    this.age,
    this.specialNeeds,
  });

  factory Dependency.fromJson(Map<String, dynamic> json) {
    return Dependency(
      name: json['name'] as String,
      type: json['type'] as String,
      relationship: json['relationship'] as String?,
      age: json['age'] as int?,
      specialNeeds: json['specialNeeds'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'relationship': relationship,
      'age': age,
      'specialNeeds': specialNeeds,
    };
  }
} 