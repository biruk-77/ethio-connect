import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/landing_provider.dart';

class SearchResultsPanel extends StatefulWidget {
  final String searchQuery;
  final VoidCallback onClose;

  const SearchResultsPanel({
    super.key,
    required this.searchQuery,
    required this.onClose,
  });

  @override
  State<SearchResultsPanel> createState() => _SearchResultsPanelState();
}

class _SearchResultsPanelState extends State<SearchResultsPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    await _controller.reverse();
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: _close,
      child: Container(
        color: Colors.black.withOpacity(0.3),
        child: GestureDetector(
          onTap: () {}, // Prevent closing when tapping inside
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -1),
              end: Offset.zero,
            ).animate(_slideAnimation),
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                // Drag down to close
                if (details.primaryDelta! > 0) {
                  _controller.value -= details.primaryDelta! / 300;
                }
              },
              onVerticalDragEnd: (details) {
                // Close if dragged down significantly
                if (_controller.value < 0.5 || details.primaryVelocity! > 700) {
                  _close();
                } else {
                  _controller.forward();
                }
              },
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: size.width,
                  constraints: BoxConstraints(
                    maxHeight: size.height * 0.7,
                  ),
                  margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 130),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Handle bar - drag to close
                      Container(
                        margin: const EdgeInsets.only(top: 12),
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
                            Icon(
                              Icons.search_rounded,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Search Results',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  if (widget.searchQuery.isNotEmpty)
                                    Text(
                                      'for "${widget.searchQuery}"',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded),
                              onPressed: _close,
                              tooltip: 'Close',
                            ),
                          ],
                        ),
                      ),

                      Divider(height: 1, color: theme.colorScheme.outline.withOpacity(0.2)),

                      // Results
                      Expanded(
                        child: Consumer<LandingProvider>(
                          builder: (context, provider, _) {
                            if (provider.isSearching) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (provider.errorMessage != null) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.error_outline_rounded,
                                        size: 64,
                                        color: theme.colorScheme.error,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Search Failed',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        provider.errorMessage!,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            final results = provider.searchResults;

                            if (results.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.search_off_rounded,
                                        size: 64,
                                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No Results Found',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Try different keywords or filters',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: results.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final result = results[index];
                                return _buildResultCard(context, result, theme);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, dynamic result, ThemeData theme) {
    final title = result['title'] ?? 'Untitled';
    final description = result['description'] ?? '';
    final price = result['price'];
    final type = result['type'] ?? 'post';
    final region = result['region']?['name'];
    final city = result['city']?['name'];
    final category = result['category']?['categoryName'];

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to detail page
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type badge and price
              Row(
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _getTypeColor(type).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _getTypeLabel(type),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _getTypeColor(type),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  if (category != null) ...[
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 10,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (price != null)
                    Text(
                      'ETB $price',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              if (description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Location
              if (city != null || region != null) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        [city, region].where((e) => e != null).join(', '),
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'job':
        return Colors.blue;
      case 'product':
        return Colors.green;
      case 'service':
        return Colors.orange;
      case 'rental':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'job':
        return 'JOB';
      case 'product':
        return 'PRODUCT';
      case 'service':
        return 'SERVICE';
      case 'rental':
        return 'RENTAL';
      default:
        return 'POST';
    }
  }
}
