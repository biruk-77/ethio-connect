import 'package:flutter/material.dart';
import '../../../widgets/chat_with_poster_button.dart';
import '../../../widgets/post_like_button.dart';

class RentalsCarousel extends StatelessWidget {
  final List<dynamic> rentals;
  final bool isLoading;

  const RentalsCarousel({
    Key? key,
    required this.rentals,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return _buildLoadingShimmer(theme);
    }

    // Completely hide if no rentals
    if (rentals.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final countText = rentals.length == 1 ? '1 rental found' : '${rentals.length} rentals';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Icon(Icons.home, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Rentals',
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
          height: 220,
          child: rentals.isEmpty
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
                          Icons.home_outlined,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No rentals available',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Check back later for new listings',
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
                  itemCount: rentals.length,
                  itemBuilder: (context, index) {
                    final rental = rentals[index];
                    return _buildRentalCard(context, rental, theme);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildRentalCard(BuildContext context, dynamic rental, ThemeData theme) {
    return Container(
      width: 280,
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: () {
            // TODO: Navigate to rental details
          },
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Property image placeholder
              Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primaryContainer,
                      theme.colorScheme.secondaryContainer,
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Center(
                  child: Icon(
                    _getPropertyIcon(rental['propertyType']),
                    size: 48,
                    color: Colors.white,
                  ),
                ),
              ),
              Flexible(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Property type and furnished badge
                          Row(
                            children: [
                              if (rental['propertyType'] != null)
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade100,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        rental['propertyType'].toString().toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade900,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              const Spacer(),
                              if (rental['furnished'] == true)
                                Icon(Icons.chair, size: 14, color: theme.colorScheme.primary),
                            ],
                          ),
                          const SizedBox(height: 3),
                          
                          // Title with responsive sizing
                          LayoutBuilder(
                            builder: (context, titleConstraints) {
                              return FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: titleConstraints.maxWidth,
                                  ),
                                  child: Text(
                                    rental['title'] ?? rental['propertyName'] ?? 'Property',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 2),
                          
                          // Bedrooms and location
                          Row(
                            children: [
                              if (rental['bedrooms'] != null) ...[
                                Icon(Icons.bed, size: 12, color: theme.colorScheme.onSurfaceVariant),
                                const SizedBox(width: 2),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '${rental['bedrooms']} bed',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                              ],
                              Icon(Icons.location_on, size: 12, color: theme.colorScheme.onSurfaceVariant),
                              const SizedBox(width: 2),
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    rental['location'] ?? 'Location',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          
                          // Price and Action buttons row
                          Row(
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'ETB ${rental['rentAmount'] ?? rental['price'] ?? 0}/mo',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              // Chat button
                              ChatWithPosterButton(
                                posterId: rental['userId'] ?? '',
                                posterName: rental['ownerName'] ?? 'Owner',
                                posterPhotoUrl: rental['user']?['photoURL'],
                                itemType: 'rental',
                                compact: true,
                              ),
                              const SizedBox(width: 4),
                              // Like button
                              Transform.scale(
                                scale: 0.8,
                                child: PostLikeButton(
                                  postId: rental['post']?['_id'] ?? rental['post']?['id'] ?? rental['id'] ?? '',
                                  postOwnerId: rental['post']?['userId'] ?? rental['userId'] ?? '',
                                  postTitle: rental['title'] ?? rental['propertyName'] ?? 'Property',
                                  initiallyLiked: rental['post']?['isFavorited'] ?? rental['isFavorited'] ?? false,
                                  initialLikeCount: rental['post']?['favoriteCount'] ?? rental['favoriteCount'] ?? 0,
                                ),
                              ),
                            ],
                          ),
                        ],
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

  IconData _getPropertyIcon(String? type) {
    if (type == null) return Icons.home;
    
    switch (type.toLowerCase()) {
      case 'apartment':
        return Icons.apartment;
      case 'house':
        return Icons.house;
      case 'villa':
        return Icons.villa;
      case 'studio':
        return Icons.home_work;
      default:
        return Icons.home;
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
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                width: 280,
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
