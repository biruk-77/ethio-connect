/// Favorite Model
/// Represents a favorited post or profile
class Favorite {
  final String id;
  final String userId;
  final String targetType; // 'Post' or 'Profile'
  final String targetId;
  final DateTime createdAt;

  Favorite({
    required this.id,
    required this.userId,
    required this.targetType,
    required this.targetId,
    required this.createdAt,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      targetType: json['targetType'] ?? 'Post',
      targetId: json['targetId'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'targetType': targetType,
      'targetId': targetId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// Post with favorite status
class PostWithFavorite {
  final String postId;
  final bool isFavorited;
  final int favoriteCount;

  PostWithFavorite({
    required this.postId,
    required this.isFavorited,
    this.favoriteCount = 0,
  });
}
