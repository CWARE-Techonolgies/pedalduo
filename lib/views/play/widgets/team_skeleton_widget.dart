import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../style/colors.dart';

class TeamSkeletonWidget extends StatelessWidget {
  const TeamSkeletonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.015),
      child: Skeletonizer(
        enabled: true,
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.04),
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(screenWidth * 0.04),
            border: Border.all(
              color: AppColors.lightGreyColor,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Team Avatar
                  Bone.circle(
                    size: screenWidth * 0.12,
                  ),
                  SizedBox(width: screenWidth * 0.03),

                  // Team Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Bone.text(
                                words: 2,
                                fontSize: screenHeight * 0.02,
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            Bone.text(
                              words: 1,
                              fontSize: screenHeight * 0.015,
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.005),
                        Bone.text(
                          words: 1,
                          fontSize: screenHeight * 0.015,
                        ),
                      ],
                    ),
                  ),

                  // Status Badge
                  Container(
                    width: screenWidth * 0.18,
                    height: screenHeight * 0.025,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    ),
                  ),
                ],
              ),

              SizedBox(height: screenHeight * 0.015),

              // Stats Row
              Row(
                children: [
                  _buildSkeletonStatItem(screenWidth, screenHeight),
                  SizedBox(width: screenWidth * 0.04),
                  _buildSkeletonStatItem(screenWidth, screenHeight),
                  SizedBox(width: screenWidth * 0.04),
                  _buildSkeletonStatItem(screenWidth, screenHeight),
                ],
              ),

              SizedBox(height: screenHeight * 0.015),

              // Tournament Info
              Container(
                padding: EdgeInsets.all(screenWidth * 0.03),
                decoration: BoxDecoration(
                  color: AppColors.lightGreyColor,
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Bone.circle(size: screenWidth * 0.04),
                        SizedBox(width: screenWidth * 0.01),
                        Bone.text(
                          words: 1,
                          fontSize: screenHeight * 0.015,
                        ),
                        const Spacer(),
                        Bone.circle(size: screenWidth * 0.04),
                        SizedBox(width: screenWidth * 0.01),
                        Bone.text(
                          words: 1,
                          fontSize: screenHeight * 0.015,
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.008),
                    Row(
                      children: [
                        Bone.circle(size: screenWidth * 0.04),
                        SizedBox(width: screenWidth * 0.01),
                        Bone.text(
                          words: 2,
                          fontSize: screenHeight * 0.015,
                        ),
                        const Spacer(),
                        Bone.text(
                          words: 1,
                          fontSize: screenHeight * 0.015,
                        ),
                      ],
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

  Widget _buildSkeletonStatItem(double screenWidth, double screenHeight) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: screenWidth * 0.02,
          horizontal: screenWidth * 0.015,
        ),
        decoration: BoxDecoration(
          color: AppColors.lightGreyColor,
          borderRadius: BorderRadius.circular(screenWidth * 0.02),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Bone.circle(size: screenWidth * 0.04),
            SizedBox(width: screenWidth * 0.01),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Bone.text(
                  words: 1,
                  fontSize: screenHeight * 0.015,
                ),
                SizedBox(height: screenHeight * 0.003),
                Bone.text(
                  words: 1,
                  fontSize: screenHeight * 0.01,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}