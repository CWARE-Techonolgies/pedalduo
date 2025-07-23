import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../../style/colors.dart';
import '../../../style/fonts_sizes.dart';
import '../../../style/texts.dart';
import '../models/team_model.dart';
import '../providers/team_provider.dart';
import '../views/add_player_screen.dart';

class TeamCardWidget extends StatefulWidget {
  final TeamModel team;
  final bool isCaptain;
  final VoidCallback? onTap;
  final String baseUrl;

  const TeamCardWidget({
    super.key,
    required this.team,
    required this.isCaptain,
    this.onTap,
    required this.baseUrl,
  });

  @override
  State<TeamCardWidget> createState() => _TeamCardWidgetState();
}

class _TeamCardWidgetState extends State<TeamCardWidget> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.015),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(screenWidth * 0.05),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.glassLightColor,
                  AppColors.glassColor,
                  AppColors.transparentColor.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(screenWidth * 0.05),
              border: Border.all(color: AppColors.glassBorderColor, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.blackColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(screenWidth * 0.05),
                splashColor: AppColors.primaryColor.withOpacity(0.1),
                highlightColor: AppColors.primaryLightColor.withOpacity(0.05),
                child: Container(
                  padding: EdgeInsets.all(screenWidth * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        children: [
                          // Team Avatar with glassmorphism border
                          Container(
                            width: screenWidth * 0.16,
                            height: screenWidth * 0.16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.accentCyanColor.withOpacity(0.8),
                                  AppColors.accentBlueColor.withOpacity(0.6),
                                  AppColors.accentPurpleColor.withOpacity(0.4),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accentCyanColor.withOpacity(
                                    0.4,
                                  ),
                                  blurRadius: 15,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Container(
                              margin: const EdgeInsets.all(2.5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.darkSecondaryColor,
                                border: Border.all(
                                  color: AppColors.glassBorderColor,
                                  width: 1,
                                ),
                              ),
                              child: ClipOval(
                                child:
                                    widget.team.teamAvatar != null
                                        ? Image.memory(
                                          base64Decode(
                                            widget.team.teamAvatar!.split(
                                              ',',
                                            )[1],
                                          ),
                                          fit: BoxFit.cover,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return _buildDefaultAvatar(
                                              screenWidth,
                                            );
                                          },
                                        )
                                        : _buildDefaultAvatar(screenWidth),
                              ),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.04),

                          // Team Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        widget.team.name,
                                        style: AppTexts.emphasizedTextStyle(
                                          context: context,
                                          textColor: AppColors.textPrimaryColor,
                                          fontSize:
                                              AppFontSizes(context).size18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: screenHeight * 0.008),
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(
                                        screenWidth * 0.015,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.goldColor.withOpacity(
                                              0.2,
                                            ),
                                            AppColors.goldColor.withOpacity(
                                              0.1,
                                            ),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          screenWidth * 0.02,
                                        ),
                                        border: Border.all(
                                          color: AppColors.goldColor
                                              .withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.emoji_events,
                                        color: AppColors.goldColor,
                                        size: screenWidth * 0.035,
                                      ),
                                    ),
                                    SizedBox(width: screenWidth * 0.02),
                                    Expanded(
                                      child: Text(
                                        widget.team.tournament.title,
                                        style: AppTexts.bodyTextStyle(
                                          context: context,
                                          textColor:
                                              AppColors.textSecondaryColor,
                                          fontSize:
                                              AppFontSizes(context).size14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Status Badge with glassmorphism
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              screenWidth * 0.04,
                            ),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.04,
                                  vertical: screenHeight * 0.01,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      _getStatusColor(
                                        widget.team.tournament.status,
                                      ).withOpacity(0.3),
                                      _getStatusColor(
                                        widget.team.tournament.status,
                                      ).withOpacity(0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    screenWidth * 0.04,
                                  ),
                                  border: Border.all(
                                    color: _getStatusColor(
                                      widget.team.tournament.status,
                                    ).withOpacity(0.5),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _getStatusColor(
                                        widget.team.tournament.status,
                                      ).withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  widget.team.tournament.status,
                                  style: AppTexts.bodyTextStyle(
                                    context: context,
                                    textColor: _getStatusColor(
                                      widget.team.tournament.status,
                                    ),
                                    fontSize: AppFontSizes(context).size11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: screenHeight * 0.025),

                      // Stats Row with glassmorphism
                      Row(
                        children: [
                          _buildStatItem(
                            context,
                            'Players',
                            '${widget.team.totalPlayers}',
                            Icons.group,
                            AppColors.accentBlueColor,
                            screenWidth,
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          _buildStatItem(
                            context,
                            'Matches',
                            '${widget.team.matchesPlayed}',
                            Icons.sports_soccer,
                            AppColors.accentPurpleColor,
                            screenWidth,
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          _buildStatItem(
                            context,
                            'Wins',
                            '${widget.team.matchesWon}',
                            Icons.emoji_events,
                            AppColors.goldColor,
                            screenWidth,
                          ),
                        ],
                      ),

                      SizedBox(height: screenHeight * 0.025),

                      // Tournament Info with enhanced glassmorphism
                      ClipRRect(
                        borderRadius: BorderRadius.circular(screenWidth * 0.04),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            padding: EdgeInsets.all(screenWidth * 0.04),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.darkSecondaryColor.withOpacity(0.6),
                                  AppColors.darkTertiaryColor.withOpacity(0.4),
                                  AppColors.transparentColor.withOpacity(0.2),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(
                                screenWidth * 0.04,
                              ),
                              border: Border.all(
                                color: AppColors.glassBorderColor,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    _buildInfoIcon(
                                      Icons.location_on,
                                      AppColors.accentCyanColor,
                                      screenWidth,
                                    ),
                                    SizedBox(width: screenWidth * 0.03),
                                    Expanded(
                                      child: Text(
                                        widget.team.tournament.location,
                                        style: AppTexts.bodyTextStyle(
                                          context: context,
                                          textColor:
                                              AppColors.textSecondaryColor,
                                          fontSize:
                                              AppFontSizes(context).size13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    _buildInfoIcon(
                                      Icons.calendar_today,
                                      AppColors.accentPinkColor,
                                      screenWidth,
                                    ),
                                    SizedBox(width: screenWidth * 0.03),
                                    Text(
                                      DateFormat('MMM dd').format(
                                        widget
                                            .team
                                            .tournament
                                            .tournamentStartDate,
                                      ),
                                      style: AppTexts.bodyTextStyle(
                                        context: context,
                                        textColor: AppColors.textSecondaryColor,
                                        fontSize: AppFontSizes(context).size13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: screenHeight * 0.015),
                                Row(
                                  children: [
                                    _buildInfoIcon(
                                      widget.team.isPaymentComplete
                                          ? Icons.check_circle
                                          : Icons.warning,
                                      widget.team.isPaymentComplete
                                          ? AppColors.successColor
                                          : AppColors.warningColor,
                                      screenWidth,
                                    ),
                                    SizedBox(width: screenWidth * 0.03),
                                    Expanded(
                                      child: Text(
                                        widget.team.isPaymentComplete
                                            ? 'Payment Complete'
                                            : 'Payment Pending',
                                        style: AppTexts.bodyTextStyle(
                                          context: context,
                                          textColor:
                                              widget.team.isPaymentComplete
                                                  ? AppColors.successColor
                                                  : AppColors.warningColor,
                                          fontSize:
                                              AppFontSizes(context).size13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        screenWidth * 0.03,
                                      ),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                          sigmaX: 3,
                                          sigmaY: 3,
                                        ),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: screenWidth * 0.025,
                                            vertical: screenHeight * 0.008,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                AppColors.glassLightColor,
                                                AppColors.glassColor,
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              screenWidth * 0.03,
                                            ),
                                            border: Border.all(
                                              color: AppColors.glassBorderColor,
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            'PKR ${widget.team.totalAmountPaid}',
                                            style: AppTexts.emphasizedTextStyle(
                                              context: context,
                                              textColor:
                                                  AppColors.textPrimaryColor,
                                              fontSize:
                                                  AppFontSizes(context).size13,
                                            ),
                                          ),
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

                      SizedBox(height: screenHeight * 0.025),

                      // Action Buttons with glassmorphism
                      if (widget.isCaptain) ...[
                        if (widget.team.tournament.status == 'Cancelled') ...[
                          _buildStatusMessage(
                            'This tournament has been cancelled',
                            AppColors.warningColor,
                            context,
                            screenWidth,
                          ),
                        ] else ...[
                          if (!widget.team.isPaymentComplete) ...[
                            _buildPayNowButton(
                              context,
                              screenWidth,
                              screenHeight,
                            ),
                          ] else if (widget.team.tournament.status !=
                              'Completed') ...[
                            Row(
                              children: [
                                Expanded(
                                  child: _buildActionButton(
                                    context,
                                    'Add Players',
                                    Icons.person_add,
                                    AppColors.accentBlueColor,
                                    () => _navigateToAddPlayers(context),
                                    screenWidth,
                                    screenHeight,
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.04),
                                Expanded(
                                  child: _buildActionButton(
                                    context,
                                    'Withdraw',
                                    Icons.logout,
                                    AppColors.errorColor,
                                    () => _showWithdrawDialog(context),
                                    screenWidth,
                                    screenHeight,
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            _buildStatusMessage(
                              widget.team.isEliminated
                                  ? 'Your Team has been eliminated'
                                  : 'Congratulations! You won this tournament',
                              widget.team.isEliminated
                                  ? AppColors.errorColor
                                  : AppColors.successColor,
                              context,
                              screenWidth,
                            ),
                          ],
                        ],
                      ],
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

  Widget _buildDefaultAvatar(double screenWidth) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accentCyanColor.withOpacity(0.3),
            AppColors.accentBlueColor.withOpacity(0.2),
            AppColors.accentPurpleColor.withOpacity(0.1),
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.group,
        color: AppColors.accentCyanColor,
        size: screenWidth * 0.08,
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
    double screenWidth,
  ) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            padding: EdgeInsets.all(screenWidth * 0.04),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.2),
                  color.withOpacity(0.1),
                  color.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(screenWidth * 0.04),
              border: Border.all(color: color.withOpacity(0.3), width: 1),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.025),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withOpacity(0.3), color.withOpacity(0.2)],
                    ),
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                    border: Border.all(color: color.withOpacity(0.4), width: 1),
                  ),
                  child: Icon(icon, color: color, size: screenWidth * 0.05),
                ),
                SizedBox(height: screenWidth * 0.015),
                Text(
                  value,
                  style: AppTexts.emphasizedTextStyle(
                    context: context,
                    textColor: color,
                    fontSize: AppFontSizes(context).size16,
                  ),
                ),
                SizedBox(height: screenWidth * 0.005),
                Text(
                  label,
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: color.withOpacity(0.8),
                    fontSize: AppFontSizes(context).size10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoIcon(IconData icon, Color color, double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.025),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(screenWidth * 0.025),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Icon(icon, color: color, size: screenWidth * 0.04),
    );
  }

  Widget _buildStatusMessage(
    String message,
    Color color,
    BuildContext context,
    double screenWidth,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(screenWidth * 0.04),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(screenWidth * 0.04),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
            ),
            borderRadius: BorderRadius.circular(screenWidth * 0.04),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: AppTexts.emphasizedTextStyle(
              context: context,
              textColor: color,
              fontSize: AppFontSizes(context).size16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPayNowButton(
    BuildContext context,
    double screenWidth,
    double screenHeight,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(screenWidth * 0.04),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.successColor.withOpacity(0.8),
                AppColors.successColor.withOpacity(0.6),
                AppColors.successColor.withOpacity(0.4),
              ],
            ),
            borderRadius: BorderRadius.circular(screenWidth * 0.04),
            border: Border.all(
              color: AppColors.successColor.withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.successColor.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isProcessing ? null : () => _processPayment(''),
              borderRadius: BorderRadius.circular(screenWidth * 0.04),
              splashColor: AppColors.successColor.withOpacity(0.2),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.018),
                child:
                    _isProcessing
                        ? Center(
                          child: SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.textPrimaryColor,
                              ),
                            ),
                          ),
                        )
                        : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.payment,
                              color: AppColors.textPrimaryColor,
                              size: screenWidth * 0.06,
                            ),
                            SizedBox(width: screenWidth * 0.03),
                            Text(
                              'Pay Now',
                              style: AppTexts.emphasizedTextStyle(
                                context: context,
                                textColor: AppColors.textPrimaryColor,
                                fontSize: AppFontSizes(context).size16,
                              ),
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

  Widget _buildActionButton(
    BuildContext context,
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
    double screenWidth,
    double screenHeight,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(screenWidth * 0.04),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.3),
                color.withOpacity(0.2),
                color.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(screenWidth * 0.04),
            border: Border.all(color: color.withOpacity(0.4), width: 1),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(screenWidth * 0.04),
              splashColor: color.withOpacity(0.2),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: color, size: screenWidth * 0.05),
                    SizedBox(width: screenWidth * 0.02),
                    Text(
                      text,
                      style: AppTexts.emphasizedTextStyle(
                        context: context,
                        textColor: color,
                        fontSize: AppFontSizes(context).size14,
                      ),
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

  void _showPaymentDialog(BuildContext context) {
    final TextEditingController phoneController = TextEditingController();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.blackColor.withOpacity(0.7),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.05),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(screenWidth * 0.05),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: EdgeInsets.all(screenWidth * 0.06),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.glassLightColor, AppColors.glassColor],
                  ),
                  borderRadius: BorderRadius.circular(screenWidth * 0.05),
                  border: Border.all(
                    color: AppColors.glassBorderColor,
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryColor,
                            AppColors.primaryLightColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryColor.withOpacity(0.3),
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.payment,
                        color: AppColors.textPrimaryColor,
                        size: screenWidth * 0.08,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      'Payment Details',
                      style: AppTexts.emphasizedTextStyle(
                        context: context,
                        textColor: AppColors.textPrimaryColor,
                        fontSize: AppFontSizes(context).size20,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      'Complete your team registration payment',
                      style: AppTexts.bodyTextStyle(
                        context: context,
                        textColor: AppColors.textSecondaryColor,
                        fontSize: AppFontSizes(context).size14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenHeight * 0.025),

                    // Amount Display
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.successColor.withOpacity(0.2),
                            AppColors.successColor.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        border: Border.all(
                          color: AppColors.successColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Amount to Pay',
                            style: AppTexts.bodyTextStyle(
                              context: context,
                              textColor: AppColors.textSecondaryColor,
                              fontSize: AppFontSizes(context).size12,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.005),
                          Text(
                            'PKR ${widget.team.totalAmountPaid}',
                            style: AppTexts.emphasizedTextStyle(
                              context: context,
                              textColor: AppColors.successColor,
                              fontSize: AppFontSizes(context).size24,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // Phone Number Input
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.glassColor,
                            AppColors.glassLightColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        border: Border.all(
                          color: AppColors.glassBorderColor,
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: 'Enter EasyPaisa Number',
                          hintStyle: AppTexts.bodyTextStyle(
                            context: context,
                            textColor: AppColors.textTertiaryColor,
                            fontSize: AppFontSizes(context).size14,
                          ),
                          prefixIcon: Container(
                            padding: EdgeInsets.all(screenWidth * 0.02),
                            child: Icon(
                              Icons.phone,
                              color: AppColors.primaryColor,
                              size: screenWidth * 0.05,
                            ),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04,
                            vertical: screenHeight * 0.015,
                          ),
                        ),
                        style: AppTexts.bodyTextStyle(
                          context: context,
                          textColor: AppColors.textPrimaryColor,
                          fontSize: AppFontSizes(context).size14,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.015,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  screenWidth * 0.03,
                                ),
                                side: BorderSide(
                                  color: AppColors.glassBorderColor,
                                ),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: AppTexts.bodyTextStyle(
                                context: context,
                                textColor: AppColors.textSecondaryColor,
                                fontSize: AppFontSizes(context).size14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.03),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (phoneController.text.isNotEmpty) {
                                Navigator.of(context).pop();
                                _processPayment(phoneController.text);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: AppColors.textPrimaryColor,
                              padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.015,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  screenWidth * 0.03,
                                ),
                              ),
                              elevation: 10,
                              shadowColor: AppColors.primaryColor.withOpacity(
                                0.5,
                              ),
                            ),
                            child: Text(
                              'Pay Now',
                              style: AppTexts.emphasizedTextStyle(
                                context: context,
                                textColor: AppColors.textPrimaryColor,
                                fontSize: AppFontSizes(context).size14,
                              ),
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
        );
      },
    );
  }

  void _showWithdrawDialog(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.blackColor.withOpacity(0.7),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.05),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(screenWidth * 0.05),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: EdgeInsets.all(screenWidth * 0.06),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.glassLightColor, AppColors.glassColor],
                  ),
                  borderRadius: BorderRadius.circular(screenWidth * 0.05),
                  border: Border.all(
                    color: AppColors.glassBorderColor,
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.errorColor,
                            AppColors.errorColor.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.errorColor.withOpacity(0.3),
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.warning,
                        color: AppColors.textPrimaryColor,
                        size: screenWidth * 0.08,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      'Withdraw Team',
                      style: AppTexts.emphasizedTextStyle(
                        context: context,
                        textColor: AppColors.textPrimaryColor,
                        fontSize: AppFontSizes(context).size20,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      'Are you sure you want to withdraw from this tournament? This action cannot be undone.',
                      style: AppTexts.bodyTextStyle(
                        context: context,
                        textColor: AppColors.textSecondaryColor,
                        fontSize: AppFontSizes(context).size14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenHeight * 0.025),

                    // Team Info
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.glassColor,
                            AppColors.glassLightColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        border: Border.all(
                          color: AppColors.glassBorderColor,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            widget.team.name,
                            style: AppTexts.emphasizedTextStyle(
                              context: context,
                              textColor: AppColors.textPrimaryColor,
                              fontSize: AppFontSizes(context).size16,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.005),
                          Text(
                            widget.team.tournament.title,
                            style: AppTexts.bodyTextStyle(
                              context: context,
                              textColor: AppColors.textSecondaryColor,
                              fontSize: AppFontSizes(context).size12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.015,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  screenWidth * 0.03,
                                ),
                                side: BorderSide(
                                  color: AppColors.glassBorderColor,
                                ),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: AppTexts.bodyTextStyle(
                                context: context,
                                textColor: AppColors.textSecondaryColor,
                                fontSize: AppFontSizes(context).size14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.03),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _withdrawTeam();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.errorColor,
                              foregroundColor: AppColors.textPrimaryColor,
                              padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.015,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  screenWidth * 0.03,
                                ),
                              ),
                              elevation: 10,
                              shadowColor: AppColors.errorColor.withOpacity(
                                0.5,
                              ),
                            ),
                            child: Text(
                              'Withdraw',
                              style: AppTexts.emphasizedTextStyle(
                                context: context,
                                textColor: AppColors.textPrimaryColor,
                                fontSize: AppFontSizes(context).size14,
                              ),
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
        );
      },
    );
  }

  void _navigateToAddPlayers(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AddPlayersScreen(
              teamId: widget.team.id.toString(),
              baseUrl: widget.baseUrl,
            ),
      ),
    );
  }

  Future<void> _processPayment(String phoneNumber) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse('${widget.baseUrl}teams/${widget.team.id}/payment'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        _showSuccessMessage('Payment processed successfully!');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<TeamProvider>().fetchTeams();
        });
      } else {
        print('error in response ${response.body}');
        _showErrorMessage('Payment failed. Please try again.');
      }
    } catch (e) {
      print('error in e: $e');
      _showErrorMessage('Error processing payment: ${e.toString()}');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _withdrawTeam() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.delete(
        Uri.parse('${widget.baseUrl}teams/${widget.team.id}/withdraw'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print('token is $token, id is ${widget.team.id}');
      if (response.statusCode == 200) {
        _showSuccessMessage('Team withdrawn successfully!');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<TeamProvider>().fetchTeams();
        });
      } else {
        final body = json.decode(response.body);
        final message = body['message'] ?? 'Something went wrong';
        _showErrorMessage('Failed to withdraw team. $message');
      }
    } catch (e) {
      print('error is : $e');
      _showErrorMessage('Error withdrawing team: ${e.toString()}');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: AppColors.textPrimaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 10,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: AppColors.textPrimaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 10,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppColors.successColor;
      case 'pending':
        return AppColors.warningColor;
      case 'rejected':
        return AppColors.errorColor;
      case 'cancelled':
        return AppColors.warningColor;
      default:
        return AppColors.textSecondaryColor;
    }
  }
}
