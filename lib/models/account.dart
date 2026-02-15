/// Account model for representing bank accounts and other financial accounts
/// This model handles all account-related data including balance and account type
class Account {
  final String id;
  final String name;
  final String type; // checking, savings, credit, cash, investment
  final double balance;
  final String? description;
  final String color; // hex color for visual representation
  final String icon; // icon name for the account
  final bool isPrimary; // is this the primary account
  final DateTime createdAt;
  final DateTime updatedAt;

  Account({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    this.description,
    required this.color,
    required this.icon,
    this.isPrimary = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert Account to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'balance': balance,
      'description': description,
      'color': color,
      'icon': icon,
      'isPrimary': isPrimary ? 1 : 0,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Create Account from Map (database query result)
  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      balance: map['balance'].toDouble(),
      description: map['description'],
      color: map['color'],
      icon: map['icon'],
      isPrimary: map['isPrimary'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  /// Create a copy of the account with updated fields
  Account copyWith({
    String? name,
    String? type,
    double? balance,
    String? description,
    String? color,
    String? icon,
    bool? isPrimary,
    DateTime? updatedAt,
  }) {
    return Account(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      description: description ?? this.description,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isPrimary: isPrimary ?? this.isPrimary,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'Account{id: $id, name: $name, type: $type, balance: $balance}';
  }
}
