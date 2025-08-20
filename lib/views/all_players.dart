import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pedalduo/chat/chat_room.dart';
import 'package:pedalduo/chat/chat_screen.dart';
import 'package:pedalduo/utils/app_utils.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../models/all_players_models.dart';
import '../providers/all_players_provider.dart';
import '../services/shared_preference_service.dart';
import '../style/colors.dart';
import '../style/fonts_sizes.dart';
import '../style/texts.dart';

class AllPlayers extends StatefulWidget {
  const AllPlayers({super.key});

  @override
  State<AllPlayers> createState() => _AllPlayersState();
}

class _AllPlayersState extends State<AllPlayers> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load players when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AllPlayersProvider>().loadPlayers();
    });
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<AllPlayersProvider>().filterPlayers(_searchController.text);
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<AllPlayersProvider>().clearSearch();
  }

  // Create skeleton card for loading state
  Widget _buildSkeletonCard(double screenWidth, double screenHeight) {
    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.015),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: EdgeInsets.all(screenWidth * 0.04),
            decoration: BoxDecoration(
              color: AppColors.glassColor,
              borderRadius: BorderRadius.circular(screenWidth * 0.03),
              border: Border.all(color: AppColors.glassBorderColor, width: 1),
            ),
            child: Row(
              children: [
                // Avatar skeleton
                Container(
                  width: screenWidth * 0.12,
                  height: screenWidth * 0.12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.glassBorderColor.withOpacity(0.3),
                  ),
                ),
                SizedBox(width: screenWidth * 0.03),

                // Info skeleton
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name skeleton
                      Container(
                        width: screenWidth * 0.4,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.glassBorderColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      // Tournament info skeleton
                      Container(
                        width: screenWidth * 0.35,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.glassBorderColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),

                // Button skeleton
                Container(
                  width: screenWidth * 0.2,
                  height: screenHeight * 0.04,
                  decoration: BoxDecoration(
                    color: AppColors.glassBorderColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.darkPrimaryColor,
      appBar: AppBar(
        title: Text(
          'Add Players',
          style: AppTexts.emphasizedTextStyle(
            context: context,
            textColor: AppColors.textPrimaryColor,
            fontSize: AppFontSizes(context).size18,
          ),
        ),
        backgroundColor: AppColors.darkSecondaryColor,
        foregroundColor: AppColors.textPrimaryColor,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.darkSecondaryColor,
                AppColors.darkTertiaryColor,
              ],
            ),
          ),
        ),
      ),
      body: Consumer<AllPlayersProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Search Header with glass effect - Skeleton when loading
              Container(
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.darkSecondaryColor,
                      AppColors.darkPrimaryColor,
                    ],
                  ),
                ),
                child: Skeletonizer(
                  enabled: provider.isLoading,
                  enableSwitchAnimation: true,
                  effect: ShimmerEffect(
                    baseColor: AppColors.glassColor,
                    highlightColor: AppColors.glassBorderColor.withOpacity(0.6),
                    duration: const Duration(milliseconds: 1200),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.glassColor,
                          borderRadius: BorderRadius.circular(
                            screenWidth * 0.03,
                          ),
                          border: Border.all(
                            color: AppColors.glassBorderColor,
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: _searchController,
                          enabled: !provider.isLoading,
                          decoration: InputDecoration(
                            hintText:
                                'Search players by name, email or phone (+92)',
                            hintStyle: AppTexts.bodyTextStyle(
                              context: context,
                              textColor: AppColors.textTertiaryColor,
                              fontSize: AppFontSizes(context).size14,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: AppColors.primaryColor,
                              size: screenWidth * 0.05,
                            ),
                            suffixIcon:
                                provider.isSearching
                                    ? IconButton(
                                      icon: Icon(
                                        Icons.clear,
                                        color: AppColors.textSecondaryColor,
                                      ),
                                      onPressed: _clearSearch,
                                    )
                                    : null,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04,
                              vertical: screenHeight * 0.015,
                            ),
                          ),
                          style: AppTexts.bodyTextStyle(
                            context: context,
                            textColor: AppColors.textPrimaryColor,
                            fontSize: AppFontSizes(context).size14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Players List with Skeletonizer
              Expanded(
                child: _buildPlayersList(provider, screenWidth, screenHeight),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlayersList(
    AllPlayersProvider provider,
    double screenWidth,
    double screenHeight,
  ) {
    // Show skeleton loading
    if (provider.isLoading) {
      return Skeletonizer(
        enabled: true,
        enableSwitchAnimation: true,
        effect: ShimmerEffect(
          baseColor: AppColors.glassColor,
          highlightColor: AppColors.glassBorderColor.withOpacity(0.6),
          duration: const Duration(milliseconds: 1200),
        ),
        child: ListView.builder(
          padding: EdgeInsets.all(screenWidth * 0.04),
          itemCount: 8, // Show 8 skeleton cards
          itemBuilder: (context, index) {
            return _buildSkeletonCard(screenWidth, screenHeight);
          },
        ),
      );
    }

    // Empty state
    if (provider.filteredPlayers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: screenWidth * 0.15,
              color: AppColors.textTertiaryColor,
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              provider.isSearching
                  ? 'No players found'
                  : 'No players available',
              style: AppTexts.bodyTextStyle(
                context: context,
                textColor: AppColors.textSecondaryColor,
                fontSize: AppFontSizes(context).size16,
              ),
            ),
            if (!provider.isSearching) ...[
              SizedBox(height: screenHeight * 0.02),
              ClipRRect(
                borderRadius: BorderRadius.circular(screenWidth * 0.02),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryColor,
                          AppColors.primaryLightColor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      border: Border.all(
                        color: AppColors.glassBorderColor,
                        width: 1,
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        provider.refresh();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: AppColors.textPrimaryColor,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            screenWidth * 0.02,
                          ),
                        ),
                      ),
                      child: Text(
                        'Refresh',
                        style: AppTexts.bodyTextStyle(
                          context: context,
                          textColor: AppColors.textPrimaryColor,
                          fontSize: AppFontSizes(context).size14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    // Players list with pull-to-refresh
    return RefreshIndicator(
      onRefresh: provider.refresh,
      color: AppColors.primaryColor,
      backgroundColor: AppColors.darkSecondaryColor,
      child: ListView.builder(
        padding: EdgeInsets.all(screenWidth * 0.04),
        itemCount: provider.filteredPlayers.length,
        itemBuilder: (context, index) {
          final player = provider.filteredPlayers[index];
          return _buildPlayerCard(player, screenWidth, screenHeight);
        },
      ),
    );
  }

  Widget _buildPlayerCard(
    AllPlayersModel player,
    double screenWidth,
    double screenHeight,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.015),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: EdgeInsets.all(screenWidth * 0.04),
            decoration: BoxDecoration(
              color: AppColors.glassColor,
              borderRadius: BorderRadius.circular(screenWidth * 0.03),
              border: Border.all(color: AppColors.glassBorderColor, width: 1),
            ),
            child: Row(
              children: [
                // Player Avatar
                Container(
                  width: screenWidth * 0.12,
                  height: screenWidth * 0.12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.accentBlueColor,
                        AppColors.accentPurpleColor,
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.person,
                    color: AppColors.textPrimaryColor,
                    size: screenWidth * 0.06,
                  ),
                ),
                SizedBox(width: screenWidth * 0.03),

                // Player Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player.name,
                        style: AppTexts.emphasizedTextStyle(
                          context: context,
                          textColor: AppColors.textPrimaryColor,
                          fontSize: AppFontSizes(context).size16,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.005),

                      Row(
                        children: [
                          Icon(
                            Icons.emoji_events,
                            color: AppColors.warningColor,
                            size: screenWidth * 0.035,
                          ),
                          SizedBox(width: screenWidth * 0.01),
                          Text(
                            '${player.totalTournaments} tournaments',
                            style: AppTexts.bodyTextStyle(
                              context: context,
                              textColor: AppColors.warningColor,
                              fontSize: AppFontSizes(context).size12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Message Button with glass effect
                Consumer<AllPlayersProvider>(
                  builder: (context, provider, child) {
                    final isCreatingChatWithThisUser =
                        provider.creatingChatWithUser == player.id.toString();

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryColor,
                              AppColors.primaryLightColor,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(
                            screenWidth * 0.02,
                          ),
                          border: Border.all(
                            color: AppColors.glassBorderColor,
                            width: 1,
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed:
                              provider.isCreatingChat
                                  ? null
                                  : () async {
                                    final provider =
                                        context.read<AllPlayersProvider>();

                                    // Check if chat room exists
                                    final result = await provider
                                        .checkDirectChatRoom(player.id);

                                    if (result == null) {
                                      // Error occurred
                                      _showErrorMessage(
                                        provider.error ??
                                            'Failed to check chat room',
                                      );
                                      provider.clearError();
                                      return;
                                    }

                                    if (result['exists'] == true) {
                                      // Chat room exists - show snackbar and pop
                                      AppUtils.showInfoSnackBar(
                                        context,
                                        'The chat with this user already exists',
                                      );
                                      Navigator.pop(context);
                                    } else {
                                      // Room doesn't exist - create new chat screen
                                      final currentUser =
                                          await SharedPreferencesService.getUserData();

                                      final participants = [
                                        Participant(
                                          id: 0,
                                          chatRoomId: 0,
                                          userId: player.id,
                                          role: 'member',
                                          joinedAt: DateTime.now(),
                                          lastReadMessageId: null,
                                          lastReadAt: null,
                                          isMuted: false,
                                          isActive: true,
                                          createdAt: DateTime.now(),
                                          updatedAt: DateTime.now(),
                                          user: User(
                                            id: player.id,
                                            name: player.name,
                                            email: player.email,
                                          ),
                                        ),
                                        Participant(
                                          id: 1,
                                          chatRoomId: 0,
                                          userId: currentUser!.id,
                                          role: 'member',
                                          joinedAt: DateTime.now(),
                                          lastReadMessageId: null,
                                          lastReadAt: null,
                                          isMuted: false,
                                          isActive: true,
                                          createdAt: DateTime.now(),
                                          updatedAt: DateTime.now(),
                                          user: User(
                                            id: currentUser.id,
                                            name: currentUser.name,
                                            email: currentUser.email,
                                          ),
                                        ),
                                      ];

                                      Navigator.pushReplacement(
                                        context,
                                        CupertinoPageRoute(
                                          builder:
                                              (_) => ChatScreen(
                                                chatRoom: ChatRoom(
                                                  id: 0,
                                                  name: "Direct Message",
                                                  type: "direct",
                                                  createdBy: currentUser.id,
                                                  isActive: true,
                                                  lastActivity: DateTime.now(),
                                                  participantCount: 2,
                                                  createdAt: DateTime.now(),
                                                  updatedAt: DateTime.now(),
                                                  participants: participants,
                                                  creator: User(
                                                    id: currentUser.id,
                                                    name: currentUser.name,
                                                    email: currentUser.email,
                                                  ),
                                                ),
                                                name: player.name,
                                                id: player.id,
                                              ),
                                        ),
                                      );
                                    }
                                  },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: AppColors.textPrimaryColor,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04,
                              vertical: screenHeight * 0.01,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                screenWidth * 0.02,
                              ),
                            ),
                          ),
                          child:
                              isCreatingChatWithThisUser
                                  ? SizedBox(
                                    width: screenWidth * 0.04,
                                    height: screenWidth * 0.04,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.textPrimaryColor,
                                      ),
                                    ),
                                  )
                                  : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        CupertinoIcons.bubble_left_fill,
                                        size: screenWidth * 0.04,
                                      ),
                                      SizedBox(width: screenWidth * 0.01),
                                      Text(
                                        'Message',
                                        style: AppTexts.bodyTextStyle(
                                          context: context,
                                          textColor: AppColors.textPrimaryColor,
                                          fontSize:
                                              AppFontSizes(context).size12,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: AppColors.textPrimaryColor),
        ),
        backgroundColor: AppColors.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
