import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:pedalduo/views/auth/login_screen.dart';

import '../models/user_model.dart';
import '../services/auth_api_service.dart';
import '../services/shared_preference_service.dart';
import '../views/home_screen/views/home_screen.dart';
import '../utils/app_utils.dart';

class UserAuthProvider extends ChangeNotifier {
  // Form controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController emailOtpController = TextEditingController();
  final TextEditingController phoneOtpController = TextEditingController();
  final TextEditingController resetOtpController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmNewPasswordController =
      TextEditingController();

  // Form validation states
  bool _isEmailValid = true;
  bool _isPasswordValid = true;
  bool _isFullNameValid = true;
  bool _isPhoneValid = true;
  bool _isConfirmPasswordValid = true;
  bool _isEmailOtpValid = true;
  bool _isPhoneOtpValid = true;
  Timer? _emailOtpTimer;
  Timer? _phoneOtpTimer;
  int _emailOtpCountdown = 0;
  int _phoneOtpCountdown = 0;
  bool _isResetOtpValid = true;
  bool _isNewPasswordValid = true;
  bool _isConfirmNewPasswordValid = true;

  // Error messages
  String _emailError = '';
  String _passwordError = '';
  String _fullNameError = '';
  String _phoneError = '';
  String _confirmPasswordError = '';
  String _emailOtpError = '';
  String _phoneOtpError = '';

  // Loading states
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isEmailVerifying = false;
  bool _isPhoneVerifying = false;
  bool _isEmailOtpVerifying = false;
  bool _isPhoneOtpVerifying = false;
  String _resetOtpError = '';
  String _newPasswordError = '';
  String _confirmNewPasswordError = '';

  // Verification states
  bool _isEmailVerified = false;
  bool _isPhoneVerified = false;
  bool _showEmailOtp = false;
  bool _showPhoneOtp = false;
  bool _isResetOtpSent = false;
  bool _isResetOtpVerified = false;
  bool _isSendingResetOtp = false;
  bool _isVerifyingResetOtp = false;
  bool _isResettingPassword = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmNewPassword = true;

  // Gender selection
  String _selectedGender = 'Male';
  final List<String> _genders = ['Male', 'Female'];

  // User data
  UserModel? _currentUser;
  String? _authToken;
  Timer? _resetOtpTimer;
  int _resetOtpCountdown = 0;

  // API error message
  String _apiErrorMessage = '';

  // Terms & Conditions
  bool _acceptTerms = false;
  String _termsError = '';

  // Getters
  bool get isEmailValid => _isEmailValid;
  bool get isPasswordValid => _isPasswordValid;
  bool get isFullNameValid => _isFullNameValid;
  bool get isPhoneValid => _isPhoneValid;
  bool get isConfirmPasswordValid => _isConfirmPasswordValid;
  bool get isEmailOtpValid => _isEmailOtpValid;
  bool get isPhoneOtpValid => _isPhoneOtpValid;
  int get emailOtpCountdown => _emailOtpCountdown;
  int get phoneOtpCountdown => _phoneOtpCountdown;
  bool get canResendEmailOtp => _emailOtpCountdown == 0;
  bool get canResendPhoneOtp => _phoneOtpCountdown == 0;
  String get emailError => _emailError;
  String get passwordError => _passwordError;
  String get fullNameError => _fullNameError;
  String get phoneError => _phoneError;
  String get confirmPasswordError => _confirmPasswordError;
  String get emailOtpError => _emailOtpError;
  String get phoneOtpError => _phoneOtpError;

  bool get isLoading => _isLoading;
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;
  bool get isEmailVerifying => _isEmailVerifying;
  bool get isPhoneVerifying => _isPhoneVerifying;
  bool get isEmailOtpVerifying => _isEmailOtpVerifying;
  bool get isPhoneOtpVerifying => _isPhoneOtpVerifying;

  bool get isEmailVerified => _isEmailVerified;
  bool get isPhoneVerified => _isPhoneVerified;
  bool get showEmailOtp => _showEmailOtp;
  bool get showPhoneOtp => _showPhoneOtp;

  String get selectedGender => _selectedGender;
  List<String> get genders => _genders;

  UserModel? get currentUser => _currentUser;
  String? get authToken => _authToken;
  String get apiErrorMessage => _apiErrorMessage;

  bool get acceptTerms => _acceptTerms;
  String get termsError => _termsError;

