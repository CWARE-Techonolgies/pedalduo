import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pedalduo/global/images.dart';
import 'package:pedalduo/models/user_model.dart';
import 'package:provider/provider.dart';
import '../../../chat/chat_room_provider.dart';
import '../../../chat/chat_rooms_screen.dart';
import '../../../providers/navigation_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../services/shared_preference_service.dart';
import '../../../style/colors.dart';
import '../../../style/fonts_sizes.dart';
import '../../profile/profile_screen.dart';
import '../../profile/update_profile_scren.dart';
import 'create_team_screen.dart';
import 'courts_screen.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatRoomsProvider>().fetchChatRooms();
      loadUser();
      context.read<NotificationProvider>().registerFCMToken();

      // Call silentRefresh periodically every 2 seconds
      Timer.periodic(const Duration(milliseconds: 2000), (timer) {
        if (mounted) {
          context.read<ChatRoomsProvider>().silentRefresh();
        } else {
          timer.cancel(); // Cancel timer if widget is disposed
        }
      });
    });
  }

  Future<void> loadUser() async {
    final user = await SharedPreferencesService.getUserData();
    setState(() {
      _user = user;
    });
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null && route.isCurrent) {
      loadUser();
    }
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
                    image: AssetImage(AppImages.logoImage2),
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
                child: Consumer<ChatRoomsProvider>(
                  builder: (context, chatProvider, child) {
                    final unreadCount = chatProvider.totalUnreadMessages;
                    return Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Container(
                          width: screenWidth * 0.1,
                          height: screenWidth * 0.1,
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
                        if (unreadCount > 0)
                          Positioned(
                            top: -0.5,
                            child: Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: AppColors.navyBlueGrey,
                                shape: BoxShape.circle,
                              ),
                              constraints: BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Center(
                                child: Text(
                                  unreadCount > 99 ? '9+' : unreadCount.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
// Replace the existing profile navigation InkWell in actions
              InkWell(
                onTap: () async {
                  // Navigate to profile update and refresh user data when returning
                  await Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (_) => UserProfileUpdateScreen(),
                    ),
                  );
                  // Refresh user data after returning from profile update
                  loadUser();
                },
                child: (_user?.imageUrl != null && _user!.imageUrl!.isNotEmpty)
                    ? CircleAvatar(
                  backgroundImage: MemoryImage(
                    base64Decode(_extractBase64(_user!.imageUrl!)),
                  ),
                )
                    : CircleAvatar(
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
        return const CreateTeamScreen();
      case 2:
        return const DiscoveryScreen();
      case 3:
        return const CourtsScreen();
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
                icon: Icon(CupertinoIcons.person_3_fill),
                label: 'Teams',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.explore),
                label: 'Discover',
              ),
              BottomNavigationBarItem(icon: Icon(Icons.sports_score_outlined), label: 'Courts'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Me'),
            ],
          ),
        ),
      ),
    );
  }String _extractBase64(String dataUrl) {
    if (dataUrl.contains(',')) {
      return dataUrl.split(',').last;
    }
    return dataUrl;
  }
}
