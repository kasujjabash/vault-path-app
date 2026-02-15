/// Category model for organizing transactions
/// This model handles expense and income categories with visual customization
class Category {
  final String id;
  final String name;
  final String type; // expense, income
  final String color; // hex color for visual representation
  final String icon; // icon name for the category
  final double? budgetLimit; // monthly budget limit for expense categories
  final bool isDefault; // system default categories that cannot be deleted
  final DateTime createdAt;
  final DateTime updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.type,
    required this.color,
    required this.icon,
    this.budgetLimit,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert Category to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'color': color,
      'icon': icon,
      'budgetLimit': budgetLimit,
      'isDefault': isDefault ? 1 : 0,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Create Category from Map (database query result)
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      color: map['color'],
      icon: map['icon'],
      budgetLimit: map['budgetLimit']?.toDouble(),
      isDefault: map['isDefault'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  /// Create a copy of the category with updated fields
  Category copyWith({
    String? name,
    String? type,
    String? color,
    String? icon,
    double? budgetLimit,
    bool? isDefault,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      budgetLimit: budgetLimit ?? this.budgetLimit,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'Category{id: $id, name: $name, type: $type}';
  }
}
