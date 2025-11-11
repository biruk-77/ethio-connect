import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/profile_model.dart';
import '../models/api_response_model.dart';
import '../utils/app_logger.dart';
import 'api_client.dart';

class ProfileService extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  
  Profile? _currentProfile;
  bool _isLoading = false;
  String? _errorMessage;

  Profile? get currentProfile => _currentProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Get current user's profile
  Future<Profile?> getMyProfile() async {
    AppLogger.profile('Fetching user profile');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.get('/api/profiles');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data,
          (data) => Profile.fromJson(data as Map<String, dynamic>),
        );

        if (apiResponse.success && apiResponse.data != null) {
          _currentProfile = apiResponse.data;
          AppLogger.success('Profile loaded: ${_currentProfile!.fullName ?? "No name"}');
          _isLoading = false;
          notifyListeners();
          return _currentProfile;
        } else {
          _errorMessage = apiResponse.message;
        }
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // Profile doesn't exist yet
        AppLogger.info('Profile not found - needs creation');
        _currentProfile = null;
      } else {
        _errorMessage = e.response?.data['message'] ?? 'Failed to load profile';
      }
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      debugPrint('Error getting profile: $e');
    }

    _isLoading = false;
    notifyListeners();
    return null;
  }

  /// Update current user's profile
  Future<bool> updateProfile({
    String? fullName,
    String? bio,
    String? profession,
    String? gender,
    int? age,
    List<String>? languages,
    String? religion,
    String? ethnicity,
    String? education,
    List<String>? interests,
  }) async {
    AppLogger.edit('Updating user profile');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = <String, dynamic>{};
      if (fullName != null) data['fullName'] = fullName;
      if (bio != null) data['bio'] = bio;
      if (profession != null) data['profession'] = profession;
      if (gender != null) data['gender'] = gender;
      if (age != null) data['age'] = age;
      if (languages != null) data['languages'] = languages;
      if (religion != null) data['religion'] = religion;
      if (ethnicity != null) data['ethnicity'] = ethnicity;
      if (education != null) data['education'] = education;
      if (interests != null) data['interests'] = interests;

      final response = await _apiClient.put('/api/profiles', data: data);

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data,
          (data) => Profile.fromJson(data as Map<String, dynamic>),
        );

        if (apiResponse.success && apiResponse.data != null) {
          _currentProfile = apiResponse.data;
          AppLogger.celebrate('Profile updated successfully! 🎉');
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _errorMessage = apiResponse.message;
        }
      }
    } on DioException catch (e) {
      _errorMessage = e.response?.data['message'] ?? 'Failed to update profile';
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      debugPrint('Error updating profile: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Upload profile avatar
  Future<bool> uploadAvatar(String filePath) async {
    AppLogger.upload('Uploading profile avatar: $filePath');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try{
      final response = await _apiClient.uploadFile(
        '/api/profiles/avatar',
        filePath,
        'avatar',
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data,
          (data) => Profile.fromJson(data as Map<String, dynamic>),
        );

        if (apiResponse.success && apiResponse.data != null) {
          _currentProfile = apiResponse.data;
          AppLogger.celebrate('Avatar uploaded successfully! 🎉');
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }
    } on DioException catch (e) {
      _errorMessage = e.response?.data['message'] ?? 'Failed to upload avatar';
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      debugPrint('Error uploading avatar: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  void clearProfile() {
    _currentProfile = null;
    _errorMessage = null;
    notifyListeners();
  }
}
