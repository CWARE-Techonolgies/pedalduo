import '../../models/user_model.dart';
class AuthResponse {
  final bool success;
  final String message;
  final UserModel user;
  final String token;

  AuthResponse({
    required this.success,
    required this.message,
    required this.user,
    required this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'],
      message: json['message'],
      user: UserModel.fromJson(json['user']),
      token: json['token'],
    );
  }
}

class UserProfileResponse {
  final bool success;
  final UserModel data;

  UserProfileResponse({
    required this.success,
    required this.data,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) {
    return UserProfileResponse(
      success: json['success'],
      data: UserModel.fromJson(json['data']),
    );
  }
}

class ResetPasswordResponse {
  final bool success;
  final String message;

  ResetPasswordResponse({
    required this.success,
    required this.message,
  });

  factory ResetPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResponse(
      success: json['success'],
      message: json['message'],
    );
  }
}

class ApiErrorResponse {
  final bool success;
  final String message;
  final String? error;

  ApiErrorResponse({
    required this.success,
    required this.message,
    this.error,
  });

  factory ApiErrorResponse.fromJson(Map<String, dynamic> json) {
    return ApiErrorResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? 'An error occurred',
      error: json['error'],
    );
  }
}