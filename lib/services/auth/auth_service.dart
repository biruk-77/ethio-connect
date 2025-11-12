import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../config/auth_api_config.dart';
import '../../models/auth/user_model.dart';
import '../../models/auth/auth_response.dart';
import '../../models/auth/verification_model.dart';
import '../../models/auth/role_model.dart';
import '../../utils/app_logger.dart';

class AuthService {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  // Secure storage keys
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUser = 'user_data';

  AuthService()
      : _dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        )),
        _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
          ),
        ) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add token to all requests (except refresh token endpoint)
        if (!options.path.contains('/refresh-token')) {
          final token = await getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }
        AppLogger.info('🌐 ${options.method} ${options.uri}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        AppLogger.success('✅ ${response.statusCode} ${response.requestOptions.uri}');
        return handler.next(response);
      },
      onError: (error, handler) async {
        AppLogger.error('❌ Error: ${error.message}');
        
        // Auto refresh token on 401 (but not for refresh-token endpoint itself)
        if (error.response?.statusCode == 401 && 
            !error.requestOptions.path.contains('/refresh-token')) {
          AppLogger.info('🔄 Access token expired, attempting refresh...');
          
          final refreshed = await refreshAccessToken();
          if (refreshed) {
            AppLogger.success('✨ Token refreshed, retrying request...');
            // Retry request with new token
            final opts = error.requestOptions;
            final token = await getAccessToken();
            opts.headers['Authorization'] = 'Bearer $token';
            
            try {
              final response = await _dio.fetch(opts);
              return handler.resolve(response);
            } catch (e) {
              AppLogger.error('❌ Retry failed: $e');
              return handler.reject(error);
            }
          } else {
            AppLogger.error('🚫 Refresh failed, clearing auth...');
            await clearAuth();
          }
        }
        
        return handler.next(error);
      },
    ));
  }

  // ==================== Token Management ====================

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
    AppLogger.success('🔐 Tokens saved securely');
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  Future<void> saveUser(User user) async {
    await _storage.write(key: _keyUser, value: jsonEncode(user.toJson()));
    AppLogger.success('👤 User data saved securely');
  }

  Future<User?> getStoredUser() async {
    try {
      final userData = await _storage.read(key: _keyUser);
      if (userData != null) {
        final user = User.fromJson(jsonDecode(userData));
        // Validate user has required fields
        if (user.id.isEmpty || user.email.isEmpty) {
          AppLogger.info('⚠️ Stored user data is invalid or incomplete, clearing...');
          await clearAuth();
          return null;
        }
        return user;
      }
      return null;
    } catch (e) {
      AppLogger.error('Failed to parse stored user data (probably old format): $e');
      AppLogger.info('⚠️ Clearing invalid user data, please login again...');
      await clearAuth();
      return null;
    }
  }

  Future<void> clearAuth() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
    await _storage.delete(key: _keyUser);
    AppLogger.info('🗑️ Auth data cleared');
  }

  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // ==================== Authentication ====================

  Future<AuthResponse?> register({
    required String username,
    required String email,
    required String password,
    String? phone,
    String role = 'user',
  }) async {
    try {
      AppLogger.info('📝 Registering user: $email');
      
      final response = await _dio.post(
        AuthApiConfig.register,
        data: {
          'username': username,
          'email': email,
          'password': password,
          if (phone != null) 'phone': phone,
          'role': role,
        },
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        final authResponse = AuthResponse.fromJson(response.data);
        if (authResponse.data != null) {
          await saveTokens(
            authResponse.data!.accessToken,
            authResponse.data!.refreshToken,
          );
          await saveUser(authResponse.data!.user);
        }
        AppLogger.success('✅ Registration successful');
        return authResponse;
      }

      return null;
    } on DioException catch (e) {
      AppLogger.error('Registration failed: ${e.response?.data ?? e.message}');
      // Return error response with message from backend
      if (e.response?.data != null && e.response!.data is Map) {
        final errorData = e.response!.data as Map<String, dynamic>;
        return AuthResponse(
          success: false,
          message: errorData['message'] ?? 'Registration failed',
        );
      }
      return AuthResponse(
        success: false,
        message: e.message ?? 'Registration failed',
      );
    }
  }

  Future<AuthResponse?> login({
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.info('🔑 Logging in: $email');
      
      final response = await _dio.post(
        AuthApiConfig.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final authResponse = AuthResponse.fromJson(response.data);
        if (authResponse.data != null) {
          await saveTokens(
            authResponse.data!.accessToken,
            authResponse.data!.refreshToken,
          );
          await saveUser(authResponse.data!.user);
        }
        AppLogger.success('✅ Login successful');
        return authResponse;
      }

      return null;
    } on DioException catch (e) {
      AppLogger.error('Login failed: ${e.response?.data ?? e.message}');
      // Return error response with message from backend
      if (e.response?.data != null && e.response!.data is Map) {
        final errorData = e.response!.data as Map<String, dynamic>;
        return AuthResponse(
          success: false,
          message: errorData['message'] ?? 'Login failed',
        );
      }
      return AuthResponse(
        success: false,
        message: e.message ?? 'Login failed',
      );
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      AppLogger.info('👤 Fetching current user');
      
      final response = await _dio.get(AuthApiConfig.me);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final user = User.fromJson(response.data['data'] ?? {});
        await saveUser(user);
        AppLogger.success('✅ User data fetched');
        
        // Socket connects only when needed by specific services
        
        return user;
      }

      return null;
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch user: ${e.message}');
      return null;
    }
  }

  Future<bool> refreshAccessToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        AppLogger.error('❌ No refresh token available');
        return false;
      }

      AppLogger.info('🔄 Refreshing access token with refresh token');
      AppLogger.debug('🔑 Refresh token: ${refreshToken.substring(0, 20)}...');
      
      // Create a new Dio instance without interceptors to avoid circular refresh
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ));
      
      final response = await dio.post(
        AuthApiConfig.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final newAccessToken = data['accessToken'];
        
        // Save new access token
        await _storage.write(key: _keyAccessToken, value: newAccessToken);
        
        // If backend also returns a new refresh token, save it
        if (data.containsKey('refreshToken') && data['refreshToken'] != null) {
          final newRefreshToken = data['refreshToken'];
          await _storage.write(key: _keyRefreshToken, value: newRefreshToken);
          AppLogger.success('✅ Both tokens refreshed');
        } else {
          AppLogger.success('✅ Access token refreshed');
        }
        
        return true;
      }

      AppLogger.error('❌ Refresh response unsuccessful');
      return false;
    } on DioException catch (e) {
      AppLogger.error('🚫 Token refresh failed: ${e.response?.data ?? e.message}');
      
      // If refresh token is invalid or expired, clear auth
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        AppLogger.info('🔑 Refresh token expired or invalid, clearing auth');
        await clearAuth();
      }
      
      return false;
    } catch (e) {
      AppLogger.error('❌ Unexpected error during token refresh: $e');
      return false;
    }
  }

  Future<bool> logout() async {
    try {
      AppLogger.info('👋 Logging out user');
      await clearAuth();
      AppLogger.success('✅ Logout successful');
      return true;
    } catch (e) {
      AppLogger.error('Logout failed: $e');
      return false;
    }
  }


  // ==================== OTP Authentication ====================

  Future<Map<String, dynamic>?> requestOTP(String phone) async {
    try {
      AppLogger.info('📱 Requesting OTP for: $phone');
      
      final response = await _dio.post(
        AuthApiConfig.otpRequest,
        data: {'phone': phone},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.success('✅ OTP sent');
        return response.data;
      }

      return null;
    } on DioException catch (e) {
      AppLogger.error('OTP request failed: ${e.response?.data ?? e.message}');
      return null;
    }
  }

  Future<AuthResponse?> verifyOTP({
    required String phone,
    required String otp,
  }) async {
    try {
      AppLogger.info('🔐 Verifying OTP for: $phone');
      
      final response = await _dio.post(
        AuthApiConfig.otpVerify,
        data: {
          'phone': phone,
          'otp': otp,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final authResponse = AuthResponse.fromJson(response.data);
        if (authResponse.data != null) {
          await saveTokens(
            authResponse.data!.accessToken,
            authResponse.data!.refreshToken,
          );
          await saveUser(authResponse.data!.user);
        }
        AppLogger.success('✅ OTP verified');
        return authResponse;
      }

      return null;
    } on DioException catch (e) {
      AppLogger.error('OTP verification failed: ${e.response?.data ?? e.message}');
      // Return error response with message from backend
      if (e.response?.data != null && e.response!.data is Map) {
        final errorData = e.response!.data as Map<String, dynamic>;
        return AuthResponse(
          success: false,
          message: errorData['message'] ?? 'OTP verification failed',
        );
      }
      return AuthResponse(
        success: false,
        message: e.message ?? 'OTP verification failed',
      );
    }
  }

  // ==================== Roles ====================

  Future<List<UserRole>> getMyRoles() async {
    try {
      final user = await getStoredUser();
      if (user == null) return [];

      AppLogger.info('📋 Fetching user roles');
      
      final response = await _dio.get(AuthApiConfig.userRoles(user.id));

      if (response.statusCode == 200 && response.data['success'] == true) {
        // Backend returns: { success: true, data: { roles: [...] } }
        final data = response.data['data'];
        final List<dynamic> rolesData = data['roles'] ?? [];
        final roles = rolesData.map((role) => UserRole.fromJson(role)).toList();
        AppLogger.success('✅ Found ${roles.length} roles');
        return roles;
      }

      return [];
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch roles: ${e.message}');
      return [];
    }
  }

  Future<List<Role>> getAllRoles() async {
    try {
      AppLogger.info('📋 Fetching all roles');
      
      final response = await _dio.get(AuthApiConfig.allRoles);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> rolesData = response.data['data']['roles'] ?? [];
        final roles = rolesData.map((role) => Role.fromJson(role)).toList();
        AppLogger.success('✅ Found ${roles.length} roles');
        return roles;
      }

      return [];
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch all roles: ${e.message}');
      return [];
    }
  }

  // ==================== Verifications ====================

  Future<List<Verification>> getMyVerifications() async {
    try {
      AppLogger.info('📄 Fetching my verifications');
      
      final response = await _dio.get(AuthApiConfig.myVerifications);

      if (response.statusCode == 200 && response.data['success'] == true) {
        // Backend returns: { success: true, data: { verifications: [...] } }
        final data = response.data['data'];
        final List<dynamic> verifications = data['verifications'] ?? [];
        final result = verifications
            .map((v) => Verification.fromJson(v))
            .toList();
        AppLogger.success('✅ Found ${result.length} verifications');
        return result;
      }

      return [];
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch verifications: ${e.message}');
      return [];
    }
  }

  Future<Verification?> submitVerification({
    required String type,
    required String filePath,
    String? notes,
  }) async {
    try {
      AppLogger.info('📤 Submitting verification: $type');
      
      final formData = FormData.fromMap({
        'type': type,
        if (notes != null) 'notes': notes,
        'document': await MultipartFile.fromFile(filePath),
      });

      final response = await _dio.post(
        AuthApiConfig.submitVerification,
        data: formData,
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        final verification = Verification.fromJson(
          response.data['data']['verification'] ?? {},
        );
        AppLogger.success('✅ Verification submitted');
        return verification;
      }

      return null;
    } on DioException catch (e) {
      AppLogger.error('Verification submission failed: ${e.response?.data ?? e.message}');
      return null;
    }
  }

  // ==================== Verification Check ====================

  Future<bool> needsVerification() async {
    try {
      final user = await getCurrentUser();
      if (user == null) return false;

      // Check if user has any pending or no verifications
      final verifications = await getMyVerifications();
      
      // If user is not verified and has no pending verifications, needs verification
      if (!user.isVerified) {
        final hasPending = verifications.any((v) => v.isPending);
        return !hasPending; // Need verification if no pending ones
      }

      return false;
    } catch (e) {
      AppLogger.error('Error checking verification status: $e');
      return false;
    }
  }
}
