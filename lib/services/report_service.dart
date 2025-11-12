import 'dart:async';
import '../models/report_model.dart';
import '../services/socket_service.dart';
import '../services/auth/auth_service.dart';
import '../utils/app_logger.dart';

/// Report Service - Handles content reporting and moderation
class ReportService {
  static final ReportService _instance = ReportService._internal();
  factory ReportService() => _instance;
  ReportService._internal();

  final SocketService _socketService = SocketService();
  final AuthService _authService = AuthService();

  /// Submit a report
  Future<Report> submitReport({
    required String targetType, // 'Post', 'Comment', 'User', 'Profile'
    required String targetId,
    required String reason,
    String? description,
  }) async {
    try {
      final completer = Completer<Report>();

      // Listen for response
      void responseHandler(dynamic data) {
        if (!completer.isCompleted) {
          if (data['success'] == true) {
            AppLogger.success('✅ Report submitted');
            completer.complete(Report.fromJson(data['data']));
          } else {
            completer.completeError(Exception(data['message'] ?? 'Failed to submit report'));
          }
          _socketService.off('report:created', responseHandler);
        }
      }

      _socketService.on('report:created', responseHandler);

      // Emit request
      _socketService.emit('report:create', {
        'targetType': targetType,
        'targetId': targetId,
        'reason': reason,
        if (description != null) 'description': description,
      });

      return await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          _socketService.off('report:created', responseHandler);
          throw Exception('Report submission timed out');
        },
      );
    } catch (e) {
      AppLogger.error('Failed to submit report: $e');
      rethrow;
    }
  }

  /// Get user's submitted reports
  Future<ReportResponse> getUserReports({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      final completer = Completer<ReportResponse>();

      void responseHandler(dynamic data) {
        if (!completer.isCompleted) {
          AppLogger.success('✅ Loaded ${data['reports']?.length ?? 0} reports');
          completer.complete(ReportResponse.fromJson(data));
          _socketService.off('reports:list', responseHandler);
        }
      }

      _socketService.on('reports:list', responseHandler);

      _socketService.emit('reports:get', {
        'page': page,
        'limit': limit,
        if (status != null) 'status': status,
      });

      return await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          _socketService.off('reports:list', responseHandler);
          throw Exception('Get reports timed out');
        },
      );
    } catch (e) {
      AppLogger.error('Failed to get reports: $e');
      rethrow;
    }
  }

  /// Get report by ID
  Future<Report> getReport(String reportId) async {
    try {
      final completer = Completer<Report>();

      void responseHandler(dynamic data) {
        if (!completer.isCompleted) {
          if (data['success'] == true) {
            completer.complete(Report.fromJson(data['data']));
          } else {
            completer.completeError(Exception(data['message'] ?? 'Report not found'));
          }
          _socketService.off('report:details', responseHandler);
        }
      }

      _socketService.on('report:details', responseHandler);

      _socketService.emit('report:get', {
        'reportId': reportId,
      });

      return await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          _socketService.off('report:details', responseHandler);
          throw Exception('Get report timed out');
        },
      );
    } catch (e) {
      AppLogger.error('Failed to get report: $e');
      rethrow;
    }
  }

  /// Cancel/withdraw a report (if pending)
  Future<void> cancelReport(String reportId) async {
    try {
      final completer = Completer<void>();

      void responseHandler(dynamic data) {
        if (!completer.isCompleted) {
          if (data['success'] == true) {
            AppLogger.success('✅ Report cancelled');
            completer.complete();
          } else {
            completer.completeError(Exception(data['message'] ?? 'Failed to cancel report'));
          }
          _socketService.off('report:cancelled', responseHandler);
        }
      }

      _socketService.on('report:cancelled', responseHandler);

      _socketService.emit('report:cancel', {
        'reportId': reportId,
      });

      return await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          _socketService.off('report:cancelled', responseHandler);
          throw Exception('Cancel report timed out');
        },
      );
    } catch (e) {
      AppLogger.error('Failed to cancel report: $e');
      rethrow;
    }
  }

  /// Check if user has already reported a target
  Future<bool> hasUserReported({
    required String targetType,
    required String targetId,
  }) async {
    try {
      final completer = Completer<bool>();

      void responseHandler(dynamic data) {
        if (!completer.isCompleted) {
          completer.complete(data['hasReported'] ?? false);
          _socketService.off('report:check:status', responseHandler);
        }
      }

      _socketService.on('report:check:status', responseHandler);

      _socketService.emit('report:check', {
        'targetType': targetType,
        'targetId': targetId,
      });

      return await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          _socketService.off('report:check:status', responseHandler);
          return false;
        },
      );
    } catch (e) {
      AppLogger.error('Failed to check report status: $e');
      return false;
    }
  }

  /// Get report statistics (for admins/moderators)
  Future<Map<String, dynamic>> getReportStats() async {
    try {
      final completer = Completer<Map<String, dynamic>>();

      void responseHandler(dynamic data) {
        if (!completer.isCompleted) {
          completer.complete(data);
          _socketService.off('reports:stats', responseHandler);
        }
      }

      _socketService.on('reports:stats', responseHandler);

      _socketService.emit('reports:stats:get', {});

      return await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          _socketService.off('reports:stats', responseHandler);
          return {};
        },
      );
    } catch (e) {
      AppLogger.error('Failed to get report stats: $e');
      return {};
    }
  }

  /// Listen for report updates
  void onReportUpdated(Function(dynamic) callback) {
    _socketService.on('report:updated', callback);
  }

  void onReportResolved(Function(dynamic) callback) {
    _socketService.on('report:resolved', callback);
  }

  /// Clean up listeners
  void dispose() {
    _socketService.off('report:created');
    _socketService.off('report:cancelled');
    _socketService.off('report:updated');
    _socketService.off('report:resolved');
    _socketService.off('reports:list');
    _socketService.off('reports:stats');
  }
}
