import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pedalduo/views/auth/forget_password.dart';
import 'package:pedalduo/views/auth/signup_screen.dart';
import 'package:pedalduo/views/home_screen/views/home_screen.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../global/images.dart';
import '../../providers/auth_provider.dart';
import '../../style/colors.dart';
import '../../style/texts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
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
            ...List.generate(5, (index) {
              return Positioned(
                top: height * (0.1 + (index * 0.18)),
                right: width * (0.1 + (index * 0.15)),
                child: Container(
                  width: width * (0.03 + (index * 0.01)),
                  height: width * (0.03 + (index * 0.01)),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.orangeColor.withOpacity(0.2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.orangeColor.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
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
                              SizedBox(height: height * 0.08),

                              // Logo container
                              Container(
                                width: width * 0.25,
                                height: width * 0.25,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    width * 0.06,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.orangeColor.withOpacity(
                                        0.3,
                                      ),
                                      blurRadius: 20,
                                      spreadRadius: 3,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    width * 0.06,
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
                                          width * 0.06,
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
                                          width: width * 0.15,
                                          height: width * 0.15,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: height * 0.04),

                              // Welcome text
                              Text(
                                'Welcome Back!',
                                style: AppTexts.headingStyle(
                                  context: context,
                                  textColor: AppColors.whiteColor,
                                  fontSize: width * 0.08,
                                ),
                              ),

                              SizedBox(height: height * 0.01),

                              Text(
                                'Sign in to continue your journey',
                                style: AppTexts.emphasizedTextStyle(
                                  context: context,
                                  textColor: AppColors.whiteColor.withOpacity(
                                    0.8,
                                  ),
                                  fontSize: width * 0.04,
                                ),
                              ),

                              SizedBox(height: height * 0.05),

                              // Login form
                              Consumer<UserAuthProvider>(
                                builder: (context, authProvider, child) {
                                  return Column(
                                    children: [
                                      // Email field
                                      _buildGlassTextField(
                                        controller:
                                            authProvider.emailController,
                                        hint:
                                            'Enter your email or phone number',
                                        icon: Icons.security,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        onChanged:
                                            authProvider
                                                .validateEmailOrPhoneForLogin,
                                        isValid: authProvider.isEmailValid,
                                        errorText: authProvider.emailError,
                                        width: width,
                                      ),

                                      SizedBox(height: height * 0.025),

                                      // Password field
                                      _buildGlassTextField(
                                        controller:
                                            authProvider.passwordController,
                                        hint: 'Password',
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

                                      // Forgot password
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              CupertinoPageRoute(
                                                builder:
                                                    (context) =>
                                                        const ForgotPasswordScreen(),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            'Forgot Password?',
                                            style: AppTexts.emphasizedTextStyle(
                                              context: context,
                                              textColor: AppColors.orangeColor,
                                              fontSize: width * 0.035,
                                            ),
                                          ),
                                        ),
                                      ),

                                      SizedBox(height: height * 0.04),

                                      // Login button
                                      _buildGlassButton(
                                        text: 'Sign In',
                                        onPressed:
                                            authProvider.isLoading
                                                ? null
                                                : () async {
                                                  bool success =
                                                      await authProvider.login(
                                                        context,
                                                      );
                                                  if (success) {
                                                    // Navigate to home screen
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          'Login successful!',
                                                        ),
                                                      ),
                                                    );
                                                    Navigator.pushReplacement(
                                                      context,
                                                      CupertinoPageRoute(
                                                        builder:
                                                            (_) => HomeScreen(),
                                                      ),
                                                    );
                                                  }
                                                },
                                        isLoading: authProvider.isLoading,
                                        width: width,
                                      ),

                                      SizedBox(height: height * 0.04),

                                      // Sign up link
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Don't have an account? ",
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
                                              Navigator.push(
                                                context,
                                                CupertinoPageRoute(
                                                  builder:
                                                      (context) =>
                                                          const SignupScreen(),
                                                ),
                                              );
                                            },
                                            child: Text(
                                              'Sign Up',
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
  }) {
    return Container(
      width: double.infinity,
      height: width * 0.14,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(width * 0.04),
        boxShadow: [
          BoxShadow(
            color: AppColors.orangeColor.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(width * 0.04),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.orangeColor.withOpacity(0.8),
                  AppColors.lightOrangeColor.withOpacity(0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(width * 0.04),
              border: Border.all(
                color: AppColors.whiteColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
                borderRadius: BorderRadius.circular(width * 0.04),
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
