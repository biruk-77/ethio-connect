import 'package:flutter/material.dart';
import '../../providers/comment_provider.dart';
import '../../providers/report_provider.dart';
import '../../widgets/comment_widget.dart';
import '../../widgets/report_dialog.dart';
import '../../models/comment_model.dart';
import '../../utils/app_logger.dart';

class CommentsScreen extends StatefulWidget {
  final String targetType; // 'Post' or 'Profile'
  final String targetId;
  final String? targetTitle;
  final String? postOwnerId; // For notifications
  
  const CommentsScreen({
    super.key,
    required this.targetType,
    required this.targetId,
    this.targetTitle,
    this.postOwnerId,
  });

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final CommentProvider _commentProvider = CommentProvider();
  final ReportProvider _reportProvider = ReportProvider();
  final ScrollController _scrollController = ScrollController();
  
  String? _replyToCommentId;
  String? _replyToUsername;
  String? _editCommentId;
  bool _showCommentInput = false;

  @override
  void initState() {
    super.initState();
    _commentProvider.initializeListeners();
    _loadComments();
    
    // Setup infinite scroll
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMoreComments();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _commentProvider.dispose();
    _reportProvider.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    await _commentProvider.loadComments(
      targetType: widget.targetType,
      targetId: widget.targetId,
      refresh: true,
    );
  }

  Future<void> _loadMoreComments() async {
    await _commentProvider.loadComments(
      targetType: widget.targetType,
      targetId: widget.targetId,
      refresh: false,
    );
  }

  Future<void> _submitComment(String content) async {
    final success = await _commentProvider.createComment(
      targetType: widget.targetType,
      targetId: widget.targetId,
      content: content,
      parentId: _replyToCommentId,
      postTitle: widget.targetTitle,
      postOwnerId: widget.postOwnerId,
    );

    if (success) {
      setState(() {
        _replyToCommentId = null;
        _replyToUsername = null;
        _showCommentInput = false;
      });
      AppLogger.success('✅ Comment posted');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_commentProvider.error ?? 'Failed to post comment'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _startReply(Comment comment) {
    setState(() {
      _replyToCommentId = comment.id;
      _replyToUsername = comment.author?.username;
      _showCommentInput = true;
      _editCommentId = null;
    });
  }

  void _startEdit(Comment comment) {
    setState(() {
      _editCommentId = comment.id;
      _replyToCommentId = null;
      _replyToUsername = null;
      _showCommentInput = true;
    });
  }

  void _cancelInput() {
    setState(() {
      _replyToCommentId = null;
      _replyToUsername = null;
      _editCommentId = null;
      _showCommentInput = false;
    });
  }

  void _deleteComment(Comment comment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await _commentProvider.deleteComment(comment.id);
              if (!success) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_commentProvider.error ?? 'Failed to delete comment'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _reportComment(Comment comment) {
    ReportMenuItem.handleReport(
      context,
      targetType: 'Comment',
      targetId: comment.id,
      targetTitle: comment.content.length > 50
          ? '${comment.content.substring(0, 50)}...'
          : comment.content,
      onReportSubmitted: () {
        AppLogger.info('Comment reported: ${comment.id}');
      },
    );
  }

  void _loadReplies(Comment comment) {
    _commentProvider.loadReplies(comment.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comments (${_commentProvider.comments.length})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadComments,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: AnimatedBuilder(
              animation: _commentProvider,
              builder: (context, _) {
                if (_commentProvider.isLoading && _commentProvider.comments.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (_commentProvider.error != null && _commentProvider.comments.isEmpty) {
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
                          _commentProvider.error!,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadComments,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (_commentProvider.comments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No comments yet',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Be the first to comment!',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadComments,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _commentProvider.comments.length + 
                        (_commentProvider.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= _commentProvider.comments.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final comment = _commentProvider.comments[index];
                      final replies = _commentProvider.replies[comment.id];
                      
                      return CommentWidget(
                        comment: comment,
                        replies: replies,
                        onReply: () => _startReply(comment),
                        onEdit: () => _startEdit(comment),
                        onDelete: () => _deleteComment(comment),
                        onReport: () => _reportComment(comment),
                        canEdit: true, // TODO: Check if current user is author
                        canDelete: true, // TODO: Check permissions
                      );
                    },
                  ),
                );
              },
            ),
          ),
          
          // Comment input
          if (_showCommentInput) 
            AnimatedBuilder(
              animation: _commentProvider,
              builder: (context, _) {
                return CommentInput(
                  parentCommentId: _replyToCommentId,
                  replyToUsername: _replyToUsername,
                  onSubmit: _submitComment,
                  onCancel: _cancelInput,
                  isLoading: _commentProvider.isLoading,
                );
              },
            ),
        ],
      ),
      floatingActionButton: _showCommentInput ? null : FloatingActionButton(
        onPressed: () {
          setState(() {
            _showCommentInput = true;
          });
        },
        child: const Icon(Icons.add_comment),
        tooltip: 'Add Comment',
      ),
    );
  }
}
