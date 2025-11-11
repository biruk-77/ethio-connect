import 'package:flutter/material.dart';
import '../../services/auth/auth_service.dart';
import '../../models/auth/verification_model.dart';
import '../../models/auth/role_model.dart';
import '../../utils/app_logger.dart';
import '../../config/auth_api_config.dart';

class VerificationCenterScreen extends StatefulWidget {
  const VerificationCenterScreen({super.key});

  @override
  State<VerificationCenterScreen> createState() => _VerificationCenterScreenState();
}

class _VerificationCenterScreenState extends State<VerificationCenterScreen> {
  final AuthService _authService = AuthService();
  
  List<Verification> _verifications = [];
  List<UserRole> _userRoles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final verifications = await _authService.getMyVerifications();
    final roles = await _authService.getMyRoles();

    setState(() {
      _verifications = verifications;
      _userRoles = roles;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification Center'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // My Roles Section
                    _buildSection(
                      title: 'My Roles',
                      icon: Icons.badge,
                      color: theme.colorScheme.primary,
                      child: _buildRolesSection(),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Verification Status Section
                    _buildSection(
                      title: 'Verification Status',
                      icon: Icons.verified_user,
                      color: Colors.orange,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildVerificationsSection(),
                          if (_verifications.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(context, '/profile/verifications');
                              },
                              icon: const Icon(Icons.history, size: 18),
                              label: const Text('View Full History'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Submit New Verification
                    ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.pushNamed(context, '/verification/submit');
                        _loadData(); // Refresh after returning
                      },
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Submit New Verification'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Logout
                    OutlinedButton.icon(
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Logout'),
                            content: const Text('Are you sure you want to logout?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Logout'),
                              ),
                            ],
                          ),
                        );
                        
                        if (confirmed == true && mounted) {
                          await _authService.logout();
                          if (mounted) {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/',
                              (route) => false,
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildRolesSection() {
    if (_userRoles.isEmpty) {
      return const Text(
        'No roles assigned yet',
        style: TextStyle(color: Colors.grey),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _userRoles.map((userRole) {
        final roleName = userRole.role?.name ?? 'Unknown';
        return Chip(
          label: Text(roleName.toUpperCase()),
          avatar: const Icon(Icons.check_circle, size: 18),
        );
      }).toList(),
    );
  }

  Widget _buildVerificationsSection() {
    if (_verifications.isEmpty) {
      return Column(
        children: [
          Icon(
            Icons.info_outline,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          const Text(
            'No verifications submitted yet',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          const Text(
            'Submit a verification to access more features',
            style: TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return Column(
      children: _verifications.map((verification) {
        return _buildVerificationCard(verification);
      }).toList(),
    );
  }

  Widget _buildVerificationCard(Verification verification) {
    final documentUrl = verification.documentUrl;
    final fullImageUrl = documentUrl != null 
        ? '${AuthApiConfig.baseUrl}$documentUrl'
        : null;
    
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (verification.isPending) {
      statusColor = Colors.orange;
      statusIcon = Icons.pending;
      statusText = 'PENDING';
    } else if (verification.isApproved) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = 'APPROVED';
    } else if (verification.isRejected) {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
      statusText = 'REJECTED';
    } else {
      statusColor = Colors.grey;
      statusIcon = Icons.help;
      statusText = verification.status.toUpperCase();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Document thumbnail
            if (fullImageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  fullImageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.description,
                        color: Colors.grey.shade400,
                      ),
                    );
                  },
                ),
              ),
            if (fullImageUrl != null) const SizedBox(width: 12),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          verification.type.replaceAll('_', ' ').toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: statusColor),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, size: 14, color: statusColor),
                            const SizedBox(width: 4),
                            Text(
                              statusText,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (verification.notes != null && verification.notes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      verification.notes!,
                      style: TextStyle(
                        fontSize: 12,
                        color: verification.isRejected ? Colors.red : Colors.grey.shade700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    'Submitted ${_formatDate(verification.createdAt)}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
