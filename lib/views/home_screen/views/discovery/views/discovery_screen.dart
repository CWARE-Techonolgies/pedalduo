import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pedalduo/services/shared_preference_service.dart';
import 'package:pedalduo/style/fonts_sizes.dart';
import 'package:pedalduo/views/all_players.dart';
import 'package:pedalduo/views/play/views/play_screen.dart';
import '../../../../../style/colors.dart';
import '../../../../../widgets/hero_slider.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  final PageController _pageController = PageController();
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
          _buildUpcomingMatches(),
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
              Expanded(
                child: _buildGlassCard(
                  title: 'Tryouts',
                  icon: Icons.star,
                  color: AppColors.lightGreenColor,
                  onTap: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildGlassCard(
                  title: 'Top Feed',
                  icon: Icons.local_fire_department,
                  color: AppColors.blueColor,
                  onTap: () {},
                ),
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

  Widget _buildUpcomingMatches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              TextButton(
                onPressed: () {},
                child: Text(
                  'See All →',
                  style: GoogleFonts.barlow(
                    fontSize: AppFontSizes(context).size14,
                    color: AppColors.orangeColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
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
                          Text(
                            'Pro Padel League',
                            style: GoogleFonts.barlow(
                              fontSize: AppFontSizes(context).size12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.whiteColor,
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
                              'Semi Finals',
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
                    Text(
                      'Match #2',
                      style: GoogleFonts.barlowCondensed(
                        fontSize: AppFontSizes(context).size18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.whiteColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'Tanveer Team',
                          style: GoogleFonts.barlow(
                            fontSize: AppFontSizes(context).size16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.whiteColor,
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
                        Text(
                          'Saud Team',
                          style: GoogleFonts.barlow(
                            fontSize: AppFontSizes(context).size16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.whiteColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: AppFontSizes(context).size16,
                          color: AppColors.greyColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tomorrow • 12:30 am',
                          style: GoogleFonts.barlow(
                            fontSize: AppFontSizes(context).size14,
                            color: AppColors.greyColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: AppFontSizes(context).size16,
                          color: AppColors.greyColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Raiwind, Lahore',
                          style: GoogleFonts.barlow(
                            fontSize: AppFontSizes(context).size14,
                            color: AppColors.greyColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: AppFontSizes(context).size16,
                          color: AppColors.greyColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'by Tanveer',
                          style: GoogleFonts.barlow(
                            fontSize: AppFontSizes(context).size14,
                            color: AppColors.greyColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.blueColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.blueColor,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Bracket Scheduled',
                            style: GoogleFonts.barlow(
                              fontSize: AppFontSizes(context).size12,
                              color: AppColors.blueColor,
                            ),
                          ),
                        ),
                        const Spacer(),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.orangeColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'View Details',
                            style: GoogleFonts.barlow(
                              fontSize: AppFontSizes(context).size14,
                              color: AppColors.orangeColor,
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
        ),
      ],
    );
  }
}
