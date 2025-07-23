class ChatRoom {
  final int id;
  final String name;
  final String type;
  final String? description;
  final int? tournamentId;
  final int? teamId;
  final int? user1Id;
  final int? user2Id;
  final int createdBy;
  final bool isActive;
  final LastMessage? lastMessage;
  final DateTime lastActivity;
  final int participantCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Participant> participants;
  final User creator;
  final User? user1;
  final User? user2;
  final int? unreadCount;

  ChatRoom({
    required this.id,
    required this.name,
    this.lastMessage,
    required this.type,
    this.unreadCount,
    this.description,
    this.tournamentId,
    this.teamId,
    this.user1Id,
    this.user2Id,
    required this.createdBy,
    required this.isActive,
    required this.lastActivity,
    required this.participantCount,
    required this.createdAt,
    required this.updatedAt,
    required this.participants,
    required this.creator,
    this.user1,
    this.user2,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'] as int,
      unreadCount: (json['unread_count'] as int?) ?? 0,
      name: (json['name'] as String?) ?? '',
      type: (json['type'] as String?) ?? 'direct',
      description: json['description'] as String?,
      lastMessage: json['last_message'] != null
          ? LastMessage.fromJson(json['last_message'])
          : null,
      tournamentId: json['tournament_id'] as int?,
      teamId: json['team_id'] as int?,
      user1Id: json['user1_id'] as int?,
      user2Id: json['user2_id'] as int?,
      createdBy: json['created_by'] as int,
      isActive: (json['is_active'] as bool?) ?? true,
      lastActivity: DateTime.parse(json['last_activity'] as String),
      participantCount: (json['participant_count'] as int?) ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      participants: json['participants'] != null
          ? (json['participants'] as List)
          .map((p) => Participant.fromJson(p as Map<String, dynamic>))
          .toList()
          : [],
      creator: User.fromJson(json['creator'] as Map<String, dynamic>),
      user1: json['user1'] != null ? User.fromJson(json['user1'] as Map<String, dynamic>) : null,
      user2: json['user2'] != null ? User.fromJson(json['user2'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'unread_count': unreadCount,
      'name': name,
      'type': type,
      'description': description,
      'last_message': lastMessage?.toJson(),
      'tournament_id': tournamentId,
      'team_id': teamId,
      'user1_id': user1Id,
      'user2_id': user2Id,
      'created_by': createdBy,
      'is_active': isActive,
      'last_activity': lastActivity.toIso8601String(),
      'participant_count': participantCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'participants': participants.map((p) => p.toJson()).toList(),
      'creator': creator.toJson(),
      'user1': user1?.toJson(),
      'user2': user2?.toJson(),
    };
  }

  bool get isDirectMessage => type == 'direct';
  bool get isTeamChat => type == 'team';
  bool get isTournamentChat => type == 'tournament';

  String get displayName {
    if (isDirectMessage && user1 != null && user2 != null) {
      // Return the name of the other user (not the current user)
      return user2!.name; // You might want to adjust this based on current user
    }
    return name;
  }

  String get subtitle {
    if (isTeamChat) {
      return '$participantCount members';
    } else if (isTournamentChat) {
      return '$participantCount participants';
    }
    return 'Direct Message';
  }
}

class Participant {
  final int id;
  final int chatRoomId;
  final int userId;
  final String role;
  final DateTime joinedAt;
  final int? lastReadMessageId;
  final DateTime? lastReadAt;
  final bool isMuted;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User user;

  Participant({
    required this.id,
    required this.chatRoomId,
    required this.userId,
    required this.role,
    required this.joinedAt,
    this.lastReadMessageId,
    this.lastReadAt,
    required this.isMuted,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id'] as int,
      chatRoomId: json['chat_room_id'] as int,
      userId: json['user_id'] as int,
      role: (json['role'] as String?) ?? 'member',
      joinedAt: DateTime.parse(json['joined_at'] as String),
      lastReadMessageId: json['last_read_message_id'] as int?,
      lastReadAt: json['last_read_at'] != null
          ? DateTime.parse(json['last_read_at'] as String)
          : null,
      isMuted: (json['is_muted'] as bool?) ?? false,
      isActive: (json['is_active'] as bool?) ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_room_id': chatRoomId,
      'user_id': userId,
      'role': role,
      'joined_at': joinedAt.toIso8601String(),
      'last_read_message_id': lastReadMessageId,
      'last_read_at': lastReadAt?.toIso8601String(),
      'is_muted': isMuted,
      'is_active': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'user': user.toJson(),
    };
  }
}

class User {
  final int id;
  final String name;
  final String email;
  final String? avatarUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: (json['name'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
    };
  }

  String get initials {
    List<String> nameParts = name.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '';
  }
}
class LastMessage {
  final int id;
  final String content;
  final String messageType;
  final int senderId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User sender;

  LastMessage({
    required this.id,
    required this.content,
    required this.messageType,
    required this.senderId,
    required this.createdAt,
    required this.updatedAt,
    required this.sender,
  });

  factory LastMessage.fromJson(Map<String, dynamic> json) {
    return LastMessage(
      id: json['id'] as int,
      content: (json['content'] as String?) ?? '',
      messageType: (json['message_type'] as String?) ?? 'text',
      senderId: json['sender_id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      sender: User.fromJson(json['sender'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'message_type': messageType,
      'sender_id': senderId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'sender': sender.toJson(),
    };
  }
}