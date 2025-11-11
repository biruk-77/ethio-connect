import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/app_logger.dart';

class ApiClient {
  static const String baseUrl = 'https://ethiouser.zewdbingo.com';
 
  
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  // Singleton pattern
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  
  ApiClient._internal() {
    AppLogger.startup('Initializing API Client with base URL: $baseUrl');
    
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl, // Change to localUrl for local development
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
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
            data: options.data is FormData ? {'type': 'FormData'} : options.data,
          );
          
          // Add auth token to requests
          final token = await getAccessToken();
          if (token != null && token.isNotEmpty) {
            AppLogger.token('Attaching access token to request');
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // Format error message nicely
          final statusCode = error.response?.statusCode;
          final endpoint = error.requestOptions.path;
          final errorData = error.response?.data;
          
          AppLogger.divider();
          AppLogger.error('🚨 API REQUEST FAILED', tag: '');
          AppLogger.info('📍 Endpoint: $endpoint');
          if (statusCode != null) {
            AppLogger.info('🔢 Status Code: $statusCode');
          }
          
          // Extract meaningful error message
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
          
          // Handle 401 errors by refreshing token
          if (error.response?.statusCode == 401) {
            AppLogger.warning('Received 401 Unauthorized - attempting token refresh');
            final refreshToken = await getRefreshToken();
            if (refreshToken != null && refreshToken.isNotEmpty) {
              try {
                AppLogger.token('Refreshing access token', isRefresh: true);
                final response = await _dio.post(
                  '/api/auth/refresh-token',
                  data: {'refreshToken': refreshToken},
                );
                
                if (response.statusCode == 200) {
                  final newAccessToken = response.data['data']['accessToken'];
                  await saveAccessToken(newAccessToken);
                  AppLogger.success('Token refreshed successfully');
                  
                  // Retry the original request
                  final opts = error.requestOptions;
                  opts.headers['Authorization'] = 'Bearer $newAccessToken';
                  AppLogger.info('Retrying original request');
                  final cloneReq = await _dio.request(
                    opts.path,
                    options: Options(
                      method: opts.method,
                      headers: opts.headers,
                    ),
                    data: opts.data,
                    queryParameters: opts.queryParameters,
                  );
                  return handler.resolve(cloneReq);
                }
              } catch (e) {
                // Refresh failed, clear tokens
                AppLogger.error('Token refresh failed - clearing tokens', error: e);
                await clearTokens();
              }
            }
          }
          return handler.next(error);
        },
        onResponse: (response, handler) {
          final statusCode = response.statusCode ?? 0;
          final endpoint = response.requestOptions.path;
          final data = response.data;
          
          AppLogger.divider();
          AppLogger.success('✅ API RESPONSE: $statusCode');
          AppLogger.info('📍 Endpoint: $endpoint');
          AppLogger.info('🔢 Status Code: $statusCode');
          
          // Log response data structure
          if (data is Map) {
            AppLogger.info('📦 Response Type: Map');
            AppLogger.info('🔑 Keys: ${data.keys.join(", ")}');
            
            // Log success status if available
            if (data.containsKey('success')) {
              AppLogger.info('✓ Success: ${data['success']}');
            }
            
            // Log message if available
            if (data.containsKey('message')) {
              AppLogger.info('💬 Message: ${data['message']}');
            }
            
            // Log data details
            if (data.containsKey('data')) {
              final responseData = data['data'];
              if (responseData is List) {
                AppLogger.info('📊 Data Count: ${responseData.length} items');
                if (responseData.isNotEmpty) {
                  AppLogger.info('📋 First Item Keys: ${(responseData[0] as Map).keys.join(", ")}');
                }
              } else if (responseData is Map) {
                AppLogger.info('📦 Data Keys: ${responseData.keys.join(", ")}');
                // For user data
                if (responseData.containsKey('username')) {
                  AppLogger.info('👤 User: ${responseData['username']}');
                }
                if (responseData.containsKey('email')) {
                  AppLogger.info('📧 Email: ${responseData['email']}');
                }
              } else {
                AppLogger.info('📦 Data: $responseData');
              }
            }
          } else if (data is List) {
            AppLogger.info('📦 Response Type: List');
            AppLogger.info('📊 Items Count: ${data.length}');
            if (data.isNotEmpty && data[0] is Map) {
              AppLogger.info('🔑 Item Keys: ${(data[0] as Map).keys.join(", ")}');
            }
          } else {
            AppLogger.info('📦 Response: $data');
          }
          
          AppLogger.dividerBottom();
          return handler.next(response);
        },
      ),
    );
  }

  Dio get dio => _dio;

  // Token management
  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  Future<void> saveAccessToken(String token) async {
    AppLogger.database('Saving access token', isWrite: true);
    await _storage.write(key: 'access_token', value: token);
    AppLogger.success('Access token saved');
  }

  Future<void> saveRefreshToken(String token) async {
    AppLogger.database('Saving refresh token', isWrite: true);
    await _storage.write(key: 'refresh_token', value: token);
    AppLogger.success('Refresh token saved');
  }

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    AppLogger.token('Saving authentication tokens');
    await saveAccessToken(accessToken);
    await saveRefreshToken(refreshToken);
    AppLogger.celebrate('Tokens saved successfully!');
  }

  Future<void> clearTokens() async {
    AppLogger.delete('Clearing authentication tokens');
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    AppLogger.success('Tokens cleared');
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
    AppLogger.upload('Uploading file: $filePath to $path');
    
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
