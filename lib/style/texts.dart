import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTexts {
  static TextStyle bodyTextStyle({
    required BuildContext context,
    required Color textColor,
    double? fontSize,
    FontWeight? fontWeight,
    TextDecoration? textDecoration,
    Color? decorationColor,
  }) {
    final Size screenSize = MediaQuery.of(context).size;
    final double width = screenSize.width;
    final double bodyFontSize = width * 0.032;
    return GoogleFonts.barlow(
      textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
          fontSize: fontSize ?? bodyFontSize,
          decoration: textDecoration ?? TextDecoration.none,
          decorationColor: decorationColor ?? AppColors.greenColor,
          color: textColor,
          fontWeight: fontWeight ?? FontWeight.normal),
    );
  }

  static TextStyle emphasizedTextStyle(
      {required BuildContext context,
      double? fontSize,
      required Color textColor}) {
    final Size screenSize = MediaQuery.of(context).size;
    final double width = screenSize.width;
    final double headingFontSize = width * 0.034;
    return GoogleFonts.barlowCondensed(
      textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontSize: fontSize ?? headingFontSize,
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
    );
  }

  static TextStyle headingStyle(
      {required BuildContext context,
      required Color textColor,
      double? fontSize}) {
    final Size screenSize = MediaQuery.of(context).size;
    final double width = screenSize.width;
    final double headingFontSize = width * 0.15;
    return GoogleFonts.barlowCondensed(
      textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
            fontSize: fontSize ?? headingFontSize,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
    );
  }
}
