import 'package:flutter/material.dart';
import '../../../style/colors.dart';
import '../../../style/fonts_sizes.dart';
import '../../../style/texts.dart';

class BuildDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;
  final Color? textColor;

  const BuildDetailRow({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.symmetric(vertical: screenWidth * 0.01),
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenWidth * 0.03,
      ),
      decoration: BoxDecoration(
        color: AppColors.whiteColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        border: Border.all(
          color: AppColors.whiteColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(screenWidth * 0.02),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.orangeColor.withOpacity(0.3),
                  AppColors.lightOrangeColor.withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(screenWidth * 0.02),
              border: Border.all(
                color: AppColors.orangeColor.withOpacity(0.4),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              size: screenWidth * 0.05,
              color: iconColor ?? AppColors.orangeColor.withOpacity(0.9),
            ),
          ),
          SizedBox(width: screenWidth * 0.03),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTexts.bodyTextStyle(
                  context: context,
                  textColor: textColor?.withOpacity(0.7) ?? AppColors.whiteColor.withOpacity(0.7),
                  fontSize: AppFontSizes(context).size12,
                ),
              ),
              SizedBox(height: screenWidth * 0.005),
              Text(
                value,
                style: AppTexts.bodyTextStyle(
                  context: context,
                  textColor: textColor ?? AppColors.whiteColor,
                  fontSize: AppFontSizes(context).size14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}