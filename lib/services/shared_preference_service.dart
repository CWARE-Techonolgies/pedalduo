import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class SharedPreferencesService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';

  // Save user data and token after login/signup
  static Future<void> saveUserData(UserModel user, String token) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    await prefs.setBool(_isLoggedInKey, true);
  }

  // Get saved token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Get saved user data
  static Future<UserModel?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);

    if (userJson != null) {
      return UserModel.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Update user data
  static Future<void> updateUserData(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  // Clear all user data (logout)
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.setBool(_isLoggedInKey, false);
    await prefs.clear();
  }

  // Get user ID
  static Future<int?> getUserId() async {
    final user = await getUserData();
    return user?.id;
  }

  // Get user email
  static Future<String?> getUserEmail() async {
    final user = await getUserData();
    return user?.email;
  }

  // Get user name
  static Future<String?> getUserName() async {
    final user = await getUserData();
    return user?.name;
  }

  // Update specific user fields
  static Future<void> updateWalletBalance(String newBalance) async {
    final user = await getUserData();
    final userToken = await getToken();
    if (user != null && userToken != null) {
      final updatedUser = user.copyWith(walletBalance: newBalance);
      await saveUserData(updatedUser, userToken);
    }
  }

  static Future<void> updateTournamentStats({
    int? tournamentsPlayed,
    int? tournamentsOrganized,
    int? firstPlaceWins,
    int? secondPlaceWins,
    String? averageRating,
    bool? isFirstTournament,
  }) async {
    final user = await getUserData();
    final userToken = await getToken();
    if (user != null && userToken != null) {
      final updatedUser = user.copyWith(
        tournamentsPlayed: tournamentsPlayed,
        tournamentsOrganized: tournamentsOrganized,
        firstPlaceWins: firstPlaceWins,
        secondPlaceWins: secondPlaceWins,
        averageRating: averageRating,
        isFirstTournament: isFirstTournament,
      );
      await saveUserData(updatedUser, userToken);
    }
  }

  static Future<void> updateUserAvatar(String avatarUrl) async {
    final user = await getUserData();
    final userToken = await getToken();
    if (user != null && userToken != null) {
      final updatedUser = user.copyWith(imageUrl: avatarUrl);
      await saveUserData(updatedUser, userToken);
    }
  }
}
