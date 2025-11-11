import 'package:flutter/material.dart';
import '../../../widgets/post_like_button.dart';
import 'package:provider/provider.dart';
import '../../../providers/landing_provider.dart';

class CategoryDetailsPanel extends StatefulWidget {
  final VoidCallback onClose;

  const CategoryDetailsPanel({
    super.key,
    required this.onClose,
  });

  @override
  State<CategoryDetailsPanel> createState() => _CategoryDetailsPanelState();
}

class _CategoryDetailsPanelState extends State<CategoryDetailsPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleClose() async {
    await _animationController.reverse();
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SlideTransition(
      position: _slideAnimation,
      child: Consumer<LandingProvider>(
        builder: (context, provider, _) {
          final categoryDetails = provider.categoryDetails;
          final isLoading = provider.isLoadingCategoryDetails;

          if (categoryDetails == null && !isLoading) {
            return const SizedBox.shrink();
          }

          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Drag indicator
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (categoryDetails != null) ...[
                              Row(
                                children: [
                                  Text(
                                    _getCategoryEmoji(categoryDetails['categoryName']),
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    categoryDetails['categoryName'].toString().toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: _getCategoryColor(categoryDetails['categoryName']),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                categoryDetails['description'] ?? '',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _handleClose,
                        icon: const Icon(Icons.close),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Content
                Expanded(
                  child: isLoading
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Loading category details...',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        )
                      : categoryDetails == null
                          ? Center(
                              child: Text(
                                'No category details available',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            )
                          : _buildCategoryContent(categoryDetails, theme),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryContent(Map<String, dynamic> categoryDetails, ThemeData theme) {
    final posts = categoryDetails['posts'] as List<dynamic>? ?? [];
    final postCount = categoryDetails['postCount'] ?? 0;

    return Column(
      children: [
        // Stats bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
          child: Row(
            children: [
              Icon(
                Icons.article_outlined,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                '$postCount ${postCount == 1 ? 'post' : 'posts'} in this category',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        // Posts list
        Expanded(
          child: posts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 64,
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No posts in this category yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: posts.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return _buildPostCard(post, theme);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post, ThemeData theme) {
    final title = post['title'] ?? 'Untitled';
    final postType = post['postType'] ?? 'offer';
    final isActive = post['isActive'] ?? false;
    final createdAt = post['createdAt'] != null
        ? DateTime.parse(post['createdAt'])
        : DateTime.now();

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to post details
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  postType == 'offer' ? Icons.local_offer : Icons.work_outline,
                  size: 20,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: postType == 'offer' ? Colors.green : Colors.blue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            postType.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          isActive ? Icons.check_circle : Icons.cancel,
                          size: 12,
                          color: isActive ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatDate(createdAt),
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Like button
                  PostLikeButton(
                    postId: post['_id'] ?? post['id'] ?? '',
                    postOwnerId: post['userId'] ?? '',
                    postTitle: title,
                    initiallyLiked: post['isFavorited'] ?? false,
                    initialLikeCount: post['favoriteCount'] ?? 0,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _getCategoryEmoji(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'job':
        return '💼';
      case 'tutor':
        return '📚';
      case 'product':
        return '🛍️';
      case 'service':
        return '🔧';
      case 'rental':
        return '🏠';
      default:
        return '📁';
    }
  }

  Color _getCategoryColor(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'job':
        return Colors.blue;
      case 'tutor':
        return Colors.purple;
      case 'product':
        return Colors.orange;
      case 'service':
        return Colors.teal;
      case 'rental':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
