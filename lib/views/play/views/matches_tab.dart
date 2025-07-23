import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:intl/intl.dart';
import '../../../style/colors.dart';
import '../../../style/fonts_sizes.dart';
import '../../../style/texts.dart';
import '../models/my_matches_model.dart';
import '../providers/matches_provider.dart';

class MatchesTab extends StatefulWidget {
  const MatchesTab({super.key});

  @override
  State<MatchesTab> createState() => _MatchesTabState();
}

class _MatchesTabState extends State<MatchesTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MatchesProvider>().fetchMatches();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.primaryGradient,
        ),
      ),
      child: Consumer<MatchesProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              SizedBox(height: screenHeight * 0.02),

              // Header with title and refresh button
              Container(
                margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: AppColors.glassColor,
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  border: Border.all(
                    color: AppColors.glassBorderColor,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      'My Matches',
                      style: AppTexts.bodyTextStyle(
                        context: context,
                        textColor: AppColors.textPrimaryColor,
                        fontSize: AppFontSizes(context).size20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (provider.hasLoadedOnce)
                      GestureDetector(
                        onTap: () => provider.refreshMatches(),
                        child: Container(
                          padding: EdgeInsets.all(screenWidth * 0.02),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(
                              screenWidth * 0.02,
                            ),
                            border: Border.all(
                              color: AppColors.primaryColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.refresh,
                            color: AppColors.primaryColor,
                            size: screenWidth * 0.05,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

              // Sub tabs
              Container(
                margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                child: Row(
                  children: [
                    _buildSubTabButton(
                      context: context,
                      title: 'Completed',
                      count: provider.completedMatches.length,
                      isSelected: provider.selectedTabIndex == 0,
                      onTap: () => provider.setSelectedTab(0),
                    ),
                    SizedBox(width: screenWidth * 0.04),
                    _buildSubTabButton(
                      context: context,
                      title: 'Pending',
                      count: provider.pendingMatches.length,
                      isSelected: provider.selectedTabIndex == 1,
                      onTap: () => provider.setSelectedTab(1),
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

              // Content
              Expanded(
                child: Skeletonizer(
                  enabled: provider.isLoading,
                  child: _buildContent(context, provider),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, MatchesProvider provider) {
    if (provider.error.isNotEmpty) {
      return _buildErrorState(context, provider);
    }

    final matches =
    provider.selectedTabIndex == 0
        ? provider.completedMatches
        : provider.pendingMatches;

    if (matches.isEmpty && provider.hasLoadedOnce) {
      return _buildEmptyState(context);
    }

    if (provider.isLoading) {
      return _buildSkeletonList(context);
    }

    return _buildMatchesList(context, matches);
  }

  Widget _buildSkeletonList(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.04,
      ),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.02,
          ),
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
          decoration: BoxDecoration(
            color: AppColors.glassColor,
            borderRadius: BorderRadius.circular(
              MediaQuery.of(context).size.width * 0.03,
            ),
            border: Border.all(
              color: AppColors.glassBorderColor,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.textTertiaryColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Container(
                width: MediaQuery.of(context).size.width * 0.3,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.textTertiaryColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMatchesList(BuildContext context, List<MyMatchesModel> matches) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.04,
      ),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        return _buildMatchCard(context, match);
      },
    );
  }

  Widget _buildMatchCard(BuildContext context, MyMatchesModel match) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isCompleted = match.winnerTeamId != null;

    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: AppColors.glassColor,
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        border: Border.all(
          color: AppColors.glassBorderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tournament info
          Row(
            children: [
              Expanded(
                child: Text(
                  match.tournament.title,
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.textPrimaryColor,
                    fontSize: AppFontSizes(context).size16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.03,
                  vertical: screenHeight * 0.005,
                ),
                decoration: BoxDecoration(
                  color:
                  isCompleted
                      ? AppColors.successColor
                      : AppColors.warningColor,
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                ),
                child: Text(
                  match.status,
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.textPrimaryColor,
                    fontSize: AppFontSizes(context).size12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: screenHeight * 0.01),

          // Round info
          Text(
            '${match.roundName} - Match ${match.matchNumber}',
            style: AppTexts.bodyTextStyle(
              context: context,
              textColor: AppColors.textSecondaryColor,
              fontSize: AppFontSizes(context).size14,
            ),
          ),

          SizedBox(height: screenHeight * 0.015),

          // Teams
          Row(
            children: [
              Expanded(
                child: _buildTeamInfo(
                  context: context,
                  team: match.team1,
                  isWinner: match.winnerTeamId == match.team1Id,
                  score: match.team1Score,
                  noShow: match.team1NoShow,
                ),
              ),

              Container(
                margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                padding: EdgeInsets.all(screenWidth * 0.02),
                decoration: BoxDecoration(
                  color: AppColors.glassLightColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.glassBorderColor,
                    width: 1,
                  ),
                ),
                child: Text(
                  'VS',
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.textSecondaryColor,
                    fontSize: AppFontSizes(context).size12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Expanded(
                child: _buildTeamInfo(
                  context: context,
                  team: match.team2,
                  isWinner: match.winnerTeamId == match.team2Id,
                  score: match.team2Score,
                  noShow: match.team2NoShow,
                ),
              ),
            ],
          ),

          if (match.matchDate != null) ...[
            SizedBox(height: screenHeight * 0.015),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: screenWidth * 0.04,
                  color: AppColors.textSecondaryColor,
                ),
                SizedBox(width: screenWidth * 0.02),
                Text(
                  DateFormat('MMM dd, yyyy • hh:mm a').format(match.matchDate!),
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.textSecondaryColor,
                    fontSize: AppFontSizes(context).size12,
                  ),
                ),
              ],
            ),
          ],

          SizedBox(height: screenHeight * 0.01),

          // Location
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: screenWidth * 0.04,
                color: AppColors.textSecondaryColor,
              ),
              SizedBox(width: screenWidth * 0.02),
              Text(
                match.tournament.location,
                style: AppTexts.bodyTextStyle(
                  context: context,
                  textColor: AppColors.textSecondaryColor,
                  fontSize: AppFontSizes(context).size12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamInfo({
    required BuildContext context,
    required Team team,
    required bool isWinner,
    String? score,
    required bool noShow,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(
        color:
        isWinner
            ? AppColors.successColor.withOpacity(0.2)
            : AppColors.glassLightColor,
        borderRadius: BorderRadius.circular(screenWidth * 0.02),
        border: Border.all(
          color: isWinner
              ? AppColors.successColor.withOpacity(0.5)
              : AppColors.glassBorderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isWinner)
                Container(
                  margin: EdgeInsets.only(right: screenWidth * 0.02),
                  child: Icon(
                    Icons.emoji_events,
                    size: screenWidth * 0.04,
                    color: AppColors.goldColor,
                  ),
                ),
              Expanded(
                child: Text(
                  team.name,
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.textPrimaryColor,
                    fontSize: AppFontSizes(context).size14,
                    fontWeight: isWinner ? FontWeight.w600 : FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (score != null || noShow) ...[
            SizedBox(height: screenHeight * 0.005),
            Text(
              noShow ? 'No Show' : score!,
              style: AppTexts.bodyTextStyle(
                context: context,
                textColor: noShow ? AppColors.errorColor : AppColors.textSecondaryColor,
                fontSize: AppFontSizes(context).size12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Center(
      child: Container(
        margin: EdgeInsets.all(screenWidth * 0.08),
        padding: EdgeInsets.all(screenWidth * 0.08),
        decoration: BoxDecoration(
          color: AppColors.glassColor,
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
          border: Border.all(
            color: AppColors.glassBorderColor,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                color: AppColors.glassLightColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.glassBorderColor,
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.sports_outlined,
                size: screenWidth * 0.15,
                color: AppColors.textSecondaryColor,
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Text(
              "No Matches Found",
              style: AppTexts.bodyTextStyle(
                context: context,
                textColor: AppColors.textPrimaryColor,
                fontSize: AppFontSizes(context).size18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: screenHeight * 0.015),
            Text(
              "You haven't participated in any matches yet",
              style: AppTexts.bodyTextStyle(
                context: context,
                textColor: AppColors.textSecondaryColor,
                fontSize: AppFontSizes(context).size14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, MatchesProvider provider) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Center(
      child: Container(
        margin: EdgeInsets.all(screenWidth * 0.08),
        padding: EdgeInsets.all(screenWidth * 0.08),
        decoration: BoxDecoration(
          color: AppColors.glassColor,
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
          border: Border.all(
            color: AppColors.glassBorderColor,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                color: AppColors.errorColor.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.errorColor.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.error_outline,
                size: screenWidth * 0.15,
                color: AppColors.errorColor,
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Text(
              "Something went wrong",
              style: AppTexts.bodyTextStyle(
                context: context,
                textColor: AppColors.textPrimaryColor,
                fontSize: AppFontSizes(context).size18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: screenHeight * 0.015),
            Text(
              provider.error,
              style: AppTexts.bodyTextStyle(
                context: context,
                textColor: AppColors.textSecondaryColor,
                fontSize: AppFontSizes(context).size14,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenHeight * 0.03),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryColor, AppColors.primaryLightColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(screenWidth * 0.02),
                border: Border.all(
                  color: AppColors.glassBorderColor,
                  width: 1,
                ),
              ),
              child: ElevatedButton(
                onPressed: () => provider.refreshMatches(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.08,
                    vertical: screenHeight * 0.015,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                  ),
                ),
                child: Text(
                  'Try Again',
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.textPrimaryColor,
                    fontSize: AppFontSizes(context).size14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubTabButton({
    required BuildContext context,
    required String title,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.01,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : AppColors.glassColor,
          borderRadius: BorderRadius.circular(screenWidth * 0.06),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor.withOpacity(0.5)
                : AppColors.glassBorderColor,
            width: 1,
          ),
          gradient: isSelected
              ? LinearGradient(
            colors: [AppColors.primaryColor, AppColors.primaryLightColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: AppTexts.bodyTextStyle(
                context: context,
                textColor: AppColors.textPrimaryColor,
                fontSize: AppFontSizes(context).size14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (count > 0) ...[
              SizedBox(width: screenWidth * 0.02),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.015,
                  vertical: screenHeight * 0.002,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.textPrimaryColor.withOpacity(0.2)
                      : AppColors.glassLightColor,
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  border: Border.all(
                    color: AppColors.glassBorderColor,
                    width: 0.5,
                  ),
                ),
                child: Text(
                  count.toString(),
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.textPrimaryColor,
                    fontSize: AppFontSizes(context).size12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}