import '../models/verification_model.dart';

/// Maps post categories to required verification types
/// This ensures only verified professionals can post in restricted categories
class CategoryVerificationMap {
  // Category name to verification type mapping
  static final Map<String, VerificationType> _categoryMap = {
    'medical': VerificationType.doctorLicense,
    'health': VerificationType.doctorLicense,
    'healthcare': VerificationType.doctorLicense,
    'education': VerificationType.teacherCert,
    'tutoring': VerificationType.teacherCert,
    'jobs': VerificationType.businessLicense,
    'employment': VerificationType.businessLicense,
    'business': VerificationType.businessLicense,
    'general': VerificationType.kyc,
    'marketplace': VerificationType.kyc,
    'services': VerificationType.kyc,
  };

  /// Get required verification type for a category
  /// Returns null if the category doesn't require special verification
  static VerificationType? getVerificationTypeForCategory(String category) {
    return _categoryMap[category.toLowerCase()];
  }

  /// Check if a category requires verification
  static bool requiresVerification(String category) {
    return _categoryMap.containsKey(category.toLowerCase());
  }

  /// Get user-friendly message for verification requirement
  static String getVerificationMessage(String category) {
    final type = getVerificationTypeForCategory(category);
    if (type == null) {
      return 'This category is open to all verified users.';
    }

    switch (type) {
      case VerificationType.doctorLicense:
        return 'You need to be a verified medical professional to post in this category. Please submit your medical license for verification.';
      case VerificationType.teacherCert:
        return 'You need to be a verified educator to post in this category. Please submit your teaching certificate for verification.';
      case VerificationType.businessLicense:
        return 'You need to be a verified business to post in this category. Please submit your business license for verification.';
      case VerificationType.kyc:
        return 'You need to complete KYC verification to post in this category. Please submit your identification documents.';
      default:
        return 'Verification required to post in this category.';
    }
  }

  /// Get all categories that require a specific verification type
  static List<String> getCategoriesForVerificationType(VerificationType type) {
    return _categoryMap.entries
        .where((entry) => entry.value == type)
        .map((entry) => entry.key)
        .toList();
  }

  /// Get verification badge text for display
  static String getVerificationBadge(VerificationType type) {
    switch (type) {
      case VerificationType.doctorLicense:
        return '🏥 Verified Doctor';
      case VerificationType.teacherCert:
        return '🎓 Verified Educator';
      case VerificationType.businessLicense:
        return '💼 Verified Business';
      case VerificationType.kyc:
        return '✅ Verified User';
      case VerificationType.employerCert:
        return '🏢 Verified Employer';
      default:
        return '✅ Verified';
    }
  }
}
