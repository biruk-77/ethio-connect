import 'package:flutter/material.dart';
import '../../../widgets/post_like_button.dart';
import '../../../services/auth/auth_service.dart';
import '../../../theme/app_colors.dart';
import '../categories/post_details_sheet.dart';

class MatchmakingScreen extends StatefulWidget {
  final List<dynamic> matchmaking;
  
  const MatchmakingScreen({
    super.key,
    required this.matchmaking,
  });

  @override
  State<MatchmakingScreen> createState() => _MatchmakingScreenState();
}

class _MatchmakingScreenState extends State<MatchmakingScreen> {
  final _authService = AuthService();
  bool _isAuthenticated = false;
  bool _hasMatchmakerRole = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    _isAuthenticated = await _authService.isAuthenticated();
    
    if (_isAuthenticated) {
      final roles = await _authService.getMyRoles();
      _hasMatchmakerRole = roles.any((role) => 
        (role.role?.name?.toLowerCase() ?? '') == 'matchmaker' || 
        (role.role?.name?.toLowerCase() ?? '') == 'verified'
      );
      if (mounted) setState(() {});
    }
  }

  void _showApplyDialog() {
    if (!_isAuthenticated) {
      _showLoginPrompt();
      return;
    }
    
    if (!_hasMatchmakerRole) {
      _showApplyForRoleDialog();
    }
  }

  void _showLoginPrompt() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lock, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Login Required'),
          ],
        ),
        content: const Text('Please login to use matchmaking services.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/auth/login');
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  void _showApplyForRoleDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Text('💑'),
            SizedBox(width: 8),
            Text('Apply for Matchmaker Role'),
          ],
        ),
        content: const Text(
          'To provide matchmaking services, you need to be verified as a Matchmaker. '
          'Would you like to apply for this role?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/verification/center');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Apply Now'),
          ),
        ],
      ),
    );
  }

  void _showPostDetails(dynamic matchPost) {
    // Matchmaking posts have nested post object or postId
    final postId = matchPost['post']?['id'] ?? matchPost['postId'] ?? '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PostDetailsSheet(postId: postId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text('💑'),
            SizedBox(width: 8),
            Text('Matchmaking'),
          ],
        ),
        actions: [
          if (_isAuthenticated && _hasMatchmakerRole)
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'Create Profile',
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/posts/create',
                  arguments: {
                    'categoryName': 'matchmaking',
                  },
                );
              },
            ),
        ],
      ),
      body: widget.matchmaking.isEmpty
              ? _buildEmptyState()
              : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: widget.matchmaking.length,
                    itemBuilder: (context, index) {
                      final matchPost = widget.matchmaking[index];
                      final post = matchPost['post'] ?? {};
                      final title = post['title'] ?? matchPost['title'] ?? 'Profile';
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => _showPostDetails(matchPost),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: post.product?.firstImageUrl != null
                                    ? Image.network(
                                        post.product!.firstImageUrl!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      )
                                    : Container(
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: Icon(Icons.person, size: 60),
                                        ),
                                      ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                          post['description'] ?? '',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      const SizedBox(height: 4),
                                      PostLikeButton(
                                        postId: post['_id'] ?? post['id'] ?? matchPost['id'] ?? '',
                                        postOwnerId: post['userId'] ?? matchPost['userId'] ?? '',
                                        postTitle: title,
                                        initiallyLiked: post['isFavorited'] ?? matchPost['isFavorited'] ?? false,
                                        initialLikeCount: post['favoriteCount'] ?? matchPost['favoriteCount'] ?? 0,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      floatingActionButton: _isAuthenticated
          ? FloatingActionButton.extended(
              onPressed: _hasMatchmakerRole
                  ? () {
                      Navigator.pushNamed(
                        context,
                        '/posts/create',
                        arguments: {
                          'categoryName': 'matchmaking',
                        },
                      );
                    }
                  : _showApplyDialog,
              backgroundColor: AppColors.primary,
              icon: Icon(_hasMatchmakerRole ? Icons.add : Icons.favorite),
              label: Text(_hasMatchmakerRole ? 'Create Profile' : 'Become a Matchmaker'),
            )
          : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite_border, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No profiles yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text('Be the first to create a profile!'),
        ],
      ),
    );
  }
}
