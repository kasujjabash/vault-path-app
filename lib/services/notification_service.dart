import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import '../models/notification.dart';
import '../utils/format_utils.dart';

/// Service to manage app notifications
class NotificationService extends ChangeNotifier {
  static const String _notificationsKey = 'app_notifications';
  static const String _lastBudgetReminderKey = 'last_budget_reminder';
  static const String _deviceIdKey = 'device_id';
  static const String _welcomeShownKey = 'welcome_notification_shown';

  List<AppNotification> _notifications = [];
  SharedPreferences? _prefs;
  bool _isInitialized = false;

  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  bool get hasUnreadNotifications => unreadCount > 0;

  bool get isInitialized => _isInitialized;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadNotifications();
      await _checkBudgetReminder();
      await _checkNewDeviceAndShowWelcome(); // Check for new device
      _isInitialized = true;
      notifyListeners();
      debugPrint(
        'NotificationService initialized with ${_notifications.length} notifications',
      );
    } catch (e) {
      debugPrint('Error initializing NotificationService: $e');
    }
  }

  /// Load notifications from local storage
  Future<void> _loadNotifications() async {
    try {
      final notificationsJson = _prefs?.getStringList(_notificationsKey) ?? [];
      _notifications =
          notificationsJson
              .map((jsonStr) {
                try {
                  return AppNotification.fromJson(json.decode(jsonStr));
                } catch (e) {
                  debugPrint('Error parsing notification: $e');
                  return null;
                }
              })
              .whereType<AppNotification>()
              .toList();

      // Sort by creation date (newest first)
      _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Keep only last 50 notifications to avoid storage bloat
      if (_notifications.length > 50) {
        _notifications = _notifications.take(50).toList();
        await _saveNotifications();
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
      _notifications = [];
    }
  }

  /// Save notifications to local storage
  Future<void> _saveNotifications() async {
    try {
      final notificationsJson =
          _notifications
              .map((notification) => json.encode(notification.toJson()))
              .toList();
      await _prefs?.setStringList(_notificationsKey, notificationsJson);
    } catch (e) {
      debugPrint('Error saving notifications: $e');
    }
  }

  /// Add a new notification
  Future<void> addNotification(AppNotification notification) async {
    _notifications.insert(0, notification);

    // Keep only last 50 notifications
    if (_notifications.length > 50) {
      _notifications = _notifications.take(50).toList();
    }

    await _saveNotifications();
    notifyListeners();
    debugPrint('Added notification: ${notification.title}');
  }

  /// Create and add an income notification
  Future<void> addIncomeNotification(double amount, String description) async {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '💰 Income Added!',
      message:
          'You added ${FormatUtils.formatCurrency(amount)} to your income${description.isNotEmpty ? ' for $description' : ''}.',
      type: NotificationType.income,
      createdAt: DateTime.now(),
      data: {'amount': amount, 'description': description},
    );

    await addNotification(notification);
  }

  /// Create and add a budget reminder notification
  Future<void> addBudgetReminderNotification() async {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '📊 Time to Create a Budget!',
      message:
          'Set up your monthly budget to better track your spending and achieve your financial goals.',
      type: NotificationType.reminder,
      createdAt: DateTime.now(),
      data: {'action': 'create_budget'},
    );

    await addNotification(notification);
  }

  /// Create and add an expense notification
  Future<void> addExpenseNotification(
    double amount,
    String category,
    String description,
  ) async {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '💸 Expense Recorded',
      message:
          'You spent ${FormatUtils.formatCurrency(amount)} on $category${description.isNotEmpty ? ' for $description' : ''}.',
      type: NotificationType.expense,
      createdAt: DateTime.now(),
      data: {
        'amount': amount,
        'category': category,
        'description': description,
      },
    );

    await addNotification(notification);
  }

  /// Create and add an achievement notification
  Future<void> addAchievementNotification(String title, String message) async {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '🏆 $title',
      message: message,
      type: NotificationType.achievement,
      createdAt: DateTime.now(),
    );

    await addNotification(notification);
  }

  /// Check if it's time to remind about budget creation
  Future<void> _checkBudgetReminder() async {
    final lastReminder = _prefs?.getString(_lastBudgetReminderKey);
    final now = DateTime.now();

    if (lastReminder == null) {
      // First time user - show reminder after 2 days of usage
      final installDate = _prefs?.getString('app_install_date');
      if (installDate != null) {
        final install = DateTime.parse(installDate);
        if (now.difference(install).inDays >= 2) {
          await addBudgetReminderNotification();
          await _prefs?.setString(
            _lastBudgetReminderKey,
            now.toIso8601String(),
          );
        }
      }
    } else {
      // Remind weekly if no budget is set
      final lastReminderDate = DateTime.parse(lastReminder);
      if (now.difference(lastReminderDate).inDays >= 7) {
        await addBudgetReminderNotification();
        await _prefs?.setString(_lastBudgetReminderKey, now.toIso8601String());
      }
    }
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      await _saveNotifications();
      notifyListeners();
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    _notifications =
        _notifications
            .map((notification) => notification.copyWith(isRead: true))
            .toList();
    await _saveNotifications();
    notifyListeners();
  }

  /// Delete a notification and return it for potential undo
  AppNotification? deleteNotification(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      final deletedNotification = _notifications.removeAt(index);
      _saveNotifications();
      notifyListeners();
      return deletedNotification;
    }
    return null;
  }

  /// Undo notification deletion by restoring it
  Future<void> undoDeleteNotification(AppNotification notification) async {
    // Insert the notification back in the correct position based on creation date
    int insertIndex = 0;
    for (int i = 0; i < _notifications.length; i++) {
      if (_notifications[i].createdAt.isBefore(notification.createdAt)) {
        insertIndex = i;
        break;
      }
      insertIndex = i + 1;
    }

    _notifications.insert(insertIndex, notification);
    await _saveNotifications();
    notifyListeners();
    debugPrint('Restored notification: ${notification.title}');
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    _notifications.clear();
    await _saveNotifications();
    notifyListeners();
  }

  /// Get notifications by type
  List<AppNotification> getNotificationsByType(NotificationType type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  /// Get recent notifications (last 10)
  List<AppNotification> getRecentNotifications() {
    return _notifications.take(10).toList();
  }

  /// Check for weekly budget reminder and achievements
  Future<void> checkWeeklyReminders() async {
    await _checkBudgetReminder();
    await _checkAchievements();
  }

  /// Check and award achievements based on user activity
  Future<void> _checkAchievements() async {
    // This could be expanded with actual achievement logic
    // For now, we'll add a sample achievement for demonstration
    final now = DateTime.now();
    final lastAchievementCheck = _prefs?.getString('last_achievement_check');

    if (lastAchievementCheck == null) {
      // First time - welcome achievement
      await addAchievementNotification(
        'Welcome to Vault Path!',
        'Start your financial journey with us. Track, budget, and achieve your goals!',
      );
      await _prefs?.setString('last_achievement_check', now.toIso8601String());
    }
  }

  /// Set app install date for first-time reminder calculation
  Future<void> setAppInstallDate() async {
    final installDate = _prefs?.getString('app_install_date');
    if (installDate == null) {
      await _prefs?.setString(
        'app_install_date',
        DateTime.now().toIso8601String(),
      );
    }
  }

  /// Check if this is a new device and show welcome notification
  Future<void> _checkNewDeviceAndShowWelcome() async {
    try {
      String currentDeviceId = await _getDeviceIdentifier();
      String? storedDeviceId = _prefs?.getString(_deviceIdKey);

      if (storedDeviceId == null || storedDeviceId != currentDeviceId) {
        // This is a new device
        debugPrint('New device detected: $currentDeviceId');

        // Store the new device ID
        await _prefs?.setString(_deviceIdKey, currentDeviceId);

        // Show welcome notification
        await _showWelcomeNotification();

        // Mark that we've shown the welcome
        await _prefs?.setBool(_welcomeShownKey, true);
      } else {
        debugPrint('Existing device: $currentDeviceId');
      }
    } catch (e) {
      debugPrint('Error checking device for welcome notification: $e');
    }
  }

  /// Get a unique identifier for this device
  Future<String> _getDeviceIdentifier() async {
    try {
      if (kIsWeb) {
        // For web, use a combination of user agent and timestamp on first run
        String? webDeviceId = _prefs?.getString('web_device_id');
        if (webDeviceId == null) {
          webDeviceId = 'web_${DateTime.now().millisecondsSinceEpoch}';
          await _prefs?.setString('web_device_id', webDeviceId);
        }
        return webDeviceId;
      } else {
        // For mobile platforms, use a simple approach with platform info
        String platformInfo = Platform.operatingSystem;
        String? deviceId = _prefs?.getString('mobile_device_id');
        if (deviceId == null) {
          deviceId = '${platformInfo}_${DateTime.now().millisecondsSinceEpoch}';
          await _prefs?.setString('mobile_device_id', deviceId);
        }
        return deviceId;
      }
    } catch (e) {
      debugPrint('Error getting device identifier: $e');
      // Fallback to timestamp-based ID
      String fallbackId = 'device_${DateTime.now().millisecondsSinceEpoch}';
      return fallbackId;
    }
  }

  /// Show welcome notification for new users on new devices
  Future<void> _showWelcomeNotification() async {
    await addNotification(
      AppNotification(
        id: 'welcome_${DateTime.now().millisecondsSinceEpoch}',
        title: '🎉 Welcome to Vault Path!',
        message:
            'Your smart expense tracker is ready! Start by adding your first transaction to begin tracking your finances.',
        type: NotificationType.achievement,
        createdAt: DateTime.now(),
        isRead: false,
        data: {
          'actionText': 'Get Started',
          'actionType': 'navigate_to_add_transaction',
          'isWelcome': true,
          'showTime': DateTime.now().toIso8601String(),
        },
      ),
    );

    debugPrint('Welcome notification sent for new device');
  }

  /// Send a follow-up welcome notification after a delay (optional enhancement)
  Future<void> scheduleFollowUpWelcomeNotification() async {
    // This can be called after a few hours or days to provide tips
    await Future.delayed(const Duration(seconds: 5), () async {
      // Add multiple different notifications for variety
      final notifications = [
        {
          'title': '💡 Quick Tips',
          'message':
              'Did you know? You can set budgets to track your spending goals and get insights about your financial habits.',
        },
        {
          'title': '📊 Track Your Progress',
          'message':
              'Monitor your spending patterns and see where your money goes with detailed analytics.',
        },
        {
          'title': '🎯 Set Your Goals',
          'message':
              'Create budgets for different categories and stay on track with your financial objectives.',
        },
        {
          'title': '📱 Stay Organized',
          'message':
              'Keep all your accounts in one place and never lose track of your transactions.',
        },
      ];

      // Pick a random notification
      final random =
          notifications[DateTime.now().millisecond % notifications.length];

      await addNotification(
        AppNotification(
          id: 'welcome_tips_${DateTime.now().millisecondsSinceEpoch}',
          title: random['title']!,
          message: random['message']!,
          type: NotificationType.general,
          createdAt: DateTime.now(),
          isRead: false,
          data: {
            'actionText': 'Learn More',
            'actionType': 'navigate_to_budgets',
            'isWelcomeTip': true,
          },
        ),
      );
    });
  }

  /// Reset welcome notification state (useful for testing)
  Future<void> resetWelcomeState() async {
    await _prefs?.remove(_deviceIdKey);
    await _prefs?.remove(_welcomeShownKey);
    await _prefs?.remove('web_device_id');
    await _prefs?.remove('mobile_device_id');
    debugPrint('Welcome notification state reset');
  }
}
