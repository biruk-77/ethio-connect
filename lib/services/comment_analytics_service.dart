import 'dart:async';
import '../utils/app_logger.dart';
import 'socket_service.dart';

/// Comment Analytics Service - Handles comment statistics and analytics
/// Based on Abel's backend comment analytics system
class CommentAnalyticsService {
  static final CommentAnalyticsService _instance = CommentAnalyticsService._internal();
  factory CommentAnalyticsService() => _instance;
  CommentAnalyticsService._internal();

  final SocketService _socketService = SocketService();

  // Cache for comment analytics
  final Map<String, Map<String, dynamic>> _commentStatsCache = {};
  final Map<String, List<dynamic>> _commentThreadCache = {};
  final Map<String, List<dynamic>> _commentRepliesCache = {};
  
  // Stream controllers for real-time updates
  final _commentStatsController = StreamController<Map<String, dynamic>>.broadcast();
  final _commentThreadController = StreamController<Map<String, dynamic>>.broadcast();
  
  // Streams for UI updates
  Stream<Map<String, dynamic>> get commentStatsStream => _commentStatsController.stream;
  Stream<Map<String, dynamic>> get commentThreadStream => _commentThreadController.stream;

  /// Initialize comment analytics listeners
  void initialize() {
    // Listen for comment stats updates
    _socketService.on('comment:stats', (data) {
      AppLogger.info('📊 Comment stats received: ${data['targetId']}');
      final targetId = data['targetId'];
      _commentStatsCache[targetId] = data['stats'] ?? {};
      
      // Emit to UI stream
      _commentStatsController.add({
        'targetId': targetId,
        'targetType': data['targetType'],
        'stats': data['stats'],
      });
    });

    // Listen for comment thread updates
    _socketService.on('comment:thread', (data) {
      AppLogger.info('💬 Comment thread received: ${data['commentId']}');
      final commentId = data['commentId'];
      _commentThreadCache[commentId] = data['thread'] ?? [];
      
      // Emit to UI stream
      _commentThreadController.add({
        'commentId': commentId,
        'thread': data['thread'],
      });
    });

    // Listen for comment replies updates
    _socketService.on('comment:replies', (data) {
      AppLogger.info('💭 Comment replies received: ${data['commentId']}');
      final commentId = data['commentId'];
      _commentRepliesCache[commentId] = data['replies'] ?? [];
      
      // Emit to UI stream
      _commentThreadController.add({
        'commentId': commentId,
        'replies': data['replies'],
      });
    });

    // Listen for comment moderation events
    _socketService.on('comment:moderated', (data) {
      AppLogger.info('🚨 Comment moderated: ${data['commentId']} - ${data['action']}');
      
      // Emit to UI stream for moderation updates
      _commentStatsController.add({
        'commentId': data['commentId'],
        'action': 'moderated',
        'moderationAction': data['action'],
        'reason': data['reason'],
      });
    });

    AppLogger.info('📊 Comment Analytics Service initialized');
  }

  /// Get comment statistics for a target (post, user, etc.)
  Future<void> getCommentStats({
    required String targetType,
    required String targetId,
  }) async {
    try {
      AppLogger.info('📊 Getting comment stats: $targetType:$targetId');
      
      await _ensureSocketConnected();
      
      _socketService.emit('comment:stats:get', {
        'targetType': targetType,
        'targetId': targetId,
      });
    } catch (e) {
      AppLogger.error('Failed to get comment stats: $e');
    }
  }

  /// Get comment thread (conversation tree)
  Future<void> getCommentThread(String commentId) async {
    try {
      AppLogger.info('💬 Getting comment thread: $commentId');
      
      await _ensureSocketConnected();
      
      _socketService.emit('comment:thread:get', {
        'commentId': commentId,
      });
    } catch (e) {
      AppLogger.error('Failed to get comment thread: $e');
    }
  }

  /// Get comment replies
  Future<void> getCommentReplies({
    required String commentId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      AppLogger.info('💭 Getting comment replies: $commentId');
      
      await _ensureSocketConnected();
      
      _socketService.emit('comment:replies:get', {
        'commentId': commentId,
        'page': page,
        'limit': limit,
      });
    } catch (e) {
      AppLogger.error('Failed to get comment replies: $e');
    }
  }

  /// Get user's comments across the platform
  Future<void> getUserComments({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      AppLogger.info('👤 Getting user comments: $userId');
      
      await _ensureSocketConnected();
      
      _socketService.emit('comment:user:get', {
        'userId': userId,
        'page': page,
        'limit': limit,
      });
    } catch (e) {
      AppLogger.error('Failed to get user comments: $e');
    }
  }

  /// Moderate a comment (admin/moderator function)
  Future<void> moderateComment({
    required String commentId,
    required String action, // 'approve', 'reject', 'hide', 'delete'
    String? reason,
  }) async {
    try {
      AppLogger.info('🚨 Moderating comment: $commentId - $action');
      
      await _ensureSocketConnected();
      
      _socketService.emit('comment:moderate', {
        'commentId': commentId,
        'action': action,
        if (reason != null) 'reason': reason,
      });
    } catch (e) {
      AppLogger.error('Failed to moderate comment: $e');
    }
  }

  /// Get cached comment stats
  Map<String, dynamic>? getCachedCommentStats(String targetId) {
    return _commentStatsCache[targetId];
  }

  /// Get cached comment thread
  List<dynamic>? getCachedCommentThread(String commentId) {
    return _commentThreadCache[commentId];
  }

  /// Get cached comment replies
  List<dynamic>? getCachedCommentReplies(String commentId) {
    return _commentRepliesCache[commentId];
  }

  /// Ensure socket is connected before making requests
  Future<void> _ensureSocketConnected() async {
    if (!_socketService.isConnected) {
      AppLogger.info('🔌 Socket not connected, connecting now...');
      await _socketService.connect();
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  /// Clear cache
  void clearCache() {
    _commentStatsCache.clear();
    _commentThreadCache.clear();
    _commentRepliesCache.clear();
  }

  /// Clean up listeners
  void dispose() {
    _socketService.off('comment:stats');
    _socketService.off('comment:thread');
    _socketService.off('comment:replies');
    _socketService.off('comment:moderated');
    _commentStatsController.close();
    _commentThreadController.close();
  }
}