  // Check if signup button should be enabled
  bool get isSignupButtonEnabled {
    return _isFullNameValid &&
        _isEmailValid &&
        _isPhoneValid &&
        _isPasswordValid &&
        _isConfirmPasswordValid &&
        // _isEmailVerified &&
        // _isPhoneVerified &&
        _acceptTerms &&
        fullNameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        phoneController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty;
  }

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

  // Getters for password reset
  bool get isResetOtpValid => _isResetOtpValid;
  bool get isNewPasswordValid => _isNewPasswordValid;
  bool get isConfirmNewPasswordValid => _isConfirmNewPasswordValid;

  String get resetOtpError => _resetOtpError;
  String get newPasswordError => _newPasswordError;
  String get confirmNewPasswordError => _confirmNewPasswordError;

  bool get isResetOtpSent => _isResetOtpSent;
  bool get isResetOtpVerified => _isResetOtpVerified;
  bool get isSendingResetOtp => _isSendingResetOtp;
  bool get isVerifyingResetOtp => _isVerifyingResetOtp;
  bool get isResettingPassword => _isResettingPassword;
  bool get obscureNewPassword => _obscureNewPassword;
  bool get obscureConfirmNewPassword => _obscureConfirmNewPassword;

  int get resetOtpCountdown => _resetOtpCountdown;
  bool get canResendResetOtp => _resetOtpCountdown == 0;

  bool get isResetPasswordButtonEnabled {
    return _isResetOtpVerified &&
        _isNewPasswordValid &&
        _isConfirmNewPasswordValid &&
        newPasswordController.text.isNotEmpty &&
        confirmNewPasswordController.text.isNotEmpty;
  }

  void validateResetOtp(String otp) {
    if (otp.isEmpty) {
      _isResetOtpValid = false;
      _resetOtpError = 'OTP is required';
    } else if (otp.length != 6) {
      _isResetOtpValid = false;
      _resetOtpError = 'OTP must be 6 digits';
    } else {
      _isResetOtpValid = true;
      _resetOtpError = '';
    }
    notifyListeners();
  }

  void validateNewPassword(String password) {
    newPasswordController.text = password;

    if (password.isEmpty) {
      _newPasswordError = 'New password is required';
      _isNewPasswordValid = false;
    } else if (password.length < 6) {
      _newPasswordError = 'Password must be at least 6 characters long';
      _isNewPasswordValid = false;
    } else if (!RegExp(
      r'^(?=.*[a-zA-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]',
    ).hasMatch(password)) {
      _newPasswordError =
          'Password must contain at least one letter, one number, and one special character';
      _isNewPasswordValid = false;
    } else {
      _newPasswordError = '';
      _isNewPasswordValid = true;
    }

    // Re-validate confirm password if it has value
    if (confirmNewPasswordController.text.isNotEmpty) {
      validateConfirmNewPassword(confirmNewPasswordController.text);
    }
    notifyListeners();
  }

  void validateConfirmNewPassword(String password) {
    confirmNewPasswordController.text = password;

    if (password.isEmpty) {
      _confirmNewPasswordError = 'Please confirm your new password';
      _isConfirmNewPasswordValid = false;
    } else if (password != newPasswordController.text) {
      _confirmNewPasswordError = 'Passwords do not match';
      _isConfirmNewPasswordValid = false;
    } else {
      _confirmNewPasswordError = '';
      _isConfirmNewPasswordValid = true;
    }
    notifyListeners();
  }

  void toggleNewPasswordVisibility() {
    _obscureNewPassword = !_obscureNewPassword;
    notifyListeners();
  }

  void toggleConfirmNewPasswordVisibility() {
    _obscureConfirmNewPassword = !_obscureConfirmNewPassword;
    notifyListeners();
  }

