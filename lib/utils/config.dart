/// Configuration utilities for the EthioConnect app
class Config {
  static const String baseUrl = 'https://ethiocms.unitybingo.com';
  static const String socketUrl = 'https://ethiocms.unitybingo.com';
  static const String apiVersion = 'v1';
  
  // API endpoints
  static String get apiBaseUrl => '$baseUrl/api/$apiVersion';
  
  // Socket.IO configuration
  static Map<String, dynamic> get socketOptions => {
    'transports': ['polling', 'websocket'],
    'timeout': 20000,
    'forceNew': true,
  };
}
