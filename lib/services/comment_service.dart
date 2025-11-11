import 'dart:async';
import '../services/socket_service.dart';
import '../services/auth/auth_service.dart';
import '../utils/app_logger.dart';

/// Comment Service - Handles thread-based commenting on posts/profiles
/// Based on backend: test/test/logs/comment.service.js
class CommentService {
  static final CommentService _instance = CommentService._internal();
  factory CommentService() => _instance;
  CommentService._internal();

  final SocketService _socketService = SocketService();
  final AuthService _authService = AuthService();

  /// Create a comment on a post or profile
  Future<Map<String, dynamic>> createComment({
    required String targetType, // 'Post' or 'Profile'
    required String targetId,
    required String content,
    String? parentId, // For replies
  }) async {
    try {
      final completer = Completer<Map<String, dynamic>>();

      // Listen for response
      void responseHandler(dynamic data) {
        if (!completer.isCompleted) {
          if (data['success'] == true) {
            AppLogger.success('✅ Comment created');
            completer.complete(data['data']);
          } else {
            completer.completeError(Exception(data['message'] ?? 'Failed to create comment'));
          }
          _socketService.off('comment:created', responseHandler);
        }
      }

      _socketService.on('comment:created', responseHandler);

      // Emit request
      _socketService.emit('comment:create', {
        'targetType': targetType,
        'targetId': targetId,
        'content': content,
        if (parentId != null) 'parentId': parentId,
      });

      return await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          _socketService.off('comment:created', responseHandler);
          throw Exception('Comment creation timed out');
        },
      );
    } catch (e) {
      AppLogger.error('Failed to create comment: $e');
      rethrow;
    }
  }

  /// Get comments for a target (post or profile)
  Future<Map<String, dynamic>> getComments({
    required String targetType,
    required String targetId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final completer = Completer<Map<String, dynamic>>();

      void responseHandler(dynamic data) {
        if (!completer.isCompleted) {
          AppLogger.success('✅ Loaded ${data['comments']?.length ?? 0} comments');
          completer.complete(data);
          _socketService.off('comments:list', responseHandler);
        }
      }

      _socketService.on('comments:list', responseHandler);

      _socketService.emit('comments:get', {
        'targetType': targetType,
        'targetId': targetId,
        'page': page,
        'limit': limit,
      });

      return await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          _socketService.off('comments:list', responseHandler);
          throw Exception('Get comments timed out');
        },
      );
    } catch (e) {
      AppLogger.error('Failed to get comments: $e');
      rethrow;
    }
  }

  /// Get replies to a comment
  Future<Map<String, dynamic>> getReplies({
    required String commentId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final completer = Completer<Map<String, dynamic>>();

      void responseHandler(dynamic data) {
        if (!completer.isCompleted) {
          completer.complete(data);
          _socketService.off('replies:list', responseHandler);
        }
      }

      _socketService.on('replies:list', responseHandler);

      _socketService.emit('replies:get', {
        'commentId': commentId,
        'page': page,
        'limit': limit,
      });

      return await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          _socketService.off('replies:list', responseHandler);
          throw Exception('Get replies timed out');
        },
      );
    } catch (e) {
      AppLogger.error('Failed to get replies: $e');
      rethrow;
    }
  }

  /// Update a comment
  Future<Map<String, dynamic>> updateComment({
    required String commentId,
    required String content,
  }) async {
    try {
      final completer = Completer<Map<String, dynamic>>();

      void responseHandler(dynamic data) {
        if (!completer.isCompleted) {
          if (data['success'] == true) {
            AppLogger.success('✅ Comment updated');
            completer.complete(data['data']);
          } else {
            completer.completeError(Exception(data['message'] ?? 'Failed to update comment'));
          }
          _socketService.off('comment:updated', responseHandler);
        }
      }

      _socketService.on('comment:updated', responseHandler);

      _socketService.emit('comment:update', {
        'commentId': commentId,
        'content': content,
      });

      return await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          _socketService.off('comment:updated', responseHandler);
          throw Exception('Update comment timed out');
        },
      );
    } catch (e) {
      AppLogger.error('Failed to update comment: $e');
      rethrow;
    }
  }

  /// Delete a comment
  Future<void> deleteComment(String commentId) async {
    try {
      final completer = Completer<void>();

      void responseHandler(dynamic data) {
        if (!completer.isCompleted) {
          if (data['success'] == true) {
            AppLogger.success('✅ Comment deleted');
            completer.complete();
          } else {
            completer.completeError(Exception(data['message'] ?? 'Failed to delete comment'));
          }
          _socketService.off('comment:deleted', responseHandler);
        }
      }

      _socketService.on('comment:deleted', responseHandler);

      _socketService.emit('comment:delete', {
        'commentId': commentId,
      });

      return await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          _socketService.off('comment:deleted', responseHandler);
          throw Exception('Delete comment timed out');
        },
      );
    } catch (e) {
      AppLogger.error('Failed to delete comment: $e');
      rethrow;
    }
  }

  /// Listen for real-time comment updates
  void onCommentCreated(Function(dynamic) callback) {
    _socketService.on('comment:created', callback);
  }

  void onCommentUpdated(Function(dynamic) callback) {
    _socketService.on('comment:updated', callback);
  }

  void onCommentDeleted(Function(dynamic) callback) {
    _socketService.on('comment:deleted', callback);
  }

  /// Listen for typing indicators
  void onUserTyping(Function(dynamic) callback) {
    _socketService.on('comment:typing', callback);
  }

  /// Emit typing indicator
  void startTyping({
    required String targetType,
    required String targetId,
  }) {
    _socketService.emit('comment:typing:start', {
      'targetType': targetType,
      'targetId': targetId,
    });
  }

  void stopTyping({
    required String targetType,
    required String targetId,
  }) {
    _socketService.emit('comment:typing:stop', {
      'targetType': targetType,
      'targetId': targetId,
    });
  }

  /// Clean up listeners
  void dispose() {
    _socketService.off('comment:created');
    _socketService.off('comment:updated');
    _socketService.off('comment:deleted');
    _socketService.off('comment:typing');
  }
}
