import 'package:flutter/material.dart';
import '../../providers/report_provider.dart';
import '../../models/report_model.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  final ReportProvider _reportProvider = ReportProvider();
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _reportProvider.initializeListeners();
    _loadReports();

    // Setup infinite scroll
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMoreReports();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _reportProvider.dispose();
    super.dispose();
  }

  Future<void> _loadReports() async {
    final status = _getStatusForTab(_tabController.index);
    await _reportProvider.loadUserReports(refresh: true, status: status);
  }

  Future<void> _loadMoreReports() async {
    final status = _getStatusForTab(_tabController.index);
    await _reportProvider.loadUserReports(refresh: false, status: status);
  }

  String? _getStatusForTab(int index) {
    switch (index) {
      case 0: return null; // All
      case 1: return 'pending';
      case 2: return 'reviewed';
      case 3: return 'resolved';
      default: return null;
    }
  }

  List<Report> _getFilteredReports() {
    final status = _getStatusForTab(_tabController.index);
    if (status == null) {
      return _reportProvider.reports;
    }
    return _reportProvider.getReportsByStatus(status);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReports,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) {
            _loadReports();
          },
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Reviewed'),
            Tab(text: 'Resolved'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReportsList(),
          _buildReportsList(),
          _buildReportsList(),
          _buildReportsList(),
        ],
      ),
    );
  }

  Widget _buildReportsList() {
    return AnimatedBuilder(
      animation: _reportProvider,
      builder: (context, _) {
        if (_reportProvider.isLoading && _reportProvider.reports.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_reportProvider.error != null && _reportProvider.reports.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  _reportProvider.error!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadReports,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final filteredReports = _getFilteredReports();

        if (filteredReports.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.report_off,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No reports found',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Reports you submit will appear here',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadReports,
          child: ListView.builder(
            controller: _scrollController,
            itemCount: filteredReports.length + (_reportProvider.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= filteredReports.length) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final report = filteredReports[index];
              return ReportCard(
                report: report,
                onCancel: report.isPending ? () => _cancelReport(report) : null,
                onTap: () => _viewReportDetails(report),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _cancelReport(Report report) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Report'),
        content: const Text('Are you sure you want to cancel this report?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _reportProvider.cancelReport(report.id);
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_reportProvider.error ?? 'Failed to cancel report'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _viewReportDetails(Report report) {
    showDialog(
      context: context,
      builder: (context) => ReportDetailsDialog(report: report),
    );
  }
}

class ReportCard extends StatelessWidget {
  final Report report;
  final VoidCallback? onCancel;
  final VoidCallback? onTap;

  const ReportCard({
    super.key,
    required this.report,
    this.onCancel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getIconForTargetType(report.targetType),
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${report.targetType} Report',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _buildStatusChip(context),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                ReportReason.displayNames[report.reason] ?? report.reason,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.red[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (report.description != null) ...[
                const SizedBox(height: 4),
                Text(
                  report.description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    report.timeAgo,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const Spacer(),
                  if (onCancel != null)
                    TextButton(
                      onPressed: onCancel,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: const Text('Cancel'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    final theme = Theme.of(context);
    Color color;
    String label;

    switch (report.status) {
      case 'pending':
        color = Colors.orange;
        label = 'Pending';
        break;
      case 'reviewed':
        color = Colors.blue;
        label = 'Reviewed';
        break;
      case 'resolved':
        color = Colors.green;
        label = 'Resolved';
        break;
      case 'dismissed':
        color = Colors.grey;
        label = 'Dismissed';
        break;
      default:
        color = Colors.grey;
        label = report.status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  IconData _getIconForTargetType(String targetType) {
    switch (targetType) {
      case 'Post':
        return Icons.article;
      case 'Comment':
        return Icons.comment;
      case 'User':
        return Icons.person;
      case 'Profile':
        return Icons.account_circle;
      default:
        return Icons.report;
    }
  }
}

class ReportDetailsDialog extends StatelessWidget {
  final Report report;

  const ReportDetailsDialog({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: Text('Report Details'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Type:', report.targetType),
            _buildDetailRow('Reason:', ReportReason.displayNames[report.reason] ?? report.reason),
            _buildDetailRow('Status:', report.status),
            _buildDetailRow('Submitted:', report.timeAgo),
            if (report.description != null) ...[
              const SizedBox(height: 16),
              Text(
                'Description:',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                report.description!,
                style: theme.textTheme.bodyMedium,
              ),
            ],
            if (report.reviewedAt != null) ...[
              const SizedBox(height: 16),
              _buildDetailRow('Reviewed:', report.reviewedAt!.toString()),
            ],
            if (report.resolution != null) ...[
              const SizedBox(height: 8),
              Text(
                'Resolution:',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                report.resolution!,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
