import 'package:flutter/material.dart';
import '../categories/post_details_sheet.dart';

class ContentCategoriesGrid extends StatelessWidget {
  final String? selectedCategory;
  final String? expandedCategoryId;
  final Map<String, dynamic>? categoryDetails;
  final bool isLoadingDetails;
  final ValueChanged<String>? onCategoryTap;
  final List<dynamic> categories;
  final bool isLoading;

  const ContentCategoriesGrid({
    super.key,
    this.selectedCategory,
    this.expandedCategoryId,
    this.categoryDetails,
    this.isLoadingDetails = false,
    this.onCategoryTap,
    required this.categories,
    this.isLoading = false,
  });

  // Map category names to emojis
  static String _getCategoryEmoji(String categoryName) {
    final Map<String, String> categoryEmojis = {
      'job': '💼',
      'tutor': '📚',
      'product': '🛍️',
      'service': '🔧',
      'rental': '🏠',
      'event': '🎉',
      'matchmaking': '💑',
    };

    return categoryEmojis[categoryName.toLowerCase()] ?? '📋';
  }

  // Get category color
  static Color _getCategoryColor(String categoryName) {
    final Map<String, Color> categoryColors = {
      'job': const Color(0xFF2196F3),
      'tutor': const Color(0xFF9C27B0),
      'product': const Color(0xFF4CAF50),
      'service': const Color(0xFFFF9800),
      'rental': const Color(0xFFE91E63),
      'event': const Color(0xFFFF5722),
      'matchmaking': const Color(0xFFE91E63),
    };

    return categoryColors[categoryName.toLowerCase()] ?? const Color(0xFF757575);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Browse Categories',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),
          if (isLoading && categories.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (categories.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  'No categories available',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: categories.map((category) {
                  final categoryId = category['id']?.toString() ?? '';
                  final categoryName = category['categoryName'] ?? 'Unknown';
                  final postCount = category['postCount'] ?? 0;
                  final isExpanded = expandedCategoryId == categoryId;

                  return _ExpandableCategoryCard(
                    key: ValueKey(categoryId),
                    categoryId: categoryId,
                    categoryName: categoryName,
                    postCount: postCount,
                    isExpanded: isExpanded,
                    isLoadingDetails: isLoadingDetails && isExpanded,
                    categoryDetails: isExpanded ? categoryDetails : null,
                    onTap: () => onCategoryTap?.call(categoryId),
                    theme: theme,
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

// Expandable Category Card Widget
class _ExpandableCategoryCard extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final int postCount;
  final bool isExpanded;
  final bool isLoadingDetails;
  final Map<String, dynamic>? categoryDetails;
  final VoidCallback onTap;
  final ThemeData theme;

  const _ExpandableCategoryCard({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.postCount,
    required this.isExpanded,
    required this.isLoadingDetails,
    this.categoryDetails,
    required this.onTap,
    required this.theme,
  });

  @override
  State<_ExpandableCategoryCard> createState() => _ExpandableCategoryCardState();
}

class _ExpandableCategoryCardState extends State<_ExpandableCategoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didUpdateWidget(_ExpandableCategoryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = ContentCategoriesGrid._getCategoryColor(widget.categoryName);
    final categoryEmoji = ContentCategoriesGrid._getCategoryEmoji(widget.categoryName);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: widget.isExpanded ? 4 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: widget.isExpanded
              ? BorderSide(color: categoryColor, width: 2)
              : BorderSide.none,
        ),
        child: Column(
          children: [
            // Category Header (always visible)
            InkWell(
              onTap: widget.onTap,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: widget.isExpanded
                      ? categoryColor.withOpacity(0.1)
                      : null,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    // Emoji Icon
                    Text(
                      categoryEmoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(width: 16),
                    
                    // Category Name & Count
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.categoryName.toUpperCase(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: widget.isExpanded
                                  ? categoryColor
                                  : widget.theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.postCount} ${widget.postCount == 1 ? 'post' : 'posts'}',
                            style: TextStyle(
                              fontSize: 13,
                              color: widget.theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Expand/Collapse Icon
                    AnimatedRotation(
                      turns: widget.isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: categoryColor,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Expandable Content
            SizeTransition(
              sizeFactor: _expandAnimation,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: widget.theme.colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                ),
                child: widget.isLoadingDetails
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : widget.categoryDetails == null
                        ? const SizedBox.shrink()
                        : _buildExpandedContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedContent() {
    final posts = widget.categoryDetails?['posts'] as List<dynamic>? ?? [];

    if (posts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 48,
                color: widget.theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
              const SizedBox(height: 12),
              Text(
                'No posts yet in this category',
                style: TextStyle(
                  fontSize: 14,
                  color: widget.theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Posts in ${widget.categoryName}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: widget.theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        ...posts.map((post) => _buildPostItem(post)).toList(),
      ],
    );
  }

  Widget _buildPostItem(Map<String, dynamic> post) {
    final title = post['title'] ?? 'Untitled';
    final postType = post['postType'] ?? 'offer';
    final isActive = post['isActive'] ?? false;
    final postId = post['id']?.toString() ?? '';
    final createdAt = post['createdAt'] != null
        ? DateTime.parse(post['createdAt'])
        : DateTime.now();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 1,
        child: InkWell(
          onTap: () {
            if (postId.isNotEmpty) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                isDismissible: true,
                enableDrag: true,
                backgroundColor: Colors.transparent,
                builder: (context) => DraggableScrollableSheet(
                  initialChildSize: 0.9,
                  minChildSize: 0.5,
                  maxChildSize: 0.95,
                  expand: false,
                  builder: (context, scrollController) => PostDetailsSheet(
                    postId: postId,
                    scrollController: scrollController,
                  ),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Post Type Icon
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: postType == 'offer' ? Colors.green : Colors.blue,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    postType == 'offer' ? Icons.local_offer : Icons.work_outline,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),

                // Post Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
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
                              color: widget.theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _formatDate(createdAt),
                            style: TextStyle(
                              fontSize: 11,
                              color: widget.theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow Icon
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: widget.theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
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
}
