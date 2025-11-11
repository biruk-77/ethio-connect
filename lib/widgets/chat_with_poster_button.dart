import 'package:flutter/material.dart';
import '../screens/messaging/chat_screen.dart';
import '../services/auth/auth_service.dart';
import '../utils/app_logger.dart';

/// Reusable "Chat with Poster" button
/// Shows on all posts, products, jobs, services, rentals
class ChatWithPosterButton extends StatelessWidget {
  final String posterId;
  final String posterName;
  final String? posterPhotoUrl;
  final String? postId; // Optional: Pass postId for post-based chats
  final bool compact; // true for carousel cards, false for detail pages
  final String itemType; // 'post', 'product', 'job', etc.

  const ChatWithPosterButton({
    super.key,
    required this.posterId,
    required this.posterName,
    this.posterPhotoUrl,
    this.postId,
    this.compact = false,
    this.itemType = 'post',
  });

  Future<void> _handleChatPress(BuildContext context) async {
    final authService = AuthService();
    final currentUser = await authService.getStoredUser();

    if (currentUser == null) {
      if (!context.mounted) return;
      
      // Show login prompt
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.chat_bubble, color: Colors.blue),
              SizedBox(width: 12),
              Text('Login Required'),
            ],
          ),
          content: const Text('You need to login to chat with sellers and posters.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Login'),
            ),
          ],
        ),
      );

      if (result == true && context.mounted) {
        Navigator.pushNamed(context, '/auth/login');
      }
      return;
    }

    // Check if trying to chat with self
    if (currentUser.id == posterId) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You cannot chat with yourself'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    AppLogger.info('💬 Opening chat with: $posterName ($posterId)');
    if (postId != null) {
      AppLogger.info('💬 Post-based chat for post: $postId');
    }

    // Navigate to chat screen
    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          userId: posterId,
          username: posterName,
          photoURL: posterPhotoUrl,
          postId: postId, // Pass postId for context
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (compact) {
      // Compact button for carousel cards
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleChatPress(context),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Chat',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Full button for detail pages
    return ElevatedButton.icon(
      onPressed: () => _handleChatPress(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      icon: const Icon(Icons.chat_bubble_rounded, size: 20),
      label: Text(
        'Chat with ${_getItemTypeText()}',
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _getItemTypeText() {
    switch (itemType.toLowerCase()) {
      case 'product':
        return 'Seller';
      case 'job':
        return 'Employer';
      case 'service':
        return 'Provider';
      case 'rental':
        return 'Owner';
      case 'event':
        return 'Organizer';
      case 'matchmaking':
        return 'User';
      default:
        return 'Poster';
    }
  }
}
