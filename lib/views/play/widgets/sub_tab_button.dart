import 'package:flutter/material.dart';

import '../../../../style/colors.dart';
import '../../../../style/fonts_sizes.dart';
import '../../../../style/texts.dart';

class SubTabButtom extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  const SubTabButtom({super.key, required this.onTap, required this.title, required this.isSelected});

  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.01,
        ),
        decoration: BoxDecoration(
          color:
          isSelected ? AppColors.lightGreenColor : AppColors.lightGreyColor,
          borderRadius: BorderRadius.circular(screenWidth * 0.06),
        ),
        child: Text(
          title,
          style: AppTexts.bodyTextStyle(
            context: context,
            textColor: isSelected ? AppColors.whiteColor : AppColors.greyColor,
            fontSize: AppFontSizes(context).size14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
