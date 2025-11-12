import 'post_model.dart';

class OfferPost {
  final String id;
  final String postId;
  final String offerType;
  final double originalPrice;
  final double? discountedPrice;
  final double? discountPercentage;
  final DateTime validFrom;
  final DateTime validUntil;
  final String? termsAndConditions;
  final int maxRedemptions;
  final int redemptionCount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Post? post;

  OfferPost({
    required this.id,
    required this.postId,
    required this.offerType,
    required this.originalPrice,
    this.discountedPrice,
    this.discountPercentage,
    required this.validFrom,
    required this.validUntil,
    this.termsAndConditions,
    required this.maxRedemptions,
    this.redemptionCount = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.post,
  });

  factory OfferPost.fromJson(Map<String, dynamic> json) {
    return OfferPost(
      id: json['id'] ?? '',
      postId: json['postId'] ?? '',
      offerType: json['offerType'] ?? 'discount',
      originalPrice: (json['originalPrice'] ?? 0).toDouble(),
      discountedPrice: json['discountedPrice']?.toDouble(),
      discountPercentage: json['discountPercentage']?.toDouble(),
      validFrom: DateTime.parse(json['validFrom']),
      validUntil: DateTime.parse(json['validUntil']),
      termsAndConditions: json['termsAndConditions'],
      maxRedemptions: json['maxRedemptions'] ?? 0,
      redemptionCount: json['redemptionCount'] ?? 0,
      isActive: json['isActive'] ?? true,
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
      'offerType': offerType,
      'originalPrice': originalPrice,
      'discountedPrice': discountedPrice,
      'discountPercentage': discountPercentage,
      'validFrom': validFrom.toIso8601String(),
      'validUntil': validUntil.toIso8601String(),
      'termsAndConditions': termsAndConditions,
      'maxRedemptions': maxRedemptions,
      'redemptionCount': redemptionCount,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  double get savings {
    if (discountedPrice != null) {
      return originalPrice - discountedPrice!;
    }
    if (discountPercentage != null) {
      return originalPrice * (discountPercentage! / 100);
    }
    return 0;
  }

  bool get isValid {
    final now = DateTime.now();
    return isActive && 
           now.isAfter(validFrom) && 
           now.isBefore(validUntil) &&
           redemptionCount < maxRedemptions;
  }

  int get remainingRedemptions => maxRedemptions - redemptionCount;
}
