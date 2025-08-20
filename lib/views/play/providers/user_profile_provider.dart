import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:pedalduo/services/shared_preference_service.dart';
import '../../../global/apis.dart';
import '../../../models/user_model.dart';

class UserProfileProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool _isImageDeleted = false;

  bool get isImageDeleted => _isImageDeleted;

  // Method to delete the current profile image
  void deleteProfileImage() {
    _selectedImage = null;
    _isImageDeleted = true;
    notifyListeners();
  }

  // Method to reset image deletion state (call when loading user profile)
  void resetImageDeletionState() {
    _isImageDeleted = false;
    notifyListeners();
  }

  // Initialize user data from SharedPreferences
  Future<void> initializeUser() async {
    _user = await SharedPreferencesService.getUserData();
    notifyListeners();
  }

  // Fetch user profile from API and save to SharedPreferences
  Future<bool> fetchUserProfile({String? token}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final authToken = token ?? await SharedPreferencesService.getToken();
      if (authToken == null) {
        _error = 'No authentication token found';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final response = await http.get(
        Uri.parse(AppApis.userProfile),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (kDebugMode) {
        print('User Profile Response: ${response.statusCode}');
        print('User Profile Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          _user = UserModel.fromJson(jsonData['data']);
          await SharedPreferencesService.saveUserData(_user!, token!);
          _error = null;
        } else {
          _error = 'Invalid response format';
        }
      } else {
        _error = 'Failed to fetch user profile: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Network error: $e';
      if (kDebugMode) {
        print('Get user profile error: $e');
      }
    }

    _isLoading = false;
    notifyListeners();
    return _user != null && _error == null;
  }

  // Update wallet balance
  Future<void> updateWalletBalance(String newBalance) async {
    if (_user != null) {
      _user = _user!.copyWith(walletBalance: newBalance);
      await SharedPreferencesService.updateWalletBalance(newBalance);
      notifyListeners();
    }
  }

  // Update tournament stats
  Future<void> updateTournamentStats({
    int? tournamentsPlayed,
    int? tournamentsOrganized,
    int? firstPlaceWins,
    int? secondPlaceWins,
    String? averageRating,
    bool? isFirstTournament,
  }) async {
    if (_user != null) {
      _user = _user!.copyWith(
        tournamentsPlayed: tournamentsPlayed ?? _user!.tournamentsPlayed,
        tournamentsOrganized:
            tournamentsOrganized ?? _user!.tournamentsOrganized,
        firstPlaceWins: firstPlaceWins ?? _user!.firstPlaceWins,
        secondPlaceWins: secondPlaceWins ?? _user!.secondPlaceWins,
        averageRating: averageRating ?? _user!.averageRating,
        isFirstTournament: isFirstTournament ?? _user!.isFirstTournament,
      );

      await SharedPreferencesService.updateTournamentStats(
        tournamentsPlayed: tournamentsPlayed,
        tournamentsOrganized: tournamentsOrganized,
        firstPlaceWins: firstPlaceWins,
        secondPlaceWins: secondPlaceWins,
        averageRating: averageRating,
        isFirstTournament: isFirstTournament,
      );
      notifyListeners();
    }
  }

  // Clear user data (for logout)
  Future<void> clearUserData() async {
    _user = null;
    _error = null;
    await SharedPreferencesService.clearUserData();
    notifyListeners();
  }

  // Refresh user profile from API
  Future<bool> refreshUserProfile() async {
    return await fetchUserProfile();
  }

  bool _isUpdating = false;
  String? _errorMessage;
  File? _selectedImage;

  bool get isUpdating => _isUpdating;
  String? get errorMessage => _errorMessage;
  File? get selectedImage => _selectedImage;

  Future<void> loadUserProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await SharedPreferencesService.getUserData();
    } catch (e) {
      _errorMessage = 'Failed to load user profile: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserProfile({
    required String name,
    required String phone,
    required String email,
    String? avatar,
  }) async {
    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await SharedPreferencesService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      // Prepare the request body
      final Map<String, dynamic> requestBody = {
        'name': name,
        'phone': phone,
        'email': email,
      };

      // Handle avatar logic
      if (_isImageDeleted) {
        // If image was deleted, send empty string
        requestBody['avatar'] = '';
      } else if (avatar != null) {
        // If new image was selected
        requestBody['avatar'] = avatar;
      }
      // If neither deleted nor new image selected, don't include avatar in request

      // Make API call
      final response = await http.put(
        Uri.parse(AppApis.userProfile),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        if (_user != null) {
          String? newImageUrl = _user!.imageUrl;

          if (_isImageDeleted) {
            newImageUrl = '';
          } else if (avatar != null) {
            newImageUrl = avatar;
          }

          _user = _user!.copyWith(
            name: name,
            phone: phone,
            email: email,
            imageUrl: newImageUrl,
          );

          await SharedPreferencesService.saveUserData(_user!, token);
        }

        _selectedImage = null;
        _isImageDeleted = false; // Reset deletion state after successful update
      } else {
        throw Exception('Failed to update profile: ${response.body}');
      }
    } catch (e) {
      _errorMessage = 'Failed to update profile: $e';
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  Future<bool> deleteProfileImageFromServer() async {
    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await SharedPreferencesService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      // Prepare the request body with empty avatar to delete image
      final Map<String, dynamic> requestBody = {
        'name': _user!.name,
        'phone': _user!.phone,
        'email': _user!.email,
        'avatar': '', // Empty string to delete the image
      };

      // Make API call
      final response = await http.put(
        Uri.parse(AppApis.userProfile),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        // Update local user data
        _user = _user!.copyWith(imageUrl: '');
        await SharedPreferencesService.saveUserData(_user!, token);

        // Reset image states
        _selectedImage = null;
        _isImageDeleted = true;

        _isUpdating = false;
        notifyListeners();
        return true;
      } else {
        throw Exception('Failed to delete profile image: ${response.body}');
      }
    } catch (e) {
      _errorMessage = 'Failed to delete profile image: $e';
      _isUpdating = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );

      if (image != null) {
        _selectedImage = File(image.path);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to pick image: $e';
      notifyListeners();
    }
  }

  String? imageToBase64(File imageFile) {
    try {
      final bytes = imageFile.readAsBytesSync();
      return 'data:image/png;base64,${base64Encode(bytes)}';
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Email OTP verification methods
  Future<bool> sendEmailOtp(String email) async {
    try {
      final token = await SharedPreferencesService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('${AppApis.baseUrl}send-email-otp'),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer $token',
        },
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception('${jsonDecode(response.body)['message']}');
      }
    } catch (e) {
      _errorMessage = 'Failed to send email OTP: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyEmailOtp(String email, String otp) async {
    try {
      final token = await SharedPreferencesService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('${AppApis.baseUrl}verify-email-otp'),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer $token',
        },
        body: json.encode({'email': email, 'otp': otp}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception('${jsonDecode(response.body)['message']}');
      }
    } catch (e) {
      _errorMessage = 'Failed to verify email OTP: $e';
      notifyListeners();
      return false;
    }
  }

  // Phone OTP verification methods
  Future<bool> sendPhoneOtp(String phone) async {
    try {
      final token = await SharedPreferencesService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('${AppApis.baseUrl}send-phone-otp'),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer $token',
        },
        body: json.encode({'phoneNumber': phone}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception('${jsonDecode(response.body)['message']}');
      }
    } catch (e) {
      _errorMessage = 'Failed to send phone OTP: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyPhoneOtp(String phone, String otp) async {
    try {
      final token = await SharedPreferencesService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('${AppApis.baseUrl}verify-phone-otp'),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer $token',
        },
        body: json.encode({'phoneNumber': phone, 'otp': otp}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception('${jsonDecode(response.body)['message']}');
      }
    } catch (e) {
      _errorMessage = 'Failed to verify phone OTP: $e';
      notifyListeners();
      return false;
    }
  }
}
