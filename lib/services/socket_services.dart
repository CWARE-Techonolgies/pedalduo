import 'dart:async';

import 'package:pedalduo/services/shared_preference_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';
import '../chat/message_model.dart';
import '../global/apis.dart';

class SocketService {
  static SocketService? _instance;
  IO.Socket? _socket;
  bool _isConnected = false;

  static SocketService get instance {
    _instance ??= SocketService._();
    return _instance!;
  }

  SocketService._();

  bool get isConnected => _isConnected && _socket?.connected == true;

  Future<void> connect() async {
    try {
      // Don't connect if already connected
      if (_socket != null && _socket!.connected) {
        _isConnected = true;
        debugPrint('🟢 Socket already connected');
        return;
      }

      final token = await SharedPreferencesService.getToken();
      if (token == null) {
        debugPrint('❌ No token found for socket connection');
        return;
      }

      // Disconnect existing socket if any
      await disconnect();

      debugPrint('🔄 Connecting to socket...');

      _socket = IO.io(
        AppApis.chatBaseUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setAuth({'token': token})
            .setTimeout(10000)
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionAttempts(5)
            .setReconnectionDelay(1000)
            .build(),
      );

      // Connection event handlers
      _socket!.onConnect((_) {
        _isConnected = true;
        debugPrint('🟢 Socket connected successfully');
      });

      _socket!.onDisconnect((reason) {
        _isConnected = false;
        debugPrint('🔴 Socket disconnected: $reason');
      });

      _socket!.onConnectError((error) {
        _isConnected = false;
        debugPrint('❌ Socket connection error: $error');
      });

      _socket!.onReconnect((attempt) {
        _isConnected = true;
        debugPrint('🟢 Socket reconnected on attempt: $attempt');
      });

      _socket!.onReconnectError((error) {
        debugPrint('❌ Socket reconnection error: $error');
      });

      // Connect
      _socket!.connect();

      // Wait for connection with timeout
      int attempts = 0;
      while (!isConnected && attempts < 20) {
        await Future.delayed(Duration(milliseconds: 250));
        attempts++;
      }

      if (!isConnected) {
        debugPrint('⏰ Socket connection timeout');
        throw Exception('Socket connection timeout');
      }

    } catch (e) {
      debugPrint('❌ Socket connection exception: $e');
      _isConnected = false;
      rethrow;
    }
  }

  Future<void> disconnect() async {
    try {
      if (_socket != null) {
        _socket!.clearListeners();
        _socket!.disconnect();
        _socket!.dispose();
        _socket = null;
      }
      _isConnected = false;
      debugPrint('🔴 Socket disconnected and disposed');
    } catch (e) {
      debugPrint('❌ Error during socket disconnect: $e');
    }
  }

  Future<void> forceReconnect() async {
    debugPrint('🔄 Force reconnecting socket...');
    await disconnect();
    await connect();
  }

  void joinRoom(int roomId) {
    if (_socket != null && isConnected) {
      _socket!.emit('join_room', {'roomId': roomId});
      debugPrint('🚪 Joined room: $roomId');
    } else {
      debugPrint('⚠️ Cannot join room: Socket not connected');
    }
  }

  void leaveRoom(int roomId) {
    if (_socket != null && isConnected) {
      _socket!.emit('leave_room', {'roomId': roomId});
      debugPrint('🚪 Left room: $roomId');
    } else {
      debugPrint('⚠️ Cannot leave room: Socket not connected');
    }
  }

