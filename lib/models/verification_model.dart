class Verification {
  final String id;
  final String userId;
  final String type;
  final String status;
  final String? documentUrl;
  final String? notes;
  final String? adminNotes;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Verification({
    required this.id,
    required this.userId,
    required this.type,
    required this.status,
    this.documentUrl,
    this.notes,
    this.adminNotes,
    this.reviewedBy,
    this.reviewedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Verification.fromJson(Map<String, dynamic> json) {
    return Verification(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: json['type'] as String,
      status: json['status'] as String,
      documentUrl: json['documentUrl'] as String?,
      notes: json['notes'] as String?,
      adminNotes: json['adminNotes'] as String?,
      reviewedBy: json['reviewedBy'] as String?,
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.parse(json['reviewedAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'status': status,
      'documentUrl': documentUrl,
      'notes': notes,
      'adminNotes': adminNotes,
      'reviewedBy': reviewedBy,
      'reviewedAt': reviewedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

enum VerificationType {
  kyc,
  doctorLicense,
  teacherCert,
  businessLicense,
  employerCert,
  other;

  String get apiValue {
    switch (this) {
      case VerificationType.kyc:
        return 'kyc';
      case VerificationType.doctorLicense:
        return 'doctor_license';
      case VerificationType.teacherCert:
        return 'teacher_cert';
      case VerificationType.businessLicense:
        return 'business_license';
      case VerificationType.employerCert:
        return 'employer_cert';
      case VerificationType.other:
        return 'other';
    }
  }

  static VerificationType fromString(String value) {
    switch (value) {
      case 'kyc':
        return VerificationType.kyc;
      case 'doctor_license':
        return VerificationType.doctorLicense;
      case 'teacher_cert':
        return VerificationType.teacherCert;
      case 'business_license':
        return VerificationType.businessLicense;
      case 'employer_cert':
        return VerificationType.employerCert;
      default:
        return VerificationType.other;
    }
  }
}

enum VerificationStatus {
  pending,
  approved,
  rejected;

  static VerificationStatus fromString(String value) {
    switch (value) {
      case 'approved':
        return VerificationStatus.approved;
      case 'rejected':
        return VerificationStatus.rejected;
      default:
        return VerificationStatus.pending;
    }
  }
}

/// Result of verification check (for posting in categories)
/// Used to determine if user can post in restricted categories
class VerificationCheckResult {
  final String userId;
  final String type;
  final bool hasRole;
  final bool hasVerification;
  final bool isVerified;
  final String? roleName;
  final DateTime? verifiedAt;
  final String? reason;

  VerificationCheckResult({
    required this.userId,
    required this.type,
    required this.hasRole,
    required this.hasVerification,
    required this.isVerified,
    this.roleName,
    this.verifiedAt,
    this.reason,
  });

  factory VerificationCheckResult.fromJson(Map<String, dynamic> json) {
    return VerificationCheckResult(
      userId: json['userId'] ?? '',
      type: json['type'] ?? '',
      hasRole: json['hasRole'] ?? false,
      hasVerification: json['hasVerification'] ?? false,
      isVerified: json['isVerified'] ?? false,
      roleName: json['roleName'],
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.parse(json['verifiedAt'])
          : null,
      reason: json['reason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'type': type,
      'hasRole': hasRole,
      'hasVerification': hasVerification,
      'isVerified': isVerified,
      'roleName': roleName,
      'verifiedAt': verifiedAt?.toIso8601String(),
      'reason': reason,
    };
  }
}
