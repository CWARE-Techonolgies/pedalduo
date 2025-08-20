import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pedalduo/providers/navigation_provider.dart';
import 'package:pedalduo/services/shared_preference_service.dart';
import 'package:pedalduo/style/fonts_sizes.dart';
import 'package:pedalduo/views/all_players.dart';
import 'package:pedalduo/views/play/brackets/all_brackets_views.dart';
import 'package:pedalduo/views/play/views/play_screen.dart';
import 'package:provider/provider.dart';
import '../../../../../style/colors.dart';
import '../../../../../widgets/hero_slider.dart';
import '../../../../invitation/invitation_screen.dart';
import '../../../../invitation/invitation_provider.dart'; // Add this import
import '../../../../play/models/my_matches_model.dart';
import '../../../../play/providers/matches_provider.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Call the invitation API every time this screen is visited
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvitationsProvider>().initialize();
      _refreshInvitations();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Method to refresh invitations
  void _refreshInvitations() {
    final invitationsProvider = context.read<InvitationsProvider>();
    invitationsProvider.refreshAll();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Slider
          AutoSlideHeroSlider(),

          const SizedBox(height: 24),

          // Action Cards Grid
          _buildActionCards(),

          const SizedBox(height: 24),

          // Upcoming Matches
          _buildUpcomingMatches(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildActionCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildGlassCard(
                  title: 'Play',
                  icon: Icons.sports_tennis,
                  color: AppColors.orangeColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(builder: (_) => PlayScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              // Updated Invitations card with Consumer to listen to invitation count
              Expanded(
                child: Consumer<InvitationsProvider>(
                  builder: (context, invitationsProvider, child) {
                    final totalInvitations = invitationsProvider.pendingReceivedCount;

                    return _buildGlassCardWithBadge(
                      title: 'Invitations',
                      icon: Icons.inbox_outlined,
                      color: AppColors.greenColor,
                      badgeCount: totalInvitations,
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(builder: (_) => InvitationsScreen()),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Consumer<NavigationProvider>(
                builder: (BuildContext context, NavigationProvider navProvider, Widget? child) {
                  return Expanded(
                    child: _buildGlassCard(
                      title: 'Top Feed',
                      icon: Icons.local_fire_department,
                      color: AppColors.blueColor,
                      onTap: () {
                        navProvider.goToTab(context, 0);
                      },
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildGlassCard(
                  title: 'Players',
                  icon: Icons.group,
                  color: AppColors.purpleColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(builder: (_) => AllPlayers()),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.8), color.withOpacity(0.6)],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.7),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: AppColors.whiteColor,
                    size: AppFontSizes(context).size20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: GoogleFonts.barlowCondensed(
                      fontSize: AppFontSizes(context).size16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.whiteColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // New method for glass card with badge (for invitations)
  Widget _buildGlassCardWithBadge({
    required String title,
    required IconData icon,
    required Color color,
    required int badgeCount,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.8), color.withOpacity(0.6)],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.7),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: AppColors.whiteColor,
                    size: AppFontSizes(context).size20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: GoogleFonts.barlowCondensed(
                      fontSize: AppFontSizes(context).size16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.whiteColor,
                    ),
                  ),
                  if (badgeCount > 0)...[
                    SizedBox(width: 10,),
                    Container(
                      decoration: BoxDecoration(
                          color: AppColors.backgroundColor,
                        shape: BoxShape.circle,

                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          badgeCount > 99 ? '99+' : badgeCount.toString(),
                          style: GoogleFonts.barlow(
                            fontSize: AppFontSizes(context).size10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.whiteColor,
                          ),
                        ),
                      ),
                    ),
                  ]

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingMatches(BuildContext context) {
    return Consumer<MatchesProvider>(
      builder: (context, provider, child) {
        final upcomingMatches = provider.upcomingMatches;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Upcoming Matches',
                    style: GoogleFonts.barlowCondensed(
                      fontSize: AppFontSizes(context).size20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.whiteColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Content Section
            if (provider.isLoading)
              _buildLoadingState(context)
            else if (upcomingMatches.isEmpty)
              _buildEmptyState(context)
            else
              _buildUpcomingMatchesList(context, upcomingMatches),
          ],
        );
      },
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 2,
        itemBuilder: (context, index) {
          return Container(
            width: MediaQuery.of(context).size.width * 0.85,
            margin: EdgeInsets.only(right: index == 1 ? 0 : 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.lightNavyBlueGrey.withOpacity(0.3),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.lightNavyBlueGrey.withOpacity(0.3),
        border: Border.all(
          color: AppColors.orangeColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_note, size: 64, color: AppColors.greyColor),
                const SizedBox(height: 16),
                Text(
                  'No Upcoming Matches',
                  style: GoogleFonts.barlowCondensed(
                    fontSize: AppFontSizes(context).size18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.whiteColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'There are no scheduled matches at the moment. Join or create any tournament',
                  style: GoogleFonts.barlow(
                    fontSize: AppFontSizes(context).size14,
                    color: AppColors.greyColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingMatchesList(
      BuildContext context,
      List<MyMatchesModel> matches,
      ) {
    if (matches.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: MediaQuery.sizeOf(context).height *.23,
      child: matches.length == 1
          ? Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _buildUpcomingMatchCard(context, matches.first),
      )
          : ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: matches.length,
        itemBuilder: (context, index) {
          final match = matches[index];
          return _buildUpcomingMatchCard(context, match);
        },
      ),
    );
  }
  Widget _buildUpcomingMatchCard(BuildContext context, MyMatchesModel match) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.lightNavyBlueGrey.withOpacity(0.8),
        border: Border.all(
          color: AppColors.orangeColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tournament Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.orangeColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.emoji_events,
                        size: AppFontSizes(context).size14,
                        color: AppColors.whiteColor,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          match.tournament.title,
                          style: GoogleFonts.barlow(
                            fontSize: AppFontSizes(context).size12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.whiteColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.whiteColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          match.roundName,
                          style: GoogleFonts.barlow(
                            fontSize: AppFontSizes(context).size10,
                            color: AppColors.whiteColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Match Number
                Text(
                  'Match #${match.matchNumber}',
                  style: GoogleFonts.barlowCondensed(
                    fontSize: AppFontSizes(context).size18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.whiteColor,
                  ),
                ),
                const SizedBox(height: 12),

                // Teams
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        match.team1.name,
                        style: GoogleFonts.barlow(
                          fontSize: AppFontSizes(context).size16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.whiteColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.blueColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: AppColors.blueColor,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'VS',
                        style: GoogleFonts.barlowCondensed(
                          fontSize: AppFontSizes(context).size12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.blueColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        match.team2.name,
                        style: GoogleFonts.barlow(
                          fontSize: AppFontSizes(context).size16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.whiteColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Match Details
                if (match.matchDate != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: AppFontSizes(context).size16,
                        color: AppColors.greyColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${DateFormat('MMM dd').format(match.matchDate!)} • ${DateFormat('hh:mm a').format(match.matchDate!)}',
                        style: GoogleFonts.barlow(
                          fontSize: AppFontSizes(context).size14,
                          color: AppColors.greyColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],

                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: AppFontSizes(context).size16,
                      color: AppColors.greyColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        match.tournament.location,
                        style: GoogleFonts.barlow(
                          fontSize: AppFontSizes(context).size14,
                          color: AppColors.greyColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
  }

  String _getMatchStatus(MyMatchesModel match) {
    // You can customize this based on your match status logic
    if (match.matchDate != null) {
      final now = DateTime.now();
      final matchDate = match.matchDate!;

      if (matchDate.isAfter(now)) {
        final difference = matchDate.difference(now);
        if (difference.inDays > 0) {
          return 'In ${difference.inDays} days';
        } else if (difference.inHours > 0) {
          return 'In ${difference.inHours} hours';
        } else {
          return 'Starting soon';
        }
      }
    }
    return 'Bracket Scheduled';
  }
}