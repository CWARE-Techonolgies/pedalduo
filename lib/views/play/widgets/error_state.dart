import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../style/colors.dart';
import '../../../../style/fonts_sizes.dart';
import '../../../../style/texts.dart';
import '../providers/tournament_provider.dart';

class ErrorState extends StatelessWidget {
  final TournamentProvider provider;
  final VoidCallback onTap;
  const ErrorState({super.key, required this.provider, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
        padding: EdgeInsets.all(screenWidth * 0.06),
        decoration: BoxDecoration(
          color: AppColors.navyBlueGrey.withOpacity(0.7),
          borderRadius: BorderRadius.circular(screenWidth * 0.08),
          border: Border.all(
            color: AppColors.whiteColor.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.blackColor.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(screenWidth * 0.08),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.redColor.withOpacity(0.3),
                        AppColors.orangeColor.withOpacity(0.2),
                      ],
                    ),
                    border: Border.all(
                      color: AppColors.redColor.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: screenWidth * 0.15,
                    color: AppColors.redColor.withOpacity(0.9),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                Text(
                  'Error',
                  style: AppTexts.emphasizedTextStyle(
                    context: context,
                    textColor: AppColors.whiteColor,
                    fontSize: AppFontSizes(context).size20,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.015),
                Text(
                  provider.errorMessage,
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.whiteColor.withOpacity(0.7),
                    fontSize: AppFontSizes(context).size14,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.04),
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.08,
                      vertical: screenHeight * 0.015,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.orangeColor.withOpacity(0.8),
                          AppColors.lightOrangeColor.withOpacity(0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(screenWidth * 0.06),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.orangeColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(screenWidth * 0.06),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Text(
                          'Retry',
                          style: AppTexts.bodyTextStyle(
                            context: context,
                            textColor: AppColors.whiteColor,
                            fontSize: AppFontSizes(context).size14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}