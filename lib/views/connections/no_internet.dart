import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../style/colors.dart';
import '../../style/texts.dart';
import '../../providers/connectivity_provider.dart';

class NoInternetScreen extends StatefulWidget {
  const NoInternetScreen({super.key});

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _floatController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _floatAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _floatController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.orangeColor,
              AppColors.lightOrangeColor,
              AppColors.darkOrangeColor,
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: CustomPaint(
          painter: NoInternetBackgroundPainter(),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated WiFi Icon
                  AnimatedBuilder(
                    animation: Listenable.merge([_pulseAnimation, _floatAnimation]),
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _floatAnimation.value),
                        child: Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: screenWidth * 0.4,
                            height: screenWidth * 0.4,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.whiteColor.withOpacity(0.15),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.whiteColor.withOpacity(0.2),
                                  blurRadius: 30,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.wifi_off_rounded,
                              size: screenWidth * 0.2,
                              color: AppColors.whiteColor,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: screenHeight * 0.06),

                  // Main Title
                  Text(
                    'Oops! No Internet',
                    textAlign: TextAlign.center,
                    style: AppTexts.emphasizedTextStyle(
                      context: context,
                      textColor: AppColors.whiteColor,
                      fontSize: screenWidth * 0.07,
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  // Subtitle
                  Text(
                    'It looks like you\'re not connected to the internet.\nPlease check your connection and try again.',
                    textAlign: TextAlign.center,
                    style: AppTexts.emphasizedTextStyle(
                      context: context,
                      textColor: AppColors.whiteColor.withOpacity(0.8),
                      fontSize: screenWidth * 0.04,
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.08),

                  // Retry Button
                  Consumer<ConnectivityProvider>(
                    builder: (context, connectivity, child) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: connectivity.isCheckingConnection
                            ? screenWidth * 0.15
                            : screenWidth * 0.6,
                        height: screenWidth * 0.15,
                        child: ElevatedButton(
                          onPressed: connectivity.isCheckingConnection
                              ? null
                              : () => connectivity.checkConnection(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.whiteColor,
                            foregroundColor: AppColors.greenColor,
                            elevation: 8,
                            shadowColor: AppColors.blackColor.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                connectivity.isCheckingConnection ? 30 : 15,
                              ),
                            ),
                          ),
                          child: connectivity.isCheckingConnection
                              ? AnimatedBuilder(
                            animation: _rotateController,
                            builder: (context, child) {
                              return Transform.rotate(
                                angle: _rotateAnimation.value * 2 * 3.14159,
                                child: const Icon(
                                  Icons.refresh_rounded,
                                  size: 30,
                                ),
                              );
                            },
                          )
                              : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.refresh_rounded,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Try Again',
                                style: AppTexts.emphasizedTextStyle(
                                  context: context,
                                  textColor: AppColors.greenColor,
                                  fontSize: screenWidth * 0.045,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: screenHeight * 0.04),

                  // Tips Section
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.05),
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.whiteColor.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Quick Tips:',
                          style: AppTexts.emphasizedTextStyle(
                            context: context,
                            textColor: AppColors.whiteColor,
                            fontSize: screenWidth * 0.045,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        _buildTipItem(
                          context,
                          Icons.wifi_rounded,
                          'Check your WiFi connection',
                          screenWidth,
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        _buildTipItem(
                          context,
                          Icons.signal_cellular_alt_rounded,
                          'Verify mobile data is enabled',
                          screenWidth,
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        _buildTipItem(
                          context,
                          Icons.router_rounded,
                          'Restart your router if needed',
                          screenWidth,
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
  }

  Widget _buildTipItem(
      BuildContext context,
      IconData icon,
      String text,
      double screenWidth,
      ) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.whiteColor.withOpacity(0.8),
          size: screenWidth * 0.05,
        ),
        SizedBox(width: screenWidth * 0.03),
        Expanded(
          child: Text(
            text,
            style: AppTexts.emphasizedTextStyle(
              context: context,
              textColor: AppColors.whiteColor.withOpacity(0.8),
              fontSize: screenWidth * 0.035,
            ),
          ),
        ),
      ],
    );
  }
}

class NoInternetBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;

    // Draw floating network symbols
    _drawNetworkSymbols(canvas, size);
    _drawDecorativeElements(canvas, size);
  }

  void _drawNetworkSymbols(Canvas canvas, Size size) {
    final Paint symbolPaint = Paint()
      ..color = AppColors.whiteColor.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw WiFi symbols
    final List<Offset> wifiPositions = [
      Offset(size.width * 0.1, size.height * 0.2),
      Offset(size.width * 0.9, size.height * 0.15),
      Offset(size.width * 0.15, size.height * 0.8),
      Offset(size.width * 0.85, size.height * 0.75),
    ];

    for (var position in wifiPositions) {
      _drawWiFiSymbol(canvas, position, symbolPaint);
    }
  }

  void _drawWiFiSymbol(Canvas canvas, Offset center, Paint paint) {
    const double radius = 20;

    // Draw three arcs for WiFi symbol
    for (int i = 1; i <= 3; i++) {
      final rect = Rect.fromCircle(
        center: center,
        radius: radius * i * 0.5,
      );
      canvas.drawArc(
        rect,
        -0.8,
        1.6,
        false,
        paint,
      );
    }

    // Draw center dot
    canvas.drawCircle(center, 3, paint..style = PaintingStyle.fill);
    paint.style = PaintingStyle.stroke;
  }

  void _drawDecorativeElements(Canvas canvas, Size size) {
    final Paint elementPaint = Paint()
      ..color = AppColors.whiteColor.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // Draw floating circles
    final List<Map<String, dynamic>> circles = [
      {'center': Offset(size.width * 0.2, size.height * 0.3), 'radius': 40.0},
      {'center': Offset(size.width * 0.8, size.height * 0.4), 'radius': 60.0},
      {'center': Offset(size.width * 0.3, size.height * 0.7), 'radius': 30.0},
      {'center': Offset(size.width * 0.7, size.height * 0.9), 'radius': 45.0},
    ];

    for (var circle in circles) {
      canvas.drawCircle(circle['center'], circle['radius'], elementPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}