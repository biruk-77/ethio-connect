import 'dart:async';
import '../services/socket_service.dart';
import '../services/auth/auth_service.dart';
import '../utils/app_logger.dart';

/// Like Service - Manages matchmaking likes/skips (dating/networking)
/// Based on backend: test/test/logs/like.service.js
/// NOTE: This is different from FavoritesService (bookmarking posts)
class LikeService {
  static final LikeService _instance = LikeService._internal();
  factory LikeService() => _instance;
  LikeService._internal();

  final SocketService _socketService = SocketService();
  final AuthService _authService = AuthService();

  /// Create a like or skip
  Future<Map<String, dynamic>> createLike({
    required String likedId,
    String status = 'like', // 'like' or 'skip'
  }) async {
    try {
      final completer = Completer<Map<String, dynamic>>();

      void responseHandler(dynamic data) {
        if (!completer.isCompleted) {
          AppLogger.success('✅ ${status == 'like' ? 'Liked' : 'Skipped'} user');
          completer.complete({
            'like': data['like'],
            'isMutual': data['isMutual'] ?? false,
          });
          _socketService.off('like:created', responseHandler);
        }
      }

      _socketService.on('like:created', responseHandler);

      _socketService.emit('like:create', {
        'likedId': likedId,
        'status': status,
      });

      return await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          _socketService.off('like:created', responseHandler);
          throw Exception('Create like timed out');
        },
      );
    } catch (e) {
      AppLogger.error('Failed to create like: $e');
      rethrow;
    }
  }

  /// Unlike a user
  Future<void> unlike(String likedId) async {
    try {
      final completer = Completer<void>();

      void responseHandler(dynamic data) {
        if (!completer.isCompleted) {
          AppLogger.success('✅ Unliked user');
          completer.complete();
          _socketService.off('like:removed', responseHandler);
        }
      }

      _socketService.on('like:removed', responseHandler);

      _socketService.emit('like:remove', {
        'likedId': likedId,
      });

      return await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          _socketService.off('like:removed', responseHandler);
          throw Exception('Unlike timed out');
        },
      );
    } catch (e) {
      AppLogger.error('Failed to unlike: $e');
      rethrow;
    }
  }

  /// Get user's likes
  Future<Map<String, dynamic>> getUserLikes({
    int page = 1,
    int limit = 20,
    String status = 'like',
  }) async {
    try {
      final completer = Completer<Map<String, dynamic>>();

      void responseHandler(dynamic data) {
        if (!completer.isCompleted) {
          final likes = data['likes'] ?? [];
          AppLogger.success('✅ Loaded ${likes.length} likes');
          completer.complete(data);
          _socketService.off('likes:list', responseHandler);
        }
      }

      _socketService.on('likes:list', responseHandler);

      _socketService.emit('likes:get', {
        'page': page,
        'limit': limit,
        'status': status,
      });

      return await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          _socketService.off('likes:list', responseHandler);
          throw Exception('Get likes timed out');
        },
      );
    } catch (e) {
      AppLogger.error('Failed to get likes: $e');
      rethrow;
    }
  }

  /// Get mutual likes (matches)
  Future<Map<String, dynamic>> getMutualLikes({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final completer = Completer<Map<String, dynamic>>();

      void responseHandler(dynamic data) {
        if (!completer.isCompleted) {
          final matches = data['matches'] ?? [];
          AppLogger.success('✅ Loaded ${matches.length} matches');
          completer.complete(data);
          _socketService.off('likes:matches', responseHandler);
        }
      }

      _socketService.on('likes:matches', responseHandler);

      _socketService.emit('likes:mutual', {
        'page': page,
        'limit': limit,
      });

      return await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          _socketService.off('likes:matches', responseHandler);
          throw Exception('Get matches timed out');
        },
      );
    } catch (e) {
      AppLogger.error('Failed to get matches: $e');
      rethrow;
    }
  }

  /// Get users who liked you
  Future<Map<String, dynamic>> getUserLikers({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final completer = Completer<Map<String, dynamic>>();

      void responseHandler(dynamic data) {
        if (!completer.isCompleted) {
          final likers = data['likes'] ?? [];
          AppLogger.success('✅ Loaded ${likers.length} likers');
          completer.complete(data);
          _socketService.off('likers:list', responseHandler);
        }
      }

      _socketService.on('likers:list', responseHandler);

      _socketService.emit('likers:get', {
        'page': page,
        'limit': limit,
      });

      return await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          _socketService.off('likers:list', responseHandler);
          throw Exception('Get likers timed out');
        },
      );
    } catch (e) {
      AppLogger.error('Failed to get likers: $e');
      rethrow;
    }
  }

  /// Check if mutual like exists
  Future<bool> checkMutualLike(String userId) async {
    try {
      final completer = Completer<bool>();

      void responseHandler(dynamic data) {
        if (!completer.isCompleted) {
          completer.complete(data['isMutual'] ?? false);
          _socketService.off('like:mutual:status', responseHandler);
        }
      }

      _socketService.on('like:mutual:status', responseHandler);

      _socketService.emit('like:mutual:check', {
        'userId': userId,
      });

      return await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          _socketService.off('like:mutual:status', responseHandler);
          return false;
        },
      );
    } catch (e) {
      AppLogger.error('Failed to check mutual like: $e');
      return false;
    }
  }

  /// Listen for real-time match notifications
  void onNewMatch(Function(dynamic) callback) {
    _socketService.on('like:match', callback);
  }

  /// Clean up listeners
  void dispose() {
    _socketService.off('like:created');
    _socketService.off('like:removed');
    _socketService.off('likes:list');
    _socketService.off('likes:matches');
    _socketService.off('likers:list');
    _socketService.off('like:match');
  }
}
