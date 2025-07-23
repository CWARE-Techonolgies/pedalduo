import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../global/apis.dart';
import '../../../style/colors.dart';
import '../../../style/fonts_sizes.dart';
import '../../../style/texts.dart';
import '../models/team_model.dart';
import '../providers/team_provider.dart';
import '../providers/tournament_provider.dart';
import '../widgets/team_card_widget.dart';

class TeamsTab extends StatefulWidget {
  const TeamsTab({super.key});

  @override
  State<TeamsTab> createState() => _TeamsTabState();
}

class _TeamsTabState extends State<TeamsTab>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Fetch teams when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeamProvider>().fetchTeams();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildGlassContainer({
    required Widget child,
    double? width,
    double? height,
    EdgeInsets? margin,
    EdgeInsets? padding,
    double borderRadius = 16,
    double blur = 10,
    double opacity = 0.15,
  }) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: AppColors.whiteColor.withOpacity(opacity),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: AppColors.whiteColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1a1a2e),
            Color(0xFF16213e),
            Color(0xFF0f3460),
          ],
        ),
      ),
      child: Consumer<TeamProvider>(
        builder: (context, teamProvider, child) {
          if (teamProvider.isLoading) {
            return _buildLoadingState(screenWidth, screenHeight);
          }

          if (teamProvider.error != null) {
            return _buildErrorState(
              context,
              teamProvider.error!,
              screenWidth,
              screenHeight,
            );
          }

          if (!teamProvider.hasTeams) {
            return _buildEmptyState(context, screenWidth, screenHeight);
          }

          return _buildTeamsContent(
            context,
            teamProvider,
            screenWidth,
            screenHeight,
          );
        },
      ),
    );
  }

  Widget _buildLoadingState(double screenWidth, double screenHeight) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          children: [
            // Loading header with glassmorphism
            _buildGlassContainer(
              height: screenHeight * 0.06,
              borderRadius: screenWidth * 0.03,
              child: Container(),
            ),
            SizedBox(height: screenHeight * 0.02),

            // Loading cards
            Expanded(
              child: ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) => Container(
                  margin: EdgeInsets.only(bottom: screenHeight * 0.015),
                  child: _buildGlassContainer(
                    height: screenHeight * 0.12,
                    borderRadius: 16,
                    child: Row(
                      children: [
                        Container(
                          width: screenWidth * 0.15,
                          height: screenWidth * 0.15,
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.04),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: 16,
                                width: screenWidth * 0.4,
                                decoration: BoxDecoration(
                                  color: AppColors.whiteColor.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              Container(
                                height: 12,
                                width: screenWidth * 0.25,
                                decoration: BoxDecoration(
                                  color: AppColors.whiteColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ],
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
      ),
    );
  }

  Widget _buildErrorState(
      BuildContext context,
      String error,
      double screenWidth,
      double screenHeight,
      ) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.06),
          child: _buildGlassContainer(
            padding: EdgeInsets.all(screenWidth * 0.06),
            borderRadius: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: screenWidth * 0.2,
                  height: screenWidth * 0.2,
                  decoration: BoxDecoration(
                    color: AppColors.redColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: screenWidth * 0.1,
                    color: AppColors.redColor,
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                Text(
                  "Something went wrong",
                  style: AppTexts.emphasizedTextStyle(
                    context: context,
                    textColor: AppColors.whiteColor,
                    fontSize: AppFontSizes(context).size18,
                  ),
                ),
                SizedBox(height: screenHeight * 0.015),
                Text(
                  error.replaceAll('Exception: ', ''),
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.whiteColor.withOpacity(0.7),
                    fontSize: AppFontSizes(context).size14,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.04),
                GestureDetector(
                  onTap: () {
                    context.read<TeamProvider>().fetchTeams();
                  },
                  child: _buildGlassContainer(
                    width: screenWidth * 0.5,
                    height: screenHeight * 0.06,
                    borderRadius: screenWidth * 0.08,
                    opacity: 0.3,
                    child: Center(
                      child: Text(
                        'Try Again',
                        style: AppTexts.bodyTextStyle(
                          context: context,
                          textColor: AppColors.whiteColor,
                          fontSize: AppFontSizes(context).size16,
                          fontWeight: FontWeight.w600,
                        ),
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

  Widget _buildEmptyState(
      BuildContext context,
      double screenWidth,
      double screenHeight,
      ) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.06),
          child: _buildGlassContainer(
            padding: EdgeInsets.all(screenWidth * 0.06),
            borderRadius: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: screenWidth * 0.3,
                  height: screenWidth * 0.3,
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.groups_outlined,
                    size: screenWidth * 0.15,
                    color: AppColors.whiteColor.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                Text(
                  "No Teams Found",
                  style: AppTexts.emphasizedTextStyle(
                    context: context,
                    textColor: AppColors.whiteColor,
                    fontSize: AppFontSizes(context).size20,
                  ),
                ),
                SizedBox(height: screenHeight * 0.015),
                Text(
                  "You're not part of any teams yet. Join or create a team to get started!",
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.whiteColor.withOpacity(0.7),
                    fontSize: AppFontSizes(context).size14,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.04),
                Consumer<TournamentProvider>(
                  builder: (BuildContext context, TournamentProvider tournamentProvider, Widget? child) {
                    return GestureDetector(
                      onTap: () {
                        tournamentProvider.selectedTabIndex = 0;
                      },
                      child: _buildGlassContainer(
                        width: screenWidth * 0.65,
                        height: screenHeight * 0.06,
                        borderRadius: screenWidth * 0.08,
                        opacity: 0.3,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.explore_outlined,
                                color: AppColors.whiteColor,
                                size: screenWidth * 0.05,
                              ),
                              SizedBox(width: screenWidth * 0.02),
                              Text(
                                'Browse Tournaments',
                                style: AppTexts.bodyTextStyle(
                                  context: context,
                                  textColor: AppColors.whiteColor,
                                  fontSize: AppFontSizes(context).size16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: screenHeight * 0.02),
                GestureDetector(
                  onTap: () {
                    context.read<TeamProvider>().fetchTeams();
                  },
                  child: _buildGlassContainer(
                    width: screenWidth * 0.65,
                    height: screenHeight * 0.06,
                    borderRadius: screenWidth * 0.08,
                    opacity: 0.1,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.refresh_outlined,
                            color: AppColors.whiteColor.withOpacity(0.8),
                            size: screenWidth * 0.05,
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          Text(
                            'Refresh',
                            style: AppTexts.bodyTextStyle(
                              context: context,
                              textColor: AppColors.whiteColor.withOpacity(0.8),
                              fontSize: AppFontSizes(context).size16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
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

  Widget _buildTeamsContent(
      BuildContext context,
      TeamProvider teamProvider,
      double screenWidth,
      double screenHeight,
      ) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // Tab Header with glassmorphism
          Container(
            margin: EdgeInsets.all(screenWidth * 0.04),
            child: _buildGlassContainer(
              borderRadius: screenWidth * 0.03,
              opacity: 0.2,
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.whiteColor,
                unselectedLabelColor: AppColors.whiteColor.withOpacity(0.6),
                labelStyle: AppTexts.bodyTextStyle(
                  context: context,
                  textColor: AppColors.whiteColor,
                  fontSize: AppFontSizes(context).size14,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: AppTexts.bodyTextStyle(
                  context: context,
                  textColor: AppColors.whiteColor.withOpacity(0.6),
                  fontSize: AppFontSizes(context).size14,
                  fontWeight: FontWeight.w500,
                ),
                indicator: BoxDecoration(
                  color: AppColors.whiteColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star_outline, size: screenWidth * 0.04),
                        SizedBox(width: screenWidth * 0.01),
                        Text('Captain (${teamProvider.captainTeams.length})'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.group_outlined, size: screenWidth * 0.04),
                        SizedBox(width: screenWidth * 0.01),
                        Text('Player (${teamProvider.playerTeams.length})'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Captain Teams
                _buildTeamsList(
                  context,
                  teamProvider.captainTeams,
                  true,
                  screenWidth,
                  screenHeight,
                ),
                // Player Teams
                _buildTeamsList(
                  context,
                  teamProvider.playerTeams,
                  false,
                  screenWidth,
                  screenHeight,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamsList(
      BuildContext context,
      List<TeamModel> teams,
      bool isCaptain,
      double screenWidth,
      double screenHeight,
      ) {
    if (teams.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.06),
          child: _buildGlassContainer(
            padding: EdgeInsets.all(screenWidth * 0.06),
            borderRadius: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: screenWidth * 0.2,
                  height: screenWidth * 0.2,
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCaptain ? Icons.star_outline : Icons.group_outlined,
                    size: screenWidth * 0.1,
                    color: AppColors.whiteColor.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                Text(
                  isCaptain ? "No Captain Teams" : "No Player Teams",
                  style: AppTexts.emphasizedTextStyle(
                    context: context,
                    textColor: AppColors.whiteColor,
                    fontSize: AppFontSizes(context).size18,
                  ),
                ),
                SizedBox(height: screenHeight * 0.015),
                Text(
                  isCaptain
                      ? "You haven't created any teams yet. Create your first team!"
                      : "You haven't joined any teams yet. Join a team to start playing!",
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.whiteColor.withOpacity(0.7),
                    fontSize: AppFontSizes(context).size14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<TeamProvider>().fetchTeams();
      },
      color: AppColors.whiteColor,
      backgroundColor: AppColors.navyBlueGrey,
      child: ListView.builder(
        padding: EdgeInsets.all(screenWidth * 0.04),
        itemCount: teams.length,
        itemBuilder: (context, index) {
          final team = teams[index];
          return TeamCardWidget(
            team: team,
            isCaptain: isCaptain,
            onTap: () {},
            baseUrl: AppApis.baseUrl,
          );
        },
      ),
    );
  }
}