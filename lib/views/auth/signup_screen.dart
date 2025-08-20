import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pedalduo/global/constants.dart';
import 'package:pedalduo/utils/app_utils.dart';
import 'package:pedalduo/views/auth/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';
import '../../global/images.dart';
import '../../style/colors.dart';
import '../../style/texts.dart';
import '../../providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
    );
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double width = screenSize.width;
    final double height = screenSize.height;

    return Scaffold(
      body: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.navyBlueGrey,
              AppColors.lightNavyBlueGrey,
              AppColors.navyBlueGrey.withOpacity(0.9),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background particles
            ...List.generate(6, (index) {
              return Positioned(
                top: height * (0.05 + (index * 0.15)),
                left: width * (0.05 + (index * 0.12)),
                child: Container(
                  width: width * (0.02 + (index * 0.008)),
                  height: width * (0.02 + (index * 0.008)),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.blueColor.withOpacity(0.2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.blueColor.withOpacity(0.1),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              );
            }),

            // Main content
            SafeArea(
              child: SingleChildScrollView(
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    _fadeAnimation,
                    _slideAnimation,
                  ]),
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.05,
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: height * 0.05),

                              // Logo container
                              Container(
                                width: width * 0.2,
                                height: width * 0.2,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    width * 0.05,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.orangeColor.withOpacity(
                                        0.3,
                                      ),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    width * 0.05,
                                  ),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 10,
                                      sigmaY: 10,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.whiteColor.withOpacity(
                                          0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          width * 0.05,
                                        ),
                                        border: Border.all(
                                          color: AppColors.whiteColor
                                              .withOpacity(0.2),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Center(
                                        child: Image.asset(
                                          AppImages.logoImage2,
                                          width: width * 0.12,
                                          height: width * 0.12,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: height * 0.03),

                              // Create Account text
                              Text(
                                'Create Account',
                                style: AppTexts.headingStyle(
                                  context: context,
                                  textColor: AppColors.whiteColor,
                                  fontSize: width * 0.07,
                                ),
                              ),

                              SizedBox(height: height * 0.01),

                              Text(
                                'Join the cycling community today',
                                style: AppTexts.emphasizedTextStyle(
                                  context: context,
                                  textColor: AppColors.whiteColor.withOpacity(
                                    0.8,
                                  ),
                                  fontSize: width * 0.038,
                                ),
                              ),

                              SizedBox(height: height * 0.04),

                              // Signup form
                              Consumer<UserAuthProvider>(
                                builder: (context, authProvider, child) {
                                  return Column(
                                    children: [
                                      // Full Name field
                                      _buildGlassTextField(
                                        controller:
                                            authProvider.fullNameController,
                                        hint: 'Full Name',
                                        icon: Icons.person_outline,
                                        onChanged:
                                            authProvider.validateFullName,
                                        isValid: authProvider.isFullNameValid,
                                        errorText: authProvider.fullNameError,
                                        width: width,
                                      ),

                                      SizedBox(height: height * 0.02),

                                      // Email field with verification
                                      _buildVerifiableTextField(
                                        controller:
                                            authProvider.emailController,
                                        hint: 'Email Address',
                                        icon: Icons.email_outlined,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        onChanged: authProvider.validateEmail,
                                        isValid: authProvider.isEmailValid,
                                        errorText: authProvider.emailError,
                                        width: width,
                                        isVerified:
                                            authProvider.isEmailVerified,
                                        isVerifying:
                                            authProvider.isEmailVerifying,
                                        onVerify:
                                            () => _handleEmailVerification(
                                              authProvider,
                                            ),
                                        enabled: !authProvider.isEmailVerified,
                                        authProvider: authProvider,
                                        fieldType: 'email',
                                      ),

                                      // Email OTP field (show when verification is sent)
                                      if (authProvider.showEmailOtp)
                                        Column(
                                          children: [
                                            SizedBox(height: height * 0.02),
                                            _buildOtpField(
                                              controller:
                                                  authProvider
                                                      .emailOtpController,
                                              hint: 'Enter Email OTP',
                                              onChanged:
                                                  authProvider.validateEmailOtp,
                                              isValid:
                                                  authProvider.isEmailOtpValid,
                                              errorText:
                                                  authProvider.emailOtpError,
                                              width: width,
                                              isVerifying:
                                                  authProvider
                                                      .isEmailOtpVerifying,

                                              onVerify:
                                                  () =>
                                                      _handleEmailOtpVerification(
                                                        authProvider,
                                                      ),
                                            ),
                                          ],
                                        ),

                                      // Email verified indicator
                                      if (authProvider.isEmailVerified)
                                        Padding(
                                          padding: EdgeInsets.only(
                                            top: height * 0.01,
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.verified,
                                                color: AppColors.greenColor,
                                                size: width * 0.04,
                                              ),
                                              SizedBox(width: width * 0.02),
                                              Text(
                                                'Email verified successfully',
                                                style: AppTexts.bodyTextStyle(
                                                  context: context,
                                                  textColor:
                                                      AppColors.greenColor,
                                                  fontSize: width * 0.032,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                      SizedBox(height: height * 0.02),

                                      // Phone Number field with verification
                                      _buildVerifiableTextField(
                                        controller:
                                            authProvider.phoneController,
                                        hint: 'Phone Number (+923xxxxxxxxx)',
                                        icon: Icons.phone_outlined,
                                        keyboardType: TextInputType.phone,
                                        onChanged:
                                            authProvider.validatePhoneNumber,
                                        isValid: authProvider.isPhoneValid,
                                        errorText: authProvider.phoneError,
                                        width: width,
                                        isVerified:
                                            authProvider.isPhoneVerified,
                                        isVerifying:
                                            authProvider.isPhoneVerifying,
                                        onVerify:
                                            () => _handlePhoneVerification(
                                              authProvider,
                                            ),
                                        enabled: !authProvider.isPhoneVerified,
                                        authProvider: authProvider,
                                        fieldType: 'phone',
                                      ),

                                      // Phone OTP field (show when verification is sent)
                                      if (authProvider.showPhoneOtp)
                                        Column(
                                          children: [
                                            SizedBox(height: height * 0.01),
                                            Text(
                                              'As the application is currently in the Testing Mode, Use 123456 as your OTP',
                                              style:
                                                  AppTexts.emphasizedTextStyle(
                                                    context: context,
                                                    textColor: AppColors
                                                        .whiteColor
                                                        .withOpacity(0.8),
                                                    fontSize: width * 0.038,
                                                  ),
                                            ),
                                            SizedBox(height: height * 0.02),
                                            _buildOtpField(
                                              controller:
                                                  authProvider
                                                      .phoneOtpController,
                                              hint: 'Enter Phone OTP',
                                              onChanged:
                                                  authProvider.validatePhoneOtp,
                                              isValid:
                                                  authProvider.isPhoneOtpValid,
                                              errorText:
                                                  authProvider.phoneOtpError,
                                              width: width,
                                              isVerifying:
                                                  authProvider
                                                      .isPhoneOtpVerifying,
                                              onVerify:
                                                  () =>
                                                      _handlePhoneOtpVerification(
                                                        authProvider,
                                                      ),
                                            ),
                                          ],
                                        ),

                                      // Phone verified indicator
                                      if (authProvider.isPhoneVerified)
                                        Padding(
                                          padding: EdgeInsets.only(
                                            top: height * 0.01,
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.verified,
                                                color: AppColors.greenColor,
                                                size: width * 0.04,
                                              ),
                                              SizedBox(width: width * 0.02),
                                              Text(
                                                'Phone number verified successfully',
                                                style: AppTexts.bodyTextStyle(
                                                  context: context,
                                                  textColor:
                                                      AppColors.greenColor,
                                                  fontSize: width * 0.032,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                      SizedBox(height: height * 0.02),

                                      // Country and Gender Row
                                      Row(
                                        children: [
                                          // Country (Fixed to Pakistan)
                                          Expanded(
                                            child: _buildGlassContainer(
                                              width: width,
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.flag_outlined,
                                                    color: AppColors.orangeColor
                                                        .withOpacity(0.8),
                                                    size: width * 0.06,
                                                  ),
                                                  SizedBox(width: width * 0.03),
                                                  Text(
                                                    'Pakistan',
                                                    style:
                                                        AppTexts.bodyTextStyle(
                                                          context: context,
                                                          textColor:
                                                              AppColors
                                                                  .whiteColor,
                                                          fontSize:
                                                              width * 0.04,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),

                                          SizedBox(width: width * 0.03),

                                          // Gender Dropdown
                                          Expanded(
                                            child: _buildGlassContainer(
                                              width: width,
                                              child: DropdownButtonHideUnderline(
                                                child: DropdownButton<String>(
                                                  value:
                                                      authProvider
                                                          .selectedGender,
                                                  isExpanded: true,
                                                  dropdownColor:
                                                      AppColors
                                                          .lightNavyBlueGrey,
                                                  icon: Icon(
                                                    Icons.keyboard_arrow_down,
                                                    color: AppColors.whiteColor
                                                        .withOpacity(0.7),
                                                  ),
                                                  items:
                                                      authProvider.genders.map((
                                                        String gender,
                                                      ) {
                                                        return DropdownMenuItem<
                                                          String
                                                        >(
                                                          value: gender,
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                gender == 'Male'
                                                                    ? Icons.male
                                                                    : gender ==
                                                                        'Female'
                                                                    ? Icons
                                                                        .female
                                                                    : Icons
                                                                        .person,
                                                                color: AppColors
                                                                    .orangeColor
                                                                    .withOpacity(
                                                                      0.8,
                                                                    ),
                                                                size:
                                                                    width *
                                                                    0.05,
                                                              ),
                                                              SizedBox(
                                                                width:
                                                                    width *
                                                                    0.02,
                                                              ),
                                                              Text(
                                                                gender,
                                                                style: AppTexts.bodyTextStyle(
                                                                  context:
                                                                      context,
                                                                  textColor:
                                                                      AppColors
                                                                          .whiteColor,
                                                                  fontSize:
                                                                      width *
                                                                      0.04,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      }).toList(),
                                                  onChanged: (
                                                    String? newValue,
                                                  ) {
                                                    if (newValue != null) {
                                                      authProvider.selectGender(
                                                        newValue,
                                                      );
                                                    }
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      SizedBox(height: height * 0.02),

                                      // Password field
                                      _buildGlassTextField(
                                        controller:
                                            authProvider.passwordController,
                                        hint: 'Password (min 8 characters)',
                                        icon: Icons.lock_outline,
                                        obscureText:
                                            authProvider.obscurePassword,
                                        onChanged:
                                            authProvider.validatePassword,
                                        isValid: authProvider.isPasswordValid,
                                        errorText: authProvider.passwordError,
                                        width: width,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            authProvider.obscurePassword
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: AppColors.whiteColor
                                                .withOpacity(0.7),
                                          ),
                                          onPressed:
                                              authProvider
                                                  .togglePasswordVisibility,
                                        ),
                                      ),

                                      SizedBox(height: height * 0.02),

                                      // Confirm Password field
                                      _buildGlassTextField(
                                        controller:
                                            authProvider
                                                .confirmPasswordController,
                                        hint: 'Confirm Password',
                                        icon: Icons.lock_outline,
                                        obscureText:
                                            authProvider.obscureConfirmPassword,
                                        onChanged:
                                            authProvider
                                                .validateConfirmPassword,
                                        isValid:
                                            authProvider.isConfirmPasswordValid,
                                        errorText:
                                            authProvider.confirmPasswordError,
                                        width: width,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            authProvider.obscureConfirmPassword
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: AppColors.whiteColor
                                                .withOpacity(0.7),
                                          ),
                                          onPressed:
                                              authProvider
                                                  .toggleConfirmPasswordVisibility,
                                        ),
                                      ),

                                      SizedBox(height: height * 0.03),

                                      // Terms & Conditions checkbox
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Checkbox(
                                            value: authProvider.acceptTerms,
                                            onChanged: (value) {
                                              authProvider
                                                  .toggleTermsAcceptance(
                                                    value ?? false,
                                                  );
                                            },
                                            activeColor: AppColors.orangeColor,
                                            checkColor: AppColors.whiteColor,
                                            side: BorderSide(
                                              color: AppColors.whiteColor
                                                  .withOpacity(0.6),
                                              width: 1.5,
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                top: width * 0.03,
                                              ),
                                              child: RichText(
                                                text: TextSpan(
                                                  text:
                                                      'By clicking I accept the ',
                                                  style: AppTexts.bodyTextStyle(
                                                    context: context,
                                                    textColor: AppColors
                                                        .whiteColor
                                                        .withOpacity(0.8),
                                                    fontSize: width * 0.035,
                                                  ),
                                                  children: [
                                                    WidgetSpan(
                                                      child: GestureDetector(
                                                        onTap:
                                                            _launchTermsAndConditions,
                                                        child: Text(
                                                          'Terms & Conditions',
                                                          style: AppTexts.emphasizedTextStyle(
                                                            context: context,
                                                            textColor:
                                                                AppColors
                                                                    .orangeColor,
                                                            fontSize:
                                                                width * 0.035,
                                                          ).copyWith(
                                                            decoration:
                                                                TextDecoration
                                                                    .underline,
                                                            decorationColor:
                                                                AppColors
                                                                    .orangeColor,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text: ' and ',
                                                      style:
                                                          AppTexts.bodyTextStyle(
                                                            context: context,
                                                            textColor: AppColors
                                                                .whiteColor
                                                                .withOpacity(
                                                                  0.8,
                                                                ),
                                                            fontSize:
                                                                width * 0.035,
                                                          ),
                                                    ),
                                                    WidgetSpan(
                                                      child: GestureDetector(
                                                        onTap:
                                                            _launchPrivacyPolicy,
                                                        child: Text(
                                                          'Privacy Policy',
                                                          style: AppTexts.emphasizedTextStyle(
                                                            context: context,
                                                            textColor:
                                                                AppColors
                                                                    .orangeColor,
                                                            fontSize:
                                                                width * 0.035,
                                                          ).copyWith(
                                                            decoration:
                                                                TextDecoration
                                                                    .underline,
                                                            decorationColor:
                                                                AppColors
                                                                    .orangeColor,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      if (!authProvider.acceptTerms &&
                                          authProvider.termsError.isNotEmpty)
                                        Padding(
                                          padding: EdgeInsets.only(
                                            top: width * 0.02,
                                            left: width * 0.04,
                                          ),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              authProvider.termsError,
                                              style: AppTexts.bodyTextStyle(
                                                context: context,
                                                textColor: AppColors.redColor,
                                                fontSize: width * 0.03,
                                              ),
                                            ),
                                          ),
                                        ),

                                      SizedBox(height: height * 0.03),

                                      // Sign Up button
                                      _buildGlassButton(
                                        text: 'Create Account',
                                        onPressed:
                                            authProvider.isSignupButtonEnabled &&
                                                    !authProvider.isLoading
                                                ? () async {
                                                  bool success =
                                                      await authProvider.signup(
                                                        context,
                                                      );
                                                  if (success) {
                                                    AppUtils.showSuccessSnackBar(
                                                      context,
                                                      'Account Created Successfully',
                                                    );
                                                  }
                                                }
                                                : null,
                                        isLoading: authProvider.isLoading,
                                        isEnabled:
                                            authProvider.isSignupButtonEnabled,
                                        width: width,
                                      ),

                                      SizedBox(height: height * 0.03),

                                      // Sign in link
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Already have an account? ",
                                            style: AppTexts.bodyTextStyle(
                                              context: context,
                                              textColor: AppColors.whiteColor
                                                  .withOpacity(0.7),
                                              fontSize: width * 0.035,
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              authProvider.clearAllFields();
                                              Navigator.pushReplacement(
                                                context,
                                                CupertinoPageRoute(
                                                  builder: (_) => LoginScreen(),
                                                ),
                                              );
                                            },
                                            child: Text(
                                              'Sign In',
                                              style:
                                                  AppTexts.emphasizedTextStyle(
                                                    context: context,
                                                    textColor:
                                                        AppColors.orangeColor,
                                                    fontSize: width * 0.035,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),

                              SizedBox(height: height * 0.05),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Handle email verification
  Future<void> _handleEmailVerification(UserAuthProvider authProvider) async {
    bool success = await authProvider.sendEmailOtp();
    if (success) {
      AppUtils.showSuccessSnackBar(
        context,
        'OTP sent to your email successfully!',
      );
    }
  }

  // Handle email OTP verification
  Future<void> _handleEmailOtpVerification(
    UserAuthProvider authProvider,
  ) async {
    bool success = await authProvider.verifyEmailOtp();
    if (success) {
      AppUtils.showSuccessSnackBar(context, 'Email verified successfully!');
    }
  }

  // Handle phone verification
  Future<void> _handlePhoneVerification(UserAuthProvider authProvider) async {
    bool success = await authProvider.sendPhoneOtp(context);
    if (success) {
      AppUtils.showSuccessSnackBar(
        context,
        'OTP sent to your phone successfully!',
      );
    }
  }

  // Handle phone OTP verification
  Future<void> _handlePhoneOtpVerification(
    UserAuthProvider authProvider,
  ) async {
    bool success = await authProvider.verifyPhoneOtp();
    if (success) {
      AppUtils.showSuccessSnackBar(
        context,
        'Phone number verified successfully!',
      );
    }
  }

  Widget _buildVerifiableTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required double width,
    TextInputType keyboardType = TextInputType.text,
    required Function(String) onChanged,
    required bool isValid,
    required String errorText,
    required bool isVerified,
    required bool isVerifying,
    required VoidCallback onVerify,
    required UserAuthProvider authProvider, // Add this parameter
    required String fieldType, // Add this to distinguish email/phone
    bool enabled = true,
  }) {
    // Determine if this is email or phone field
    bool canResend = fieldType == 'email'
        ? authProvider.canResendEmailOtp
        : authProvider.canResendPhoneOtp;

    int countdown = fieldType == 'email'
        ? authProvider.emailOtpCountdown
        : authProvider.phoneOtpCountdown;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(width * 0.04),
            boxShadow: [
              BoxShadow(
                color: AppColors.orangeColor.withOpacity(0.1),
                blurRadius: 15,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(width * 0.04),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.whiteColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(width * 0.04),
                  border: Border.all(
                    color: isVerified
                        ? AppColors.greenColor.withOpacity(0.8)
                        : isValid
                        ? AppColors.whiteColor.withOpacity(0.3)
                        : AppColors.redColor.withOpacity(0.6),
                    width: 1.5,
                  ),
                ),
                child: TextFormField(
                  controller: controller,
                  keyboardType: keyboardType,
                  onChanged: onChanged,
                  enabled: enabled,
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: enabled
                        ? AppColors.whiteColor
                        : AppColors.whiteColor.withOpacity(0.6),
                    fontSize: width * 0.04,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: AppTexts.bodyTextStyle(
                      context: context,
                      textColor: AppColors.whiteColor.withOpacity(0.6),
                      fontSize: width * 0.04,
                    ),
                    prefixIcon: Icon(
                      isVerified ? Icons.verified : icon,
                      color: isVerified
                          ? AppColors.greenColor
                          : AppColors.orangeColor.withOpacity(0.8),
                      size: width * 0.06,
                    ),
                    suffixIcon: enabled &&
                        isValid &&
                        controller.text.isNotEmpty &&
                        !isVerified
                        ? Container(
                      margin: EdgeInsets.all(8),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: (isVerifying || !canResend) ? null : onVerify,
                          borderRadius: BorderRadius.circular(width * 0.02),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: width * 0.03,
                              vertical: width * 0.02,
                            ),
                            decoration: BoxDecoration(
                              color: (isVerifying || !canResend)
                                  ? Colors.grey.withOpacity(0.6)
                                  : AppColors.orangeColor.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(width * 0.02),
                            ),
                            child: isVerifying
                                ? SizedBox(
                              width: width * 0.04,
                              height: width * 0.04,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.whiteColor),
                              ),
                            )
                                : !canResend
                                ? Text(
                              authProvider.formatCountdown(countdown),
                              style: AppTexts.bodyTextStyle(
                                context: context,
                                textColor: AppColors.whiteColor,
                                fontSize: width * 0.028,
                              ),
                            )
                                : Text(
                              'Verify',
                              style: AppTexts.bodyTextStyle(
                                context: context,
                                textColor: AppColors.whiteColor,
                                fontSize: width * 0.032,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                        : null,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: width * 0.04,
                      vertical: width * 0.04,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (!isValid && errorText.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: width * 0.02, left: width * 0.04),
            child: Text(
              errorText,
              style: AppTexts.bodyTextStyle(
                context: context,
                textColor: AppColors.redColor,
                fontSize: width * 0.03,
              ),
            ),
          ),
        // Show cooldown message
        if (!canResend && countdown > 0 && !isVerified)
          Padding(
            padding: EdgeInsets.only(top: width * 0.01, left: width * 0.04),
            child: Text(
              'You can request a new OTP in ${authProvider.formatCountdown(countdown)}',
              style: AppTexts.bodyTextStyle(
                context: context,
                textColor: AppColors.whiteColor.withOpacity(0.7),
                fontSize: width * 0.03,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOtpField({
    required TextEditingController controller,
    required String hint,
    required Function(String) onChanged,
    required bool isValid,
    required String errorText,
    required double width,
    required bool isVerifying,
    required VoidCallback onVerify,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(width * 0.04),
            boxShadow: [
              BoxShadow(
                color: AppColors.blueColor.withOpacity(0.1),
                blurRadius: 15,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(width * 0.04),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.whiteColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(width * 0.04),
                  border: Border.all(
                    color:
                        isValid
                            ? AppColors.blueColor.withOpacity(0.6)
                            : AppColors.redColor.withOpacity(0.6),
                    width: 1.5,
                  ),
                ),
                child: TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  onChanged: onChanged,
                  maxLength: 6,
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.whiteColor,
                    fontSize: width * 0.04,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: AppTexts.bodyTextStyle(
                      context: context,
                      textColor: AppColors.whiteColor.withOpacity(0.6),
                      fontSize: width * 0.04,
                    ),
                    prefixIcon: Icon(
                      Icons.security,
                      color: AppColors.blueColor.withOpacity(0.8),
                      size: width * 0.06,
                    ),
                    suffixIcon:
                        isValid && controller.text.length == 6
                            ? Container(
                              margin: EdgeInsets.all(8),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: isVerifying ? null : onVerify,
                                  borderRadius: BorderRadius.circular(
                                    width * 0.02,
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: width * 0.03,
                                      vertical: width * 0.02,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.blueColor.withOpacity(
                                        0.8,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        width * 0.02,
                                      ),
                                    ),
                                    child:
                                        isVerifying
                                            ? SizedBox(
                                              width: width * 0.04,
                                              height: width * 0.04,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(AppColors.whiteColor),
                                              ),
                                            )
                                            : Text(
                                              'Verify',
                                              style: AppTexts.bodyTextStyle(
                                                context: context,
                                                textColor: AppColors.whiteColor,
                                                fontSize: width * 0.032,
                                              ),
                                            ),
                                  ),
                                ),
                              ),
                            )
                            : null,
                    border: InputBorder.none,
                    counterText: '',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: width * 0.04,
                      vertical: width * 0.04,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (!isValid && errorText.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: width * 0.02, left: width * 0.04),
            child: Text(
              errorText,
              style: AppTexts.bodyTextStyle(
                context: context,
                textColor: AppColors.redColor,
                fontSize: width * 0.03,
              ),
            ),
          ),
      ],
    );
  }

  // URL launcher methods
  Future<void> _launchTermsAndConditions() async {
    const url = AppConstants.termsAndConditions;
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        AppUtils.showFailureSnackBar(
          context,
          'Could not open Terms & Conditions',
        );
      }
    }
  }

  Future<void> _launchPrivacyPolicy() async {
    const url = AppConstants.privacyPolicy;
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        AppUtils.showFailureSnackBar(context, 'Could not open Privacy Policy');
      }
    }
  }

  Widget _buildGlassContainer({required double width, required Widget child}) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(width * 0.04),
        boxShadow: [
          BoxShadow(
            color: AppColors.orangeColor.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(width * 0.04),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.04,
              vertical: width * 0.04,
            ),
            decoration: BoxDecoration(
              color: AppColors.whiteColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(width * 0.04),
              border: Border.all(
                color: AppColors.whiteColor.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required double width,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    required Function(String) onChanged,
    required bool isValid,
    required String errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(width * 0.04),
            boxShadow: [
              BoxShadow(
                color: AppColors.orangeColor.withOpacity(0.1),
                blurRadius: 15,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(width * 0.04),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.whiteColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(width * 0.04),
                  border: Border.all(
                    color:
                        isValid
                            ? AppColors.whiteColor.withOpacity(0.3)
                            : AppColors.redColor.withOpacity(0.6),
                    width: 1.5,
                  ),
                ),
                child: TextFormField(
                  controller: controller,
                  keyboardType: keyboardType,
                  obscureText: obscureText,
                  onChanged: onChanged,
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.whiteColor,
                    fontSize: width * 0.04,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: AppTexts.bodyTextStyle(
                      context: context,
                      textColor: AppColors.whiteColor.withOpacity(0.6),
                      fontSize: width * 0.04,
                    ),
                    prefixIcon: Icon(
                      icon,
                      color: AppColors.orangeColor.withOpacity(0.8),
                      size: width * 0.06,
                    ),
                    suffixIcon: suffixIcon,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: width * 0.04,
                      vertical: width * 0.04,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (!isValid && errorText.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: width * 0.02, left: width * 0.04),
            child: Text(
              errorText,
              style: AppTexts.bodyTextStyle(
                context: context,
                textColor: AppColors.redColor,
                fontSize: width * 0.03,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGlassButton({
    required String text,
    required VoidCallback? onPressed,
    required bool isLoading,
    required double width,
    required bool isEnabled,
  }) {
    final borderRadius = BorderRadius.circular(width * 0.04);

    return Container(
      width: double.infinity,
      height: width * 0.14,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color:
                isEnabled
                    ? AppColors.orangeColor.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors:
                    isEnabled
                        ? [
                          AppColors.orangeColor.withOpacity(0.8),
                          AppColors.lightOrangeColor.withOpacity(0.9),
                        ]
                        : [
                          Colors.grey.withOpacity(0.6),
                          Colors.grey.withOpacity(0.6),
                        ],
              ),
              borderRadius: borderRadius,
              border: Border.all(
                color: AppColors.whiteColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isEnabled ? onPressed : null,
                borderRadius: borderRadius,
                child: Center(
                  child:
                      isLoading
                          ? SizedBox(
                            width: width * 0.06,
                            height: width * 0.06,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.whiteColor,
                              ),
                              strokeWidth: 2,
                            ),
                          )
                          : Text(
                            text,
                            style: AppTexts.emphasizedTextStyle(
                              context: context,
                              textColor: AppColors.whiteColor,
                              fontSize: width * 0.045,
                            ),
                          ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
