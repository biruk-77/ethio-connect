import 'package:flutter/foundation.dart';

/// Centralized logger with emoji support for better visual debugging
class AppLogger {
  static const bool _enableLogs = kDebugMode; // Only log in debug mode
  
  // Emoji constants for different log types
  static const String _rocket = '🚀';
  static const String _check = '✅';
  static const String _error = '❌';
  static const String _warning = '⚠️';
  static const String _info = 'ℹ️';
  static const String _api = '🌐';
  static const String _auth = '🔐';
  static const String _user = '👤';
  static const String _profile = '📋';
  static const String _document = '📄';
  static const String _upload = '📤';
  static const String _download = '📥';
  static const String _database = '💾';
  static const String _search = '🔍';
  static const String _settings = '⚙️';
  static const String _clock = '⏰';
  static const String _fire = '🔥';
  static const String _party = '🎉';
  static const String _lock = '🔒';
  static const String _unlock = '🔓';
  static const String _phone = '📱';
  static const String _email = '📧';
  static const String _key = '🔑';
  static const String _shield = '🛡️';
  static const String _refresh = '🔄';
  static const String _trash = '🗑️';
  static const String _edit = '✏️';
  static const String _save = '💾';
  static const String _loading = '⏳';
  static const String _bug = '🐛';
  
