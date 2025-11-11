import 'package:dio/dio.dart';
import '../config/communication_config.dart';
import '../utils/app_logger.dart';
import 'auth/auth_service.dart';

/// Notification API Client
/// Handles REST API calls for notifications
class NotificationApiClient {
  static final NotificationApiClient _instance = NotificationApiClient._internal();
  factory NotificationApiClient() => _instance;
  NotificationApiClient._internal();

  final Dio _dio = Dio(BaseOptions(
    baseUrl: CommunicationConfig.apiUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  final AuthService _authService = AuthService();

  /// Get auth headers with Bearer token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Get all notifications
  Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int limit = 20,
    bool unreadOnly = false,
  }) async {
    try {
      AppLogger.info('📥 Fetching notifications (page: $page, limit: $limit, unreadOnly: $unreadOnly)');
      
      final headers = await _getHeaders();
      final response = await _dio.get(
        '/api/v1/notifications',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (unreadOnly) 'unreadOnly': true,
        },
        options: Options(headers: headers),
      );

      AppLogger.success('✅ Notifications fetched: ${response.data['notifications']?.length ?? 0} items');
      return response.data;
    } on DioException catch (e) {
      AppLogger.error('❌ Failed to fetch notifications: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized - please login again');
      }
      throw Exception('Failed to load notifications: ${e.message}');
    } catch (e) {
      AppLogger.error('❌ Unexpected error: $e');
      throw Exception('Failed to load notifications');
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      AppLogger.info('✅ Marking notification as read: $notificationId');
      
      final headers = await _getHeaders();
      await _dio.put(
        '/api/v1/notifications/$notificationId/read',
        options: Options(headers: headers),
      );

      AppLogger.success('✅ Notification marked as read');
    } on DioException catch (e) {
      AppLogger.error('❌ Failed to mark notification as read: ${e.message}');
      throw Exception('Failed to update notification');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      AppLogger.info('✅ Marking all notifications as read');
      
      final headers = await _getHeaders();
      await _dio.put(
        '/api/v1/notifications/read-all',
        options: Options(headers: headers),
      );

      AppLogger.success('✅ All notifications marked as read');
    } on DioException catch (e) {
      AppLogger.error('❌ Failed to mark all notifications as read: ${e.message}');
      throw Exception('Failed to update notifications');
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      AppLogger.info('🗑️ Deleting notification: $notificationId');
      
      final headers = await _getHeaders();
      await _dio.delete(
        '/api/v1/notifications/$notificationId',
        options: Options(headers: headers),
      );

      AppLogger.success('✅ Notification deleted');
    } on DioException catch (e) {
      AppLogger.error('❌ Failed to delete notification: ${e.message}');
      throw Exception('Failed to delete notification');
    }
  }

  /// Get unread notification count
  Future<int> getUnreadCount() async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '/api/v1/notifications/unread-count',
        options: Options(headers: headers),
      );

      final count = response.data['count'] ?? 0;
      AppLogger.info('📊 Unread notifications: $count');
      return count;
    } on DioException catch (e) {
      AppLogger.error('❌ Failed to get unread count: ${e.message}');
      return 0;
    }
  }
}
