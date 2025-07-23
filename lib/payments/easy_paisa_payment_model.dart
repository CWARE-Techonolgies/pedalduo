import '../enums/payment_statuses.dart';

class EasyPaisaPaymentModel {
  final String mobileNumber;
  final String email;
  final double amount;
  final String tournamentId;
  final String? transactionId;
  final PaymentStatus status;
  final DateTime createdAt;

  EasyPaisaPaymentModel({
    required this.mobileNumber,
    required this.email,
    required this.amount,
    required this.tournamentId,
    this.transactionId,
    this.status = PaymentStatus.pending,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'mobile_number': mobileNumber,
      'email': email,
      'amount': amount,
      'tournament_id': tournamentId,
      'transaction_id': transactionId,
      'status': status.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory EasyPaisaPaymentModel.fromJson(Map<String, dynamic> json) {
    return EasyPaisaPaymentModel(
      mobileNumber: json['mobile_number'] ?? '',
      email: json['email'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      tournamentId: json['tournament_id'] ?? '',
      transactionId: json['transaction_id'],
      status: PaymentStatus.values.firstWhere(
            (e) => e.toString().split('.').last == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  EasyPaisaPaymentModel copyWith({
    String? mobileNumber,
    String? email,
    double? amount,
    String? tournamentId,
    String? transactionId,
    PaymentStatus? status,
    DateTime? createdAt,
  }) {
    return EasyPaisaPaymentModel(
      mobileNumber: mobileNumber ?? this.mobileNumber,
      email: email ?? this.email,
      amount: amount ?? this.amount,
      tournamentId: tournamentId ?? this.tournamentId,
      transactionId: transactionId ?? this.transactionId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}