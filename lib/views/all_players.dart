import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../chat/chat_room_provider.dart';
import '../chat/chat_rooms_screen.dart';
import '../models/all_players_models.dart';
import '../providers/add_players_provider.dart';
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
      context.read<AddPlayersProvider>().loadPlayers();
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
    context.read<AddPlayersProvider>().filterPlayers(_searchController.text);
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<AddPlayersProvider>().clearSearch();
  }

  Future<void> _onMessageTap(AllPlayersModel player) async {
    final provider = context.read<AddPlayersProvider>();

    // Show loading dialog
    _showCreatingChatDialog(player.name);

    // Create chat with user
    final success = await provider.createChatWithUser(player.id, player.name);

    // Hide loading dialog
    if (mounted) {
      Navigator.of(context).pop();
    }

    if (success) {
      // Success - navigate to chat screen
      if (mounted) {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => ChatRoomsScreen(refresh: true,)));
      
      }
    } else {
      // Show error message
      if (mounted) {
        _showErrorMessage('Failed to create chat with ${player.name}');
      }
    }
  }

  void _showCreatingChatDialog(String userName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;

        return Dialog(
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(screenWidth * 0.04),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: EdgeInsets.all(screenWidth * 0.06),
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
                    // Loading indicator
                    Container(
                      width: screenWidth * 0.15,
                      height: screenWidth * 0.15,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryColor,
                            AppColors.primaryLightColor,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(screenWidth * 0.075),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.textPrimaryColor,
                          ),
                          strokeWidth: 3,
                        ),
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.04),

                    // Title
                    Text(
                      'Creating Chat',
                      style: AppTexts.emphasizedTextStyle(
                        context: context,
                        textColor: AppColors.textPrimaryColor,
                        fontSize: AppFontSizes(context).size18,
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.02),

                    // Subtitle
                    Text(
                      'Starting conversation with $userName...',
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
            ),
          ),
        );
      },
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
      body: Consumer<AddPlayersProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Search Header with glass effect
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.glassColor,
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        border: Border.all(
                          color: AppColors.glassBorderColor,
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search players by name, email, or phone',
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
                          suffixIcon: provider.isSearching
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

              // Players List
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
      AddPlayersProvider provider,
      double screenWidth,
      double screenHeight,
      ) {
    if (provider.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
        ),
      );
    }

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
                          borderRadius: BorderRadius.circular(screenWidth * 0.02),
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
              border: Border.all(
                color: AppColors.glassBorderColor,
                width: 1,
              ),
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
                            Icons.email,
                            color: AppColors.textTertiaryColor,
                            size: screenWidth * 0.035,
                          ),
                          SizedBox(width: screenWidth * 0.01),
                          Expanded(
                            child: Text(
                              player.email,
                              style: AppTexts.bodyTextStyle(
                                context: context,
                                textColor: AppColors.textSecondaryColor,
                                fontSize: AppFontSizes(context).size12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.003),
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            color: AppColors.textTertiaryColor,
                            size: screenWidth * 0.035,
                          ),
                          SizedBox(width: screenWidth * 0.01),
                          Text(
                            player.phone,
                            style: AppTexts.bodyTextStyle(
                              context: context,
                              textColor: AppColors.textSecondaryColor,
                              fontSize: AppFontSizes(context).size12,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.003),
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
                Consumer<AddPlayersProvider>(
                  builder: (context, provider, child) {
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
                          borderRadius: BorderRadius.circular(screenWidth * 0.02),
                          border: Border.all(
                            color: AppColors.glassBorderColor,
                            width: 1,
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: provider.isCreatingChat
                              ? null
                              : () => _onMessageTap(player),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: AppColors.textPrimaryColor,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04,
                              vertical: screenHeight * 0.01,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(screenWidth * 0.02),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [

                                Icon(
                                  CupertinoIcons.bubble_left_fill,
                                  size: screenWidth * 0.04,
                                ),
                              SizedBox(width: screenWidth * 0.01),
                              Text( 'Message',
                                style: AppTexts.bodyTextStyle(
                                  context: context,
                                  textColor: AppColors.textPrimaryColor,
                                  fontSize: AppFontSizes(context).size12,
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