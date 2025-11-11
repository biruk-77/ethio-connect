import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

/// Message input bar with emoji, attachments, and voice
class MessageInputBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback? onTyping;
  final VoidCallback? onStopTyping;
  final VoidCallback? onAttachment;
  final VoidCallback? onVoice;

  const MessageInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    this.onTyping,
    this.onStopTyping,
    this.onAttachment,
    this.onVoice,
  });

  @override
  State<MessageInputBar> createState() => _MessageInputBarState();
}

class _MessageInputBarState extends State<MessageInputBar> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
      
      if (hasText) {
        widget.onTyping?.call();
      } else {
        widget.onStopTyping?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Attachment button
            if (!_hasText && widget.onAttachment != null)
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                color: AppColors.primary,
                onPressed: widget.onAttachment,
              ),
            
            // Text input
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: widget.controller,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.emoji_emotions_outlined),
                      color: Colors.grey[600],
                      onPressed: () {
                        // TODO: Show emoji picker
                      },
                    ),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) {
                    if (_hasText) widget.onSend();
                  },
                ),
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Send or Voice button
            _hasText
                ? FloatingActionButton(
                    onPressed: widget.onSend,
                    mini: true,
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.mic),
                    color: AppColors.primary,
                    onPressed: widget.onVoice,
                  ),
          ],
        ),
      ),
    );
  }
}
