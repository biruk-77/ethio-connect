import 'package:timeago/timeago.dart' as timeago;

/// Utility functions for message formatting and parsing
class MessageUtils {
  /// Format timestamp for messages
  static String formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      // Today: Show time only
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      // Yesterday
      return 'Yesterday ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      // This week: Show day name
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return '${days[dateTime.weekday - 1]} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      // Older: Show date
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  /// Format conversation list time (uses timeago)
  static String formatConversationTime(DateTime dateTime) {
    return timeago.format(dateTime, locale: 'en_short');
  }

  /// Extract mentions from message content
  static List<String> extractMentions(String content) {
    final regex = RegExp(r'@(\w+)');
    final matches = regex.allMatches(content);
    return matches.map((m) => m.group(1)!).toList();
  }

  /// Extract URLs from message content
  static List<String> extractUrls(String content) {
    final regex = RegExp(
      r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
    );
    final matches = regex.allMatches(content);
    return matches.map((m) => m.group(0)!).toList();
  }

  /// Check if message contains only emojis
  static bool isOnlyEmojis(String content) {
    final emojiRegex = RegExp(
      r'^(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff]|\s)+$',
    );
    return emojiRegex.hasMatch(content.trim());
  }

  /// Truncate message for preview (conversation list)
  static String truncateForPreview(String content, {int maxLength = 50}) {
    if (content.length <= maxLength) return content;
    return '${content.substring(0, maxLength)}...';
  }

  /// Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Get message status text
  static String getMessageStatusText(bool isSent, bool isDelivered, bool isRead) {
    if (isRead) return 'Read';
    if (isDelivered) return 'Delivered';
    if (isSent) return 'Sent';
    return 'Sending...';
  }

  /// Check if message was sent today
  static bool isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  /// Check if message was sent yesterday
  static bool isYesterday(DateTime dateTime) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return dateTime.year == yesterday.year &&
        dateTime.month == yesterday.month &&
        dateTime.day == yesterday.day;
  }

  /// Group messages by date
  static Map<String, List<dynamic>> groupMessagesByDate(List<dynamic> messages) {
    final grouped = <String, List<dynamic>>{};
    
    for (var message in messages) {
      final dateTime = message.createdAt as DateTime;
      final dateKey = isToday(dateTime)
          ? 'Today'
          : isYesterday(dateTime)
              ? 'Yesterday'
              : '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      
      grouped.putIfAbsent(dateKey, () => []).add(message);
    }
    
    return grouped;
  }
}
