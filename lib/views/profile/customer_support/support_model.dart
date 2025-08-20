// models/support_ticket.dart
import 'package:flutter/material.dart';
class SupportTicket {
  final int id;
  final int userId;
  final String ticketNumber;
  final String subject;
  final String description;
  final String category;
  final String priority;
  final String status;
  final int? assignedTo;
  final String? resolution;
  final DateTime? resolvedAt;
  final DateTime? closedAt;
  final List<String>? attachments;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? user;
  final Admin? assignedAdmin;
  final List<TicketMessage> messages;

  SupportTicket({
    required this.id,
    required this.userId,
    required this.ticketNumber,
    required this.subject,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    this.assignedTo,
    this.resolution,
    this.resolvedAt,
    this.closedAt,
    this.attachments,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.assignedAdmin,
    this.messages = const [],
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['id'],
      userId: json['user_id'],
      ticketNumber: json['ticket_number'],
      subject: json['subject'],
      description: json['description'],
      category: json['category'],
      priority: json['priority'],
      status: json['status'],
      assignedTo: json['assigned_to'],
      resolution: json['resolution'],
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'])
          : null,
      closedAt: json['closed_at'] != null
          ? DateTime.parse(json['closed_at'])
          : null,
      attachments: json['attachments'] != null
          ? List<String>.from(json['attachments'])
          : null,
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      assignedAdmin: json['assigned_admin'] != null
          ? Admin.fromJson(json['assigned_admin'])
          : null,
      messages: json['messages'] != null
          ? List<TicketMessage>.from(
          json['messages'].map((x) => TicketMessage.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'ticket_number': ticketNumber,
      'subject': subject,
      'description': description,
      'category': category,
      'priority': priority,
      'status': status,
      'assigned_to': assignedTo,
      'resolution': resolution,
      'resolved_at': resolvedAt?.toIso8601String(),
      'closed_at': closedAt?.toIso8601String(),
      'attachments': attachments,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'user': user?.toJson(),
      'assigned_admin': assignedAdmin?.toJson(),
      'messages': messages.map((x) => x.toJson()).toList(),
    };
  }

  SupportTicket copyWith({
    int? id,
    int? userId,
    String? ticketNumber,
    String? subject,
    String? description,
    String? category,
    String? priority,
    String? status,
    int? assignedTo,
    String? resolution,
    DateTime? resolvedAt,
    DateTime? closedAt,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? user,
    Admin? assignedAdmin,
    List<TicketMessage>? messages,
  }) {
    return SupportTicket(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      ticketNumber: ticketNumber ?? this.ticketNumber,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      resolution: resolution ?? this.resolution,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      closedAt: closedAt ?? this.closedAt,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
      assignedAdmin: assignedAdmin ?? this.assignedAdmin,
      messages: messages ?? this.messages,
    );
  }
}

class TicketMessage {
  final int id;
  final int supportTicketId;
  final String senderType;
  final int senderId;
  final String message;
  final List<String>? attachments;
  final bool isInternal;
  final DateTime createdAt;
  final DateTime updatedAt;

  TicketMessage({
    required this.id,
    required this.supportTicketId,
    required this.senderType,
    required this.senderId,
    required this.message,
    this.attachments,
    required this.isInternal,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TicketMessage.fromJson(Map<String, dynamic> json) {
    return TicketMessage(
      id: json['id'],
      supportTicketId: json['support_ticket_id'],
      senderType: json['sender_type'],
      senderId: json['sender_id'],
      message: json['message'],
      attachments: json['attachments'] != null
          ? List<String>.from(json['attachments'])
          : null,
      isInternal: json['is_internal'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'support_ticket_id': supportTicketId,
      'sender_type': senderType,
      'sender_id': senderId,
      'message': message,
      'attachments': attachments,
      'is_internal': isInternal,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class User {
  final int id;
  final String name;
  final String email;

  User({
    required this.id,
    required this.name,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}

class Admin {
  final int id;
  final String name;
  final String email;

  Admin({
    required this.id,
    required this.name,
    required this.email,
  });

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}

class CreateTicketRequest {
  final String subject;
  final String description;
  final String category;
  final String priority;
  final Map<String, dynamic>? metadata;

  CreateTicketRequest({
    required this.subject,
    required this.description,
    required this.category,
    required this.priority,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'description': description,
      'category': category,
      'priority': priority,
      if (metadata != null) 'metadata': metadata,
    };
  }
}

class CreateMessageRequest {
  final String message;

  CreateMessageRequest({
    required this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'message': message,
    };
  }
}

// Enums
enum TicketCategory {
  technicalIssue('technical_issue', 'Technical Issue', Icons.bug_report),
  paymentIssue('payment_issue', 'Payment Issue', Icons.payment),
  tournamentIssue('tournament_issue', 'Tournament Issue', Icons.emoji_events),
  teamIssue('team_issue', 'Team Issue', Icons.group),
  accountIssue('account_issue', 'Account Issue', Icons.account_circle),
  featureRequest('feature_request', 'Feature Request', Icons.lightbulb),
  bugReport('bug_report', 'Bug Report', Icons.bug_report_outlined),
  generalInquiry('general_inquiry', 'General Inquiry', Icons.help);

  const TicketCategory(this.value, this.displayName, this.icon);

  final String value;
  final String displayName;
  final IconData icon;

  static TicketCategory fromValue(String value) {
    return TicketCategory.values.firstWhere(
          (category) => category.value == value,
      orElse: () => TicketCategory.generalInquiry,
    );
  }
}

enum TicketPriority {
  low('low', 'Low', Color(0xFF10b981)),
  medium('medium', 'Medium', Color(0xFFf59e0b)),
  high('high', 'High', Color(0xFFef4444)),
  urgent('urgent', 'Urgent', Color(0xFFdc2626));

  const TicketPriority(this.value, this.displayName, this.color);

  final String value;
  final String displayName;
  final Color color;

  static TicketPriority fromValue(String value) {
    return TicketPriority.values.firstWhere(
          (priority) => priority.value == value,
      orElse: () => TicketPriority.low,
    );
  }
}

enum TicketStatus {
  open('open', 'Open', Color(0xFF3b82f6)),
  inProgress('in_progress', 'In Progress', Color(0xFFf59e0b)),
  resolved('resolved', 'Resolved', Color(0xFF10b981)),
  closed('closed', 'Closed', Color(0xFF6b7280));

  const TicketStatus(this.value, this.displayName, this.color);

  final String value;
  final String displayName;
  final Color color;

  static TicketStatus fromValue(String value) {
    return TicketStatus.values.firstWhere(
          (status) => status.value == value,
      orElse: () => TicketStatus.open,
    );
  }
}