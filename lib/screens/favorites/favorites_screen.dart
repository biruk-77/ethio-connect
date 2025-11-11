import 'package:flutter/material.dart';
import '../../services/favorites_service.dart';
import '../../services/auth/auth_service.dart';
import '../../utils/app_logger.dart';
import '../landing/categories/post_details_sheet.dart';

/// Favorites Screen
/// Shows all posts the user has favorited
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  final AuthService _authService = AuthService();
  
  List<dynamic> _favorites = [];
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoad();
    _setupListeners();
  }

  Future<void> _checkAuthAndLoad() async {
    // Just check if token exists locally, don't make API call
    final token = await _authService.getAccessToken();
    setState(() {
      _isAuthenticated = token != null;
    });

    if (_isAuthenticated) {
      _loadFavorites();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _setupListeners() {
    // Listen for favorites list response
    _favoritesService.on('favorites:list', (data) {
      AppLogger.info('📋 Favorites list received: ${data['favorites']?.length ?? 0} items');
      if (mounted) {
        setState(() {
          _favorites = data['favorites'] ?? [];
          _isLoading = false;
        });
      }
    });

    // Listen for favorite removed
    _favoritesService.on('favorite:toggled', (data) {
      if (data['action'] == 'removed' || data['isFavorited'] == false) {
        if (mounted) {
          setState(() {
            _favorites.removeWhere((fav) => 
              fav['targetId'] == data['targetId'] || 
              fav['_id'] == data['targetId']
            );
          });
        }
      }
    });
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _favoritesService.getFavorites(page: 1, limit: 50);
      
      // Set timeout
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted && _isLoading) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    } catch (e) {
      AppLogger.error('Failed to load favorites: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _removeFavorite(dynamic favorite) {
    final targetId = favorite['targetId'] ?? favorite['_id'] ?? '';
    if (targetId.isEmpty) return;

    _favoritesService.toggleFavorite(
      targetType: favorite['targetType'] ?? 'Post',
      targetId: targetId,
    );
  }

  void _showPostDetails(dynamic favorite) {
    final postId = favorite['targetId'] ?? favorite['_id'] ?? '';
    if (postId.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PostDetailsSheet(postId: postId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!_isAuthenticated) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Favorites'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite_border,
                size: 80,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                'Login to see your favorites',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/auth/login');
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.favorite, color: Colors.red),
            SizedBox(width: 8),
            Text('My Favorites'),
          ],
        ),
        actions: [
          if (_favorites.isNotEmpty)
            TextButton.icon(
              onPressed: _loadFavorites,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _favorites.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 80,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No favorites yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start liking posts to see them here',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadFavorites,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _favorites.length,
                    itemBuilder: (context, index) {
                      final favorite = _favorites[index];
                      return _buildFavoriteCard(favorite, theme);
                    },
                  ),
                ),
    );
  }

  Widget _buildFavoriteCard(dynamic favorite, ThemeData theme) {
    final targetType = favorite['targetType'] ?? 'Post';
    final createdAt = favorite['createdAt'] != null
        ? DateTime.parse(favorite['createdAt'])
        : null;

    // Try to get post data if available
    final post = favorite['post'];
    final title = post?['title'] ?? favorite['title'] ?? 'Untitled';
    final description = post?['description'] ?? favorite['description'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            _getIconForType(targetType),
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (description.isNotEmpty)
              Text(
                description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.favorite, size: 14, color: Colors.red),
                const SizedBox(width: 4),
                Text(
                  'Favorited ${_formatDate(createdAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _removeFavorite(favorite),
              tooltip: 'Remove from favorites',
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
        onTap: () => _showPostDetails(favorite),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'post':
        return Icons.article;
      case 'profile':
        return Icons.person;
      default:
        return Icons.favorite;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'recently';
    
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

  @override
  void dispose() {
    _favoritesService.off('favorites:list');
    _favoritesService.off('favorite:toggled');
    super.dispose();
  }
}