  // ANSI color codes
  static const String _reset = '\x1B[0m';
  static const String _red = '\x1B[31m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _blue = '\x1B[34m';
  static const String _magenta = '\x1B[35m';
  static const String _cyan = '\x1B[36m';
  static const String _white = '\x1B[37m';

  /// Log app startup
  static void startup(String message) {
    _log('$_rocket $_rocket $_rocket STARTUP', message, _green);
  }

  /// Log successful operations
  static void success(String message, {String? tag}) {
    _log('$_check SUCCESS ${tag ?? ""}', message, _green);
  }

  /// Log errors
  static void error(String message, {dynamic error, StackTrace? stackTrace, String? tag}) {
    _log('$_error ERROR ${tag ?? ""}', message, _red);
    if (error != null) {
      _log('$_bug Details', error.toString(), _red);
    }
    if (stackTrace != null && kDebugMode) {
      debugPrintStack(stackTrace: stackTrace, label: 'Stack Trace');
    }
  }

  /// Log warnings
  static void warning(String message, {String? tag}) {
    _log('$_warning WARNING ${tag ?? ""}', message, _yellow);
  }

  /// Log info messages
  static void info(String message, {String? tag}) {
    _log('$_info INFO ${tag ?? ""}', message, _blue);
  }

  /// Log API requests
  static void apiRequest(String method, String endpoint, {Map<String, dynamic>? data}) {
    divider();
    _log('$_rocket API REQUEST', '$method $endpoint', _cyan);
    if (data != null && data.isNotEmpty) {
      _log('📦 Request Data', data.toString(), _cyan);
    }
  }

  /// Log API responses
  static void apiResponse(int statusCode, String endpoint, {dynamic data}) {
    final emoji = statusCode >= 200 && statusCode < 300 ? _check : _error;
    final color = statusCode >= 200 && statusCode < 300 ? _green : _red;
    _log('$emoji API RESPONSE', '$statusCode $endpoint', color);
    if (data != null && data.toString().length < 500) {
      _log('📦 Response Data', data.toString(), color);
    } else {
      _log('📦 Response Data', 'Large response (${data.toString().length} chars)', color);
    }
    dividerBottom();
  }

  /// Log authentication events
  static void auth(String message, {bool isSuccess = true}) {
    final emoji = isSuccess ? _unlock : _lock;
    final color = isSuccess ? _green : _yellow;
    _log('$_auth AUTHENTICATION $emoji', message, color);
  }

  /// Log user-related events
  static void user(String message) {
    _log('$_user USER', message, _magenta);
  }

  /// Log profile events
  static void profile(String message) {
    _log('$_profile PROFILE', message, _magenta);
  }

  /// Log document/verification events
  static void document(String message) {
    _log('$_document DOCUMENT', message, _cyan);
  }

  /// Log file uploads
  static void upload(String message) {
    _log('$_upload UPLOAD', message, _blue);
  }

  /// Log file downloads
  static void download(String message) {
    _log('$_download DOWNLOAD', message, _blue);
  }

  /// Log database operations
  static void database(String message, {bool isWrite = false}) {
    final emoji = isWrite ? _save : _database;
    _log('$emoji DATABASE', message, _yellow);
  }

  /// Log search operations
  static void search(String query) {
    _log('$_search SEARCH', query, _cyan);
  }

  /// Log settings changes
  static void settings(String message) {
    _log('$_settings SETTINGS', message, _blue);
  }

  /// Log token operations
  static void token(String message, {bool isRefresh = false}) {
    final emoji = isRefresh ? _refresh : _key;
    _log('$emoji TOKEN', message, _yellow);
  }

  /// Log phone/OTP events
  static void phone(String message) {
    _log('$_phone PHONE', message, _magenta);
  }

  /// Log email events
  static void email(String message) {
    _log('$_email EMAIL', message, _magenta);
  }

  /// Log security events
  static void security(String message) {
    _log('$_shield SECURITY', message, _red);
  }

  /// Log loading states
  static void loading(String message, {bool isStart = true}) {
    final emoji = isStart ? _loading : _check;
    _log('$emoji LOADING', message, _yellow);
  }

  /// Log celebration/milestone events
  static void celebrate(String message) {
    _log('$_party $_fire CELEBRATION $_fire $_party', message, _green);
  }

  /// Log navigation events
  static void navigation(String route) {
    _log('$_rocket NAVIGATION', route, _cyan);
  }

  /// Log performance metrics
  static void performance(String operation, Duration duration) {
    _log('$_clock PERFORMANCE', '$operation took ${duration.inMilliseconds}ms', _yellow);
  }

  /// Log memory/cache operations
  static void cache(String message, {bool isHit = true}) {
    final emoji = isHit ? _check : _warning;
    _log('$emoji CACHE', message, _blue);
  }

  /// Log deletion operations
  static void delete(String message) {
    _log('$_trash DELETE', message, _red);
  }

  /// Log edit operations
  static void edit(String message) {
    _log('$_edit EDIT', message, _blue);
  }

  /// Log debug information
  static void debug(String message, {String? tag}) {
    _log('$_bug DEBUG ${tag ?? ""}', message, _white);
  }

  /// Internal log method
  static void _log(String prefix, String message, String color) {
    if (!_enableLogs) return;
    
    final timestamp = DateTime.now().toString().split('.')[0];
    final logMessage = '[$timestamp] $prefix: $message';
    
    if (kDebugMode) {
      // Use color in debug mode
      debugPrint('$color$logMessage$_reset');
    } else {
      debugPrint(logMessage);
    }
  }

  /// Log a divider for better readability
  static void divider() {
    if (!_enableLogs) return;
    debugPrint('$_cyan╔════════════════════════════════════════════════════╗$_reset');
  }

  /// Log a bottom divider
  static void dividerBottom() {
    if (!_enableLogs) return;
    debugPrint('$_cyan╚════════════════════════════════════════════════════╝$_reset');
  }

  /// Log a section header
  static void section(String title) {
    if (!_enableLogs) return;
    debugPrint('');
    divider();
    _log('$_fire $title $_fire', '', _cyan);
    dividerBottom();
    debugPrint('');
  }

  /// Log object properties in a formatted way
  static void object(String name, Map<String, dynamic> properties) {
    if (!_enableLogs) return;
    _log('$_info OBJECT', name, _blue);
    properties.forEach((key, value) {
      debugPrint('  $key: $value');
    });
  }

  /// Log list items
  static void list(String name, List<dynamic> items) {
    if (!_enableLogs) return;
    _log('$_info LIST', '$name (${items.length} items)', _blue);
    for (var i = 0; i < items.length; i++) {
      debugPrint('  [$i]: ${items[i]}');
    }
  }
}
