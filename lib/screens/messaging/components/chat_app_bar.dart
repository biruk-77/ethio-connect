import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

/// Custom chat screen app bar with avatar, name, and status
class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String username;
  final String? photoURL;
  final String? status; // 'online', 'offline', 'typing'
  final VoidCallback? onTap;
  final List<Widget>? actions;

  const ChatAppBar({
    super.key,
    required this.username,
    this.photoURL,
    this.status,
    this.onTap,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leadingWidth: 40,
      title: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary,
                  backgroundImage: photoURL != null
                      ? NetworkImage(photoURL!)
                      : null,
                  child: photoURL == null
                      ? Text(
                          username[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                // Online indicator
                if (status == 'online')
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    username,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (status != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      _getStatusText(),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getStatusColor(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      actions: actions ?? [
        IconButton(
          icon: const Icon(Icons.videocam_outlined),
          onPressed: () {
            // TODO: Video call
          },
        ),
        IconButton(
          icon: const Icon(Icons.call_outlined),
          onPressed: () {
            // TODO: Voice call
          },
        ),
        PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view_profile',
              child: Text('View Profile'),
            ),
            const PopupMenuItem(
              value: 'mute',
              child: Text('Mute Notifications'),
            ),
            const PopupMenuItem(
              value: 'block',
              child: Text('Block User'),
            ),
            const PopupMenuItem(
              value: 'clear',
              child: Text('Clear Chat'),
            ),
          ],
          onSelected: (value) {
            // TODO: Handle menu actions
          },
        ),
      ],
    );
  }

  String _getStatusText() {
    switch (status) {
      case 'online':
        return 'Online';
      case 'typing':
        return 'typing...';
      case 'away':
        return 'Away';
      default:
        return 'Offline';
    }
  }

  Color _getStatusColor() {
    switch (status) {
      case 'online':
        return Colors.green;
      case 'typing':
        return Colors.blue;
      case 'away':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
