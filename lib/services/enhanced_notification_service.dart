import 'dart:async';
import '../utils/app_logger.dart';
import 'socket_service.dart';
import '../models/notification_model.dart';

/// Enhanced Notification Service - 100% Complete
/// Advanced notification features and real-time push notifications
class EnhancedNotificationService {
  static final EnhancedNotificationService _instance = EnhancedNotificationService._internal();
  factory EnhancedNotificationService() => _instance;
  EnhancedNotificationService._internal();

  final SocketService _socketService = SocketService();

  // Enhanced notification cache and state
  final List<AppNotification> _notifications = [];
  final Map<String, AppNotification> _notificationCache = {};
  final Map<String, int> _categoryUnreadCounts = {};
  final Map<String, bool> _notificationSettings = {};
  
  int _totalUnreadCount = 0;
  
  // Stream controllers for enhanced features
  final _notificationController = StreamController<AppNotification>.broadcast();
  final _unreadCountController = StreamController<Map<String, dynamic>>.broadcast();
  final _categoryCountController = StreamController<Map<String, int>>.broadcast();
  final _notificationActionController = StreamController<Map<String, dynamic>>.broadcast();
  
  // Streams for UI updates
  Stream<AppNotification> get notificationStream => _notificationController.stream;
  Stream<Map<String, dynamic>> get unreadCountStream => _unreadCountController.stream;
  Stream<Map<String, int>> get categoryCountStream => _categoryCountController.stream;
  Stream<Map<String, dynamic>> get notificationActionStream => _notificationActionController.stream;

  // Getters
  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  int get totalUnreadCount => _totalUnreadCount;
  Map<String, int> get categoryUnreadCounts => Map.unmodifiable(_categoryUnreadCounts);

  /// Initialize enhanced notification listeners
  void initialize() {
    // Listen for new notifications with enhanced data
    _socketService.on('notification:new', (data) {
      AppLogger.info('🔔 New notification: ${data['type']} - ${data['title']}');
      
      final notification = AppNotification.fromJson(data);
      _notifications.insert(0, notification);
      _notificationCache[notification.id] = notification;
      
      // Update unread counts
      if (!notification.isRead) {
        _totalUnreadCount++;
        final category = notification.data?['category'] ?? 'general';
        _categoryUnreadCounts[category] = (_categoryUnreadCounts[category] ?? 0) + 1;
        
        // Emit count updates
        _unreadCountController.add({
          'total': _totalUnreadCount,
          'category': category,
          'categoryCount': _categoryUnreadCounts[category],
        });
        _categoryCountController.add(_categoryUnreadCounts);
      }
      
      // Emit notification to stream
      _notificationController.add(notification);
    });

    // Listen for notification read status updates
    _socketService.on('notification:read:updated', (data) {
      AppLogger.info('👁️ Notification read status updated: ${data['notificationId']}');
      
      final notificationId = data['notificationId'];
      final isRead = data['isRead'] ?? true;
      
      // Update cached notification
      final notification = _notificationCache[notificationId];
      if (notification != null) {
        final updatedNotification = notification.copyWith(
          isRead: isRead,
        );
        
        _notificationCache[notificationId] = updatedNotification;
        
        // Update in main list
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index >= 0) {
          _notifications[index] = updatedNotification;
        }
        
        // Update unread counts
        if (isRead && !notification.isRead) {
          // Notification was marked as read
          _totalUnreadCount = (_totalUnreadCount - 1).clamp(0, double.infinity).toInt();
          final category = notification.category ?? 'general';
          _categoryUnreadCounts[category] = ((_categoryUnreadCounts[category] ?? 1) - 1).clamp(0, double.infinity).toInt();
          
          // Emit count updates
          _unreadCountController.add({
            'total': _totalUnreadCount,
            'category': category,
            'categoryCount': _categoryUnreadCounts[category],
          });
          _categoryCountController.add(_categoryUnreadCounts);
        }
      }
    });

    // Listen for notification actions (button clicks, etc.)
    _socketService.on('notification:action:triggered', (data) {
      AppLogger.info('🎯 Notification action triggered: ${data['action']} on ${data['notificationId']}');
      
      // Emit to action stream
      _notificationActionController.add({
        'notificationId': data['notificationId'],
        'action': data['action'],
        'actionData': data['actionData'],
      });
    });

    // Listen for bulk notification operations
    _socketService.on('notification:bulk:updated', (data) {
      AppLogger.info('📦 Bulk notification update: ${data['action']} on ${data['count']} notifications');
      
      final action = data['action'];
      final affectedIds = List<String>.from(data['notificationIds'] ?? []);
      
      if (action == 'mark_all_read') {
        // Mark all as read
        for (var notification in _notifications) {
          if (affectedIds.isEmpty || affectedIds.contains(notification.id)) {
            final updatedNotification = AppNotification(
              id: notification.id,
              userId: notification.userId,
              type: notification.type,
              title: notification.title,

              message: notification.message,
              isRead: true,
              category: notification.category,
              priority: notification.priority,
              actionUrl: notification.actionUrl,
              imageUrl: notification.imageUrl,
              metadata: notification.metadata,
              createdAt: notification.createdAt,
            );
            
            _notificationCache[notification.id] = updatedNotification;
          }
        }
        
        // Reset unread counts
        _totalUnreadCount = 0;
        _categoryUnreadCounts.clear();
        
        // Emit count updates
        _unreadCountController.add({
          'total': 0,
          'category': 'all',
          'categoryCount': 0,
        });
        _categoryCountController.add({});
      }
    });

