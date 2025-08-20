import 'package:flutter/material.dart';
import 'package:pedalduo/style/colors.dart';

class BeautifulSnackBar {
  static void showTopSnackBar({
    required BuildContext context,
    required String message,
    required String subtitle,
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    Duration duration = const Duration(seconds: 4),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder:
          (context) => TopSnackBarWidget(
            message: message,
            subtitle: subtitle,
            icon: icon,
            backgroundColor: backgroundColor,
            iconColor: iconColor,
            onDismiss: () => overlayEntry.remove(),
            duration: duration,
          ),
    );

    overlay.insert(overlayEntry);
  }

  static void showInviteLinkSuccess(BuildContext context) {
    showTopSnackBar(
      context: context,
      message: 'Invite Link Shared Successfully!',
      subtitle: 'Link copied to clipboard & sent via email',
      icon: Icons.check_circle,
      backgroundColor: const Color(0xFF1B2B3A), // Dark success background
      iconColor: const Color(0xFF4CAF50), // Green success icon
    );
  }

  static void showError(BuildContext context, String errorMessage) {
    showTopSnackBar(
      context: context,
      message: 'Failed to Share Invite Link',
      subtitle: errorMessage,
      icon: Icons.error,
      backgroundColor: const Color(0xFF2D1B1B), // Dark error background
      iconColor: const Color(0xFFFF5252), // Red error icon
    );
  }

  static void showLoading(BuildContext context) {
    showTopSnackBar(
      context: context,
      message: 'Generating Invite Link...',
      subtitle: 'Please wait while we prepare your invite link',
      icon: Icons.hourglass_empty,
      backgroundColor: const Color(0xFF1A2332),
      iconColor: AppColors.orangeColor,
    );
  }
}

class TopSnackBarWidget extends StatefulWidget {
  final String message;
  final String subtitle;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onDismiss;
  final Duration duration;

  const TopSnackBarWidget({
    Key? key,
    required this.message,
    required this.subtitle,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.onDismiss,
    required this.duration,
  }) : super(key: key);

  @override
  State<TopSnackBarWidget> createState() => _TopSnackBarWidgetState();
}

class _TopSnackBarWidgetState extends State<TopSnackBarWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      reverseDuration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
        reverseCurve: Curves.easeInBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();

    // Auto dismiss after duration
    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() {
    _animationController.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: _dismiss,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  // Dark glassmorphism effect
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Icon container with glassmorphism
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: widget.iconColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: widget.iconColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.iconColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.message,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.subtitle,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Close button with glassmorphism
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        onPressed: _dismiss,
                        icon: Icon(
                          Icons.close,
                          color: Colors.white.withOpacity(0.8),
                          size: 18,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: const EdgeInsets.all(6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
