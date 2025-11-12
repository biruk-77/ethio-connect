/// Notification Model
/// Represents a user notification (like, comment, match, message)
class AppNotification {
  final String id;
  final String userId;
  final String type; // 'like', 'comment', 'match', 'message', etc.
  final String title;
  final String body;
  final String message; // Added for compatibility with enhanced services
  final String? category; // Added for notification categorization
  final String? priority; // Added for notification priority
  final String? actionUrl; // Added for notification actions
  final String? imageUrl; // Added for notification images
  final Map<String, dynamic>? data;
  final Map<String, dynamic>? metadata; // Added for additional metadata
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.message,
    this.category,
    this.priority,
    this.actionUrl,
    this.imageUrl,
    this.data,
    this.metadata,
    this.isRead = false,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      type: json['type'] ?? 'general',
      title: json['title'] ?? '',
      body: json['body'] ?? json['message'] ?? '',
      message: json['message'] ?? json['body'] ?? '',
      category: json['category'],
      priority: json['priority'],
      actionUrl: json['actionUrl'],
      imageUrl: json['imageUrl'],
      data: json['data'] as Map<String, dynamic>?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'title': title,
      'body': body,
      'message': message,
      'category': category,
      'priority': priority,
      'actionUrl': actionUrl,
      'imageUrl': imageUrl,
      'data': data,
      'metadata': metadata,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  AppNotification copyWith({
    String? id,
    String? userId,
    String? type,
    String? title,
    String? body,
    String? message,
    String? category,
    String? priority,
    String? actionUrl,
    String? imageUrl,
    Map<String, dynamic>? data,
    Map<String, dynamic>? metadata,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      message: message ?? this.message,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      actionUrl: actionUrl ?? this.actionUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      data: data ?? this.data,
      metadata: metadata ?? this.metadata,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Notification types
class NotificationType {
  static const String like = 'post_like';
  static const String comment = 'post_comment';
  static const String reply = 'comment_reply';
  static const String match = 'mutual_match';
  static const String message = 'new_message';
  static const String favorite = 'favorite_added';
}
