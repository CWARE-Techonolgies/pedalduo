import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/server_health_provider.dart';
import '../../style/colors.dart';
import '../../style/texts.dart';

class ServerDownScreen extends StatefulWidget {
  const ServerDownScreen({super.key});

  @override
  State<ServerDownScreen> createState() => _ServerDownScreenState();
}

class _ServerDownScreenState extends State<ServerDownScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _floatController;
  late AnimationController _rotateController;
  late AnimationController _sparkleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _sparkleAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);

    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3500),
      vsync: this,
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    )..repeat();

    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _floatAnimation = Tween<double>(begin: -15, end: 15).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.linear),
    );

    _sparkleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _sparkleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _floatController.dispose();
    _rotateController.dispose();
    _sparkleController.dispose();
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
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.orangeColor,
              AppColors.lightOrangeColor,
              AppColors.darkOrangeColor,
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: CustomPaint(
          painter: ServerDownBackgroundPainter(_sparkleAnimation),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Server Icon
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
                                  color: AppColors.whiteColor.withOpacity(0.3),
                                  blurRadius: 40,
                                  spreadRadius: 15,
                                ),
                                BoxShadow(
                                  color: AppColors.greenColor.withOpacity(0.5),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  Icons.dns_outlined,
                                  size: screenWidth * 0.18,
                                  color: AppColors.whiteColor,
                                ),
                                Positioned(
                                  right: screenWidth * 0.08,
                                  bottom: screenWidth * 0.08,
                                  child: Container(
                                    width: screenWidth * 0.08,
                                    height: screenWidth * 0.08,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.red.shade400,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.red.withOpacity(0.5),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      size: screenWidth * 0.05,
                                      color: AppColors.whiteColor,
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

                  SizedBox(height: screenHeight * 0.06),

                  // Main Title
                  Text(
                    'Server is Down',
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
                    'We\'re experiencing technical difficulties.\nOur team is working hard to fix this issue.',
                    textAlign: TextAlign.center,
                    style: AppTexts.emphasizedTextStyle(
                      context: context,
                      textColor: AppColors.whiteColor.withOpacity(0.8),
                      fontSize: screenWidth * 0.04,
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.08),

                  // Retry Button
                  Consumer<ServerHealthProvider>(
                    builder: (context, serverHealth, child) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: serverHealth.isCheckingHealth
                            ? screenWidth * 0.15
                            : screenWidth * 0.6,
                        height: screenWidth * 0.15,
                        child: ElevatedButton(
                          onPressed: serverHealth.isCheckingHealth
                              ? null
                              : () => serverHealth.checkServerHealth(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.whiteColor,
                            foregroundColor: AppColors.greenColor,
                            elevation: 12,
                            shadowColor: AppColors.blackColor.withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                serverHealth.isCheckingHealth ? 30 : 15,
                              ),
                            ),
                          ),
                          child: serverHealth.isCheckingHealth
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
                                'Check Again',
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

                  // Status Information
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.05),
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.whiteColor.withOpacity(0.25),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.blackColor.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.whiteColor,
                              size: screenWidth * 0.05,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'What\'s happening?',
                              style: AppTexts.emphasizedTextStyle(
                                context: context,
                                textColor: AppColors.whiteColor,
                                fontSize: screenWidth * 0.045,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        _buildStatusItem(
                          context,
                          Icons.cloud_sync,
                          'Server maintenance in progress',
                          screenWidth,
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        _buildStatusItem(
                          context,
                          Icons.engineering_outlined,
                          'Our team is working on fixes',
                          screenWidth,
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        _buildStatusItem(
                          context,
                          Icons.schedule_outlined,
                          'Expected resolution: Shortly',
                          screenWidth,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.03),

                  // Support Contact
                  Text(
                    'Need immediate help? Contact our support team',
                    textAlign: TextAlign.center,
                    style: AppTexts.emphasizedTextStyle(
                      context: context,
                      textColor: AppColors.whiteColor.withOpacity(0.7),
                      fontSize: screenWidth * 0.032,
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

  Widget _buildStatusItem(
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

class ServerDownBackgroundPainter extends CustomPainter {
  final Animation<double> sparkleAnimation;

  ServerDownBackgroundPainter(this.sparkleAnimation) : super(repaint: sparkleAnimation);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;

    // Draw server rack symbols
    _drawServerRacks(canvas, size);
    _drawDecorativeElements(canvas, size);
    _drawSparkles(canvas, size);
  }

  void _drawServerRacks(Canvas canvas, Size size) {
    final Paint serverPaint = Paint()
      ..color = AppColors.whiteColor.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    final Paint strokePaint = Paint()
      ..color = AppColors.whiteColor.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw server rack silhouettes
    final List<Offset> rackPositions = [
      Offset(size.width * 0.1, size.height * 0.25),
      Offset(size.width * 0.9, size.height * 0.15),
      Offset(size.width * 0.15, size.height * 0.75),
      Offset(size.width * 0.85, size.height * 0.8),
    ];

    for (var position in rackPositions) {
      _drawServerRack(canvas, position, serverPaint, strokePaint);
    }
  }

  void _drawServerRack(Canvas canvas, Offset position, Paint fillPaint, Paint strokePaint) {
    const double width = 40;
    const double height = 60;

    // Main rack body
    final Rect mainRect = Rect.fromCenter(
      center: position,
      width: width,
      height: height,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(mainRect, const Radius.circular(5)),
      fillPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(mainRect, const Radius.circular(5)),
      strokePaint,
    );

    // Server units (horizontal lines)
    for (int i = 0; i < 4; i++) {
      final double y = position.dy - height/2 + 10 + (i * 12);
      canvas.drawLine(
        Offset(position.dx - width/2 + 8, y),
        Offset(position.dx + width/2 - 8, y),
        strokePaint,
      );
    }

    // Status lights
    final Paint errorPaint = Paint()
      ..color = Colors.red.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(position.dx + width/2 - 8, position.dy - height/2 + 5),
      2,
      errorPaint,
    );
  }

  void _drawDecorativeElements(Canvas canvas, Size size) {
    final Paint elementPaint = Paint()
      ..color = AppColors.whiteColor.withOpacity(0.06)
      ..style = PaintingStyle.fill;

    // Draw floating geometric shapes
    final List<Map<String, dynamic>> shapes = [
      {'center': Offset(size.width * 0.2, size.height * 0.4), 'radius': 35.0},
      {'center': Offset(size.width * 0.8, size.height * 0.3), 'radius': 50.0},
      {'center': Offset(size.width * 0.3, size.height * 0.8), 'radius': 25.0},
      {'center': Offset(size.width * 0.7, size.height * 0.85), 'radius': 40.0},
    ];

    for (var shape in shapes) {
      canvas.drawCircle(shape['center'], shape['radius'], elementPaint);
    }
  }

  void _drawSparkles(Canvas canvas, Size size) {
    final Paint sparklePaint = Paint()
      ..color = AppColors.whiteColor.withOpacity(0.3 * sparkleAnimation.value)
      ..style = PaintingStyle.fill;

    // Draw animated sparkles
    final List<Offset> sparklePositions = [
      Offset(size.width * 0.15, size.height * 0.2),
      Offset(size.width * 0.85, size.height * 0.25),
      Offset(size.width * 0.25, size.height * 0.7),
      Offset(size.width * 0.75, size.height * 0.75),
      Offset(size.width * 0.5, size.height * 0.15),
    ];

    for (var position in sparklePositions) {
      _drawSparkle(canvas, position, sparklePaint);
    }
  }

  void _drawSparkle(Canvas canvas, Offset center, Paint paint) {
    const double size = 8;

    // Draw cross-shaped sparkle
    canvas.drawLine(
      Offset(center.dx - size, center.dy),
      Offset(center.dx + size, center.dy),
      paint..strokeWidth = 2,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - size),
      Offset(center.dx, center.dy + size),
      paint,
    );

    // Draw diagonal lines
    canvas.drawLine(
      Offset(center.dx - size * 0.7, center.dy - size * 0.7),
      Offset(center.dx + size * 0.7, center.dy + size * 0.7),
      paint..strokeWidth = 1,
    );
    canvas.drawLine(
      Offset(center.dx - size * 0.7, center.dy + size * 0.7),
      Offset(center.dx + size * 0.7, center.dy - size * 0.7),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}