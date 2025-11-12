import 'dart:async';
import '../utils/app_logger.dart';
import 'socket_service.dart';

/// Comment Like Service - Handles comment likes/unlikes
/// Based on Abel's backend comment interaction system
class CommentLikeService {
  static final CommentLikeService _instance = CommentLikeService._internal();
  factory CommentLikeService() => _instance;
  CommentLikeService._internal();

  final SocketService _socketService = SocketService();

  // Cache for comment like status and counts
  final Map<String, bool> _commentLikeStatusCache = {};
  final Map<String, int> _commentLikeCountCache = {};
  
  // Stream controllers for real-time updates
  final _commentLikeController = StreamController<Map<String, dynamic>>.broadcast();
  final _commentCountController = StreamController<Map<String, dynamic>>.broadcast();
  
  // Streams for UI updates
  Stream<Map<String, dynamic>> get commentLikeStream => _commentLikeController.stream;
  Stream<Map<String, dynamic>> get commentCountStream => _commentCountController.stream;

  /// Initialize comment like listeners
  void initialize() {
    // Listen for comment liked events
    _socketService.on('comment:liked', (data) {
      AppLogger.info('👍 Comment liked: ${data['commentId']}');
      final commentId = data['commentId'];
      _commentLikeStatusCache[commentId] = true;
      
      // Emit to UI stream
      _commentLikeController.add({
        'commentId': commentId,
        'isLiked': true,
        'action': 'liked',
        'userId': data['userId'],
      });
    });

    // Listen for comment unliked events
    _socketService.on('comment:unliked', (data) {
      AppLogger.info('👎 Comment unliked: ${data['commentId']}');
      final commentId = data['commentId'];
      _commentLikeStatusCache[commentId] = false;
      
      // Emit to UI stream
      _commentLikeController.add({
        'commentId': commentId,
        'isLiked': false,
        'action': 'unliked',
        'userId': data['userId'],
      });
    });

    // Listen for comment like count updates
    _socketService.on('comment:likes:count', (data) {
      AppLogger.info('📊 Comment like count: ${data['commentId']} = ${data['count']}');
      final commentId = data['commentId'];
      final count = data['count'] ?? 0;
      _commentLikeCountCache[commentId] = count;
      
      // Emit to UI stream
      _commentCountController.add({
        'commentId': commentId,
        'count': count,
      });
    });

    AppLogger.info('💬👍 Comment Like Service initialized');
  }

  /// Like a comment
  Future<void> likeComment(String commentId) async {
    try {
      AppLogger.info('👍 Liking comment: $commentId');
      
      await _ensureSocketConnected();
      
      _socketService.emit('comment:like', {
        'commentId': commentId,
      });
      
      // Optimistic update
      _commentLikeStatusCache[commentId] = true;
    } catch (e) {
      AppLogger.error('Failed to like comment: $e');
    }
  }

  /// Unlike a comment
  Future<void> unlikeComment(String commentId) async {
    try {
      AppLogger.info('👎 Unliking comment: $commentId');
      
      await _ensureSocketConnected();
      
      _socketService.emit('comment:unlike', {
        'commentId': commentId,
      });
      
      // Optimistic update
      _commentLikeStatusCache[commentId] = false;
    } catch (e) {
      AppLogger.error('Failed to unlike comment: $e');
    }
  }

  /// Toggle comment like status
  Future<void> toggleCommentLike(String commentId) async {
    final isLiked = _commentLikeStatusCache[commentId] ?? false;
    if (isLiked) {
      await unlikeComment(commentId);
    } else {
      await likeComment(commentId);
    }
  }

  /// Get comment like count
  Future<void> getCommentLikeCount(String commentId) async {
    try {
      AppLogger.info('📊 Getting comment like count: $commentId');
      
      await _ensureSocketConnected();
      
      _socketService.emit('comment:likes:count:get', {
        'commentId': commentId,
      });
    } catch (e) {
      AppLogger.error('Failed to get comment like count: $e');
    }
  }

  /// Check if comment is liked by current user
  Future<void> checkCommentLikeStatus(String commentId) async {
    try {
      AppLogger.info('🔍 Checking comment like status: $commentId');
      
      await _ensureSocketConnected();
      
      _socketService.emit('comment:like:status', {
        'commentId': commentId,
      });
    } catch (e) {
      AppLogger.error('Failed to check comment like status: $e');
    }
  }

  /// Get cached comment like status
  bool? getCachedCommentLikeStatus(String commentId) {
    return _commentLikeStatusCache[commentId];
  }

  /// Get cached comment like count
  int? getCachedCommentLikeCount(String commentId) {
    return _commentLikeCountCache[commentId];
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
    _commentLikeStatusCache.clear();
    _commentLikeCountCache.clear();
  }

  /// Clean up listeners
  void dispose() {
    _socketService.off('comment:liked');
    _socketService.off('comment:unliked'); 
    _socketService.off('comment:likes:count');
    _commentLikeController.close();
    _commentCountController.close();
  }
}
