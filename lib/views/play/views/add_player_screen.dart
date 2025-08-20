import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../models/all_players_models.dart';
import '../../../providers/team_add_players_provider.dart';
import '../../../style/colors.dart';
import '../../../style/fonts_sizes.dart';
import '../../../style/texts.dart';
import '../../../utils/beautiful_snackbar.dart';
import '../providers/team_provider.dart';

class AddPlayersScreen extends StatefulWidget {
  final String teamId;
  final String baseUrl;

  const AddPlayersScreen({
    super.key,
    required this.teamId,
    required this.baseUrl,
  });

  @override
  State<AddPlayersScreen> createState() => _AddPlayersScreenState();
}

class _AddPlayersScreenState extends State<AddPlayersScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load players when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeamAddPlayersProvider>().loadPlayers();
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
    context.read<TeamAddPlayersProvider>().filterPlayers(_searchController.text);
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<TeamAddPlayersProvider>().clearSearch();
  }

  Future<void> _handleAddPlayer(int playerId) async {
    final provider = context.read<TeamAddPlayersProvider>();

    final success = await provider.addPlayerToTeam(
        playerId,
        widget.teamId,
        widget.baseUrl
    );

    if (mounted) {
      if (success) {
        _showSuccessMessage('Player invited successfully!');
      } else {
        _showErrorMessage(provider.error ?? 'Failed to invite player');
        provider.clearError();
      }
    }
  }

  Future<void> _handleCopyInviteLink(
      BuildContext context,
      TeamProvider teamProvider,
      ) async {
    // Show loading with beautiful top snackbar
    if (context.mounted) {
      BeautifulSnackBar.showTopSnackBar(
        context: context,
        message: 'Generating Invite Link...',
        subtitle: 'Please wait while we prepare your invite link',
        icon: Icons.hourglass_empty,
        backgroundColor: AppColors.orangeColor,
        iconColor: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }

    // Call the provider method to handle copy and share
    final success = await teamProvider.handleCopyInviteLink(widget.teamId);

    if (context.mounted) {
      if (success) {
        // Show beautiful success snackbar from top
        BeautifulSnackBar.showInviteLinkSuccess(context);
      } else {
        // Show beautiful error snackbar from top
        BeautifulSnackBar.showError(
          context,
          teamProvider.error ?? 'Unable to generate invite link',
        );
      }
    }
  }

  // Create skeleton containers for loading
  Widget _buildSkeletonCard(double screenWidth, double screenHeight) {
    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.015),
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          color: AppColors.glassColor,
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
          border: Border.all(color: AppColors.glassBorderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
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
                  SizedBox(height: screenHeight * 0.01),
                  // Tournament skeleton
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
              width: screenWidth * 0.18,
              height: screenHeight * 0.04,
              decoration: BoxDecoration(
                color: AppColors.glassBorderColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(screenWidth * 0.03),
              ),
            ),
          ],
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
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(CupertinoIcons.back)),
        title: Text(
          'Invite Players',
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
              colors: AppColors.primaryGradient.cast<Color>(),
            ),
          ),
        ),
      ),
      body: Consumer<TeamAddPlayersProvider>(
        builder: (context, provider, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.darkSecondaryColor,
                  AppColors.darkPrimaryColor,
                  AppColors.darkTertiaryColor,
                ],
              ),
            ),
            child: Column(
              children: [
                // Copy Invitation Link Button - Skeleton when loading
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: Skeletonizer(
                    enabled: provider.isLoading,
                    enableSwitchAnimation: true,
                    effect: ShimmerEffect(
                      baseColor: AppColors.glassColor,
                      highlightColor: AppColors.glassBorderColor.withOpacity(0.6),
                      duration: const Duration(milliseconds: 1200),
                    ),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.accentBlueColor,
                            AppColors.accentPurpleColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(screenWidth * 0.04),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentBlueColor.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Consumer<TeamProvider>(
                        builder: (BuildContext context, TeamProvider teamProvider, Widget? child) {
                          return ElevatedButton(
                            onPressed: provider.isLoading ? null : () {
                              _handleCopyInviteLink(context, teamProvider);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: AppColors.textPrimaryColor,
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.05,
                                vertical: screenHeight * 0.018,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(screenWidth * 0.04),
                              ),
                              elevation: 0,
                              shadowColor: Colors.transparent,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(screenWidth * 0.02),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.link,
                                    size: screenWidth * 0.05,
                                    color: AppColors.textPrimaryColor,
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.03),
                                Text(
                                  'Copy Invitation Link',
                                  style: AppTexts.bodyTextStyle(
                                    context: context,
                                    textColor: AppColors.textPrimaryColor,
                                    fontSize: AppFontSizes(context).size16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                Icon(
                                  Icons.copy,
                                  size: screenWidth * 0.04,
                                  color: AppColors.textPrimaryColor.withOpacity(0.8),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // Search Header with Glass Effect - Skeleton when loading
                Container(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: Skeletonizer(
                    enabled: provider.isLoading,
                    enableSwitchAnimation: true,
                    effect: ShimmerEffect(
                      baseColor: AppColors.glassColor,
                      highlightColor: AppColors.glassBorderColor.withOpacity(0.6),
                      duration: const Duration(milliseconds: 1200),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.glassColor,
                        borderRadius: BorderRadius.circular(screenWidth * 0.04),
                        border: Border.all(
                          color: AppColors.glassBorderColor,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        enabled: !provider.isLoading,
                        decoration: InputDecoration(
                          hintText: 'Search players by name, email or phone (+92)',
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

                SizedBox(height: screenHeight * 0.02),

                // Players List with Skeleton Loading
                Expanded(
                  child: _buildPlayersList(provider, screenWidth, screenHeight),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlayersList(
      TeamAddPlayersProvider provider,
      double screenWidth,
      double screenHeight,
      ) {
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
          itemCount: 8,
          itemBuilder: (context, index) {
            return _buildSkeletonCard(screenWidth, screenHeight);
          },
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
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryColor,
                      AppColors.primaryLightColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                ),
                child: ElevatedButton(
                  onPressed: provider.refresh,
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
          return _buildPlayerCard(player, screenWidth, screenHeight, provider);
        },
      ),
    );
  }

  Widget _buildPlayerCard(
      TeamAddPlayersModel player,
      double screenWidth,
      double screenHeight,
      TeamAddPlayersProvider provider,
      ) {
    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.015),
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          color: AppColors.glassColor,
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
          border: Border.all(color: AppColors.glassBorderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Player Avatar with Gradient
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
                border: Border.all(color: AppColors.glassBorderColor, width: 2),
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
                  SizedBox(height: screenHeight * 0.003),
                  Row(
                    children: [
                      Icon(
                        Icons.emoji_events,
                        color: AppColors.primaryColor,
                        size: screenWidth * 0.035,
                      ),
                      SizedBox(width: screenWidth * 0.01),
                      Text(
                        '${player.totalTournaments} tournaments',
                        style: AppTexts.bodyTextStyle(
                          context: context,
                          textColor: AppColors.primaryColor,
                          fontSize: AppFontSizes(context).size12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Add Button with Glass Effect
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryColor, AppColors.primaryLightColor],
                ),
                borderRadius: BorderRadius.circular(screenWidth * 0.03),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: provider.addingPlayerId != null
                    ? null
                    : () => _handleAddPlayer(player.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: AppColors.textPrimaryColor,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenHeight * 0.01,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                child: provider.addingPlayerId == player.id
                    ? SpinKitCircle(
                    color: AppColors.whiteColor,
                    size: screenWidth * 0.05
                )
                    : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Invite',
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
          ],
        ),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: AppColors.textPrimaryColor),
        ),
        backgroundColor: AppColors.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }
}