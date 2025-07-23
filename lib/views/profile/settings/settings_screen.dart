import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import '../../../style/colors.dart';
import '../../../style/fonts_sizes.dart';
import '../../../style/texts.dart';
import '../../../widgets/logout_dialogue.dart';
import 'notification_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.primaryGradient,
          ),
        ),
        child: Column(
          children: [
            // Custom App Bar with Glass Effect
            SafeArea(
              child: Container(
                margin: const EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.glassColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.glassBorderColor,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimaryColor),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Expanded(
                            child: Text(
                              'Settings',
                              style: AppTexts.emphasizedTextStyle(
                                context: context,
                                textColor: AppColors.textPrimaryColor,
                                fontSize: AppFontSizes(context).size18,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 48), // Balance the back button
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Settings Content
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.glassColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.glassBorderColor,
                          width: 1,
                        ),
                      ),
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          // General Settings Section
                          _buildSectionHeader(context, 'General'),
                          const SizedBox(height: 12),

                          _buildSettingsItem(
                            context,
                            'Manage Notifications',
                            Icons.notifications_outlined,
                            AppColors.accentBlueColor,
                                () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (_) => NotificationSettingsScreen(),
                                ),
                              );
                            },
                          ),

                          _buildSettingsItem(
                            context,
                            'Manage Payment',
                            Icons.payment_outlined,
                            AppColors.primaryColor,
                                () {},
                          ),

                          _buildSettingsItem(
                            context,
                            'Contact Us',
                            Icons.email_outlined,
                            AppColors.accentCyanColor,
                                () {},
                          ),

                          const SizedBox(height: 24),

                          // Legal Section
                          _buildSectionHeader(context, 'Legal'),
                          const SizedBox(height: 12),

                          _buildSettingsItem(
                            context,
                            'Privacy Policy',
                            Icons.privacy_tip_outlined,
                            AppColors.accentPurpleColor,
                                () {},
                          ),

                          _buildSettingsItem(
                            context,
                            'Terms of Service',
                            Icons.description_outlined,
                            AppColors.warningColor,
                                () {},
                          ),

                          const SizedBox(height: 24),

                          // Danger Zone Section
                          _buildSectionHeader(context, 'Account'),
                          const SizedBox(height: 12),

                          _buildSettingsItem(
                            context,
                            'Logout',
                            Icons.logout_outlined,
                            AppColors.errorColor,
                                () {
                              LogoutDialog.show(context);
                            },
                            isDangerous: true,
                          ),

                          _buildSettingsItem(
                            context,
                            'Delete Account',
                            Icons.delete_outline,
                            AppColors.errorColor,
                                () {},
                            isDangerous: true,
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title,
        style: AppTexts.emphasizedTextStyle(
          context: context,
          textColor: AppColors.primaryColor,
          fontSize: AppFontSizes(context).size16,
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
      BuildContext context,
      String title,
      IconData icon,
      Color iconColor,
      VoidCallback onTap, {
        bool isDangerous = false,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              color: isDangerous
                  ? AppColors.errorColor.withOpacity(0.1)
                  : AppColors.glassLightColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDangerous
                    ? AppColors.errorColor.withOpacity(0.3)
                    : AppColors.glassBorderColor,
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: iconColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: iconColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: iconColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          title,
                          style: AppTexts.bodyTextStyle(
                            context: context,
                            textColor: isDangerous
                                ? AppColors.errorColor
                                : AppColors.textPrimaryColor,
                            fontSize: isDangerous
                                ? AppFontSizes(context).size16
                                : AppFontSizes(context).size14,
                            fontWeight: isDangerous
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.glassColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.glassBorderColor,
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: AppColors.textSecondaryColor,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}