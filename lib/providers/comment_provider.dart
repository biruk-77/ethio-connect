import 'package:flutter/material.dart';
import '../models/comment_model.dart';
import '../services/comment_service.dart';
import '../services/notification_service.dart';
import '../utils/app_logger.dart';

class CommentProvider extends ChangeNotifier {
  final CommentService _commentService = CommentService();
  final NotificationService _notificationService = NotificationService();

  // State
  bool _isLoading = false;
  String? _error;
  List<Comment> _comments = [];
  Map<String, List<Comment>> _replies = {};
  Map<String, bool> _loadingStates = {};
  
  // Pagination
  int _currentPage = 1;
  bool _hasMore = true;
  final int _limit = 20;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Comment> get comments => _comments;
  bool get hasMore => _hasMore;
  int get currentPage => _currentPage;

  Map<String, List<Comment>> get replies => _replies;
  
  bool isLoadingReplies(String commentId) => _loadingStates[commentId] ?? false;

  /// Clear state
  void clearState() {
    _comments.clear();
    _replies.clear();
    _loadingStates.clear();
    _currentPage = 1;
    _hasMore = true;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Load comments for a target (post or profile)
  Future<void> loadComments({
    required String targetType,
    required String targetId,
    bool refresh = false,
  }) async {
    if (refresh) {
      clearState();
    }

    if (_isLoading || (!_hasMore && !refresh)) return;

    _setLoading(true);
    _error = null;

    try {
      final response = await _commentService.getComments(
        targetType: targetType,
        targetId: targetId,
        page: _currentPage,
        limit: _limit,
      );

      final newComments = (response['comments'] as List? ?? [])
          .map((c) => Comment.fromJson(c))
          .toList();

      if (refresh) {
        _comments = newComments;
      } else {
        _comments.addAll(newComments);
      }

      _currentPage++;
      _hasMore = response['hasMore'] ?? false;
      
      AppLogger.success('✅ Loaded ${newComments.length} comments');
    } catch (e) {
      _error = e.toString();
      AppLogger.error('Failed to load comments: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load replies for a comment
  Future<void> loadReplies(String commentId, {bool refresh = false}) async {
    if (_loadingStates[commentId] == true) return;

    _loadingStates[commentId] = true;
    notifyListeners();

    try {
      final response = await _commentService.getReplies(
        commentId: commentId,
        page: 1,
        limit: 50,
      );

      final repliesList = (response['replies'] as List? ?? [])
          .map((r) => Comment.fromJson(r))
          .toList();

      _replies[commentId] = repliesList;
      
      AppLogger.success('✅ Loaded ${repliesList.length} replies');
    } catch (e) {
      AppLogger.error('Failed to load replies: $e');
    } finally {
      _loadingStates[commentId] = false;
      notifyListeners();
    }
  }

  /// Create a new comment
  Future<bool> createComment({
    required String targetType,
    required String targetId,
    required String content,
    String? parentId,
    String? postTitle,
    String? postOwnerId,
  }) async {
    try {
      final comment = await _commentService.createComment(
        targetType: targetType,
        targetId: targetId,
        content: content,
        parentId: parentId,
      );

      final newComment = Comment.fromJson(comment);

      // Add to appropriate list
      if (parentId != null) {
        // This is a reply
        if (_replies[parentId] != null) {
          _replies[parentId]!.add(newComment);
        } else {
          _replies[parentId] = [newComment];
        }
      } else {
        // This is a top-level comment
        _comments.insert(0, newComment);
      }

      // Send notification if it's a post comment
      if (targetType == 'Post' && postOwnerId != null && postTitle != null) {
        _notificationService.sendPostCommentNotification(
          postId: targetId,
          postOwnerId: postOwnerId,
          postTitle: postTitle,
          commentId: newComment.id,
          commentContent: content,
        );
      }

      notifyListeners();
      AppLogger.success('✅ Comment created');
      return true;
    } catch (e) {
      _error = e.toString();
      AppLogger.error('Failed to create comment: $e');
      notifyListeners();
      return false;
    }
  }

  /// Update a comment
  Future<bool> updateComment({
    required String commentId,
    required String content,
  }) async {
    try {
      final updatedComment = await _commentService.updateComment(
        commentId: commentId,
        content: content,
      );

      final comment = Comment.fromJson(updatedComment);

      // Update in main comments list
      final index = _comments.indexWhere((c) => c.id == commentId);
      if (index != -1) {
        _comments[index] = comment;
      }

      // Update in replies if it's a reply
      for (final repliesList in _replies.values) {
        final replyIndex = repliesList.indexWhere((r) => r.id == commentId);
        if (replyIndex != -1) {
          repliesList[replyIndex] = comment;
          break;
        }
      }

      notifyListeners();
      AppLogger.success('✅ Comment updated');
      return true;
    } catch (e) {
      _error = e.toString();
      AppLogger.error('Failed to update comment: $e');
      notifyListeners();
      return false;
    }
  }

  /// Delete a comment
  Future<bool> deleteComment(String commentId) async {
    try {
      await _commentService.deleteComment(commentId);

      // Remove from main comments list
      _comments.removeWhere((c) => c.id == commentId);

      // Remove from replies if it's a reply
      for (final repliesList in _replies.values) {
        repliesList.removeWhere((r) => r.id == commentId);
      }

      notifyListeners();
      AppLogger.success('✅ Comment deleted');
      return true;
    } catch (e) {
      _error = e.toString();
      AppLogger.error('Failed to delete comment: $e');
      notifyListeners();
      return false;
    }
  }

  /// Get comment count for a target
  int getCommentCount({String? targetId}) {
    if (targetId != null) {
      return _comments.where((c) => c.targetId == targetId).length;
    }
    return _comments.length;
  }

  /// Get replies count for a comment
  int getRepliesCount(String commentId) {
    return _replies[commentId]?.length ?? 0;
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Initialize real-time listeners
  void initializeListeners() {
    _commentService.onCommentCreated((data) {
      try {
        final comment = Comment.fromJson(data['data']);
        if (comment.parentId != null) {
          // It's a reply
          if (_replies[comment.parentId!] != null) {
            _replies[comment.parentId!]!.add(comment);
          }
        } else {
          // It's a top-level comment
          _comments.insert(0, comment);
        }
        notifyListeners();
      } catch (e) {
        AppLogger.error('Error handling real-time comment: $e');
      }
    });

    _commentService.onCommentUpdated((data) {
      try {
        final comment = Comment.fromJson(data['data']);
        
        // Update in main list
        final index = _comments.indexWhere((c) => c.id == comment.id);
        if (index != -1) {
          _comments[index] = comment;
        }

        // Update in replies
        for (final repliesList in _replies.values) {
          final replyIndex = repliesList.indexWhere((r) => r.id == comment.id);
          if (replyIndex != -1) {
            repliesList[replyIndex] = comment;
            break;
          }
        }
        
        notifyListeners();
      } catch (e) {
        AppLogger.error('Error handling comment update: $e');
      }
    });

    _commentService.onCommentDeleted((data) {
      try {
        final commentId = data['commentId'];
        
        // Remove from main list
        _comments.removeWhere((c) => c.id == commentId);
        
        // Remove from replies
        for (final repliesList in _replies.values) {
          repliesList.removeWhere((r) => r.id == commentId);
        }
        
        notifyListeners();
      } catch (e) {
        AppLogger.error('Error handling comment deletion: $e');
      }
    });
  }

  @override
  void dispose() {
    _commentService.dispose();
    super.dispose();
  }
}
