import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'package:pedalduo/style/fonts_sizes.dart';
import '../../../models/activity_model.dart';
import '../../../providers/activity_provider.dart';
import '../../../style/colors.dart';
import '../../../style/texts.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ActivityProvider>(
      builder: (context, activityProvider, child) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.navyBlueGrey,
                AppColors.lightNavyBlueGrey,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'My Activity',
                    style: AppTexts.headingStyle(
                      context: context,
                      textColor: AppColors.whiteColor,
                      fontSize: AppFontSizes(context).size32,
                    ),
                  ),
                ),

                // Activity List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    itemCount: activityProvider.activities.length,
                    itemBuilder: (context, index) {
                      final activity = activityProvider.activities[index];
                      return _buildActivityCard(context, activity);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActivityCard(BuildContext context, ActivityItem activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.whiteColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppColors.whiteColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Activity Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: activity.iconColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    activity.icon,
                    color: activity.iconColor,
                    size: 20,
                  ),
                ),

                const SizedBox(width: 16),

                // Activity Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: activity.name,
                              style: AppTexts.emphasizedTextStyle(
                                context: context,
                                textColor: AppColors.whiteColor,
                                fontSize: AppFontSizes(context).size14,
                              ),
                            ),
                            TextSpan(
                              text: ' ${activity.action}',
                              style: AppTexts.bodyTextStyle(
                                context: context,
                                textColor: AppColors.greyColor,
                                fontSize: AppFontSizes(context).size14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        activity.time,
                        style: AppTexts.bodyTextStyle(
                          context: context,
                          textColor: AppColors.greyColor,
                          fontSize: AppFontSizes(context).size12,
                        ),
                      ),
                    ],
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