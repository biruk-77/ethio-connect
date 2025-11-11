import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/message_model.dart';
import '../../../theme/app_colors.dart';

/// Individual message bubble with swipe actions
class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final VoidCallback? onReply;
  final VoidCallback? onDelete;
  final VoidCallback? onCopy;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.onReply,
    this.onDelete,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showMessageOptions(context),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              // Message content
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isMe ? AppColors.primary : Colors.grey[200],
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isMe ? 20 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  message.content,
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black87,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // Time and read status
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(message.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        message.isRead ? Icons.done_all : Icons.done,
                        size: 16,
                        color: message.isRead ? Colors.blue : Colors.grey[600],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMessageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onReply != null)
              ListTile(
                leading: const Icon(Icons.reply),
                title: const Text('Reply'),
                onTap: () {
                  Navigator.pop(context);
                  onReply?.call();
                },
              ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy'),
              onTap: () {
                Navigator.pop(context);
                Clipboard.setData(ClipboardData(text: message.content));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message copied')),
                );
              },
            ),
            if (isMe && onDelete != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  onDelete?.call();
                },
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
