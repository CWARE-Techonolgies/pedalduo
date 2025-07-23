import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../global/images.dart';
import '../../providers/auth_provider.dart';
import '../../style/colors.dart';
import '../../style/texts.dart';
import 'dart:math' as math;

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

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

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
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

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
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
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double width = screenSize.width;
    final double height = screenSize.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(width * 0.02),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.whiteColor.withOpacity(0.1),
              border: Border.all(
                color: AppColors.whiteColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.arrow_back_ios,
              color: AppColors.whiteColor,
              size: width * 0.05,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
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
            // Background floating elements
            ...List.generate(4, (index) {
              return AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Positioned(
                    top: height * (0.15 + (index * 0.2)),
                    right: width * (0.05 + (index * 0.15)),
                    child: Transform.scale(
                      scale: _pulseAnimation.value * (0.5 + (index * 0.1)),
                      child: Container(
                        width: width * (0.04 + (index * 0.01)),
                        height: width * (0.04 + (index * 0.01)),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.purpleColor.withOpacity(0.3),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.purpleColor.withOpacity(0.2),
                              blurRadius: 15,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
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
                              SizedBox(height: height * 0.1),

                              // Lock icon with logo
                              Container(
                                width: width * 0.3,
                                height: width * 0.3,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    width * 0.075,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.orangeColor.withOpacity(
                                        0.3,
                                      ),
                                      blurRadius: 25,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    width * 0.075,
                                  ),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 15,
                                      sigmaY: 15,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.whiteColor.withOpacity(
                                          0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          width * 0.075,
                                        ),
                                        border: Border.all(
                                          color: AppColors.whiteColor
                                              .withOpacity(0.2),
                                          width: 2,
                                        ),
                                      ),
                                      child: Stack(
                                        children: [
                                          // Background logo
                                          Center(
                                            child: Opacity(
                                              opacity: 0.3,
                                              child: Image.asset(
                                                AppImages.logoImage,
                                                width: width * 0.15,
                                                height: width * 0.15,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),

                                          // Lock icon
                                          Center(
                                            child: Icon(
                                              Icons.lock_reset,
                                              color: AppColors.orangeColor,
                                              size: width * 0.12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: height * 0.05),

                              // Title
                              Text(
                                'Forgot Password?',
                                style: AppTexts.headingStyle(
                                  context: context,
                                  textColor: AppColors.whiteColor,
                                  fontSize: width * 0.08,
                                ),
                              ),

                              SizedBox(height: height * 0.02),

                              // Description
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: width * 0.05,
                                ),
                                child: Text(
                                  'Don\'t worry! Enter your email address and we\'ll send you a link to reset your password.',
                                  textAlign: TextAlign.center,
                                  style: AppTexts.bodyTextStyle(
                                    context: context,
                                    textColor: AppColors.whiteColor.withOpacity(
                                      0.8,
                                    ),
                                    fontSize: width * 0.04,
                                  ),
                                ),
                              ),

                              SizedBox(height: height * 0.06),

                              // Email form
                              Consumer<UserAuthProvider>(
                                builder: (context, authProvider, child) {
                                  return Column(
                                    children: [
                                      // Email field
                                      _buildGlassTextField(
                                        controller:
                                            authProvider.emailController,
                                        hint: 'Enter your email address',
                                        icon: Icons.email_outlined,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        onChanged: authProvider.validateEmail,
                                        isValid: authProvider.isEmailValid,
                                        errorText: authProvider.emailError,
                                        width: width,
                                      ),

                                      SizedBox(height: height * 0.05),

                                      // Send Reset Link button
                                      _buildGlassButton(
                                        text: 'Send Reset Link',
                                        onPressed:
                                            authProvider.isLoading
                                                ? null
                                                : () async {
                                                  bool success =
                                                      await authProvider
                                                          .forgotPassword();
                                                  if (success) {
                                                    _showSuccessDialog(context);
                                                  }
                                                },
                                        isLoading: authProvider.isLoading,
                                        width: width,
                                      ),

                                      SizedBox(height: height * 0.04),

                                      // Back to login
                                      TextButton(
                                        onPressed: () {
                                          authProvider.clearAllFields();
                                          Navigator.pop(context);
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.arrow_back_ios,
                                              color: AppColors.orangeColor,
                                              size: width * 0.04,
                                            ),
                                            SizedBox(width: width * 0.02),
                                            Text(
                                              'Back to Login',
                                              style:
                                                  AppTexts.emphasizedTextStyle(
                                                    context: context,
                                                    textColor:
                                                        AppColors.orangeColor,
                                                    fontSize: width * 0.04,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),

                              SizedBox(height: height * 0.1),

                              // Help section
                              Container(
                                padding: EdgeInsets.all(width * 0.05),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    width * 0.04,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.blueColor.withOpacity(
                                        0.1,
                                      ),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    width * 0.04,
                                  ),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 10,
                                      sigmaY: 10,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.whiteColor.withOpacity(
                                          0.05,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          width * 0.04,
                                        ),
                                        border: Border.all(
                                          color: AppColors.whiteColor
                                              .withOpacity(0.1),
                                          width: 1,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.help_outline,
                                            color: AppColors.blueColor
                                                .withOpacity(0.8),
                                            size: width * 0.08,
                                          ),
                                          SizedBox(height: height * 0.02),
                                          Text(
                                            'Need Help?',
                                            style: AppTexts.emphasizedTextStyle(
                                              context: context,
                                              textColor: AppColors.whiteColor,
                                              fontSize: width * 0.045,
                                            ),
                                          ),
                                          SizedBox(height: height * 0.01),
                                          Text(
                                            'Contact our support team if you\'re having trouble accessing your account.',
                                            textAlign: TextAlign.center,
                                            style: AppTexts.bodyTextStyle(
                                              context: context,
                                              textColor: AppColors.whiteColor
                                                  .withOpacity(0.7),
                                              fontSize: width * 0.035,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
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

void _showSuccessDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.7),
    builder: (BuildContext context) {
      return const SuccessDialog();
    },
  );
}

class SuccessDialog extends StatefulWidget {
  const SuccessDialog({super.key});

  @override
  State<SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<SuccessDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _checkController;
  late AnimationController _pulseController;
  late AnimationController _particleController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _checkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.easeOut),
    );

    _pulseController.repeat(reverse: true);
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _scaleController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _checkController.forward();
    _particleController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _checkController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double width = screenSize.width;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _scaleAnimation,
          _checkAnimation,
          _pulseAnimation,
          _particleAnimation,
        ]),
        builder: (context, child) {
          return ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: width * 0.85,
              padding: EdgeInsets.all(width * 0.06),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(width * 0.06),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.greenColor.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                  BoxShadow(
                    color: AppColors.orangeColor.withOpacity(0.2),
                    blurRadius: 40,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(width * 0.06),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.whiteColor.withOpacity(0.15),
                          AppColors.greenColor.withOpacity(0.1),
                          AppColors.whiteColor.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(width * 0.06),
                      border: Border.all(
                        color: AppColors.whiteColor.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Floating particles
                        ...List.generate(8, (index) {
                          return AnimatedBuilder(
                            animation: _particleAnimation,
                            builder: (context, child) {
                              double progress = _particleAnimation.value;
                              double angle = (index * 45) * (3.14159 / 180);
                              double radius = progress * width * 0.15;

                              return Positioned(
                                left: width * 0.35 + (radius * math.cos(angle)),
                                top: width * 0.25 + (radius * math.sin(angle)),
                                child: Opacity(
                                  opacity: 1 - progress,
                                  child: Container(
                                    width: width * 0.015,
                                    height: width * 0.015,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          index.isEven
                                              ? AppColors.greenColor
                                              : AppColors.orangeColor,
                                      boxShadow: [
                                        BoxShadow(
                                          color: (index.isEven
                                                  ? AppColors.greenColor
                                                  : AppColors.orangeColor)
                                              .withOpacity(0.6),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }),

                        // Main content
                        Padding(
                          padding: EdgeInsets.all(width * 0.04),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Success icon with check animation
                              ScaleTransition(
                                scale: _pulseAnimation,
                                child: Container(
                                  width: width * 0.2,
                                  height: width * 0.2,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.greenColor,
                                        AppColors.lightGreenColor ??
                                            AppColors.greenColor.withOpacity(
                                              0.8,
                                            ),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.greenColor.withOpacity(
                                          0.4,
                                        ),
                                        blurRadius: 20,
                                        spreadRadius: 3,
                                      ),
                                    ],
                                  ),
                                  child: AnimatedBuilder(
                                    animation: _checkAnimation,
                                    builder: (context, child) {
                                      return CustomPaint(
                                        painter: CheckMarkPainter(
                                          _checkAnimation.value,
                                        ),
                                        size: Size(width * 0.2, width * 0.2),
                                      );
                                    },
                                  ),
                                ),
                              ),

                              SizedBox(height: width * 0.06),

                              // Success title
                              Text(
                                'Email Sent!',
                                style: AppTexts.headingStyle(
                                  context: context,
                                  textColor: AppColors.whiteColor,
                                  fontSize: width * 0.06,
                                ),
                              ),

                              SizedBox(height: width * 0.03),

                              // Success message
                              Text(
                                'We\'ve sent a password reset link to your email address. Please check your inbox and follow the instructions.',
                                textAlign: TextAlign.center,
                                style: AppTexts.bodyTextStyle(
                                  context: context,
                                  textColor: AppColors.whiteColor.withOpacity(
                                    0.8,
                                  ),
                                  fontSize: width * 0.035,
                                ),
                              ),

                              SizedBox(height: width * 0.08),

                              // Action buttons
                              Row(
                                children: [
                                  // Check Email button
                                  Expanded(
                                    child: _buildGlassButton(
                                      text: 'Close',
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      isPrimary: true,
                                      width: width,
                                    ),
                                  ),

                                  SizedBox(width: width * 0.03),

                                  // Resend button
                                  Expanded(
                                    child: _buildGlassButton(
                                      text: 'Resend',
                                      onPressed: () async {
                                        Navigator.of(context).pop();
                                        // Trigger resend functionality
                                        final authProvider =
                                            Provider.of<UserAuthProvider>(
                                              context,
                                              listen: false,
                                            );
                                        bool success =
                                            await authProvider.forgotPassword();
                                        if (success) {
                                          _showSuccessDialog(context);
                                        }
                                      },
                                      isPrimary: false,
                                      width: width,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: width * 0.04),

                              // Helpful tip
                              Container(
                                padding: EdgeInsets.all(width * 0.03),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    width * 0.03,
                                  ),
                                  color: AppColors.blueColor.withOpacity(0.1),
                                  border: Border.all(
                                    color: AppColors.blueColor.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: AppColors.blueColor,
                                      size: width * 0.04,
                                    ),
                                    SizedBox(width: width * 0.02),
                                    Expanded(
                                      child: Text(
                                        'Don\'t see the email? Check your spam folder.',
                                        style: AppTexts.bodyTextStyle(
                                          context: context,
                                          textColor: AppColors.whiteColor
                                              .withOpacity(0.7),
                                          fontSize: width * 0.03,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGlassButton({
    required String text,
    required VoidCallback onPressed,
    required bool isPrimary,
    required double width,
  }) {
    return Container(
      height: width * 0.12,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(width * 0.03),
        boxShadow: [
          BoxShadow(
            color: (isPrimary ? AppColors.orangeColor : AppColors.whiteColor)
                .withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(width * 0.03),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient:
                  isPrimary
                      ? LinearGradient(
                        colors: [
                          AppColors.orangeColor.withOpacity(0.8),
                          AppColors.lightOrangeColor?.withOpacity(0.9) ??
                              AppColors.orangeColor.withOpacity(0.6),
                        ],
                      )
                      : null,
              color: isPrimary ? null : AppColors.whiteColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(width * 0.03),
              border: Border.all(
                color:
                    isPrimary
                        ? AppColors.whiteColor.withOpacity(0.3)
                        : AppColors.whiteColor.withOpacity(0.4),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
                borderRadius: BorderRadius.circular(width * 0.03),
                child: Center(
                  child: Text(
                    text,
                    style: AppTexts.emphasizedTextStyle(
                      context: context,
                      textColor: AppColors.whiteColor,
                      fontSize: width * 0.035,
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

// Custom painter for animated checkmark
class CheckMarkPainter extends CustomPainter {
  final double progress;

  CheckMarkPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white
          ..strokeWidth = 3.0
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.3;

    // Draw checkmark path
    final path = Path();

    // Start point (left part of checkmark)
    final startX = center.dx - radius * 0.5;
    final startY = center.dy;

    // Middle point (bottom of checkmark)
    final midX = center.dx - radius * 0.1;
    final midY = center.dy + radius * 0.3;

    // End point (right part of checkmark)
    final endX = center.dx + radius * 0.6;
    final endY = center.dy - radius * 0.4;

    if (progress <= 0.5) {
      // First half: draw from start to middle
      final currentProgress = progress * 2;
      final currentX = startX + (midX - startX) * currentProgress;
      final currentY = startY + (midY - startY) * currentProgress;

      path.moveTo(startX, startY);
      path.lineTo(currentX, currentY);
    } else {
      // Second half: draw from middle to end
      final currentProgress = (progress - 0.5) * 2;
      final currentX = midX + (endX - midX) * currentProgress;
      final currentY = midY + (endY - midY) * currentProgress;

      path.moveTo(startX, startY);
      path.lineTo(midX, midY);
      path.lineTo(currentX, currentY);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
