import 'package:flutter/material.dart';
import '../../../widgets/post_like_button.dart';
import '../../../services/auth/auth_service.dart';
import '../../../theme/app_colors.dart';
import '../categories/post_details_sheet.dart';
import '../../reports/reports_screen.dart';

class JobsScreen extends StatefulWidget {
  final List<dynamic> jobs;

  const JobsScreen({
    super.key,
    required this.jobs,
  });

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final _authService = AuthService();
  bool _isAuthenticated = false;
  bool _hasEmployerRole = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Check authentication
    _isAuthenticated = await _authService.isAuthenticated();

    // Check if user has employer role
    if (_isAuthenticated) {
      final roles = await _authService.getMyRoles();
      _hasEmployerRole = roles.any((role) =>
          (role.role?.name.toLowerCase() ?? '') == 'employer' ||
          (role.role?.name.toLowerCase() ?? '') == 'business');
      if (mounted) setState(() {});
    }
  }

  void _showApplyDialog() {
    if (!_isAuthenticated) {
      _showLoginPrompt();
      return;
    }

    if (!_hasEmployerRole) {
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
        content: const Text(
          'Please login to apply for employer role and post jobs.',
        ),
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
            Text('💼'),
            SizedBox(width: 8),
            Text('Apply for Employer Role'),
          ],
        ),
        content: const Text(
          'To post jobs, you need to be verified as an Employer. '
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

  void _showPostDetails(dynamic jobPost) {
    // Job posts have nested post object with ID
    final postId = jobPost['post']?['id'] ?? jobPost['postId'] ?? '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PostDetailsSheet(postId: postId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text('💼'),
            SizedBox(width: 8),
            Text('Job Opportunities'),
          ],
        ),
        actions: [
          if (_isAuthenticated && _hasEmployerRole)
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'Post a Job',
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/posts/create',
                  arguments: {
                    'categoryName': 'jobs',
                  },
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.flag_outlined),
            tooltip: 'My Reports',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReportsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: widget.jobs.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.jobs.length,
              itemBuilder: (context, index) {
                final jobPost = widget.jobs[index];
                final post = jobPost['post'] ?? {};
                final title =
                    post['title'] ?? jobPost['title'] ?? 'Job Position';
                final description =
                    post['description'] ?? jobPost['description'] ?? '';
                final company = jobPost['company'] ?? 'Company';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading:
                        const Icon(Icons.work, size: 40, color: Colors.blue),
                    title: Text(title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          company,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        // Like button
                        PostLikeButton(
                          postId:
                              post['_id'] ?? post['id'] ?? jobPost['id'] ?? '',
                          postOwnerId:
                              post['userId'] ?? jobPost['userId'] ?? '',
                          postTitle: title,
                          initiallyLiked: post['isFavorited'] ??
                              jobPost['isFavorited'] ??
                              false,
                          initialLikeCount: post['favoriteCount'] ??
                              jobPost['favoriteCount'] ??
                              0,
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _showPostDetails(jobPost),
                  ),
                );
              },
            ),
      floatingActionButton: _isAuthenticated
          ? FloatingActionButton.extended(
              onPressed: _hasEmployerRole
                  ? () {
                      Navigator.pushNamed(
                        context,
                        '/posts/create',
                        arguments: {
                          'categoryName': 'jobs',
                        },
                      );
                    }
                  : _showApplyDialog,
              backgroundColor: AppColors.primary,
              icon: Icon(_hasEmployerRole ? Icons.add : Icons.work),
              label:
                  Text(_hasEmployerRole ? 'Post a Job' : 'Become an Employer'),
            )
          : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.work_off, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No job posts yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text('Be the first to post a job opportunity!'),
        ],
      ),
    );
  }
}
