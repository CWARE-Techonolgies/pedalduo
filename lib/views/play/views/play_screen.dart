import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pedalduo/views/play/providers/tournament_provider.dart';
import 'package:pedalduo/views/play/views/tournaments_tab.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../../style/colors.dart';
import '../../../style/fonts_sizes.dart';
import '../../../style/texts.dart';
import 'create_tournament_screen.dart';
import 'matches_tab.dart';

class PlayScreen extends StatelessWidget {
  final int initialTabIndex;
  const PlayScreen({super.key, required this.initialTabIndex});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TournamentProvider>().setSelectedTab(initialTabIndex);
    });
    return Scaffold(
      backgroundColor: AppColors.navyBlueGrey,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.lightNavyBlueGrey.withOpacity(0.8),
                    AppColors.navyBlueGrey.withOpacity(0.6),
                  ],
                ),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.lightGreenColor.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
        leading: Padding(
          padding: EdgeInsets.only(left: screenWidth * 0.04),
          child: Container(
            margin: EdgeInsets.symmetric(vertical: screenHeight * 0.008),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(screenWidth * 0.025),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.lightNavyBlueGrey.withOpacity(0.7),
                  AppColors.navyBlueGrey.withOpacity(0.5),
                ],
              ),
              border: Border.all(
                color: AppColors.lightOrangeColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(screenWidth * 0.025),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: AppColors.whiteColor,
                    size: screenWidth * 0.05,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
        ),
        title: Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenHeight * 0.01,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(screenWidth * 0.06),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.lightOrangeColor.withOpacity(0.2),
                AppColors.orangeColor.withOpacity(0.1),
              ],
            ),
            border: Border.all(
              color: AppColors.lightOrangeColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(screenWidth * 0.06),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Text(
                'PLAY',
                style: AppTexts.headingStyle(
                  context: context,
                  textColor: AppColors.whiteColor,
                  fontSize: AppFontSizes(context).size24,
                ).copyWith(fontWeight: FontWeight.w700, letterSpacing: 2),
              ),
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: screenWidth * 0.02),
            child: Row(
              children: [
                _buildGlassmorphicActionButton(
                  context: context,
                  icon: Icons.add_rounded,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.lightOrangeColor.withOpacity(0.8),
                      AppColors.orangeColor.withOpacity(0.6),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => CreateTournamentScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.navyBlueGrey,
              AppColors.lightNavyBlueGrey,
              AppColors.navyBlueGrey,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).padding.top + kToolbarHeight,
            ),
            Consumer<TournamentProvider>(
              builder: (context, provider, child) {
                return Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenHeight * 0.01,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(screenWidth * 0.05),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.lightNavyBlueGrey.withOpacity(0.6),
                        AppColors.navyBlueGrey.withOpacity(0.4),
                      ],
                    ),
                    border: Border.all(
                      color: AppColors.lightOrangeColor.withOpacity(0.1),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.lightOrangeColor.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(screenWidth * 0.05),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildEnhancedTabButton(
                              context: context,
                              title: 'Tournaments',
                              icon: Icons.emoji_events_rounded,
                              isSelected: provider.selectedTabIndex == 0,
                              onTap: () => provider.setSelectedTab(0),
                            ),
                          ),

                          Expanded(
                            child: _buildEnhancedTabButton(
                              context: context,
                              title: 'Matches',
                              icon: Icons.sports_soccer_rounded,
                              isSelected: provider.selectedTabIndex == 1,
                              onTap: () => provider.setSelectedTab(1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Enhanced Content Area
            Expanded(
              child: Container(
                margin: EdgeInsets.fromLTRB(
                  screenWidth * 0.04,
                  screenHeight * 0.02,
                  screenWidth * 0.04,
                  screenHeight * 0.02,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(screenWidth * 0.05),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.lightNavyBlueGrey.withOpacity(0.3),
                      AppColors.navyBlueGrey.withOpacity(0.2),
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.lightOrangeColor.withOpacity(0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.lightOrangeColor.withOpacity(0.05),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(screenWidth * 0.05),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Consumer<TournamentProvider>(
                      builder: (context, provider, child) {
                        switch (provider.selectedTabIndex) {
                          case 0:
                            return const TournamentsTab();
                          case 1:
                            return const MatchesTab();
                          default:
                            return const TournamentsTab();
                        }
                      },
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

  Widget _buildGlassmorphicActionButton({
    required BuildContext context,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: screenWidth * 0.11,
        height: screenWidth * 0.11,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
          gradient: gradient,
          border: Border.all(
            color: AppColors.whiteColor.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.lightOrangeColor.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Icon(
              icon,
              color: AppColors.whiteColor,
              size: screenWidth * 0.055,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedTabButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.005),
        padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.015,
          horizontal: screenWidth * 0.02,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
          gradient:
              isSelected
                  ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.lightOrangeColor.withOpacity(0.8),
                      AppColors.orangeColor.withOpacity(0.6),
                    ],
                  )
                  : null,
          border: Border.all(
            color:
                isSelected
                    ? AppColors.lightOrangeColor.withOpacity(0.3)
                    : Colors.transparent,
            width: 1,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: AppColors.lightOrangeColor.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ]
                  : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color:
                      isSelected
                          ? AppColors.whiteColor
                          : AppColors.greyColor.withOpacity(0.8),
                  size: screenWidth * 0.045,
                ),
                SizedBox(height: screenHeight * 0.005),
                Text(
                  title,
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor:
                        isSelected
                            ? AppColors.whiteColor
                            : AppColors.greyColor.withOpacity(0.8),
                    fontSize: AppFontSizes(context).size12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
