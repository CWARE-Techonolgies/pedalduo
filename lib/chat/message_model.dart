// models/message.dart
import 'chat_room.dart';

class Message {
  final int id;
  final int chatRoomId;
  final int senderId;
  final String content;
  final String messageType;
  final String? attachmentUrl;
  final int? replyToMessageId;
  final bool isEdited;
  final DateTime? editedAt;
  final bool isDeleted;
  final DateTime? deletedAt;
  final List<int> readBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User sender;
  final Message? repliedMessage;

  Message({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.content,
    required this.messageType,
    this.attachmentUrl,
    this.replyToMessageId,
    required this.isEdited,
    this.editedAt,
    required this.isDeleted,
    this.deletedAt,
    required this.readBy,
    required this.createdAt,
    required this.updatedAt,
    required this.sender,
    this.repliedMessage,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as int,
      chatRoomId: json['chat_room_id'] as int,
      senderId: json['sender_id'] as int,
      content: (json['content'] as String?) ?? '', // Handle null content
      messageType:
          (json['message_type'] as String?) ??
          'text', // Handle null message_type
      attachmentUrl: json['attachment_url'] as String?,
      replyToMessageId: json['reply_to_message_id'] as int?,
      isEdited: (json['is_edited'] as bool?) ?? false,
      editedAt:
          json['edited_at'] != null
              ? DateTime.parse(json['edited_at'] as String)
              : null,
      isDeleted: (json['is_deleted'] as bool?) ?? false,
      deletedAt:
          json['deleted_at'] != null
              ? DateTime.parse(json['deleted_at'] as String)
              : null,
      readBy: List<int>.from(json['read_by'] ?? []), // Handle null read_by
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      sender: User.fromJson(json['sender'] as Map<String, dynamic>),
      repliedMessage:
          json['replied_message'] != null
              ? Message.fromJson(
                json['replied_message'] as Map<String, dynamic>,
              )
              : null,
    );
  }

  // Convert to JSON for sending to API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_room_id': chatRoomId,
      'sender_id': senderId,
      'content': content,
      'message_type': messageType,
      'attachment_url': attachmentUrl,
      'reply_to_message_id': replyToMessageId,
      'is_edited': isEdited,
      'edited_at': editedAt?.toIso8601String(),
      'is_deleted': isDeleted,
      'deleted_at': deletedAt?.toIso8601String(),
      'read_by': readBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'sender': sender.toJson(),
      'replied_message': repliedMessage?.toJson(),
    };
  }

  bool get isText => messageType == 'text';
  bool get isImage => messageType == 'image';
  bool get isFile => messageType == 'file';
  bool get hasAttachment => attachmentUrl != null;
  bool get isReply => replyToMessageId != null;
}

class ChatPagination {
  final int currentPage;
  final int totalPages;
  final int totalMessages;
  final bool hasMore;

  ChatPagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalMessages,
    required this.hasMore,
  });

  factory ChatPagination.fromJson(Map<String, dynamic> json) {
    return ChatPagination(
      currentPage: json['currentPage'] as int,
      totalPages: json['totalPages'] as int,
      totalMessages: json['totalMessages'] as int,
      hasMore: json['hasMore'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPage': currentPage,
      'totalPages': totalPages,
      'totalMessages': totalMessages,
      'hasMore': hasMore,
    };
  }
}
