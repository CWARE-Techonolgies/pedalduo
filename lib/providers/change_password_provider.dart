import 'package:flutter/material.dart';
import 'package:pedalduo/global/apis.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../utils/app_utils.dart';

class ChangePasswordProvider extends ChangeNotifier {
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _currentPasswordVisible = false;
  bool _newPasswordVisible = false;
  bool _confirmPasswordVisible = false;

  String? _currentPasswordError;
  String? _newPasswordError;
  String? _confirmPasswordError;

  // Getters
  bool get isLoading => _isLoading;
  bool get currentPasswordVisible => _currentPasswordVisible;
  bool get newPasswordVisible => _newPasswordVisible;
  bool get confirmPasswordVisible => _confirmPasswordVisible;
  String? get currentPasswordError => _currentPasswordError;
  String? get newPasswordError => _newPasswordError;
  String? get confirmPasswordError => _confirmPasswordError;

  // Check if all fields are filled and passwords are different
  bool get isFormValid {
    return currentPasswordController.text.isNotEmpty &&
        newPasswordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty &&
        currentPasswordController.text != newPasswordController.text;
  }

  // Toggle password visibility
  void toggleCurrentPasswordVisibility() {
    _currentPasswordVisible = !_currentPasswordVisible;
    notifyListeners();
  }

  void toggleNewPasswordVisibility() {
    _newPasswordVisible = !_newPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _confirmPasswordVisible = !_confirmPasswordVisible;
    notifyListeners();
  }

  // Password validation
  bool _isPasswordValid(String password) {
    if (password.length < 6) return false;

    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasDigit = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    return hasUppercase && hasLowercase && hasDigit && hasSpecialChar;
  }

  // Real-time password validation
  String? validateNewPassword(String password) {
    if (password.isEmpty) return null; // Don't show error for empty field

    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }

    // Check if same as current password
    if (currentPasswordController.text.isNotEmpty && password == currentPasswordController.text) {
      return 'New password must be different from current password';
    }

    return null; // Password is valid
  }

  // Validate all fields for final submission
  bool _validateFields() {
    _currentPasswordError = null;
    _newPasswordError = null;
    _confirmPasswordError = null;

    bool isValid = true;

    // Validate current password
    if (currentPasswordController.text.isEmpty) {
      _currentPasswordError = 'Current password is required';
      isValid = false;
    }

    // Validate new password
    final newPasswordValidation = validateNewPassword(newPasswordController.text);
    if (newPasswordController.text.isEmpty) {
      _newPasswordError = 'New password is required';
      isValid = false;
    } else if (newPasswordValidation != null) {
      _newPasswordError = newPasswordValidation;
      isValid = false;
    }

    // Validate confirm password
    if (confirmPasswordController.text.isEmpty) {
      _confirmPasswordError = 'Please confirm your password';
      isValid = false;
    } else if (newPasswordController.text != confirmPasswordController.text) {
      _confirmPasswordError = 'Passwords do not match';
      isValid = false;
    }

    notifyListeners();
    return isValid;
  }

  // Get auth token from shared preferences
  Future<String?> _getAuthToken() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      print('Error getting auth token: $e');
      return null;
    }
  }

  // Change password API call
  Future<void> changePassword(BuildContext context) async {
    if (!_validateFields()) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Get auth token
      final String? authToken = await _getAuthToken();
      if (authToken == null) {
        AppUtils.showFailureSnackBar(context, 'Authentication token not found. Please login again.');
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Prepare request body
      final Map<String, String> requestBody = {
        'currentPassword': currentPasswordController.text,
        'newPassword': newPasswordController.text,
        'confirmPassword': confirmPasswordController.text,
      };

      // Make API call
      final response = await http.put(
        Uri.parse(AppApis.changePassword),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        // Success
        AppUtils.showSuccessSnackBar(context, 'Password changed successfully!');
        _clearFields();
        Navigator.of(context).pop();
      } else if (response.statusCode == 401) {
        // Unauthorized - current password is wrong
        _currentPasswordError = 'Current password is incorrect';
        AppUtils.showFailureSnackBar(context, 'Current password is incorrect');
        notifyListeners();
      } else if (response.statusCode == 400) {
        // Bad request - validation error
        final Map<String, dynamic> errorResponse = json.decode(response.body);
        String errorMessage = errorResponse['message'] ?? 'Invalid request. Please check your input.';
        AppUtils.showFailureSnackBar(context, errorMessage);
      } else {
        // Other errors
        AppUtils.showFailureSnackBar(context, 'Failed to change password. Please try again.');
      }
    } catch (e) {
      print('Error changing password: $e');
      AppUtils.showFailureSnackBar(context, 'Network error. Please check your connection and try again.');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _clearFields() {
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
    _currentPasswordError = null;
    _newPasswordError = null;
    _confirmPasswordError = null;
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}

// Extension to clear individual field errors
extension ChangePasswordProviderExtension on ChangePasswordProvider {
  void clearFieldError(String fieldLabel) {
    switch (fieldLabel) {
      case 'Current Password':
        _currentPasswordError = null;
        break;
      case 'New Password':
        _newPasswordError = null;
        break;
      case 'Confirm New Password':
        _confirmPasswordError = null;
        break;
    }
    notifyListeners();
  }
}