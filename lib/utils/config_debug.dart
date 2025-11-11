import '../config/communication_config.dart';
import 'app_logger.dart';

/// Debug utility to verify configuration values
class ConfigDebug {
  static void printConfig() {
    AppLogger.info('╔════════════════════════════════════════════════════════════');
    AppLogger.info('║  CONFIGURATION DEBUG');
    AppLogger.info('╠════════════════════════════════════════════════════════════');
    AppLogger.info('║  Base URL: ${CommunicationConfig.baseUrl}');
    AppLogger.info('║  Socket URL: ${CommunicationConfig.socketUrl}');
    AppLogger.info('║  API URL: ${CommunicationConfig.apiUrl}');
    AppLogger.info('║  Conversations: ${CommunicationConfig.conversationsEndpoint}');
    AppLogger.info('║  Notifications: ${CommunicationConfig.notificationsEndpoint}');
    AppLogger.info('╠════════════════════════════════════════════════════════════');
    
    // Character-by-character check for typos
    final baseUrl = CommunicationConfig.baseUrl;
    AppLogger.info('║  Base URL length: ${baseUrl.length} characters');
    AppLogger.info('║  Contains "unitybingo": ${baseUrl.contains("unitybingo")}');
    AppLogger.info('║  Contains "unittybingo": ${baseUrl.contains("unittybingo")}');
    
    // Check for the exact substring around 'unity'
    final unityIndex = baseUrl.indexOf('unity');
    if (unityIndex != -1) {
      final snippet = baseUrl.substring(
        unityIndex.clamp(0, baseUrl.length),
        (unityIndex + 15).clamp(0, baseUrl.length),
      );
      AppLogger.info('║  Around "unity": $snippet');
    }
    
    AppLogger.info('╚════════════════════════════════════════════════════════════');
  }

  static void checkForTypos() {
    final config = CommunicationConfig.baseUrl;
    final issues = <String>[];
    
    if (config.contains('unittybingo')) {
      issues.add('❌ TYPO FOUND: "unittybingo" (double t)');
    }
    
    if (!config.startsWith('https://')) {
      issues.add('⚠️ URL does not start with https://');
    }
    
    if (config.contains(' ')) {
      issues.add('❌ URL contains spaces');
    }
    
    if (issues.isEmpty) {
      AppLogger.success('✅ Configuration looks correct!');
    } else {
      AppLogger.error('🔥 CONFIGURATION ISSUES DETECTED:');
      for (final issue in issues) {
        AppLogger.error('   $issue');
      }
    }
  }
}
