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
import '../../../providers/navigation_provider.dart';
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

              // Filter Section
              // _buildFilterSection(context, provider),
              SizedBox(height: screenHeight * 0.02),
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
        image: DecorationImage(
          image: AssetImage(AppImages.placeholderTournament),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, TournamentStatus status) {
    final screenWidth = MediaQuery.of(context).size.width;

    Color chipColor;
    List<Color> gradientColors;

    switch (status) {
      case TournamentStatus.approved:
        chipColor = AppColors.followColor;
        gradientColors = [
          AppColors.followColor.withOpacity(0.8),
          AppColors.followColor.withOpacity(0.6),
        ];
        break;
      case TournamentStatus.underReview:
        chipColor = AppColors.goldColor;
        gradientColors = [
          AppColors.goldColor.withOpacity(0.8),
          AppColors.goldColor.withOpacity(0.6),
        ];
        break;
      case TournamentStatus.rejected:
        chipColor = AppColors.redColor;
        gradientColors = [
          AppColors.redColor.withOpacity(0.8),
          AppColors.redColor.withOpacity(0.6),
        ];
        break;
      case TournamentStatus.ongoing:
        chipColor = AppColors.blueColor;
        gradientColors = [
          AppColors.blueColor.withOpacity(0.8),
          AppColors.blueColor.withOpacity(0.6),
        ];
        break;
      case TournamentStatus.cancelled:
        chipColor = AppColors.orangeColor;
        gradientColors = [
          AppColors.orangeColor.withOpacity(0.8),
          AppColors.orangeColor.withOpacity(0.6),
        ];
        break;
      case TournamentStatus.completed:
        chipColor = AppColors.greyColor;
        gradientColors = [
          AppColors.greyColor.withOpacity(0.8),
          AppColors.greyColor.withOpacity(0.6),
        ];
        break;
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
      child: Text(
        status.displayName, // ✅ uses extension (e.g., "Up Coming")
        style: AppTexts.bodyTextStyle(
          context: context,
          textColor: AppColors.whiteColor,
          fontSize: AppFontSizes(context).size10,
          fontWeight: FontWeight.w600,
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

    // Show loading state
    if (provider.isLoadingTournaments) {
      return BuildSkeletonLoader();
    }

    // Show error state
    if (provider.errorMessage.isNotEmpty) {
      return ErrorState(
        provider: provider,
        onTap: () {
          _loadTournaments(provider);
        },
      );
    }

    // Handle "My Tournaments" tab
    if (provider.selectedSubTabIndex == 0) {
      // Combine organized + played tournaments
      final myTournaments = [
        ...provider.organizedTournaments,
        ...provider.playedTournaments,
      ];

      if (myTournaments.isEmpty) {
        return _buildEmptyState(context, provider);
      }

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
      // Handle "All Tournaments" tab
      final allTournaments = provider.allTournaments;

      if (allTournaments.isEmpty) {
        return _buildEmptyState(context, provider);
      }

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
              InkWell(
                onTap: () {
                  _showTournamentDetails(context, tournament, provider);
                },
                child: ClipRRect(
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
                        if (!isRegistrationClosed)
                          _buildStatusChip(
                            context,
                            tournament.status.toTournamentStatus(),
                          ),
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
                    Column(
                      children: [
                        // View Details Button - Always visible
                        Consumer<NavigationProvider>(
                          builder: (
                            BuildContext context,
                            NavigationProvider value,
                            Widget? child,
                          ) {
                            return GestureDetector(
                              onTap: () {
                                isRegistrationClosed
                                    ? null
                                    : value.goToTab(context, 1);
                              },
                              child: Container(
                                width: double.infinity,
                                height: screenHeight * 0.05,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      isRegistrationClosed
                                          ? AppColors.redColor.withOpacity(0.8)
                                          : AppColors.orangeColor.withOpacity(
                                            0.8,
                                          ),
                                      isRegistrationClosed
                                          ? AppColors.redColor.withOpacity(0.6)
                                          : AppColors.lightOrangeColor
                                              .withOpacity(0.6),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    screenWidth * 0.06,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.orangeColor.withOpacity(
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
                                        isRegistrationClosed
                                            ? 'Registration Closed'
                                            : (tournament.status ==
                                                    TournamentStatus
                                                        .cancelled
                                                        .displayName
                                                ? 'Tournament Cancelled'
                                                : 'Register your team'),
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
                            );
                          },
                        ),

                        // View Brackets Button - Only for ongoing/completed tournaments
                        Visibility(
                          visible:
                              tournament.status ==
                                  TournamentStatus.ongoing.displayName ||
                              tournament.status ==
                                  TournamentStatus.completed.displayName,
                          child: Column(
                            children: [
                              SizedBox(height: screenHeight * 0.01),
                              Consumer<Brackets>(
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
                            ],
                          ),
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
              InkWell(
                onTap: () {
                  _showTournamentDetails(context, tournament, provider);
                },
                child: ClipRRect(
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
                        if (!isRegistrationClosed)
                          _buildStatusChip(
                            context,
                            tournament.status.toTournamentStatus(),
                          ),
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
                              visible: tournament.status.toLowerCase() == 'approved',
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
                            Consumer<NavigationProvider>(
                              builder: (
                                BuildContext context,
                                NavigationProvider value,
                                Widget? child,
                              ) {
                                return Expanded(
                                  child: GestureDetector(
                                    onTap:
                                        isRegistrationClosed
                                            ? null
                                            : () {
                                              value.goToTab(context, 1);
                                            },
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
                                                ? AppColors.redColor
                                                    .withOpacity(0.8)
                                                : AppColors.orangeColor
                                                    .withOpacity(0.8),
                                            isRegistrationClosed ||
                                                    tournament.status ==
                                                        TournamentStatus
                                                            .cancelled
                                                            .displayName
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
                                                      : 'Register your team'),
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
                                );
                              },
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
                    // Add this after the existing action buttons (around line 300+ in your card)
                    // Check if tournament can be cancelled
                    Visibility(
                      visible:
                          tournament.status ==
                              TournamentStatus.approved.displayName ||
                          tournament.status ==
                              TournamentStatus.underReview.displayName,
                      child: Column(
                        children: [
                          SizedBox(height: screenHeight * 0.01),
                          Consumer<TournamentProvider>(
                            builder: (context, tournamentProvider, child) {
                              return GestureDetector(
                                onTap:
                                    tournamentProvider.isCancelLoading
                                        ? null
                                        : () => _showCancelConfirmationDialog(
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
                                        tournamentProvider.isLoading
                                            ? AppColors.greyColor.withOpacity(
                                              0.8,
                                            )
                                            : AppColors.redColor.withOpacity(
                                              0.8,
                                            ),
                                        tournamentProvider.isLoading
                                            ? AppColors.greyColor.withOpacity(
                                              0.6,
                                            )
                                            : AppColors.redColor.withOpacity(
                                              0.6,
                                            ),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      screenWidth * 0.06,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            tournamentProvider.isLoading
                                                ? AppColors.greyColor
                                                    .withOpacity(0.2)
                                                : AppColors.redColor
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
                                            tournamentProvider.isLoading
                                                ? SizedBox(
                                                  height: 20,
                                                  child: SpinKitThreeBounce(
                                                    color: AppColors.whiteColor,
                                                    size: screenWidth * 0.04,
                                                  ),
                                                )
                                                : Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.cancel_outlined,
                                                      color:
                                                          AppColors.whiteColor,
                                                      size: screenWidth * 0.04,
                                                    ),
                                                    SizedBox(
                                                      width: screenWidth * 0.02,
                                                    ),
                                                    Text(
                                                      'Cancel Tournament',
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
                                                  ],
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

  void _showCancelConfirmationDialog(
    BuildContext context,
    MyTournament tournament,
    TournamentProvider provider,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.navyBlueGrey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: AppColors.whiteColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          title: Text(
            'Cancel Tournament',
            style: AppTexts.emphasizedTextStyle(
              context: dialogContext,
              textColor: AppColors.whiteColor,
              fontSize: AppFontSizes(dialogContext).size18,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to cancel this tournament?',
                style: AppTexts.bodyTextStyle(
                  context: dialogContext,
                  textColor: AppColors.whiteColor.withOpacity(0.8),
                  fontSize: AppFontSizes(dialogContext).size14,
                ),
              ),
              SizedBox(height: MediaQuery.of(dialogContext).size.height * 0.02),
              Text(
                '• Tournament: ${tournament.title}',
                style: AppTexts.bodyTextStyle(
                  context: dialogContext,
                  textColor: AppColors.orangeColor,
                  fontSize: AppFontSizes(dialogContext).size14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: MediaQuery.of(dialogContext).size.height * 0.01),
              Text(
                '• This action cannot be undone',
                style: AppTexts.bodyTextStyle(
                  context: dialogContext,
                  textColor: AppColors.redColor,
                  fontSize: AppFontSizes(dialogContext).size12,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Keep Tournament',
                style: AppTexts.bodyTextStyle(
                  context: dialogContext,
                  textColor: AppColors.whiteColor.withOpacity(0.7),
                  fontSize: AppFontSizes(dialogContext).size14,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Close the dialog first
                Navigator.of(dialogContext).pop();

                // Then perform the cancellation
                // Use the original context here, not the dialog context
                await provider.cancelTournament(
                  context: context,
                  tournamentId: tournament.id,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.redColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Cancel Tournament',
                style: AppTexts.bodyTextStyle(
                  context: dialogContext,
                  textColor: AppColors.whiteColor,
                  fontSize: AppFontSizes(dialogContext).size14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Widget _buildFilterSection(BuildContext context, TournamentProvider provider) {
  //   final screenWidth = MediaQuery.of(context).size.width;
  //   final screenHeight = MediaQuery.of(context).size.height;
  //
  //   return AnimatedContainer(
  //     duration: const Duration(milliseconds: 300),
  //     margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
  //     child: Column(
  //       children: [
  //         // Filter Toggle Button
  //         GestureDetector(
  //           onTap: provider.toggleFilterOptions,
  //           child: Container(
  //             padding: EdgeInsets.symmetric(
  //               horizontal: screenWidth * 0.04,
  //               vertical: screenHeight * 0.015,
  //             ),
  //             decoration: BoxDecoration(
  //               color: AppColors.whiteColor.withOpacity(0.1),
  //               borderRadius: BorderRadius.circular(screenWidth * 0.06),
  //               border: Border.all(
  //                 color: AppColors.whiteColor.withOpacity(0.2),
  //                 width: 1,
  //               ),
  //             ),
  //             child: ClipRRect(
  //               borderRadius: BorderRadius.circular(screenWidth * 0.06),
  //               child: BackdropFilter(
  //                 filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
  //                 child: Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     Row(
  //                       children: [
  //                         Container(
  //                           padding: EdgeInsets.all(screenWidth * 0.02),
  //                           decoration: BoxDecoration(
  //                             gradient: LinearGradient(
  //                               begin: Alignment.topLeft,
  //                               end: Alignment.bottomRight,
  //                               colors: [
  //                                 AppColors.orangeColor.withOpacity(0.8),
  //                                 AppColors.lightOrangeColor.withOpacity(0.6),
  //                               ],
  //                             ),
  //                             borderRadius: BorderRadius.circular(screenWidth * 0.03),
  //                           ),
  //                           child: Icon(
  //                             Icons.filter_list,
  //                             color: AppColors.whiteColor,
  //                             size: screenWidth * 0.05,
  //                           ),
  //                         ),
  //                         SizedBox(width: screenWidth * 0.03),
  //                         Column(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           children: [
  //                             Text(
  //                               'Filter Tournaments',
  //                               style: AppTexts.bodyTextStyle(
  //                                 context: context,
  //                                 textColor: AppColors.whiteColor,
  //                                 fontSize: AppFontSizes(context).size16,
  //                                 fontWeight: FontWeight.w600,
  //                               ),
  //                             ),
  //                             Text(
  //                               '${provider.selectedStatuses.length} status(es) selected',
  //                               style: AppTexts.bodyTextStyle(
  //                                 context: context,
  //                                 textColor: AppColors.whiteColor.withOpacity(0.7),
  //                                 fontSize: AppFontSizes(context).size12,
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ],
  //                     ),
  //                     AnimatedRotation(
  //                       turns: provider.showFilterOptions ? 0.5 : 0,
  //                       duration: const Duration(milliseconds: 300),
  //                       child: Icon(
  //                         Icons.expand_more,
  //                         color: AppColors.whiteColor.withOpacity(0.8),
  //                         size: screenWidth * 0.06,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //
  //         // Filter Options
  //         AnimatedContainer(
  //           duration: const Duration(milliseconds: 300),
  //           height: provider.showFilterOptions ? null : 0,
  //           child: provider.showFilterOptions
  //               ? Container(
  //             margin: EdgeInsets.only(top: screenHeight * 0.01),
  //             padding: EdgeInsets.all(screenWidth * 0.04),
  //             decoration: BoxDecoration(
  //               color: AppColors.whiteColor.withOpacity(0.1),
  //               borderRadius: BorderRadius.circular(screenWidth * 0.04),
  //               border: Border.all(
  //                 color: AppColors.whiteColor.withOpacity(0.2),
  //                 width: 1,
  //               ),
  //             ),
  //             child: ClipRRect(
  //               borderRadius: BorderRadius.circular(screenWidth * 0.04),
  //               child: BackdropFilter(
  //                 filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Row(
  //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                       children: [
  //                         Text(
  //                           'Select Status',
  //                           style: AppTexts.bodyTextStyle(
  //                             context: context,
  //                             textColor: AppColors.whiteColor,
  //                             fontSize: AppFontSizes(context).size16,
  //                             fontWeight: FontWeight.w600,
  //                           ),
  //                         ),
  //                         GestureDetector(
  //                           onTap: provider.resetFilters,
  //                           child: Container(
  //                             padding: EdgeInsets.symmetric(
  //                               horizontal: screenWidth * 0.03,
  //                               vertical: screenWidth * 0.01,
  //                             ),
  //                             decoration: BoxDecoration(
  //                               color: AppColors.orangeColor.withOpacity(0.2),
  //                               borderRadius: BorderRadius.circular(screenWidth * 0.03),
  //                               border: Border.all(
  //                                 color: AppColors.orangeColor.withOpacity(0.4),
  //                                 width: 1,
  //                               ),
  //                             ),
  //                             child: Text(
  //                               'Reset',
  //                               style: AppTexts.bodyTextStyle(
  //                                 context: context,
  //                                 textColor: AppColors.orangeColor,
  //                                 fontSize: AppFontSizes(context).size12,
  //                                 fontWeight: FontWeight.w500,
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                     SizedBox(height: screenHeight * 0.015),
  //                     Wrap(
  //                       spacing: screenWidth * 0.02,
  //                       runSpacing: screenWidth * 0.02,
  //                       children: provider.statusOptions.map((status) {
  //                         final isSelected = provider.selectedStatuses
  //                             .contains(status['value']);
  //                         return GestureDetector(
  //                           onTap: () => provider.toggleStatusFilter(status['value']!),
  //                           child: AnimatedContainer(
  //                             duration: const Duration(milliseconds: 200),
  //                             padding: EdgeInsets.symmetric(
  //                               horizontal: screenWidth * 0.03,
  //                               vertical: screenWidth * 0.02,
  //                             ),
  //                             decoration: BoxDecoration(
  //                               gradient: isSelected
  //                                   ? LinearGradient(
  //                                 begin: Alignment.topLeft,
  //                                 end: Alignment.bottomRight,
  //                                 colors: [
  //                                   AppColors.orangeColor.withOpacity(0.8),
  //                                   AppColors.lightOrangeColor.withOpacity(0.6),
  //                                 ],
  //                               )
  //                                   : null,
  //                               color: isSelected
  //                                   ? null
  //                                   : AppColors.whiteColor.withOpacity(0.1),
  //                               borderRadius: BorderRadius.circular(screenWidth * 0.05),
  //                               border: Border.all(
  //                                 color: isSelected
  //                                     ? AppColors.orangeColor.withOpacity(0.5)
  //                                     : AppColors.whiteColor.withOpacity(0.2),
  //                                 width: 1,
  //                               ),
  //                               boxShadow: isSelected
  //                                   ? [
  //                                 BoxShadow(
  //                                   color: AppColors.orangeColor.withOpacity(0.3),
  //                                   blurRadius: 8,
  //                                   offset: const Offset(0, 4),
  //                                 ),
  //                               ]
  //                                   : [],
  //                             ),
  //                             child: Row(
  //                               mainAxisSize: MainAxisSize.min,
  //                               children: [
  //                                 AnimatedContainer(
  //                                   duration: const Duration(milliseconds: 200),
  //                                   width: screenWidth * 0.04,
  //                                   height: screenWidth * 0.04,
  //                                   decoration: BoxDecoration(
  //                                     shape: BoxShape.circle,
  //                                     color: isSelected
  //                                         ? AppColors.whiteColor
  //                                         : Colors.transparent,
  //                                     border: Border.all(
  //                                       color: isSelected
  //                                           ? AppColors.whiteColor
  //                                           : AppColors.whiteColor.withOpacity(0.5),
  //                                       width: 2,
  //                                     ),
  //                                   ),
  //                                   child: isSelected
  //                                       ? Icon(
  //                                     Icons.check,
  //                                     color: AppColors.orangeColor,
  //                                     size: screenWidth * 0.025,
  //                                   )
  //                                       : null,
  //                                 ),
  //                                 SizedBox(width: screenWidth * 0.02),
  //                                 Text(
  //                                   status['display']!,
  //                                   style: AppTexts.bodyTextStyle(
  //                                     context: context,
  //                                     textColor: AppColors.whiteColor,
  //                                     fontSize: AppFontSizes(context).size14,
  //                                     fontWeight: isSelected
  //                                         ? FontWeight.w600
  //                                         : FontWeight.w500,
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                         );
  //                       }).toList(),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           )
  //               : const SizedBox.shrink(),
  //         ),
  //       ],
  //     ),
  //   );
  // }
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
        image: DecorationImage(
          image: AssetImage(AppImages.placeholderTournament),
          fit: BoxFit.cover,
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

                            // SizedBox(height: screenHeight * 0.01),

                            // Status Badge
                            // Align(
                            //   alignment: Alignment.centerLeft,
                            //   child: _buildStatusChip(
                            //     context,
                            //       tournament.status
                            //   ),
                            // ),
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

                    // // Action Buttons
                    // Container(
                    //   padding: EdgeInsets.all(screenWidth * 0.04),
                    //   decoration: BoxDecoration(
                    //     color: AppColors.whiteColor.withOpacity(0.05),
                    //     borderRadius: BorderRadius.only(
                    //       bottomLeft: Radius.circular(screenWidth * 0.06),
                    //       bottomRight: Radius.circular(screenWidth * 0.06),
                    //     ),
                    //     border: Border(
                    //       top: BorderSide(
                    //         color: AppColors.whiteColor.withOpacity(0.1),
                    //         width: 1,
                    //       ),
                    //     ),
                    //   ),
                    //   child: Row(
                    //     children: [
                    //       Expanded(
                    //         child: GestureDetector(
                    //           onTap: () => Navigator.pop(context),
                    //           child: Container(
                    //             height: screenHeight * 0.055,
                    //             decoration: BoxDecoration(
                    //               color: AppColors.whiteColor.withOpacity(0.1),
                    //               borderRadius: BorderRadius.circular(
                    //                 screenWidth * 0.06,
                    //               ),
                    //               border: Border.all(
                    //                 color: AppColors.whiteColor.withOpacity(
                    //                   0.2,
                    //                 ),
                    //                 width: 1,
                    //               ),
                    //             ),
                    //             child: ClipRRect(
                    //               borderRadius: BorderRadius.circular(
                    //                 screenWidth * 0.06,
                    //               ),
                    //               child: BackdropFilter(
                    //                 filter: ImageFilter.blur(
                    //                   sigmaX: 10,
                    //                   sigmaY: 10,
                    //                 ),
                    //                 child: Center(
                    //                   child: Text(
                    //                     'Close',
                    //                     style: AppTexts.bodyTextStyle(
                    //                       context: context,
                    //                       textColor: AppColors.whiteColor
                    //                           .withOpacity(0.8),
                    //                       fontSize:
                    //                           AppFontSizes(context).size16,
                    //                       fontWeight: FontWeight.w500,
                    //                     ),
                    //                   ),
                    //                 ),
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //       SizedBox(width: screenWidth * 0.04),
                    //       Consumer<NavigationProvider>(
                    //         builder: (
                    //           BuildContext context,
                    //           NavigationProvider navProvider,
                    //           Widget? child,
                    //         ) {
                    //           return Expanded(
                    //             flex: 2,
                    //             child: GestureDetector(
                    //               onTap:
                    //                   isRegistrationClosed
                    //                       ? null
                    //                       : () {
                    //                         // Navigator.pop(context);
                    //                         // showDialog(
                    //                         //   context: context,
                    //                         //   builder:
                    //                         //       (context) => RegisterTeamDialog(
                    //                         //         tournamentId: tournament.id,
                    //                         //         provider: provider,
                    //                         //       ),
                    //                         // );
                    //                         navProvider.goToTab(context, 1);
                    //                       },
                    //               child: Container(
                    //                 height: screenHeight * 0.055,
                    //                 decoration: BoxDecoration(
                    //                   gradient: LinearGradient(
                    //                     begin: Alignment.topLeft,
                    //                     end: Alignment.bottomRight,
                    //                     colors:
                    //                         isRegistrationClosed ||
                    //                                 tournament
                    //                                         .registeredTeams >=
                    //                                     tournament.totalTeams
                    //                             ? [
                    //                               AppColors.greyColor
                    //                                   .withOpacity(0.5),
                    //                               AppColors.darkGreyColor
                    //                                   .withOpacity(0.3),
                    //                             ]
                    //                             : [
                    //                               AppColors.orangeColor
                    //                                   .withOpacity(0.8),
                    //                               AppColors.lightOrangeColor
                    //                                   .withOpacity(0.6),
                    //                             ],
                    //                   ),
                    //                   borderRadius: BorderRadius.circular(
                    //                     screenWidth * 0.06,
                    //                   ),
                    //                   boxShadow:
                    //                       isRegistrationClosed ||
                    //                               tournament.registeredTeams >=
                    //                                   tournament.totalTeams
                    //                           ? []
                    //                           : [
                    //                             BoxShadow(
                    //                               color: AppColors.orangeColor
                    //                                   .withOpacity(0.3),
                    //                               blurRadius: 8,
                    //                               offset: const Offset(0, 4),
                    //                             ),
                    //                           ],
                    //                 ),
                    //                 child: ClipRRect(
                    //                   borderRadius: BorderRadius.circular(
                    //                     screenWidth * 0.06,
                    //                   ),
                    //                   child: BackdropFilter(
                    //                     filter: ImageFilter.blur(
                    //                       sigmaX: 10,
                    //                       sigmaY: 10,
                    //                     ),
                    //                     child: Center(
                    //                       child: Text(
                    //                         isRegistrationClosed
                    //                             ? 'Registration Closed'
                    //                             : 'Register Team',
                    //                         style: AppTexts.bodyTextStyle(
                    //                           context: context,
                    //                           textColor: AppColors.whiteColor,
                    //                           fontSize:
                    //                               AppFontSizes(context).size16,
                    //                           fontWeight: FontWeight.w600,
                    //                         ),
                    //                       ),
                    //                     ),
                    //                   ),
                    //                 ),
                    //               ),
                    //             ),
                    //           );
                    //         },
                    //       ),
                    //     ],
                    //   ),
                    // ),
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

extension TournamentStatusParsing on String {
  TournamentStatus toTournamentStatus() {
    switch (toLowerCase()) {
      case 'approved':
        return TournamentStatus.approved;
      case 'under review':
        return TournamentStatus.underReview;
      case 'rejected':
        return TournamentStatus.rejected;
      case 'ongoing':
        return TournamentStatus.ongoing;
      case 'completed':
        return TournamentStatus.completed;
      case 'cancelled':
        return TournamentStatus.cancelled;
      default:
        return TournamentStatus.underReview;
    }
  }
}