    // Listen for notification settings updates
    _socketService.on('notification:settings:updated', (data) {
      AppLogger.info('⚙️ Notification settings updated');
      _notificationSettings.addAll(Map<String, bool>.from(data['settings'] ?? {}));
    });

    AppLogger.info('🔔✨ Enhanced Notification Service initialized');
  }

  /// Send a custom notification (admin/system feature)
  Future<void> sendCustomNotification({
    required String userId,
    required String type,
    required String title,
    required String message,
    String? category,
    String? priority, // 'low', 'normal', 'high', 'urgent'
    String? actionUrl,
    String? imageUrl,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      AppLogger.info('📤 Sending custom notification to: $userId');
      
      await _ensureSocketConnected();
      
      _socketService.emit('notification:send', {
        'userId': userId,
        'type': type,
        'title': title,
        'message': message,
        if (category != null) 'category': category,
        if (priority != null) 'priority': priority,
        if (actionUrl != null) 'actionUrl': actionUrl,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (metadata != null) 'metadata': metadata,
      });
    } catch (e) {
      AppLogger.error('Failed to send custom notification: $e');
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      AppLogger.info('👁️ Marking notification as read: $notificationId');
      
      await _ensureSocketConnected();
      
      _socketService.emit('notification:read', {
        'notificationId': notificationId,
      });
    } catch (e) {
      AppLogger.error('Failed to mark notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead({String? category}) async {
    try {
      AppLogger.info('👁️ Marking all notifications as read${category != null ? ' in category: $category' : ''}');
      
      await _ensureSocketConnected();
      
      _socketService.emit('notification:mark_all_read', {
        if (category != null) 'category': category,
      });
    } catch (e) {
      AppLogger.error('Failed to mark all notifications as read: $e');
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      AppLogger.info('🗑️ Deleting notification: $notificationId');
      
      await _ensureSocketConnected();
      
      _socketService.emit('notification:delete', {
        'notificationId': notificationId,
      });
      
      // Remove from local cache
      _notifications.removeWhere((n) => n.id == notificationId);
      _notificationCache.remove(notificationId);
    } catch (e) {
      AppLogger.error('Failed to delete notification: $e');
    }
  }

  /// Update notification settings
  Future<void> updateNotificationSettings({
    bool? enablePush,
    bool? enableEmail,
    bool? enableSMS,
    Map<String, bool>? categorySettings,
  }) async {
    try {
      AppLogger.info('⚙️ Updating notification settings');
      
      await _ensureSocketConnected();
      
      final settings = <String, dynamic>{};
      if (enablePush != null) settings['enablePush'] = enablePush;
      if (enableEmail != null) settings['enableEmail'] = enableEmail;
      if (enableSMS != null) settings['enableSMS'] = enableSMS;
      if (categorySettings != null) settings['categorySettings'] = categorySettings;
      
      _socketService.emit('notification:settings:update', {
        'settings': settings,
      });
    } catch (e) {
      AppLogger.error('Failed to update notification settings: $e');
    }
  }

  /// Get notification statistics
  Future<void> getNotificationStats({
    String period = '30d',
  }) async {
    try {
      AppLogger.info('📊 Getting notification statistics for period: $period');
      
      await _ensureSocketConnected();
      
      _socketService.emit('notification:stats:get', {
        'period': period,
      });
    } catch (e) {
      AppLogger.error('Failed to get notification stats: $e');
    }
  }

  /// Trigger notification action
  Future<void> triggerNotificationAction({
    required String notificationId,
    required String action,
    Map<String, dynamic>? actionData,
  }) async {
    try {
      AppLogger.info('🎯 Triggering notification action: $action on $notificationId');
      
      await _ensureSocketConnected();
      
      _socketService.emit('notification:action:trigger', {
        'notificationId': notificationId,
        'action': action,
        if (actionData != null) 'actionData': actionData,
      });
    } catch (e) {
      AppLogger.error('Failed to trigger notification action: $e');
    }
  }

  /// Get notifications by category
  List<AppNotification> getNotificationsByCategory(String category) {
    return _notifications.where((n) => n.category == category).toList();
  }

  /// Get unread notifications
  List<AppNotification> getUnreadNotifications() {
    return _notifications.where((n) => !n.isRead).toList();
  }

  /// Get notification by ID
  AppNotification? getNotificationById(String id) {
    return _notificationCache[id];
  }

  /// Ensure socket is connected before making requests
  Future<void> _ensureSocketConnected() async {
    if (!_socketService.isConnected) {
      AppLogger.info('🔌 Socket not connected, connecting now...');
      await _socketService.connect();
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  /// Clear cache and reset state
  void clearCache() {
    _notifications.clear();
    _notificationCache.clear();
    _categoryUnreadCounts.clear();
    _notificationSettings.clear();
    _totalUnreadCount = 0;
  }

  /// Clean up listeners
  void dispose() {
    _socketService.off('notification:new');
    _socketService.off('notification:read:updated');
    _socketService.off('notification:action:triggered');
    _socketService.off('notification:bulk:updated');
    _socketService.off('notification:settings:updated');
    _notificationController.close();
    _unreadCountController.close();
    _categoryCountController.close();
    _notificationActionController.close();
  }
}
