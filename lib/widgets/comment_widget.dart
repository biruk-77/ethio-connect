import 'package:flutter/material.dart';
import '../models/comment_model.dart';
import '../utils/app_logger.dart';

class CommentWidget extends StatelessWidget {
  final Comment comment;
  final VoidCallback? onReply;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onReport;
  final bool showReplies;
  final List<Comment>? replies;
  final bool canEdit;
  final bool canDelete;

  const CommentWidget({
    super.key,
    required this.comment,
    this.onReply,
    this.onEdit,
    this.onDelete,
    this.onReport,
    this.showReplies = true,
    this.replies,
    this.canEdit = false,
    this.canDelete = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(
        left: comment.isReply ? 32.0 : 8.0,
        right: 8.0,
        top: 4.0,
        bottom: 4.0,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCommentHeader(context),
            const SizedBox(height: 8),
            _buildCommentContent(context),
            const SizedBox(height: 8),
            _buildCommentActions(context),
            if (showReplies && replies != null && replies!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildReplies(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCommentHeader(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
          child: Text(
            comment.author?.username.substring(0, 1).toUpperCase() ?? 'U',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                comment.author?.username ?? 'Anonymous',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  Text(
                    comment.timeAgo,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  if (comment.isEdited) ...[
                    const SizedBox(width: 4),
                    Text(
                      '(edited)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            size: 16,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit?.call();
                break;
              case 'delete':
                onDelete?.call();
                break;
              case 'report':
                onReport?.call();
                break;
            }
          },
          itemBuilder: (context) => [
            if (canEdit)
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 16),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
            if (canDelete)
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 16, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'report',
              child: Row(
                children: [
                  Icon(Icons.report, size: 16),
                  SizedBox(width: 8),
                  Text('Report'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCommentContent(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Text(
        comment.content,
        style: theme.textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildCommentActions(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        TextButton.icon(
          onPressed: onReply,
          icon: const Icon(Icons.reply, size: 16),
          label: const Text('Reply'),
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        if (comment.repliesCount > 0) ...[
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              // Toggle replies visibility
              AppLogger.info('Toggle replies for comment ${comment.id}');
            },
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurface.withOpacity(0.7),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              '${comment.repliesCount} ${comment.repliesCount == 1 ? 'reply' : 'replies'}',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReplies(BuildContext context) {
    return Column(
      children: replies!.map((reply) => CommentWidget(
        comment: reply,
        onReply: onReply,
        onEdit: onEdit,
        onDelete: onDelete,
        onReport: onReport,
        showReplies: false, // Don't show nested replies for now
        canEdit: canEdit,
        canDelete: canDelete,
      )).toList(),
    );
  }
}

class CommentInput extends StatefulWidget {
  final String? parentCommentId;
  final String? replyToUsername;
  final Function(String content) onSubmit;
  final VoidCallback? onCancel;
  final bool isLoading;

  const CommentInput({
    super.key,
    this.parentCommentId,
    this.replyToUsername,
    required this.onSubmit,
    this.onCancel,
    this.isLoading = false,
  });

  @override
  State<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final content = _controller.text.trim();
    if (content.isNotEmpty) {
      widget.onSubmit(content);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: EdgeInsets.only(
        left: widget.parentCommentId != null ? 32.0 : 8.0,
        right: 8.0,
        top: 4.0,
        bottom: 4.0,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.replyToUsername != null) ...[
              Text(
                'Replying to @${widget.replyToUsername}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 8),
            ],
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              maxLines: null,
              decoration: InputDecoration(
                hintText: widget.parentCommentId != null 
                    ? 'Write a reply...' 
                    : 'Write a comment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              textInputAction: TextInputAction.newline,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (widget.onCancel != null)
                  TextButton(
                    onPressed: widget.onCancel,
                    child: const Text('Cancel'),
                  ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: widget.isLoading ? null : _submit,
                  child: widget.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(widget.parentCommentId != null ? 'Reply' : 'Comment'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
