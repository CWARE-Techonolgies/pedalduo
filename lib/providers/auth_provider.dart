import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pedalduo/views/auth/login_screen.dart';

import '../models/user_model.dart';
import '../services/auth_api_service.dart';
import '../services/shared_preference_service.dart';
import '../views/home_screen/views/home_screen.dart';

class UserAuthProvider extends ChangeNotifier {
  // Form controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Form validation states
  bool _isEmailValid = true;
  bool _isPasswordValid = true;
  bool _isFullNameValid = true;
  bool _isPhoneValid = true;
  bool _isConfirmPasswordValid = true;

  // Error messages
  String _emailError = '';
  String _passwordError = '';
  String _fullNameError = '';
  String _phoneError = '';
  String _confirmPasswordError = '';

  // Loading states
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Gender selection
  String _selectedGender = 'Male';
  final List<String> _genders = ['Male', 'Female', 'Other'];

  // User data
  UserModel? _currentUser;
  String? _authToken;

  // API error message
  String _apiErrorMessage = '';

  // Getters
  bool get isEmailValid => _isEmailValid;
  bool get isPasswordValid => _isPasswordValid;
  bool get isFullNameValid => _isFullNameValid;
  bool get isPhoneValid => _isPhoneValid;
  bool get isConfirmPasswordValid => _isConfirmPasswordValid;

  String get emailError => _emailError;
  String get passwordError => _passwordError;
  String get fullNameError => _fullNameError;
  String get phoneError => _phoneError;
  String get confirmPasswordError => _confirmPasswordError;

  bool get isLoading => _isLoading;
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;

  String get selectedGender => _selectedGender;
  List<String> get genders => _genders;

  UserModel? get currentUser => _currentUser;
  String? get authToken => _authToken;
  String get apiErrorMessage => _apiErrorMessage;