  void sendMessage(int roomId, String content, {int? replyToMessageId}) {
    if (_socket != null && isConnected) {
      final messageData = {
        'roomId': roomId,
        'content': content,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      if (replyToMessageId != null) {
        messageData['replyToMessageId'] = replyToMessageId;
      }

      _socket!.emit('send_message', messageData);
      debugPrint('📤 Message sent to room $roomId: ${content.substring(0, content.length > 50 ? 50 : content.length)}...');
    } else {
      debugPrint('⚠️ Cannot send message: Socket not connected');
    }
  }

  void editMessage(int messageId, String content) {
    if (_socket != null && isConnected) {
      _socket!.emit('edit_message', {
        'messageId': messageId,
        'content': content,
      });
      debugPrint('✏️ Edit message request sent: $messageId');
    } else {
      debugPrint('⚠️ Cannot edit message: Socket not connected');
    }
  }

  void deleteMessage(int messageId) {
    if (_socket != null && isConnected) {
      _socket!.emit('delete_message', {'messageId': messageId});
      debugPrint('🗑️ Delete message request sent: $messageId');
    } else {
      debugPrint('⚠️ Cannot delete message: Socket not connected');
    }
  }

  void startTyping(int roomId) {
    if (_socket != null && isConnected) {
      _socket!.emit('typing_start', {'roomId': roomId});
    }
  }

  void stopTyping(int roomId) {
    if (_socket != null && isConnected) {
      _socket!.emit('typing_stop', {'roomId': roomId});
    }
  }

  void markMessagesRead(int roomId, int lastMessageId) {
    if (_socket != null && isConnected) {
      _socket!.emit('mark_messages_read', {
        'roomId': roomId,
        'lastMessageId': lastMessageId,
      });
      debugPrint('👁️ Marked messages read: room=$roomId, lastMsg=$lastMessageId');
    } else {
      debugPrint('⚠️ Cannot mark messages read: Socket not connected');
    }
  }

  // Global event listeners (for chat rooms list updates)
  final Map<String, List<Function>> _globalListeners = {};

  void addGlobalListener(String event, Function callback) {
    if (!_globalListeners.containsKey(event)) {
      _globalListeners[event] = [];
    }
    _globalListeners[event]!.add(callback);

    // Setup socket listener if not already setup
    if (_socket != null) {
      _socket!.off(event); // Remove existing listener to prevent duplicates
      _socket!.on(event, (data) {
        for (var callback in _globalListeners[event] ?? []) {
          try {
            if (event == 'new_message') {
              final message = Message.fromJson(data);
              callback(message);
            } else {
              callback(data);
            }
          } catch (e) {
            debugPrint('❌ Error in global listener for $event: $e');
          }
        }
      });
    }
  }

  void removeGlobalListener(String event, Function callback) {
    _globalListeners[event]?.remove(callback);
    if (_globalListeners[event]?.isEmpty == true) {
      _globalListeners.remove(event);
      _socket?.off(event);
    }
  }

  void onRoomUpdated(Function(dynamic) callback) {
    addGlobalListener('room_updated', callback);
  }

  // Chat-specific event listeners - simplified and more reliable
  void setupChatListeners({
    Function(Message)? onNewMessage,
    Function(Message)? onMessageEdited,
    Function(int)? onMessageDeleted,
    Function(int, String)? onUserTypingStart,
    Function(int)? onUserTypingStop,
    Function(Map<String, dynamic>)? onMessagesReadAck,
  }) {
    if (_socket == null) {
      debugPrint('⚠️ Cannot setup chat listeners: Socket is null');
      return;
    }

    debugPrint('🔧 Setting up chat listeners...');

    // Clear existing chat listeners to prevent duplicates
    _socket!.off('new_message');
    _socket!.off('message_edited');
    _socket!.off('message_deleted');
    _socket!.off('user_typing_start');
    _socket!.off('user_typing_stop');
    _socket!.off('messages_read_ack');

    // Setup new listeners
    if (onNewMessage != null) {
      _socket!.on('new_message', (data) {
        try {
          debugPrint('📨 Raw new message data received: $data');
          final message = Message.fromJson(data);
          onNewMessage(message);
        } catch (e) {
          debugPrint('❌ Error parsing new message: $e');
          debugPrint('❌ Raw data: $data');
        }
      });
    }

    if (onMessageEdited != null) {
      _socket!.on('message_edited', (data) {
        try {
          debugPrint('✏️ Message edited data received: $data');
          final message = Message.fromJson(data);
          onMessageEdited(message);
        } catch (e) {
          debugPrint('❌ Error parsing edited message: $e');
        }
      });
    }

    if (onMessageDeleted != null) {
      _socket!.on('message_deleted', (data) {
        try {
          debugPrint('🗑️ Message deleted data received: $data');
          final messageId = data['messageId'] as int;
          onMessageDeleted(messageId);
        } catch (e) {
          debugPrint('❌ Error parsing deleted message: $e');
        }
      });
    }

    if (onUserTypingStart != null) {
      _socket!.on('user_typing_start', (data) {
        try {
          final userId = data['userId'] as int;
          final userName = data['userName'] as String;
          onUserTypingStart(userId, userName);
        } catch (e) {
          debugPrint('❌ Error parsing typing start: $e');
        }
      });
    }

    if (onUserTypingStop != null) {
      _socket!.on('user_typing_stop', (data) {
        try {
          final userId = data['userId'] as int;
          onUserTypingStop(userId);
        } catch (e) {
          debugPrint('❌ Error parsing typing stop: $e');
        }
      });
    }

    if (onMessagesReadAck != null) {
      _socket!.on('messages_read_ack', (data) {
        try {
          debugPrint('👁️ Messages read ack data received: $data');
          onMessagesReadAck(data);
        } catch (e) {
          debugPrint('❌ Error parsing messages read ack: $e');
        }
      });
    }

    debugPrint('✅ Chat listeners setup complete');
  }

  void clearListeners() {
    if (_socket != null) {
      debugPrint('🧹 Clearing all socket listeners');
      _socket!.clearListeners();
    }
    _globalListeners.clear();
  }

  void removeAllListeners() {
    clearListeners();
  }

  // Connection health check
  Future<bool> checkConnectionHealth() async {
    if (!isConnected) return false;

    try {
      // Emit a ping and wait for response
      final completer = Completer<bool>();

      _socket!.emitWithAck('ping', {}, ack: (data) {
        completer.complete(true);
      });

      // Timeout after 3 seconds
      Timer(Duration(seconds: 3), () {
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      });

      return await completer.future;
    } catch (e) {
      debugPrint('❌ Connection health check failed: $e');
      return false;
    }
  }
}