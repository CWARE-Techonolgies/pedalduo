// models/notification_model.dart
class NotificationModel {
  final int id;
  final int userId;
  final String type;
  final String title;
  final String message;
  final NotificationData data;
  final bool isRead;
  final String? readAt;
  final String priority;
  final String? actionUrl;
  final String? expiresAt;
  final int? senderId;
  final String createdAt;
  final String updatedAt;
  final NotificationSender? sender;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.data,
    required this.isRead,
    this.readAt,
    required this.priority,
    this.actionUrl,
    this.expiresAt,
    this.senderId,
    required this.createdAt,
    required this.updatedAt,
    this.sender,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      data: NotificationData.fromJson(json['data'] ?? {}),
      isRead: json['is_read'] ?? false,
      readAt: json['read_at'],
      priority: json['priority'] ?? 'medium',
      actionUrl: json['action_url'],
      expiresAt: json['expires_at'],
      senderId: json['sender_id'],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      sender: json['sender'] != null
          ? NotificationSender.fromJson(json['sender'])
          : null,
    );
  }

  NotificationModel copyWith({
    int? id,
    int? userId,
    String? type,
    String? title,
    String? message,
    NotificationData? data,
    bool? isRead,
    String? readAt,
    String? priority,
    String? actionUrl,
    String? expiresAt,
    int? senderId,
    String? createdAt,
    String? updatedAt,
    NotificationSender? sender,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      priority: priority ?? this.priority,
      actionUrl: actionUrl ?? this.actionUrl,
      expiresAt: expiresAt ?? this.expiresAt,
      senderId: senderId ?? this.senderId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sender: sender ?? this.sender,
    );
  }
}

class NotificationData {
  final String? preferenceType;
  final String? clickAction;
  final int? tournamentId;

  NotificationData({
    this.preferenceType,
    this.clickAction,
    this.tournamentId,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      preferenceType: json['preference_type'],
      clickAction: json['click_action'],
      tournamentId: json['tournament_id'],
    );
  }
}

class NotificationSender {
  final int id;
  final String name;

  NotificationSender({
    required this.id,
    required this.name,
  });

  factory NotificationSender.fromJson(Map<String, dynamic> json) {
    return NotificationSender(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class NotificationResponse {
  final List<NotificationModel> notifications;
  final NotificationPagination pagination;
  final int unreadCount;

  NotificationResponse({
    required this.notifications,
    required this.pagination,
    required this.unreadCount,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    // Handle the nested data structure
    final data = json['data'] ?? {};
    final notifications = (data['notifications'] as List? ?? [])
        .map((e) => NotificationModel.fromJson(e))
        .toList();

    final pagination = NotificationPagination.fromJson(data['pagination'] ?? {});

    // Calculate unread count from notifications
    final unreadCount = notifications.where((n) => !n.isRead).length;

    return NotificationResponse(
      notifications: notifications,
      pagination: pagination,
      unreadCount: unreadCount,
    );
  }
}

class NotificationPagination {
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final int perPage;

  NotificationPagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.perPage,
  });

  factory NotificationPagination.fromJson(Map<String, dynamic> json) {
    return NotificationPagination(
      currentPage: json['current_page'] ?? 1,
      totalPages: json['total_pages'] ?? 1,
      totalCount: json['total_count'] ?? 0,
      perPage: json['per_page'] ?? 10,
    );
  }
}