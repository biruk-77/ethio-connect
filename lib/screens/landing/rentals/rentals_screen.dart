import 'package:flutter/material.dart';
import '../../../widgets/post_like_button.dart';
import '../../../services/auth/auth_service.dart';
import '../../../theme/app_colors.dart';
import '../categories/post_details_sheet.dart';

class RentalsScreen extends StatefulWidget {
  final List<dynamic> rentals;
  
  const RentalsScreen({
    super.key,
    required this.rentals,
  });

  @override
  State<RentalsScreen> createState() => _RentalsScreenState();
}

class _RentalsScreenState extends State<RentalsScreen> {
  final _authService = AuthService();
  bool _isAuthenticated = false;
  bool _hasLandlordRole = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    _isAuthenticated = await _authService.isAuthenticated();
    
    if (_isAuthenticated) {
      final roles = await _authService.getMyRoles();
      _hasLandlordRole = roles.any((role) => 
        (role.role?.name.toLowerCase() ?? '') == 'landlord' || 
        (role.role?.name.toLowerCase() ?? '') == 'business'
      );
      if (mounted) setState(() {});
    }
  }

  void _showApplyDialog() {
    if (!_isAuthenticated) {
      _showLoginPrompt();
      return;
    }
    
    if (!_hasLandlordRole) {
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
        content: const Text('Please login to list rental properties.'),
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
            Text('🏠'),
            SizedBox(width: 8),
            Text('Apply for Landlord Role'),
          ],
        ),
        content: const Text(
          'To list rental properties, you need to be verified as a Landlord. '
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

  void _showPostDetails(dynamic rental) {
    // Rental listings have nested post object or postId
    final postId = rental['post']?['id'] ?? rental['postId'] ?? '';
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
            Text('🏠'),
            SizedBox(width: 8),
            Text('Rentals & Real Estate'),
          ],
        ),
        actions: [
          if (_isAuthenticated && _hasLandlordRole)
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'List a Property',
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/posts/create',
                  arguments: {
                    'categoryName': 'rental',
                  },
                );
              },
            ),
        ],
      ),
      body: widget.rentals.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.rentals.length,
                    itemBuilder: (context, index) {
                      final rental = widget.rentals[index];
                      final post = rental['post'] ?? {};
                      final title = post['title'] ?? rental['title'] ?? 'Rental';
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => _showPostDetails(rental),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (rental['images'] != null && rental['images'].isNotEmpty)
                                Image.network(
                                  'https://ethiopost.unitybingo.com${rental['images'][0]}',
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                        post['description'] ?? '',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        if (post['price'] != null)
                                          Text(
                                            '${post['price']} ETB/month',
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        const Spacer(),
                                        PostLikeButton(
                                          postId: post['_id'] ?? post['id'] ?? rental['id'] ?? '',
                                          postOwnerId: post['userId'] ?? rental['userId'] ?? '',
                                          postTitle: title,
                                          initiallyLiked: post['isFavorited'] ?? rental['isFavorited'] ?? false,
                                          initialLikeCount: post['favoriteCount'] ?? rental['favoriteCount'] ?? 0,
                                        ),
                                      ],
                                    ),
                                  ],
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
              onPressed: _hasLandlordRole
                  ? () {
                      Navigator.pushNamed(
                        context,
                        '/posts/create',
                        arguments: {
                          'categoryName': 'rental',
                        },
                      );
                    }
                  : _showApplyDialog,
              backgroundColor: AppColors.primary,
              icon: Icon(_hasLandlordRole ? Icons.add : Icons.home_work),
              label: Text(_hasLandlordRole ? 'List a Property' : 'Become a Landlord'),
            )
          : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.home_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No rental properties yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text('Be the first to list a property!'),
        ],
      ),
    );
  }
}
