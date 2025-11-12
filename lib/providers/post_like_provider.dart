import 'package:flutter/material.dart';
import '../models/post_like_model.dart';
import '../services/post_like_service.dart';
import '../utils/app_logger.dart';

class PostLikeProvider extends ChangeNotifier {
  final PostLikeService _postLikeService = PostLikeService();

  // State
  bool _isLoading = false;
  String? _error;
  Map<String, bool> _likedPosts = {};
  Map<String, String> _likeTypes = {};
  Map<String, int> _likeCounts = {};
  Map<String, Map<String, int>> _likeBreakdowns = {};
  List<PostLike> _userLikes = [];
  
  // Pagination for user likes
  int _currentPage = 1;
  bool _hasMore = true;
  final int _limit = 20;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<PostLike> get userLikes => _userLikes;
  bool get hasMore => _hasMore;
  int get currentPage => _currentPage;

  /// Check if post is liked by current user
  bool isPostLiked(String postId) => _likedPosts[postId] ?? false;
  
  /// Get like type for post
  String? getLikeType(String postId) => _likeTypes[postId];
  
  /// Get like count for post
  int getLikeCount(String postId) => _likeCounts[postId] ?? 0;
  
  /// Get like breakdown for post
  Map<String, int> getLikeBreakdown(String postId) => _likeBreakdowns[postId] ?? {};

