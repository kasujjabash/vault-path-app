/// Notification model for the Vault Path app
class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? data;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.data,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? createdAt,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.name,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'data': data,
    };
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.general,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      isRead: json['isRead'] ?? false,
      data: json['data'],
    );
  }
}

enum NotificationType {
  income,
  expense,
  budget,
  reminder,
  achievement,
  general,
}

extension NotificationTypeExtension on NotificationType {
  String get displayName {
    switch (this) {
      case NotificationType.income:
        return 'Income';
      case NotificationType.expense:
        return 'Expense';
      case NotificationType.budget:
        return 'Budget';
      case NotificationType.reminder:
        return 'Reminder';
      case NotificationType.achievement:
        return 'Achievement';
      case NotificationType.general:
        return 'General';
    }
  }

  String get emoji {
    switch (this) {
      case NotificationType.income:
        return '💰';
      case NotificationType.expense:
        return '💸';
      case NotificationType.budget:
        return '📊';
      case NotificationType.reminder:
        return '⏰';
      case NotificationType.achievement:
        return '🏆';
      case NotificationType.general:
        return '📢';
    }
  }
}
