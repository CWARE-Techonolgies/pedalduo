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

    // Calculate team capacity status
    final hasSpaceLeft =
        invitation.team.totalPlayers < invitation.tournament.playersPerTeam;
    final teamCapacityText =
        '${invitation.team.totalPlayers}/${invitation.tournament.playersPerTeam}';

    // Check if invitation is expired
    final isExpired = DateTime.now().isAfter(invitation.expiresAt);
    final tournamentStarted = DateTime.now().isAfter(
      invitation.tournament.tournamentStartDate,
    );

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
                      invitation.tournament.title,
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
          // Tournament gender and start date
          Row(
            children: [
              _buildHeaderChip(
                context,
                screenSize,
                Icons.sports_rounded,
                invitation.tournament.gender.toUpperCase(),
                AppColors.glassColor,
              ),
              SizedBox(width: screenSize.width * 0.025),
              _buildHeaderChip(
                context,
                screenSize,
                Icons.calendar_today_rounded,
                _formatDate(invitation.tournament.tournamentStartDate),
                AppColors.glassColor,
              ),
            ],
          ),
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
        color: backgroundColor,
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
              fontWeight: FontWeight.w600,
            ),
          ),
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

    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSecondaryColor.withOpacity(0.3),
      ),
      child: Padding(
        padding: EdgeInsets.all(screenSize.width * 0.045),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info or Universal link
            _buildUserInfo(context, screenSize),

            SizedBox(height: screenSize.width * 0.04),

            // Tournament details
            _buildTournamentDetails(
              context,
              screenSize,
              teamCapacityText,
              hasSpaceLeft,
            ),

            SizedBox(height: screenSize.width * 0.035),

            // Message
            if (invitation.message.isNotEmpty &&
                invitation.message != "Universal team invitation link" &&
                invitation.message != "Invitation to join the team")
              _buildMessage(context, screenSize),

            // Invitation details
            _buildInvitationDetails(context, screenSize, isExpired),

            // Action buttons for received pending invitations
            if (!isSent && invitation.isPending)
              _buildActionButtons(context, screenSize, buttonsEnabled),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context, Size screenSize) {
    final invitation = widget.invitation;
    final isSent = widget.isSent;

    if (invitation.isUniversal) {
      return Container(
        padding: EdgeInsets.all(screenSize.width * 0.035),
        decoration: BoxDecoration(
          color: AppColors.accentPurpleColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(screenSize.width * 0.025),
          border: Border.all(
            color: AppColors.accentPurpleColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(screenSize.width * 0.02),
              decoration: BoxDecoration(
                color: AppColors.accentPurpleColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(screenSize.width * 0.02),
              ),
              child: Icon(
                Icons.link_rounded,
                color: AppColors.accentPurpleColor,
                size: screenSize.width * 0.05,
              ),
            ),
            SizedBox(width: screenSize.width * 0.035),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Universal Invitation',
                    style: AppTexts.emphasizedTextStyle(
                      context: context,
                      textColor: AppColors.accentPurpleColor,
                      fontSize: screenSize.width * 0.037,
                    ),
                  ),
                  Text(
                    'Code: ${invitation.invitationCode}',
                    style: AppTexts.bodyTextStyle(
                      context: context,
                      textColor: AppColors.textSecondaryColor,
                      fontSize: screenSize.width * 0.03,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (widget.onCopyLink != null)
              GestureDetector(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(text: invitation.invitationCode),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Invitation code copied!'),
                      duration: Duration(seconds: 2),
                      backgroundColor: AppColors.darkSecondaryColor,
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(screenSize.width * 0.02),
                  decoration: BoxDecoration(
                    color: AppColors.accentPurpleColor,
                    borderRadius: BorderRadius.circular(
                      screenSize.width * 0.02,
                    ),
                  ),
                  child: Icon(
                    Icons.copy_rounded,
                    color: AppColors.textPrimaryColor,
                    size: screenSize.width * 0.04,
                  ),
                ),
              ),
          ],
        ),
      );
    } else {
      final user = isSent ? invitation.invitee : invitation.inviter;
      return Container(
        padding: EdgeInsets.all(screenSize.width * 0.035),
        decoration: BoxDecoration(
          color: AppColors.glassColor,
          borderRadius: BorderRadius.circular(screenSize.width * 0.025),
          border: Border.all(
            color: AppColors.glassBorderColor,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: screenSize.width * 0.055,
              backgroundColor: AppColors.primaryColor,
              child: Text(
                user?.initials ?? 'U',
                style: AppTexts.emphasizedTextStyle(
                  context: context,
                  textColor: AppColors.textPrimaryColor,
                  fontSize: screenSize.width * 0.042,
                ),
              ),
            ),
            SizedBox(width: screenSize.width * 0.035),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isSent ? 'Invited Player:' : 'Invitation From:',
                    style: AppTexts.bodyTextStyle(
                      context: context,
                      textColor: AppColors.textTertiaryColor,
                      fontSize: screenSize.width * 0.03,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: screenSize.width * 0.008),
                  Text(
                    user?.name ?? 'Unknown User',
                    style: AppTexts.emphasizedTextStyle(
                      context: context,
                      textColor: AppColors.textPrimaryColor,
                      fontSize: screenSize.width * 0.037,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (user?.email != null && user!.email.isNotEmpty) ...[
                    SizedBox(height: screenSize.width * 0.005),
                    Text(
                      user.email,
                      style: AppTexts.bodyTextStyle(
                        context: context,
                        textColor: AppColors.textSecondaryColor,
                        fontSize: screenSize.width * 0.028,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildTournamentDetails(
      BuildContext context,
      Size screenSize,
      String teamCapacityText,
      bool hasSpaceLeft,
      ) {
    final invitation = widget.invitation;

    return Row(
      children: [
        Expanded(
          child: _buildInfoItem(
            context,
            screenSize,
            Icons.location_on_rounded,
            'Location',
            invitation.tournament.location,
            AppColors.errorColor,
            subtitle: '',
          ),
        ),
        SizedBox(width: screenSize.width * 0.04),
        Expanded(
          child: _buildInfoItem(
            context,
            screenSize,
            Icons.people_rounded,
            'Team Size',
            teamCapacityText,
            hasSpaceLeft ? AppColors.successColor : AppColors.warningColor,
            subtitle: hasSpaceLeft ? 'Space Available' : 'Team Full',
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(
      BuildContext context,
      Size screenSize,
      IconData icon,
      String label,
      String value,
      Color color, {
        String? subtitle,
      }) {
    return Container(
      padding: EdgeInsets.all(screenSize.width * 0.03),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(screenSize.width * 0.025),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(screenSize.width * 0.015),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(screenSize.width * 0.015),
            ),
            child: Icon(icon, size: screenSize.width * 0.04, color: color),
          ),
          SizedBox(width: screenSize.width * 0.025),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: color,
                    fontSize: screenSize.width * 0.027,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: screenSize.width * 0.005),
                Text(
                  value,
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.textPrimaryColor,
                    fontSize: screenSize.width * 0.032,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: screenSize.width * 0.002),
                  Text(
                    subtitle,
                    style: AppTexts.bodyTextStyle(
                      context: context,
                      textColor: color,
                      fontSize: screenSize.width * 0.024,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(BuildContext context, Size screenSize) {
    return Container(
      margin: EdgeInsets.only(bottom: screenSize.width * 0.035),
      padding: EdgeInsets.all(screenSize.width * 0.035),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(screenSize.width * 0.025),
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.message_rounded,
            color: AppColors.primaryColor,
            size: screenSize.width * 0.045,
          ),
          SizedBox(width: screenSize.width * 0.025),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Message',
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.primaryColor,
                    fontSize: screenSize.width * 0.03,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: screenSize.width * 0.01),
                Text(
                  widget.invitation.message,
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.textPrimaryColor,
                    fontSize: screenSize.width * 0.034,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvitationDetails(
      BuildContext context,
      Size screenSize,
      bool isExpired,
      ) {
    final invitation = widget.invitation;

    return Container(
      margin: EdgeInsets.only(bottom: screenSize.width * 0.04),
      padding: EdgeInsets.all(screenSize.width * 0.03),
      decoration: BoxDecoration(
        color: AppColors.glassColor,
        borderRadius: BorderRadius.circular(screenSize.width * 0.02),
        border: Border.all(
          color: AppColors.glassBorderColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDetailItem(
                context,
                screenSize,
                Icons.schedule_rounded,
                'Expires',
                _formatDate(invitation.expiresAt),
                isExpired ? AppColors.errorColor : AppColors.warningColor,
              ),
              _buildDetailItem(
                context,
                screenSize,
                Icons.send_rounded,
                'Sent',
                _formatDate(invitation.createdAt),
                AppColors.accentBlueColor,
              ),
            ],
          ),
          SizedBox(height: screenSize.width * 0.025),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDetailItem(
                context,
                screenSize,
                Icons.qr_code_rounded,
                'Code',
                invitation.invitationCode,
                AppColors.accentPurpleColor,
              ),
              _buildDetailItem(
                context,
                screenSize,
                Icons.category_rounded,
                'Type',
                invitation.invitationType.replaceAll('_', ' ').toUpperCase(),
                AppColors.primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
      BuildContext context,
      Size screenSize,
      IconData icon,
      String label,
      String value,
      Color color,
      ) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: screenSize.width * 0.035, color: color),
          SizedBox(width: screenSize.width * 0.015),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: color,
                    fontSize: screenSize.width * 0.025,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.textPrimaryColor,
                    fontSize: screenSize.width * 0.028,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Size screenSize, bool buttonsEnabled) {
    final hasSpaceLeft = widget.invitation.team.totalPlayers < widget.invitation.tournament.playersPerTeam;
    final isExpired = DateTime.now().isAfter(widget.invitation.expiresAt);
    final tournamentStarted = DateTime.now().isAfter(widget.invitation.tournament.tournamentStartDate);

    // Show disabled message if buttons are not enabled
    if (!buttonsEnabled) {
      String disabledReason = '';
      if (!hasSpaceLeft) {
        disabledReason = 'Team is full';
      } else if (isExpired) {
        disabledReason = 'Invitation expired';
      } else if (tournamentStarted) {
        disabledReason = 'Tournament has started';
      }

      if (disabledReason.isNotEmpty) {
        return Container(
          margin: EdgeInsets.only(top: screenSize.width * 0.02),
          padding: EdgeInsets.all(screenSize.width * 0.03),
          decoration: BoxDecoration(
            color: AppColors.greyColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(screenSize.width * 0.025),
            border: Border.all(
              color: AppColors.greyColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppColors.darkGreyColor,
                size: screenSize.width * 0.045,
              ),
              SizedBox(width: screenSize.width * 0.02),
              Text(
                disabledReason,
                style: AppTexts.bodyTextStyle(
                  context: context,
                  textColor: AppColors.darkGreyColor,
                  fontSize: screenSize.width * 0.032,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }
    }

    return Container(
      margin: EdgeInsets.only(top: screenSize.width * 0.02),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTapDown: buttonsEnabled ? (_) => _animationController.forward() : null,
              onTapUp: buttonsEnabled ? (_) => _animationController.reverse() : null,
              onTapCancel: buttonsEnabled ? () => _animationController.reverse() : null,
              onTap: (_isLoading || !buttonsEnabled)
                  ? null
                  : () async {
                setState(() => _isLoading = true);
                widget.onDecline?.call();
                setState(() => _isLoading = false);
              },
              child: Opacity(
                opacity: buttonsEnabled ? 1.0 : 0.5,
                child: Container(
                  height: screenSize.width * 0.12,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.redColor.withOpacity(0.8),
                        AppColors.redColor,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(screenSize.width * 0.025),
                    boxShadow: buttonsEnabled
                        ? [
                      BoxShadow(
                        color: AppColors.redColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                        : [],
                  ),
                  child: _isLoading
                      ? Center(
                    child: SizedBox(
                      width: screenSize.width * 0.05,
                      height: screenSize.width * 0.05,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.whiteColor,
                        ),
                      ),
                    ),
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.close_rounded,
                        color: AppColors.whiteColor,
                        size: screenSize.width * 0.05,
                      ),
                      SizedBox(width: screenSize.width * 0.02),
                      Text(
                        'DECLINE',
                        style: AppTexts.bodyTextStyle(
                          context: context,
                          textColor: AppColors.whiteColor,
                          fontSize: screenSize.width * 0.035,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: screenSize.width * 0.04),
          Expanded(
            child: GestureDetector(
              onTapDown: buttonsEnabled ? (_) => _animationController.forward() : null,
              onTapUp: buttonsEnabled ? (_) => _animationController.reverse() : null,
              onTapCancel: buttonsEnabled ? () => _animationController.reverse() : null,
              onTap: (_isLoading || !buttonsEnabled)
                  ? null
                  : () async {
                setState(() => _isLoading = true);
                widget.onAccept?.call();
                setState(() => _isLoading = false);
              },
              child: Opacity(
                opacity: buttonsEnabled ? 1.0 : 0.5,
                child: Container(
                  height: screenSize.width * 0.12,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.orangeColor, AppColors.lightOrangeColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(screenSize.width * 0.025),
                    boxShadow: buttonsEnabled
                        ? [
                      BoxShadow(
                        color: AppColors.greenColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                        : [],
                  ),
                  child: _isLoading
                      ? Center(
                    child: SizedBox(
                      width: screenSize.width * 0.05,
                      height: screenSize.width * 0.05,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.whiteColor,
                        ),
                      ),
                    ),
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_rounded,
                        color: AppColors.whiteColor,
                        size: screenSize.width * 0.05,
                      ),
                      SizedBox(width: screenSize.width * 0.02),
                      Text(
                        'ACCEPT',
                        style: AppTexts.bodyTextStyle(
                          context: context,
                          textColor: AppColors.whiteColor,
                          fontSize: screenSize.width * 0.035,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays > 0) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays == 0) {
      return 'Today';
    } else {
      return 'Expired';
    }
  }
}