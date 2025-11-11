import 'user_model.dart';

class AuthResponse {
  final bool success;
  final String? message;
  final AuthData? data;

  AuthResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null ? AuthData.fromJson(json['data']) : null,
    );
  }
}

class AuthData {
  final String accessToken;
  final String refreshToken;
  final User user;

  AuthData({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'user': user.toJson(),
    };
  }
}
