
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

  bool get isConnected => _isConnected;

  Future<void> connect() async {
    if (_socket != null && _isConnected) return;

    final token = await SharedPreferencesService.getToken();
    if (token == null) {
      debugPrint('No token found for socket connection');
      return;
    }

    _socket = IO.io(
      AppApis.chatBaseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );

    _socket!.onConnect((_) {
      _isConnected = true;
      debugPrint('Socket connected');
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      debugPrint('Socket disconnected');
    });

    _socket!.onConnectError((error) {
      _isConnected = false;
      debugPrint('Socket connection error: $error');
    });

    _socket!.connect();
  }

  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
    }
  }

  // Room management
  void joinRoom(int roomId) {
    if (_socket != null && _isConnected) {
      _socket!.emit('join_room', {'roomId': roomId});
      debugPrint('Joined room: $roomId');
    }
  }

  void leaveRoom(int roomId) {
    if (_socket != null && _isConnected) {
      _socket!.emit('leave_room', {'roomId': roomId});
      debugPrint('Left room: $roomId');
    }
  }

  // Message operations
  void sendMessage(int roomId, String content, {int? replyToMessageId}) {
    if (_socket != null && _isConnected) {
      _socket!.emit('send_message', {
        'roomId': roomId,
        'content': content,
        'replyToMessageId': replyToMessageId,
      });
    }
  }

  void editMessage(int messageId, String content) {
    if (_socket != null && _isConnected) {
      _socket!.emit('edit_message', {
        'messageId': messageId,
        'content': content,
      });
    }
  }

  void deleteMessage(int messageId) {
    if (_socket != null && _isConnected) {
      _socket!.emit('delete_message', {'messageId': messageId});
    }
  }

  // Typing indicators
  void startTyping(int roomId) {
    if (_socket != null && _isConnected) {
      _socket!.emit('typing_start', {'roomId': roomId});
    }
  }

  void stopTyping(int roomId) {
    if (_socket != null && _isConnected) {
      _socket!.emit('typing_stop', {'roomId': roomId});
    }
  }

  // Mark messages as read
  void markMessagesRead(int roomId, int lastMessageId) {
    if (_socket != null && _isConnected) {
      _socket!.emit('mark_messages_read', {
        'roomId': roomId,
        'lastMessageId': lastMessageId,
      });
    }
  }

  // Event listeners
  void onNewMessage(Function(Message) callback) {
    if (_socket != null) {
      _socket!.on('new_message', (data) {
        final message = Message.fromJson(data);
        callback(message);
      });
    }
  }

  void onMessageEdited(Function(Message) callback) {
    if (_socket != null) {
      _socket!.on('message_edited', (data) {
        final message = Message.fromJson(data);
        callback(message);
      });
    }
  }

  void onMessageDeleted(Function(int) callback) {
    if (_socket != null) {
      _socket!.on('message_deleted', (data) {
        final messageId = data['messageId'] as int;
        callback(messageId);
      });
    }
  }

  void onUserTypingStart(Function(int, String) callback) {
    if (_socket != null) {
      _socket!.on('user_typing_start', (data) {
        final userId = data['userId'] as int;
        final userName = data['userName'] as String;
        callback(userId, userName);
      });
    }
  }

  void onUserTypingStop(Function(int) callback) {
    if (_socket != null) {
      _socket!.on('user_typing_stop', (data) {
        final userId = data['userId'] as int;
        callback(userId);
      });
    }
  }

  void onUserJoinedRoom(Function(Map<String, dynamic>) callback) {
    if (_socket != null) {
      _socket!.on('user_joined_room', (data) {
        callback(data);
      });
    }
  }

  void onUserLeftRoom(Function(Map<String, dynamic>) callback) {
    if (_socket != null) {
      _socket!.on('user_left_room', (data) {
        callback(data);
      });
    }
  }
  void onRoomUpdated(Function(Map<String, dynamic>) callback) {
    print('onRoomUpdated method called, socket status: ${_socket != null ? "exists" : "null"}, connected: $_isConnected');

    if (_socket != null) {
      // Remove existing listener first to avoid duplicates
      _socket!.off('room_updated');

      _socket!.on('room_updated', (data) {
        print('room_updated event received: $data');
        callback(data);
      });

      print('room_updated listener set up successfully');
    } else {
      print('Socket is null, cannot set up room_updated listener');
    }
  }

  // Remove all listeners
  void removeAllListeners() {
    if (_socket != null) {
      _socket!.clearListeners();
    }
  }
}