  /// Clear state
  void clearState() {
    _likedPosts.clear();
    _likeTypes.clear();
    _likeCounts.clear();
    _likeBreakdowns.clear();
    _userLikes.clear();
    _currentPage = 1;
    _hasMore = true;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Like a post
  Future<bool> likePost({
    required String postId,
    String type = 'like',
  }) async {
    // Optimistic update
    final wasLiked = _likedPosts[postId] ?? false;
    final oldType = _likeTypes[postId];
    final oldCount = _likeCounts[postId] ?? 0;
    
    if (!wasLiked) {
      _likedPosts[postId] = true;
      _likeTypes[postId] = type;
      _likeCounts[postId] = oldCount + 1;
    } else if (oldType != type) {
      _likeTypes[postId] = type;
    }
    
    notifyListeners();

    try {
      await _postLikeService.likePost(postId: postId, type: type);
      
      // Refresh like status to get accurate counts
      await checkPostLikeStatus(postId);
      
      AppLogger.success('✅ Post liked');
      return true;
    } catch (e) {
      // Revert optimistic update on error
      if (!wasLiked) {
        _likedPosts[postId] = false;
        _likeTypes.remove(postId);
        _likeCounts[postId] = oldCount;
      } else if (oldType != null) {
        _likeTypes[postId] = oldType;
      }
      
      _error = e.toString();
      AppLogger.error('Failed to like post: $e');
      notifyListeners();
      return false;
    }
  }

  /// Unlike a post
  Future<bool> unlikePost(String postId) async {
    // Optimistic update
    final wasLiked = _likedPosts[postId] ?? false;
    final oldType = _likeTypes[postId];
    final oldCount = _likeCounts[postId] ?? 0;
    
    _likedPosts[postId] = false;
    _likeTypes.remove(postId);
    _likeCounts[postId] = oldCount > 0 ? oldCount - 1 : 0;
    
    notifyListeners();

    try {
      await _postLikeService.unlikePost(postId);
      
      // Refresh like status to get accurate counts
      await checkPostLikeStatus(postId);
      
      AppLogger.success('✅ Post unliked');
      return true;
    } catch (e) {
      // Revert optimistic update on error
      _likedPosts[postId] = wasLiked;
      if (oldType != null) {
        _likeTypes[postId] = oldType;
      }
      _likeCounts[postId] = oldCount;
      
      _error = e.toString();
      AppLogger.error('Failed to unlike post: $e');
      notifyListeners();
      return false;
    }
  }

  /// Check post like status
  Future<void> checkPostLikeStatus(String postId) async {
    try {
      final status = await _postLikeService.checkPostLikeStatus(postId);
      
      _likedPosts[postId] = status['isLiked'] ?? false;
      if (status['likeType'] != null) {
        _likeTypes[postId] = status['likeType'];
      } else {
        _likeTypes.remove(postId);
      }
      _likeCounts[postId] = status['likesCount'] ?? 0;
      _likeBreakdowns[postId] = Map<String, int>.from(status['likeBreakdown'] ?? {});
      
      notifyListeners();
    } catch (e) {
      AppLogger.error('Failed to check post like status: $e');
    }
  }

  /// Load likes for multiple posts
  Future<void> loadPostsLikeStatus(List<String> postIds) async {
    for (String postId in postIds) {
      await checkPostLikeStatus(postId);
    }
  }

  /// Load user's liked posts
  Future<void> loadUserLikedPosts({
    bool refresh = false,
    String? type,
  }) async {
    if (refresh) {
      _userLikes.clear();
      _currentPage = 1;
      _hasMore = true;
    }

    if (_isLoading || (!_hasMore && !refresh)) return;

    _setLoading(true);
    _error = null;

    try {
      final response = await _postLikeService.getUserLikedPosts(
        page: _currentPage,
        limit: _limit,
        type: type,
      );

      if (refresh) {
        _userLikes = response.likes;
      } else {
        _userLikes.addAll(response.likes);
      }

      _currentPage++;
      _hasMore = response.hasMore;
      
      AppLogger.success('✅ Loaded ${response.likes.length} liked posts');
    } catch (e) {
      _error = e.toString();
      AppLogger.error('Failed to load user likes: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Get post likes with users who liked
  Future<PostLikeResponse?> getPostLikes({
    required String postId,
    int page = 1,
    String? type,
  }) async {
    try {
      final response = await _postLikeService.getPostLikes(
        postId: postId,
        page: page,
        limit: _limit,
        type: type,
      );
      
      return response;
    } catch (e) {
      _error = e.toString();
      AppLogger.error('Failed to get post likes: $e');
      notifyListeners();
      return null;
    }
  }

  /// Get post like statistics
  Future<Map<String, dynamic>?> getPostLikeStats(String postId) async {
    try {
      final stats = await _postLikeService.getPostLikeStats(postId);
      return stats;
    } catch (e) {
      _error = e.toString();
      AppLogger.error('Failed to get post like stats: $e');
      notifyListeners();
      return null;
    }
  }

  /// Toggle like on post
  Future<bool> toggleLike({
    required String postId,
    String type = 'like',
  }) async {
    final isLiked = _likedPosts[postId] ?? false;
    
    if (isLiked) {
      return await unlikePost(postId);
    } else {
      return await likePost(postId: postId, type: type);
    }
  }

  /// Get total likes count for all loaded posts
  int get totalLikesCount {
    return _likeCounts.values.fold(0, (sum, count) => sum + count);
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Initialize real-time listeners
  void initializeListeners() {
    _postLikeService.onPostLiked((data) {
      try {
        final postLike = PostLike.fromJson(data['data']);
        
        // Update local state
        _likedPosts[postLike.postId] = true;
        _likeTypes[postLike.postId] = postLike.type;
        
        // Update like count
        final currentCount = _likeCounts[postLike.postId] ?? 0;
        _likeCounts[postLike.postId] = currentCount + 1;
        
        notifyListeners();
      } catch (e) {
        AppLogger.error('Error handling real-time like: $e');
      }
    });

    _postLikeService.onPostUnliked((data) {
      try {
        final postId = data['postId'];
        
        // Update local state
        _likedPosts[postId] = false;
        _likeTypes.remove(postId);
        
        // Update like count
        final currentCount = _likeCounts[postId] ?? 0;
        _likeCounts[postId] = currentCount > 0 ? currentCount - 1 : 0;
        
        notifyListeners();
      } catch (e) {
        AppLogger.error('Error handling real-time unlike: $e');
      }
    });
  }

  @override
  void dispose() {
    _postLikeService.dispose();
    super.dispose();
  }
}
