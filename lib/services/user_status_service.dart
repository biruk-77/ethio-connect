import '../services/socket_service.dart';
import '../services/auth/auth_service.dart';
import '../utils/app_logger.dart';

/// User Status Service - Manages user online/offline/away/busy status
/// Based on backend: test/test/logs/userStatus.service.js
class UserStatusService {
  static final UserStatusService _instance = UserStatusService._internal();
  factory UserStatusService() => _instance;
  UserStatusService._internal();

  final SocketService _socketService = SocketService();
  final AuthService _authService = AuthService();

  String _currentStatus = 'offline';
  
  String get currentStatus => _currentStatus;

  /// Update user status
  void updateStatus(String status) {
    if (!['online', 'away', 'busy', 'offline'].contains(status)) {
      AppLogger.error('Invalid status: $status');
      return;
    }

    AppLogger.info('📡 Updating status to: $status');
    _currentStatus = status;

    _socketService.emit('status:update', {
      'status': status,
    });
  }

  /// Set status to online
  void setOnline() {
    updateStatus('online');
  }

  /// Set status to away
  void setAway() {
    updateStatus('away');
  }

  /// Set status to busy
  void setBusy() {
    updateStatus('busy');
  }

  /// Set status to offline
  void setOffline() {
    updateStatus('offline');
  }

  /// Listen for status updates
  void onStatusUpdated(Function(Map<String, dynamic>) callback) {
    _socketService.on('status:updated', (data) {
      AppLogger.info('✅ Status updated: ${data['status']}');
      _currentStatus = data['status'];
      callback(data);
    });
  }

  /// Listen for other users' status changes
  void onUserStatusChanged(Function(Map<String, dynamic>) callback) {
    _socketService.on('user:status:changed', (data) {
      AppLogger.info('👤 User ${data['userId']} is now ${data['status']}');
      callback(data);
    });
  }

  /// Get status of specific user (if backend supports it)
  void getUserStatus(String userId) {
    _socketService.emit('status:get', {
      'userId': userId,
    });
  }

  /// Listen for user status response
  void onUserStatus(Function(Map<String, dynamic>) callback) {
    _socketService.on('status:user', callback);
  }

  /// Auto-update status based on app lifecycle
  void handleAppLifecycleChange(String state) {
    switch (state) {
      case 'resumed':
        setOnline();
        break;
      case 'inactive':
        setAway();
        break;
      case 'paused':
      case 'detached':
        setOffline();
        break;
    }
  }

  /// Clean up listeners
  void dispose() {
    _socketService.off('status:updated');
    _socketService.off('user:status:changed');
    _socketService.off('status:user');
  }
}
