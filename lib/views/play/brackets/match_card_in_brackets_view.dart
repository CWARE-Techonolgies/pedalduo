import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pedalduo/views/play/models/tournament_data.dart';
import '../../../style/colors.dart';
import '../../../style/fonts_sizes.dart';
import '../../../style/texts.dart';

class MatchCardInBracketsView extends StatelessWidget {
  final MyMatch match;
  final bool isOrganizer;
  final Function(MyMatch) onScheduleMatch;
  final Function(MyMatch) onUpdateScore;

  const MatchCardInBracketsView({
    super.key,
    required this.match,
    required this.isOrganizer,
    required this.onScheduleMatch,
    required this.onUpdateScore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: _buildGlassDecoration(),
      child: Column(
        children: [
          _buildMatchHeader(context),
          match.isCompleted ? _buildWinnerSection(context) : _buildTeamsSection(context),
          if (match.matchDate != null) _buildDateInfo(context),
          if (isOrganizer && !match.isCompleted) _buildActionButtons(context),
        ],
      ),
    );
  }

  BoxDecoration _buildGlassDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppColors.glassLightColor,
          AppColors.glassColor,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.glassBorderColor, width: 1.5),
      boxShadow: [
        BoxShadow(
          color: match.isCompleted ? AppColors.successColor.withOpacity(0.3) : AppColors.darkTertiaryColor.withOpacity(0.2),
          blurRadius: match.isCompleted ? 25 : 15,
          offset: const Offset(0, 8),
          spreadRadius: match.isCompleted ? 3 : 1,
        ),
      ],
    );
  }

  Widget _buildMatchHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: match.isCompleted
              ? [AppColors.successColor.withOpacity(0.3), AppColors.primaryColor.withOpacity(0.2)]
              : [AppColors.darkSecondaryColor, AppColors.darkTertiaryColor],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildMatchNumberChip(context),
          _buildStatusChip(context),
        ],
      ),
    );
  }

  Widget _buildMatchNumberChip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.glassLightColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.glassBorderColor),
      ),
      child: Text(
        'Match ${match.matchNumber}',
        style: AppTexts.bodyTextStyle(
          context: context,
          textColor: AppColors.textPrimaryColor,
          fontSize: AppFontSizes(context).size14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: match.isCompleted
              ? [AppColors.successColor, AppColors.accentCyanColor]
              : [_getStatusColor(), _getStatusColor().withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: _getStatusColor().withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getStatusIcon(), color: AppColors.textPrimaryColor, size: 16),
          const SizedBox(width: 6),
          Text(
            match.isCompleted ? 'COMPLETED' : match.status,
            style: AppTexts.bodyTextStyle(
              context: context,
              textColor: AppColors.textPrimaryColor,
              fontSize: AppFontSizes(context).size12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWinnerSection(BuildContext context) {
    final winner = match.winnerTeam;
    final loser = match.winnerTeamId == match.team1Id ? match.team2 : match.team1;
    final winnerScore = match.winnerTeamId == match.team1Id ? match.team1Score : match.team2Score;
    final loserScore = match.winnerTeamId == match.team1Id ? match.team2Score : match.team1Score;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildWinnerCard(context, winner, winnerScore),
          _buildVSDivider(context),
          _buildLoserCard(context, loser, loserScore),
        ],
      ),
    );
  }

  Widget _buildWinnerCard(BuildContext context, Team? winner, String? score) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.successColor.withOpacity(0.3), AppColors.accentCyanColor.withOpacity(0.2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.successColor.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.successColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildWinnerAvatar(context, winner?.name ?? 'W'),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.emoji_events, color: AppColors.warningColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'WINNER',
                      style: AppTexts.bodyTextStyle(
                        context: context,
                        textColor: AppColors.warningColor,
                        fontSize: AppFontSizes(context).size12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  winner?.name ?? 'Winner',
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.textPrimaryColor,
                    fontSize: AppFontSizes(context).size18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (score != null) _buildScoreChip(context, score, true),
        ],
      ),
    );
  }

  Widget _buildWinnerAvatar(BuildContext context, String initial) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.warningColor, AppColors.primaryColor],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.textPrimaryColor, width: 3),
        boxShadow: [
          BoxShadow(
            color: AppColors.warningColor.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initial.isNotEmpty ? initial[0].toUpperCase() : 'W',
          style: AppTexts.bodyTextStyle(
            context: context,
            textColor: AppColors.textPrimaryColor,
            fontSize: AppFontSizes(context).size24,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _buildVSDivider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: AppColors.glassBorderColor)),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.glassColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.glassBorderColor),
            ),
            child: Text(
              'VS',
              style: AppTexts.bodyTextStyle(
                context: context,
                textColor: AppColors.textSecondaryColor,
                fontSize: AppFontSizes(context).size12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(child: Container(height: 1, color: AppColors.glassBorderColor)),
        ],
      ),
    );
  }

  Widget _buildLoserCard(BuildContext context, Team? loser, String? score) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.darkGreyColor,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Center(
              child: Text(
                loser?.name?.isNotEmpty == true ? loser!.name[0].toUpperCase() : 'L',
                style: AppTexts.bodyTextStyle(
                  context: context,
                  textColor: AppColors.textPrimaryColor,
                  fontSize: AppFontSizes(context).size18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              loser?.name ?? 'Team',
              style: AppTexts.bodyTextStyle(
                context: context,
                textColor: AppColors.textSecondaryColor,
                fontSize: AppFontSizes(context).size16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (score != null) _buildScoreChip(context, score, false),
        ],
      ),
    );
  }

  Widget _buildTeamsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTeamRow(context, match.team1, match.team1Score, match.team1NoShow, match.winnerTeamId == match.team1Id),
          const SizedBox(height: 12),
          _buildVSDivider(context),
          _buildTeamRow(context, match.team2, match.team2Score, match.team2NoShow, match.winnerTeamId == match.team2Id),
        ],
      ),
    );
  }

  Widget _buildTeamRow(BuildContext context, Team team, String? score, bool noShow, bool isWinner) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isWinner
            ? LinearGradient(colors: [AppColors.successColor.withOpacity(0.2), AppColors.glassColor])
            : LinearGradient(colors: [AppColors.glassColor, AppColors.glassLightColor]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWinner ? AppColors.successColor.withOpacity(0.6) : AppColors.glassBorderColor,
          width: isWinner ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: isWinner
                  ? LinearGradient(colors: [AppColors.successColor, AppColors.accentCyanColor])
                  : LinearGradient(colors: [AppColors.darkGreyColor, AppColors.greyColor]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                team.name.isNotEmpty ? team.name[0].toUpperCase() : 'T',
                style: AppTexts.emphasizedTextStyle(
                  context: context,
                  textColor: AppColors.textPrimaryColor,
                  fontSize: AppFontSizes(context).size16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  team.name,
                  style: AppTexts.emphasizedTextStyle(
                    context: context,
                    textColor: AppColors.textPrimaryColor,
                    fontSize: AppFontSizes(context).size16,
                  ),
                ),
                if (noShow)
                  Text(
                    'No Show',
                    style: AppTexts.bodyTextStyle(
                      context: context,
                      textColor: AppColors.errorColor,
                      fontSize: AppFontSizes(context).size12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          if (score != null) _buildScoreChip(context, score, isWinner),
          if (isWinner && match.isCompleted) _buildWinnerIcon(),
        ],
      ),
    );
  }

  Widget _buildScoreChip(BuildContext context, String score, bool isWinner) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: isWinner
            ? LinearGradient(colors: [AppColors.successColor, AppColors.accentCyanColor])
            : LinearGradient(colors: [AppColors.darkGreyColor, AppColors.greyColor]),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: (isWinner ? AppColors.successColor : AppColors.darkGreyColor).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        score,
        style: AppTexts.emphasizedTextStyle(
          context: context,
          textColor: AppColors.textPrimaryColor,
          fontSize: AppFontSizes(context).size16,
        ),
      ),
    );
  }

  Widget _buildWinnerIcon() {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.warningColor, AppColors.primaryColor]),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.warningColor.withOpacity(0.4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(Icons.emoji_events, color: AppColors.textPrimaryColor, size: 16),
    );
  }

  Widget _buildDateInfo(BuildContext context) {
    final DateTime date = DateTime.parse(match.matchDate!);
    final String formattedDate = DateFormat('MMM dd, yyyy').format(date);
    final String formattedTime = DateFormat('hh:mm a').format(date);
    final bool isCompleted = match.isCompleted;

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isCompleted
              ? [AppColors.successColor.withOpacity(0.2), AppColors.glassColor]
              : [AppColors.accentBlueColor.withOpacity(0.2), AppColors.glassColor],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted ? AppColors.successColor.withOpacity(0.5) : AppColors.accentBlueColor.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isCompleted
                    ? [AppColors.successColor, AppColors.accentCyanColor]
                    : [AppColors.accentBlueColor, AppColors.accentPurpleColor],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isCompleted ? Icons.check_circle : Icons.schedule,
              color: AppColors.textPrimaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCompleted ? 'Match Completed' : 'Scheduled for',
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: isCompleted ? AppColors.successColor : AppColors.accentBlueColor,
                    fontSize: AppFontSizes(context).size14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '$formattedDate at $formattedTime',
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.textSecondaryColor,
                    fontSize: AppFontSizes(context).size12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (isCompleted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.successColor, AppColors.accentCyanColor]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'FINAL',
                style: AppTexts.bodyTextStyle(
                  context: context,
                  textColor: AppColors.textPrimaryColor,
                  fontSize: AppFontSizes(context).size10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassColor,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
        border: Border(top: BorderSide(color: AppColors.glassBorderColor)),
      ),
      child: Row(
        children: [
          Expanded(child: _buildActionButton(context, Icons.schedule, match.isScheduled ? 'Reschedule' : 'Schedule Match', AppColors.accentBlueColor, () => onScheduleMatch(match))),
          const SizedBox(width: 12),
          Expanded(child: _buildActionButton(context, Icons.scoreboard, 'Add Scores', AppColors.successColor, () => onUpdateScore(match))),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String text, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: AppColors.textPrimaryColor),
      label: Text(
        text,
        style: AppTexts.bodyTextStyle(
          context: context,
          textColor: AppColors.textPrimaryColor,
          fontSize: AppFontSizes(context).size14,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimaryColor,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ).copyWith(
        backgroundColor: WidgetStateProperty.all(Colors.transparent),
        overlayColor: WidgetStateProperty.all(color.withOpacity(0.1)),
        side: WidgetStateProperty.all(BorderSide(color: color.withOpacity(0.6), width: 1.5)),
      ),
    );
  }

  Color _getStatusColor() {
    switch (match.status.toLowerCase()) {
      case 'completed': return AppColors.successColor;
      case 'no show': return AppColors.errorColor;
      case 'scheduled': return AppColors.accentBlueColor;
      default: return AppColors.greyColor;
    }
  }

  IconData _getStatusIcon() {
    switch (match.status.toLowerCase()) {
      case 'completed': return Icons.check_circle;
      case 'no show': return Icons.cancel;
      case 'scheduled': return Icons.schedule;
      default: return Icons.pending;
    }
  }
}