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
      context.read<NotificationProvider>().fetchNotificationSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
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
        flexibleSpace: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.glassBorderColor,
                width: 1,
              ),
            ),
          ),
        ),
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.errorColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.errorColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppColors.errorColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Something went wrong',
                    style: AppTexts.emphasizedTextStyle(
                      context: context,
                      textColor: AppColors.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.error!,
                    style: AppTexts.bodyTextStyle(
                      context: context,
                      textColor: AppColors.textSecondaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryColor,
                          AppColors.primaryDarkColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        provider.clearError();
                        provider.fetchNotificationSettings();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
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
            );
          }

          return Skeletonizer(
            enabled: provider.isLoading,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.glassColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.glassBorderColor,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.blackColor.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.primaryColor.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.notifications_outlined,
                                color: AppColors.primaryColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Notification Settings',
                                    style: AppTexts.emphasizedTextStyle(
                                      context: context,
                                      textColor: AppColors.textPrimaryColor,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
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

                  const SizedBox(height: 24),

                  // Push Notification Status
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.glassColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.glassBorderColor,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.blackColor.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Push Notification Status',
                          style: AppTexts.emphasizedTextStyle(
                            context: context,
                            textColor: AppColors.textPrimaryColor,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.accentCyanColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.accentCyanColor.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.phone_android,
                                color: AppColors.accentCyanColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
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
                                    : () => provider.enablePushNotifications(),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: provider.isEnablingNotifications
                                        ? null
                                        : LinearGradient(
                                      colors: [
                                        AppColors.primaryColor,
                                        AppColors.primaryDarkColor,
                                      ],
                                    ),
                                    color: provider.isEnablingNotifications
                                        ? AppColors.textTertiaryColor
                                        : null,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: provider.isEnablingNotifications
                                          ? AppColors.glassBorderColor
                                          : Colors.transparent,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (provider.isEnablingNotifications)
                                        SizedBox(
                                          width: 12,
                                          height: 12,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              AppColors.textPrimaryColor,
                                            ),
                                          ),
                                        ),
                                      if (provider.isEnablingNotifications)
                                        const SizedBox(width: 8),
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
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primaryColor,
                                      AppColors.primaryDarkColor,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
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

                  const SizedBox(height: 24),

                  // Notification Categories
                  Text(
                    'Notification Categories',
                    style: AppTexts.emphasizedTextStyle(
                      context: context,
                      textColor: AppColors.textSecondaryColor,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Categories List
                  if (provider.settings != null) ...[
                    _buildNotificationCategory(
                      context: context,
                      provider: provider,
                      icon: Icons.emoji_events,
                      iconColor: AppColors.warningColor,
                      title: 'Tournament Updates',
                      subtitle:
                      'Notifications about tournament approvals, rejections, and status changes',
                      category: 'tournament_updates',
                      settings: provider.settings!.tournamentUpdates,
                    ),
                    const SizedBox(height: 12),
                    _buildNotificationCategory(
                      context: context,
                      provider: provider,
                      icon: Icons.sports_cricket,
                      iconColor: AppColors.primaryColor,
                      title: 'Match Notifications',
                      subtitle: 'Reminders about upcoming matches and results',
                      category: 'match_notifications',
                      settings: provider.settings!.matchNotifications,
                    ),
                    const SizedBox(height: 12),
                    _buildNotificationCategory(
                      context: context,
                      provider: provider,
                      icon: Icons.group,
                      iconColor: AppColors.accentCyanColor,
                      title: 'Team Updates',
                      subtitle:
                      'Player joins, team changes, and team-related announcements',
                      category: 'team_updates',
                      settings: provider.settings!.teamUpdates,
                    ),
                    const SizedBox(height: 12),
                    _buildNotificationCategory(
                      context: context,
                      provider: provider,
                      icon: Icons.payment,
                      iconColor: AppColors.warningColor,
                      title: 'Payment Confirmations',
                      subtitle:
                      'Payment receipts and transaction confirmations',
                      category: 'payment_confirmations',
                      settings: provider.settings!.paymentConfirmations,
                    ),
                    const SizedBox(height: 12),
                    _buildNotificationCategory(
                      context: context,
                      provider: provider,
                      icon: Icons.campaign,
                      iconColor: AppColors.textTertiaryColor,
                      title: 'General Announcements',
                      subtitle: 'Platform updates and important announcements',
                      category: 'general_announcements',
                      settings: provider.settings!.generalAnnouncements,
                    ),
                    const SizedBox(height: 12),
                    _buildNotificationCategory(
                      context: context,
                      provider: provider,
                      icon: Icons.local_offer,
                      iconColor: AppColors.accentPurpleColor,
                      title: 'Marketing & Promotions',
                      subtitle:
                      'Special offers, new features, and promotional content',
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
    );
  }

  Widget _buildNotificationCategory({
    required BuildContext context,
    required NotificationProvider provider,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String category,
    required Map<String, bool> settings,
  }) {
    final topicName = _getTopicName(category);
    final isProcessing = provider.isTopicProcessing(topicName);
    final isEnabled = settings['push'] ?? false;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.glassColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.glassBorderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackColor.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: iconColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
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
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
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
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Push',
                style: AppTexts.bodyTextStyle(
                  context: context,
                  textColor: AppColors.textPrimaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              if (isProcessing)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryColor,
                    ),
                  ),
                ),
              const Spacer(),
              Switch(
                value: isEnabled,
                onChanged:
                (provider.settings?.pushEnabled == true && !isProcessing)
                    ? (value) {
                  provider.updateNotificationSetting(
                    category,
                    'push',
                    value,
                  );
                }
                    : null,
                activeColor: AppColors.primaryColor,
                activeTrackColor: AppColors.primaryColor.withOpacity(0.3),
                inactiveTrackColor: AppColors.textTertiaryColor,
                inactiveThumbColor: AppColors.textSecondaryColor,
              ),
            ],
          ),
          if (provider.settings?.pushEnabled != true)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Enable push notifications first to manage this setting',
                style: AppTexts.bodyTextStyle(
                  context: context,
                  textColor: AppColors.warningColor,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getTopicName(String category) {
    // Map category to topic name - should match the provider's mapping
    switch (category) {
      case 'tournament_updates':
        return 'tournament_updates';
      case 'match_notifications':
        return 'match_notifications';
      case 'team_updates':
        return 'team_updates';
      case 'payment_confirmations':
        return 'payment_confirmations';
      case 'chat_messages':
        return 'chat_messages';
      case 'general_announcements':
        return 'general_announcements';
      case 'marketing_updates':
        return 'marketing_updates';
      default:
        return category;
    }
  }
}