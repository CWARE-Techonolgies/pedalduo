import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../providers/notification_provider.dart';
import '../../../style/colors.dart';
import '../../../style/texts.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🔄 Initializing notification settings screen');
      context.read<NotificationProvider>().fetchNotificationSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkPrimaryColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: AppColors.glassColor,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: AppColors.glassColor,
            border: Border(
              bottom: BorderSide(
                color: AppColors.glassBorderColor,
                width: 0.5,
              ),
            ),
          ),
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(),
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notification Settings',
          style: AppTexts.emphasizedTextStyle(
            context: context,
            textColor: AppColors.textPrimaryColor,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.primaryGradient,
          ),
        ),
        child: Consumer<NotificationProvider>(
          builder: (context, provider, child) {
            if (provider.error != null) {
              return Center(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.glassColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.glassBorderColor,
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.errorColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.errorColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: AppColors.errorColor,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Something went wrong',
                            style: AppTexts.emphasizedTextStyle(
                              context: context,
                              textColor: AppColors.textPrimaryColor,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            provider.error!,
                            style: AppTexts.bodyTextStyle(
                              context: context,
                              textColor: AppColors.textSecondaryColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primaryColor,
                                  AppColors.primaryLightColor,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryColor.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                provider.clearError();
                                provider.fetchNotificationSettings();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.transparentColor,
                                foregroundColor: AppColors.textPrimaryColor,
                                shadowColor: AppColors.transparentColor,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Retry',
                                style: AppTexts.bodyTextStyle(
                                  context: context,
                                  textColor: AppColors.textPrimaryColor,
                                  fontWeight: FontWeight.w600,
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

            return Skeletonizer(
              enabled: provider.isLoading,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 100, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.glassColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.glassBorderColor,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.blackColor.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.accentPurpleColor,
                                          AppColors.accentBlueColor,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.accentPurpleColor.withOpacity(0.3),
                                          blurRadius: 15,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.notifications_outlined,
                                      color: AppColors.textPrimaryColor,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Notification Settings',
                                          style: AppTexts.emphasizedTextStyle(
                                            context: context,
                                            textColor: AppColors.textPrimaryColor,
                                            fontSize: 20,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Manage your notification preferences and stay updated',
                                          style: AppTexts.bodyTextStyle(
                                            context: context,
                                            textColor: AppColors.textSecondaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Push Notification Status
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.glassColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.glassBorderColor,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.blackColor.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Push Notification Status',
                                style: AppTexts.emphasizedTextStyle(
                                  context: context,
                                  textColor: AppColors.textPrimaryColor,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.accentBlueColor,
                                          AppColors.accentCyanColor,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.accentBlueColor.withOpacity(0.3),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.phone_android,
                                      color: AppColors.textPrimaryColor,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Push Notifications',
                                          style: AppTexts.bodyTextStyle(
                                            context: context,
                                            textColor: AppColors.textPrimaryColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          provider.settings?.pushEnabled == true
                                              ? 'Enabled'
                                              : 'Not Set',
                                          style: AppTexts.bodyTextStyle(
                                            context: context,
                                            textColor: AppColors.textSecondaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (provider.settings?.pushEnabled != true)
                                    GestureDetector(
                                      onTap: provider.isEnablingNotifications
                                          ? null
                                          : () {
                                        print('🔔 User tapped enable push notifications');
                                        provider.enablePushNotifications();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: provider.isEnablingNotifications
                                              ? LinearGradient(
                                            colors: [
                                              AppColors.textTertiaryColor,
                                              AppColors.textTertiaryColor,
                                            ],
                                          )
                                              : LinearGradient(
                                            colors: [
                                              AppColors.primaryColor,
                                              AppColors.primaryLightColor,
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(25),
                                          boxShadow: provider.isEnablingNotifications
                                              ? []
                                              : [
                                            BoxShadow(
                                              color: AppColors.primaryColor.withOpacity(0.4),
                                              blurRadius: 15,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (provider.isEnablingNotifications)
                                              const SizedBox(
                                                width: 16,
                                                height: 16,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(
                                                    AppColors.textPrimaryColor,
                                                  ),
                                                ),
                                              ),
                                            if (provider.isEnablingNotifications)
                                              const SizedBox(width: 10),
                                            Text(
                                              provider.isEnablingNotifications
                                                  ? 'Enabling...'
                                                  : 'Enable',
                                              style: AppTexts.bodyTextStyle(
                                                context: context,
                                                textColor: AppColors.textPrimaryColor,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  if (provider.settings?.pushEnabled == true)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.successColor,
                                            AppColors.accentCyanColor,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(25),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.successColor.withOpacity(0.4),
                                            blurRadius: 15,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        'Enabled',
                                        style: AppTexts.bodyTextStyle(
                                          context: context,
                                          textColor: AppColors.textPrimaryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Notification Categories Header
                    Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 20),
                      child: Text(
                        'Notification Categories',
                        style: AppTexts.emphasizedTextStyle(
                          context: context,
                          textColor: AppColors.textPrimaryColor,
                          fontSize: 18,
                        ),
                      ),
                    ),

                    // Categories List
                    if (provider.settings != null) ...[
                      _buildNotificationCategory(
                        context: context,
                        provider: provider,
                        icon: Icons.emoji_events,
                        gradientColors: [AppColors.goldColor, AppColors.primaryColor],
                        title: 'Tournament Updates',
                        subtitle: 'Notifications about tournament approvals, rejections, and status changes',
                        category: 'tournament_updates',
                        settings: provider.settings!.tournamentUpdates,
                      ),
                      const SizedBox(height: 16),
                      _buildNotificationCategory(
                        context: context,
                        provider: provider,
                        icon: Icons.chat_bubble_outline,
                        gradientColors: [AppColors.accentCyanColor, AppColors.accentBlueColor],
                        title: 'Chat Messages',
                        subtitle: 'In-app notifications for new chat messages and replies',
                        category: 'chat_messages',
                        settings: provider.settings!.chatMessages,
                      ),
                      const SizedBox(height: 16),
                      _buildNotificationCategory(
                        context: context,
                        provider: provider,
                        icon: Icons.sports_cricket,
                        gradientColors: [AppColors.primaryColor, AppColors.primaryLightColor],
                        title: 'Match Notifications',
                        subtitle: 'Reminders about upcoming matches and results',
                        category: 'match_notifications',
                        settings: provider.settings!.matchNotifications,
                      ),
                      const SizedBox(height: 16),

                      _buildNotificationCategory(
                        context: context,
                        provider: provider,
                        icon: Icons.group,
                        gradientColors: [AppColors.accentBlueColor, AppColors.accentCyanColor],
                        title: 'Team Updates',
                        subtitle: 'Player joins, team changes, and team-related announcements',
                        category: 'team_updates',
                        settings: provider.settings!.teamUpdates,
                      ),
                      const SizedBox(height: 16),
                      _buildNotificationCategory(
                        context: context,
                        provider: provider,
                        icon: Icons.payment,
                        gradientColors: [AppColors.goldColor, AppColors.warningColor],
                        title: 'Payment Confirmations',
                        subtitle: 'Payment receipts and transaction confirmations',
                        category: 'payment_confirmations',
                        settings: provider.settings!.paymentConfirmations,
                      ),
                      const SizedBox(height: 16),
                      _buildNotificationCategory(
                        context: context,
                        provider: provider,
                        icon: Icons.campaign,
                        gradientColors: [AppColors.accentPurpleColor, AppColors.accentPinkColor],
                        title: 'General Announcements',
                        subtitle: 'Platform updates and important announcements',
                        category: 'general_announcements',
                        settings: provider.settings!.generalAnnouncements,
                      ),
                      const SizedBox(height: 16),
                      _buildNotificationCategory(
                        context: context,
                        provider: provider,
                        icon: Icons.local_offer,
                        gradientColors: [AppColors.accentPinkColor, AppColors.accentPurpleColor],
                        title: 'Marketing & Promotions',
                        subtitle: 'Special offers, new features, and promotional content',
                        category: 'marketing_updates',
                        settings: provider.settings!.marketingUpdates,
                      ),
                    ],

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotificationCategory({
    required BuildContext context,
    required NotificationProvider provider,
    required IconData icon,
    required List<Color> gradientColors,
    required String title,
    required String subtitle,
    required String category,
    required Map<String, bool> settings,
  }) {
    final isProcessing = provider.isCategoryProcessing(category);
    final isPushEnabled = settings['push'] ?? false;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.glassColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.glassBorderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: gradientColors),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: gradientColors.first.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: AppColors.textPrimaryColor, size: 28),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTexts.emphasizedTextStyle(
                            context: context,
                            textColor: AppColors.textPrimaryColor,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: AppTexts.bodyTextStyle(
                            context: context,
                            textColor: AppColors.textSecondaryColor,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Push Notification Toggle
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.glassLightColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.glassBorderColor,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.accentBlueColor,
                            AppColors.accentCyanColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.phone_android,
                        size: 18,
                        color: AppColors.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Push',
                      style: AppTexts.bodyTextStyle(
                        context: context,
                        textColor: AppColors.textPrimaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (isProcessing)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.successColor,
                          ),
                        ),
                      ),
                    const Spacer(),
                    Switch(
                      value: isPushEnabled,
                      onChanged: (provider.settings?.pushEnabled == true && !isProcessing)
                          ? (value) {
                        print('🔔 Toggling push for $category: $value');
                        provider.updateNotificationSetting(
                          category,
                          'push',
                          value,
                        );
                      }
                          : null,
                      activeColor: AppColors.successColor,
                      activeTrackColor: AppColors.successColor.withOpacity(0.3),
                      inactiveThumbColor: AppColors.textTertiaryColor,
                      inactiveTrackColor: AppColors.textTertiaryColor.withOpacity(0.2),
                    ),
                  ],
                ),
              ),

              if (provider.settings?.pushEnabled != true)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.warningColor.withOpacity(0.1),
                          AppColors.primaryColor.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.warningColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: AppColors.warningColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Enable push notifications first to manage push settings',
                            style: AppTexts.bodyTextStyle(
                              context: context,
                              textColor: AppColors.warningColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}