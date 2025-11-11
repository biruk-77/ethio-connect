import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../models/auth_response_model.dart';
import '../models/api_response_model.dart';
import '../utils/app_logger.dart';
import 'api_client.dart';

enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated,
  needsProfileCompletion,
}

class AuthService extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  
  AuthStatus _status = AuthStatus.unknown;
  User? _currentUser;
  String? _errorMessage;
  bool _isLoading = false;

  AuthStatus get status => _status;
  User? get currentUser => _currentUser;
  String? get userId => _currentUser?.id;
  String? get userEmail => _currentUser?.email;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  final StreamController<AuthStatus> _authStatusController = StreamController<AuthStatus>.broadcast();
  Stream<AuthStatus> get authStatusStream => _authStatusController.stream;

  AuthService() {
    AppLogger.section('AUTH SERVICE INITIALIZED');
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    AppLogger.auth('Checking authentication status');
    _setLoading(true);
    
    try {
      final token = await _apiClient.getAccessToken();
      
      if (token != null && token.isNotEmpty) {
        AppLogger.token('Token found - verifying with server');
        // Verify token by getting current user
        final response = await _apiClient.get('/api/auth/me');
        
        if (response.statusCode == 200) {
          final apiResponse = ApiResponse.fromJson(
            response.data,
            (data) => User.fromJson(data as Map<String, dynamic>),
          );
          
          if (apiResponse.success && apiResponse.data != null) {
            _currentUser = apiResponse.data;
            AppLogger.user('User verified: ${_currentUser!.username}');
            _updateAuthStatus(AuthStatus.authenticated);
          } else {
            AppLogger.warning('Token verification failed');
            await _apiClient.clearTokens();
            _updateAuthStatus(AuthStatus.unauthenticated);
          }
        }
      } else {
        AppLogger.info('No token found - user not authenticated');
        _updateAuthStatus(AuthStatus.unauthenticated);
      }
    } catch (e) {
      AppLogger.error('Error checking auth status', error: e);
      await _apiClient.clearTokens();
      _updateAuthStatus(AuthStatus.unauthenticated);
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    AppLogger.section('LOGIN ATTEMPT');
    AppLogger.email('Email: $email');
    _setLoading(true);
    _errorMessage = null;
    
    try {
      final response = await _apiClient.post(
        '/api/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      
      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data,
          (data) => AuthResponse.fromJson(data as Map<String, dynamic>),
        );
        
        if (apiResponse.success && apiResponse.data != null) {
          final authResponse = apiResponse.data!;
          
          // Save tokens
          await _apiClient.saveAccessToken(authResponse.accessToken);
          if (authResponse.refreshToken != null) {
            await _apiClient.saveRefreshToken(authResponse.refreshToken!);
          } else {
            AppLogger.info('No refresh token returned');
          }
          
          // Update user state
          _currentUser = authResponse.user;
          AppLogger.user('Logged in: ${authResponse.user.username}');
          AppLogger.celebrate('LOGIN SUCCESSFUL! 🎉');
          _updateAuthStatus(AuthStatus.authenticated);
          _setLoading(false);
          return true;
        } else {
          _errorMessage = apiResponse.message;
          _setLoading(false);
          return false;
        }
      }
    } on DioException catch (e) {
      _errorMessage = e.response?.data['message'] ?? 'Login failed. Please try again.';
      AppLogger.error('Login failed', error: e, tag: 'AUTH');
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred.';
      AppLogger.error('Login error', error: e, tag: 'AUTH');
      _setLoading(false);
      return false;
    }
    
    _errorMessage = 'Login failed. Please try again.';
    _setLoading(false);
    return false;
  }

  Future<bool> signUpWithEmailAndPassword(
    String email,
    String password, {
    String? username,
    String? phone,
    List<String>? roles,
  }) async {
    AppLogger.section('REGISTRATION ATTEMPT');
    AppLogger.email('Email: $email');
    if (phone != null) AppLogger.phone('Phone: $phone');
    if (roles != null) AppLogger.list('Roles', roles);
    _setLoading(true);
    _errorMessage = null;
    
    try {
      final response = await _apiClient.post(
        '/api/auth/register',
        data: {
          'email': email,
          'password': password,
          'username': username ?? email.split('@')[0],
          if (phone != null) 'phone': phone,
          if (roles != null && roles.isNotEmpty) 'role': roles,
        },
      );
      
      if (response.statusCode == 201) {
        final apiResponse = ApiResponse.fromJson(
          response.data,
          (data) => AuthResponse.fromJson(data as Map<String, dynamic>),
        );
        
        if (apiResponse.success && apiResponse.data != null) {
          final authResponse = apiResponse.data!;
          
          // Save tokens (refreshToken may be null on registration)
          await _apiClient.saveAccessToken(authResponse.accessToken);
          if (authResponse.refreshToken != null) {
            await _apiClient.saveRefreshToken(authResponse.refreshToken!);
          } else {
            AppLogger.info('No refresh token returned - using access token only');
          }
          
          // Update user state
          _currentUser = authResponse.user;
          AppLogger.user('Registered: ${authResponse.user.username}');
          AppLogger.celebrate('REGISTRATION SUCCESSFUL! 🎉');
          _updateAuthStatus(AuthStatus.needsProfileCompletion);
          _setLoading(false);
          return true;
        } else {
          _errorMessage = apiResponse.message;
          _setLoading(false);
          return false;
        }
      }
    } on DioException catch (e) {
      _errorMessage = e.response?.data['message'] ?? 'Registration failed. Please try again.';
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred.';
      _setLoading(false);
      return false;
    }
    
    _errorMessage = 'Registration failed. Please try again.';
    _setLoading(false);
    return false;
  }

  Future<void> signOut() async {
    AppLogger.auth('Signing out user: ${_currentUser?.username ?? "Unknown"}');
    _setLoading(true);
    
    try {
      // Clear tokens from secure storage
      await _apiClient.clearTokens();
      
      // Clear user state
      _currentUser = null;
      _updateAuthStatus(AuthStatus.unauthenticated);
      AppLogger.success('User signed out successfully');
    } catch (e) {
      AppLogger.error('Error signing out', error: e);
    } finally {
      _setLoading(false);
    }
  }

  // OTP Authentication
  Future<bool> requestOtp(String phone) async {
    AppLogger.section('OTP REQUEST');
    AppLogger.phone('Requesting OTP for: $phone');
    _setLoading(true);
    _errorMessage = null;
    
    try {
      final response = await _apiClient.post(
        '/api/auth/otp/request',
        data: {'phone': phone},
      );
      
      if (response.statusCode == 200) {
        AppLogger.success('OTP sent successfully');
        _setLoading(false);
        return true;
      }
    } on DioException catch (e) {
      _errorMessage = e.response?.data['message'] ?? 'Failed to send OTP.';
    } catch (e) {
      _errorMessage = 'An unexpected error occurred.';
    }
    
    _setLoading(false);
    return false;
  }

  Future<bool> verifyOtp(String phone, String otp) async {
    AppLogger.section('OTP VERIFICATION');
    AppLogger.phone('Verifying OTP for: $phone');
    _setLoading(true);
    _errorMessage = null;
    
    try{
      final response = await _apiClient.post(
        '/api/auth/otp/verify',
        data: {
          'phone': phone,
          'otp': otp,
        },
      );
      
      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data,
          (data) => AuthResponse.fromJson(data as Map<String, dynamic>),
        );
        
        if (apiResponse.success && apiResponse.data != null) {
          final authResponse = apiResponse.data!;
          
          // Save tokens
          await _apiClient.saveAccessToken(authResponse.accessToken);
          if (authResponse.refreshToken != null) {
            await _apiClient.saveRefreshToken(authResponse.refreshToken!);
          } else {
            AppLogger.info('No refresh token returned');
          }
          
          _currentUser = authResponse.user;
          AppLogger.user('OTP verified: ${authResponse.user.username}');
          AppLogger.celebrate('OTP LOGIN SUCCESSFUL! 🎉');
          _updateAuthStatus(AuthStatus.authenticated);
          _setLoading(false);
          return true;
        }
      }
    } on DioException catch (e) {
      _errorMessage = e.response?.data['message'] ?? 'OTP verification failed.';
    } catch (e) {
      _errorMessage = 'An unexpected error occurred.';
    }
    
    _setLoading(false);
    return false;
  }

  // Get current user info
  Future<void> refreshCurrentUser() async {
    try {
      final response = await _apiClient.get('/api/auth/me');
      
      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data,
          (data) => User.fromJson(data as Map<String, dynamic>),
        );
        
        if (apiResponse.success && apiResponse.data != null) {
          _currentUser = apiResponse.data;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error refreshing user: $e');
    }
  }

  // Password Reset (Placeholder - endpoint not available in current API)
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _errorMessage = null;
    
    // TODO: Implement when password reset endpoint is available
    // Expected endpoint: POST /api/auth/reset-password or /api/auth/forgot-password
    
    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      _errorMessage = 'Password reset feature is not yet implemented on the server.';
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred.';
      _setLoading(false);
      return false;
    }
  }

  void _updateAuthStatus(AuthStatus status) {
    _status = status;
    _authStatusController.add(status);
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  void dispose() {
    _authStatusController.close();
    super.dispose();
  }
}
