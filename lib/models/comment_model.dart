import 'user_model.dart';

/// Comment Model - Represents comments on posts/profiles
class Comment {
  final String id;
  final String targetType; // 'Post' or 'Profile'
  final String targetId;
  final String authorId;
  final String content;
  final String? parentId; // For replies
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Related objects
  final User? author;
  final List<Comment>? replies;
  final int repliesCount;
  final bool isEdited;

  Comment({
    required this.id,
    required this.targetType,
    required this.targetId,
    required this.authorId,
    required this.content,
    this.parentId,
    required this.createdAt,
    required this.updatedAt,
    this.author,
    this.replies,
    this.repliesCount = 0,
    this.isEdited = false,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['_id'] ?? json['id'] ?? '',
      targetType: json['targetType'] ?? 'Post',
      targetId: json['targetId'] ?? '',
      authorId: json['authorId'] ?? json['userId'] ?? '',
      content: json['content'] ?? '',
      parentId: json['parentId'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      author: json['author'] != null ? User.fromJson(json['author']) : null,
      replies: json['replies'] != null
          ? (json['replies'] as List).map((r) => Comment.fromJson(r)).toList()
          : null,
      repliesCount: json['repliesCount'] ?? 0,
      isEdited: json['isEdited'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'targetType': targetType,
      'targetId': targetId,
      'authorId': authorId,
      'content': content,
      'parentId': parentId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'repliesCount': repliesCount,
      'isEdited': isEdited,
    };
  }

  Comment copyWith({
    String? id,
    String? targetType,
    String? targetId,
    String? authorId,
    String? content,
    String? parentId,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? author,
    List<Comment>? replies,
    int? repliesCount,
    bool? isEdited,
  }) {
    return Comment(
      id: id ?? this.id,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      authorId: authorId ?? this.authorId,
      content: content ?? this.content,
      parentId: parentId ?? this.parentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      author: author ?? this.author,
      replies: replies ?? this.replies,
      repliesCount: repliesCount ?? this.repliesCount,
      isEdited: isEdited ?? this.isEdited,
    );
  }

  bool get isReply => parentId != null;
  
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 7) {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

/// Comment response model for pagination
class CommentResponse {
  final List<Comment> comments;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final bool hasMore;

  CommentResponse({
    required this.comments,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    required this.hasMore,
  });

  factory CommentResponse.fromJson(Map<String, dynamic> json) {
    return CommentResponse(
      comments: (json['comments'] as List? ?? [])
          .map((c) => Comment.fromJson(c))
          .toList(),
      totalCount: json['totalCount'] ?? 0,
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      hasMore: json['hasMore'] ?? false,
    );
  }
}
