import 'dart:async';
import '../models/post_like_model.dart';
import '../services/socket_service.dart';
import '../services/auth/auth_service.dart';
import '../services/notification_service.dart';
import '../utils/app_logger.dart';

/// Post Like Service - Manages likes on posts (different from matchmaking likes)
class PostLikeService {
  static final PostLikeService _instance = PostLikeService._internal();
  factory PostLikeService() => _instance;
  PostLikeService._internal();

  final SocketService _socketService = SocketService();
  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService();

  /// Like a post
  Future<PostLike> likePost({
    required String postId,
    String type = 'like',
  }) async {
    try {
      final completer = Completer<PostLike>();

      void responseHandler(dynamic data) {
        if (!completer.isCompleted) {
          if (data['success'] == true) {
            AppLogger.success('✅ Post ${type}d');
            final postLike = PostLike.fromJson(data['data']);
            completer.complete(postLike);
            
            // Send notification to post owner
            if (data['post'] != null) {
              _notificationService.sendPostLikeNotification(
                postId: postId,
                postOwnerId: data['post']['userId'],
                postTitle: data['post']['title'] ?? 'Untitled Post',
              );
            }
          } else {
            completer.completeError(Exception(data['message'] ?? 'Failed to like post'));
          }
          _socketService.off('post:liked', responseHandler);
        }
      }

      _socketService.on('post:liked', responseHandler);

      _socketService.emit('post:like', {
        'postId': postId,
        'type': type,
      });

      return await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          _socketService.off('post:liked', responseHandler);
          throw Exception('Post like timed out');
        },
      );
    } catch (e) {
      AppLogger.error('Failed to like post: $e');
      rethrow;
    }
  }

  /// Unlike a post
  Future<void> unlikePost(String postId) async {
    try {
      final completer = Completer<void>();

      void responseHandler(dynamic data) {
        if (!completer.isCompleted) {
          if (data['success'] == true) {
            AppLogger.success('✅ Post unliked');
            completer.complete();
          } else {
            completer.completeError(Exception(data['message'] ?? 'Failed to unlike post'));
          }
          _socketService.off('post:unliked', responseHandler);
        }
      }

      _socketService.on('post:unliked', responseHandler);

      _socketService.emit('post:unlike', {
        'postId': postId,
      });

      return await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          _socketService.off('post:unliked', responseHandler);
          throw Exception('Post unlike timed out');
        },
      );
    } catch (e) {
      AppLogger.error('Failed to unlike post: $e');
      rethrow;
    }
  }

  /// Get likes for a post
  Future<PostLikeResponse> getPostLikes({
    required String postId,
    int page = 1,
    int limit = 20,
    String? type,
  }) async {
    try {
      final completer = Completer<PostLikeResponse>();

      void responseHandler(dynamic data) {
        if (!completer.isCompleted) {
          AppLogger.success('✅ Loaded ${data['likes']?.length ?? 0} likes');
          completer.complete(PostLikeResponse.fromJson(data));
          _socketService.off('post:likes:list', responseHandler);
        }
      }

      _socketService.on('post:likes:list', responseHandler);

      _socketService.emit('post:likes:get', {
        'postId': postId,
        'page': page,
        'limit': limit,
        if (type != null) 'type': type,
      });

      return await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          _socketService.off('post:likes:list', responseHandler);
          throw Exception('Get post likes timed out');
        },
      );
    } catch (e) {
      AppLogger.error('Failed to get post likes: $e');
      rethrow;
    }
  }

  /// Get user's liked posts
  Future<PostLikeResponse> getUserLikedPosts({
    int page = 1,
    int limit = 20,
    String? type,
  }) async {
    try {
      final completer = Completer<PostLikeResponse>();

      void responseHandler(dynamic data) {
        if (!completer.isCompleted) {
          AppLogger.success('✅ Loaded ${data['likes']?.length ?? 0} liked posts');
          completer.complete(PostLikeResponse.fromJson(data));
          _socketService.off('user:likes:list', responseHandler);
        }
      }

      _socketService.on('user:likes:list', responseHandler);

      _socketService.emit('user:likes:get', {
        'page': page,
        'limit': limit,
        if (type != null) 'type': type,
      });

      return await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          _socketService.off('user:likes:list', responseHandler);
          throw Exception('Get user likes timed out');
        },
      );
    } catch (e) {
      AppLogger.error('Failed to get user likes: $e');
      rethrow;
    }
  }

  /// Check if user has liked a post
  Future<Map<String, dynamic>> checkPostLikeStatus(String postId) async {
    try {
      final completer = Completer<Map<String, dynamic>>();

      void responseHandler(dynamic data) {
        if (!completer.isCompleted) {
          completer.complete({
            'isLiked': data['isLiked'] ?? false,
            'likeType': data['likeType'],
            'likesCount': data['likesCount'] ?? 0,
            'likeBreakdown': data['likeBreakdown'] ?? {},
          });
          _socketService.off('post:like:status', responseHandler);
        }
      }

      _socketService.on('post:like:status', responseHandler);

      _socketService.emit('post:like:check', {
        'postId': postId,
      });

      return await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          _socketService.off('post:like:status', responseHandler);
          return {
            'isLiked': false,
            'likeType': null,
            'likesCount': 0,
            'likeBreakdown': {},
          };
        },
      );
    } catch (e) {
      AppLogger.error('Failed to check post like status: $e');
      return {
        'isLiked': false,
        'likeType': null,
        'likesCount': 0,
        'likeBreakdown': {},
      };
    }
  }

  /// Get post like statistics
  Future<Map<String, dynamic>> getPostLikeStats(String postId) async {
    try {
      final completer = Completer<Map<String, dynamic>>();

      void responseHandler(dynamic data) {
        if (!completer.isCompleted) {
          completer.complete(data);
          _socketService.off('post:likes:stats', responseHandler);
        }
      }

      _socketService.on('post:likes:stats', responseHandler);

      _socketService.emit('post:likes:stats:get', {
        'postId': postId,
      });

      return await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          _socketService.off('post:likes:stats', responseHandler);
          return {};
        },
      );
    } catch (e) {
      AppLogger.error('Failed to get post like stats: $e');
      return {};
    }
  }

  /// Listen for real-time like updates
  void onPostLiked(Function(dynamic) callback) {
    _socketService.on('post:liked', callback);
  }

  void onPostUnliked(Function(dynamic) callback) {
    _socketService.on('post:unliked', callback);
  }

  /// Clean up listeners
  void dispose() {
    _socketService.off('post:liked');
    _socketService.off('post:unliked');
    _socketService.off('post:likes:list');
    _socketService.off('user:likes:list');
    _socketService.off('post:like:status');
    _socketService.off('post:likes:stats');
  }
}
