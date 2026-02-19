import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/notification_service.dart';
import '../models/notification.dart';

/// Compact notification card widget for displaying recent notifications
class NotificationCard extends StatelessWidget {
  final bool showViewAll;
  final int maxNotifications;

  const NotificationCard({
    super.key,
    this.showViewAll = true,
    this.maxNotifications = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationService>(
      builder: (context, notificationService, child) {
        final recentNotifications =
            notificationService.notifications.take(maxNotifications).toList();

        if (recentNotifications.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Activity',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF006E1F),
                      ),
                    ),
                    if (showViewAll)
                      TextButton(
                        onPressed: () => context.push('/notifications'),
                        child: const Text(
                          'View All',
                          style: TextStyle(
                            color: Color(0xFF006E1F),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Notifications List
              ...recentNotifications.asMap().entries.map((entry) {
                final index = entry.key;
                final notification = entry.value;
                final isLast = index == recentNotifications.length - 1;

                return Column(
                  children: [
                    _buildNotificationItem(
                      context,
                      notification,
                      notificationService,
                    ),
                    if (!isLast)
                      Divider(
                        height: 1,
                        indent: 20,
                        endIndent: 20,
                        color: Colors.grey.shade200,
                      ),
                  ],
                );
              }),

              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    AppNotification notification,
    NotificationService service,
  ) {
    return InkWell(
      onTap: () {
        if (!notification.isRead) {
          service.markAsRead(notification.id);
        }
        // Handle specific notification actions
        _handleNotificationTap(context, notification);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _getNotificationColor(
                  notification.type,
                ).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Text(
                  notification.type.emoji,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight:
                          notification.isRead
                              ? FontWeight.w500
                              : FontWeight.bold,
                      fontSize: 14,
                      color: const Color(0xFF006E1F),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatNotificationTime(notification.createdAt),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),

            // Unread indicator
            if (!notification.isRead)
              Container(
                margin: const EdgeInsets.only(left: 8, top: 4),
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF006E1F),
                  shape: BoxShape.circle,
                ),
              ),
          ],
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
      return '${difference.inDays}d ago';
    }
  }

  void _handleNotificationTap(
    BuildContext context,
    AppNotification notification,
  ) {
    final data = notification.data;
    if (data != null) {
      switch (data['action']) {
        case 'create_budget':
          context.push('/budgets');
          break;
        // Add more actions as needed
      }
    }
  }
}
