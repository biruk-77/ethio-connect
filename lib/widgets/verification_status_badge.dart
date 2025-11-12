import 'package:flutter/material.dart';
import '../models/auth/user_model.dart';
import '../models/role_model.dart';

class VerificationStatusBadge extends StatelessWidget {
  final User? user;
  final List<Role> roles;
  final bool showLabel;
  final double size;

  const VerificationStatusBadge({
    super.key,
    required this.user,
    required this.roles,
    this.showLabel = true,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = user != null;
    final isVerified = isLoggedIn && roles.isNotEmpty;

    if (!isLoggedIn) {
      return _buildBadge(
        icon: Icons.person_outline,
        color: Colors.grey,
        label: 'Guest User',
        context: context,
      );
    }

    if (!isVerified) {
      return _buildBadge(
        icon: Icons.access_time,
        color: Colors.orange,
        label: 'Pending Verification',
        context: context,
      );
    }

    return _buildBadge(
      icon: Icons.verified,
      color: Colors.amber,
      label: 'Verified Member',
      context: context,
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required Color color,
    required String label,
    required BuildContext context,
  }) {
    if (!showLabel) {
      return Icon(icon, color: color, size: size);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: size),
          if (showLabel) ...[
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Feature Access Card for authenticated users
class FeatureAccessCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String route;
  final bool isPremium;
  final bool requiresVerification;
  final User? user;
  final List<Role> roles;

  const FeatureAccessCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
    this.isPremium = false,
    this.requiresVerification = false,
    this.user,
    this.roles = const [],
  });

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = user != null;
    final isVerified = isLoggedIn && roles.isNotEmpty;
    final canAccess = !requiresVerification || isVerified;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (isPremium) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'PREMIUM',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: canAccess
                      ? () => Navigator.pushNamed(context, route)
                      : () => _showVerificationRequired(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canAccess ? color : Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    canAccess 
                        ? 'Access Feature'
                        : 'Verification Required',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVerificationRequired(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verification Required'),
        content: const Text(
          'This feature requires account verification. Please complete the verification process to access premium features.',
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
            child: const Text('Get Verified'),
          ),
        ],
      ),
    );
  }
}
