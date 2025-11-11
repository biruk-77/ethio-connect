import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../config/communication_config.dart';
import '../services/auth/auth_service.dart';
import '../utils/app_logger.dart';

/// Upload Service - Handles file and image uploads
/// Based on backend: test/test/logs/upload.routes.js
class UploadService {
  static final UploadService _instance = UploadService._internal();
  factory UploadService() => _instance;
  UploadService._internal();

  final Dio _dio = Dio();
  final AuthService _authService = AuthService();

  /// Upload a single image
  Future<Map<String, dynamic>> uploadImage(File imageFile) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      AppLogger.info('📤 Uploading image: ${imageFile.path}');

      final fileName = imageFile.path.split('/').last;
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
          contentType: MediaType('image', _getImageExtension(fileName)),
        ),
      });

      final response = await _dio.post(
        CommunicationConfig.uploadImageEndpoint,
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        AppLogger.success('✅ Image uploaded successfully');
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Upload failed');
      }
    } catch (e) {
      AppLogger.error('Failed to upload image: $e');
      rethrow;
    }
  }

  /// Upload multiple images
  Future<List<Map<String, dynamic>>> uploadImages(List<File> imageFiles) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      AppLogger.info('📤 Uploading ${imageFiles.length} images');

      final formData = FormData.fromMap({
        'images': await Future.wait(
          imageFiles.map((file) async {
            final fileName = file.path.split('/').last;
            return await MultipartFile.fromFile(
              file.path,
              filename: fileName,
              contentType: MediaType('image', _getImageExtension(fileName)),
            );
          }),
        ),
      });

      final response = await _dio.post(
        CommunicationConfig.uploadImagesEndpoint,
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        AppLogger.success('✅ ${imageFiles.length} images uploaded successfully');
        return List<Map<String, dynamic>>.from(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Upload failed');
      }
    } catch (e) {
      AppLogger.error('Failed to upload images: $e');
      rethrow;
    }
  }

  /// Upload a file (PDF, document, etc.)
  Future<Map<String, dynamic>> uploadFile(File file) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      AppLogger.info('📤 Uploading file: ${file.path}');

      final fileName = file.path.split('/').last;
      final extension = fileName.split('.').last.toLowerCase();
      
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
          contentType: MediaType('application', _getFileContentType(extension)),
        ),
      });

      final response = await _dio.post(
        CommunicationConfig.uploadFileEndpoint,
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        AppLogger.success('✅ File uploaded successfully');
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Upload failed');
      }
    } catch (e) {
      AppLogger.error('Failed to upload file: $e');
      rethrow;
    }
  }

  /// Upload with progress tracking
  Future<Map<String, dynamic>> uploadImageWithProgress(
    File imageFile,
    Function(int, int) onProgress,
  ) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final fileName = imageFile.path.split('/').last;
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
          contentType: MediaType('image', _getImageExtension(fileName)),
        ),
      });

      final response = await _dio.post(
        CommunicationConfig.uploadImageEndpoint,
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          contentType: 'multipart/form-data',
        ),
        onSendProgress: (sent, total) {
          onProgress(sent, total);
          AppLogger.info('Upload progress: ${(sent / total * 100).toStringAsFixed(0)}%');
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        AppLogger.success('✅ Image uploaded successfully');
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Upload failed');
      }
    } catch (e) {
      AppLogger.error('Failed to upload image: $e');
      rethrow;
    }
  }

  /// Helper: Get image extension
  String _getImageExtension(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'jpeg';
      case 'png':
        return 'png';
      case 'gif':
        return 'gif';
      case 'webp':
        return 'webp';
      default:
        return 'jpeg';
    }
  }

  /// Helper: Get file content type
  String _getFileContentType(String extension) {
    switch (extension) {
      case 'pdf':
        return 'pdf';
      case 'doc':
      case 'docx':
        return 'msword';
      case 'xls':
      case 'xlsx':
        return 'vnd.ms-excel';
      case 'zip':
        return 'zip';
      default:
        return 'octet-stream';
    }
  }
}
