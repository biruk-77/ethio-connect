import 'user_model.dart';
import 'post_model.dart';

/// PostLike Model - Represents likes on posts (different from matchmaking likes)
class PostLike {
  final String id;
  final String postId;
  final String userId;
  final String type; // 'like', 'love', 'dislike', etc.
  final DateTime createdAt;
  
  // Related objects
  final User? user;
  final Post? post;

  PostLike({
    required this.id,
    required this.postId,
    required this.userId,
    this.type = 'like',
    required this.createdAt,
    this.user,
    this.post,
  });

  factory PostLike.fromJson(Map<String, dynamic> json) {
    return PostLike(
      id: json['_id'] ?? json['id'] ?? '',
      postId: json['postId'] ?? '',
      userId: json['userId'] ?? '',
      type: json['type'] ?? 'like',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      post: json['post'] != null ? Post.fromJson(json['post']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  PostLike copyWith({
    String? id,
    String? postId,
    String? userId,
    String? type,
    DateTime? createdAt,
    User? user,
    Post? post,
  }) {
    return PostLike(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      user: user ?? this.user,
      post: post ?? this.post,
    );
  }

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

/// Like types
class LikeType {
  static const String like = 'like';
  static const String love = 'love';
  static const String dislike = 'dislike';

  static const Map<String, String> displayNames = {
    like: '👍 Like',
    love: '❤️ Love',
    dislike: '👎 Dislike',
  };

  static List<String> get allTypes => [like, love, dislike];
}

/// PostLike response model for pagination
class PostLikeResponse {
  final List<PostLike> likes;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final bool hasMore;

  PostLikeResponse({
    required this.likes,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    required this.hasMore,
  });

  factory PostLikeResponse.fromJson(Map<String, dynamic> json) {
    return PostLikeResponse(
      likes: (json['likes'] as List? ?? [])
          .map((l) => PostLike.fromJson(l))
          .toList(),
      totalCount: json['totalCount'] ?? 0,
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      hasMore: json['hasMore'] ?? false,
    );
  }
}
