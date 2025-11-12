import 'dart:convert';
import 'post_model.dart';
import 'user_model.dart';

class MatchmakingPost {
  final String id;
  final String postId;
  final String visibility;
  final String? religion;
  final String? ethnicity;
  final String? maritalPrefs;
  final String? ageRange;
  final Map<String, bool> privacyFlags;
  final List<String> photos;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Post? post;

  MatchmakingPost({
    required this.id,
    required this.postId,
    this.visibility = 'public',
    this.religion,
    this.ethnicity,
    this.maritalPrefs,
    this.ageRange,
    this.privacyFlags = const {},
    this.photos = const [],
    required this.createdAt,
    required this.updatedAt,
    this.post,
  });

  factory MatchmakingPost.fromJson(Map<String, dynamic> json) {
    // Parse photos from JSON
    List<String> photosList = [];
    if (json['photos'] != null) {
      try {
        if (json['photos'] is String) {
          final decoded = jsonDecode(json['photos']);
          photosList = List<String>.from(decoded);
        } else if (json['photos'] is List) {
          photosList = List<String>.from(json['photos']);
        }
      } catch (e) {
        photosList = [];
      }
    }

    // Parse privacy flags
    Map<String, bool> flags = {};
    if (json['privacyFlags'] != null) {
      try {
        if (json['privacyFlags'] is String) {
          final decoded = jsonDecode(json['privacyFlags']);
          flags = Map<String, bool>.from(decoded);
        } else if (json['privacyFlags'] is Map) {
          flags = Map<String, bool>.from(json['privacyFlags']);
        }
      } catch (e) {
        flags = {};
      }
    }

    return MatchmakingPost(
      id: json['id'] ?? '',
      postId: json['postId'] ?? '',
      visibility: json['visibility'] ?? 'public',
      religion: json['religion'],
      ethnicity: json['ethnicity'],
      maritalPrefs: json['maritalPrefs'],
      ageRange: json['ageRange'],
      privacyFlags: flags,
      photos: photosList,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      post: json['post'] != null ? Post.fromJson(json['post']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'visibility': visibility,
      'religion': religion,
      'ethnicity': ethnicity,
      'maritalPrefs': maritalPrefs,
      'ageRange': ageRange,
      'privacyFlags': jsonEncode(privacyFlags),
      'photos': jsonEncode(photos),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Get full image URLs
  List<String> get fullImageUrls {
    return photos.map((pic) => 'https://ethiopost.unitybingo.com$pic').toList();
  }

  // Get first full image URL
  String? get firstImageUrl {
    if (photos.isEmpty) return null;
    return 'https://ethiopost.unitybingo.com${photos.first}';
  }

  bool get hideAge => privacyFlags['hideAge'] ?? false;
  bool get hideLocation => privacyFlags['hideLocation'] ?? false;
  bool get hidePhotos => privacyFlags['hidePhotos'] ?? false;
}

class Match {
  final String id;
  final String userAId;
  final String userBId;
  final String status;
  final DateTime? matchedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? userA;
  final User? userB;

  Match({
    required this.id,
    required this.userAId,
    required this.userBId,
    this.status = 'pending',
    this.matchedAt,
    required this.createdAt,
    required this.updatedAt,
    this.userA,
    this.userB,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'] ?? '',
      userAId: json['userAId'] ?? '',
      userBId: json['userBId'] ?? '',
      status: json['status'] ?? 'pending',
      matchedAt: json['matchedAt'] != null
          ? DateTime.parse(json['matchedAt'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      userA: json['userA'] != null ? User.fromJson(json['userA']) : null,
      userB: json['userB'] != null ? User.fromJson(json['userB']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userAId': userAId,
      'userBId': userBId,
      'status': status,
      'matchedAt': matchedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get statusDisplayText {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'matched':
        return 'Matched';
      case 'blocked':
        return 'Blocked';
      case 'declined':
        return 'Declined';
      default:
        return status;
    }
  }

  User? getOtherUser(String currentUserId) {
    if (userAId == currentUserId) return userB;
    if (userBId == currentUserId) return userA;
    return null;
  }
}
