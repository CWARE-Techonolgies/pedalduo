import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pedalduo/models/user_model.dart';
import 'package:pedalduo/services/shared_preference_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  // Simple message tracking
  final Set<int> _messageIds = {};

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isSending => _isSending;
  String? get error => _error;
  ChatPagination? get pagination => _pagination;
  UserModel? get currentUser => _currentUser;
  Map<int, String> get typingUsers => _typingUsers;
  int? get currentRoomId => _currentRoomId; // Add this getter

  Future<void> initializeCurrentUser() async {
    try {
      _currentUser = await SharedPreferencesService.getUserData();
      debugPrint('✅ Current user initialized: ${_currentUser?.id}');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error initializing user: $e');
      _error = 'Failed to initialize user';
      notifyListeners();
    }
  }

  Future<void> fetchMessages(
      int chatRoomId, {
        int page = 1,
        bool silent = false,
      }) async {
    debugPrint('${silent ? "🤫 Silent" : "📥"} Fetching messages for room: $chatRoomId, page: $page');

    // Handle room switching (only when not silent)
    if (!silent && _currentRoomId != chatRoomId) {
      debugPrint('🔄 Switching from room $_currentRoomId to $chatRoomId');

      if (_currentRoomId != null) {
        SocketService.instance.leaveRoom(_currentRoomId!);
      }

      _currentRoomId = chatRoomId;
      _messages.clear();
      _messageIds.clear();
      _typingUsers.clear();
    }

    if (!silent) {
      if (page == 1) {
        _isLoading = true;
        if (_currentRoomId == chatRoomId) {
          _messages.clear();
          _messageIds.clear();
        }
      } else {
        _isLoadingMore = true;
      }
      _error = null;
      notifyListeners();
    }

    try {
      await _ensureSocketConnection();

      final token = await SharedPreferencesService.getToken();
      if (token == null) throw Exception('No authentication token');

      final response = await http
          .get(
        Uri.parse(
          '${AppApis.chatBaseUrl}api/chat/rooms/$chatRoomId/messages?page=$page&limit=50',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      )
          .timeout(Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          final messageData = data['data'];
          final newMessages = (messageData['messages'] as List)
              .map((message) => Message.fromJson(message))
              .toList();

          _pagination = ChatPagination.fromJson(messageData['pagination']);

          if (page == 1 && !silent) {
            // Fresh load
            _messages = newMessages;
            _messageIds.clear();
            for (var msg in newMessages) {
              _messageIds.add(msg.id);
            }
          } else {
            // Append silently
            for (var message in newMessages) {
              if (!_messageIds.contains(message.id)) {
                _messages.insert(0, message);
                _messageIds.add(message.id);
              }
            }
          }

          _sortMessages();
          _initializedChats[chatRoomId] = true;

          debugPrint(
            '${silent ? "🤫" : "✅"} Loaded ${newMessages.length} messages, total: ${_messages.length}',
          );

          if (!silent) notifyListeners();
        } else {
          throw Exception(data['message'] ?? 'Failed to load messages');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('${silent ? "❌ Silent error" : "❌ Error"} fetching messages: $e');
      if (!silent) {
        _error = e.toString();
      }
    } finally {
      if (!silent) {
        _isLoading = false;
        _isLoadingMore = false;
        notifyListeners();
      }
    }
  }

  Future<void> _ensureSocketConnection() async {
    try {
      if (!SocketService.instance.isConnected) {
        debugPrint('🔌 Connecting socket...');
        await SocketService.instance.connect();
      }

      if (SocketService.instance.isConnected && _currentRoomId != null) {
        // Setup listeners
        _setupSocketListeners();

        // Join room
        SocketService.instance.joinRoom(_currentRoomId!);
        debugPrint('✅ Socket ready, joined room: $_currentRoomId');
      }
    } catch (e) {
      debugPrint('❌ Socket connection error: $e');
    }
  }

  void _setupSocketListeners() {
    SocketService.instance.setupChatListeners(
      onNewMessage: (message) {
        debugPrint(
          '📨 New message received: ${message.id} from ${message.senderId}',
        );

        if (message.chatRoomId == _currentRoomId) {
          // Simple duplicate check
          if (!_messageIds.contains(message.id)) {
            _messages.add(message);
            _messageIds.add(message.id);
            _sortMessages();

            // Auto mark as read if not from current user
            if (message.senderId != _currentUser?.id) {
              Timer(Duration(milliseconds: 500), () {
                if (_currentRoomId == message.chatRoomId) {
                  markMessagesAsRead(_currentRoomId!, message.id);
                }
              });
            }

            // Always notify listeners to update UI
            notifyListeners();
            debugPrint('✅ Added new message: ${message.id}');
          } else {
            debugPrint('⚠️ Duplicate message ignored: ${message.id}');
          }
        } else {
          debugPrint('⚠️ Message for different room ignored. Expected: $_currentRoomId, Got: ${message.chatRoomId}');
        }
      },

      onMessageEdited: (editedMessage) {
        debugPrint('✏️ Message edited: ${editedMessage.id}');
        if (editedMessage.chatRoomId == _currentRoomId) {
          final index = _messages.indexWhere(
                (msg) => msg.id == editedMessage.id,
          );
          if (index != -1) {
            _messages[index] = editedMessage;
            notifyListeners();
          }
        }
      },

      onMessageDeleted: (messageId) {
        debugPrint('🗑️ Message deleted: $messageId');
        _messages.removeWhere((msg) => msg.id == messageId);
        _messageIds.remove(messageId);
        notifyListeners();
      },

      onUserTypingStart: (userId, userName) {
        if (userId != _currentUser?.id) {
          _typingUsers[userId] = userName;
          notifyListeners();
        }
      },

      onUserTypingStop: (userId) {
        _typingUsers.remove(userId);
        notifyListeners();
      },

      onMessagesReadAck: (data) {
        debugPrint('👁️ Messages read ack: $data');
        // Simple implementation - just trigger UI update
        notifyListeners();
      },
    );
  }

// Modified to set the current room ID after creating chat
  Future<int?> createChatWithUser(int otherUserId) async {
    final String methodName = 'createChatWithUser';
    debugPrint('🚀 [$methodName] Starting chat creation with user: $otherUserId');

    try {
      // Clear previous error
      _error = null;
      notifyListeners();

      // Get auth token from shared preferences
      debugPrint('🔑 [$methodName] Retrieving auth token...');
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        debugPrint('❌ [$methodName] FAILURE: Authentication token not found');
        _error = 'Authentication required. Please login again.';
        notifyListeners();
        throw Exception('Authentication token not found');
      }
      debugPrint('✅ [$methodName] Auth token retrieved successfully');

      // Prepare request body
      final requestBody = json.encode({'otherUserId': otherUserId});
      debugPrint('📝 [$methodName] Request body prepared: $requestBody');

      // Make API call
      debugPrint('🌐 [$methodName] Making API call to: ${AppApis.directChatWithUser}');
      final response = await http.post(
        Uri.parse(AppApis.directChatWithUser),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: requestBody,
      );

      debugPrint('📡 [$methodName] API Response Status: ${response.statusCode}');
      debugPrint('📡 [$methodName] API Response Body: ${response.body}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          // Extract the chat room ID from response - API returns data directly, not under chatRoom
          debugPrint('🔍 [$methodName] Parsing response data structure...');
          final chatRoomData = data['data'];

          if (chatRoomData == null) {
            debugPrint('❌ [$methodName] FAILURE: Chat room data is null in response');
            throw Exception('Invalid response: missing chat room data');
          }

          final chatRoomId = chatRoomData['id'] as int?;
          if (chatRoomId == null) {
            debugPrint('❌ [$methodName] FAILURE: Chat room ID is null in response');
            throw Exception('Invalid response: missing chat room ID');
          }

          debugPrint('🎉 [$methodName] SUCCESS: Chat created with ID: $chatRoomId');

          // Set this as the current room ID
          _currentRoomId = chatRoomId;
          debugPrint('🔄 [$methodName] Current room ID updated to: $_currentRoomId');

          // Initialize socket connection for the new room
          debugPrint('🔌 [$methodName] Initializing socket connection...');
          await _ensureSocketConnection();
          debugPrint('✅ [$methodName] Socket connection ensured');

          notifyListeners();
          debugPrint('✅ [$methodName] COMPLETE: Chat creation successful');
          return chatRoomId;
        } else {
          final errorMessage = data['message'] ?? 'Unknown server error';
          debugPrint('❌ [$methodName] FAILURE: Server returned error: $errorMessage');
          _error = 'Failed to create chat: $errorMessage';
          notifyListeners();
          throw Exception('Failed to create chat: $errorMessage');
        }
      } else if (response.statusCode == 400) {
        debugPrint('❌ [$methodName] FAILURE: Bad request (400)');
        _error = 'Invalid request. Please check your input.';
        notifyListeners();
        throw Exception('Bad request: ${response.statusCode}');
      } else if (response.statusCode == 401) {
        debugPrint('❌ [$methodName] FAILURE: Unauthorized (401)');
        _error = 'Authentication failed. Please login again.';
        notifyListeners();
        throw Exception('Unauthorized: ${response.statusCode}');
      } else if (response.statusCode == 403) {
        debugPrint('❌ [$methodName] FAILURE: Forbidden (403)');
        _error = 'You don\'t have permission to create this chat.';
        notifyListeners();
        throw Exception('Forbidden: ${response.statusCode}');
      } else if (response.statusCode == 404) {
        debugPrint('❌ [$methodName] FAILURE: User not found (404)');
        _error = 'User not found. Please try again.';
        notifyListeners();
        throw Exception('User not found: ${response.statusCode}');
      } else if (response.statusCode >= 500) {
        debugPrint('❌ [$methodName] FAILURE: Server error (${response.statusCode})');
        _error = 'Server error. Please try again later.';
        notifyListeners();
        throw Exception('Server error: ${response.statusCode}');
      } else {
        debugPrint('❌ [$methodName] FAILURE: Unexpected status code: ${response.statusCode}');
        _error = 'Unexpected error occurred. Please try again.';
        notifyListeners();
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('💥 [$methodName] EXCEPTION: ${e.toString()}');
      debugPrint('📚 [$methodName] Stack trace: ${StackTrace.current}');

      if (_error == null) { // Only set error if not already set
        _error = 'Error creating chat: ${e.toString()}';
      }

      notifyListeners();
      return null;
    }
  }

// Modified sendMessage method with proper debugging
  Future<void> sendMessage(
      int chatRoomId,
      String content, {
        int? replyToMessageId,
        int? otherUserId,
      }) async {
    final String methodName = 'sendMessage';
    debugPrint('🚀 [$methodName] Starting message send process');
    debugPrint('📋 [$methodName] Parameters: chatRoomId=$chatRoomId, content="$content", replyToMessageId=$replyToMessageId, otherUserId=$otherUserId');

    // Validation checks
    if (content.trim().isEmpty) {
      debugPrint('⚠️ [$methodName] VALIDATION FAILED: Empty content');
      _error = 'Message cannot be empty';
      notifyListeners();
      return;
    }

    if (_isSending) {
      debugPrint('⚠️ [$methodName] VALIDATION FAILED: Already sending a message');
      return;
    }

    final trimmedContent = content.trim();
    debugPrint('📝 [$methodName] Message content validated: "$trimmedContent"');

    // Set sending state
    _isSending = true;
    _error = null; // Clear previous errors
    notifyListeners();
    debugPrint('🔄 [$methodName] Sending state set to true');

    try {
      int actualChatRoomId = chatRoomId;

      // Handle new chat creation if needed
      if (chatRoomId == 0 && otherUserId != null) {
        debugPrint('🆕 [$methodName] Chat room ID is 0, creating new chat with user: $otherUserId');
        final newChatRoomId = await createChatWithUser(otherUserId);

        if (newChatRoomId == null) {
          debugPrint('❌ [$methodName] FAILURE: Failed to create chat room');
          throw Exception('Failed to create chat room');
        }

        actualChatRoomId = newChatRoomId;
        debugPrint('✅ [$methodName] New chat created with ID: $actualChatRoomId');
      } else if (chatRoomId == 0 && otherUserId == null) {
        debugPrint('❌ [$methodName] FAILURE: Cannot create chat without otherUserId');
        throw Exception('Cannot send message: No chat room ID and no user ID provided');
      }

      // Ensure socket connection
      debugPrint('🔌 [$methodName] Ensuring socket connection...');
      await _ensureSocketConnection();

      if (!SocketService.instance.isConnected) {
        debugPrint('❌ [$methodName] FAILURE: Socket not connected');
        throw Exception('Not connected to server. Please check your internet connection.');
      }
      debugPrint('✅ [$methodName] Socket connection verified');

      // Send message via socket
      debugPrint('📤 [$methodName] Sending message via socket to room: $actualChatRoomId');
      SocketService.instance.sendMessage(
        actualChatRoomId,
        trimmedContent,
        replyToMessageId: replyToMessageId,
      );

      debugPrint('🎉 [$methodName] SUCCESS: Message sent successfully');
      debugPrint('📊 [$methodName] Final details: roomId=$actualChatRoomId, messageLength=${trimmedContent.length}');

    } catch (e) {
      debugPrint('💥 [$methodName] EXCEPTION: ${e.toString()}');
      debugPrint('📚 [$methodName] Stack trace: ${StackTrace.current}');

      // Set user-friendly error message
      String userFriendlyError;
      if (e.toString().contains('Authentication')) {
        userFriendlyError = 'Authentication failed. Please login again.';
      } else if (e.toString().contains('Not connected')) {
        userFriendlyError = 'Connection lost. Please check your internet connection.';
      } else if (e.toString().contains('Failed to create chat')) {
        userFriendlyError = 'Could not create chat. Please try again.';
      } else {
        userFriendlyError = 'Failed to send message. Please try again.';
      }

      _error = userFriendlyError;
      debugPrint('🚨 [$methodName] User error set: $userFriendlyError');
      notifyListeners();
      rethrow;
    } finally {
      // Always reset sending state
      _isSending = false;
      notifyListeners();
      debugPrint('🔄 [$methodName] Sending state reset to false');
      debugPrint('✅ [$methodName] COMPLETE: sendMessage method finished');
    }
  }

  void _sortMessages() {
    _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  void editMessage(int messageId, String content) {
    if (SocketService.instance.isConnected) {
      SocketService.instance.editMessage(messageId, content);
    }
  }

  void deleteMessage(int messageId) {
    if (SocketService.instance.isConnected) {
      SocketService.instance.deleteMessage(messageId);
    }
  }

  void startTyping(int roomId) {
    if (SocketService.instance.isConnected) {
      SocketService.instance.startTyping(roomId);
    }
  }

  void stopTyping(int roomId) {
    if (SocketService.instance.isConnected) {
      SocketService.instance.stopTyping(roomId);
    }
  }

  void onTypingChanged(String text, int roomId) {
    if (text.isNotEmpty) {
      startTyping(roomId);
      _typingTimer?.cancel();
      _typingTimer = Timer(Duration(seconds: 2), () => stopTyping(roomId));
    } else {
      stopTyping(roomId);
      _typingTimer?.cancel();
    }
  }

  void markMessagesAsRead(int roomId, int lastMessageId) {
    if (SocketService.instance.isConnected) {
      SocketService.instance.markMessagesRead(roomId, lastMessageId);
      debugPrint('👁️ Marked messages as read: $lastMessageId');
    }
  }

  void loadMoreMessages(int chatRoomId) {
    if (_pagination?.hasMore == true && !_isLoadingMore) {
      fetchMessages(chatRoomId, page: (_pagination?.currentPage ?? 1) + 1);
    }
  }

  void refresh(int chatRoomId) {
    debugPrint('🔄 Refreshing chat: $chatRoomId');
    _initializedChats[chatRoomId] = false;
    _error = null;
    fetchMessages(chatRoomId);
  }

  bool isCurrentUser(int senderId) {
    return _currentUser?.id == senderId;
  }

  bool isMessageRead(int messageId) {
    // Simplified - assume sent messages are read after 2 seconds
    return true;
  }

  int getMessageReadCount(int messageId) {
    return 1;
  }

  void leaveRoom() {
    if (_currentRoomId != null) {
      SocketService.instance.leaveRoom(_currentRoomId!);
      debugPrint('🚪 Left room: $_currentRoomId');
    }
    _currentRoomId = null;
    _typingUsers.clear();
    _typingTimer?.cancel();
  }

  @override
  void dispose() {
    leaveRoom();
    _typingTimer?.cancel();
    super.dispose();
  }
}