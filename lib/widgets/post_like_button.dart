import 'package:flutter/material.dart';
import '../services/favorites_service.dart';
import '../services/notification_service.dart';
import '../utils/app_logger.dart';

/// Post Like Button Widget
/// Shows heart icon with animation, handles like/unlike
class PostLikeButton extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  final String postTitle;
  final bool initiallyLiked;
  final int initialLikeCount;
  final VoidCallback? onLikeChanged;

  const PostLikeButton({
    super.key,
    required this.postId,
    required this.postOwnerId,
    required this.postTitle,
    this.initiallyLiked = false,
    this.initialLikeCount = 0,
    this.onLikeChanged,
  });

  @override
  State<PostLikeButton> createState() => _PostLikeButtonState();
}

class _PostLikeButtonState extends State<PostLikeButton>
    with SingleTickerProviderStateMixin {
  final FavoritesService _favoritesService = FavoritesService();
  final NotificationService _notificationService = NotificationService();

  late bool _isLiked;
  late int _likeCount;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.initiallyLiked;
    _likeCount = widget.initialLikeCount;

    // Setup animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    // Listen for favorite status updates
    _favoritesService.on('favorite:toggled', (data) {
      if (data['targetId'] == widget.postId) {
        if (mounted) {
          setState(() {
            _isLiked = data['isFavorited'] ?? false;
          });
        }
      }
    });

    // Listen for count updates
    _favoritesService.on('favorite:count:updated', (data) {
      if (data['targetId'] == widget.postId) {
        if (mounted) {
          setState(() {
            _likeCount = data['count'] ?? 0;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleLike() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Optimistic UI update
      setState(() {
        _isLiked = !_isLiked;
        _likeCount = _isLiked ? _likeCount + 1 : _likeCount - 1;
      });

      // Animate
      if (_isLiked) {
        _animationController.forward().then((_) {
          _animationController.reverse();
        });
      }

      // Toggle favorite via Socket.IO
      await _favoritesService.toggleFavorite(
        targetType: 'Post',
        targetId: widget.postId,
      );

      // Send notification if liked (not unliked)
      if (_isLiked) {
        await _notificationService.sendPostLikeNotification(
          postId: widget.postId,
          postOwnerId: widget.postOwnerId,
          postTitle: widget.postTitle,
        );
      }

      // Callback
      widget.onLikeChanged?.call();

      AppLogger.success(_isLiked ? '❤️ Post liked!' : '🤍 Post unliked');
    } catch (e) {
      AppLogger.error('Failed to toggle like: $e');
      
      // Revert on error
      if (mounted) {
        setState(() {
          _isLiked = !_isLiked;
          _likeCount = _isLiked ? _likeCount + 1 : _likeCount - 1;
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to ${_isLiked ? "unlike" : "like"} post'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScaleTransition(
          scale: _scaleAnimation,
          child: IconButton(
            icon: Icon(
              _isLiked ? Icons.favorite : Icons.favorite_border,
              color: _isLiked ? Colors.red : Colors.grey[600],
              size: 24,
            ),
            onPressed: _isProcessing ? null : _handleLike,
            tooltip: _isLiked ? 'Unlike' : 'Like',
          ),
        ),
        if (_likeCount > 0)
          Text(
            '$_likeCount',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }
}

/// Compact Like Button (for smaller cards)
class CompactLikeButton extends StatelessWidget {
  final String postId;
  final String postOwnerId;
  final String postTitle;
  final bool isLiked;
  final int likeCount;

  const CompactLikeButton({
    super.key,
    required this.postId,
    required this.postOwnerId,
    required this.postTitle,
    this.isLiked = false,
    this.likeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isLiked ? Colors.red.withOpacity(0.1) : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            size: 16,
            color: isLiked ? Colors.red : Colors.grey[600],
          ),
          if (likeCount > 0) ...[
            const SizedBox(width: 4),
            Text(
              '$likeCount',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
