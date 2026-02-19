import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/notification_service.dart';
import '../models/notification.dart';
import '../utils/format_utils.dart';

/// Screen showing all user notifications
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Mark all as read when user opens notifications
      context.read<NotificationService>().markAllAsRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationService>(
      builder: (context, notificationService, child) {
        final notifications = notificationService.notifications;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            backgroundColor: const Color(0xFF006E1F),
            elevation: 0,
            title: const Text(
              'Notifications',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),
          body:
              notifications.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return _buildNotificationCard(
                        context,
                        notification,
                        notificationService,
                      );
                    },
                  ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'ll see updates about your finances here',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    AppNotification notification,
    NotificationService service,
  ) {
    // Automatically mark as read when displayed
    if (!notification.isRead) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          service.markAsRead(notification.id);
        }
      });
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Dismissible(
        key: Key(notification.id),
        direction: DismissDirection.endToStart,
        background: Container(
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.delete, color: Colors.white, size: 24),
              SizedBox(height: 4),
              Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        onDismissed: (direction) {
          final deletedNotification = service.deleteNotification(
            notification.id,
          );
          if (deletedNotification != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Notification deleted'),
                backgroundColor: const Color(0xFF006E1F),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 4),
                action: SnackBarAction(
                  label: 'Undo',
                  textColor: Colors.white,
                  onPressed: () {
                    service.undoDeleteNotification(deletedNotification);
                  },
                ),
              ),
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                spreadRadius: 0,
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
            border:
                notification.isRead
                    ? null
                    : Border.all(
                      color: const Color(0xFF006E1F).withOpacity(0.2),
                      width: 1.5,
                    ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notification icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _getNotificationColor(
                          notification.type,
                        ).withOpacity(0.15),
                        _getNotificationColor(
                          notification.type,
                        ).withOpacity(0.25),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      notification.type.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and timestamp row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    notification.isRead
                                        ? FontWeight.w600
                                        : FontWeight.bold,
                                color: const Color(0xFF1A1A1A),
                                height: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatNotificationTime(notification.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Message
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // New indicator only
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // New indicator
                          if (!notification.isRead)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF006E1F),
                                    Color(0xFF00A040),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'NEW',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.income:
        return const Color(0xFF4CAF50);
      case NotificationType.expense:
        return const Color(0xFFFF5722);
      case NotificationType.budget:
        return const Color(0xFF2196F3);
      case NotificationType.reminder:
        return const Color(0xFFFF9800);
      case NotificationType.achievement:
        return const Color(0xFF9C27B0);
      case NotificationType.general:
        return const Color(0xFF006E1F);
    }
  }

  String _formatNotificationTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return FormatUtils.formatDate(dateTime);
    }
  }

  void _showClearAllDialog(BuildContext context, NotificationService service) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear All Notifications'),
            content: const Text(
              'Are you sure you want to delete all notifications? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  service.clearAllNotifications();
                  Navigator.pop(context);
                },
                child: const Text(
                  'Clear All',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
