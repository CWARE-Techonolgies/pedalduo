import 'dart:async';
import 'dart:io'; // Add this import

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pedalduo/chat/chat_room.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../global/apis.dart';
import '../services/shared_preference_service.dart';
import '../services/socket_services.dart';
import 'message_model.dart';

class ChatRoomsProvider with ChangeNotifier {
  List<ChatRoom> _chatRooms = [];
  bool _isLoading = false;
  String? _error;
  String? _friendlyError; // Add this for user-friendly error messages
  bool _hasInitialized = false;

  // Getters
  List<ChatRoom> get chatRooms => _chatRooms;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get friendlyError => _friendlyError; // Add this getter
  bool get hasInitialized => _hasInitialized;

  // Filtered lists
  List<ChatRoom> get directMessages =>
      _chatRooms.where((room) => room.type == 'direct').toList();

  List<ChatRoom> get teamChats =>
      _chatRooms.where((room) => room.type == 'team').toList();

  List<ChatRoom> get tournamentChats =>
      _chatRooms.where((room) => room.type == 'tournament').toList();

  // Global message listener reference for cleanup
  Function(Message)? _messageListener;

  // Helper method to convert technical errors to user-friendly messages
  String _getFriendlyErrorMessage(String technicalError) {
    final errorLower = technicalError.toLowerCase();

    if (errorLower.contains('socketexception') ||
        errorLower.contains('failed host lookup') ||
        errorLower.contains('network is unreachable') ||
        errorLower.contains('no address associated with hostname')) {
      return 'No internet connection';
    } else if (errorLower.contains('timeout') || errorLower.contains('timed out')) {
      return 'Connection timeout';
    } else if (errorLower.contains('401') || errorLower.contains('unauthorized')) {
      return 'Session expired';
    } else if (errorLower.contains('403') || errorLower.contains('forbidden')) {
      return 'Access denied';
    } else if (errorLower.contains('404') || errorLower.contains('not found')) {
      return 'Service unavailable';
    } else if (errorLower.contains('500') || errorLower.contains('server error')) {
      return 'Server error';
    } else if (errorLower.contains('connection refused') ||
        errorLower.contains('connection failed')) {
      return 'Connection failed';
    } else if (errorLower.contains('authentication token not found')) {
      return 'Authentication required';
    } else {
      return 'Something went wrong';
    }
  }

