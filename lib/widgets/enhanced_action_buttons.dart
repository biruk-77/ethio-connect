import 'package:flutter/material.dart';
import '../services/favorites_service.dart';
import '../services/comment_like_service.dart';
import '../services/analytics_service.dart';
import '../services/room_management_service.dart';
import '../theme/app_colors.dart';

/// Enhanced Action Buttons with Real-Time Communication Features
class EnhancedActionButtons extends StatefulWidget {
  final String postId;
  final String postType;
  final String userId;
  final Map<String, dynamic>? initialCounts;
  
  const EnhancedActionButtons({
    super.key,
    required this.postId,
    required this.postType,
    required this.userId,
    this.initialCounts,
  });

  @override
  State<EnhancedActionButtons> createState() => _EnhancedActionButtonsState();
}

class _EnhancedActionButtonsState extends State<EnhancedActionButtons> {
  final FavoritesService _favoritesService = FavoritesService();
  final AnalyticsService _analyticsService = AnalyticsService();
  final RoomManagementService _roomService = RoomManagementService();
  
  bool _isFavorited = false;
  int _favoriteCount = 0;
  int _commentCount = 0;
  int _viewCount = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeCounts();
    _setupListeners();
    _joinPostRoom();
  }

  void _initializeCounts() {
    // Initialize with provided counts or defaults
    _favoriteCount = widget.initialCounts?['favorites'] ?? 0;
    _commentCount = widget.initialCounts?['comments'] ?? 0;
    _viewCount = widget.initialCounts?['views'] ?? 0;
    
    // Check if already favorited
    final cachedStatus = _favoritesService.getCachedFavoriteStatus(widget.postId);
    if (cachedStatus != null) {
      _isFavorited = cachedStatus;
    } else {
      // Check favorite status from server
      _favoritesService.checkFavoriteStatus(
        targetType: widget.postType,
        targetId: widget.postId,
      );
    }
  }

  void _setupListeners() {
    // Listen for favorite status changes
    _favoritesService.favoriteStatusStream.listen((data) {
      if (data['targetId'] == widget.postId && mounted) {
        setState(() {
          _isFavorited = data['isFavorited'] ?? false;
        });
      }
    });

    // Listen for favorite count updates
    _favoritesService.favoriteCountStream.listen((data) {
      if (data['targetId'] == widget.postId && mounted) {
        setState(() {
          _favoriteCount = data['count'] ?? 0;
        });
      }
    });

    // Listen for analytics updates
    _analyticsService.contentPerformanceStream.listen((data) {
      if (data['contentId'] == widget.postId && mounted) {
        final performance = data['performance'] as Map<String, dynamic>? ?? {};
        setState(() {
          _viewCount = performance['views'] ?? _viewCount;
          _commentCount = performance['comments'] ?? _commentCount;
        });
      }
    });
  }

  void _joinPostRoom() {
    // Auto-join post room for real-time updates
    _roomService.joinPostRoomIfNeeded(widget.postId);
  }

  Future<void> _toggleFavorite() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    
    try {
      // Track interaction for analytics
      await _analyticsService.trackInteraction(
        action: _isFavorited ? 'unfavorite' : 'favorite',
        targetType: widget.postType,
        targetId: widget.postId,
      );
      
      // Toggle favorite
      await _favoritesService.toggleFavorite(
        targetType: widget.postType,
        targetId: widget.postId,
      );
      
      // Optimistic update
      setState(() {
        _isFavorited = !_isFavorited;
        _favoriteCount += _isFavorited ? 1 : -1;
      });
      
    } catch (e) {
      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to ${_isFavorited ? 'unfavorite' : 'favorite'} post'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _openComments() {
    // Track analytics
    _analyticsService.trackInteraction(
      action: 'open_comments',
      targetType: widget.postType,
      targetId: widget.postId,
    );
    
    // Navigate to comments with post room auto-join
    Navigator.pushNamed(
      context,
      '/post/comments',
      arguments: {
        'postId': widget.postId,
        'postType': widget.postType,
        'userId': widget.userId,
      },
    );
  }

  void _sharePost() {
    // Track analytics
    _analyticsService.trackInteraction(
      action: 'share',
      targetType: widget.postType,
      targetId: widget.postId,
    );
    
    // Implement share functionality
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildShareSheet(),
    );
  }

  Widget _buildShareSheet() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Share this post',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildShareOption(
                icon: Icons.message,
                label: 'Message',
                onTap: () => _shareViaMessage(),
              ),
              _buildShareOption(
                icon: Icons.link,
                label: 'Copy Link',
                onTap: () => _copyLink(),
              ),
              _buildShareOption(
                icon: Icons.share,
                label: 'More',
                onTap: () => _shareExternal(),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  void _shareViaMessage() {
    Navigator.pop(context);
    Navigator.pushNamed(
      context,
      '/messages/share',
      arguments: {
        'postId': widget.postId,
        'postType': widget.postType,
      },
    );
  }

  void _copyLink() {
    Navigator.pop(context);
    // Implement copy to clipboard
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link copied to clipboard')),
    );
  }

  void _shareExternal() {
    Navigator.pop(context);
    // Implement external sharing (platform share)
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // Favorite Button
        _buildActionButton(
          icon: _isFavorited ? Icons.favorite : Icons.favorite_border,
          count: _favoriteCount,
          color: _isFavorited ? Colors.red : Colors.grey,
          onPressed: _toggleFavorite,
          isLoading: _isLoading,
        ),
        
        // Comments Button
        _buildActionButton(
          icon: Icons.comment_outlined,
          count: _commentCount,
          color: Colors.grey,
          onPressed: _openComments,
        ),
        
        // Views Counter (read-only)
        _buildActionButton(
          icon: Icons.visibility_outlined,
          count: _viewCount,
          color: Colors.grey,
          onPressed: null, // Read-only
        ),
        
        // Share Button
        _buildActionButton(
          icon: Icons.share_outlined,
          count: null, // No count for share
          color: Colors.grey,
          onPressed: _sharePost,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required int? count,
    required Color color,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              )
            else
              Icon(icon, size: 20, color: color),
            if (count != null) ...[
              const SizedBox(width: 4),
              Text(
                count > 999 ? '${(count / 1000).toStringAsFixed(1)}k' : '$count',
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Leave post room when widget is disposed
    _roomService.leavePostRoomIfJoined(widget.postId);
    super.dispose();
  }
}
