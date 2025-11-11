import 'package:flutter/material.dart';
import '../../../models/message_model.dart';
import '../../../services/conversation_service.dart';
import '../../../utils/app_logger.dart';
import '../chat_screen.dart';

/// Horizontal carousel of recent chat conversations
/// Shows avatars with unread badges for quick access
class ChatCarousel extends StatefulWidget {
  const ChatCarousel({super.key});

  @override
  State<ChatCarousel> createState() => _ChatCarouselState();
}

class _ChatCarouselState extends State<ChatCarousel> {
  final ConversationService _conversationService = ConversationService();
  List<Conversation> _conversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    try {
      final conversations = await _conversationService.getConversations(
        page: 1,
        limit: 10, // Only show recent 10
      );
      
      if (mounted) {
        setState(() {
          _conversations = conversations;
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error('Failed to load carousel conversations: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_conversations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _conversations.length,
        itemBuilder: (context, index) {
          return _buildChatButton(_conversations[index]);
        },
      ),
    );
  }

  Widget _buildChatButton(Conversation conversation) {
    final hasUnread = conversation.unreadCount > 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              userId: conversation.otherUser.id,
              username: conversation.otherUser.displayName,
              photoURL: conversation.otherUser.photoURL,
            ),
          ),
        );
      },
      child: Container(
        width: 70,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar with badge
            Stack(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: hasUnread ? Colors.blue : Colors.grey[300]!,
                      width: hasUnread ? 3 : 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: conversation.otherUser.photoURL != null
                        ? NetworkImage(conversation.otherUser.photoURL!)
                        : null,
                    child: conversation.otherUser.photoURL == null
                        ? Text(
                            conversation.otherUser.displayName[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                ),
                // Online status
                if (conversation.otherUser.status == 'online')
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                // Unread badge
                if (hasUnread)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Text(
                        conversation.unreadCount > 99
                            ? '99+'
                            : conversation.unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            // Name
            Text(
              conversation.otherUser.displayName.split(' ').first,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
