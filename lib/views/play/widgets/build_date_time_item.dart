import 'package:flutter/material.dart';
import '../../../style/colors.dart';
import '../../../style/fonts_sizes.dart';
import '../../../style/texts.dart';


class BuildDateTimeItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String date;
  final Color color;
  const BuildDateTimeItem({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Row(
      children: [
        Icon(icon, size: screenWidth * 0.05, color: color),
        SizedBox(width: screenWidth * 0.03),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTexts.bodyTextStyle(
                context: context,
                textColor: AppColors.greyColor,
                fontSize: AppFontSizes(context).size12,
              ),
            ),
            Text(
              date,
              style: AppTexts.bodyTextStyle(
                context: context,
                textColor: AppColors.whiteColor,
                fontSize: AppFontSizes(context).size14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
