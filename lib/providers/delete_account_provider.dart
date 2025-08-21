import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pedalduo/global/apis.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeleteAccountProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isCheckingParticipation = false;
  String? _error;

  bool get isLoading => _isLoading;
  bool get isCheckingParticipation => _isCheckingParticipation;
  String? get error => _error;

  // ✅ Utility: get token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Check if user has active participation
  Future<Map<String, dynamic>?> checkActiveParticipation() async {
    _isCheckingParticipation = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) {
        _error = "No auth token found";
        _isCheckingParticipation = false;
        notifyListeners();
        return null;
      }

      final response = await http.get(
        Uri.parse(AppApis.checkDeletionValidation),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _isCheckingParticipation = false;
        notifyListeners();
        return data;
      } else {
        _error = 'Failed to check participation status';
        _isCheckingParticipation = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      _isCheckingParticipation = false;
      notifyListeners();
      return null;
    }
  }

  // Delete account API call
  Future<bool> deleteAccount(Map<String, dynamic> deleteData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) {
        _error = "No auth token found";
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final response = await http.post(
        Uri.parse(AppApis.deleteAccount),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(deleteData),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to delete account';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear all data from SharedPreferences
  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      print('Error clearing data: $e');
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}