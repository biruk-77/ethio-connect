import 'package:flutter/material.dart';
import '../../../widgets/post_like_button.dart';
import '../../../models/post_model.dart';
import '../../../services/auth/auth_service.dart';
import '../../../theme/app_colors.dart';
import '../categories/post_details_sheet.dart';

class ProductsScreen extends StatefulWidget {
  final List<Product> products;
  
  const ProductsScreen({
    super.key,
    required this.products,
  });

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _authService = AuthService();
  bool _isAuthenticated = false;
  bool _hasBusinessRole = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    _isAuthenticated = await _authService.isAuthenticated();
    
    if (_isAuthenticated) {
      final roles = await _authService.getMyRoles();
      _hasBusinessRole = roles.any((role) => 
        (role.role?.name?.toLowerCase() ?? '') == 'business' || 
        (role.role?.name?.toLowerCase() ?? '') == 'seller'
      );
      if (mounted) setState(() {});
    }
  }

  void _showApplyDialog() {
    if (!_isAuthenticated) {
      _showLoginPrompt();
      return;
    }
    
    if (!_hasBusinessRole) {
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
        content: const Text('Please login to sell products.'),
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
            Text('🛍️'),
            SizedBox(width: 8),
            Text('Apply for Business Role'),
          ],
        ),
        content: const Text(
          'To sell products, you need to be verified as a Business. '
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

  void _showPostDetails(Product product) {
    // Product has postId field
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PostDetailsSheet(postId: product.postId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text('🛍️'),
            SizedBox(width: 8),
            Text('Products'),
          ],
        ),
        actions: [
          if (_isAuthenticated && _hasBusinessRole)
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'List a Product',
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/posts/create',
                  arguments: {
                    'categoryName': 'product',
                  },
                );
              },
            ),
        ],
      ),
      body: widget.products.isEmpty
              ? _buildEmptyState()
              : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: widget.products.length,
                    itemBuilder: (context, index) {
                      final product = widget.products[index];
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => _showPostDetails(product),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: product.firstImageUrl != null
                                    ? Image.network(
                                        product.firstImageUrl!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      )
                                    : Container(
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: Icon(Icons.shopping_bag, size: 60),
                                        ),
                                      ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.post?.title ?? 'Product',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (product.post?.price != null)
                                      Text(
                                        '${product.post!.price} ETB',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    const SizedBox(height: 4),
                                    PostLikeButton(
                                      postId: product.post?.id ?? '',
                                      postOwnerId: product.post?.userId ?? '',
                                      postTitle: product.post?.title ?? 'Product',
                                      initiallyLiked: false,
                                      initialLikeCount: 0,
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
              onPressed: _hasBusinessRole
                  ? () {
                      Navigator.pushNamed(
                        context,
                        '/posts/create',
                        arguments: {
                          'categoryName': 'product',
                        },
                      );
                    }
                  : _showApplyDialog,
              backgroundColor: AppColors.primary,
              icon: Icon(_hasBusinessRole ? Icons.add : Icons.store),
              label: Text(_hasBusinessRole ? 'List a Product' : 'Become a Seller'),
            )
          : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No products yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text('Be the first to list a product!'),
        ],
      ),
    );
  }
}
