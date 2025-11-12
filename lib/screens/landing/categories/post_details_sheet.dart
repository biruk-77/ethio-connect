import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/landing_provider.dart';
import '../../../utils/app_logger.dart';
import '../../../widgets/post_like_button.dart';
import '../../../widgets/chat_with_poster_button.dart';
import '../../../services/favorites_service.dart';

class PostDetailsSheet extends StatefulWidget {
  final String postId;
  final ScrollController? scrollController;

  const PostDetailsSheet({
    super.key,
    required this.postId,
    this.scrollController,
  });

  @override
  State<PostDetailsSheet> createState() => _PostDetailsSheetState();
}

class _PostDetailsSheetState extends State<PostDetailsSheet> {
  Map<String, dynamic>? _postDetails;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPostDetails();
  }

  Future<void> _loadPostDetails() async {
    final provider = Provider.of<LandingProvider>(context, listen: false);
    final details = await provider.fetchPostDetails(widget.postId);
    
    setState(() {
      _postDetails = details;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: _isLoading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(),
              ),
            )
          : _postDetails == null
              ? _buildErrorState(theme)
              : _buildPostDetails(theme),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load post details',
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostDetails(ThemeData theme) {
    final post = _postDetails!;
    final title = post['title'] ?? 'Untitled';
    final description = post['description'] ?? 'No description';
    final price = post['price'];
    final postType = post['postType'] ?? 'offer';
    final isActive = post['isActive'] ?? false;
    final createdAt = post['createdAt'] != null
        ? DateTime.parse(post['createdAt'])
        : DateTime.now();
    
    final category = post['category'];
    final region = post['region'];
    final city = post['city'];
    final tags = post['tags'];
    
    return SingleChildScrollView(
      controller: widget.scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with drag handle
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Post Type & Status Badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: postType == 'offer' ? Colors.green : Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            postType == 'offer'
                                ? Icons.local_offer
                                : Icons.work_outline,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            postType.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.green.withOpacity(0.2)
                            : Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isActive ? Icons.check_circle : Icons.cancel,
                            size: 14,
                            color: isActive ? Colors.green : Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isActive ? 'ACTIVE' : 'INACTIVE',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isActive ? Colors.green : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Title and Action Buttons
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Like button
                    PostLikeButton(
                      postId: widget.postId,
                      postOwnerId: post['userId'] ?? '',
                      postTitle: title,
                      initiallyLiked: post['isFavorited'] ?? false,
                      initialLikeCount: post['favoriteCount'] ?? 0,
                    ),
                    const SizedBox(width: 8),
                    // Favorite/Bookmark button
                    IconButton(
                      icon: Icon(
                        post['isFavorited'] == true
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        color: post['isFavorited'] == true
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () {
                        FavoritesService().toggleFavorite(
                          targetType: 'Post',
                          targetId: widget.postId,
                        );
                        setState(() {
                          post['isFavorited'] = !(post['isFavorited'] ?? false);
                        });
                      },
                      tooltip: 'Bookmark',
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Chat with Poster Button
                ChatWithPosterButton(
                  posterId: post['userId'] ?? '',
                  posterName: post['user']?['displayName'] ?? 
                             post['user']?['username'] ?? 
                             post['userName'] ?? 
                             post['ownerName'] ?? 
                             'Poster',
                  posterPhotoUrl: post['user']?['photoURL'] ?? post['userPhotoURL'],
                  postId: widget.postId, // Pass post ID for context
                  itemType: 'post',
                  compact: false,
                ),

                const SizedBox(height: 8),

                // Time
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(createdAt),
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Price (if available)
                if (price != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.green.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.attach_money,
                          color: Colors.green,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Price',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              'ETB ${double.parse(price.toString()).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Category, Region, City
                _buildInfoSection(
                  theme: theme,
                  icon: Icons.category,
                  label: 'Category',
                  value: category?['categoryName'] ?? 'N/A',
                  subtitle: category?['description'],
                ),

                const SizedBox(height: 12),

                _buildInfoSection(
                  theme: theme,
                  icon: Icons.location_on,
                  label: 'Location',
                  value: '${city?['name'] ?? 'Unknown'}, ${region?['name'] ?? 'Unknown'}',
                ),

                const SizedBox(height: 20),

                // Description
                Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    description,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Tags (if available)
                if (tags != null && tags.toString().isNotEmpty) ...[
                  Text(
                    'Tags',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTags(theme, tags),
                  const SizedBox(height: 20),
                ],

                // Action Buttons
                _buildActionButtons(theme, category?['categoryName']),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme, String? categoryName) {
    // Get button config based on category
    final config = _getButtonConfig(categoryName);
    
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // TODO: Handle primary action
            },
            icon: Icon(config['primaryIcon'] as IconData),
            label: Text(config['primaryText'] as String),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: Share
            },
            icon: const Icon(Icons.share),
            label: const Text('Share'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _getButtonConfig(String? categoryName) {
    final category = categoryName?.toLowerCase() ?? '';

    switch (category) {
      case 'job':
        return {
          'primaryText': 'Apply Now',
          'primaryIcon': Icons.work,
        };
      case 'tutor':
        return {
          'primaryText': 'Hire Tutor',
          'primaryIcon': Icons.school,
        };
      case 'product':
        return {
          'primaryText': 'Buy Now',
          'primaryIcon': Icons.shopping_cart,
        };
      case 'service':
        return {
          'primaryText': 'Use Service',
          'primaryIcon': Icons.handyman,
        };
      case 'rental':
        return {
          'primaryText': 'Rent Now',
          'primaryIcon': Icons.home,
        };
      case 'matchmaking':
        return {
          'primaryText': 'Connect',
          'primaryIcon': Icons.favorite,
        };
      case 'event':
        return {
          'primaryText': 'Register',
          'primaryIcon': Icons.event,
        };
      default:
        return {
          'primaryText': 'Contact',
          'primaryIcon': Icons.message,
        };
    }
  }

  Widget _buildInfoSection({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required String value,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTags(ThemeData theme, dynamic tags) {
    List<String> tagList = [];
    
    if (tags is String) {
      // Parse JSON string
      try {
        final parsed = tags.replaceAll('[', '').replaceAll(']', '').replaceAll('"', '');
        tagList = parsed.split(',').map((e) => e.trim()).toList();
      } catch (e) {
        AppLogger.error('Failed to parse tags: $e');
      }
    } else if (tags is List) {
      tagList = tags.map((e) => e.toString()).toList();
    }

    if (tagList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tagList.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.tag,
                size: 14,
                color: theme.colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 4),
              Text(
                tag,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
