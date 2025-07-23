import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pedalduo/global/images.dart';
import 'package:pedalduo/models/user_model.dart';
import 'package:provider/provider.dart';
import '../../../chat/chat_rooms_screen.dart';
import '../../../providers/navigation_provider.dart';
import '../../../services/shared_preference_service.dart';
import '../../../style/colors.dart';
import '../../../style/fonts_sizes.dart';
import '../../profile/profile_screen.dart';
import '../../profile/update_profile_scren.dart';
import 'activity_screen.dart';
import 'clubs_screen.dart';
import 'discovery/views/discovery_screen.dart';
import 'highlighst_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final user = await SharedPreferencesService.getUserData();
    setState(() {
      _user = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        return Scaffold(
          backgroundColor: AppColors.navyBlueGrey,
          appBar: AppBar(
            backgroundColor: AppColors.navyBlueGrey,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.orangeColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image(
                    image: AssetImage(AppImages.logoImage),
                    width: 25,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PadelDuo',
                      style: GoogleFonts.barlowCondensed(
                        fontSize: AppFontSizes(context).size20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.whiteColor,
                      ),
                    ),
                    Text(
                      'Tournament Platform',
                      style: GoogleFonts.barlow(
                        fontSize: AppFontSizes(context).size12,
                        color: AppColors.greyColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (_) => ChatRoomsScreen(refresh: false),
                    ),
                  );
                },
                child: Container(
                  width: screenWidth * 0.08,
                  height: screenWidth * 0.08,
                  decoration: BoxDecoration(
                    color: AppColors.orangeColor,
                    borderRadius: BorderRadius.circular(screenWidth * 0.015),
                  ),
                  child: Icon(
                    CupertinoIcons.bubble_left_bubble_right_fill,
                    color: AppColors.whiteColor,
                    size: screenWidth * 0.05,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (_) => UserProfileUpdateScreen(),
                    ),
                  );
                },
                child: CircleAvatar(
                  backgroundColor: AppColors.orangeColor,
                  child: Text(
                    _getInitials(_user?.name ?? 'P'),
                    style: GoogleFonts.barlow(
                      fontWeight: FontWeight.bold,
                      color: AppColors.whiteColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
          body: _getSelectedScreen(navigationProvider.selectedIndex),
          bottomNavigationBar: _buildBottomNavigationBar(
            context,
            navigationProvider,
          ),
        );
      },
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return parts.take(2).map((e) => e[0].toUpperCase()).join();
  }

  Widget _getSelectedScreen(int index) {
    switch (index) {
      case 0:
        return const HighlightsScreen();
      case 1:
        return const ActivityScreen();
      case 2:
        return const DiscoveryScreen();
      case 3:
        return const ClubsScreen();
      case 4:
        return const ProfileScreen();
      default:
        return const DiscoveryScreen();
    }
  }

  Widget _buildBottomNavigationBar(
    BuildContext context,
    NavigationProvider navigationProvider,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightNavyBlueGrey.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackColor.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            selectedItemColor: AppColors.orangeColor,
            unselectedItemColor: AppColors.greyColor,
            currentIndex: navigationProvider.selectedIndex,
            onTap: navigationProvider.setSelectedIndex,
            selectedLabelStyle: GoogleFonts.barlow(
              fontSize: AppFontSizes(context).size12,
            ),
            unselectedLabelStyle: GoogleFonts.barlow(
              fontSize: AppFontSizes(context).size12,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.highlight),
                label: 'Highlights',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications),
                label: 'Activity',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.explore),
                label: 'Discover',
              ),
              BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Clubs'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Me'),
            ],
          ),
        ),
      ),
    );
  }
}
