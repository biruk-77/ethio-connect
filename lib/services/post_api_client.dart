import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/post_api_config.dart';
import '../utils/app_logger.dart';

/// Dedicated API client for Post Service
/// Handles all requests to https://ethiopost.unitybingo.com
class PostApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  // Singleton pattern
  static final PostApiClient _instance = PostApiClient._internal();
  factory PostApiClient() => _instance;
  
  PostApiClient._internal() {
    AppLogger.startup('Initializing Post API Client with base URL: ${PostApiConfig.apiUrl}');
    
    _dio = Dio(BaseOptions(
      baseUrl: PostApiConfig.apiUrl,
      connectTimeout: PostApiConfig.connectionTimeout,
      receiveTimeout: PostApiConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Log API request
          AppLogger.apiRequest(
            options.method,
            options.path,
            data: options.data,
          );
          
          // Add auth token to requests
          final token = await getAccessToken();
          AppLogger.debug('🔍 Token retrieved from storage: ${token != null ? "✅ Found (${token.length} chars)" : "❌ NULL"}');
          
          if (token != null && token.isNotEmpty) {
            AppLogger.token('✅ Attaching access token to Post Service request');
            options.headers['Authorization'] = 'Bearer $token';
          } else {
            AppLogger.error('⚠️ NO TOKEN FOUND! Request will fail with 401');
            AppLogger.warning('💡 Make sure you are logged in before creating posts');
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // Format error message
          final statusCode = error.response?.statusCode;
          final endpoint = error.requestOptions.path;
          final errorData = error.response?.data;
          
          AppLogger.divider();
          AppLogger.error('🚨 POST SERVICE API FAILED', tag: '');
          AppLogger.info('📍 Endpoint: $endpoint');
          if (statusCode != null) {
            AppLogger.info('🔢 Status Code: $statusCode');
          }
          
          // Extract error message
          String? errorMessage;
          if (errorData is Map) {
            errorMessage = errorData['message'] ?? errorData['error'] ?? errorData['msg'];
            if (errorData['errors'] != null) {
              AppLogger.warning('⚠️ Validation Errors:');
              if (errorData['errors'] is List) {
                for (var err in errorData['errors']) {
                  AppLogger.warning('   • $err');
                }
              } else if (errorData['errors'] is Map) {
                errorData['errors'].forEach((key, value) {
                  AppLogger.warning('   • $key: $value');
                });
              }
            }
          }
          
          if (errorMessage != null) {
            AppLogger.error('💬 Message: $errorMessage');
          } else {
            AppLogger.error('💬 Message: ${error.message}');
          }
          AppLogger.dividerBottom();
          
          return handler.next(error);
        },
        onResponse: (response, handler) {
          final statusCode = response.statusCode ?? 0;
          final endpoint = response.requestOptions.path;
          final data = response.data;
          
          AppLogger.divider();
          AppLogger.success('✅ POST SERVICE RESPONSE: $statusCode');
          AppLogger.info('📍 Endpoint: $endpoint');
          
          // Log response data structure
          if (data is Map) {
            if (data.containsKey('success')) {
              AppLogger.info('✓ Success: ${data['success']}');
            }
            if (data.containsKey('message')) {
              AppLogger.info('💬 Message: ${data['message']}');
            }
            if (data.containsKey('data')) {
              final responseData = data['data'];
              if (responseData is List) {
                AppLogger.info('📊 Data Count: ${responseData.length} items');
              } else if (responseData is Map) {
                AppLogger.info('📦 Data Keys: ${responseData.keys.join(", ")}');
              }
            }
          }
          
          AppLogger.dividerBottom();
          return handler.next(response);
        },
      ),
    );
  }

  Dio get dio => _dio;

  // Token management (shared with main ApiClient)
  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  // Generic request methods
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // Multipart form data for file uploads
  Future<Response> uploadFile(
    String path,
    String filePath,
    String fieldName, {
    Map<String, dynamic>? additionalData,
  }) async {
    AppLogger.upload('Uploading file: $filePath to Post Service');
    
    FormData formData = FormData.fromMap({
      fieldName: await MultipartFile.fromFile(filePath),
      ...?additionalData,
    });

    final response = await _dio.post(
      path,
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      ),
    );
    
    AppLogger.success('File uploaded successfully');
    return response;
  }
}
