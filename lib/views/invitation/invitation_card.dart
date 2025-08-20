import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../style/colors.dart';
import '../../style/texts.dart';
import 'invitation_model.dart';

class InvitationCard extends StatefulWidget {
  final Invitation invitation;
  final bool isSent;
  final VoidCallback? onAccept;
  final bool isProcessing;
  final VoidCallback? onDecline;
  final VoidCallback? onCopyLink;

  const InvitationCard({
    super.key,
    required this.invitation,
    this.isProcessing = false,
    required this.isSent,
    this.onAccept,
    this.onDecline,
    this.onCopyLink,
  });

  @override
  State<InvitationCard> createState() => _InvitationCardState();
}

class _InvitationCardState extends State<InvitationCard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final invitation = widget.invitation;
    final isSent = widget.isSent;

    // Calculate team capacity status using updated field names
    final hasSpaceLeft = invitation.team.totalPlayers < invitation.team.maxPlayers;
    final teamCapacityText = '${invitation.team.totalPlayers}/${invitation.team.maxPlayers}';

    // Check if invitation is expired
    final isExpired = DateTime.now().isAfter(invitation.expiresAt);
    final tournamentStarted = invitation.tournament != null
        ? DateTime.now().isAfter(invitation.tournament!.tournamentStartDate)
        : false;

    // Check if buttons should be enabled
    final buttonsEnabled = !isSent &&
        invitation.isPending &&
        hasSpaceLeft &&
        !isExpired &&
        !tournamentStarted;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: EdgeInsets.only(bottom: screenSize.width * 0.04),
            decoration: BoxDecoration(
              // Glassmorphism background
              color: AppColors.glassColor,
              borderRadius: BorderRadius.circular(screenSize.width * 0.045),
              border: Border.all(
                color: AppColors.glassBorderColor,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.blackColor.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: AppColors.blackColor.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(screenSize.width * 0.045),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Column(
                  children: [
                    _buildHeader(context, screenSize),
                    _buildContent(
                      context,
                      screenSize,
                      hasSpaceLeft,
                      teamCapacityText,
                      isExpired,
                      tournamentStarted,
                      buttonsEnabled,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, Size screenSize) {
    final invitation = widget.invitation;
    final isSent = widget.isSent;

    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (invitation.isAccepted) {
      statusColor = AppColors.successColor;
      statusIcon = Icons.check_circle_rounded;
      statusText = 'ACCEPTED';
    } else if (invitation.isRejected) {
      statusColor = AppColors.errorColor;
      statusIcon = Icons.cancel_rounded;
      statusText = 'DECLINED';
    } else {
      statusColor = AppColors.primaryColor;
      statusIcon = Icons.schedule_rounded;
      statusText = 'PENDING';
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenSize.width * 0.045),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(screenSize.width * 0.025),
                decoration: BoxDecoration(
                  color: AppColors.glassLightColor,
                  borderRadius: BorderRadius.circular(screenSize.width * 0.025),
                  border: Border.all(
                    color: AppColors.glassBorderColor,
                    width: 1,
                  ),
                ),
                child: Icon(
                  invitation.isUniversal
                      ? Icons.link_rounded
                      : Icons.group_rounded,
                  color: AppColors.textPrimaryColor,
                  size: screenSize.width * 0.065,
                ),
              ),
              SizedBox(width: screenSize.width * 0.035),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invitation.team.name,
                      style: AppTexts.emphasizedTextStyle(
                        context: context,
                        textColor: AppColors.textPrimaryColor,
                        fontSize: screenSize.width * 0.048,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: screenSize.width * 0.008),
                    Text(
                      invitation.tournament?.title ?? 'Team Invitation',
                      style: AppTexts.bodyTextStyle(
                        context: context,
                        textColor: AppColors.textSecondaryColor,
                        fontSize: screenSize.width * 0.034,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Only show status for received invitations, not sent ones
              if (!isSent) ...[
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenSize.width * 0.03,
                    vertical: screenSize.width * 0.018,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(
                      screenSize.width * 0.06,
                    ),
                    border: Border.all(
                      color: statusColor.withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusIcon,
                        color: statusColor,
                        size: screenSize.width * 0.038,
                      ),
                      SizedBox(width: screenSize.width * 0.012),
                      Text(
                        statusText,
                        style: AppTexts.bodyTextStyle(
                          context: context,
                          textColor: statusColor,
                          fontSize: screenSize.width * 0.027,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: screenSize.width * 0.025),
          // Tournament gender and start date (only if tournament data is available)
          if (invitation.tournament != null) ...[
            Row(
              children: [
                _buildHeaderChip(
                  context,
                  screenSize,
                  Icons.sports_rounded,
                  invitation.tournament!.gender.toUpperCase(),
                  AppColors.glassColor,
                ),
                SizedBox(width: screenSize.width * 0.025),
                _buildHeaderChip(
                  context,
                  screenSize,
                  Icons.calendar_today_rounded,
                  _formatDate(invitation.tournament!.tournamentStartDate),
                  AppColors.glassColor,
                ),
              ],
            ),
          ] else ...[

          ],
        ],
      ),
    );
  }

  Widget _buildContent(
      BuildContext context,
      Size screenSize,
      bool hasSpaceLeft,
      String teamCapacityText,
      bool isExpired,
      bool tournamentStarted,
      bool buttonsEnabled,
      ) {
    final invitation = widget.invitation;
    final isSent = widget.isSent;

    return Padding(
      padding: EdgeInsets.all(screenSize.width * 0.045),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Team capacity and invitation details
          Row(
            children: [
              _buildInfoChip(
                context,
                screenSize,
                Icons.people_rounded,
                'Team Size',
                teamCapacityText,
                hasSpaceLeft ? AppColors.successColor : AppColors.errorColor,
              ),
              SizedBox(width: screenSize.width * 0.025),
              _buildInfoChip(
                context,
                screenSize,
                Icons.schedule_rounded,
                'Expires',
                _formatDate(invitation.expiresAt),
                isExpired ? AppColors.errorColor : AppColors.primaryColor,
              ),
            ],
          ),

          // Message section (if available)
          if (invitation.message.isNotEmpty) ...[
            SizedBox(height: screenSize.width * 0.035),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(screenSize.width * 0.035),
              decoration: BoxDecoration(
                color: AppColors.glassLightColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(screenSize.width * 0.03),
                border: Border.all(
                  color: AppColors.glassBorderColor.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.message_rounded,
                        color: AppColors.primaryColor,
                        size: screenSize.width * 0.04,
                      ),
                      SizedBox(width: screenSize.width * 0.02),
                      Text(
                        'Message',
                        style: AppTexts.emphasizedTextStyle(
                          context: context,
                          textColor: AppColors.textPrimaryColor,
                          fontSize: screenSize.width * 0.035,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenSize.width * 0.02),
                  Text(
                    invitation.message,
                    style: AppTexts.bodyTextStyle(
                      context: context,
                      textColor: AppColors.textSecondaryColor,
                      fontSize: screenSize.width * 0.033,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Warning messages for various states
          if (isExpired || !hasSpaceLeft || tournamentStarted) ...[
            SizedBox(height: screenSize.width * 0.03),
            _buildWarningMessage(
              context,
              screenSize,
              isExpired,
              hasSpaceLeft,
              tournamentStarted,
            ),
          ],

          // Action buttons section
          if (!isSent) ...[
            SizedBox(height: screenSize.width * 0.04),
            _buildActionButtons(
              context,
              screenSize,
              buttonsEnabled,
            ),
          ] else ...[

          ],
        ],
      ),
    );
  }

  Widget _buildHeaderChip(
      BuildContext context,
      Size screenSize,
      IconData icon,
      String text,
      Color backgroundColor,
      ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenSize.width * 0.025,
        vertical: screenSize.width * 0.012,
      ),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(screenSize.width * 0.04),
        border: Border.all(
          color: AppColors.glassBorderColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppColors.textPrimaryColor,
            size: screenSize.width * 0.032,
          ),
          SizedBox(width: screenSize.width * 0.015),
          Text(
            text,
            style: AppTexts.bodyTextStyle(
              context: context,
              textColor: AppColors.textPrimaryColor,
              fontSize: screenSize.width * 0.028,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(
      BuildContext context,
      Size screenSize,
      IconData icon,
      String label,
      String value,
      Color color,
      ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(screenSize.width * 0.03),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(screenSize.width * 0.025),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: screenSize.width * 0.045,
            ),
            SizedBox(height: screenSize.width * 0.015),
            Text(
              label,
              style: AppTexts.bodyTextStyle(
                context: context,
                textColor: AppColors.textTertiaryColor,
                fontSize: screenSize.width * 0.028,
              ),
            ),
            SizedBox(height: screenSize.width * 0.005),
            Text(
              value,
              style: AppTexts.emphasizedTextStyle(
                context: context,
                textColor: color,
                fontSize: screenSize.width * 0.032,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningMessage(
      BuildContext context,
      Size screenSize,
      bool isExpired,
      bool hasSpaceLeft,
      bool tournamentStarted,
      ) {
    String message;
    IconData icon;
    Color color = AppColors.warningColor;

    if (tournamentStarted) {
      message = 'Tournament has already started';
      icon = Icons.event_busy_rounded;
      color = AppColors.errorColor;
    } else if (isExpired) {
      message = 'This invitation has expired';
      icon = Icons.schedule_rounded;
      color = AppColors.errorColor;
    } else if (!hasSpaceLeft) {
      message = 'Team is full';
      icon = Icons.group_off_rounded;
      color = AppColors.errorColor;
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenSize.width * 0.03),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(screenSize.width * 0.025),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: screenSize.width * 0.04,
          ),
          SizedBox(width: screenSize.width * 0.025),
          Expanded(
            child: Text(
              message,
              style: AppTexts.bodyTextStyle(
                context: context,
                textColor: color,
                fontSize: screenSize.width * 0.032,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context,
      Size screenSize,
      bool buttonsEnabled,
      ) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            context,
            screenSize,
            'Accept',
            Icons.check_rounded,
            AppColors.successColor,
            buttonsEnabled ? widget.onAccept : null,
          ),
        ),
        SizedBox(width: screenSize.width * 0.025),
        Expanded(
          child: _buildActionButton(
            context,
            screenSize,
            'Decline',
            Icons.close_rounded,
            AppColors.errorColor,
            buttonsEnabled ? widget.onDecline : null,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
      BuildContext context,
      Size screenSize,
      String text,
      IconData icon,
      Color color,
      VoidCallback? onTap,
      ) {
    final isEnabled = onTap != null;

    return GestureDetector(
      onTap: isEnabled && !widget.isProcessing ? onTap : null,
      onTapDown: isEnabled && !widget.isProcessing ? (_) => _animationController.forward() : null,
      onTapUp: isEnabled && !widget.isProcessing ? (_) => _animationController.reverse() : null,
      onTapCancel: isEnabled && !widget.isProcessing ? () => _animationController.reverse() : null,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: screenSize.width * 0.035,
          horizontal: screenSize.width * 0.025,
        ),
        decoration: BoxDecoration(
          color: isEnabled
              ? color.withOpacity(0.15)
              : AppColors.greyColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(screenSize.width * 0.03),
          border: Border.all(
            color: isEnabled
                ? color.withOpacity(0.4)
                : AppColors.greyColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.isProcessing && text == 'Accept') ...[
              SizedBox(
                width: screenSize.width * 0.04,
                height: screenSize.width * 0.04,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ] else ...[
              Icon(
                icon,
                color: isEnabled ? color : AppColors.greyColor,
                size: screenSize.width * 0.04,
              ),
            ],
            SizedBox(width: screenSize.width * 0.02),
            Text(
              text,
              style: AppTexts.emphasizedTextStyle(
                context: context,
                textColor: isEnabled ? color : AppColors.greyColor,
                fontSize: screenSize.width * 0.035,
              ),
            ),
          ],
        ),
      ),
    );
  }


  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Expired';
    }
  }
}