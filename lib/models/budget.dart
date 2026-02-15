/// Budget model for setting spending limits and tracking progress
/// This model helps users manage their financial goals and spending habits
class Budget {
  final String id;
  final String categoryId; // reference to category
  final String name;
  final double amount; // budget limit
  final double spent; // amount already spent
  final String period; // monthly, weekly, yearly
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Budget({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.amount,
    this.spent = 0.0,
    required this.period,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Calculate budget progress percentage
  double get progressPercentage {
    if (amount == 0) return 0;
    return (spent / amount).clamp(0.0, 1.0);
  }

  /// Get remaining budget amount
  double get remaining {
    return (amount - spent).clamp(0.0, double.infinity);
  }

  /// Check if budget is exceeded
  bool get isExceeded => spent > amount;

  /// Check if budget is close to limit (80% or more)
  bool get isNearLimit => progressPercentage >= 0.8;

  /// Convert Budget to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'name': name,
      'amount': amount,
      'spent': spent,
      'period': period,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch,
      'isActive': isActive ? 1 : 0,
      'notes': notes,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Create Budget from Map (database query result)
  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      categoryId: map['categoryId'],
      name: map['name'],
      amount: map['amount'].toDouble(),
      spent: map['spent'].toDouble(),
      period: map['period'],
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate']),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['endDate']),
      isActive: map['isActive'] == 1,
      notes: map['notes'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  /// Create a copy of the budget with updated fields
  Budget copyWith({
    String? categoryId,
    String? name,
    double? amount,
    double? spent,
    String? period,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    String? notes,
    DateTime? updatedAt,
  }) {
    return Budget(
      id: id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      spent: spent ?? this.spent,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'Budget{id: $id, name: $name, amount: $amount, spent: $spent}';
  }
}
