import 'rental_listing_model.dart';
import 'user_model.dart';

class RentalInquiry {
  final String id;
  final String postId;
  final String tenantId;
  final String message;
  final DateTime moveInDate;
  final int leaseDuration;
  final String status;
  final String? landlordResponse;
  final DateTime createdAt;
  final DateTime updatedAt;
  final RentalListing? rentalListing;
  final User? tenant;

  RentalInquiry({
    required this.id,
    required this.postId,
    required this.tenantId,
    required this.message,
    required this.moveInDate,
    required this.leaseDuration,
    this.status = 'pending',
    this.landlordResponse,
    required this.createdAt,
    required this.updatedAt,
    this.rentalListing,
    this.tenant,
  });

  factory RentalInquiry.fromJson(Map<String, dynamic> json) {
    return RentalInquiry(
      id: json['id'] ?? '',
      postId: json['postId'] ?? '',
      tenantId: json['tenantId'] ?? '',
      message: json['message'] ?? '',
      moveInDate: DateTime.parse(json['moveInDate']),
      leaseDuration: json['leaseDuration'] ?? 12,
      status: json['status'] ?? 'pending',
      landlordResponse: json['landlordResponse'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      rentalListing: json['rentalListing'] != null
          ? RentalListing.fromJson(json['rentalListing'])
          : null,
      tenant: json['tenant'] != null ? User.fromJson(json['tenant']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'tenantId': tenantId,
      'message': message,
      'moveInDate': moveInDate.toIso8601String(),
      'leaseDuration': leaseDuration,
      'status': status,
      'landlordResponse': landlordResponse,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get statusDisplayText {
    switch (status) {
      case 'pending':
        return 'Pending Review';
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      case 'withdrawn':
        return 'Withdrawn';
      default:
        return status;
    }
  }

  String get leaseDurationText {
    if (leaseDuration == 1) return '1 month';
    if (leaseDuration < 12) return '$leaseDuration months';
    final years = leaseDuration ~/ 12;
    final months = leaseDuration % 12;
    if (months == 0) {
      return years == 1 ? '1 year' : '$years years';
    }
    return '$years year${years > 1 ? 's' : ''}, $months month${months > 1 ? 's' : ''}';
  }

  bool get canWithdraw => status == 'pending';
  bool get canUpdate => status == 'pending';
}
