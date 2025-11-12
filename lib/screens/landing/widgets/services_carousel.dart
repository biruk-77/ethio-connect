import 'package:flutter/material.dart';
import '../../../widgets/chat_with_poster_button.dart';
import '../../../widgets/post_like_button.dart';

class ServicesCarousel extends StatelessWidget {
  final List<dynamic> services;
  final bool isLoading;

  const ServicesCarousel({
    Key? key,
    required this.services,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return _buildLoadingShimmer(theme);
    }

    final countText = services.length == 1
        ? '1 service found'
        : '${services.length} services';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Icon(Icons.design_services, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Services',
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
          height: 180,
          child: services.isEmpty
              ? Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.handyman_outlined,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant
                              .withOpacity(0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No services available',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Check back later for new services',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant
                                .withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final service = services[index];
                    return _buildServiceCard(context, service, theme);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildServiceCard(
      BuildContext context, dynamic service, ThemeData theme) {
    return Container(
      width: 260,
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: () {
            // TODO: Navigate to service details
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getServiceIcon(service['serviceType']),
                        color: theme.colorScheme.onSecondaryContainer,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (service['serviceType'] != null)
                            Text(
                              service['serviceType'].toString().toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          Text(
                            service['title'] ??
                                service['serviceName'] ??
                                'Service',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (service['post']?['isFavorited'] == true ||
                        service['isFavorited'] == true)
                      Icon(Icons.bookmark,
                          color: theme.colorScheme.primary, size: 16),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  service['description'] ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (service['rate'] != null || service['price'] != null)
                      Text(
                        'ETB ${service['rate'] ?? service['price']}/hr',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    const Spacer(),
                    // Like button
                    Transform.scale(
                      scale: 0.85,
                      child: PostLikeButton(
                        postId: service['post']?['_id'] ??
                            service['post']?['id'] ??
                            service['id'] ??
                            '',
                        postOwnerId: service['post']?['userId'] ??
                            service['userId'] ??
                            '',
                        postTitle: service['title'] ??
                            service['serviceName'] ??
                            'Service',
                        initiallyLiked: service['post']?['isFavorited'] ??
                            service['isFavorited'] ??
                            false,
                        initialLikeCount: service['post']?['favoriteCount'] ??
                            service['favoriteCount'] ??
                            0,
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Chat button
                    ChatWithPosterButton(
                      posterId: service['userId'] ?? '',
                      posterName: service['providerName'] ?? 'Provider',
                      posterPhotoUrl: service['user']?['photoURL'],
                      itemType: 'service',
                      compact: true,
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getServiceIcon(String? type) {
    if (type == null) return Icons.handyman;

    switch (type.toLowerCase()) {
      case 'professional':
        return Icons.business_center;
      case 'home':
        return Icons.home_repair_service;
      case 'technical':
        return Icons.build;
      case 'creative':
        return Icons.palette;
      default:
        return Icons.handyman;
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
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                width: 260,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Card(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withOpacity(0.3),
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
