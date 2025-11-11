class AuthApiConfig {
  // Base URL - For auth, verifications, user data
  static const String baseUrl = 'https://ethiouser.zewdbingo.com';
  // static const String baseUrl = 'http://localhost:3001';
  
  // Uploads URL - For product images, posts, media
  static const String uploadsBaseUrl = 'https://ethiopost.unitybingo.com';

  // Authentication Endpoints
  static const String register = '$baseUrl/api/auth/register';
  static const String login = '$baseUrl/api/auth/login';
  static const String me = '$baseUrl/api/auth/me';
  static const String refreshToken = '$baseUrl/api/auth/refresh-token';

  // OTP Endpoints
  static const String otpRequest = '$baseUrl/api/auth/otp/request';
  static const String otpVerify = '$baseUrl/api/auth/otp/verify';
  static const String otpLogin = '$baseUrl/api/auth/otp/login';

  // Profile Endpoints
  static const String myProfile = '$baseUrl/api/profiles';

  // Roles Endpoints
  static const String allRoles = '$baseUrl/api/roles';
  static String userRoles(String userId) => '$baseUrl/api/roles/user/$userId';

  // Verification Endpoints
  static const String myVerifications = '$baseUrl/api/verifications';
  static const String submitVerification = '$baseUrl/api/verifications';

  // Headers
  static Map<String, String> headers(String? token) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Map<String, String> multipartHeaders(String? token) {
    return {
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
