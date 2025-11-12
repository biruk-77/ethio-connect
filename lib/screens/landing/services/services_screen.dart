import 'package:flutter/material.dart';
import '../../../widgets/post_like_button.dart';
import '../../../services/auth/auth_service.dart';
import '../../../theme/app_colors.dart';
import '../categories/post_details_sheet.dart';

class ServicesScreen extends StatefulWidget {
  final List<dynamic> services;
  
  const ServicesScreen({
    super.key,
    required this.services,
  });

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final _authService = AuthService();
  bool _isAuthenticated = false;
  bool _hasProviderRole = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    _isAuthenticated = await _authService.isAuthenticated();
    
    if (_isAuthenticated) {
      final roles = await _authService.getMyRoles();
      _hasProviderRole = roles.any((role) => 
        (role.role?.name.toLowerCase() ?? '') == 'service provider' || 
        (role.role?.name.toLowerCase() ?? '') == 'professional'
      );
      if (mounted) setState(() {});
    }
  }

  void _showApplyDialog() {
    if (!_isAuthenticated) {
      _showLoginPrompt();
      return;
    }
    
    if (!_hasProviderRole) {
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
        content: const Text('Please login to offer services.'),
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
            Text('🔧'),
            SizedBox(width: 8),
            Text('Apply for Service Provider Role'),
          ],
        ),
        content: const Text(
          'To offer services, you need to be verified as a Service Provider. '
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

  void _showPostDetails(dynamic service) {
    // Services have nested post object or postId
    final postId = service['post']?['id'] ?? service['postId'] ?? '';
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
            Text('🔧'),
            SizedBox(width: 8),
            Text('Services'),
          ],
        ),
        actions: [
          if (_isAuthenticated && _hasProviderRole)
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'Offer a Service',
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/posts/create',
                  arguments: {
                    'categoryName': 'service',
                  },
                );
              },
            ),
        ],
      ),
      body: widget.services.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.services.length,
                    itemBuilder: (context, index) {
                      final service = widget.services[index];
                      final post = service['post'] ?? {};
                      final title = post['title'] ?? service['title'] ?? 'Service';
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.primary,
                            child: Icon(Icons.build, color: Colors.white),
                          ),
                          title: Text(title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post['description'] ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              PostLikeButton(
                                postId: post['_id'] ?? post['id'] ?? service['id'] ?? '',
                                postOwnerId: post['userId'] ?? service['userId'] ?? '',
                                postTitle: title,
                                initiallyLiked: post['isFavorited'] ?? service['isFavorited'] ?? false,
                                initialLikeCount: post['favoriteCount'] ?? service['favoriteCount'] ?? 0,
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => _showPostDetails(service),
                        ),
                      );
                    },
                  ),
      floatingActionButton: _isAuthenticated
          ? FloatingActionButton.extended(
              onPressed: _hasProviderRole
                  ? () {
                      Navigator.pushNamed(
                        context,
                        '/posts/create',
                        arguments: {
                          'categoryName': 'service',
                        },
                      );
                    }
                  : _showApplyDialog,
              backgroundColor: AppColors.primary,
              icon: Icon(_hasProviderRole ? Icons.add : Icons.handyman),
              label: Text(_hasProviderRole ? 'Offer a Service' : 'Become a Provider'),
            )
          : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.miscellaneous_services_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No services yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text('Be the first to offer a service!'),
        ],
      ),
    );
  }
}
