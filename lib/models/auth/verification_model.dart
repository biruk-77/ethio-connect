class Verification {
  final String id;
  final String userId;
  final String type;
  final String status;
  final String? documentUrl;
  final String? notes;
  final String? verifiedBy;
  final DateTime? verifiedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Verification({
    required this.id,
    required this.userId,
    required this.type,
    required this.status,
    this.documentUrl,
    this.notes,
    this.verifiedBy,
    this.verifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory Verification.fromJson(Map<String, dynamic> json) {
    return Verification(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      type: json['type'] ?? '',
      status: json['status'] ?? 'pending',
      documentUrl: json['documentUrl'],
      notes: json['notes'],
      verifiedBy: json['verifiedBy'],
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.parse(json['verifiedAt'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
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
      'verifiedBy': verifiedBy,
      'verifiedAt': verifiedAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isRejected => status.toLowerCase() == 'rejected';
}

class VerificationTypes {
  static const String kyc = 'kyc';
  static const String doctorLicense = 'doctor_license';
  static const String teacherCert = 'teacher_cert';
  static const String businessLicense = 'business_license';
  static const String employerCert = 'employer_cert';
  static const String other = 'other';
}

/// Enum for verification types
enum VerificationType {
  kyc('kyc'),
  doctorLicense('doctor_license'),
  teacherCert('teacher_cert'),
  businessLicense('business_license'),
  employerCert('employer_cert'),
  other('other');

  final String apiValue;
  const VerificationType(this.apiValue);

  static VerificationType fromString(String value) {
    return VerificationType.values.firstWhere(
      (e) => e.apiValue == value,
      orElse: () => VerificationType.other,
    );
  }
}

/// Enum for verification status
enum VerificationStatus {
  pending,
  approved,
  rejected;

  static VerificationStatus fromString(String value) {
    return VerificationStatus.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => VerificationStatus.pending,
    );
  }
}

/// Result of verification check (for posting in categories)
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
