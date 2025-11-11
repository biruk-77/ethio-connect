import 'package:flutter/material.dart';
import '../../../widgets/chat_with_poster_button.dart';

class MatchmakingCarousel extends StatelessWidget {
  final List<dynamic> matchmakingPosts;
  final bool isLoading;

  const MatchmakingCarousel({
    super.key,
    required this.matchmakingPosts,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return _buildLoadingShimmer(theme);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.favorite, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Matchmaking',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/matchmaking');
                },
                child: const Text('View All'),
              ),
            ],
          ),
        ),

        // Carousel
        SizedBox(
          height: 220,
          child: matchmakingPosts.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No matchmaking posts yet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Check back later for profiles',
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
                  itemCount: matchmakingPosts.length,
                  itemBuilder: (context, index) {
                    final post = matchmakingPosts[index];
                    return _buildMatchmakingCard(context, post, theme);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMatchmakingCard(BuildContext context, dynamic post, ThemeData theme) {
    final name = post['name'] ?? 'Unknown';
    final age = post['age'] ?? 0;
    final gender = post['gender'] ?? 'N/A';
    final location = post['location'] ?? 'Not specified';
    final bio = post['bio'] ?? '';
    final religion = post['religion'] ?? '';
    final education = post['education'] ?? '';
    final photoUrl = post['photoUrl'];

    return Container(
      width: 280,
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: () {
            // Navigate to matchmaking details
            Navigator.pushNamed(
              context,
              '/matchmaking/details',
              arguments: {'postId': post['_id'] ?? post['id']},
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: photoUrl != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.network(
                          photoUrl,
                          width: double.infinity,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Icon(
                              Icons.person,
                              size: 48,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.person,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
              ),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name, Age, Gender
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '$name, $age',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: gender.toLowerCase() == 'male'
                                  ? Colors.blue.shade100
                                  : Colors.pink.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              gender,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: gender.toLowerCase() == 'male'
                                    ? Colors.blue.shade900
                                    : Colors.pink.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Location
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              location,
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Bio
                      if (bio.isNotEmpty)
                        Text(
                          bio,
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                      const Spacer(),

                      // Chat Button
                      Row(
                        children: [
                          if (religion.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                religion,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          const Spacer(),
                          ChatWithPosterButton(
                            posterId: post['userId'] ?? '',
                            posterName: name,
                            posterPhotoUrl: photoUrl,
                            postId: post['_id'] ?? post['id'],
                            itemType: 'matchmaking',
                            compact: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
