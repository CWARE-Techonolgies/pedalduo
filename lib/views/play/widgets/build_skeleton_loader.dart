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
      containersColor:  Colors.grey[800]! ,
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

    final skeletonColor = Colors.grey[800]! ;
    final cardBackground =  Colors.grey[900]!;
    final shadowColor = Colors.transparent ;

    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Skeleton
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(screenWidth * 0.04),
              topRight: Radius.circular(screenWidth * 0.04),
            ),
            child: Container(
              height: screenHeight * 0.2,
              width: double.infinity,
              color: skeletonColor,
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
                Container(
                  width: double.infinity,
                  height: screenHeight * 0.05,
                  decoration: BoxDecoration(
                    color: skeletonColor,
                    borderRadius: BorderRadius.circular(screenWidth * 0.06),
                  ),
                ),
              ],
            ),
          ),
        ],
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
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        SizedBox(width: MediaQuery.of(context).size.width * 0.02),
        Container(
          width: 80,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ],
    );
  }

  Widget _buildIconTextSkeleton(double screenWidth, double textWidthFactor, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        SizedBox(width: screenWidth * 0.02),
        Container(
          width: screenWidth * textWidthFactor,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildChipsSkeleton(double screenWidth, Color color) {
    return Row(
      children: [
        for (var width in [80.0, 90.0, 60.0])
          ...[
            Container(
              width: width,
              height: 28,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            SizedBox(width: screenWidth * 0.02),
          ]
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
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: 4),
                Container(
                  width: widths[1],
                  height: 14,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
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
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(height: 4),
              Container(
                width: widths[1],
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
      ],
    );
  }
}