// widgets/skeleton_loader.dart
import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../style/colors.dart';

class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;

  const SkeletonLoader({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.margin,
  }) : super(key: key);

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: AppColors.glassColor,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.glassBorderColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: const [0.0, 0.5, 1.0],
                  colors: [
                    AppColors.darkSecondaryColor.withOpacity(0.3),
                    AppColors.glassLightColor.withOpacity(0.5),
                    AppColors.darkSecondaryColor.withOpacity(0.3),
                  ],
                  transform: GradientRotation(_animation.value),
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.glassColor.withOpacity(0.1),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Specific skeleton loaders
class TicketCardSkeleton extends StatelessWidget {
  const TicketCardSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonLoader(
                width: 60,
                height: 20,
                borderRadius: BorderRadius.circular(10),
              ),
              SkeletonLoader(
                width: screenWidth * 0.3,
                height: 12,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SkeletonLoader(
            width: screenWidth * 0.9,
            height: 18,
            borderRadius: BorderRadius.circular(9),
          ),
          const SizedBox(height: 8),
          SkeletonLoader(
            width: screenWidth * 0.7,
            height: 16,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SkeletonLoader(
                width: 70,
                height: 24,
                borderRadius: BorderRadius.circular(12),
              ),
              const SizedBox(width: 12),
              SkeletonLoader(
                width: 50,
                height: 24,
                borderRadius: BorderRadius.circular(12),
              ),
              const SizedBox(width: 12),
              SkeletonLoader(
                width: 80,
                height: 24,
                borderRadius: BorderRadius.circular(12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MessageSkeleton extends StatelessWidget {
  final bool isUser;

  const MessageSkeleton({Key? key, required this.isUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            SkeletonLoader(
              width: 32,
              height: 32,
              borderRadius: BorderRadius.circular(16),
            ),
            const SizedBox(width: 8),
          ],
          Container(
            constraints: BoxConstraints(maxWidth: screenWidth * 0.7),
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                SkeletonLoader(
                  width: screenWidth * (isUser ? 0.5 : 0.6),
                  height: 40,
                  borderRadius: BorderRadius.circular(16),
                ),
                const SizedBox(height: 4),
                SkeletonLoader(
                  width: 60,
                  height: 10,
                  borderRadius: BorderRadius.circular(5),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            SkeletonLoader(
              width: 32,
              height: 32,
              borderRadius: BorderRadius.circular(16),
            ),
          ],
        ],
      ),
    );
  }
}

class FilterChipSkeleton extends StatelessWidget {
  const FilterChipSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      width: 80,
      height: 32,
      borderRadius: BorderRadius.circular(16),
      margin: const EdgeInsets.only(right: 8),
    );
  }
}

class TicketDetailHeaderSkeleton extends StatelessWidget {
  const TicketDetailHeaderSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.glassColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonLoader(
                width: screenWidth * 0.4,
                height: 14,
                borderRadius: BorderRadius.circular(7),
              ),
              SkeletonLoader(
                width: 60,
                height: 20,
                borderRadius: BorderRadius.circular(10),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SkeletonLoader(
            width: screenWidth * 0.8,
            height: 24,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(height: 8),
          SkeletonLoader(
            width: screenWidth * 0.6,
            height: 18,
            borderRadius: BorderRadius.circular(9),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SkeletonLoader(
                width: 100,
                height: 28,
                borderRadius: BorderRadius.circular(14),
              ),
              const SizedBox(width: 8),
              SkeletonLoader(
                width: 80,
                height: 28,
                borderRadius: BorderRadius.circular(14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}