import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pedalduo/utils/app_utils.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../enums/payment_statuses.dart';
import '../global/apis.dart';
import 'easy_paisa_payment_model.dart';

class EasyPaisaPaymentProvider with ChangeNotifier {
  EasyPaisaPaymentModel? _currentPayment;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isProcessingPayment = false;

  EasyPaisaPaymentModel? get currentPayment => _currentPayment;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isProcessingPayment => _isProcessingPayment;

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Initialize payment
  void initializePayment({
    required String mobileNumber,
    required String email,
    required double amount,
    required String tournamentId,
  }) {
    _currentPayment = EasyPaisaPaymentModel(
      mobileNumber: mobileNumber,
      email: email,
      amount: amount,
      tournamentId: tournamentId,
      createdAt: DateTime.now(),
    );
    _errorMessage = null;
    notifyListeners();
  }

  // Process EasyPaisa payment
  // Future<bool> processEasyPaisaPayment() async {
  //   if (_currentPayment == null) {
  //     _errorMessage = 'Payment not initialized';
  //     notifyListeners();
  //     return false;
  //   }
  //
  //   try {
  //     _isProcessingPayment = true;
  //     _errorMessage = null;
  //     notifyListeners();
  //
  //     final prefs = await SharedPreferences.getInstance();
  //     final token = prefs.getString('auth_token');
  //     if (token == null) throw Exception('Authentication token not found');
  //
  //     // Build request payload
  //     final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch}';
  //     final requestBody = {
  //       'orderId': orderId,
  //       'storeId': '78076',
  //       'transactionAmount': _currentPayment!.amount.toStringAsFixed(2),
  //       'transactionType': 'MA',
  //       'mobileAccountNo': _currentPayment!.mobileNumber,
  //       'emailAddress': _currentPayment!.email,
  //     };
  //
  //     final response = await http.post(
  //       Uri.parse('https://easypay.easypaisa.com.pk/easypay-service/rest/v4/initiate-ma-transaction'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Credentials': AppConstants.easyPaisaAuth
  //       },
  //       body: json.encode(requestBody),
  //     );
  //
  //     final data = json.decode(response.body);
  //     final code = data['responseCode'];
  //     final desc = data['responseDesc'];
  //
  //     if (code == '0000') {
  //       _currentPayment = _currentPayment!.copyWith(
  //         status: PaymentStatus.success,
  //         transactionId: data['transactionId'],
  //       );
  //
  //       await confirmPaymentWithBackend();
  //       notifyListeners();
  //       return true;
  //     } else {
  //       _errorMessage = '$code - $desc';
  //       _currentPayment = _currentPayment!.copyWith(status: PaymentStatus.failed);
  //       notifyListeners();
  //       return false;
  //     }
  //   } catch (e) {
  //     _errorMessage = 'Payment failed: ${e.toString()}';
  //     _currentPayment = _currentPayment?.copyWith(status: PaymentStatus.failed);
  //     notifyListeners();
  //     return false;
  //   } finally {
  //     _isProcessingPayment = false;
  //     notifyListeners();
  //   }
  // }
  // Confirm payment with backend
  Future<void> confirmPaymentWithBackend(
    int tournamentId,
    BuildContext context,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse(AppApis.packageFee),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          // 'tournament_id': int.parse(_currentPayment!.tournamentId),
          'tournament_id': tournamentId,
        }),
      );
      if (response.statusCode == 200) {
        AppUtils.showSuccessSnackBar(
          context,
          'Payment Approved, Please refresh your page and wait for admin to approve',
        );
      }
      if (response.statusCode != 200) {
        throw Exception('Failed to confirm payment with backend');
      }
    } catch (e) {
      debugPrint('Backend confirmation error: $e');
      // You might want to handle this differently based on your app's requirements
    }
  }

  // Cancel payment
  void cancelPayment() {
    if (_currentPayment != null) {
      _currentPayment = _currentPayment!.copyWith(
        status: PaymentStatus.cancelled,
      );
      notifyListeners();
    }
  }

  // Reset payment state
  void resetPayment() {
    _currentPayment = null;
    _errorMessage = null;
    _isLoading = false;
    _isProcessingPayment = false;
    notifyListeners();
  }
}