  // Initialize provider (check if user is already logged in)
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final isLoggedIn = await SharedPreferencesService.isLoggedIn();
      if (isLoggedIn) {
        _currentUser = await SharedPreferencesService.getUserData();
        _authToken = await SharedPreferencesService.getToken();
      }
    } catch (e) {
      debugPrint('Error initializing auth provider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Email validation
  void validateEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (email.isEmpty) {
      _isEmailValid = false;
      _emailError = 'Email is required';
    } else if (!emailRegex.hasMatch(email)) {
      _isEmailValid = false;
      _emailError = 'Please enter a valid email address';
    } else {
      _isEmailValid = true;
      _emailError = '';
    }
    notifyListeners();
  }

  // Password validation
  void validatePassword(String password) {
    if (password.isEmpty) {
      _isPasswordValid = false;
      _passwordError = 'Password is required';
    } else if (password.length < 8) {
      _isPasswordValid = false;
      _passwordError = 'Password must be at least 8 characters';
    } else {
      _isPasswordValid = true;
      _passwordError = '';
    }
    notifyListeners();
  }

  // Full name validation
  void validateFullName(String name) {
    if (name.isEmpty) {
      _isFullNameValid = false;
      _fullNameError = 'Full name is required';
    } else if (name.length < 2) {
      _isFullNameValid = false;
      _fullNameError = 'Name must be at least 2 characters';
    } else {
      _isFullNameValid = true;
      _fullNameError = '';
    }
    notifyListeners();
  }

  // Phone number validation
  void validatePhoneNumber(String phone) {
    // Remove all spaces and special characters except +
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');

    final pakistaniPhoneRegex1 = RegExp(r'^\+923\d{9}$'); // +923xxxxxxxxx
    final pakistaniPhoneRegex2 = RegExp(r'^03\d{9}$'); // 03xxxxxxxxx

    if (phone.isEmpty) {
      _isPhoneValid = false;
      _phoneError = 'Phone number is required';
    } else if (!pakistaniPhoneRegex1.hasMatch(cleanPhone) &&
        !pakistaniPhoneRegex2.hasMatch(cleanPhone)) {
      _isPhoneValid = false;
      _phoneError =
          'Enter valid Pakistani number (+923xxxxxxxxx or 03xxxxxxxxx)';
    } else {
      _isPhoneValid = true;
      _phoneError = '';
    }
    notifyListeners();
  }

  // Confirm password validation
  void validateConfirmPassword(String confirmPassword) {
    if (confirmPassword.isEmpty) {
      _isConfirmPasswordValid = false;
      _confirmPasswordError = 'Please confirm your password';
    } else if (confirmPassword != passwordController.text) {
      _isConfirmPasswordValid = false;
      _confirmPasswordError = 'Passwords do not match';
    } else {
      _isConfirmPasswordValid = true;
      _confirmPasswordError = '';
    }
    notifyListeners();
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  // Gender selection
  void selectGender(String gender) {
    _selectedGender = gender;
    notifyListeners();
  }

  // Loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Clear API error
  void clearApiError() {
    _apiErrorMessage = '';
    notifyListeners();
  }

  // Get user profile after login/signup
  Future<void> _fetchUserProfile(String token) async {
    try {
      final response = await AuthApiService.getUserProfile(token);
      _currentUser = response.data;

      // Save updated user data
      await SharedPreferencesService.saveUserData(_currentUser!, token);
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      // Continue with basic user data from login/signup response
    }
  }

  // Login method
  Future<bool> login(BuildContext context) async {
    validateEmail(emailController.text);
    validatePassword(passwordController.text);

    if (!_isEmailValid || !_isPasswordValid) {
      return false;
    }

    setLoading(true);
    clearApiError();

    try {
      final response = await AuthApiService.login(
        emailController.text.trim(),
        passwordController.text,
      );

      _authToken = response.token;
      await _fetchUserProfile(_authToken!);


      setLoading(false);

      // Navigate to home screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (_) => HomeScreen()),
        );
      });

      return true;
    } catch (e) {
      setLoading(false);
      _apiErrorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Signup method
  Future<bool> signup(BuildContext context) async {
    validateFullName(fullNameController.text);
    validateEmail(emailController.text);
    validatePhoneNumber(phoneController.text);
    validatePassword(passwordController.text);
    validateConfirmPassword(confirmPasswordController.text);

    if (!_isFullNameValid ||
        !_isEmailValid ||
        !_isPhoneValid ||
        !_isPasswordValid ||
        !_isConfirmPasswordValid) {
      return false;
    }

    setLoading(true);
    clearApiError();

    try {
      final response = await AuthApiService.signup(
        name: fullNameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        country: 'Pakistan',
        gender: _selectedGender,
        password: passwordController.text,
      );

      _authToken = response.token;
      await _fetchUserProfile(_authToken!);

      setLoading(false);

      // Navigate to home screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (_) => HomeScreen()),
        );
      });

      return true;
    } catch (e) {
      setLoading(false);
      _apiErrorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Forgot password method
  Future<bool> forgotPassword() async {
    validateEmail(emailController.text);

    if (!_isEmailValid) {
      return false;
    }

    setLoading(true);
    clearApiError();

    try {
      await AuthApiService.resetPassword(emailController.text.trim());
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      _apiErrorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Logout method
  Future<void> logout(BuildContext context) async {
    _currentUser = null;
    _authToken = null;
    await SharedPreferencesService.clearUserData();

    // Navigate to login screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(builder: (_) => LoginScreen()),
      );
    });

    notifyListeners();
  }

  // Check if user is logged in
  bool get isLoggedIn => _currentUser != null && _authToken != null;

  // Clear all fields
  void clearAllFields() {
    emailController.clear();
    passwordController.clear();
    fullNameController.clear();
    phoneController.clear();
    confirmPasswordController.clear();

    _isEmailValid = true;
    _isPasswordValid = true;
    _isFullNameValid = true;
    _isPhoneValid = true;
    _isConfirmPasswordValid = true;

    _emailError = '';
    _passwordError = '';
    _fullNameError = '';
    _phoneError = '';
    _confirmPasswordError = '';
    _apiErrorMessage = '';

    _selectedGender = 'Male';
    _obscurePassword = true;
    _obscureConfirmPassword = true;

    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    fullNameController.dispose();
    phoneController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
