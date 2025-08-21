// screens/notification_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../enums/notification_loading_state.dart';
import '../../global/images.dart';
import '../../style/colors.dart';
import 'package:collection/collection.dart';
import '../../style/texts.dart';
import '../../utils/app_utils.dart';
import 'manage_notification_provider.dart';
import 'notification_model.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _scrollController.addListener(_scrollListener);

    // Load notifications on screen enter
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManageNotificationProvider>().loadNotifications();
    });
  }

  void _scrollListener() {
    final provider = context.read<ManageNotificationProvider>();

    // Show/hide FAB based on scroll position
    if (_scrollController.offset > 100) {
      _fabAnimationController.forward();
    } else {
      _fabAnimationController.reverse();
    }

    // Load more on scroll
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      provider.loadNotifications(loadMore: true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;

    return Scaffold(
      backgroundColor: AppColors.darkPrimaryColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.primaryGradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(screenWidth, screenHeight),
              Expanded(
                child: Consumer<ManageNotificationProvider>(
                  builder: (context, provider, child) {
                    return RefreshIndicator(
                      onRefresh: provider.refreshNotifications,
                      color: AppColors.primaryColor,
                      backgroundColor: AppColors.glassColor,
                      child: _buildBody(provider, screenWidth, screenHeight),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Consumer<ManageNotificationProvider>(
        builder: (context, provider, child) {
          if (provider.notifications.isEmpty) return const SizedBox.shrink();

          return ScaleTransition(
            scale: _fabScaleAnimation,
            child: FloatingActionButton.extended(
              onPressed: () => _showOptionsBottomSheet(context, provider),
              backgroundColor: AppColors.primaryColor,
              foregroundColor: AppColors.whiteColor,
              elevation: 8,
              icon: const Icon(Icons.more_horiz),
              label: Text(
                'Options',
                style: AppTexts.bodyTextStyle(
                  context: context,
                  textColor: AppColors.whiteColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(double screenWidth, double screenHeight) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(screenWidth * 0.04),
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.glassColor,
        border: Border.all(color: AppColors.glassBorderColor, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(screenWidth * 0.03),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.notifications_active,
                          color: AppColors.primaryColor,
                          size: screenWidth * 0.06,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      Text(
                        'Notifications',
                        style: AppTexts.headingStyle(
                          context: context,
                          textColor: AppColors.textPrimaryColor,
                          fontSize: screenWidth * 0.055,
                        ),
                      ),
                    ],
                  ),
                  Consumer<ManageNotificationProvider>(
                    builder: (context, provider, child) {
                      if (provider.unreadCount > 0) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.025,
                            vertical: screenWidth * 0.015,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.errorColor,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            '${provider.unreadCount}',
                            style: AppTexts.bodyTextStyle(
                              context: context,
                              textColor: AppColors.whiteColor,
                              fontSize: screenWidth * 0.032,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.015),
              Consumer<ManageNotificationProvider>(
                builder: (context, provider, child) {
                  return _buildFilterDropdown(
                    provider,
                    screenWidth,
                    screenHeight,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(
    ManageNotificationProvider provider,
    double screenWidth,
    double screenHeight,
  ) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: provider.selectedFilter,
        icon: Icon(
          Icons.keyboard_arrow_down,
          color: AppColors.primaryColor,
          size: screenWidth * 0.05,
        ),
        dropdownColor: AppColors.darkSecondaryColor,
        style: AppTexts.bodyTextStyle(
          context: context,
          textColor: AppColors.textPrimaryColor,
          fontSize: screenWidth * 0.035,
          fontWeight: FontWeight.w500,
        ),
        isExpanded: true,
        items:
            provider.preferenceTypes.map((String type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Row(
                  children: [
                    _getFilterIcon(type, screenWidth),
                    SizedBox(width: screenWidth * 0.03),
                    Text(
                      provider.getFilterDisplayName(type),
                      style: AppTexts.bodyTextStyle(
                        context: context,
                        textColor: AppColors.textPrimaryColor,
                        fontSize: screenWidth * 0.035,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            provider.setFilter(newValue);
          }
        },
      ),
    );
  }

  Widget _getFilterIcon(String filterType, double screenWidth) {
    IconData iconData;
    Color iconColor;

    switch (filterType) {
      case 'all':
        iconData = Icons.all_inclusive;
        iconColor = AppColors.primaryColor;
        break;
      case 'general_announcements':
        iconData = Icons.campaign;
        iconColor = AppColors.infoColor;
        break;
      case 'marketing_updates':
        iconData = Icons.local_offer;
        iconColor = AppColors.warningColor;
        break;
      case 'payment_confirmations':
        iconData = Icons.payment;
        iconColor = AppColors.successColor;
        break;
      case 'team_updates':
        iconData = Icons.groups;
        iconColor = AppColors.infoColor;
        break;
      case 'match_notifications':
        iconData = Icons.sports_esports;
        iconColor = AppColors.primaryColor;
        break;
      case 'tournament_updates':
        iconData = Icons.emoji_events;
        iconColor = AppColors.warningColor;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = AppColors.primaryColor;
    }

    return Icon(iconData, color: iconColor, size: screenWidth * 0.045);
  }

  Widget _buildBody(
    ManageNotificationProvider provider,
    double screenWidth,
    double screenHeight,
  ) {
    if (provider.loadingState == NotificationLoadingState.loading &&
        provider.isInitialLoad) {
      return _buildSkeletonLoader(screenWidth, screenHeight);
    }

    if (provider.loadingState == NotificationLoadingState.error) {
      return _buildErrorState(provider, screenWidth, screenHeight);
    }

    if (provider.notifications.isEmpty &&
        provider.loadingState == NotificationLoadingState.loaded) {
      return _buildEmptyState(
        screenWidth,
        screenHeight,
        provider.selectedFilter,
      );
    }

    return _buildNotificationsList(provider, screenWidth, screenHeight);
  }

  Widget _buildSkeletonLoader(double screenWidth, double screenHeight) {
    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        padding: EdgeInsets.all(screenWidth * 0.04),
        itemCount: 8,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(bottom: screenHeight * 0.015),
            padding: EdgeInsets.all(screenWidth * 0.04),
            decoration: BoxDecoration(
              color: AppColors.glassColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.glassBorderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: screenWidth * 0.12,
                      height: screenWidth * 0.12,
                      decoration: BoxDecoration(
                        color: AppColors.glassLightColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: screenWidth * 0.5,
                            height: 16,
                            decoration: BoxDecoration(
                              color: AppColors.glassLightColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.005),
                          Container(
                            width: screenWidth * 0.3,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppColors.glassLightColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.01),
                Container(
                  width: double.infinity,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.glassLightColor,
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(
    ManageNotificationProvider provider,
    double screenWidth,
    double screenHeight,
  ) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(screenWidth * 0.06),
        padding: EdgeInsets.all(screenWidth * 0.06),
        decoration: BoxDecoration(
          color: AppColors.glassColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.glassBorderColor),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  decoration: BoxDecoration(
                    color: AppColors.errorColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(
                    Icons.error_outline,
                    color: AppColors.errorColor,
                    size: screenWidth * 0.12,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  'Oops! Something went wrong',
                  style: AppTexts.emphasizedTextStyle(
                    context: context,
                    textColor: AppColors.textPrimaryColor,
                    fontSize: screenWidth * 0.045,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  provider.errorMessage,
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.textSecondaryColor,
                    fontSize: screenWidth * 0.032,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.03),
                ElevatedButton(
                  onPressed: provider.refreshNotifications,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: AppColors.whiteColor,
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.06,
                      vertical: screenHeight * 0.015,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Try Again',
                    style: AppTexts.bodyTextStyle(
                      context: context,
                      textColor: AppColors.whiteColor,
                      fontWeight: FontWeight.w600,
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

  Widget _buildEmptyState(
    double screenWidth,
    double screenHeight,
    String currentFilter,
  ) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(screenWidth * 0.06),
        padding: EdgeInsets.all(screenWidth * 0.06),
        decoration: BoxDecoration(
          color: AppColors.glassColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.glassBorderColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(screenWidth * 0.08),
              decoration: BoxDecoration(
                color: AppColors.infoColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.notifications_off_outlined,
                color: AppColors.infoColor,
                size: screenWidth * 0.15,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              currentFilter == 'all'
                  ? 'No Notifications'
                  : 'No ${context.read<ManageNotificationProvider>().getFilterDisplayName(currentFilter)}',
              style: AppTexts.emphasizedTextStyle(
                context: context,
                textColor: AppColors.textPrimaryColor,
                fontSize: screenWidth * 0.05,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              currentFilter == 'all'
                  ? 'You\'re all caught up! No new notifications to show.'
                  : 'No notifications found for this category.',
              style: AppTexts.bodyTextStyle(
                context: context,
                textColor: AppColors.textSecondaryColor,
                fontSize: screenWidth * 0.035,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList(
      ManageNotificationProvider provider,
      double screenWidth,
      double screenHeight,
      ) {
    // Group notifications by date
    final groupedNotifications = _groupNotificationsByDate(provider.notifications);
    final sortedGroups = _sortDateGroups(groupedNotifications.keys.toList());

    // Calculate total items (notifications + headers + loading indicator if needed)
    int totalItems = 0;
    for (final group in sortedGroups) {
      totalItems += 1; // Header
      totalItems += groupedNotifications[group]!.length; // Notifications
    }

    // Add loading indicator if paginating
    if (provider.loadingState == NotificationLoadingState.loading && !provider.isInitialLoad) {
      totalItems += 1;
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(screenWidth * 0.04),
      itemCount: totalItems,
      itemBuilder: (context, index) {
        int currentIndex = 0;

        // Iterate through groups to find which item we're building
        for (final group in sortedGroups) {
          final notifications = groupedNotifications[group]!;

          // Check if this is the group header
          if (index == currentIndex) {
            return _buildDateGroupHeader(group, screenWidth, screenHeight);
          }
          currentIndex++;

          // Check if this is one of the notifications in this group
          if (index < currentIndex + notifications.length) {
            final notificationIndex = index - currentIndex;
            final notification = notifications[notificationIndex];
            return _buildNotificationItem(
              notification,
              provider,
              screenWidth,
              screenHeight,
            );
          }
          currentIndex += notifications.length;
        }

        // If we reach here, this must be the loading indicator
        return Container(
          margin: EdgeInsets.only(bottom: screenHeight * 0.015),
          padding: EdgeInsets.all(screenWidth * 0.04),
          decoration: BoxDecoration(
            color: AppColors.glassColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorderColor.withOpacity(0.5)),
          ),
          child: _buildSkeletonItem(screenWidth, screenHeight),
        );
      },
    );
  }
  // Add this method to your _NotificationScreenState class

  Widget _buildSkeletonItem(double screenWidth, double screenHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: screenWidth * 0.12,
              height: screenWidth * 0.12,
              decoration: BoxDecoration(
                color: AppColors.glassLightColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            SizedBox(width: screenWidth * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: screenWidth * 0.5,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.glassLightColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  Container(
                    width: screenWidth * 0.3,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.glassLightColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.01),
        Container(
          width: double.infinity,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.glassLightColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(7),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationItem(
    NotificationModel notification,
    ManageNotificationProvider provider,
    double screenWidth,
    double screenHeight,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.015),
      decoration: BoxDecoration(
        color: AppColors.glassColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              notification.isRead
                  ? AppColors.glassBorderColor
                  : AppColors.primaryColor.withOpacity(0.5),
          width: notification.isRead ? 1 : 2,
        ),
        boxShadow:
            notification.isRead
                ? []
                : [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _handleNotificationTap(notification, provider),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildNotificationIcon(notification, screenWidth),
                        SizedBox(width: screenWidth * 0.03),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      notification.title,
                                      style: AppTexts.emphasizedTextStyle(
                                        context: context,
                                        textColor: AppColors.textPrimaryColor,
                                        fontSize: screenWidth * 0.038,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (!notification.isRead)
                                    Container(
                                      width: screenWidth * 0.025,
                                      height: screenWidth * 0.025,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primaryColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.005),
                              Row(
                                children: [
                                  Text(
                                    _formatTime(notification.createdAt),
                                    style: AppTexts.bodyTextStyle(
                                      context: context,
                                      textColor: AppColors.textTertiaryColor,
                                      fontSize: screenWidth * 0.028,
                                    ),
                                  ),
                                  if (notification.sender?.name != null) ...[
                                    Text(
                                      ' • by ',
                                      style: AppTexts.bodyTextStyle(
                                        context: context,
                                        textColor: AppColors.textTertiaryColor,
                                        fontSize: screenWidth * 0.028,
                                      ),
                                    ),
                                    Text(
                                      notification.sender!.name,
                                      style: AppTexts.bodyTextStyle(
                                        context: context,
                                        textColor: AppColors.primaryColor,
                                        fontSize: screenWidth * 0.028,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert,
                            color: AppColors.textSecondaryColor,
                            size: screenWidth * 0.05,
                          ),
                          color: AppColors.darkSecondaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: AppColors.glassBorderColor),
                          ),
                          onSelected:
                              (value) => _handleMenuAction(
                                value,
                                notification,
                                provider,
                              ),
                          itemBuilder:
                              (context) => [
                                if (!notification.isRead)
                                  PopupMenuItem(
                                    value: 'mark_read',
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.mark_email_read,
                                          color: AppColors.successColor,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Mark as Read',
                                          style: AppTexts.bodyTextStyle(
                                            context: context,
                                            textColor:
                                                AppColors.textPrimaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.delete_outline,
                                        color: AppColors.errorColor,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Delete',
                                        style: AppTexts.bodyTextStyle(
                                          context: context,
                                          textColor: AppColors.textPrimaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      notification.message,
                      style: AppTexts.bodyTextStyle(
                        context: context,
                        textColor: AppColors.textSecondaryColor,
                        fontSize: screenWidth * 0.032,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(
    NotificationModel notification,
    double screenWidth,
  ) {
    final preferenceType = notification.data.preferenceType;

    // For general announcements, show the app logo
    if (preferenceType == 'general_announcements' || preferenceType == null) {
      return Container(
        width: screenWidth * 0.12,
        height: screenWidth * 0.12,
        padding: EdgeInsets.all(screenWidth * 0.02),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            AppImages.logoImage2,
            width: screenWidth * 0.08,
            height: screenWidth * 0.08,
            fit: BoxFit.contain,
          ),
        ),
      );
    }

    // For other notification types, show respective icons
    IconData iconData;
    Color iconColor;

    switch (preferenceType) {
      case 'marketing_updates':
        iconData = Icons.local_offer;
        iconColor = AppColors.warningColor;
        break;
      case 'payment_confirmations':
        iconData = Icons.payment;
        iconColor = AppColors.successColor;
        break;
      case 'team_updates':
        iconData = Icons.groups;
        iconColor = AppColors.infoColor;
        break;
      case 'match_notifications':
        iconData = Icons.sports_esports;
        iconColor = AppColors.primaryColor;
        break;
      case 'tournament_updates':
        iconData = Icons.emoji_events;
        iconColor = AppColors.warningColor;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = AppColors.primaryColor;
    }

    return Container(
      width: screenWidth * 0.12,
      height: screenWidth * 0.12,
      padding: EdgeInsets.all(screenWidth * 0.025),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withOpacity(0.3)),
      ),
      child: Icon(iconData, color: iconColor, size: screenWidth * 0.06),
    );
  }

  String _formatTime(String createdAt) {
    try {
      final dateTime = DateTime.parse(createdAt);
      return timeago.format(dateTime, allowFromNow: true);
    } catch (e) {
      return 'Just now';
    }
  }

  bool _shouldShowNavigationHint(NotificationModel notification) {
    final preferenceType = notification.data.preferenceType;
    // Don't show navigation hint for general announcements
    return preferenceType != 'general_announcements' && preferenceType != null;
  }

  void _handleNotificationTap(
    NotificationModel notification,
    ManageNotificationProvider provider,
  ) async {
    // Mark as read if not already read
    if (!notification.isRead) {
      try {
        await provider.markAsRead(notification.id);
      } catch (e) {
        if (mounted) {
          AppUtils.showFailureSnackBar(context, 'Failed to mark as read');
        }
      }
    }
    provider.getNavigationRoute(notification, context);
  }

  void _handleMenuAction(
    String action,
    NotificationModel notification,
    ManageNotificationProvider provider,
  ) async {
    switch (action) {
      case 'mark_read':
        try {
          await provider.markAsRead(notification.id);
          if (mounted) {
            AppUtils.showSuccessSnackBar(context, 'Marked as read');
          }
        } catch (e) {
          if (mounted) {
            AppUtils.showFailureSnackBar(context, 'Failed to mark as read');
          }
        }
        break;
      case 'delete':
        _showDeleteConfirmation(notification, provider);
        break;
    }
  }

  void _showDeleteConfirmation(
    NotificationModel notification,
    ManageNotificationProvider provider,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.darkSecondaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: AppColors.glassBorderColor),
            ),
            title: Text(
              'Delete Notification',
              style: AppTexts.emphasizedTextStyle(
                context: context,
                textColor: AppColors.textPrimaryColor,
              ),
            ),
            content: Text(
              'Are you sure you want to delete this notification?',
              style: AppTexts.bodyTextStyle(
                context: context,
                textColor: AppColors.textSecondaryColor,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.textSecondaryColor,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await provider.deleteNotification(notification.id);
                    if (mounted) {
                      AppUtils.showSuccessSnackBar(
                        context,
                        'Notification deleted',
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      AppUtils.showFailureSnackBar(
                        context,
                        'Failed to delete notification',
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.errorColor,
                  foregroundColor: AppColors.whiteColor,
                ),
                child: Text(
                  'Delete',
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.whiteColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _showOptionsBottomSheet(
    BuildContext context,
    ManageNotificationProvider provider,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.glassColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(color: AppColors.glassBorderColor),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: EdgeInsets.all(screenWidth * 0.05),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.darkSecondaryColor.withOpacity(0.9),
                      AppColors.darkTertiaryColor.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: screenWidth * 0.12,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.glassBorderColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      'Notification Options',
                      style: AppTexts.emphasizedTextStyle(
                        context: context,
                        textColor: AppColors.textPrimaryColor,
                        fontSize: screenWidth * 0.045,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    _buildOptionItem(
                      icon: Icons.mark_email_read,
                      title: 'Mark All as Read',
                      subtitle: 'Mark all notifications as read',
                      color: AppColors.successColor,
                      onTap: () async {
                        Navigator.pop(context);
                        try {
                          await provider.markAllAsRead();
                          if (mounted) {
                            AppUtils.showSuccessSnackBar(
                              context,
                              'All notifications marked as read',
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            AppUtils.showFailureSnackBar(
                              context,
                              'Failed to mark all as read',
                            );
                          }
                        }
                      },
                      screenWidth: screenWidth,
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    _buildOptionItem(
                      icon: Icons.delete_sweep,
                      title: 'Delete All',
                      subtitle: 'Delete all notifications permanently',
                      color: AppColors.errorColor,
                      onTap: () {
                        Navigator.pop(context);
                        _showDeleteAllConfirmation(provider);
                      },
                      screenWidth: screenWidth,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required double screenWidth,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.04),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(screenWidth * 0.025),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: screenWidth * 0.05),
              ),
              SizedBox(width: screenWidth * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTexts.emphasizedTextStyle(
                        context: context,
                        textColor: AppColors.textPrimaryColor,
                        fontSize: screenWidth * 0.038,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTexts.bodyTextStyle(
                        context: context,
                        textColor: AppColors.textSecondaryColor,
                        fontSize: screenWidth * 0.03,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textTertiaryColor,
                size: screenWidth * 0.04,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteAllConfirmation(ManageNotificationProvider provider) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.darkSecondaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: AppColors.glassBorderColor),
            ),
            title: Text(
              'Delete All Notifications',
              style: AppTexts.emphasizedTextStyle(
                context: context,
                textColor: AppColors.textPrimaryColor,
              ),
            ),
            content: Text(
              'Are you sure you want to delete all notifications? This action cannot be undone.',
              style: AppTexts.bodyTextStyle(
                context: context,
                textColor: AppColors.textSecondaryColor,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.textSecondaryColor,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await provider.deleteAllNotifications();
                    if (mounted) {
                      AppUtils.showSuccessSnackBar(
                        context,
                        'All notifications deleted',
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      AppUtils.showFailureSnackBar(
                        context,
                        'Failed to delete all notifications',
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.errorColor,
                  foregroundColor: AppColors.whiteColor,
                ),
                child: Text(
                  'Delete All',
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.whiteColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }
  // Helper functions to add in your NotificationScreen class

  String _getDateGroupLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final notificationDate = DateTime(date.year, date.month, date.day);

    if (notificationDate == today) {
      return 'Today';
    } else if (notificationDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(date).inDays <= 7) {
      // For this week, show day name
      const dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      return dayNames[date.weekday - 1];
    } else if (now.year == date.year) {
      // Same year, show month and day
      const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${monthNames[date.month - 1]} ${date.day}';
    } else {
      // Different year, show full date
      const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${monthNames[date.month - 1]} ${date.day}, ${date.year}';
    }
  }

  Map<String, List<NotificationModel>> _groupNotificationsByDate(List<NotificationModel> notifications) {
    final Map<String, List<NotificationModel>> grouped = {};

    for (final notification in notifications) {
      try {
        final date = DateTime.parse(notification.createdAt);
        final groupLabel = _getDateGroupLabel(date);

        if (grouped[groupLabel] == null) {
          grouped[groupLabel] = [];
        }
        grouped[groupLabel]!.add(notification);
      } catch (e) {
        // If date parsing fails, put in "Unknown" group
        if (grouped['Unknown'] == null) {
          grouped['Unknown'] = [];
        }
        grouped['Unknown']!.add(notification);
      }
    }

    return grouped;
  }

// Custom sort function for date groups
  List<String> _sortDateGroups(List<String> groups) {
    return groups.sorted((a, b) {
      // Define priority order
      const priority = {
        'Today': 0,
        'Yesterday': 1,
        'Monday': 2, 'Tuesday': 2, 'Wednesday': 2, 'Thursday': 2,
        'Friday': 2, 'Saturday': 2, 'Sunday': 2,
      };

      final priorityA = priority[a] ?? 99;
      final priorityB = priority[b] ?? 99;

      if (priorityA != priorityB) {
        return priorityA.compareTo(priorityB);
      }

      // For month-day format, parse and compare dates
      if (priorityA == 99 && priorityB == 99) {
        try {
          final dateA = _parseDateFromGroupLabel(a);
          final dateB = _parseDateFromGroupLabel(b);
          return dateB.compareTo(dateA); // Most recent first
        } catch (e) {
          return a.compareTo(b); // Fallback to string comparison
        }
      }

      return 0;
    });
  }
  Widget _buildDateGroupHeader(String dateLabel, double screenWidth, double screenHeight) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(
        top: screenHeight * 0.02,
        bottom: screenHeight * 0.01,
        left: screenWidth * 0.04,
        right: screenWidth * 0.04,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.glassBorderColor.withOpacity(0.3),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.03,
              vertical: screenWidth * 0.015,
            ),
            decoration: BoxDecoration(
              color: AppColors.glassColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.glassBorderColor.withOpacity(0.5),
              ),
            ),
            child: Text(
              dateLabel,
              style: AppTexts.bodyTextStyle(
                context: context,
                textColor: AppColors.textSecondaryColor,
                fontSize: screenWidth * 0.03,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.glassBorderColor.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }
  DateTime _parseDateFromGroupLabel(String label) {
    // This is a helper to parse dates from labels like "Jan 15" or "Jan 15, 2024"
    final now = DateTime.now();
    const monthMap = {
      'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
      'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
    };

    final parts = label.split(' ');
    if (parts.length >= 2) {
      final month = monthMap[parts[0]];
      final day = int.tryParse(parts[1].replaceAll(',', ''));
      final year = parts.length > 2 ? int.tryParse(parts[2]) : now.year;

      if (month != null && day != null && year != null) {
        return DateTime(year, month, day);
      }
    }

    return now; // Fallback
  }
}
