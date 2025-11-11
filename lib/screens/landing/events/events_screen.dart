import 'package:flutter/material.dart';
import '../../../widgets/post_like_button.dart';
import '../../../services/auth/auth_service.dart';
import '../../../theme/app_colors.dart';
import '../categories/post_details_sheet.dart';

class EventsScreen extends StatefulWidget {
  final List<dynamic> events;
  
  const EventsScreen({
    super.key,
    required this.events,
  });

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final _authService = AuthService();
  bool _isLoading = false;
  bool _isAuthenticated = false;
  bool _hasOrganizerRole = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    _isAuthenticated = await _authService.isAuthenticated();
    
    if (_isAuthenticated) {
      final roles = await _authService.getMyRoles();
      _hasOrganizerRole = roles.any((role) => 
        (role.role?.name?.toLowerCase() ?? '') == 'event organizer' || 
        (role.role?.name?.toLowerCase() ?? '') == 'organizer'
      );
      if (mounted) setState(() {});
    }
  }

  void _showApplyDialog() {
    if (!_isAuthenticated) {
      _showLoginPrompt();
      return;
    }
    
    if (!_hasOrganizerRole) {
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
        content: const Text('Please login to create events.'),
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
            Text('🎉'),
            SizedBox(width: 8),
            Text('Apply for Event Organizer Role'),
          ],
        ),
        content: const Text(
          'To create events, you need to be verified as an Event Organizer. '
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

  void _showPostDetails(dynamic event) {
    final postId = event['post']?['id'] ?? event['postId'] ?? '';
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
            Text('🎉'),
            SizedBox(width: 8),
            Text('Events & Activities'),
          ],
        ),
        actions: [
          if (_isAuthenticated && _hasOrganizerRole)
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'Create Event',
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/posts/create',
                  arguments: {
                    'categoryName': 'events',
                  },
                );
              },
            ),
        ],
      ),
      body: widget.events.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.events.length,
                    itemBuilder: (context, index) {
                      final event = widget.events[index];
                      final post = event['post'] ?? {};
                      final title = post['title'] ?? event['title'] ?? 'Event';
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => _showPostDetails(event),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (post.product?.firstImageUrl != null)
                                Stack(
                                  children: [
                                    Image.network(
                                      post.product!.firstImageUrl!,
                                      height: 180,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned(
                                      top: 12,
                                      right: 12,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(Icons.event, color: Colors.white, size: 16),
                                            SizedBox(width: 4),
                                            Text(
                                              'Event',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      post.title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                        post.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Date & time coming soon',
                                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                        ),
                                        const Spacer(),
                                        PostLikeButton(
                                          postId: post['_id'] ?? post['id'] ?? event['id'] ?? '',
                                          postOwnerId: post['userId'] ?? event['userId'] ?? '',
                                          postTitle: title,
                                          initiallyLiked: post['isFavorited'] ?? event['isFavorited'] ?? false,
                                          initialLikeCount: post['favoriteCount'] ?? event['favoriteCount'] ?? 0,
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
              onPressed: _hasOrganizerRole
                  ? () {
                      Navigator.pushNamed(
                        context,
                        '/posts/create',
                        arguments: {
                          'categoryName': 'events',
                        },
                      );
                    }
                  : _showApplyDialog,
              backgroundColor: AppColors.primary,
              icon: Icon(_hasOrganizerRole ? Icons.add : Icons.celebration),
              label: Text(_hasOrganizerRole ? 'Create an Event' : 'Become an Organizer'),
            )
          : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.event_busy, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No events yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text('Be the first to create an event!'),
        ],
      ),
    );
  }
}
