import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pedalduo/views/auth/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';

import '../../../global/constants.dart';
import '../../../providers/delete_account_provider.dart';
import '../../../style/colors.dart';
import '../../../style/fonts_sizes.dart';
import '../../../style/texts.dart';
import '../../../utils/app_utils.dart';
import '../../../widgets/delete_bottom_sheet.dart';
import '../../../widgets/logout_dialogue.dart';
import '../../auth/change_password.dart';
import '../customer_support/support_ticket_main_screen.dart';
import 'notification_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
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
                            icon: const Icon(
                              Icons.arrow_back,
                              color: AppColors.textPrimaryColor,
                            ),
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
                            AppColors.goldColor,
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
                            () {
                              AppUtils.showInfoDialog(
                                context,
                                'Coming Soon', // title
                                'This feature is coming soon.', // message
                                buttonText: 'Got It',
                              );
                            },
                          ),

                          _buildSettingsItem(
                            context,
                            'Customer Support',
                            Icons.support_agent_outlined,
                            AppColors.accentCyanColor,
                            () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (_) => SupportTicketScreen(),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 24),

                          // Security Section
                          _buildSectionHeader(context, 'Security'),
                          const SizedBox(height: 12),

                          _buildSettingsItem(
                            context,
                            'Change Password',
                            Icons.lock_outline,
                            AppColors.lightOrangeColor,
                            () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (_) => const ChangePasswordScreen(),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 24),

                          // Legal Section
                          _buildSectionHeader(context, 'Legal'),
                          const SizedBox(height: 12),

                          _buildSettingsItem(
                            context,
                            'Privacy Policy',
                            Icons.privacy_tip_outlined,
                            AppColors.backgroundColor,
                            _launchPrivacyPolicy,
                          ),

                          _buildSettingsItem(
                            context,
                            'Terms of Service',
                            Icons.description_outlined,
                            AppColors.warningColor,
                            _launchTermsAndConditions,
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

                          Consumer<DeleteAccountProvider>(
                            builder: (context, provider, child) {
                              return _buildSettingsItem(
                                context,
                                provider.isCheckingParticipation
                                    ? 'Checking...'
                                    : 'Delete Account',
                                Icons.delete_outline,
                                AppColors.errorColor,
                                provider.isCheckingParticipation
                                    ? () {}
                                    : _handleDeleteAccount,
                                isDangerous: true,
                              );
                            },
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
              color:
                  isDangerous
                      ? AppColors.errorColor.withOpacity(0.1)
                      : AppColors.glassLightColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    isDangerous
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
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
                        child: Icon(icon, color: iconColor, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          title,
                          style: AppTexts.bodyTextStyle(
                            context: context,
                            textColor:
                                isDangerous
                                    ? AppColors.errorColor
                                    : AppColors.textPrimaryColor,
                            fontSize:
                                isDangerous
                                    ? AppFontSizes(context).size16
                                    : AppFontSizes(context).size14,
                            fontWeight:
                                isDangerous ? FontWeight.w600 : FontWeight.w500,
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

  Future<void> _launchTermsAndConditions() async {
    const url = AppConstants.termsAndConditions;
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        AppUtils.showFailureSnackBar(
          context,
          'Could not open Terms & Conditions',
        );
      }
    }
  }

  Future<void> _launchPrivacyPolicy() async {
    const url = AppConstants.privacyPolicy;
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        AppUtils.showFailureSnackBar(context, 'Could not open Privacy Policy');
      }
    }
  }

  void _handleDeleteAccount() async {
    final provider = Provider.of<DeleteAccountProvider>(context, listen: false);

    final participationData = await provider.checkActiveParticipation();

    if (participationData != null && participationData['success'] == true) {
      final hasActive = participationData['data']['hasActive'];

      if (hasActive == true) {
        // Show info dialog that account cannot be deleted
        AppUtils.showInfoDialog(
          context,
          'Cannot Delete Account',
          'You cannot delete your account as you have active participation in tournaments, teams, or matches. Please complete or leave your active participations first.',
          buttonText: 'Understood',
        );
        return;
      }
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder:
          (context) => DeleteAccountBottomSheet(
            onDeleteSuccess: () async {
              final provider = Provider.of<DeleteAccountProvider>(
                context,
                listen: false,
              );


              await provider.clearAllData();
              // Show grace period info dialog
              Navigator.pushAndRemoveUntil(
                context,
                CupertinoPageRoute(builder: (_) => LoginScreen(comingFrom: 'Delete')),
                (route) => false,
              );
              // Clear all data from SharedPreferences

            },
          ),
    );
  }
}
