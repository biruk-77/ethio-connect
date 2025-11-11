import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/verification_model.dart';
import '../models/api_response_model.dart';
import '../utils/app_logger.dart';
import 'api_client.dart';

class VerificationService extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  
  List<Verification> _verifications = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Verification> get verifications => _verifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Get current user's verification requests
  Future<List<Verification>> getMyVerifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.get('/api/verifications');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data,
          (data) => (data as List)
              .map((item) => Verification.fromJson(item as Map<String, dynamic>))
              .toList(),
        );

        if (apiResponse.success && apiResponse.data != null) {
          _verifications = apiResponse.data!;
          _isLoading = false;
          notifyListeners();
          return _verifications;
        } else {
          _errorMessage = apiResponse.message;
        }
      }
    } on DioException catch (e) {
      _errorMessage = e.response?.data['message'] ?? 'Failed to load verifications';
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      debugPrint('Error getting verifications: $e');
    }

    _isLoading = false;
    notifyListeners();
    return [];
  }

  /// Submit verification with document
  Future<Verification?> submitVerification({
    required VerificationType type,
    required String documentPath,
    String? notes,
  }) async {
    AppLogger.document('Submitting ${type.apiValue} verification');
    AppLogger.upload('Document: $documentPath');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.uploadFile(
        '/api/verifications',
        documentPath,
        'document',
        additionalData: {
          'type': type.apiValue,
          if (notes != null) 'notes': notes,
        },
      );

      if (response.statusCode == 201) {
        final apiResponse = ApiResponse.fromJson(
          response.data,
          (data) {
            final verificationData = data['verification'] ?? data;
            return Verification.fromJson(verificationData as Map<String, dynamic>);
          },
        );

        if (apiResponse.success && apiResponse.data != null) {
          // Add to local list
          _verifications.insert(0, apiResponse.data!);
          AppLogger.celebrate('Verification submitted successfully! 🎉');
          _isLoading = false;
          notifyListeners();
          return apiResponse.data;
        } else {
          _errorMessage = apiResponse.message;
        }
      }
    } on DioException catch (e) {
      _errorMessage = e.response?.data['message'] ?? 'Failed to submit verification';
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      debugPrint('Error submitting verification: $e');
    }

    _isLoading = false;
    notifyListeners();
    return null;
  }

  /// Get pending verifications (admin only)
  Future<List<Verification>> getPendingVerifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.get('/api/verifications/pending');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data,
          (data) => (data as List)
              .map((item) => Verification.fromJson(item as Map<String, dynamic>))
              .toList(),
        );

        if (apiResponse.success && apiResponse.data != null) {
          _isLoading = false;
          notifyListeners();
          return apiResponse.data!;
        } else {
          _errorMessage = apiResponse.message;
        }
      }
    } on DioException catch (e) {
      _errorMessage = e.response?.data['message'] ?? 'Failed to load pending verifications';
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      debugPrint('Error getting pending verifications: $e');
    }

    _isLoading = false;
    notifyListeners();
    return [];
  }

  /// Get verifications for a specific user (admin only)
  Future<List<Verification>> getUserVerifications(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.get('/api/verifications/user/$userId');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data,
          (data) => (data as List)
              .map((item) => Verification.fromJson(item as Map<String, dynamic>))
              .toList(),
        );

        if (apiResponse.success && apiResponse.data != null) {
          _isLoading = false;
          notifyListeners();
          return apiResponse.data!;
        } else {
          _errorMessage = apiResponse.message;
        }
      }
    } on DioException catch (e) {
      _errorMessage = e.response?.data['message'] ?? 'Failed to load user verifications';
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      debugPrint('Error getting user verifications: $e');
    }

    _isLoading = false;
    notifyListeners();
    return [];
  }

  /// Update verification status (admin only)
  Future<bool> updateVerificationStatus({
    required String verificationId,
    required VerificationStatus status,
    String? notes,
  }) async {
    AppLogger.document('Updating verification status to: ${status.name}');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.put(
        '/api/verifications/$verificationId',
        data: {
          'status': status.name,
          if (notes != null) 'notes': notes,
        },
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data,
          (data) => Verification.fromJson(data as Map<String, dynamic>),
        );

        if (apiResponse.success && apiResponse.data != null) {
          // Update local list if exists
          final index = _verifications.indexWhere((v) => v.id == verificationId);
          if (index != -1) {
            _verifications[index] = apiResponse.data!;
          }
          
          AppLogger.success('Verification ${status.name}');
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _errorMessage = apiResponse.message;
        }
      }
    } on DioException catch (e) {
      _errorMessage = e.response?.data['message'] ?? 'Failed to update verification';
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      debugPrint('Error updating verification: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Check if current user is verified for a specific type
  /// This is used by Post Service to check if user can post in certain categories
  Future<VerificationCheckResult?> isVerified(VerificationType type) async {
    AppLogger.document('Checking if user is verified for ${type.apiValue}');
    
    try {
      final response = await _apiClient.get(
        '/api/verifications/is-verified',
        queryParameters: {'type': type.apiValue},
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data,
          (data) => VerificationCheckResult.fromJson(data as Map<String, dynamic>),
        );

        if (apiResponse.success && apiResponse.data != null) {
          final result = apiResponse.data!;
          if (result.isVerified) {
            AppLogger.celebrate('✅ User is verified as ${result.roleName}!');
          } else {
            AppLogger.warning('❌ User is NOT verified: ${result.reason}');
          }
          return result;
        } else {
          _errorMessage = apiResponse.message;
        }
      }
    } on DioException catch (e) {
      _errorMessage = e.response?.data['message'] ?? 'Failed to check verification';
      AppLogger.error('Verification check failed: $_errorMessage');
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      debugPrint('Error checking verification: $e');
    }

    return null;
  }

  void clearVerifications() {
    _verifications = [];
    _errorMessage = null;
    notifyListeners();
  }
}
