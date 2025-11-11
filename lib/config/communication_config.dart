class CommunicationConfig {

  static const String baseUrl = 'https://ethiocms.unitybingo.com';
  
  // Socket.IO settings (from backend tests)
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration reconnectDelay = Duration(seconds: 2);
  static const int maxReconnectAttempts = 5;
  
  // API endpoints (matching backend test structure)
  static String get socketUrl => baseUrl; // Socket.IO connection
  static String get apiUrl => baseUrl;    // REST API base URL
  static String get uploadImageEndpoint => '$apiUrl/api/v1/uploads/image';
  static String get uploadImagesEndpoint => '$apiUrl/api/v1/uploads/images';
  static String get uploadFileEndpoint => '$apiUrl/api/v1/uploads/file';
  static String get conversationsEndpoint => '$apiUrl/api/v1/messages/conversations';
  static String get notificationsEndpoint => '$apiUrl/api/v1/notifications';
}
