import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../style/colors.dart';

class BuildSkeletonLoader extends StatelessWidget {
  const BuildSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Skeletonizer(
      enabled: true,
      containersColor: Colors.white.withOpacity(0.1),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
        itemCount: 3,
        itemBuilder: (context, index) {
          return _buildSkeletonTournamentCard(context, isDark);
        },
      ),
    );
  }

  Widget _buildSkeletonTournamentCard(BuildContext context, bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Glassy dark theme colors
    final skeletonColor = Colors.white.withOpacity(0.08);
    final cardBackground = Colors.black.withOpacity(0.3);
    final shadowColor = Colors.black.withOpacity(0.2);
    final borderColor = Colors.white.withOpacity(0.1);

    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
      decoration: BoxDecoration(
        // Glassmorphism background
        color: cardBackground,
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 40,
            offset: const Offset(0, 20),
            spreadRadius: -5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Skeleton with shimmer effect
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(screenWidth * 0.04),
                  topRight: Radius.circular(screenWidth * 0.04),
                ),
                child: Container(
                  height: screenHeight * 0.2,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        skeletonColor,
                        Colors.white.withOpacity(0.15),
                        skeletonColor,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: _buildShimmerOverlay(),
                ),
              ),

              // Detail Skeletons
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRowSkeleton(context, skeletonColor),
                    SizedBox(height: screenHeight * 0.015),
                    _buildIconTextSkeleton(screenWidth, 0.4, skeletonColor),
                    SizedBox(height: screenHeight * 0.01),
                    _buildIconTextSkeleton(screenWidth, 0.3, skeletonColor),
                    SizedBox(height: screenHeight * 0.02),
                    _buildChipsSkeleton(screenWidth, skeletonColor),
                    SizedBox(height: screenHeight * 0.02),
                    _buildDatesSkeleton(screenWidth, skeletonColor),
                    SizedBox(height: screenHeight * 0.02),
                    _buildFeeRegSkeleton(screenWidth, skeletonColor),
                    SizedBox(height: screenHeight * 0.02),
                    _buildGlassyButton(
                      screenWidth,
                      screenHeight,
                      skeletonColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.transparent,
            Colors.white.withOpacity(0.05),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildRowSkeleton(BuildContext context, Color color) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 20,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, Colors.white.withOpacity(0.12), color],
              ),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: Colors.white.withOpacity(0.05),
                width: 0.5,
              ),
            ),
          ),
        ),
        SizedBox(width: MediaQuery.of(context).size.width * 0.02),
        Container(
          width: 80,
          height: 24,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, Colors.white.withOpacity(0.12), color],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
              width: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIconTextSkeleton(
    double screenWidth,
    double textWidthFactor,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [Colors.white.withOpacity(0.15), color],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 0.5,
            ),
          ),
        ),
        SizedBox(width: screenWidth * 0.02),
        Container(
          width: screenWidth * textWidthFactor,
          height: 14,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, Colors.white.withOpacity(0.1), color],
            ),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: Colors.white.withOpacity(0.05),
              width: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChipsSkeleton(double screenWidth, Color color) {
    return Row(
      children: [
        for (var width in [80.0, 90.0, 60.0]) ...[
          Container(
            width: width,
            height: 28,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.1),
                  color,
                  Colors.white.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withOpacity(0.12),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          SizedBox(width: screenWidth * 0.02),
        ],
      ],
    );
  }

  Widget _buildDatesSkeleton(double screenWidth, Color color) {
    return Row(
      children: [
        for (var widths in [
          [100.0, 80.0],
          [110.0, 90.0],
        ])
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: widths[0],
                  height: 12,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, Colors.white.withOpacity(0.1)],
                    ),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.05),
                      width: 0.5,
                    ),
                  ),
                ),
                SizedBox(height: 4),
                Container(
                  width: widths[1],
                  height: 14,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white.withOpacity(0.12), color],
                    ),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.08),
                      width: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFeeRegSkeleton(double screenWidth, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var widths in [
          [60.0, 70.0],
          [70.0, 50.0],
        ])
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: widths[0],
                height: 12,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, Colors.white.withOpacity(0.1)],
                  ),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.05),
                    width: 0.5,
                  ),
                ),
              ),
              SizedBox(height: 4),
              Container(
                width: widths[1],
                height: 16,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white.withOpacity(0.12), color],
                  ),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                    width: 0.5,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildGlassyButton(
    double screenWidth,
    double screenHeight,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      height: screenHeight * 0.05,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
            color,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(screenWidth * 0.06),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),

          ),
        ],
      ),
    );
  }
}
