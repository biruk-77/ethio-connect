import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../providers/report_provider.dart';

class ReportDialog extends StatefulWidget {
  final String targetType; // 'Post', 'Comment', 'User', 'Profile'
  final String targetId;
  final String? targetTitle;
  final VoidCallback? onReportSubmitted;

  const ReportDialog({
    super.key,
    required this.targetType,
    required this.targetId,
    this.targetTitle,
    this.onReportSubmitted,
  });

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  final ReportProvider _reportProvider = ReportProvider();
  final _descriptionController = TextEditingController();
  
  String? _selectedReason;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a reason for reporting'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final success = await _reportProvider.submitReport(
      targetType: widget.targetType,
      targetId: widget.targetId,
      reason: _selectedReason!,
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
    );

    if (success) {
      if (mounted) {
        Navigator.of(context).pop();
        widget.onReportSubmitted?.call();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_reportProvider.error ?? 'Failed to submit report'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.report,
            color: Colors.red,
            size: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Report ${widget.targetType}',
              style: theme.textTheme.titleLarge,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.targetTitle != null) ...[
              Text(
                'Reporting: "${widget.targetTitle}"',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              'Why are you reporting this ${widget.targetType.toLowerCase()}?',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            
            // Reason selection
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: ReportReason.allReasons.map((reason) {
                    return RadioListTile<String>(
                      title: Text(
                        ReportReason.displayNames[reason] ?? reason,
                        style: theme.textTheme.bodyMedium,
                      ),
                      value: reason,
                      groupValue: _selectedReason,
                      onChanged: (value) {
                        setState(() {
                          _selectedReason = value;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    );
                  }).toList(),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Optional description
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Additional details (optional)',
                hintText: 'Provide more context about why you\'re reporting this...',
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Info text
            Text(
              'Reports are reviewed by our moderation team. False reports may result in account restrictions.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitReport,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Submit Report'),
        ),
      ],
    );
  }
}

/// Floating action button for reporting
class ReportButton extends StatelessWidget {
  final String targetType;
  final String targetId;
  final String? targetTitle;
  final VoidCallback? onReportSubmitted;

  const ReportButton({
    super.key,
    required this.targetType,
    required this.targetId,
    this.targetTitle,
    this.onReportSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.flag,
        color: Colors.grey[600],
        size: 20,
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => ReportDialog(
            targetType: targetType,
            targetId: targetId,
            targetTitle: targetTitle,
            onReportSubmitted: onReportSubmitted,
          ),
        );
      },
      tooltip: 'Report',
    );
  }
}

/// Simple report menu item
class ReportMenuItem extends StatelessWidget {
  final String targetType;
  final String targetId;
  final String? targetTitle;
  final VoidCallback? onReportSubmitted;

  const ReportMenuItem({
    super.key,
    required this.targetType,
    required this.targetId,
    this.targetTitle,
    this.onReportSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuItem<String>(
      value: 'report',
      child: const Row(
        children: [
          Icon(Icons.flag, size: 16, color: Colors.red),
          SizedBox(width: 8),
          Text('Report', style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }

  static void handleReport(
    BuildContext context, {
    required String targetType,
    required String targetId,
    String? targetTitle,
    VoidCallback? onReportSubmitted,
  }) {
    showDialog(
      context: context,
      builder: (context) => ReportDialog(
        targetType: targetType,
        targetId: targetId,
        targetTitle: targetTitle,
        onReportSubmitted: onReportSubmitted,
      ),
    );
  }
}
