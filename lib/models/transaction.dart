/// Transaction model for representing all financial transactions
/// This model handles both income and expense transactions with detailed tracking
class Transaction {
  final String id;
  final String accountId; // reference to account
  final String categoryId; // reference to category
  final String type; // expense, income, transfer
  final double amount;
  final String title;
  final String? description;
  final DateTime date;
  final String? location; // where the transaction occurred
  final String? tags; // comma-separated tags for better organization
  final bool isRecurring; // is this a recurring transaction
  final String? recurringPattern; // daily, weekly, monthly, yearly
  final String? transferToAccountId; // for transfer transactions
  final DateTime createdAt;
  final DateTime updatedAt;

  Transaction({
    required this.id,
    required this.accountId,
    required this.categoryId,
    required this.type,
    required this.amount,
    required this.title,
    this.description,
    required this.date,
    this.location,
    this.tags,
    this.isRecurring = false,
    this.recurringPattern,
    this.transferToAccountId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert Transaction to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accountId': accountId,
      'categoryId': categoryId,
      'type': type,
      'amount': amount,
      'title': title,
      'description': description,
      'date': date.millisecondsSinceEpoch,
      'location': location,
      'tags': tags,
      'isRecurring': isRecurring ? 1 : 0,
      'recurringPattern': recurringPattern,
      'transferToAccountId': transferToAccountId,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Create Transaction from Map (database query result)
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      accountId: map['accountId'],
      categoryId: map['categoryId'],
      type: map['type'],
      amount: map['amount'].toDouble(),
      title: map['title'],
      description: map['description'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      location: map['location'],
      tags: map['tags'],
      isRecurring: map['isRecurring'] == 1,
      recurringPattern: map['recurringPattern'],
      transferToAccountId: map['transferToAccountId'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  /// Create a copy of the transaction with updated fields
  Transaction copyWith({
    String? accountId,
    String? categoryId,
    String? type,
    double? amount,
    String? title,
    String? description,
    DateTime? date,
    String? location,
    String? tags,
    bool? isRecurring,
    String? recurringPattern,
    String? transferToAccountId,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      location: location ?? this.location,
      tags: tags ?? this.tags,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringPattern: recurringPattern ?? this.recurringPattern,
      transferToAccountId: transferToAccountId ?? this.transferToAccountId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Get list of tags from comma-separated string
  List<String> getTagsList() {
    if (tags == null || tags!.isEmpty) return [];
    return tags!
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  @override
  String toString() {
    return 'Transaction{id: $id, type: $type, amount: $amount, title: $title}';
  }
}
