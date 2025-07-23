class NotificationSettingsModel {
  final int id;
  final int userId;
  final bool emailEnabled;
  final bool pushEnabled;
  final bool smsEnabled;
  final Map<String, bool> tournamentUpdates;
  final Map<String, bool> matchNotifications;
  final Map<String, bool> teamUpdates;
  final Map<String, bool> paymentConfirmations;
  final Map<String, bool> chatMessages;
  final Map<String, bool> generalAnnouncements;
  final Map<String, bool> marketingUpdates;
  final bool quietHoursEnabled;
  final String quietHoursStart;
  final String quietHoursEnd;
  final String timezone;

  NotificationSettingsModel({
    required this.id,
    required this.userId,
    required this.emailEnabled,
    required this.pushEnabled,
    required this.smsEnabled,
    required this.tournamentUpdates,
    required this.matchNotifications,
    required this.teamUpdates,
    required this.paymentConfirmations,
    required this.chatMessages,
    required this.generalAnnouncements,
    required this.marketingUpdates,
    required this.quietHoursEnabled,
    required this.quietHoursStart,
    required this.quietHoursEnd,
    required this.timezone,
  });

  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsModel(
      id: json['id'],
      userId: json['user_id'],
      emailEnabled: json['email_enabled'],
      pushEnabled: json['push_enabled'],
      smsEnabled: json['sms_enabled'],
      tournamentUpdates: Map<String, bool>.from(json['tournament_updates']),
      matchNotifications: Map<String, bool>.from(json['match_notifications']),
      teamUpdates: Map<String, bool>.from(json['team_updates']),
      paymentConfirmations: Map<String, bool>.from(json['payment_confirmations']),
      chatMessages: Map<String, bool>.from(json['chat_messages']),
      generalAnnouncements: Map<String, bool>.from(json['general_announcements']),
      marketingUpdates: Map<String, bool>.from(json['marketing_updates']),
      quietHoursEnabled: json['quiet_hours_enabled'],
      quietHoursStart: json['quiet_hours_start'],
      quietHoursEnd: json['quiet_hours_end'],
      timezone: json['timezone'],
    );
  }

  NotificationSettingsModel copyWith({
    int? id,
    int? userId,
    bool? emailEnabled,
    bool? pushEnabled,
    bool? smsEnabled,
    Map<String, bool>? tournamentUpdates,
    Map<String, bool>? matchNotifications,
    Map<String, bool>? teamUpdates,
    Map<String, bool>? paymentConfirmations,
    Map<String, bool>? chatMessages,
    Map<String, bool>? generalAnnouncements,
    Map<String, bool>? marketingUpdates,
    bool? quietHoursEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
    String? timezone,
  }) {
    return NotificationSettingsModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      smsEnabled: smsEnabled ?? this.smsEnabled,
      tournamentUpdates: tournamentUpdates ?? this.tournamentUpdates,
      matchNotifications: matchNotifications ?? this.matchNotifications,
      teamUpdates: teamUpdates ?? this.teamUpdates,
      paymentConfirmations: paymentConfirmations ?? this.paymentConfirmations,
      chatMessages: chatMessages ?? this.chatMessages,
      generalAnnouncements: generalAnnouncements ?? this.generalAnnouncements,
      marketingUpdates: marketingUpdates ?? this.marketingUpdates,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      timezone: timezone ?? this.timezone,
    );
  }
}