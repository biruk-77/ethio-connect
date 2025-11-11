import 'package:flutter/material.dart';
import '../../../widgets/post_like_button.dart';
import '../../../widgets/chat_with_poster_button.dart';

class JobsCarousel extends StatelessWidget {
  final List<dynamic> jobs;
  final bool isLoading;

  const JobsCarousel({
    super.key,
    required this.jobs,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return _buildLoadingShimmer(theme);
    }

    // Completely hide if no jobs
    if (jobs.isEmpty) {
      return const SizedBox.shrink();
    }

    final countText = jobs.length == 1 ? '1 job post found' : '${jobs.length} job posts';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Icon(Icons.work, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Job Opportunities',
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
          child: jobs.isEmpty
              ? Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.work_outline,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No job posts yet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'New opportunities coming soon',
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
                  itemCount: jobs.length,
                  itemBuilder: (context, index) {
                    final job = jobs[index];
                    return _buildJobCard(context, job, theme);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildJobCard(BuildContext context, dynamic job, ThemeData theme) {
    // Extract nested post data
    final post = job['post'];
    final title = post?['title'] ?? job['title'] ?? 'Job Position';
    
    return Container(
      width: 300,
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: () {
            // TODO: Navigate to job details
          },
          borderRadius: BorderRadius.circular(12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with icon and company/title
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.business,
                            color: theme.colorScheme.onPrimaryContainer,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  job['company'] ?? 'Company',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (post?['isFavorited'] == true || job['isFavorited'] == true)
                          Icon(Icons.bookmark, color: theme.colorScheme.primary, size: 16),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Tags
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        if (job['employmentType'] != null)
                          _buildChip(job['employmentType'], Colors.blue, theme),
                        if (job['experienceLevel'] != null)
                          _buildChip(job['experienceLevel'], Colors.green, theme),
                        if (job['remote'] == true) _buildChip('Remote', Colors.purple, theme),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Salary
                    if (job['salaryMin'] != null || job['salaryMax'] != null)
                      Row(
                        children: [
                          Icon(
                            Icons.attach_money,
                            size: 14,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 3),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'ETB ${job['salaryMin'] ?? 0} - ${job['salaryMax'] ?? 0}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
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
                          size: 13,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              job['location'] ?? 'Location not specified',
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Action buttons row
                    Row(
                      children: [
                        // Chat button
                        ChatWithPosterButton(
                          posterId: post?['userId'] ?? job['userId'] ?? '',
                          posterName: job['company'] ?? 'Employer',
                          itemType: 'job',
                          compact: true,
                        ),
                        const Spacer(),
                        // Like button
                        Transform.scale(
                          scale: 0.85,
                          child: PostLikeButton(
                            postId: post?['_id'] ?? post?['id'] ?? job['id'] ?? '',
                            postOwnerId: post?['userId'] ?? job['userId'] ?? '',
                            postTitle: title,
                            initiallyLiked: post?['isFavorited'] ?? job['isFavorited'] ?? false,
                            initialLikeCount: post?['favoriteCount'] ?? job['favoriteCount'] ?? 0,
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
      ),
    );
  }

  Widget _buildChip(String label, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
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
            width: 200,
            height: 24,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
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
                width: 300,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Card(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
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
