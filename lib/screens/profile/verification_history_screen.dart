import 'package:flutter/material.dart';
import '../../services/auth/auth_service.dart';
import '../../models/auth/verification_model.dart';
import '../../utils/app_logger.dart';
import '../../config/auth_api_config.dart';

class VerificationHistoryScreen extends StatefulWidget {
  const VerificationHistoryScreen({super.key});

  @override
  State<VerificationHistoryScreen> createState() => _VerificationHistoryScreenState();
}

class _VerificationHistoryScreenState extends State<VerificationHistoryScreen> {
  final AuthService _authService = AuthService();
  List<Verification> _verifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadVerifications();
  }

  Future<void> _loadVerifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final verifications = await _authService.getMyVerifications();
      
      if (mounted) {
        setState(() {
          _verifications = verifications;
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error('Failed to load verifications: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Submit New Verification',
            onPressed: () async {
              final result = await Navigator.pushNamed(
                context,
                '/verification/submit',
              );
              if (result == true) {
                _loadVerifications(); // Refresh list
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorView()
              : _verifications.isEmpty
                  ? _buildEmptyView()
                  : RefreshIndicator(
                      onRefresh: _loadVerifications,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _verifications.length,
                        itemBuilder: (context, index) {
                          return _buildVerificationCard(
                            _verifications[index],
                            theme,
                          );
                        },
                      ),
                    ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Failed to Load Verifications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadVerifications,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.verified_user_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            const Text(
              'No Verifications Yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Submit your documents to get verified and unlock all features',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.pushNamed(
                  context,
                  '/verification/submit',
                );
                if (result == true) {
                  _loadVerifications();
                }
              },
              icon: const Icon(Icons.upload_file),
              label: const Text('Submit Verification'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationCard(Verification verification, ThemeData theme) {
    final type = verification.type;
    final status = verification.status;
    final documentUrl = verification.documentUrl;
    final createdAt = verification.createdAt;
    final notes = verification.notes;

    // Build full image URL (verification docs use auth domain)
    final fullImageUrl = documentUrl != null 
        ? '${AuthApiConfig.baseUrl}$documentUrl'
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: () {
          _showVerificationDetails(verification, fullImageUrl);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Document thumbnail
                  if (fullImageUrl != null)
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: theme.colorScheme.surfaceVariant,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          fullImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.broken_image, size: 32);
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          },
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: theme.colorScheme.surfaceVariant,
                      ),
                      child: const Icon(Icons.description, size: 32),
                    ),

                  const SizedBox(width: 16),

                  // Verification info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getVerificationTypeLabel(type),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(createdAt),
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status badge
                  _buildStatusBadge(status),
                ],
              ),

              // Notes if any
              if (notes != null && notes.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.note,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          notes,
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;
    String label;

    switch (status.toLowerCase()) {
      case 'approved':
        color = Colors.green;
        icon = Icons.check_circle;
        label = 'Approved';
        break;
      case 'rejected':
        color = Colors.red;
        icon = Icons.cancel;
        label = 'Rejected';
        break;
      case 'pending':
      default:
        color = Colors.orange;
        icon = Icons.pending;
        label = 'Pending';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getVerificationTypeLabel(String type) {
    switch (type) {
      case 'kyc':
        return 'KYC Verification';
      case 'national_id':
        return 'National ID';
      case 'passport':
        return 'Passport';
      case 'driver_license':
        return 'Driver License';
      case 'doctor_license':
        return 'Doctor License';
      case 'lawyer_license':
        return 'Lawyer License';
      case 'teacher_cert':
        return 'Teacher Certificate';
      case 'engineer_cert':
        return 'Engineer Certificate';
      case 'business_license':
        return 'Business License';
      default:
        return type.split('_').map((word) {
          return word[0].toUpperCase() + word.substring(1);
        }).join(' ');
    }
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  void _showVerificationDetails(Verification verification, String? imageUrl) {
    final type = verification.type;
    final status = verification.status;
    final notes = verification.notes;
    final createdAt = verification.createdAt;
    final verifiedAt = verification.verifiedAt;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(24),
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    _getVerificationTypeLabel(type),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Status
                  _buildStatusBadge(status),
                  const SizedBox(height: 24),

                  // Document image
                  if (imageUrl != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.broken_image, size: 48),
                                  SizedBox(height: 8),
                                  Text('Failed to load image'),
                                ],
                              ),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 200,
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Details
                  if (createdAt != null)
                    _buildDetailRow('Submitted', _formatDate(createdAt)),
                  if (verifiedAt != null)
                    _buildDetailRow('Verified', _formatDate(verifiedAt)),
                  if (notes != null && notes.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Notes:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(notes),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
