// Tournaments Tab Widget - Dark Glassmorphism Design
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pedalduo/views/play/providers/tournament_provider.dart';
import 'package:pedalduo/views/play/models/tournaments_model.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import '../../../enums/tournament_statuses.dart';
import '../../../global/images.dart';
import '../../../payments/easy_paisa_payment_provider.dart';
import '../../../payments/easypaisa_payment_dialogue.dart';
import '../../../style/colors.dart';
import '../../../style/fonts_sizes.dart';
import '../../../style/texts.dart';
import '../models/my_tournament_models.dart';
import '../providers/brackets_provider.dart';
import '../widgets/build_date_time_item.dart';
import '../widgets/build_detail_row.dart';
import '../widgets/build_info_item.dart';
import '../widgets/build_skeleton_loader.dart';
import '../widgets/error_state.dart';
import '../widgets/register_team_dialogue.dart';
import '../widgets/sub_tab_button.dart';
import 'create_tournament_screen.dart';

class TournamentsTab extends StatefulWidget {
  const TournamentsTab({super.key});

  @override
  State<TournamentsTab> createState() => _TournamentsTabState();
}

class _TournamentsTabState extends State<TournamentsTab> {
  bool _initialLoadComplete = false;

  @override
  void initState() {
    super.initState();
    // Load tournaments only once when widget is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<TournamentProvider>(context, listen: false);
      _loadInitialTournaments(provider);
    });
  }

  void _loadInitialTournaments(TournamentProvider provider) {
    // Load tournaments based on current tab, but only if not already loaded
    if (provider.selectedSubTabIndex == 0) {
      if (!provider.myTournamentsLoaded) {
        provider.fetchMyTournaments();
      }
    } else {
      if (!provider.allTournamentsLoaded) {
        provider.fetchAllTournaments();
      }
    }
  }

  void _loadTournaments(TournamentProvider provider) {
    // Force refresh tournaments
    if (provider.selectedSubTabIndex == 0) {
      provider.fetchMyTournaments(forceRefresh: true);
    } else {
      provider.fetchAllTournaments(forceRefresh: true);
    }
  }

  void _loadTournamentsIfNeeded(TournamentProvider provider) {
    // Only load if we haven't loaded before or if the cache is invalid
    if (provider.selectedSubTabIndex == 0) {
      if (provider.myTournaments.isEmpty || !_initialLoadComplete) {
        provider.fetchMyTournaments();
        _initialLoadComplete = true;
      }
    } else {
      if (provider.allTournaments.isEmpty || !_initialLoadComplete) {
        provider.fetchAllTournaments();
        _initialLoadComplete = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.navyBlueGrey.withOpacity(0.9),
            AppColors.lightNavyBlueGrey.withOpacity(0.8),
            AppColors.navyBlueGrey.withOpacity(0.9),
          ],
        ),
      ),
      child: Consumer<TournamentProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              SizedBox(height: screenHeight * 0.02),

              // Sub tabs with glassmorphism
              Container(
                margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                padding: EdgeInsets.all(screenWidth * 0.01),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(screenWidth * 0.06),
                  border: Border.all(
                    color: AppColors.whiteColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(screenWidth * 0.06),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Row(
                      children: [
                        _buildGlassmorphismTab(
                          context,
                          'My Tournaments',
                          provider.selectedSubTabIndex == 0,
                          () {
                            provider.setSelectedSubTab(0);
                            _loadTournamentsIfNeeded(provider);
                          },
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        _buildGlassmorphismTab(
                          context,
                          'All Tournaments',
                          provider.selectedSubTabIndex == 1,
                          () {
                            provider.setSelectedSubTab(1);
                            _loadTournamentsIfNeeded(provider);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.03),

              // Content based on selected tab
              Expanded(child: _buildTabContent(context, provider)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGlassmorphismTab(
    BuildContext context,
    String title,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: screenHeight * 0.05,
          decoration: BoxDecoration(
            gradient:
                isSelected
                    ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.orangeColor.withOpacity(0.8),
                        AppColors.lightOrangeColor.withOpacity(0.6),
                      ],
                    )
                    : null,
            color: isSelected ? null : AppColors.whiteColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(screenWidth * 0.05),
            border: Border.all(
              color:
                  isSelected
                      ? AppColors.orangeColor.withOpacity(0.5)
                      : AppColors.whiteColor.withOpacity(0.2),
              width: 1,
            ),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: AppColors.orangeColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                    : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(screenWidth * 0.05),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Center(
                child: Text(
                  title,
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor:
                        isSelected
                            ? AppColors.whiteColor
                            : AppColors.whiteColor.withOpacity(0.8),
                    fontSize: AppFontSizes(context).size14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, TournamentProvider provider) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMyTournaments = provider.selectedSubTabIndex == 0;

    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
        padding: EdgeInsets.all(screenWidth * 0.08),
        decoration: BoxDecoration(
          color: AppColors.whiteColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(screenWidth * 0.08),
          border: Border.all(
            color: AppColors.whiteColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(screenWidth * 0.08),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.06),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.purpleColor.withOpacity(0.3),
                        AppColors.blueColor.withOpacity(0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(screenWidth * 0.1),
                    border: Border.all(
                      color: AppColors.whiteColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.emoji_events_outlined,
                    size: screenWidth * 0.15,
                    color: AppColors.whiteColor.withOpacity(0.8),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                Text(
                  isMyTournaments
                      ? "You haven't created any tournaments yet"
                      : "No tournaments available",
                  style: AppTexts.emphasizedTextStyle(
                    context: context,
                    textColor: AppColors.whiteColor,
                    fontSize: AppFontSizes(context).size18,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.015),
                Text(
                  isMyTournaments
                      ? "Create your first tournament and invite players"
                      : "Check back later for new tournaments",
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.whiteColor.withOpacity(0.7),
                    fontSize: AppFontSizes(context).size14,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.04),

                // Create Tournament Button (only show for My Tournaments tab)
                if (isMyTournaments)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (_) => CreateTournamentScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: screenWidth * 0.6,
                      height: screenHeight * 0.06,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.orangeColor.withOpacity(0.8),
                            AppColors.lightOrangeColor.withOpacity(0.6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(screenWidth * 0.08),
                        border: Border.all(
                          color: AppColors.orangeColor.withOpacity(0.5),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.orangeColor.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(screenWidth * 0.08),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Center(
                            child: Text(
                              'Create Tournament',
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
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(double screenWidth, double screenHeight) {
    return Container(
      height: screenHeight * 0.2,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.purpleColor.withOpacity(0.4),
            AppColors.blueColor.withOpacity(0.4),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: screenWidth * 0.15,
          color: AppColors.whiteColor.withOpacity(0.6),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    final screenWidth = MediaQuery.of(context).size.width;

    Color chipColor;
    List<Color> gradientColors;
    switch (status.toLowerCase()) {
      case 'approved':
        chipColor = AppColors.followColor;
        gradientColors = [
          AppColors.followColor.withOpacity(0.8),
          AppColors.followColor.withOpacity(0.6),
        ];
        break;
      case 'under review':
        chipColor = AppColors.goldColor;
        gradientColors = [
          AppColors.goldColor.withOpacity(0.8),
          AppColors.goldColor.withOpacity(0.6),
        ];
        break;
      case 'rejected':
        chipColor = AppColors.redColor;
        gradientColors = [
          AppColors.redColor.withOpacity(0.8),
          AppColors.redColor.withOpacity(0.6),
        ];
        break;
      case 'ongoing':
        chipColor = AppColors.blueColor;
        gradientColors = [
          AppColors.blueColor.withOpacity(0.8),
          AppColors.blueColor.withOpacity(0.6),
        ];
        break;
      case 'cancelled':
        chipColor = AppColors.orangeColor;
        gradientColors = [
          AppColors.orangeColor.withOpacity(0.8),
          AppColors.orangeColor.withOpacity(0.6),
        ];
        break;
      default:
        chipColor = AppColors.greyColor;
        gradientColors = [
          AppColors.greyColor.withOpacity(0.8),
          AppColors.greyColor.withOpacity(0.6),
        ];
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.025,
        vertical: screenWidth * 0.012,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        border: Border.all(color: chipColor.withOpacity(0.4), width: 1),
        boxShadow: [
          BoxShadow(
            color: chipColor.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        child: Text(
          status,
          style: AppTexts.bodyTextStyle(
            context: context,
            textColor: AppColors.whiteColor,
            fontSize: AppFontSizes(context).size10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.025,
        vertical: screenWidth * 0.018,
      ),
      decoration: BoxDecoration(
        color: AppColors.whiteColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        border: Border.all(
          color: AppColors.whiteColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: screenWidth * 0.035,
                color: AppColors.whiteColor.withOpacity(0.8),
              ),
              SizedBox(width: screenWidth * 0.01),
              Text(
                label,
                style: AppTexts.bodyTextStyle(
                  context: context,
                  textColor: AppColors.whiteColor.withOpacity(0.8),
                  fontSize: AppFontSizes(context).size10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Uint8List _decodeBase64Image(String base64String) {
    // Remove the data URL prefix if present
    String cleanBase64 = base64String;
    if (base64String.contains(',')) {
      cleanBase64 = base64String.split(',')[1];
    }
    return base64Decode(cleanBase64);
  }

  bool _isRegistrationClosed(DateTime registrationEndDate) {
    return DateTime.now().isAfter(registrationEndDate);
  }

  Widget _buildTabContent(BuildContext context, TournamentProvider provider) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Show loading state with skeletonizer
    if (provider.isLoadingTournaments) {
      return BuildSkeletonLoader();
    }

    // Show error state
    if (provider.errorMessage.isNotEmpty) {
      return ErrorState(
        provider: TournamentProvider(),
        onTap: () {
          _loadTournaments(provider);
        },
      );
    }

    // Handle different tabs
    if (provider.selectedSubTabIndex == 0) {
      // My Tournaments - combine organized and played tournaments
      final myTournaments = [
        ...provider.organizedTournaments,
        ...provider.playedTournaments,
      ];

      // Show empty state
      if (myTournaments.isEmpty) {
        return _buildEmptyState(context, provider);
      }

      // Show my tournaments list
      return RefreshIndicator(
        onRefresh: () async => _loadTournaments(provider),
        color: AppColors.orangeColor,
        backgroundColor: AppColors.whiteColor.withOpacity(0.9),
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          itemCount: myTournaments.length,
          itemBuilder: (context, index) {
            final tournament = myTournaments[index];
            return _buildMyTournamentCard(context, tournament, provider);
          },
        ),
      );
    } else {
      // All Tournaments
      final allTournaments = provider.allTournaments;

      // Show empty state
      if (allTournaments.isEmpty) {
        return _buildEmptyState(context, provider);
      }

      // Show all tournaments list
      return RefreshIndicator(
        onRefresh: () async => _loadTournaments(provider),
        color: AppColors.orangeColor,
        backgroundColor: AppColors.whiteColor.withOpacity(0.9),
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          itemCount: allTournaments.length,
          itemBuilder: (context, index) {
            final tournament = allTournaments[index];
            return _buildTournamentCard(context, tournament, provider);
          },
        ),
      );
    }
  }

  /////the following code need to be deisgned like the above code with dark glass morphism theme
  Widget _buildTournamentCard(
    BuildContext context,
    Tournament tournament,
    TournamentProvider provider,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isRegistrationClosed = _isRegistrationClosed(
      tournament.registrationEndDate,
    );
    final showBracketsButton =
        tournament.registeredTeams >= tournament.totalTeams;

    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
      decoration: BoxDecoration(
        color: AppColors.navyBlueGrey.withOpacity(0.7),
        borderRadius: BorderRadius.circular(screenWidth * 0.06),
        border: Border.all(
          color: AppColors.whiteColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(screenWidth * 0.06),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tournament Image
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(screenWidth * 0.06),
                  topRight: Radius.circular(screenWidth * 0.06),
                ),
                child:
                    (tournament.imageUrl != null &&
                            tournament.imageUrl!.isNotEmpty)
                        ? Image.memory(
                          _decodeBase64Image(tournament.imageUrl!),
                          height: screenHeight * 0.2,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildLetterPlaceholder(
                              screenWidth,
                              screenHeight,
                              tournament.title,
                            );
                          },
                        )
                        : _buildLetterPlaceholder(
                          screenWidth,
                          screenHeight,
                          tournament.title,
                        ),
              ),

              // Tournament Details
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Status
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            tournament.title,
                            style: AppTexts.emphasizedTextStyle(
                              context: context,
                              textColor: AppColors.whiteColor,
                              fontSize: AppFontSizes(context).size18,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildStatusChip(context, tournament.status),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.01),

                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: screenWidth * 0.04,
                          color: AppColors.whiteColor.withOpacity(0.7),
                        ),
                        SizedBox(width: screenWidth * 0.01),
                        Text(
                          tournament.location,
                          style: AppTexts.bodyTextStyle(
                            context: context,
                            textColor: AppColors.whiteColor.withOpacity(0.7),
                            fontSize: AppFontSizes(context).size14,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.01),

                    // Organizer
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: screenWidth * 0.04,
                          color: AppColors.whiteColor.withOpacity(0.7),
                        ),
                        SizedBox(width: screenWidth * 0.01),
                        Text(
                          'By ${tournament.organizer.name}',
                          style: AppTexts.bodyTextStyle(
                            context: context,
                            textColor: AppColors.whiteColor.withOpacity(0.7),
                            fontSize: AppFontSizes(context).size14,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.015),

                    // Tournament Info Row
                    Wrap(
                      spacing: screenWidth * 0.02,
                      runSpacing: screenWidth * 0.02,
                      children: [
                        _buildInfoChip(
                          context,
                          Icons.groups_outlined,
                          '${tournament.totalTeams} Teams',
                        ),
                        _buildInfoChip(
                          context,
                          Icons.people_outline,
                          '${tournament.playersPerTeam} Players',
                        ),
                        _buildInfoChip(
                          context,
                          Icons.wc_outlined,
                          tournament.gender.toUpperCase(),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.015),

                    // Dates
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Registration Ends',
                                style: AppTexts.bodyTextStyle(
                                  context: context,
                                  textColor: AppColors.whiteColor.withOpacity(
                                    0.7,
                                  ),
                                  fontSize: AppFontSizes(context).size12,
                                ),
                              ),
                              Text(
                                DateFormat(
                                  'MMM dd, yyyy',
                                ).format(tournament.registrationEndDate),
                                style: AppTexts.bodyTextStyle(
                                  context: context,
                                  textColor: AppColors.whiteColor,
                                  fontSize: AppFontSizes(context).size14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tournament Starts',
                                style: AppTexts.bodyTextStyle(
                                  context: context,
                                  textColor: AppColors.whiteColor.withOpacity(
                                    0.7,
                                  ),
                                  fontSize: AppFontSizes(context).size12,
                                ),
                              ),
                              Text(
                                DateFormat(
                                  'MMM dd, yyyy',
                                ).format(tournament.tournamentStartDate),
                                style: AppTexts.bodyTextStyle(
                                  context: context,
                                  textColor: AppColors.whiteColor,
                                  fontSize: AppFontSizes(context).size14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.015),

                    // Player Fee and Registered Teams
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Entry Fee',
                              style: AppTexts.bodyTextStyle(
                                context: context,
                                textColor: AppColors.whiteColor.withOpacity(
                                  0.7,
                                ),
                                fontSize: AppFontSizes(context).size12,
                              ),
                            ),
                            Text(
                              'PKR ${tournament.playerFee}',
                              style: AppTexts.emphasizedTextStyle(
                                context: context,
                                textColor: AppColors.orangeColor,
                                fontSize: AppFontSizes(context).size16,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Registered',
                              style: AppTexts.bodyTextStyle(
                                context: context,
                                textColor: AppColors.whiteColor.withOpacity(
                                  0.7,
                                ),
                                fontSize: AppFontSizes(context).size12,
                              ),
                            ),
                            Text(
                              '${tournament.registeredTeams}/${tournament.totalTeams}',
                              style: AppTexts.emphasizedTextStyle(
                                context: context,
                                textColor: AppColors.whiteColor,
                                fontSize: AppFontSizes(context).size16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    // Action Buttons
                    Visibility(
                      visible:
                          tournament.status ==
                              TournamentStatus.ongoing.displayName ||
                          tournament.status ==
                              TournamentStatus.completed.displayName,
                      child: Consumer<Brackets>(
                        builder: (
                          BuildContext context,
                          Brackets brackets,
                          Widget? child,
                        ) {
                          return GestureDetector(
                            onTap: () {
                              print(
                                'tournament status is ${tournament.status}',
                              );
                              print(
                                'tournament winner is ${tournament.winnerTeamId.toString()}',
                              );
                              brackets.showTournamentBrackets(
                                context,
                                tournament,
                                provider,
                                false,
                                tournament.id.toString(),
                                tournament.title,
                                tournament.winnerTeamId,
                                tournament.status,
                                tournament.tournamentStartDate,
                                tournament.tournamentEndDate,
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              height: screenHeight * 0.05,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.purpleColor.withOpacity(0.8),
                                    AppColors.blueColor.withOpacity(0.6),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(
                                  screenWidth * 0.06,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.purpleColor.withOpacity(
                                      0.3,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  screenWidth * 0.06,
                                ),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 10,
                                    sigmaY: 10,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'View Brackets',
                                      style: AppTexts.bodyTextStyle(
                                        context: context,
                                        textColor: AppColors.whiteColor,
                                        fontSize: AppFontSizes(context).size14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyTournamentCard(
    BuildContext context,
    MyTournament tournament,
    TournamentProvider provider,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isRegistrationClosed = _isRegistrationClosed(
      tournament.registrationEndDate,
    );
    final showBracketsButton =
        tournament.registeredTeams >= tournament.totalTeams;

    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
      decoration: BoxDecoration(
        color: AppColors.navyBlueGrey.withOpacity(0.7),
        borderRadius: BorderRadius.circular(screenWidth * 0.06),
        border: Border.all(
          color: AppColors.whiteColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(screenWidth * 0.06),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tournament Image
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(screenWidth * 0.06),
                  topRight: Radius.circular(screenWidth * 0.06),
                ),
                child:
                    tournament.imageUrl.isNotEmpty
                        ? Image.memory(
                          _decodeBase64Image(tournament.imageUrl),
                          height: screenHeight * 0.2,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderImage(
                              screenWidth,
                              screenHeight,
                            );
                          },
                        )
                        : _buildPlaceholderImage(screenWidth, screenHeight),
              ),

              // Tournament Details
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Status
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            tournament.title,
                            style: AppTexts.emphasizedTextStyle(
                              context: context,
                              textColor: AppColors.whiteColor,
                              fontSize: AppFontSizes(context).size18,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildStatusChip(context, tournament.status),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.01),

                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: screenWidth * 0.04,
                          color: AppColors.whiteColor.withOpacity(0.7),
                        ),
                        SizedBox(width: screenWidth * 0.01),
                        Text(
                          tournament.location,
                          style: AppTexts.bodyTextStyle(
                            context: context,
                            textColor: AppColors.whiteColor.withOpacity(0.7),
                            fontSize: AppFontSizes(context).size14,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.015),

                    // Tournament Info Row
                    Wrap(
                      spacing: screenWidth * 0.02,
                      runSpacing: screenWidth * 0.02,
                      children: [
                        _buildInfoChip(
                          context,
                          Icons.groups_outlined,
                          '${tournament.totalTeams} Teams',
                        ),
                        _buildInfoChip(
                          context,
                          Icons.people_outline,
                          '${tournament.playersPerTeam} Players',
                        ),
                        _buildInfoChip(
                          context,
                          Icons.wc_outlined,
                          tournament.gender.toUpperCase(),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.015),

                    // Dates
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Registration Ends',
                                style: AppTexts.bodyTextStyle(
                                  context: context,
                                  textColor: AppColors.whiteColor.withOpacity(
                                    0.7,
                                  ),
                                  fontSize: AppFontSizes(context).size12,
                                ),
                              ),
                              Text(
                                DateFormat(
                                  'MMM dd, yyyy',
                                ).format(tournament.registrationEndDate),
                                style: AppTexts.bodyTextStyle(
                                  context: context,
                                  textColor: AppColors.whiteColor,
                                  fontSize: AppFontSizes(context).size14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tournament Starts',
                                style: AppTexts.bodyTextStyle(
                                  context: context,
                                  textColor: AppColors.whiteColor.withOpacity(
                                    0.7,
                                  ),
                                  fontSize: AppFontSizes(context).size12,
                                ),
                              ),
                              Text(
                                DateFormat(
                                  'MMM dd, yyyy',
                                ).format(tournament.tournamentStartDate),
                                style: AppTexts.bodyTextStyle(
                                  context: context,
                                  textColor: AppColors.whiteColor,
                                  fontSize: AppFontSizes(context).size14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.015),

                    // Player Fee and Registered Teams
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Entry Fee',
                              style: AppTexts.bodyTextStyle(
                                context: context,
                                textColor: AppColors.whiteColor.withOpacity(
                                  0.7,
                                ),
                                fontSize: AppFontSizes(context).size12,
                              ),
                            ),
                            Text(
                              'PKR ${tournament.playerFee}',
                              style: AppTexts.emphasizedTextStyle(
                                context: context,
                                textColor: AppColors.orangeColor,
                                fontSize: AppFontSizes(context).size16,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Registered',
                              style: AppTexts.bodyTextStyle(
                                context: context,
                                textColor: AppColors.whiteColor.withOpacity(
                                  0.7,
                                ),
                                fontSize: AppFontSizes(context).size12,
                              ),
                            ),
                            Text(
                              '${tournament.registeredTeams}/${tournament.totalTeams}',
                              style: AppTexts.emphasizedTextStyle(
                                context: context,
                                textColor: AppColors.whiteColor,
                                fontSize: AppFontSizes(context).size16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    // Action Buttons
                    showBracketsButton
                        ? Column(
                          children: [
                            // Action Button Row (View Details and Pay Now)
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap:
                                        isRegistrationClosed
                                            ? null
                                            : () => _showTournamentDetails(
                                              context,
                                              tournament,
                                              provider,
                                            ),
                                    child: Container(
                                      width: double.infinity,
                                      height: screenHeight * 0.05,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            isRegistrationClosed
                                                ? AppColors.redColor
                                                    .withOpacity(0.8)
                                                : AppColors.orangeColor
                                                    .withOpacity(0.8),
                                            isRegistrationClosed
                                                ? AppColors.redColor
                                                    .withOpacity(0.6)
                                                : AppColors.lightOrangeColor
                                                    .withOpacity(0.6),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          screenWidth * 0.06,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                isRegistrationClosed
                                                    ? AppColors.redColor
                                                        .withOpacity(0.3)
                                                    : AppColors.orangeColor
                                                        .withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          screenWidth * 0.06,
                                        ),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                            sigmaX: 10,
                                            sigmaY: 10,
                                          ),
                                          child: Center(
                                            child: Text(
                                              isRegistrationClosed
                                                  ? 'Registration Closed'
                                                  : 'View Details',
                                              style: AppTexts.bodyTextStyle(
                                                context: context,
                                                textColor: AppColors.whiteColor,
                                                fontSize:
                                                    AppFontSizes(
                                                      context,
                                                    ).size14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: tournament.paymentStatus == 'Unpaid',
                                  child: SizedBox(width: screenWidth * 0.02),
                                ),
                                Consumer<EasyPaisaPaymentProvider>(
                                  builder: (context, paymentProvider, child) {
                                    return Visibility(
                                      visible:
                                          tournament.paymentStatus == 'Unpaid',
                                      child: Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder:
                                                  (context) =>
                                                      EasyPaisaPaymentDialog(
                                                        amount: double.parse(
                                                          tournament.packageFee,
                                                        ),
                                                        tournamentId:
                                                            tournament.id
                                                                .toString(),
                                                        onPaymentSuccess: () {},
                                                      ),
                                            );
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            height: screenHeight * 0.05,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  AppColors.followColor
                                                      .withOpacity(0.8),
                                                  AppColors.lightGreenColor
                                                      .withOpacity(0.6),
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    screenWidth * 0.06,
                                                  ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppColors
                                                      .lightGreenColor
                                                      .withOpacity(0.3),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    screenWidth * 0.06,
                                                  ),
                                              child: BackdropFilter(
                                                filter: ImageFilter.blur(
                                                  sigmaX: 10,
                                                  sigmaY: 10,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'Pay Now',
                                                    style:
                                                        AppTexts.bodyTextStyle(
                                                          context: context,
                                                          textColor:
                                                              AppColors
                                                                  .whiteColor,
                                                          fontSize:
                                                              AppFontSizes(
                                                                context,
                                                              ).size14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            // Show Brackets Button
                            Visibility(
                              visible:
                                  tournament.status ==
                                  TournamentStatus.approved.displayName,
                              child: Consumer<Brackets>(
                                builder: (
                                  BuildContext context,
                                  Brackets brackets,
                                  Widget? child,
                                ) {
                                  return GestureDetector(
                                    onTap: () {
                                      brackets.isGeneratingBrackets
                                          ? null
                                          : brackets.generateTournamentBrackets(
                                            context,
                                            tournament,
                                            provider,
                                          );
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      height: screenHeight * 0.05,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            brackets.isGeneratingBrackets
                                                ? AppColors.greyColor
                                                    .withOpacity(0.8)
                                                : AppColors.purpleColor
                                                    .withOpacity(0.8),
                                            brackets.isGeneratingBrackets
                                                ? AppColors.greyColor
                                                    .withOpacity(0.6)
                                                : AppColors.blueColor
                                                    .withOpacity(0.6),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          screenWidth * 0.06,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                brackets.isGeneratingBrackets
                                                    ? AppColors.greyColor
                                                        .withOpacity(0.2)
                                                    : AppColors.purpleColor
                                                        .withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          screenWidth * 0.06,
                                        ),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                            sigmaX: 10,
                                            sigmaY: 10,
                                          ),
                                          child: Center(
                                            child:
                                                brackets.isGeneratingBrackets
                                                    ? SizedBox(
                                                      height: 20,
                                                      child: SpinKitThreeBounce(
                                                        color:
                                                            AppColors
                                                                .whiteColor,
                                                        size:
                                                            screenWidth * 0.04,
                                                      ),
                                                    )
                                                    : Text(
                                                      'Generate Brackets',
                                                      style:
                                                          AppTexts.bodyTextStyle(
                                                            context: context,
                                                            textColor:
                                                                AppColors
                                                                    .whiteColor,
                                                            fontSize:
                                                                AppFontSizes(
                                                                  context,
                                                                ).size14,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                    ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Visibility(
                              visible:
                                  tournament.status ==
                                      TournamentStatus.ongoing.displayName ||
                                  tournament.status ==
                                      TournamentStatus.completed.displayName,
                              child: Consumer<Brackets>(
                                builder: (
                                  BuildContext context,
                                  Brackets brackets,
                                  Widget? child,
                                ) {
                                  return GestureDetector(
                                    onTap: () {
                                      brackets.showTournamentBrackets(
                                        context,
                                        tournament,
                                        provider,
                                        true,
                                        tournament.id.toString(),
                                        tournament.title,
                                        tournament.winnerTeamId,
                                        tournament.status,
                                        tournament.tournamentStartDate,
                                        tournament.tournamentEndDate,
                                      );
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      height: screenHeight * 0.05,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            AppColors.purpleColor.withOpacity(
                                              0.8,
                                            ),
                                            AppColors.blueColor.withOpacity(
                                              0.6,
                                            ),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          screenWidth * 0.06,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.purpleColor
                                                .withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          screenWidth * 0.06,
                                        ),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                            sigmaX: 10,
                                            sigmaY: 10,
                                          ),
                                          child: Center(
                                            child: Text(
                                              'View Brackets',
                                              style: AppTexts.bodyTextStyle(
                                                context: context,
                                                textColor: AppColors.whiteColor,
                                                fontSize:
                                                    AppFontSizes(
                                                      context,
                                                    ).size14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        )
                        : Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap:
                                    isRegistrationClosed
                                        ? null
                                        : () => _showTournamentDetails(
                                          context,
                                          tournament,
                                          provider,
                                        ),
                                child: Container(
                                  width: double.infinity,
                                  height: screenHeight * 0.05,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        isRegistrationClosed ||
                                                tournament.status ==
                                                    TournamentStatus
                                                        .cancelled
                                                        .displayName
                                            ? AppColors.redColor.withOpacity(
                                              0.8,
                                            )
                                            : AppColors.orangeColor.withOpacity(
                                              0.8,
                                            ),
                                        isRegistrationClosed ||
                                                tournament.status ==
                                                    TournamentStatus
                                                        .cancelled
                                                        .displayName
                                            ? AppColors.redColor.withOpacity(
                                              0.6,
                                            )
                                            : AppColors.lightOrangeColor
                                                .withOpacity(0.6),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      screenWidth * 0.06,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            isRegistrationClosed ||
                                                    tournament.status ==
                                                        TournamentStatus
                                                            .cancelled
                                                            .displayName
                                                ? AppColors.redColor
                                                    .withOpacity(0.3)
                                                : AppColors.orangeColor
                                                    .withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      screenWidth * 0.06,
                                    ),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 10,
                                        sigmaY: 10,
                                      ),
                                      child: Center(
                                        child: Text(
                                          isRegistrationClosed
                                              ? 'Registration Closed'
                                              : (tournament.status ==
                                                      TournamentStatus
                                                          .cancelled
                                                          .displayName
                                                  ? 'Tournament Cancelled'
                                                  : 'View Details'),
                                          style: AppTexts.bodyTextStyle(
                                            context: context,
                                            textColor: AppColors.whiteColor,
                                            fontSize:
                                                AppFontSizes(context).size14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Visibility(
                              visible: tournament.paymentStatus == 'Unpaid',
                              child: SizedBox(width: screenWidth * 0.02),
                            ),
                            Consumer<EasyPaisaPaymentProvider>(
                              builder: (context, paymentProvider, child) {
                                return Visibility(
                                  visible: tournament.paymentStatus == 'Unpaid',
                                  child: Expanded(
                                    child: GestureDetector(
                                      onTap: () async {
                                        await paymentProvider
                                            .confirmPaymentWithBackend(
                                              tournament.id,
                                              context,
                                            );

                                        // showDialog(
                                        //   context: context,
                                        //   barrierDismissible: false,
                                        //   builder:
                                        //       (context) =>
                                        //           EasyPaisaPaymentDialog(
                                        //             amount: double.parse(
                                        //               tournament.packageFee,
                                        //             ),
                                        //             tournamentId:
                                        //                 tournament.id
                                        //                     .toString(),
                                        //             onPaymentSuccess: () {},
                                        //           ),
                                        // );
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        height: screenHeight * 0.05,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              AppColors.followColor.withOpacity(
                                                0.8,
                                              ),
                                              AppColors.lightGreenColor
                                                  .withOpacity(0.6),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            screenWidth * 0.06,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.lightGreenColor
                                                  .withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            screenWidth * 0.06,
                                          ),
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(
                                              sigmaX: 10,
                                              sigmaY: 10,
                                            ),
                                            child: Center(
                                              child: Text(
                                                'Pay Now',
                                                style: AppTexts.bodyTextStyle(
                                                  context: context,
                                                  textColor:
                                                      AppColors.whiteColor,
                                                  fontSize:
                                                      AppFontSizes(
                                                        context,
                                                      ).size14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLetterPlaceholder(
    double screenWidth,
    double screenHeight,
    String title,
  ) {
    return Container(
      height: screenHeight * 0.2,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.purpleColor.withOpacity(0.4),
            AppColors.blueColor.withOpacity(0.4),
          ],
        ),
      ),
      child: Center(
        child: Text(
          title.isNotEmpty ? title[0].toUpperCase() : '',
          style: TextStyle(
            fontSize: screenHeight * 0.08,
            fontWeight: FontWeight.bold,
            color: AppColors.whiteColor.withOpacity(0.8),
          ),
        ),
      ),
    );
  }

  void _showTournamentDetails(
    BuildContext context,
    dynamic tournament,
    TournamentProvider provider,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isRegistrationClosed = _isRegistrationClosed(
      tournament.registrationEndDate,
    );

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(screenWidth * 0.05),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(screenWidth * 0.06),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                width: screenWidth * 0.9,
                constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
                decoration: BoxDecoration(
                  color: AppColors.navyBlueGrey.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(screenWidth * 0.06),
                  border: Border.all(
                    color: AppColors.whiteColor.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.blackColor.withOpacity(0.3),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with close button
                    Container(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.orangeColor.withOpacity(0.3),
                            AppColors.orangeColor.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(screenWidth * 0.06),
                          topRight: Radius.circular(screenWidth * 0.06),
                        ),
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.whiteColor.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(screenWidth * 0.02),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.orangeColor.withOpacity(0.8),
                                  AppColors.lightOrangeColor.withOpacity(0.6),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(
                                screenWidth * 0.03,
                              ),
                            ),
                            child: Icon(
                              Icons.emoji_events,
                              color: AppColors.whiteColor,
                              size: screenWidth * 0.06,
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          Expanded(
                            child: Text(
                              'Tournament Details',
                              style: AppTexts.emphasizedTextStyle(
                                context: context,
                                textColor: AppColors.whiteColor,
                                fontSize: AppFontSizes(context).size18,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: EdgeInsets.all(screenWidth * 0.02),
                              decoration: BoxDecoration(
                                color: AppColors.whiteColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                  screenWidth * 0.03,
                                ),
                                border: Border.all(
                                  color: AppColors.whiteColor.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.close,
                                color: AppColors.whiteColor.withOpacity(0.8),
                                size: screenWidth * 0.05,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Scrollable content
                    Flexible(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tournament Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                screenWidth * 0.04,
                              ),
                              child:
                                  tournament.imageUrl != null &&
                                          tournament.imageUrl!.isNotEmpty
                                      ? Image.memory(
                                        _decodeBase64Image(
                                          tournament.imageUrl!,
                                        ),
                                        height: screenHeight * 0.2,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return _buildPlaceholderImage(
                                            screenWidth,
                                            screenHeight,
                                          );
                                        },
                                      )
                                      : _buildPlaceholderImage(
                                        screenWidth,
                                        screenHeight,
                                      ),
                            ),

                            SizedBox(height: screenHeight * 0.02),

                            // Tournament Title
                            Text(
                              tournament.title,
                              style: AppTexts.emphasizedTextStyle(
                                context: context,
                                textColor: AppColors.whiteColor,
                                fontSize: AppFontSizes(context).size22,
                              ),
                            ),

                            SizedBox(height: screenHeight * 0.01),

                            // Status Badge
                            Align(
                              alignment: Alignment.centerLeft,
                              child: _buildStatusChip(
                                context,
                                tournament.status,
                              ),
                            ),

                            SizedBox(height: screenHeight * 0.02),

                            // Location and Organizer
                            BuildDetailRow(
                              icon: Icons.location_on_outlined,
                              label: 'Location',
                              value: tournament.location,
                              // iconColor: AppColors.whiteColor.withOpacity(0.7),
                              // textColor: AppColors.whiteColor.withOpacity(0.9),
                            ),
                            SizedBox(height: screenHeight * 0.015),

                            BuildDetailRow(
                              icon: Icons.person_outline,
                              label: 'Organizer',
                              value:
                                  tournament is Tournament
                                      ? tournament.organizer.name
                                      : 'Tournament Organizer',
                            ),

                            SizedBox(height: screenHeight * 0.02),

                            // Tournament Info Grid
                            Container(
                              padding: EdgeInsets.all(screenWidth * 0.04),
                              decoration: BoxDecoration(
                                color: AppColors.whiteColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                  screenWidth * 0.04,
                                ),
                                border: Border.all(
                                  color: AppColors.whiteColor.withOpacity(0.1),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: BuildInfoItem(
                                          icon: Icons.groups_outlined,
                                          label: 'Total Teams',
                                          value: '${tournament.totalTeams}',
                                          // iconColor: AppColors.whiteColor.withOpacity(0.7),
                                          // textColor: AppColors.whiteColor,
                                        ),
                                      ),
                                      Expanded(
                                        child: BuildInfoItem(
                                          icon: Icons.people_outline,
                                          label: 'Players/Team',
                                          value: '${tournament.playersPerTeam}',
                                          // iconColor: AppColors.whiteColor.withOpacity(0.7),
                                          // textColor: AppColors.whiteColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: screenHeight * 0.015),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: BuildInfoItem(
                                          icon: Icons.wc_outlined,
                                          label: 'Category',
                                          value:
                                              tournament.gender.toUpperCase(),
                                          // iconColor: AppColors.whiteColor.withOpacity(0.7),
                                          // textColor: AppColors.whiteColor,
                                        ),
                                      ),
                                      Expanded(
                                        child: BuildInfoItem(
                                          icon: Icons.how_to_reg_outlined,
                                          label: 'Registered',
                                          value:
                                              '${tournament.registeredTeams}/${tournament.totalTeams}',
                                          // iconColor: AppColors.whiteColor.withOpacity(0.7),
                                          // textColor: AppColors.whiteColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: screenHeight * 0.02),

                            // Dates Section
                            Container(
                              padding: EdgeInsets.all(screenWidth * 0.04),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.orangeColor.withOpacity(0.1),
                                    AppColors.orangeColor.withOpacity(0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(
                                  screenWidth * 0.04,
                                ),
                                border: Border.all(
                                  color: AppColors.orangeColor.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  BuildDateTimeItem(
                                    label: 'Registration Ends',
                                    date: DateFormat(
                                      'MMM dd, yyyy',
                                    ).format(tournament.registrationEndDate),
                                    icon: Icons.event_available,
                                    color:
                                        isRegistrationClosed
                                            ? AppColors.redColor
                                            : AppColors.orangeColor,
                                    // textColor: AppColors.whiteColor,
                                  ),
                                  SizedBox(height: screenHeight * 0.01),
                                  BuildDateTimeItem(
                                    label: 'Tournament Starts',
                                    date: DateFormat(
                                      'MMM dd, yyyy',
                                    ).format(tournament.tournamentStartDate),
                                    icon: Icons.sports_cricket,
                                    color: AppColors.orangeColor,
                                    // textColor: AppColors.whiteColor,
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: screenHeight * 0.02),

                            // Entry Fee
                            Container(
                              padding: EdgeInsets.all(screenWidth * 0.04),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.orangeColor.withOpacity(0.1),
                                    AppColors.lightOrangeColor.withOpacity(
                                      0.05,
                                    ),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(
                                  screenWidth * 0.04,
                                ),
                                border: Border.all(
                                  color: AppColors.whiteColor.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(screenWidth * 0.03),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          AppColors.orangeColor.withOpacity(
                                            0.8,
                                          ),
                                          AppColors.lightOrangeColor
                                              .withOpacity(0.6),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        screenWidth * 0.03,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.orangeColor
                                              .withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.payments_outlined,
                                      color: AppColors.whiteColor,
                                      size: screenWidth * 0.06,
                                    ),
                                  ),
                                  SizedBox(width: screenWidth * 0.04),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Entry Fee',
                                        style: AppTexts.bodyTextStyle(
                                          context: context,
                                          textColor: AppColors.whiteColor
                                              .withOpacity(0.7),
                                          fontSize:
                                              AppFontSizes(context).size14,
                                        ),
                                      ),
                                      Text(
                                        'PKR ${tournament.playerFee}',
                                        style: AppTexts.emphasizedTextStyle(
                                          context: context,
                                          textColor: AppColors.orangeColor,
                                          fontSize:
                                              AppFontSizes(context).size20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: screenHeight * 0.03),
                          ],
                        ),
                      ),
                    ),

                    // Action Buttons
                    Container(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor.withOpacity(0.05),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(screenWidth * 0.06),
                          bottomRight: Radius.circular(screenWidth * 0.06),
                        ),
                        border: Border(
                          top: BorderSide(
                            color: AppColors.whiteColor.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                height: screenHeight * 0.055,
                                decoration: BoxDecoration(
                                  color: AppColors.whiteColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(
                                    screenWidth * 0.06,
                                  ),
                                  border: Border.all(
                                    color: AppColors.whiteColor.withOpacity(
                                      0.2,
                                    ),
                                    width: 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    screenWidth * 0.06,
                                  ),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 10,
                                      sigmaY: 10,
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Close',
                                        style: AppTexts.bodyTextStyle(
                                          context: context,
                                          textColor: AppColors.whiteColor
                                              .withOpacity(0.8),
                                          fontSize:
                                              AppFontSizes(context).size16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.04),
                          Expanded(
                            flex: 2,
                            child: GestureDetector(
                              onTap:
                                  isRegistrationClosed
                                      ? null
                                      : () {
                                        Navigator.pop(context);
                                        showDialog(
                                          context: context,
                                          builder:
                                              (context) => RegisterTeamDialog(
                                                tournamentId: tournament.id,
                                                provider: provider,
                                              ),
                                        );
                                      },
                              child: Container(
                                height: screenHeight * 0.055,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors:
                                        isRegistrationClosed ||
                                                tournament.registeredTeams >=
                                                    tournament.totalTeams
                                            ? [
                                              AppColors.greyColor.withOpacity(
                                                0.5,
                                              ),
                                              AppColors.darkGreyColor
                                                  .withOpacity(0.3),
                                            ]
                                            : [
                                              AppColors.orangeColor.withOpacity(
                                                0.8,
                                              ),
                                              AppColors.lightOrangeColor
                                                  .withOpacity(0.6),
                                            ],
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    screenWidth * 0.06,
                                  ),
                                  boxShadow:
                                      isRegistrationClosed ||
                                              tournament.registeredTeams >=
                                                  tournament.totalTeams
                                          ? []
                                          : [
                                            BoxShadow(
                                              color: AppColors.orangeColor
                                                  .withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    screenWidth * 0.06,
                                  ),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 10,
                                      sigmaY: 10,
                                    ),
                                    child: Center(
                                      child: Text(
                                        isRegistrationClosed
                                            ? 'Registration Closed'
                                            : 'Register Team',
                                        style: AppTexts.bodyTextStyle(
                                          context: context,
                                          textColor: AppColors.whiteColor,
                                          fontSize:
                                              AppFontSizes(context).size16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
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
        );
      },
    );
  }
}
