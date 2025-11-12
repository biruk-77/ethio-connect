import 'dart:async';
import '../utils/app_logger.dart';
import 'socket_service.dart';

/// Room Management Service - Handles automatic room joining/leaving
/// Based on Abel's backend room management system
class RoomManagementService {
  static final RoomManagementService _instance = RoomManagementService._internal();
  factory RoomManagementService() => _instance;
  RoomManagementService._internal();

  final SocketService _socketService = SocketService();
  
  // Track currently joined rooms to avoid duplicates
  final Set<String> _joinedPostRooms = {};
  final Set<String> _joinedUserRooms = {};
  final Set<String> _joinedConversationRooms = {};

  /// Initialize room management listeners
  void initialize() {
    // Listen for successful room joins
    _socketService.on('room:joined', (data) {
      final roomType = data['roomType'];
      final roomId = data['roomId'];
      AppLogger.success('✅ Joined room: $roomType:$roomId');
      
      // Track joined rooms
      switch (roomType) {
        case 'post':
          _joinedPostRooms.add(roomId);
          break;
        case 'user':
          _joinedUserRooms.add(roomId);
          break;
        case 'conversation':
          _joinedConversationRooms.add(roomId);
          break;
      }
    });

    // Listen for room leave confirmations
    _socketService.on('room:left', (data) {
      final roomType = data['roomType'];
      final roomId = data['roomId'];
      AppLogger.info('👋 Left room: $roomType:$roomId');
      
      // Remove from tracking
      switch (roomType) {
        case 'post':
          _joinedPostRooms.remove(roomId);
          break;
        case 'user':
          _joinedUserRooms.remove(roomId);
          break;
        case 'conversation':
          _joinedConversationRooms.remove(roomId);
          break;
      }
    });

    AppLogger.info('🏠 Room Management Service initialized');
  }

  /// Auto-join post room (with duplicate prevention)
  void joinPostRoomIfNeeded(String postId) {
    if (!_joinedPostRooms.contains(postId)) {
      _socketService.joinPostRoom(postId);
    }
  }

  /// Auto-join user room (with duplicate prevention)
  void joinUserRoomIfNeeded(String userId) {
    if (!_joinedUserRooms.contains(userId)) {
      _socketService.joinUserRoom(userId);
    }
  }

  /// Auto-join conversation room (with duplicate prevention)
  void joinConversationRoomIfNeeded(String conversationId) {
    if (!_joinedConversationRooms.contains(conversationId)) {
      _socketService.joinConversationRoom(conversationId);
    }
  }

  /// Leave post room safely
  void leavePostRoomIfJoined(String postId) {
    if (_joinedPostRooms.contains(postId)) {
      _socketService.leavePostRoom(postId);
    }
  }

  /// Leave user room safely
  void leaveUserRoomIfJoined(String userId) {
    if (_joinedUserRooms.contains(userId)) {
      _socketService.leaveUserRoom(userId);
    }
  }

  /// Leave conversation room safely
  void leaveConversationRoomIfJoined(String conversationId) {
    if (_joinedConversationRooms.contains(conversationId)) {
      _socketService.leaveConversationRoom(conversationId);
    }
  }

  /// Smart room management for screen navigation
  void onScreenEntered({
    String? postId,
    String? userId,
    String? conversationId,
  }) {
    if (postId != null) joinPostRoomIfNeeded(postId);
    if (userId != null) joinUserRoomIfNeeded(userId);
    if (conversationId != null) joinConversationRoomIfNeeded(conversationId);
  }

  /// Smart room management for screen exit
  void onScreenExited({
    String? postId,
    String? userId,
    String? conversationId,
  }) {
    if (postId != null) leavePostRoomIfJoined(postId);
    if (userId != null) leaveUserRoomIfJoined(userId);
    if (conversationId != null) leaveConversationRoomIfJoined(conversationId);
  }

  /// Cleanup all rooms (call on logout)
  void cleanup() {
    AppLogger.info('🧹 Cleaning up all rooms');
    _socketService.leaveAllRooms();
    _joinedPostRooms.clear();
    _joinedUserRooms.clear();
    _joinedConversationRooms.clear();
  }

  /// Get current room status
  Map<String, dynamic> getRoomStatus() {
    return {
      'postRooms': _joinedPostRooms.toList(),
      'userRooms': _joinedUserRooms.toList(),
      'conversationRooms': _joinedConversationRooms.toList(),
      'totalRooms': _joinedPostRooms.length + _joinedUserRooms.length + _joinedConversationRooms.length,
    };
  }

  /// Dispose resources
  void dispose() {
    cleanup();
    _socketService.off('room:joined');
    _socketService.off('room:left');
  }
}