  Future<bool> sendResetPasswordOtp(BuildContext context) async {
    validateEmail(emailController.text);

    if (!_isEmailValid || !canResendResetOtp) {
      return false;
    }

    _isSendingResetOtp = true;
    clearApiError();
    notifyListeners();

    try {
      final response = await AuthApiService.sendResetPasswordOtp(
        emailController.text.trim(),
      );

      _isResetOtpSent = true;
      _isSendingResetOtp = false;
      _startResetOtpTimer();

      notifyListeners();
      return true;
    } catch (e) {
      _isSendingResetOtp = false;
      _apiErrorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyResetPasswordOtp() async {
    validateResetOtp(resetOtpController.text);

    if (!_isResetOtpValid) {
      return false;
    }

    _isVerifyingResetOtp = true;
    notifyListeners();

    try {
      // In a real scenario, you might want to verify OTP with backend
      // For now, we'll assume 123456 is valid (as per your testing setup)
      if (resetOtpController.text == '123456') {
        _isResetOtpVerified = true;
        _isVerifyingResetOtp = false;

        // Stop timer on successful verification
        _resetOtpTimer?.cancel();
        _resetOtpTimer = null;
        _resetOtpCountdown = 0;

        notifyListeners();
        return true;
      } else {
        _isVerifyingResetOtp = false;
        _resetOtpError = 'Invalid OTP';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isVerifyingResetOtp = false;
      _resetOtpError = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(BuildContext context) async {
    validateNewPassword(newPasswordController.text);
    validateConfirmNewPassword(confirmNewPasswordController.text);

    if (!isResetPasswordButtonEnabled) {
      return false;
    }

    _isResettingPassword = true;
    clearApiError();
    notifyListeners();

    try {
      final response = await AuthApiService.resetPasswordWithOtp(
        otp: resetOtpController.text.trim(),
        newPassword: newPasswordController.text,
        confirmPassword: confirmNewPasswordController.text,
        email: emailController.text
      );

      _isResettingPassword = false;

      // Clear all reset-related fields
      _clearResetPasswordFields();

      notifyListeners();
      return true;
    } catch (e) {
      _isResettingPassword = false;
      _apiErrorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Start reset OTP timer
  void _startResetOtpTimer() {
    _resetOtpCountdown = 120; // 2 minutes
    _resetOtpTimer?.cancel();

    _resetOtpTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_resetOtpCountdown > 0) {
        _resetOtpCountdown--;
        notifyListeners();
      } else {
        timer.cancel();
        _resetOtpTimer = null;
      }
    });
  }

  void _clearResetPasswordFields() {
    resetOtpController.clear();
    newPasswordController.clear();
    confirmNewPasswordController.clear();

    _isResetOtpValid = true;
    _isNewPasswordValid = true;
    _isConfirmNewPasswordValid = true;

    _resetOtpError = '';
    _newPasswordError = '';
    _confirmNewPasswordError = '';

    _isResetOtpSent = false;
    _isResetOtpVerified = false;
    _obscureNewPassword = true;
    _obscureConfirmNewPassword = true;

    _resetOtpTimer?.cancel();
    _resetOtpTimer = null;
    _resetOtpCountdown = 0;
  }

  // New method - only for login
  void validateEmailOrPhoneForLogin(String value) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    final phoneRegex = RegExp(r'^\+923\d{9}$');

    if (value.isEmpty) {
      _isEmailValid = false;
      _emailError = 'Email or phone number is required';
    } else if (emailRegex.hasMatch(value) || phoneRegex.hasMatch(value)) {
      _isEmailValid = true;
      _emailError = '';
    } else {
      _isEmailValid = false;
      _emailError = 'Enter valid email or phone (+923xxxxxxxxx)';
    }
    notifyListeners();
  }

  bool _isEmail(String value) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(value);
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

    // Reset email verification if email changes
    if (_isEmailVerified || _showEmailOtp) {
      _isEmailVerified = false;
      _showEmailOtp = false;
      emailOtpController.clear();
    }

    notifyListeners();
  }

  // Password validation
  void validatePassword(String value) {
    passwordController.text = value;

    if (value.isEmpty) {
      _passwordError = 'Password is required';
      _isPasswordValid = false;
    } else if (value.length < 6) {
      _passwordError = 'Password must be at least 6 characters long';
      _isPasswordValid = false;
    } else if (!RegExp(
      r'^(?=.*[a-zA-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]',
    ).hasMatch(value)) {
      _passwordError =
          'Password must contain at least one letter, one number, and one special character';
      _isPasswordValid = false;
    } else {
      _passwordError = '';
      _isPasswordValid = true;
    }

    // Re-validate confirm password if it has value
    if (confirmPasswordController.text.isNotEmpty) {
      validateConfirmPassword(confirmPasswordController.text);
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
    // final pakistaniPhoneRegex2 = RegExp(r'^03\d{9}$'); // 03xxxxxxxxx

    if (phone.isEmpty) {
      _isPhoneValid = false;
      _phoneError = 'Phone number is required';
    } else if (!pakistaniPhoneRegex1.hasMatch(cleanPhone)) {
      _isPhoneValid = false;
      _phoneError =
          'Enter valid Pakistani number (+923xxxxxxxxx or 03xxxxxxxxx)';
    } else {
      _isPhoneValid = true;
      _phoneError = '';
    }

    // Reset phone verification if phone changes
    if (_isPhoneVerified || _showPhoneOtp) {
      _isPhoneVerified = false;
      _showPhoneOtp = false;
      phoneOtpController.clear();
    }

    notifyListeners();
  }

  void validateConfirmPassword(String value) {
    confirmPasswordController.text = value;

    if (value.isEmpty) {
      _confirmPasswordError = 'Please confirm your password';
      _isConfirmPasswordValid = false;
    } else if (value != passwordController.text) {
      _confirmPasswordError = 'Passwords do not match';
      _isConfirmPasswordValid = false;
    } else {
      _confirmPasswordError = '';
      _isConfirmPasswordValid = true;
    }

    notifyListeners();
  }

  // Email OTP validation
  void validateEmailOtp(String otp) {
    if (otp.isEmpty) {
      _isEmailOtpValid = false;
      _emailOtpError = 'OTP is required';
    } else if (otp.length != 6) {
      _isEmailOtpValid = false;
      _emailOtpError = 'OTP must be 6 digits';
    } else {
      _isEmailOtpValid = true;
      _emailOtpError = '';
    }
    notifyListeners();
  }

  // Phone OTP validation
  void validatePhoneOtp(String otp) {
    if (otp.isEmpty) {
      _isPhoneOtpValid = false;
      _phoneOtpError = 'OTP is required';
    } else if (otp.length != 6) {
      _isPhoneOtpValid = false;
      _phoneOtpError = 'OTP must be 6 digits';
    } else {
      _isPhoneOtpValid = true;
      _phoneOtpError = '';
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

  // Toggle terms acceptance
  void toggleTermsAcceptance(bool value) {
    _acceptTerms = value;
    if (value) {
      _termsError = '';
    }
    notifyListeners();
  }

  // Validate terms acceptance
  void validateTerms() {
    if (!_acceptTerms) {
      _termsError = 'You must accept the Terms & Conditions to continue';
    } else {
      _termsError = '';
    }
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
    validateEmailOrPhoneForLogin(emailController.text); // Changed this line
    validatePassword(passwordController.text);

    if (!_isEmailValid || !_isPasswordValid) {
      return false;
    }

    setLoading(true);
    clearApiError();

    try {
      final inputValue = emailController.text.trim();
      final isEmail = _isEmail(inputValue);

      // Updated API call with type parameter
      final response = await AuthApiService.login(
        inputValue,
        passwordController.text,
        isEmail ? 'email' : 'phone',
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

      // Show failure dialog
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppUtils.showFailureDialog(
          context,
          'Login Failed',
          _apiErrorMessage.isNotEmpty
              ? _apiErrorMessage
              : 'Unable to login. Please check your credentials and try again.',
        );
      });

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
    validateTerms();

    if (!isSignupButtonEnabled) {
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

      // Show failure dialog
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppUtils.showFailureDialog(
          context,
          'Signup Failed',
          _apiErrorMessage.isNotEmpty
              ? _apiErrorMessage
              : 'Unable to create account. Please try again later.',
        );
      });

      notifyListeners();
      return false;
    }
  }

  // Forgot password method
  Future<bool> forgotPassword(BuildContext context) async {
    validateEmail(emailController.text);

    if (!_isEmailValid) {
      return false;
    }

    setLoading(true);
    clearApiError();

    try {
      await AuthApiService.resetPassword(emailController.text.trim());
      setLoading(false);

      // Show success message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppUtils.showSuccessSnackBar(
          context,
          'Password reset email sent successfully!',
        );
      });

      return true;
    } catch (e) {
      setLoading(false);
      _apiErrorMessage = e.toString();

      // Show failure dialog
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppUtils.showFailureDialog(
          context,
          'Password Reset Failed',
          _apiErrorMessage.isNotEmpty
              ? _apiErrorMessage
              : 'Unable to send password reset email. Please try again.',
        );
      });

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

