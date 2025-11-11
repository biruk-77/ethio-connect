import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/notification_model.dart';
import '../../services/notification_service.dart';

/// Notifications Screen
/// Shows all user notifications
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  List<AppNotification> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();

    // Listen for new notifications
    _notificationService.notificationStream.listen((notification) {
      if (mounted) {
        setState(() {
          _notifications = _notificationService.notifications;
        });
      }
    });
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _notifications = _notificationService.notifications;
    });
    
    // Fetch from backend
    await _notificationService.fetchNotifications();
    
    if (mounted) {
      setState(() {
        _notifications = _notificationService.notifications;
      });
    }
  }

  Future<void> _markAsRead(AppNotification notification) async {
    await _notificationService.markAsRead(notification.id);
    if (mounted) {
      setState(() {
        _notifications = _notificationService.notifications;
      });
    }
  }

  Future<void> _markAllAsRead() async {
    await _notificationService.markAllAsRead();
    if (mounted) {
      setState(() {
        _notifications = _notificationService.notifications;
      });
    }
  }

  void _clearAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all notifications?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _notificationService.clearAll();
              setState(() {
                _notifications = [];
              });
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case NotificationType.like:
        return Icons.favorite;
      case NotificationType.comment:
        return Icons.comment;
      case NotificationType.reply:
        return Icons.reply;
      case NotificationType.match:
        return Icons.favorite;
      case NotificationType.message:
        return Icons.message;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case NotificationType.like:
        return Colors.red;
      case NotificationType.comment:
        return Colors.blue;
      case NotificationType.reply:
        return Colors.green;
      case NotificationType.match:
        return Colors.pink;
      case NotificationType.message:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (_notifications.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.done_all),
              onPressed: _markAllAsRead,
              tooltip: 'Mark all as read',
            ),
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clearAll,
              tooltip: 'Clear all',
            ),
          ],
        ],
      ),
      body: _notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                _loadNotifications();
              },
              child: ListView.builder(
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  return _buildNotificationTile(notification);
                },
              ),
            ),
    );
  }

  Widget _buildNotificationTile(AppNotification notification) {
    final icon = _getNotificationIcon(notification.type);
    final color = _getNotificationColor(notification.type);

    return Dismissible(
      key: Key(notification.id),
      background: Container(
        color: Colors.green,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        child: const Icon(Icons.done, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Mark as read
          _markAsRead(notification);
          return false;
        } else {
          // Delete
          return true;
        }
      },
      onDismissed: (direction) {
        // Remove from list (already dismissed)
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        color: notification.isRead ? null : Colors.blue.withOpacity(0.05),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color, size: 20),
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(notification.body),
              const SizedBox(height: 4),
              Text(
                timeago.format(notification.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          trailing: !notification.isRead
              ? Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
          onTap: () {
            if (!notification.isRead) {
              _markAsRead(notification);
            }
            // TODO: Navigate based on notification type and data
          },
        ),
      ),
    );
  }
}
