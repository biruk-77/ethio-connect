import 'package:flutter/material.dart';
import '../services/enhanced_notification_service.dart';
import '../services/user_status_service.dart';
import '../services/room_management_service.dart';
import '../theme/app_colors.dart';

/// Enhanced Navigation Bar with Real-Time Communication Features
class EnhancedNavigationBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  
  const EnhancedNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<EnhancedNavigationBar> createState() => _EnhancedNavigationBarState();
}

class _EnhancedNavigationBarState extends State<EnhancedNavigationBar> {
  final EnhancedNotificationService _notificationService = EnhancedNotificationService();
  final UserStatusService _statusService = UserStatusService();
  final RoomManagementService _roomService = RoomManagementService();
  
  int _unreadNotifications = 0;
  String _userStatus = 'offline';

  @override
  void initState() {
    super.initState();
    _setupListeners();
  }

  void _setupListeners() {
    // Listen for notification count updates
    _notificationService.unreadCountStream.listen((data) {
      if (mounted) {
        setState(() {
          _unreadNotifications = data['total'] ?? 0;
        });
      }
    });

    // Listen for user status changes
    _statusService.onStatusUpdated((data) {
      if (mounted) {
        setState(() {
          _userStatus = data['status'] ?? 'offline';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: widget.currentIndex,
        onTap: widget.onTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: [
          // Home
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          
          // Messages with Room Status
          BottomNavigationBarItem(
            icon: _buildMessagesIcon(),
            label: 'Messages',
          ),
          
          // Notifications with Unread Count
          BottomNavigationBarItem(
            icon: _buildNotificationIcon(),
            label: 'Notifications',
          ),
          
          // Favorites
          const BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          
          // Profile with Status
          BottomNavigationBarItem(
            icon: _buildProfileIcon(),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesIcon() {
    final roomStatus = _roomService.getRoomStatus();
    final activeRooms = roomStatus['totalRooms'] as int? ?? 0;
    
    return Stack(
      children: [
        const Icon(Icons.message),
        if (activeRooms > 0)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(6),
              ),
              constraints: const BoxConstraints(
                minWidth: 12,
                minHeight: 12,
              ),
              child: Text(
                '$activeRooms',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNotificationIcon() {
    return Stack(
      children: [
        const Icon(Icons.notifications),
        if (_unreadNotifications > 0)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(6),
              ),
              constraints: const BoxConstraints(
                minWidth: 12,
                minHeight: 12,
              ),
              child: Text(
                _unreadNotifications > 99 ? '99+' : '$_unreadNotifications',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileIcon() {
    return Stack(
      children: [
        const Icon(Icons.person),
        // Status indicator
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getStatusColor(),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1),
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (_userStatus) {
      case 'online':
        return Colors.green;
      case 'away':
        return Colors.orange;
      case 'busy':
        return Colors.red;
      case 'offline':
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    // Cleanup is handled by the services themselves
    super.dispose();
  }
}