  // Send Email OTP
  Future<bool> sendEmailOtp() async {
    if (!_isEmailValid || emailController.text.isEmpty || !canResendEmailOtp) {
      return false;
    }

    _isEmailVerifying = true;
    notifyListeners();

    try {
      final response = await AuthApiService.sendEmailOtp(
        emailController.text.trim(),
      );

      _showEmailOtp = true;
      _isEmailVerifying = false;

      // Start 2-minute countdown
      _startEmailOtpTimer();

      notifyListeners();
      return true;
    } catch (e) {
      _isEmailVerifying = false;
      _emailError = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Send Phone OTP
  Future<bool> sendPhoneOtp(BuildContext context) async {
    if (!_isPhoneValid || phoneController.text.isEmpty || !canResendPhoneOtp) {
      return false;
    }

    _isPhoneVerifying = true;
    notifyListeners();

    try {
      final response = await AuthApiService.sendPhoneOtp(
        phoneController.text.trim(),
        context,
      );

      _showPhoneOtp = true;
      _isPhoneVerifying = false;

      // Start 2-minute countdown
      _startPhoneOtpTimer();

      notifyListeners();
      return true;
    } catch (e) {
      _isPhoneVerifying = false;
      _phoneError = e.toString();
      notifyListeners();
      return false;
    }
  }

  void _startEmailOtpTimer() {
    _emailOtpCountdown = 120; // 2 minutes
    _emailOtpTimer?.cancel();

    _emailOtpTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_emailOtpCountdown > 0) {
        _emailOtpCountdown--;
        notifyListeners();
      } else {
        timer.cancel();
        _emailOtpTimer = null;
      }
    });
  }

  // Start phone OTP timer
  void _startPhoneOtpTimer() {
    _phoneOtpCountdown = 120; // 2 minutes
    _phoneOtpTimer?.cancel();

    _phoneOtpTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_phoneOtpCountdown > 0) {
        _phoneOtpCountdown--;
        notifyListeners();
      } else {
        timer.cancel();
        _phoneOtpTimer = null;
      }
    });
  }

  // Format countdown time
  String formatCountdown(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<bool> verifyEmailOtp() async {
    validateEmailOtp(emailOtpController.text);

    if (!_isEmailOtpValid) {
      return false;
    }

    _isEmailOtpVerifying = true;
    notifyListeners();

    try {
      final response = await AuthApiService.verifyEmailOtp(
        emailController.text.trim(),
        emailOtpController.text.trim(),
      );

      _isEmailVerified = true;
      _showEmailOtp = false;
      _isEmailOtpVerifying = false;

      // Stop timer on successful verification
      _emailOtpTimer?.cancel();
      _emailOtpTimer = null;
      _emailOtpCountdown = 0;

      notifyListeners();
      return true;
    } catch (e) {
      _isEmailOtpVerifying = false;
      _emailOtpError = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Updated Verify Phone OTP - stop timer on success
  Future<bool> verifyPhoneOtp() async {
    validatePhoneOtp(phoneOtpController.text);

    if (!_isPhoneOtpValid) {
      return false;
    }

    _isPhoneOtpVerifying = true;
    notifyListeners();

    try {
      final response = await AuthApiService.verifyPhoneOtp(
        phoneController.text.trim(),
        phoneOtpController.text.trim(),
      );

      _isPhoneVerified = true;
      _showPhoneOtp = false;
      _isPhoneOtpVerifying = false;

      // Stop timer on successful verification
      _phoneOtpTimer?.cancel();
      _phoneOtpTimer = null;
      _phoneOtpCountdown = 0;

      notifyListeners();
      return true;
    } catch (e) {
      _isPhoneOtpVerifying = false;
      _phoneOtpError = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearAllFields() {
    emailController.clear();
    passwordController.clear();
    fullNameController.clear();
    phoneController.clear();
    confirmPasswordController.clear();
    emailOtpController.clear();
    phoneOtpController.clear();
    _clearResetPasswordFields();
    _isEmailValid = true;
    _isPasswordValid = true;
    _isFullNameValid = true;
    _isPhoneValid = true;
    _isConfirmPasswordValid = true;
    _isEmailOtpValid = true;
    _isPhoneOtpValid = true;

    _emailError = '';
    _passwordError = '';
    _fullNameError = '';
    _phoneError = '';
    _confirmPasswordError = '';
    _emailOtpError = '';
    _phoneOtpError = '';
    _apiErrorMessage = '';

    _selectedGender = 'Male';
    _obscurePassword = true;
    _obscureConfirmPassword = true;
    _acceptTerms = false;
    _termsError = '';

    _isEmailVerified = false;
    _isPhoneVerified = false;
    _showEmailOtp = false;
    _showPhoneOtp = false;

    // Clear timers
    _emailOtpTimer?.cancel();
    _phoneOtpTimer?.cancel();
    _emailOtpTimer = null;
    _phoneOtpTimer = null;
    _emailOtpCountdown = 0;
    _phoneOtpCountdown = 0;

    notifyListeners();
  }

  // Updated dispose method
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    fullNameController.dispose();
    phoneController.dispose();
    confirmPasswordController.dispose();
    emailOtpController.dispose();
    phoneOtpController.dispose();
    resetOtpController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    _resetOtpTimer?.cancel();
    // Cancel timers
    _emailOtpTimer?.cancel();
    _phoneOtpTimer?.cancel();

    super.dispose();
  }
}
