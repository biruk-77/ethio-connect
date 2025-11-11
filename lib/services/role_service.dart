import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/role_model.dart';
import '../models/api_response_model.dart';
import 'api_client.dart';

class RoleService extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  
  List<Role> _roles = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Role> get roles => _roles;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Get all available roles
  Future<List<Role>> getAllRoles() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.get('/api/roles');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data,
          (data) {
            // Handle both formats: List directly or nested in 'roles' key
            final rolesList = data is List ? data : (data['roles'] as List? ?? []);
            return rolesList
                .map((item) => Role.fromJson(item as Map<String, dynamic>))
                .toList();
          },
        );

        if (apiResponse.success && apiResponse.data != null) {
          _roles = apiResponse.data!;
          _isLoading = false;
          notifyListeners();
          return _roles;
        } else {
          _errorMessage = apiResponse.message;
        }
      }
    } on DioException catch (e) {
      _errorMessage = e.response?.data['message'] ?? 'Failed to load roles';
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      debugPrint('Error getting roles: $e');
    }

    _isLoading = false;
    notifyListeners();
    return [];
  }

  /// Get roles for a specific user
  Future<List<Role>> getUserRoles(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.get('/api/roles/user/$userId');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data,
          (data) => (data as List)
              .map((item) => Role.fromJson(item as Map<String, dynamic>))
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
      _errorMessage = e.response?.data['message'] ?? 'Failed to load user roles';
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      debugPrint('Error getting user roles: $e');
    }

    _isLoading = false;
    notifyListeners();
    return [];
  }

  /// Create new role (admin only)
  Future<Role?> createRole(String roleName) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.post(
        '/api/roles',
        data: {'name': roleName},
      );

      if (response.statusCode == 201) {
        final apiResponse = ApiResponse.fromJson(
          response.data,
          (data) => Role.fromJson(data as Map<String, dynamic>),
        );

        if (apiResponse.success && apiResponse.data != null) {
          _roles.add(apiResponse.data!);
          _isLoading = false;
          notifyListeners();
          return apiResponse.data;
        } else {
          _errorMessage = apiResponse.message;
        }
      }
    } on DioException catch (e) {
      _errorMessage = e.response?.data['message'] ?? 'Failed to create role';
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      debugPrint('Error creating role: $e');
    }

    _isLoading = false;
    notifyListeners();
    return null;
  }

  void clearRoles() {
    _roles = [];
    _errorMessage = null;
    notifyListeners();
  }
}
