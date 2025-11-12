import 'package:flutter/material.dart';
import '../services/room_management_service.dart';
import '../services/analytics_service.dart';
import 'enhanced_action_buttons.dart';
import '../models/post_model.dart';
import '../theme/app_colors.dart';

/// Enhanced Post Card with Real-Time Communication Features
class EnhancedPostCard extends StatefulWidget {
  final Post post;
  final VoidCallback? onTap;
  final bool showFullContent;
  
  const EnhancedPostCard({
    super.key,
    required this.post,
    this.onTap,
    this.showFullContent = false,
  });

  @override
  State<EnhancedPostCard> createState() => _EnhancedPostCardState();
}

class _EnhancedPostCardState extends State<EnhancedPostCard> {
  final RoomManagementService _roomService = RoomManagementService();
  final AnalyticsService _analyticsService = AnalyticsService();
  
  bool _hasTrackedView = false;

  @override
  void initState() {
    super.initState();
    _setupPostTracking();
  }

  void _setupPostTracking() {
    // Track post view for analytics
    if (!_hasTrackedView) {
      _analyticsService.trackInteraction(
        action: 'view',
        targetType: 'post',
        targetId: widget.post.id,
        metadata: {
          'category': widget.post.category,
          'userId': widget.post.userId,
        },
      );
      _hasTrackedView = true;
    }

    // Auto-join post room for real-time updates
    _roomService.joinPostRoomIfNeeded(widget.post.id);
  }

  void _handlePostTap() {
    // Track post open
    _analyticsService.trackInteraction(
      action: 'open',
      targetType: 'post',
      targetId: widget.post.id,
    );
    
    if (widget.onTap != null) {
      widget.onTap!();
    } else {
      // Default navigation to post detail
      Navigator.pushNamed(
        context,
        '/post/detail',
        arguments: widget.post,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: _handlePostTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post Header
            _buildPostHeader(),
            
            // Post Content
            if (widget.post.content != null && widget.post.content!.isNotEmpty)
              _buildPostContent(),
            
            // Post Images
            if (widget.post.images != null && widget.post.images!.isNotEmpty)
              _buildPostImages(),
            
            // Post Actions with Real-Time Features
            Padding(
              padding: const EdgeInsets.all(12),
              child: EnhancedActionButtons(
                postId: widget.post.id,
                postType: 'post',
                userId: widget.post.userId,
                initialCounts: {
                  'favorites': widget.post.likesCount ?? 0,
                  'comments': widget.post.commentsCount ?? 0,
                  'views': widget.post.viewsCount ?? 0,
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostHeader() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // User Avatar
          CircleAvatar(
            radius: 20,
            backgroundImage: widget.post.user?.profilePicture != null
                ? NetworkImage(widget.post.user!.profilePicture!)
                : null,
            child: widget.post.user?.profilePicture == null
                ? Text(
                    widget.post.user?.displayName?.substring(0, 1).toUpperCase() ?? '?',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.post.user?.displayName ?? 'Unknown User',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    if (widget.post.user?.isVerified == true) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.verified,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _formatTimeAgo(widget.post.createdAt),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Post Menu
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showPostMenu(),
          ),
        ],
      ),
    );
  }

  Widget _buildPostContent() {
    final content = widget.post.content!;
    final shouldTruncate = !widget.showFullContent && content.length > 200;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            shouldTruncate ? '${content.substring(0, 200)}...' : content,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
          if (shouldTruncate)
            GestureDetector(
              onTap: _handlePostTap,
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Read more',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPostImages() {
    final images = widget.post.images!;
    
    if (images.length == 1) {
      return Container(
        margin: const EdgeInsets.all(12),
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: NetworkImage(images.first),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return Container(
        margin: const EdgeInsets.all(12),
        height: 150,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: images.length,
          itemBuilder: (context, index) {
            return Container(
              width: 120,
              margin: EdgeInsets.only(right: index < images.length - 1 ? 8 : 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(images[index]),
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
      );
    }
  }

  void _showPostMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.bookmark_border),
              title: const Text('Save Post'),
              onTap: () {
                Navigator.pop(context);
                _savePost();
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                _sharePost();
              },
            ),
            if (widget.post.userId != 'current_user_id') // Replace with actual current user check
              ListTile(
                leading: const Icon(Icons.report),
                title: const Text('Report'),
                onTap: () {
                  Navigator.pop(context);
                  _reportPost();
                },
              ),
          ],
        ),
      ),
    );
  }

  void _savePost() {
    // Implement save post functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post saved')),
    );
  }

  void _sharePost() {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality here')),
    );
  }

  void _reportPost() {
    // Implement report functionality
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Post'),
        content: const Text('Are you sure you want to report this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Post reported')),
              );
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  void dispose() {
    // Leave post room when widget is disposed
    _roomService.leavePostRoomIfJoined(widget.post.id);
    super.dispose();
  }
}
