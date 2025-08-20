import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../style/colors.dart';

class TennisGlassMorphContainer extends StatelessWidget {
  final Widget child;
  final Color? borderColor;

  const TennisGlassMorphContainer({
    super.key,
    required this.child,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor ?? AppColors.glassBorderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: child,
        ),
      ),
    );
  }
}