  Future<void> fetchChatRooms({bool showLoader = true}) async {
    if (_hasInitialized && showLoader) return;

    if (showLoader) {
      _isLoading = true;
      _error = null;
      _friendlyError = null; // Clear friendly error too
      notifyListeners();
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final response = await http
          .get(
        Uri.parse(AppApis.chatRooms),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      )
          .timeout(Duration(seconds: 15)); // Increased timeout

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          _chatRooms = (data['data'] as List)
              .map((room) => ChatRoom.fromJson(room))
              .toList();
          debugPrint('the loaded data is $data');
          // Sort by last activity (most recent first)
          _sortRooms();
          _hasInitialized = true;

          // Setup socket listeners after successful fetch
          _setupSocketListeners();
        } else {
          throw Exception('Failed to load chat rooms');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
      _friendlyError = _getFriendlyErrorMessage(e.toString()); // Set friendly error
      debugPrint('Error fetching chat rooms: $e');
    } finally {
      if (showLoader) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  int get totalUnreadMessages {
    return _chatRooms.fold(0, (sum, room) => sum + (room.unreadCount ?? 0));
  }

  Timer? _timer;
  void startPeriodicRefresh() {
    // Cancel any existing timer
    _timer?.cancel();

    // Start new timer
    _timer = Timer.periodic(const Duration(milliseconds: 2000), (timer) {
      silentRefresh();
    });
  }

  int? _currentUserId;

  int? get currentUserId => _currentUserId;

  Future<void> initializeCurrentUser() async {
    try {
      _currentUserId = await SharedPreferencesService.getUserId();
      notifyListeners();
    } catch (e) {
      debugPrint('Error getting current user ID: $e');
    }
  }

  void _setupSocketListeners() {
    // Remove existing listener if any
    if (_messageListener != null) {
      SocketService.instance.removeGlobalListener(
        'new_message',
        _messageListener!,
      );
    }

    // Setup new message listener
    _messageListener = (Message message) {
      _updateChatRoomWithNewMessage(message);
    };

    SocketService.instance.addGlobalListener('new_message', _messageListener!);
    debugPrint('Socket listeners setup for ChatRoomsProvider');
  }

  void _updateChatRoomWithNewMessage(Message message) {
    final roomIndex = _chatRooms.indexWhere(
          (room) => room.id == message.chatRoomId,
    );

    if (roomIndex != -1) {
      // Create updated chat room
      final currentRoom = _chatRooms[roomIndex];
      final updatedRoom = currentRoom.copyWith(
        lastMessage: LastMessage(
          id: message.id,
          content: message.content,
          messageType: message.messageType,
          senderId: message.senderId,
          createdAt: message.createdAt,
          updatedAt: message.updatedAt,
          sender: message.sender,
        ),
        lastActivity: message.createdAt,
        updatedAt: DateTime.now(),
      );

      _chatRooms[roomIndex] = updatedRoom;
      _sortRooms();

      debugPrint('Updated chat room ${updatedRoom.name} with new message');
      notifyListeners();
    } else {
      // If room not found, refresh the list
      debugPrint('Room ${message.chatRoomId} not found, refreshing list');
      refresh();
    }
  }
  int get unreadDirectMessagesCount {
    return _chatRooms
        .where((room) => room.type == 'direct' && (room.unreadCount ?? 0) > 0)
        .length;
  }

  int get unreadTeamChatsCount {
    return _chatRooms
        .where((room) => room.type == 'team' && (room.unreadCount ?? 0) > 0)
        .length;
  }

  int get unreadTournamentChatsCount {
    return _chatRooms
        .where((room) => room.type == 'tournament' && (room.unreadCount ?? 0) > 0)
        .length;
  }

  int get unreadGroupChatsCount {
    return unreadTeamChatsCount + unreadTournamentChatsCount;
  }
  void _sortRooms() {
    _chatRooms.sort((a, b) => b.lastActivity.compareTo(a.lastActivity));
  }

  Map<String, String> getLastMessageWithSender(ChatRoom chatRoom, int currentUserId) {
    if (chatRoom.lastMessage == null) {
      return {'message': 'Start New Conversation', 'sender': ''};
    }

    final lastMessage = chatRoom.lastMessage!;
    final messageContent = lastMessage.content;

    // Direct message - show "Me:" for current user, nothing for other user
    if (chatRoom.type == 'direct') {
      if (lastMessage.senderId == currentUserId) {
        return {'message': messageContent, 'sender': 'Me'};
      } else {
        return {'message': messageContent, 'sender': ''};
      }
    }

    // Team or Tournament chat - show sender name
    String senderName;

    if (lastMessage.senderId == currentUserId) {
      senderName = 'You';
    } else {
      // Get sender name from lastMessage.sender or participants
      senderName = lastMessage.sender.name;
        }

    return {'message': messageContent, 'sender': senderName};
  }


  Future<void> markMessagesAsRead(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('No auth token found');
      }

      final response = await http.post(
        Uri.parse('${AppApis.chatBaseUrl}api/chat/rooms/$id/read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({}),
      );

      if (response.statusCode == 200) {
        // Update unread count locally
        final roomIndex = _chatRooms.indexWhere(
              (room) => room.id.toString() == id,
        );
        if (roomIndex != -1) {
          _chatRooms[roomIndex] = _chatRooms[roomIndex].copyWith(
            unreadCount: 0,
          );
          notifyListeners();
        }
        debugPrint('Messages marked as read successfully');
      } else {
        debugPrint('Failed to mark messages as read: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
    }
  }

  // Updated refresh method to properly reset state
  void refresh() {
    _hasInitialized = false;
    _error = null;
    _friendlyError = null;
    fetchChatRooms(showLoader: true); // Changed to show loader for manual refresh
  }

  void silentRefresh() {
    if (!_isLoading) { // Prevent multiple simultaneous requests
      fetchChatRooms(showLoader: false);
    }
  }

  void setLoading() {
    _isLoading = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    // Clean up socket listeners
    if (_messageListener != null) {
      SocketService.instance.removeGlobalListener(
        'new_message',
        _messageListener!,
      );
    }
    super.dispose();
  }
}

extension ChatRoomCopyWith on ChatRoom {
  ChatRoom copyWith({
    int? id,
    String? name,
    String? type,
    String? description,
    int? tournamentId,
    int? teamId,
    int? user1Id,
    int? user2Id,
    int? createdBy,
    bool? isActive,
    LastMessage? lastMessage,
    DateTime? lastActivity,
    int? participantCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Participant>? participants, // 👈 match model's type
    User? creator,
    User? user1,
    User? user2,
    int? unreadCount,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      tournamentId: tournamentId ?? this.tournamentId,
      teamId: teamId ?? this.teamId,
      user1Id: user1Id ?? this.user1Id,
      user2Id: user2Id ?? this.user2Id,
      createdBy: createdBy ?? this.createdBy,
      isActive: isActive ?? this.isActive,
      lastMessage: lastMessage ?? this.lastMessage,
      lastActivity: lastActivity ?? this.lastActivity,
      participantCount: participantCount ?? this.participantCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      participants: participants ?? this.participants, // ✅ fixed
      creator: creator ?? this.creator,
      user1: user1 ?? this.user1,
      user2: user2 ?? this.user2,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}