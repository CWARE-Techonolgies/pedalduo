import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pedalduo/global/apis.dart';
import '../models/auth_response_model.dart';

class AuthApiService {
  static const String loginEndpoint = AppApis.login;
  static const String signupEndpoint = AppApis.signUp;
  static const String profileEndpoint = AppApis.userProfile;
  static const String resetPasswordEndpoint = AppApis.forgetPassword;

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
  static Future<AuthResponse> login(String email, String password) async {
    debugPrint('🔐 Sending login request to $loginEndpoint');

    try {
      final response = await http.post(
        Uri.parse(loginEndpoint),
        headers: headers,
        body: jsonEncode({'email': email, 'password': password}),
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
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException({
    required this.message,
    required this.statusCode,
  });

  @override
  String toString() => message;
}