import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pedalduo/views/home_screen/views/home_screen.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

import '../global/images.dart';
import '../providers/auth_provider.dart';
import '../style/colors.dart';
import '../style/texts.dart';
import 'auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _backgroundController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();

    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
    );

    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _backgroundController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    _scaleController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _fadeController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    _slideController.forward();

    // Wait for all animations to finish before checking auth
    await Future.delayed(const Duration(seconds: 1));
    await checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    final authProvider = Provider.of<UserAuthProvider>(context, listen: false);
    await authProvider.initialize();

    // Wait for 2 seconds for splash effect
    await Future.delayed(Duration(seconds: 3));

    if (authProvider.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (_) => HomeScreen()),
        );
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (_) => LoginScreen()),
        );
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double width = screenSize.width;
    final double height = screenSize.height;

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _fadeAnimation,
          _scaleAnimation,
          _slideAnimation,
          _backgroundAnimation,
        ]),
        builder: (context, child) {
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.navyBlueGrey.withOpacity(0.9),
                  AppColors.lightNavyBlueGrey.withOpacity(0.8),
                  AppColors.orangeColor.withOpacity(0.1),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Animated background particles
                ...List.generate(6, (index) {
                  return AnimatedBuilder(
                    animation: _backgroundAnimation,
                    builder: (context, child) {
                      return Positioned(
                        top:
                            height *
                            (0.1 + (index * 0.15)) *
                            _backgroundAnimation.value,
                        left:
                            width *
                            (0.1 + (index * 0.12)) *
                            _backgroundAnimation.value,
                        child: Opacity(
                          opacity: _backgroundAnimation.value * 0.3,
                          child: Container(
                            width: width * (0.04 + (index * 0.02)),
                            height: width * (0.04 + (index * 0.02)),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  index.isEven
                                      ? AppColors.orangeColor
                                      : AppColors.blueColor,
                              boxShadow: [
                                BoxShadow(
                                  color: (index.isEven
                                          ? AppColors.orangeColor
                                          : AppColors.blueColor)
                                      .withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
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
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo container with glassmorphism effect
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: width * 0.35,
                          height: width * 0.35,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(width * 0.08),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.orangeColor.withOpacity(0.3),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(width * 0.08),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.whiteColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(
                                    width * 0.08,
                                  ),
                                  border: Border.all(
                                    color: AppColors.whiteColor.withOpacity(
                                      0.2,
                                    ),
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: FadeTransition(
                                    opacity: _fadeAnimation,
                                    child: Image.asset(
                                      AppImages.logoImage2,
                                      width: width * 0.2,
                                      height: width * 0.2,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: height * 0.04),

                      // App name with slide animation
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: width * 0.08,
                              vertical: height * 0.015,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(width * 0.05),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.orangeColor.withOpacity(0.2),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(width * 0.05),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 15,
                                  sigmaY: 15,
                                ),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: width * 0.06,
                                    vertical: height * 0.01,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.whiteColor.withOpacity(
                                      0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      width * 0.05,
                                    ),
                                    border: Border.all(
                                      color: AppColors.whiteColor.withOpacity(
                                        0.2,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  child: ShaderMask(
                                    shaderCallback:
                                        (bounds) => LinearGradient(
                                          colors: [
                                            AppColors.orangeColor,
                                            AppColors.lightOrangeColor,
                                            AppColors.goldColor,
                                          ],
                                        ).createShader(bounds),
                                    child: Text(
                                      'Padel Duo',
                                      style: AppTexts.headingStyle(
                                        context: context,
                                        textColor: AppColors.whiteColor,
                                        fontSize: width * 0.12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: height * 0.02),

                      // Tagline
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Text(
                            'Organize Tournaments, Like Never Before',
                            style: AppTexts.emphasizedTextStyle(
                              context: context,
                              textColor: AppColors.whiteColor.withOpacity(0.8),
                              fontSize: width * 0.045,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: height * 0.08),

                      // Loading indicator
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          width: width * 0.15,
                          height: width * 0.15,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(width * 0.03),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.orangeColor.withOpacity(0.3),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(width * 0.03),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.whiteColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(
                                    width * 0.03,
                                  ),
                                  border: Border.all(
                                    color: AppColors.whiteColor.withOpacity(
                                      0.2,
                                    ),
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: SizedBox(
                                    width: width * 0.08,
                                    height: width * 0.08,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.orangeColor,
                                      ),
                                      strokeWidth: 3,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom decoration
                Positioned(
                  bottom: height * 0.08,
                  left: 0,
                  right: 0,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Center(
                      child: Container(
                        width: width * 0.6,
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.orangeColor.withOpacity(0.1),
                              AppColors.orangeColor,
                              AppColors.lightOrangeColor,
                              AppColors.orangeColor,
                              AppColors.orangeColor.withOpacity(0.1),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
