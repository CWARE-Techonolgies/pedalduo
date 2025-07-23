import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pedalduo/models/user_model.dart';
import 'package:pedalduo/services/shared_preference_service.dart';
import 'dart:convert';
import 'dart:async';
import '../global/apis.dart';
import '../services/socket_services.dart';
import 'message_model.dart';

class ChatProvider with ChangeNotifier {
  List<Message> _messages = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isSending = false;
  String? _error;
  ChatPagination? _pagination;
  final Map<int, bool> _initializedChats = {};
  UserModel? _currentUser;
  int? _currentRoomId;

  // Typing indicators
  final Map<int, String> _typingUsers = {};
  Timer? _typingTimer;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isSending => _isSending;
  String? get error => _error;
  ChatPagination? get pagination => _pagination;
  UserModel? get currentUser => _currentUser;
  Map<int, String> get typingUsers => _typingUsers;

  Future<void> initializeCurrentUser() async {
    _currentUser = await SharedPreferencesService.getUserData();
    await _initializeSocket();
    notifyListeners();
  }

  Future<void> _initializeSocket() async {
    await SocketService.instance.connect();
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    // Listen for new messages
    SocketService.instance.onNewMessage((message) {
      if (message.chatRoomId == _currentRoomId) {
        _messages.add(message);
        notifyListeners();
      }
    });

    // Listen for message edits
    SocketService.instance.onMessageEdited((editedMessage) {
      if (editedMessage.chatRoomId == _currentRoomId) {
        final index = _messages.indexWhere((msg) => msg.id == editedMessage.id);
        if (index != -1) {
          _messages[index] = editedMessage;
          notifyListeners();
        }
      }
    });

    // Listen for message deletions
    SocketService.instance.onMessageDeleted((messageId) {
      _messages.removeWhere((msg) => msg.id == messageId);
      notifyListeners();
    });

    // Listen for typing indicators
    SocketService.instance.onUserTypingStart((userId, userName) {
      if (userId != _currentUser?.id) {
        _typingUsers[userId] = userName;
        notifyListeners();
      }
    });

    SocketService.instance.onUserTypingStop((userId) {
      _typingUsers.remove(userId);
      notifyListeners();
    });
  }

  Future<void> fetchMessages(int chatRoomId, {int page = 1}) async {
    if (_initializedChats[chatRoomId] == true && page == 1) return;

    // Set current room and join socket room
    _currentRoomId = chatRoomId;
    SocketService.instance.joinRoom(chatRoomId);

    if (page == 1) {
      _isLoading = true;
      _messages.clear();
    } else {
      _isLoadingMore = true;
    }

    _error = null;
    notifyListeners();

    try {
      final token = await SharedPreferencesService.getToken();
      if (token == null) {
        _error = 'Authentication required';
        _isLoading = false;
        _isLoadingMore = false;
        notifyListeners();
        return;
      }

      final response = await http.get(
        Uri.parse(
          '${AppApis.chatBaseUrl}api/chat/rooms/$chatRoomId/messages?page=$page&limit=50',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          final messageData = data['data'];
          final newMessages =
              (messageData['messages'] as List)
                  .map((message) => Message.fromJson(message))
                  .toList();

          _pagination = ChatPagination.fromJson(messageData['pagination']);

          if (page == 1) {
            _messages = newMessages;
            _initializedChats[chatRoomId] = true;
          } else {
            _messages.insertAll(0, newMessages.reversed.toList());
          }
        } else {
          _error = 'Failed to load messages';
        }
      } else {
        _error = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Network error: $e');
      }
      _error = 'Network error: $e';
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(
    int chatRoomId,
    String content, {
    int? replyToMessageId,
  }) async {
    if (content.trim().isEmpty) return;

    _isSending = true;
    notifyListeners();

    try {
      // Send via socket for real-time delivery
      SocketService.instance.sendMessage(
        chatRoomId,
        content,
        replyToMessageId: replyToMessageId,
      );
    } catch (e) {
      _error = 'Failed to send message: $e';
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  void editMessage(int messageId, String content) {
    SocketService.instance.editMessage(messageId, content);
  }

  void deleteMessage(int messageId) {
    SocketService.instance.deleteMessage(messageId);
  }

  void startTyping(int roomId) {
    SocketService.instance.startTyping(roomId);
  }

  void stopTyping(int roomId) {
    SocketService.instance.stopTyping(roomId);
  }

  void onTypingChanged(String text, int roomId) {
    if (text.isNotEmpty) {
      startTyping(roomId);

      // Reset typing timer
      _typingTimer?.cancel();
      _typingTimer = Timer(Duration(seconds: 2), () {
        stopTyping(roomId);
      });
    } else {
      stopTyping(roomId);
      _typingTimer?.cancel();
    }
  }

  void markMessagesAsRead(int roomId, int lastMessageId) {
    SocketService.instance.markMessagesRead(roomId, lastMessageId);
  }

  void loadMoreMessages(int chatRoomId) {
    if (_pagination?.hasMore == true && !_isLoadingMore) {
      fetchMessages(chatRoomId, page: (_pagination?.currentPage ?? 1) + 1);
    }
  }

  void refresh(int chatRoomId) {
    _initializedChats[chatRoomId] = false;
    fetchMessages(chatRoomId);
  }

  bool isCurrentUser(int senderId) {
    return _currentUser?.id == senderId;
  }

  void leaveRoom() {
    if (_currentRoomId != null) {
      SocketService.instance.leaveRoom(_currentRoomId!);
      _currentRoomId = null;
      _typingUsers.clear();
      _typingTimer?.cancel();
    }
  }

  @override
  void dispose() {
    leaveRoom();
    _typingTimer?.cancel();
    super.dispose();
  }
}
