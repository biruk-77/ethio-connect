import 'package:flutter/material.dart';
import '../../../models/auth/user_model.dart';

/// Quick action buttons for common user actions
/// Shows: Create Post, Verification Center, My Posts, Profile, Settings
class QuickActionButtons extends StatelessWidget {
  final User? currentUser;

  const QuickActionButtons({
    super.key,
    this.currentUser,
  });

  List<Map<String, dynamic>> _getActions() {
    final actions = <Map<String, dynamic>>[];

    // Create Post - Only for logged in users
    if (currentUser != null) {
      actions.add({
        'id': 'create_post',
        'name': 'Create Post',
        'emoji': '✏️',
        'color': const Color(0xFF4CAF50),
        'route': '/posts/create',
      });
    }

    // Messages - Only for logged in users
    if (currentUser != null) {
      actions.add({
        'id': 'messages',
        'name': 'Messages',
        'emoji': '💬',
        'color': const Color(0xFFFF9800),
        'route': '/messages',
      });
    }

    // Verification Center - Only for logged in users
    if (currentUser != null) {
      actions.add({
        'id': 'verification',
        'name': 'Verification',
        'emoji': '✅',
        'color': const Color(0xFF2196F3),
        'route': '/verification/center',
      });
    }

    // My Profile - Only for logged in users
    if (currentUser != null) {
      actions.add({
        'id': 'profile',
        'name': 'My Profile',
        'emoji': '👤',
        'color': const Color(0xFF9C27B0),
        'route': '/profile',
      });
    }

    // Settings - Available to all
    actions.add({
      'id': 'settings',
      'name': 'Settings',
      'emoji': '⚙️',
      'color': const Color(0xFF607D8B),
      'route': '/settings',
    });

    // If not logged in, show Login option
    if (currentUser == null) {
      actions.add({
        'id': 'login',
        'name': 'Login',
        'emoji': '🔐',
        'color': const Color(0xFF3F51B5),
        'route': '/auth/login',
      });

      actions.add({
        'id': 'register',
        'name': 'Sign Up',
        'emoji': '📝',
        'color': const Color(0xFFE91E63),
        'route': '/auth/register',
      });
    }

    return actions;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final actions = _getActions();

    // Don't show if no actions (shouldn't happen)
    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            currentUser != null ? 'Quick Actions' : 'Get Started',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: actions.length > 4 ? 3 : 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              return _QuickActionCard(
                emoji: action['emoji'],
                title: action['name'],
                color: action['color'],
                isDark: isDark,
                isHighlighted: action['id'] == 'create_post', // Highlight Create Post
                onTap: () {
                  Navigator.pushNamed(context, action['route']);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String emoji;
  final String title;
  final Color color;
  final bool isDark;
  final bool isHighlighted;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.emoji,
    required this.title,
    required this.color,
    required this.isDark,
    this.isHighlighted = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isHighlighted
                  ? [
                      color.withOpacity(isDark ? 0.5 : 0.3),
                      color.withOpacity(isDark ? 0.3 : 0.1),
                    ]
                  : [
                      color.withOpacity(isDark ? 0.3 : 0.1),
                      color.withOpacity(isDark ? 0.2 : 0.05),
                    ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHighlighted ? color : color.withOpacity(0.3),
              width: isHighlighted ? 2.5 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(isHighlighted ? 0.3 : 0.1),
                blurRadius: isHighlighted ? 12 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                emoji,
                style: TextStyle(
                  fontSize: isHighlighted ? 40 : 32,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isHighlighted ? FontWeight.w800 : FontWeight.bold,
                    color: isDark ? Colors.white : color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
