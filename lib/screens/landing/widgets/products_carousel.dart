import 'package:flutter/material.dart';
import '../../../models/post_model.dart';
import '../../../widgets/product_image_widget.dart';
import '../../../widgets/post_like_button.dart';
import '../../../widgets/chat_with_poster_button.dart';

class ProductsCarousel extends StatelessWidget {
  final List<dynamic> products;
  final bool isLoading;

  const ProductsCarousel({
    Key? key,
    required this.products,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return _buildLoadingShimmer(theme);
    }

    // Completely hide if no products
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final countText = products.length == 1 ? '1 product found' : '${products.length} products';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Icon(Icons.shopping_bag, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Products',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                countText,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 240,
          child: products.isEmpty
              ? Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No products available',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Check back later for new items',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _buildProductCard(context, product, theme);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildProductCard(BuildContext context, dynamic product, ThemeData theme) {
    // Parse product from JSON if needed
    Product productModel;
    if (product is Product) {
      productModel = product;
    } else {
      productModel = Product.fromJson(product);
    }
    
    final post = productModel.post;
    final title = post?.title ?? 'Product';
    final price = post?.price ?? '0';
    final pictures = productModel.pictures;
    // Access isFavorited from raw product data
    final isFavorited = product is Map ? (product['isFavorited'] ?? false) : false;
    
    return Container(
      width: 200,
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: () {
            // TODO: Navigate to product details
          },
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image
              SizedBox(
                height: 110,
                child: ProductImageWidget(
                  imagePaths: pictures,
                  width: double.infinity,
                  height: 110,
                  fit: BoxFit.cover,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  placeholder: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        size: 44,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Badges row
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getConditionColor(productModel.condition),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    productModel.condition.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 7,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                if (isFavorited)
                                  Icon(Icons.bookmark, color: theme.colorScheme.primary, size: 12),
                                const SizedBox(width: 2),
                                if (productModel.allowOffers)
                                  const Icon(Icons.local_offer, size: 10, color: Colors.orange),
                              ],
                            ),
                            const SizedBox(height: 3),
                            // Title
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            // Price
                            Text(
                              'ETB $price',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            // Stock and Like button row
                            Row(
                              children: [
                                Text(
                                  'Stock: ${productModel.stockQty}',
                                  style: TextStyle(
                                    fontSize: 8,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const Spacer(),
                                // Chat button
                                ChatWithPosterButton(
                                  posterId: product['userId'] ?? '',
                                  posterName: product['user']?['displayName'] ?? 'Seller',
                                  posterPhotoUrl: product['user']?['photoURL'],
                                  itemType: 'product',
                                  compact: true,
                                ),
                                const SizedBox(width: 4),
                                // Like button
                                Transform.scale(
                                  scale: 0.7,
                                  child: PostLikeButton(
                                    postId: post?.id ?? '',
                                    postOwnerId: post?.userId ?? '',
                                    postTitle: title,
                                    initiallyLiked: false,
                                    initialLikeCount: 0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'new':
        return Colors.green;
      case 'used':
        return Colors.orange;
      case 'refurbished':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildLoadingShimmer(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: 150,
            height: 24,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                width: 200,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Card(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
