import 'dart:async';
import '../models/notification_model.dart';
import '../utils/app_logger.dart';
import 'socket_service.dart';
import 'auth/auth_service.dart';
import 'notification_api_client.dart';

/// Notification Service
/// Handles push notifications via Socket.IO
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final SocketService _socketService = SocketService();
  final AuthService _authService = AuthService();
  final NotificationApiClient _apiClient = NotificationApiClient();

  final List<AppNotification> _notifications = [];
  int _unreadCount = 0;

  // Stream controller for notification updates
  final _notificationController = StreamController<AppNotification>.broadcast();
  final _unreadCountController = StreamController<int>.broadcast();

  Stream<AppNotification> get notificationStream => _notificationController.stream;
  Stream<int> get unreadCountStream => _unreadCountController.stream;

  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _unreadCount;

  /// Initialize notification listeners and fetch from backend
  void initialize() async {
    // Listen for incoming notifications
    _socketService.on('notification', (data) {
      AppLogger.info('🔔 Notification received: ${data['type']}');
      
      final notification = AppNotification.fromJson(data);
      _notifications.insert(0, notification);
      
      if (!notification.isRead) {
        _unreadCount++;
        _unreadCountController.add(_unreadCount);
      }
      
      _notificationController.add(notification);
    });

    // Listen for notification sent confirmation
    _socketService.on('notification:sent', (data) {
      AppLogger.success('✅ Notification sent: ${data['type']}');
    });

    AppLogger.info('📱 Notification service initialized');
    
    // Fetch notifications from backend
    await fetchNotifications();
  }

  /// Fetch notifications from backend API
  Future<void> fetchNotifications({int page = 1, int limit = 50}) async {
    try {
      AppLogger.info('📥 Fetching notifications from backend...');
      
      final response = await _apiClient.getNotifications(
        page: page,
        limit: limit,
      );
      
      final notificationsList = response['notifications'] as List?;
      if (notificationsList != null) {
        _notifications.clear();
        
        for (var notifData in notificationsList) {
          final notification = AppNotification.fromJson(notifData);
          _notifications.add(notification);
          
          if (!notification.isRead) {
            _unreadCount++;
          }
        }
        
        _unreadCountController.add(_unreadCount);
        AppLogger.success('✅ Loaded ${_notifications.length} notifications from backend');
      }
    } catch (e) {
      AppLogger.error('Failed to fetch notifications from backend: $e');
    }
  }

  /// Refresh unread count from backend
  Future<void> refreshUnreadCount() async {
    try {
      final count = await _apiClient.getUnreadCount();
      _unreadCount = count;
      _unreadCountController.add(_unreadCount);
    } catch (e) {
      AppLogger.error('Failed to refresh unread count: $e');
    }
  }

  /// Send post like notification
  Future<void> sendPostLikeNotification({
    required String postId,
    required String postOwnerId,
    required String postTitle,
  }) async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) return;

      // Don't send notification to self
      if (currentUser.id == postOwnerId) return;

      AppLogger.info('👍 Sending post like notification');
      
      _socketService.emit('notification:post:like', {
        'postOwnerId': postOwnerId,
        'post': {
          'id': postId,
          'title': postTitle,
        },
        'liker': {
          'id': currentUser.id,
          'username': currentUser.username,
          'displayName': currentUser.profile?.fullName ?? currentUser.username,
        },
      });
    } catch (e) {
      AppLogger.error('Failed to send like notification: $e');
    }
  }

  /// Send post comment notification
  Future<void> sendPostCommentNotification({
    required String postId,
    required String postOwnerId,
    required String postTitle,
    required String commentId,
    required String commentContent,
  }) async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) return;

      // Don't send notification to self
      if (currentUser.id == postOwnerId) return;

      AppLogger.info('💬 Sending post comment notification');
      
      _socketService.emit('notification:post:comment', {
        'postOwnerId': postOwnerId,
        'post': {
          'id': postId,
          'title': postTitle,
        },
        'comment': {
          'id': commentId,
          'content': commentContent,
        },
        'commenter': {
          'id': currentUser.id,
          'username': currentUser.username,
          'displayName': currentUser.profile?.fullName ?? currentUser.username,
        },
      });
    } catch (e) {
      AppLogger.error('Failed to send comment notification: $e');
    }
  }

  /// Send comment reply notification
  Future<void> sendCommentReplyNotification({
    required String commentId,
    required String commentOwnerId,
    required String commentContent,
    required String replyId,
    required String replyContent,
  }) async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) return;

      // Don't send notification to self
      if (currentUser.id == commentOwnerId) return;

      AppLogger.info('💭 Sending comment reply notification');
      
      _socketService.emit('notification:comment:reply', {
        'commentOwnerId': commentOwnerId,
        'comment': {
          'id': commentId,
          'content': commentContent,
        },
        'reply': {
          'id': replyId,
          'content': replyContent,
        },
        'replier': {
          'id': currentUser.id,
          'username': currentUser.username,
          'displayName': currentUser.profile?.fullName ?? currentUser.username,
        },
      });
    } catch (e) {
      AppLogger.error('Failed to send reply notification: $e');
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      // Update backend first
      await _apiClient.markAsRead(notificationId);
      
      // Update local state
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1 && !_notifications[index].isRead) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
        _unreadCountController.add(_unreadCount);
      }
    } catch (e) {
      AppLogger.error('Failed to mark notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      // Update backend first
      await _apiClient.markAllAsRead();
      
      // Update local state
      for (var i = 0; i < _notifications.length; i++) {
        if (!_notifications[i].isRead) {
          _notifications[i] = _notifications[i].copyWith(isRead: true);
        }
      }
      _unreadCount = 0;
      _unreadCountController.add(_unreadCount);
    } catch (e) {
      AppLogger.error('Failed to mark all notifications as read: $e');
    }
  }

  /// Clear all notifications
  void clearAll() {
    _notifications.clear();
    _unreadCount = 0;
    _unreadCountController.add(_unreadCount);
  }

  /// Dispose
  void dispose() {
    _notificationController.close();
    _unreadCountController.close();
  }
}
