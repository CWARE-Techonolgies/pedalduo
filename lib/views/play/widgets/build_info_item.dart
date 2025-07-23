import 'package:flutter/material.dart';

import '../../../style/colors.dart';
import '../../../style/fonts_sizes.dart';
import '../../../style/texts.dart';

class BuildInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const BuildInfoItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Icon(icon, size: screenWidth * 0.06, color: AppColors.orangeColor),
        SizedBox(height: screenWidth * 0.02),
        Text(
          label,
          style: AppTexts.bodyTextStyle(
            context: context,
            textColor: AppColors.greyColor,
            fontSize: AppFontSizes(context).size12,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          value,
          style: AppTexts.emphasizedTextStyle(
            context: context,
            textColor: AppColors.whiteColor,
            fontSize: AppFontSizes(context).size16,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
