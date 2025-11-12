import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../services/report_service.dart';
import '../utils/app_logger.dart';

class ReportProvider extends ChangeNotifier {
  final ReportService _reportService = ReportService();

  // State
  bool _isLoading = false;
  String? _error;
  List<Report> _reports = [];
  Map<String, bool> _reportedTargets = {};
  Map<String, dynamic> _reportStats = {};
  
  // Pagination
  int _currentPage = 1;
  bool _hasMore = true;
  final int _limit = 20;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Report> get reports => _reports;
  bool get hasMore => _hasMore;
  int get currentPage => _currentPage;
  Map<String, dynamic> get reportStats => _reportStats;

  /// Check if target has been reported by current user
  bool hasReported(String targetType, String targetId) {
    return _reportedTargets['${targetType}_$targetId'] ?? false;
  }

  /// Clear state
  void clearState() {
    _reports.clear();
    _reportedTargets.clear();
    _currentPage = 1;
    _hasMore = true;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Submit a report
  Future<bool> submitReport({
    required String targetType,
    required String targetId,
    required String reason,
    String? description,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final report = await _reportService.submitReport(
        targetType: targetType,
        targetId: targetId,
        reason: reason,
        description: description,
      );

      // Mark as reported locally
      _reportedTargets['${targetType}_$targetId'] = true;
      
      // Add to reports list
      _reports.insert(0, report);
      
      notifyListeners();
      AppLogger.success('✅ Report submitted successfully');
      return true;
    } catch (e) {
      _error = e.toString();
      AppLogger.error('Failed to submit report: $e');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Load user's reports
  Future<void> loadUserReports({
    bool refresh = false,
    String? status,
  }) async {
    if (refresh) {
      clearState();
    }

    if (_isLoading || (!_hasMore && !refresh)) return;

    _setLoading(true);
    _error = null;

    try {
      final response = await _reportService.getUserReports(
        page: _currentPage,
        limit: _limit,
        status: status,
      );

      if (refresh) {
        _reports = response.reports;
      } else {
        _reports.addAll(response.reports);
      }

      _currentPage++;
      _hasMore = response.hasMore;
      
      AppLogger.success('✅ Loaded ${response.reports.length} reports');
    } catch (e) {
      _error = e.toString();
      AppLogger.error('Failed to load reports: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Get report by ID
  Future<Report?> getReport(String reportId) async {
    try {
      final report = await _reportService.getReport(reportId);
      return report;
    } catch (e) {
      _error = e.toString();
      AppLogger.error('Failed to get report: $e');
      notifyListeners();
      return null;
    }
  }

  /// Cancel a report
  Future<bool> cancelReport(String reportId) async {
    _setLoading(true);
    _error = null;

    try {
      await _reportService.cancelReport(reportId);
      
      // Remove from local list
      _reports.removeWhere((r) => r.id == reportId);
      
      notifyListeners();
      AppLogger.success('✅ Report cancelled');
      return true;
    } catch (e) {
      _error = e.toString();
      AppLogger.error('Failed to cancel report: $e');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Check if user has reported a target
  Future<bool> checkReportStatus({
    required String targetType,
    required String targetId,
  }) async {
    try {
      final hasReported = await _reportService.hasUserReported(
        targetType: targetType,
        targetId: targetId,
      );
      
      _reportedTargets['${targetType}_$targetId'] = hasReported;
      notifyListeners();
      
      return hasReported;
    } catch (e) {
      AppLogger.error('Failed to check report status: $e');
      return false;
    }
  }

  /// Load report statistics
  Future<void> loadReportStats() async {
    try {
      _reportStats = await _reportService.getReportStats();
      notifyListeners();
      AppLogger.success('✅ Report stats loaded');
    } catch (e) {
      AppLogger.error('Failed to load report stats: $e');
    }
  }

  /// Get reports by status
  List<Report> getReportsByStatus(String status) {
    return _reports.where((r) => r.status == status).toList();
  }

  /// Get pending reports count
  int get pendingReportsCount {
    return _reports.where((r) => r.isPending).length;
  }

  /// Get resolved reports count
  int get resolvedReportsCount {
    return _reports.where((r) => r.isResolved).length;
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Initialize real-time listeners
  void initializeListeners() {
    _reportService.onReportUpdated((data) {
      try {
        final report = Report.fromJson(data['data']);
        
        final index = _reports.indexWhere((r) => r.id == report.id);
        if (index != -1) {
          _reports[index] = report;
          notifyListeners();
        }
      } catch (e) {
        AppLogger.error('Error handling report update: $e');
      }
    });

    _reportService.onReportResolved((data) {
      try {
        final report = Report.fromJson(data['data']);
        
        final index = _reports.indexWhere((r) => r.id == report.id);
        if (index != -1) {
          _reports[index] = report;
          notifyListeners();
        }
      } catch (e) {
        AppLogger.error('Error handling report resolution: $e');
      }
    });
  }

  @override
  void dispose() {
    _reportService.dispose();
    super.dispose();
  }
}
