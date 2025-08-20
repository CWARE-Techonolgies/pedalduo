import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pedalduo/global/apis.dart';
import 'package:pedalduo/utils/app_utils.dart';
import '../models/auth_response_model.dart';

class AuthApiService {
  static const String loginEndpoint = AppApis.login;
  static const String signupEndpoint = AppApis.signUp;
  static const String profileEndpoint = AppApis.userProfile;
  static const String resetPasswordEndpoint = AppApis.forgetPassword;
  static const String resetPasswordEndpointUpdate = AppApis.updateResetPassword;
  static const String sendEmailOtpEndpoint = AppApis.sendEmailOtp;
  static const String verifyEmailOtpEndpoint = AppApis.verifyEmailOtp;
  static const String sendPhoneOtpEndpoint = AppApis.sendPhoneOtp;
  static const String verifyPhoneOtpEndpoint = AppApis.verifyPhoneOtp;

  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> get authHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer ${getToken()}',
  };

  static String? getToken() {
    // TODO: Implement token fetch from SharedPreferences
    return null;
  }

  // Login API
  static Future<AuthResponse> login(
    String emailOrPhone,
    String password,
    String type,
  ) async {
    debugPrint('🔐 Sending login request to $loginEndpoint');

    final requestBody =
        type == 'email'
            ? {'email': emailOrPhone, 'password': password, 'type': 'email'}
            : {'phone': emailOrPhone, 'password': password, 'type': 'phone'};

    try {
      final response = await http.post(
        Uri.parse(loginEndpoint),
        headers: headers,
        body: jsonEncode(
          requestBody,
        ), // Use requestBody instead of hardcoded values
      );

      debugPrint('✅ Login response status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        debugPrint('✅ Login success: $data');
        return AuthResponse.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body);
        debugPrint('❌ Login failed: ${errorData['message']}');
        throw ApiException(
          message: errorData['message'] ?? 'Login failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      debugPrint('🚨 Login exception: $e');
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Network error: $e', statusCode: 0);
    }
  }

  // Signup API
  static Future<AuthResponse> signup({
    required String name,
    required String email,
    required String phone,
    required String country,
    required String gender,
    required String password,
  }) async {
    debugPrint('📝 Sending signup request to $signupEndpoint');

    try {
      final response = await http.post(
        Uri.parse(signupEndpoint),
        headers: headers,
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone,
          'country': country,
          'gender': gender.toLowerCase(),
          'password': password,
        }),
      );

      debugPrint('✅ Signup response status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        debugPrint('✅ Signup success: $data');
        return AuthResponse.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body);
        debugPrint('❌ Signup failed: ${errorData['message']}');
        throw ApiException(
          message: errorData['message'] ?? 'Signup failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      debugPrint('🚨 Signup exception: $e');
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Network error: $e', statusCode: 0);
    }
  }

  // Get User Profile API
  static Future<UserProfileResponse> getUserProfile(String token) async {
    debugPrint('👤 Fetching user profile from $profileEndpoint');

    try {
      final response = await http.get(
        Uri.parse(profileEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('✅ Profile response status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        debugPrint('✅ Profile data: $data');
        return UserProfileResponse.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body);
        debugPrint('❌ Profile fetch failed: ${errorData['message']}');
        throw ApiException(
          message: errorData['message'] ?? 'Failed to fetch profile',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      debugPrint('🚨 Profile exception: $e');
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Network error: $e', statusCode: 0);
    }
  }

  // Reset Password API
  static Future<ResetPasswordResponse> resetPassword(String email) async {
    debugPrint('🔄 Sending password reset to $resetPasswordEndpoint');

    try {
      final response = await http.post(
        Uri.parse(resetPasswordEndpoint),
        headers: headers,
        body: jsonEncode({'email': email}),
      );

      debugPrint('✅ Reset password status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        debugPrint('✅ Reset password success: $data');
        return ResetPasswordResponse.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body);
        debugPrint('❌ Reset password failed: ${errorData['message']}');
        throw ApiException(
          message: errorData['message'] ?? 'Failed to send reset email',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      debugPrint('🚨 Reset password exception: $e');
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Network error: $e', statusCode: 0);
    }
  }

  // Send Email OTP API
  static Future<Map<String, dynamic>> sendEmailOtp(String email) async {
    debugPrint('📧 Sending email OTP to $sendEmailOtpEndpoint');

    try {
      final response = await http.post(
        Uri.parse(sendEmailOtpEndpoint),
        headers: headers,
        body: jsonEncode({'email': email}),
      );

      debugPrint('✅ Send email OTP status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        debugPrint('✅ Email OTP sent: $data');
        return data;
      } else {
        final errorData = jsonDecode(response.body);
        debugPrint('❌ Send email OTP failed: ${errorData['message']}');
        throw ApiException(
          message: errorData['message'] ?? 'Failed to send email OTP',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      debugPrint('🚨 Send email OTP exception: $e');
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Network error: $e', statusCode: 0);
    }
  }

  // Verify Email OTP API
  static Future<Map<String, dynamic>> verifyEmailOtp(
    String email,
    String otp,
  ) async {
    debugPrint('✅ Verifying email OTP at $verifyEmailOtpEndpoint');

    try {
      final response = await http.post(
        Uri.parse(verifyEmailOtpEndpoint),
        headers: headers,
        body: jsonEncode({'email': email, 'otp': otp}),
      );

      debugPrint('✅ Verify email OTP status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        debugPrint('✅ Email OTP verified: $data');
        return data;
      } else {
        final errorData = jsonDecode(response.body);
        debugPrint('❌ Verify email OTP failed: ${errorData['message']}');
        throw ApiException(
          message: errorData['message'] ?? 'Invalid email OTP',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      debugPrint('🚨 Verify email OTP exception: $e');
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Network error: $e', statusCode: 0);
    }
  }

  // Send Phone OTP API
  static Future<Map<String, dynamic>> sendPhoneOtp(
    String phoneNumber,
    BuildContext context,
  ) async {
    debugPrint('📱 Sending phone OTP to $sendPhoneOtpEndpoint');

    try {
      final response = await http.post(
        Uri.parse(sendPhoneOtpEndpoint),
        headers: headers,
        body: jsonEncode({'phoneNumber': phoneNumber}),
      );

      debugPrint('✅ Send phone OTP status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        debugPrint('✅ Phone OTP sent: $data');
        return data;
      } else {
        final errorData = jsonDecode(response.body);
        debugPrint('❌ Send phone OTP failed: ${errorData['message']}');
        AppUtils.showInfoDialog(
          context,
          'Failed to Send Otp',
          errorData['message'],
        );
        throw ApiException(
          message: errorData['message'] ?? 'Failed to send phone OTP',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      debugPrint('🚨 Send phone OTP exception: $e');
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Network error: $e', statusCode: 0);
    }
  }

  // Verify Phone OTP API
  static Future<Map<String, dynamic>> verifyPhoneOtp(
    String phone,
    String otp,
  ) async {
    debugPrint('✅ Verifying phone OTP at $verifyPhoneOtpEndpoint');

    try {
      final response = await http.post(
        Uri.parse(verifyPhoneOtpEndpoint),
        headers: headers,
        body: jsonEncode({'phoneNumber': phone, 'otp': otp}),
      );

      debugPrint('✅ Verify phone OTP status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        debugPrint('✅ Phone OTP verified: $data');
        return data;
      } else {
        final errorData = jsonDecode(response.body);
        debugPrint('❌ Verify phone OTP failed: ${errorData['message']}');
        throw ApiException(
          message: errorData['message'] ?? 'Invalid phone OTP',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      debugPrint('🚨 Verify phone OTP exception: $e');
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Network error: $e', statusCode: 0);
    }
  }

  static Future<ResetPasswordResponse> sendResetPasswordOtp(
    String email,
  ) async {
    debugPrint('🔄 Sending reset password OTP to $resetPasswordEndpoint');

    try {
      final response = await http.post(
        Uri.parse(resetPasswordEndpoint),
        headers: headers,
        body: jsonEncode({'email': email}),
      );

      debugPrint('✅ Send reset OTP status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        debugPrint('✅ Send reset OTP success: $data');
        return ResetPasswordResponse.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body);
        debugPrint('❌ Send reset OTP failed: ${errorData['message']}');
        throw ApiException(
          message: errorData['message'] ?? 'Failed to send reset OTP',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      debugPrint('🚨 Send reset OTP exception: $e');
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Network error: $e', statusCode: 0);
    }
  }

  // Reset Password with OTP (new method)
  static Future<ResetPasswordResponse> resetPasswordWithOtp({
    required String otp,
    required String newPassword,
    required String confirmPassword,
    required String email,
  }) async {
    // You'll need to define this endpoint URL
    const String resetPasswordWithOtpEndpoint =
        resetPasswordEndpointUpdate ;

    debugPrint(
      '🔄 Resetting password with OTP to $resetPasswordWithOtpEndpoint',
    );

    try {
      final response = await http.post(
        Uri.parse(resetPasswordWithOtpEndpoint),
        headers: headers,
        body: jsonEncode({
          'otp': otp,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
          'email':email,
          'phone':  null
        }),
      );

      debugPrint('✅ Reset password with OTP status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        debugPrint('✅ Reset password with OTP success: $data');
        return ResetPasswordResponse.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body);
        debugPrint('❌ Reset password with OTP failed: ${errorData['message']}');
        throw ApiException(
          message: errorData['message'] ?? 'Failed to reset password',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      debugPrint('🚨 Reset password with OTP exception: $e');
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Network error: $e', statusCode: 0);
    }
  }

}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException({required this.message, required this.statusCode});

  @override
  String toString() => message;
}
