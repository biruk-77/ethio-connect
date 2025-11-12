import 'user_model.dart';

/// Report Model - Represents reports for content moderation
class Report {
  final String id;
  final String reporterId;
  final String targetType; // 'Post', 'Comment', 'User', 'Profile'
  final String targetId;
  final String reason;
  final String? description;
  final String status; // 'pending', 'reviewed', 'resolved', 'dismissed'
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final String? resolution;
  
  // Related objects
  final User? reporter;
  final Map<String, dynamic>? targetData; // Post/Comment/User data

  Report({
    required this.id,
    required this.reporterId,
    required this.targetType,
    required this.targetId,
    required this.reason,
    this.description,
    this.status = 'pending',
    required this.createdAt,
    this.reviewedAt,
    this.reviewedBy,
    this.resolution,
    this.reporter,
    this.targetData,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['_id'] ?? json['id'] ?? '',
      reporterId: json['reporterId'] ?? '',
      targetType: json['targetType'] ?? '',
      targetId: json['targetId'] ?? '',
      reason: json['reason'] ?? '',
      description: json['description'],
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.parse(json['reviewedAt'])
          : null,
      reviewedBy: json['reviewedBy'],
      resolution: json['resolution'],
      reporter: json['reporter'] != null ? User.fromJson(json['reporter']) : null,
      targetData: json['targetData'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reporterId': reporterId,
      'targetType': targetType,
      'targetId': targetId,
      'reason': reason,
      'description': description,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'reviewedAt': reviewedAt?.toIso8601String(),
      'reviewedBy': reviewedBy,
      'resolution': resolution,
    };
  }

  Report copyWith({
    String? id,
    String? reporterId,
    String? targetType,
    String? targetId,
    String? reason,
    String? description,
    String? status,
    DateTime? createdAt,
    DateTime? reviewedAt,
    String? reviewedBy,
    String? resolution,
    User? reporter,
    Map<String, dynamic>? targetData,
  }) {
    return Report(
      id: id ?? this.id,
      reporterId: reporterId ?? this.reporterId,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      reason: reason ?? this.reason,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      resolution: resolution ?? this.resolution,
      reporter: reporter ?? this.reporter,
      targetData: targetData ?? this.targetData,
    );
  }

  bool get isPending => status == 'pending';
  bool get isReviewed => status == 'reviewed';
  bool get isResolved => status == 'resolved';
  bool get isDismissed => status == 'dismissed';
  
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

/// Report reasons
class ReportReason {
  static const String spam = 'spam';
  static const String harassment = 'harassment';
  static const String inappropriateContent = 'inappropriate_content';
  static const String falseInformation = 'false_information';
  static const String violentContent = 'violent_content';
  static const String hateSpeech = 'hate_speech';
  static const String copyright = 'copyright';
  static const String other = 'other';

  static const Map<String, String> displayNames = {
    spam: 'Spam',
    harassment: 'Harassment or Bullying',
    inappropriateContent: 'Inappropriate Content',
    falseInformation: 'False Information',
    violentContent: 'Violent Content',
    hateSpeech: 'Hate Speech',
    copyright: 'Copyright Violation',
    other: 'Other',
  };

  static List<String> get allReasons => [
    spam,
    harassment,
    inappropriateContent,
    falseInformation,
    violentContent,
    hateSpeech,
    copyright,
    other,
  ];
}

/// Report response model for pagination
class ReportResponse {
  final List<Report> reports;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final bool hasMore;

  ReportResponse({
    required this.reports,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    required this.hasMore,
  });

  factory ReportResponse.fromJson(Map<String, dynamic> json) {
    return ReportResponse(
      reports: (json['reports'] as List? ?? [])
          .map((r) => Report.fromJson(r))
          .toList(),
      totalCount: json['totalCount'] ?? 0,
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      hasMore: json['hasMore'] ?? false,
    );
  }
}
