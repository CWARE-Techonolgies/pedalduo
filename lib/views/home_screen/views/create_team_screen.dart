// screens/club_team_screen.dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pedalduo/global/apis.dart';
import 'package:pedalduo/views/play/views/add_player_screen.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../models/club_team_member_model.dart';
import '../../../providers/create_team_provider.dart';
import '../../../style/colors.dart';
import '../../../style/fonts_sizes.dart';
import '../../../style/texts.dart';
import '../../play/models/tournaments_model.dart';
import '../../play/providers/user_profile_provider.dart';

class CreateTeamScreen extends StatefulWidget {
  const CreateTeamScreen({super.key});

  @override
  State<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

String _originalEmail = '';

class _CreateTeamScreenState extends State<CreateTeamScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CreateTeamProvider>(context, listen: false).initialize();
      final provider = Provider.of<UserProfileProvider>(context, listen: false);
      provider.loadUserProfile().then((_) {
        provider.resetImageDeletionState();
        if (provider.user != null) {
          _originalEmail = provider.user!.email;
        }
      });
      print('the email of current user is $_originalEmail');
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CreateTeamProvider>(
      builder: (context, teamProvider, child) {
        // Show error/success messages
        if (teamProvider.errorMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showMessage(context, teamProvider.errorMessage ?? '', false);
            teamProvider.clearMessages();
          });
        }

        if (teamProvider.successMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showMessage(context, teamProvider.successMessage ?? '', true);
            teamProvider.clearMessages();
          });
        }

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.navyBlueGrey, AppColors.lightNavyBlueGrey],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(context),

                // Tab Bar
                // _buildTabBar(context),

                // Tab Views
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildMyTeamsTab(context, teamProvider),
                      // _buildPublicTeamsTab(context, teamProvider),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Consumer<CreateTeamProvider>(
      builder: (context, teamProvider, child) {
        // Check if user has created or joined any team
        final hasCreatedTeam = teamProvider.myTeams.any(
              (team) => team.captain?.email == _originalEmail,
        );

        final hasJoinedTeam = teamProvider.myTeams.any(
              (team) => team.members.any(
                (member) => member.email == _originalEmail,
          ),
        );

        final shouldHideButton = hasCreatedTeam || hasJoinedTeam;

        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Team',
                style: AppTexts.headingStyle(
                  context: context,
                  textColor: AppColors.whiteColor,
                  fontSize: AppFontSizes(context).size32,
                ),
              ),
              // Only show create button if user hasn't created or joined a team
              if (!shouldHideButton) _buildCreateButton(context),
            ],
          ),
        );
      },
    );
  }



  Widget _buildCreateButton(BuildContext context) {
    return Consumer<CreateTeamProvider>(
      builder: (context, teamProvider, child) {
        return GestureDetector(
          onTap:
              teamProvider.isCreatingTeam
                  ? null
                  : () => _showCreateTeamDialog(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.orangeColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.orangeColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (teamProvider.isCreatingTeam)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: SpinKitCircle(color: AppColors.whiteColor, size: 18),
                  )
                else
                  const Icon(Icons.add, color: AppColors.whiteColor, size: 18),
                const SizedBox(width: 6),
                Text(
                  teamProvider.isCreatingTeam ? 'Creating...' : 'Create Team',
                  style: AppTexts.emphasizedTextStyle(
                    context: context,
                    textColor: AppColors.whiteColor,
                    fontSize: AppFontSizes(context).size14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMyTeamsTab(
    BuildContext context,
    CreateTeamProvider teamProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Skeletonizer(
        enabled: teamProvider.isLoading,
        child:
            teamProvider.hasTeams
                ? _buildTeamsList(context, teamProvider.myTeams, isMyTeam: true)
                : _buildEmptyState(context),
      ),
    );
  }

  Widget _buildPublicTeamsTab(
    BuildContext context,
    CreateTeamProvider teamProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: RefreshIndicator(
        onRefresh: () => teamProvider.fetchPublicTeams(),
        backgroundColor: AppColors.navyBlueGrey,
        color: AppColors.orangeColor,
        child: Skeletonizer(
          enabled: teamProvider.isLoading,
          child:
              teamProvider.publicTeams.isNotEmpty
                  ? _buildTeamsList(
                    context,
                    teamProvider.publicTeams,
                    isMyTeam: false,
                  )
                  : _buildEmptyPublicTeamsState(context),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Team icon with glassmorphic effect
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(60),
                border: Border.all(
                  color: AppColors.whiteColor.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: const Icon(
                      Icons.groups,
                      size: 60,
                      color: AppColors.greyColor,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'No Teams Created Yet',
              style: AppTexts.headingStyle(
                context: context,
                textColor: AppColors.whiteColor,
                fontSize: AppFontSizes(context).size20,
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Create your first team to start playing matches and tournaments with your friends!',
                style: AppTexts.bodyTextStyle(
                  context: context,
                  textColor: AppColors.greyColor,
                  fontSize: AppFontSizes(context).size16,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 32),

            Consumer<CreateTeamProvider>(
              builder: (context, teamProvider, child) {
                return GestureDetector(
                  onTap:
                      teamProvider.isCreatingTeam
                          ? null
                          : () => _showCreateTeamDialog(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.orangeColor,
                          AppColors.orangeColor.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.orangeColor.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (teamProvider.isCreatingTeam)
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: SpinKitCircle(
                              color: AppColors.whiteColor,
                              size: 24,
                            ),
                          )
                        else
                          const Icon(
                            Icons.add_circle_outline,
                            color: AppColors.whiteColor,
                            size: 24,
                          ),
                        const SizedBox(width: 12),
                        Text(
                          teamProvider.isCreatingTeam
                              ? 'Creating Team...'
                              : 'Create Your First Team',
                          style: AppTexts.emphasizedTextStyle(
                            context: context,
                            textColor: AppColors.whiteColor,
                            fontSize: AppFontSizes(context).size16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPublicTeamsState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(60),
                border: Border.all(
                  color: AppColors.whiteColor.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: const Icon(
                      Icons.public,
                      size: 60,
                      color: AppColors.greyColor,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'No Public Teams Available',
              style: AppTexts.headingStyle(
                context: context,
                textColor: AppColors.whiteColor,
                fontSize: AppFontSizes(context).size20,
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'There are no public teams available to join at the moment. Create your own team and make it public!',
                style: AppTexts.bodyTextStyle(
                  context: context,
                  textColor: AppColors.greyColor,
                  fontSize: AppFontSizes(context).size16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamsList(
    BuildContext context,
    List<ClubTeam> teams, {
    required bool isMyTeam,
  }) {
    if (teams.isEmpty) {
      return isMyTeam
          ? _buildEmptyState(context)
          : _buildEmptyPublicTeamsState(context);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      itemCount: teams.length,
      itemBuilder: (context, index) {
        final team = teams[index];
        return _buildTeamCard(context, team, isMyTeam: isMyTeam);
      },
    );
  }

  Widget _buildTeamCard(
    BuildContext context,
    ClubTeam team, {
    required bool isMyTeam,
  }) {
    return Consumer<CreateTeamProvider>(
      builder: (context, teamProvider, child) {
        final isLoading = teamProvider.isTeamActionLoading(team.id);

        return Container(
          margin: const EdgeInsets.only(bottom: 16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.whiteColor.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Team Avatar
                        // Team Avatar
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child:
                          // team.avatar != null
                          //     ? ClipRRect(
                          //   borderRadius: BorderRadius.circular(25),
                          //   child: Image.memory(
                          //     _decodeBase64Image(team.avatar!),
                          //     width: 50,
                          //     height: 50,
                          //     fit: BoxFit.cover,
                          //   ),
                          // )
                          //     :
                          CircleAvatar(
                            backgroundColor: AppColors.orangeColor.withOpacity(
                              0.2,
                            ),
                            child: Text(
                              team.name.isNotEmpty
                                  ? team.name[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: AppColors.orangeColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Team Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      team.name,
                                      style: AppTexts.emphasizedTextStyle(
                                        context: context,
                                        textColor: AppColors.whiteColor,
                                        fontSize: AppFontSizes(context).size16,
                                      ),
                                    ),
                                  ),
                                  if (!team.isPrivate)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.greenColor.withOpacity(
                                          0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Public',
                                        style: AppTexts.bodyTextStyle(
                                          context: context,
                                          textColor: AppColors.greenColor,
                                          fontSize:
                                              AppFontSizes(context).size10,
                                        ),
                                      ),
                                    )
                                  else
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.orangeColor
                                            .withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Private',
                                        style: AppTexts.bodyTextStyle(
                                          context: context,
                                          textColor: AppColors.orangeColor,
                                          fontSize:
                                              AppFontSizes(context).size10,
                                        ),
                                      ),
                                    ),
                                ],
                              ),

                              const SizedBox(height: 4),

                              Text(
                                '${team.totalMembers}/${team.maxMembers} members • ${team.formattedCreatedDate}',
                                style: AppTexts.bodyTextStyle(
                                  context: context,
                                  textColor: AppColors.greyColor,
                                  fontSize: AppFontSizes(context).size12,
                                ),
                              ),

                              const SizedBox(height: 4),

                              if (team.captain != null)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: AppColors.goldColor,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Captain: ${team.captain!.name}',
                                      style: AppTexts.bodyTextStyle(
                                        context: context,
                                        textColor: AppColors.greyColor,
                                        fontSize: AppFontSizes(context).size11,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),

                        // Action buttons
                        if (isMyTeam)
                          IconButton(
                            onPressed: () => _showMyTeamOptions(context, team),
                            icon: const Icon(
                              Icons.more_vert,
                              color: AppColors.greyColor,
                              size: 20,
                            ),
                          )
                        else
                          _buildJoinButton(context, team, isLoading),
                      ],
                    ),

                    // Tournament Registration Button for My Teams
                    // In _buildTeamCard method, replace the tournament registration section:
                    if (isMyTeam &&
                        team.captain != null &&
                        _originalEmail == team.captain!.email)
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        child:
                            team.isRegisteredForTournament
                                ? _buildTournamentStatusCard(context, team)
                                : _buildTournamentRegistrationButton(
                                  context,
                                  team,
                                ),
                      ),

                    // If not captain but team is registered, show status card
                    if (isMyTeam &&
                        team.isRegisteredForTournament &&
                        _originalEmail != team.captain?.email)
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        child: _buildTournamentStatusCard(context, team),
                      ),

                    // Members list (expandable for my teams)
                    if (isMyTeam && team.members.isNotEmpty)
                      _buildMembersList(context, team),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTournamentRegistrationButton(
    BuildContext context,
    ClubTeam team,
  ) {
    return Consumer<CreateTeamProvider>(
      builder: (context, teamProvider, child) {
        return GestureDetector(
          onTap:
              teamProvider.isRegisteringForTournament
                  ? null
                  : () => _showTournamentRegistrationDialog(context, team),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.blueColor.withOpacity(0.8),
                  AppColors.blueColor.withOpacity(0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.blueColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (teamProvider.isRegisteringForTournament)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: SpinKitCircle(color: AppColors.whiteColor, size: 20),
                  )
                else
                  const Icon(
                    Icons.emoji_events,
                    color: AppColors.whiteColor,
                    size: 20,
                  ),
                const SizedBox(width: 8),
                Text(
                  teamProvider.isRegisteringForTournament
                      ? 'Registering...'
                      : 'Register for Tournament',
                  style: AppTexts.emphasizedTextStyle(
                    context: context,
                    textColor: AppColors.whiteColor,
                    fontSize: AppFontSizes(context).size14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTournamentRegistrationDialog(BuildContext context, ClubTeam team) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.navyBlueGrey,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.whiteColor.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      size: 28,
                      color: AppColors.blueColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tournament Registration',
                        style: AppTexts.headingStyle(
                          context: context,
                          textColor: AppColors.whiteColor,
                          fontSize: AppFontSizes(context).size20,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.greyColor,
                        size: 24,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Tournament List
                Expanded(
                  child: Consumer<CreateTeamProvider>(
                    builder: (context, teamProvider, child) {
                      // Fetch tournaments when dialog opens
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (teamProvider.availableTournaments.isEmpty) {
                          teamProvider.fetchAvailableTournaments();
                        }
                      });

                      if (teamProvider.isLoading) {
                        return const Center(
                          child: SpinKitCircle(
                            color: AppColors.orangeColor,
                            size: 50,
                          ),
                        );
                      }

                      if (teamProvider.availableTournaments.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.emoji_events_outlined,
                                size: 60,
                                color: AppColors.greyColor,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No Tournaments Available',
                                style: AppTexts.headingStyle(
                                  context: context,
                                  textColor: AppColors.whiteColor,
                                  fontSize: AppFontSizes(context).size18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'There are no active tournaments available for registration at the moment.',
                                style: AppTexts.bodyTextStyle(
                                  context: context,
                                  textColor: AppColors.greyColor,
                                  fontSize: AppFontSizes(context).size14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: teamProvider.availableTournaments.length,
                        itemBuilder: (context, index) {
                          final tournament =
                              teamProvider.availableTournaments[index];
                          return _buildTournamentCard(
                            context,
                            tournament,
                            team,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Enhanced Tournament Card with animations and better UX
  Widget _buildTournamentCard(
      BuildContext context,
      Tournament tournament,
      ClubTeam team,
      ) {
    final canRegister = team.totalMembers >= tournament.playersPerTeam;
    final registrationOpen = DateTime.now().isBefore(
      tournament.registrationEndDate,
    );
    final isEligible = canRegister && registrationOpen;
    final playersNeeded = tournament.playersPerTeam - team.totalMembers;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEligible
              ? AppColors.blueColor.withOpacity(0.3)
              : AppColors.greyColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isEligible
                  ? AppColors.blueColor.withOpacity(0.05)
                  : AppColors.greyColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tournament Header
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.blueColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.emoji_events,
                        color: AppColors.blueColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tournament.title,
                            style: AppTexts.emphasizedTextStyle(
                              context: context,
                              textColor: AppColors.whiteColor,
                              fontSize: AppFontSizes(context).size16,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            tournament.location,
                            style: AppTexts.bodyTextStyle(
                              context: context,
                              textColor: AppColors.greyColor,
                              fontSize: AppFontSizes(context).size12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: tournament.gender.toLowerCase() == 'male'
                            ? AppColors.blueColor.withOpacity(0.2)
                            : tournament.gender.toLowerCase() == 'female'
                            ? AppColors.pinkColor.withOpacity(0.2)
                            : AppColors.purpleColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tournament.gender.toUpperCase(),
                        style: AppTexts.bodyTextStyle(
                          context: context,
                          textColor: tournament.gender.toLowerCase() == 'male'
                              ? AppColors.blueColor
                              : tournament.gender.toLowerCase() == 'female'
                              ? AppColors.pinkColor
                              : AppColors.purpleColor,
                          fontSize: AppFontSizes(context).size10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Tournament Details
                Row(
                  children: [
                    Expanded(
                      child: _buildTournamentDetailItem(
                        context,
                        Icons.people,
                        'Players per Team',
                        '${tournament.playersPerTeam}',
                      ),
                    ),
                    Expanded(
                      child: _buildTournamentDetailItem(
                        context,
                        Icons.groups,
                        'Teams',
                        '${tournament.registeredTeams}/${tournament.maxTeams}',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildTournamentDetailItem(
                        context,
                        Icons.monetization_on,
                        'Prize Pool',
                        '\$${tournament.totalPrizePool}',
                      ),
                    ),
                    Expanded(
                      child: _buildTournamentDetailItem(
                        context,
                        Icons.calendar_today,
                        'Registration Ends',
                        _formatDate(tournament.registrationEndDate.toString()),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Enhanced Status and Action Section
                if (!canRegister && registrationOpen) ...[
                  // Animated container for insufficient players
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 2000),
                    tween: Tween(begin: 0.95, end: 1.05),
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.orangeColor.withOpacity(0.8),
                                AppColors.orangeColor.withOpacity(0.6),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.orangeColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.person_add,
                                    color: AppColors.whiteColor,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          playersNeeded == 1
                                              ? 'One spot left – who\'s in?'
                                              : 'Almost there! Add $playersNeeded more players.',
                                          style: AppTexts.emphasizedTextStyle(
                                            context: context,
                                            textColor: AppColors.whiteColor,
                                            fontSize: AppFontSizes(context).size14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Invite your friends to complete the squad!',
                                          style: AppTexts.bodyTextStyle(
                                            context: context,
                                            textColor: AppColors.whiteColor.withOpacity(0.8),
                                            fontSize: AppFontSizes(context).size12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (_) => AddPlayersScreen(
                                        teamId: team.id.toString(),
                                        baseUrl: AppApis.baseUrl,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.whiteColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.whiteColor.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.group_add,
                                        color: AppColors.whiteColor,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Invite Players',
                                        style: AppTexts.emphasizedTextStyle(
                                          context: context,
                                          textColor: AppColors.whiteColor,
                                          fontSize: AppFontSizes(context).size14,
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
                    },
                    onEnd: () {
                      // Reverse animation for continuous effect
                      Future.delayed(const Duration(milliseconds: 100), () {
                        if (mounted) {
                          // Trigger rebuild to restart animation
                          setState(() {});
                        }
                      });
                    },
                  ),
                ] else if (!registrationOpen) ...[
                  // Registration closed
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.redColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Registration Closed',
                      style: AppTexts.bodyTextStyle(
                        context: context,
                        textColor: AppColors.redColor,
                        fontSize: AppFontSizes(context).size11,
                      ),
                    ),
                  ),
                ] else ...[
                  // Can register - show register button
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.greenColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Ready to Register!',
                          style: AppTexts.bodyTextStyle(
                            context: context,
                            textColor: AppColors.greenColor,
                            fontSize: AppFontSizes(context).size11,
                          ),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _showPlayerSelectionDialog(context, tournament, team),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.blueColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Register',
                            style: AppTexts.emphasizedTextStyle(
                              context: context,
                              textColor: AppColors.whiteColor,
                              fontSize: AppFontSizes(context).size14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Tournament Detail Item
  Widget _buildTournamentDetailItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, color: AppColors.greyColor, size: 16),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTexts.bodyTextStyle(
                  context: context,
                  textColor: AppColors.greyColor,
                  fontSize: AppFontSizes(context).size10,
                ),
              ),
              Text(
                value,
                style: AppTexts.bodyTextStyle(
                  context: context,
                  textColor: AppColors.whiteColor,
                  fontSize: AppFontSizes(context).size12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Player Selection Dialog
  void _showPlayerSelectionDialog(
    BuildContext context,
    Tournament tournament,
    ClubTeam team,
  ) {
    List<int> selectedPlayerIds = [];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.7,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.navyBlueGrey,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.whiteColor.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    // Header
                    Row(
                      children: [
                        const Icon(
                          Icons.people_alt,
                          size: 28,
                          color: AppColors.blueColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Select Players',
                                style: AppTexts.headingStyle(
                                  context: context,
                                  textColor: AppColors.whiteColor,
                                  fontSize: AppFontSizes(context).size18,
                                ),
                              ),
                              Text(
                                'Choose ${tournament.playersPerTeam} players for ${tournament.title}',
                                style: AppTexts.bodyTextStyle(
                                  context: context,
                                  textColor: AppColors.greyColor,
                                  fontSize: AppFontSizes(context).size12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.greyColor,
                            size: 24,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Selection Counter
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.blueColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.blueColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Selected: ${selectedPlayerIds.length}/${tournament.playersPerTeam} players',
                        style: AppTexts.emphasizedTextStyle(
                          context: context,
                          textColor: AppColors.blueColor,
                          fontSize: AppFontSizes(context).size14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Player List
                    Expanded(
                      child: ListView.builder(
                        itemCount: team.members.length,
                        itemBuilder: (context, index) {
                          final member = team.members[index];
                          final isSelected = selectedPlayerIds.contains(
                            member.id,
                          );
                          final canSelect =
                              selectedPlayerIds.length <
                              tournament.playersPerTeam;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  selectedPlayerIds.remove(member.id);
                                } else if (canSelect) {
                                  selectedPlayerIds.add(member.id);
                                }
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? AppColors.blueColor.withOpacity(0.2)
                                        : AppColors.whiteColor.withOpacity(
                                          0.05,
                                        ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? AppColors.blueColor
                                          : AppColors.whiteColor.withOpacity(
                                            0.1,
                                          ),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color:
                                          member.clubTeamMember?.isCaptain ==
                                                  true
                                              ? AppColors.goldColor.withOpacity(
                                                0.2,
                                              )
                                              : AppColors.blueColor.withOpacity(
                                                0.2,
                                              ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Icon(
                                      member.clubTeamMember?.isCaptain == true
                                          ? Icons.star
                                          : Icons.person,
                                      color:
                                          member.clubTeamMember?.isCaptain ==
                                                  true
                                              ? AppColors.goldColor
                                              : AppColors.blueColor,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          member.name,
                                          style: AppTexts.emphasizedTextStyle(
                                            context: context,
                                            textColor: AppColors.whiteColor,
                                            fontSize:
                                                AppFontSizes(context).size14,
                                          ),
                                        ),
                                        Text(
                                          member.email,
                                          style: AppTexts.bodyTextStyle(
                                            context: context,
                                            textColor: AppColors.greyColor,
                                            fontSize:
                                                AppFontSizes(context).size12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (member.clubTeamMember?.isCaptain == true)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.goldColor.withOpacity(
                                          0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Captain',
                                        style: AppTexts.bodyTextStyle(
                                          context: context,
                                          textColor: AppColors.goldColor,
                                          fontSize:
                                              AppFontSizes(context).size10,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color:
                                          isSelected
                                              ? AppColors.blueColor
                                              : Colors.transparent,
                                      border: Border.all(
                                        color:
                                            isSelected
                                                ? AppColors.blueColor
                                                : AppColors.greyColor,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child:
                                        isSelected
                                            ? const Icon(
                                              Icons.check,
                                              color: AppColors.whiteColor,
                                              size: 16,
                                            )
                                            : null,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Register Button
                    Consumer<CreateTeamProvider>(
                      builder: (context, teamProvider, child) {
                        final canRegister =
                            selectedPlayerIds.length ==
                            tournament.playersPerTeam;

                        return Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.greyColor.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Cancel',
                                    style: AppTexts.emphasizedTextStyle(
                                      context: context,
                                      textColor: AppColors.whiteColor,
                                      fontSize: AppFontSizes(context).size16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap:
                                    canRegister &&
                                            !teamProvider
                                                .isRegisteringForTournament
                                        ? () async {
                                          final success = await teamProvider
                                              .registerTeamForTournament(
                                                teamId: team.id,
                                                tournamentId: tournament.id,
                                                selectedPlayerIds:
                                                    selectedPlayerIds,
                                              );

                                          // ✅ Always close dialogs, success or fail
                                          Navigator.of(
                                            context,
                                          ).pop(); // Close player selection
                                          Navigator.of(
                                            context,
                                          ).pop(); // Close tournament list
                                        }
                                        : null,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        canRegister
                                            ? AppColors.blueColor
                                            : AppColors.greyColor.withOpacity(
                                              0.5,
                                            ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (teamProvider
                                          .isRegisteringForTournament)
                                        const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: SpinKitCircle(
                                            color: AppColors.whiteColor,
                                            size: 20,
                                          ),
                                        )
                                      else
                                        const Icon(
                                          Icons.emoji_events,
                                          color: AppColors.whiteColor,
                                          size: 20,
                                        ),
                                      const SizedBox(width: 8),
                                      Text(
                                        teamProvider.isRegisteringForTournament
                                            ? 'Registering...'
                                            : 'Register Team',
                                        style: AppTexts.emphasizedTextStyle(
                                          context: context,
                                          textColor: AppColors.whiteColor,
                                          fontSize:
                                              AppFontSizes(context).size16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }



  Widget _buildJoinButton(BuildContext context, ClubTeam team, bool isLoading) {
    return Consumer<CreateTeamProvider>(
      builder: (context, teamProvider, child) {
        // Check if current user is already a member of this team
        final isMember = team.members.any(
          (member) => member.email == _originalEmail,
        );

        return GestureDetector(
          onTap:
              isLoading || team.totalMembers >= team.maxMembers || isMember
                  ? null
                  : () => teamProvider.joinTeam(team.id),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color:
                  isMember
                      ? AppColors.blueColor.withOpacity(0.8)
                      : team.totalMembers >= team.maxMembers
                      ? AppColors.greyColor.withOpacity(0.3)
                      : AppColors.greenColor.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: SpinKitCircle(color: AppColors.whiteColor, size: 16),
                  )
                else
                  Icon(
                    isMember
                        ? Icons.check
                        : team.totalMembers >= team.maxMembers
                        ? Icons.block
                        : Icons.add,
                    color: AppColors.whiteColor,
                    size: 16,
                  ),
                const SizedBox(width: 4),
                Text(
                  isLoading
                      ? 'Joining...'
                      : isMember
                      ? 'Joined'
                      : team.totalMembers >= team.maxMembers
                      ? 'Full'
                      : 'Join',
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.whiteColor,
                    fontSize: AppFontSizes(context).size12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTournamentStatusCard(BuildContext context, ClubTeam team) {
    final tournament = team.registeredTournament!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.greenColor.withOpacity(0.8),
            AppColors.greenColor.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.greenColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.emoji_events,
                color: AppColors.whiteColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Registered in Tournament',
                  style: AppTexts.emphasizedTextStyle(
                    context: context,
                    textColor: AppColors.whiteColor,
                    fontSize: AppFontSizes(context).size14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            tournament.title,
            style: AppTexts.emphasizedTextStyle(
              context: context,
              textColor: AppColors.whiteColor,
              fontSize: AppFontSizes(context).size16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${tournament.location} • ${_formatDate(tournament.tournamentStartDate)}',
            style: AppTexts.bodyTextStyle(
              context: context,
              textColor: AppColors.whiteColor.withOpacity(0.8),
              fontSize: AppFontSizes(context).size12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Prize Pool: \$${tournament.totalPrizePool}',
            style: AppTexts.bodyTextStyle(
              context: context,
              textColor: AppColors.whiteColor.withOpacity(0.8),
              fontSize: AppFontSizes(context).size12,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildMembersList(BuildContext context, ClubTeam team) {
    return ExpansionTile(
      title: Text(
        'Team Members (${team.members.length})',
        style: AppTexts.emphasizedTextStyle(
          context: context,
          textColor: AppColors.whiteColor,
          fontSize: AppFontSizes(context).size14,
        ),
      ),
      iconColor: AppColors.orangeColor,
      collapsedIconColor: AppColors.greyColor,
      children:
          team.members.map((member) {
            final isCaptain = member.clubTeamMember?.isCaptain ?? false;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color:
                          isCaptain
                              ? AppColors.goldColor.withOpacity(0.2)
                              : AppColors.blueColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      isCaptain ? Icons.star : Icons.person,
                      color:
                          isCaptain ? AppColors.goldColor : AppColors.blueColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member.name,
                          style: AppTexts.bodyTextStyle(
                            context: context,
                            textColor: AppColors.whiteColor,
                            fontSize: AppFontSizes(context).size14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          member.email,
                          style: AppTexts.bodyTextStyle(
                            context: context,
                            textColor: AppColors.greyColor,
                            fontSize: AppFontSizes(context).size12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isCaptain)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.goldColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Captain',
                        style: AppTexts.bodyTextStyle(
                          context: context,
                          textColor: AppColors.goldColor,
                          fontSize: AppFontSizes(context).size10,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
    );
  }

  void _showCreateTeamDialog(BuildContext context) {
    final nameController = TextEditingController();
    // bool isPrivate = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.navyBlueGrey,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.whiteColor.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.groups,
                          size: 28,
                          color: AppColors.orangeColor,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Create New Team',
                          style: AppTexts.headingStyle(
                            context: context,
                            textColor: AppColors.whiteColor,
                            fontSize: AppFontSizes(context).size20,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Team name input
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.whiteColor.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.whiteColor.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              controller: nameController,
                              style: AppTexts.bodyTextStyle(
                                context: context,
                                textColor: AppColors.whiteColor,
                                fontSize: AppFontSizes(context).size16,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Enter team name',
                                hintStyle: AppTexts.bodyTextStyle(
                                  context: context,
                                  textColor: AppColors.greyColor,
                                  fontSize: AppFontSizes(context).size16,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(16),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // const SizedBox(height: 16),
                    //
                    // // Privacy toggle
                    // Container(
                    //   decoration: BoxDecoration(
                    //     borderRadius: BorderRadius.circular(12),
                    //     border: Border.all(
                    //       color: AppColors.whiteColor.withOpacity(0.1),
                    //       width: 1,
                    //     ),
                    //   ),
                    //   child: ClipRRect(
                    //     borderRadius: BorderRadius.circular(12),
                    //     child: BackdropFilter(
                    //       filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    //       child: Container(
                    //         padding: const EdgeInsets.all(16),
                    //         decoration: BoxDecoration(
                    //           color: AppColors.whiteColor.withOpacity(0.05),
                    //           borderRadius: BorderRadius.circular(12),
                    //         ),
                    //         child: Row(
                    //           children: [
                    //             Icon(
                    //               isPrivate ? Icons.lock : Icons.public,
                    //               color: AppColors.orangeColor,
                    //               size: 20,
                    //             ),
                    //             const SizedBox(width: 12),
                    //             Expanded(
                    //               child: Column(
                    //                 crossAxisAlignment:
                    //                     CrossAxisAlignment.start,
                    //                 children: [
                    //                   Text(
                    //                     isPrivate
                    //                         ? 'Private Team'
                    //                         : 'Public Team',
                    //                     style: AppTexts.emphasizedTextStyle(
                    //                       context: context,
                    //                       textColor: AppColors.whiteColor,
                    //                       fontSize:
                    //                           AppFontSizes(context).size14,
                    //                     ),
                    //                   ),
                    //                   Text(
                    //                     isPrivate
                    //                         ? 'Only invited members can join'
                    //                         : 'Anyone can join this team',
                    //                     style: AppTexts.bodyTextStyle(
                    //                       context: context,
                    //                       textColor: AppColors.greyColor,
                    //                       fontSize:
                    //                           AppFontSizes(context).size12,
                    //                     ),
                    //                   ),
                    //                 ],
                    //               ),
                    //             ),
                    //             Switch(
                    //               value: isPrivate,
                    //               onChanged: (value) {
                    //                 setState(() {
                    //                   isPrivate = value;
                    //                 });
                    //               },
                    //               activeColor: AppColors.orangeColor,
                    //               inactiveThumbColor: AppColors.greyColor,
                    //               inactiveTrackColor: AppColors.greyColor
                    //                   .withOpacity(0.3),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(height: 24),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.greyColor.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Cancel',
                                style: AppTexts.emphasizedTextStyle(
                                  context: context,
                                  textColor: AppColors.whiteColor,
                                  fontSize: AppFontSizes(context).size16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Consumer<CreateTeamProvider>(
                            builder: (context, teamProvider, child) {
                              return GestureDetector(
                                onTap:
                                    teamProvider.isCreatingTeam
                                        ? null
                                        : () async {
                                          if (nameController.text
                                              .trim()
                                              .isEmpty) {
                                            _showMessage(
                                              context,
                                              'Please enter team name',
                                              false,
                                            );
                                            return;
                                          }

                                          final request = CreateTeamRequest(
                                            name: nameController.text.trim(),
                                            isPrivate: true,
                                          );

                                          final success = await teamProvider
                                              .createTeam(request);
                                          if (success && context.mounted) {
                                            Navigator.of(context).pop();
                                          }
                                        },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.orangeColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (teamProvider.isCreatingTeam)
                                        const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: SpinKitCircle(
                                            color: AppColors.whiteColor,
                                            size: 20,
                                          ),
                                        )
                                      else
                                        const Icon(
                                          Icons.add,
                                          color: AppColors.whiteColor,
                                          size: 20,
                                        ),
                                      const SizedBox(width: 8),
                                      Text(
                                        teamProvider.isCreatingTeam
                                            ? 'Creating...'
                                            : 'Create Team',
                                        style: AppTexts.emphasizedTextStyle(
                                          context: context,
                                          textColor: AppColors.whiteColor,
                                          fontSize:
                                              AppFontSizes(context).size16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showMyTeamOptions(BuildContext context, ClubTeam team) {
    final isCaptain = _originalEmail == team.captain?.email;
    final isRegistered = team.isRegisteredForTournament;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.navyBlueGrey,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              border: Border.all(
                color: AppColors.whiteColor.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.greyColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        'Team Options',
                        style: AppTexts.headingStyle(
                          context: context,
                          textColor: AppColors.whiteColor,
                          fontSize: AppFontSizes(context).size18,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // View Details
                      _buildOptionItem(
                        context,
                        icon: Icons.info_outline,
                        title: 'View Details',
                        onTap: () {
                          Navigator.pop(context);
                          _showTeamDetails(context, team);
                        },
                      ),

                      // Captain-only options
                      if (isCaptain) ...[
                        if (!isRegistered) ...[
                          // Transfer Captaincy (only if not registered)
                          _buildOptionItem(
                            context,
                            icon: Icons.swap_horizontal_circle,
                            title: 'Transfer Captaincy',
                            onTap: () {
                              Navigator.pop(context);
                              _showTransferCaptaincyDialog(context, team);
                            },
                          ),

                          _buildOptionItem(
                            context,
                            icon: Icons.group_add,
                            title: 'Invite Players to Team',
                            onTap: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (_) => AddPlayersScreen(
                                    teamId: team.id.toString(),
                                    baseUrl: AppApis.baseUrl,
                                  ),
                                ),
                              );
                            },
                          ),

                          _buildOptionItem(
                            context,
                            icon: Icons.remove_circle_outlined,
                            title: 'Remove Member',
                            isDestructive: true,
                            onTap: () {
                              Navigator.pop(context);
                              _showRemoveMemberDialog(context, team);
                            },
                          ),
                        ] else ...[
                          // Withdraw from tournament (only if registered)
                          _buildOptionItem(
                            context,
                            icon: Icons.cancel_outlined,
                            title: 'Withdraw from Tournament',
                            isDestructive: true,
                            onTap: () {
                              Navigator.pop(context);
                              _showWithdrawConfirmation(context, team);
                            },
                          ),
                        ],
                      ],

                      // Leave Team (only if not registered in tournament)
                      if (!isRegistered)
                        _buildOptionItem(
                          context,
                          icon: Icons.exit_to_app,
                          title: 'Leave Team',
                          isDestructive: true,
                          onTap: () {
                            Navigator.pop(context);
                            _showLeaveTeamConfirmation(context, team);
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.whiteColor.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.whiteColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color:
                        isDestructive
                            ? AppColors.redColor
                            : AppColors.orangeColor,
                    size: 24,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTexts.bodyTextStyle(
                        context: context,
                        textColor:
                            isDestructive
                                ? AppColors.redColor
                                : AppColors.whiteColor,
                        fontSize: AppFontSizes(context).size16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.greyColor,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showTeamDetails(BuildContext context, ClubTeam team) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.navyBlueGrey,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.whiteColor.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.orangeColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Icon(
                        Icons.groups,
                        color: AppColors.orangeColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            team.name,
                            style: AppTexts.headingStyle(
                              context: context,
                              textColor: AppColors.whiteColor,
                              fontSize: AppFontSizes(context).size20,
                            ),
                          ),
                          Text(
                            '${team.gender.toUpperCase()} • ${team.isPrivate ? 'Private' : 'Public'}',
                            style: AppTexts.bodyTextStyle(
                              context: context,
                              textColor: AppColors.greyColor,
                              fontSize: AppFontSizes(context).size14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                _buildDetailRow(
                  context,
                  'Members',
                  '${team.totalMembers}/${team.maxMembers}',
                ),
                _buildDetailRow(context, 'Created', team.formattedCreatedDate),
                if (team.captain != null)
                  _buildDetailRow(context, 'Captain', team.captain!.name),

                const SizedBox(height: 20),

                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.orangeColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Close',
                      style: AppTexts.emphasizedTextStyle(
                        context: context,
                        textColor: AppColors.whiteColor,
                        fontSize: AppFontSizes(context).size16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTexts.bodyTextStyle(
              context: context,
              textColor: AppColors.greyColor,
              fontSize: AppFontSizes(context).size14,
            ),
          ),
          Text(
            value,
            style: AppTexts.bodyTextStyle(
              context: context,
              textColor: AppColors.whiteColor,
              fontSize: AppFontSizes(context).size14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showLeaveTeamConfirmation(BuildContext context, ClubTeam team) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.navyBlueGrey,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.whiteColor.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber,
                  size: 48,
                  color: AppColors.warningColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Leave Team?',
                  style: AppTexts.headingStyle(
                    context: context,
                    textColor: AppColors.whiteColor,
                    fontSize: AppFontSizes(context).size20,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Are you sure you want to leave "${team.name}"? This action cannot be undone.',
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.greyColor,
                    fontSize: AppFontSizes(context).size14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.greyColor.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Cancel',
                            style: AppTexts.emphasizedTextStyle(
                              context: context,
                              textColor: AppColors.whiteColor,
                              fontSize: AppFontSizes(context).size16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Consumer<CreateTeamProvider>(
                        builder: (context, teamProvider, child) {
                          return GestureDetector(
                            onTap:
                                teamProvider.isLeavingTeam
                                    ? null
                                    : () async {
                                      final success = await teamProvider
                                          .leaveTeam(team.id);
                                      if (success && context.mounted) {
                                        Navigator.of(context).pop();
                                      }
                                    },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.redColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (teamProvider.isLeavingTeam)
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: SpinKitCircle(
                                        color: AppColors.whiteColor,
                                        size: 20,
                                      ),
                                    )
                                  else
                                    const Icon(
                                      Icons.exit_to_app,
                                      color: AppColors.whiteColor,
                                      size: 20,
                                    ),
                                  const SizedBox(width: 8),
                                  Text(
                                    teamProvider.isLeavingTeam
                                        ? 'Leaving...'
                                        : 'Leave Team',
                                    style: AppTexts.emphasizedTextStyle(
                                      context: context,
                                      textColor: AppColors.whiteColor,
                                      fontSize: AppFontSizes(context).size16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMessage(BuildContext context, String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSuccess ? AppColors.successColor : AppColors.errorColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: AppColors.whiteColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.whiteColor,
                    fontSize: AppFontSizes(context).size14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // Add this new method for Transfer Captaincy Dialog
  void _showTransferCaptaincyDialog(BuildContext context, ClubTeam team) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.navyBlueGrey,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.whiteColor.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    const Icon(
                      Icons.swap_horizontal_circle,
                      size: 28,
                      color: AppColors.goldColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Transfer Captaincy',
                            style: AppTexts.headingStyle(
                              context: context,
                              textColor: AppColors.whiteColor,
                              fontSize: AppFontSizes(context).size20,
                            ),
                          ),
                          Text(
                            'Choose a new captain for ${team.name}',
                            style: AppTexts.bodyTextStyle(
                              context: context,
                              textColor: AppColors.greyColor,
                              fontSize: AppFontSizes(context).size12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.greyColor,
                        size: 24,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Warning Message
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.warningColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber,
                        color: AppColors.warningColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'You will lose captain privileges after transfer',
                          style: AppTexts.bodyTextStyle(
                            context: context,
                            textColor: AppColors.warningColor,
                            fontSize: AppFontSizes(context).size12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Members List (excluding current captain)
                Expanded(
                  child: ListView.builder(
                    itemCount:
                        team.members
                            .where(
                              (member) =>
                                  member.clubTeamMember?.isCaptain != true,
                            )
                            .length,
                    itemBuilder: (context, index) {
                      final eligibleMembers =
                          team.members
                              .where(
                                (member) =>
                                    member.clubTeamMember?.isCaptain != true,
                              )
                              .toList();
                      final member = eligibleMembers[index];

                      return GestureDetector(
                        onTap:
                            () => _showTransferConfirmation(
                              context,
                              team,
                              member,
                            ),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.whiteColor.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.blueColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: AppColors.blueColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      member.name,
                                      style: AppTexts.emphasizedTextStyle(
                                        context: context,
                                        textColor: AppColors.whiteColor,
                                        fontSize: AppFontSizes(context).size14,
                                      ),
                                    ),
                                    Text(
                                      member.email,
                                      style: AppTexts.bodyTextStyle(
                                        context: context,
                                        textColor: AppColors.greyColor,
                                        fontSize: AppFontSizes(context).size12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: AppColors.greyColor,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRemoveMemberDialog(BuildContext context, ClubTeam team) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.navyBlueGrey,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.whiteColor.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    const Icon(
                      Icons.remove_circle_outlined,
                      size: 28,
                      color: AppColors.redColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Remove Member',
                            style: AppTexts.headingStyle(
                              context: context,
                              textColor: AppColors.whiteColor,
                              fontSize: AppFontSizes(context).size20,
                            ),
                          ),
                          Text(
                            'Choose a new captain for ${team.name}',
                            style: AppTexts.bodyTextStyle(
                              context: context,
                              textColor: AppColors.greyColor,
                              fontSize: AppFontSizes(context).size12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.greyColor,
                        size: 24,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Warning Message
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.errorColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber,
                        color: AppColors.errorColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'You will lose this member and might not select him again if other teams picked',
                          style: AppTexts.bodyTextStyle(
                            context: context,
                            textColor: AppColors.errorColor,
                            fontSize: AppFontSizes(context).size12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Members List (excluding current captain)
                Expanded(
                  child: ListView.builder(
                    itemCount:
                        team.members
                            .where(
                              (member) =>
                                  member.clubTeamMember?.isCaptain != true,
                            )
                            .length,
                    itemBuilder: (context, index) {
                      final eligibleMembers =
                          team.members
                              .where(
                                (member) =>
                                    member.clubTeamMember?.isCaptain != true,
                              )
                              .toList();
                      final member = eligibleMembers[index];

                      return GestureDetector(
                        onTap:
                            () => _showRemoveMemberConfirmation(
                              context,
                              team,
                              member,
                            ),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.whiteColor.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.blueColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: AppColors.blueColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      member.name,
                                      style: AppTexts.emphasizedTextStyle(
                                        context: context,
                                        textColor: AppColors.whiteColor,
                                        fontSize: AppFontSizes(context).size14,
                                      ),
                                    ),
                                    Text(
                                      member.email,
                                      style: AppTexts.bodyTextStyle(
                                        context: context,
                                        textColor: AppColors.greyColor,
                                        fontSize: AppFontSizes(context).size12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: AppColors.greyColor,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Add this method for Transfer Confirmation
  void _showTransferConfirmation(
    BuildContext context,
    ClubTeam team,
    ClubTeamMember newCaptain,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.navyBlueGrey,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.whiteColor.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.swap_horizontal_circle,
                  size: 48,
                  color: AppColors.goldColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Transfer Captaincy?',
                  style: AppTexts.headingStyle(
                    context: context,
                    textColor: AppColors.whiteColor,
                    fontSize: AppFontSizes(context).size20,
                  ),
                ),
                const SizedBox(height: 12),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: AppTexts.bodyTextStyle(
                      context: context,
                      textColor: AppColors.greyColor,
                      fontSize: AppFontSizes(context).size14,
                    ),
                    children: [
                      const TextSpan(
                        text: 'Are you sure you want to transfer captaincy to ',
                      ),
                      TextSpan(
                        text: newCaptain.name,
                        style: AppTexts.emphasizedTextStyle(
                          context: context,
                          textColor: AppColors.goldColor,
                          fontSize: AppFontSizes(context).size14,
                        ),
                      ),
                      const TextSpan(text: '? This action cannot be undone.'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.greyColor.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Cancel',
                            style: AppTexts.emphasizedTextStyle(
                              context: context,
                              textColor: AppColors.whiteColor,
                              fontSize: AppFontSizes(context).size16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Consumer<CreateTeamProvider>(
                        builder: (context, teamProvider, child) {
                          return GestureDetector(
                            onTap:
                                teamProvider.isTransferringCaptaincy
                                    ? null
                                    : () async {
                                      final success = await teamProvider
                                          .transferCaptaincyToMember(
                                            team.id,
                                            newCaptain.id,
                                          );
                                      if (success && context.mounted) {
                                        Navigator.of(
                                          context,
                                        ).pop(); // Close confirmation
                                        Navigator.of(
                                          context,
                                        ).pop(); // Close member list
                                      }
                                    },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.goldColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (teamProvider.isTransferringCaptaincy)
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: SpinKitCircle(
                                        color: AppColors.whiteColor,
                                        size: 20,
                                      ),
                                    )
                                  else
                                    const Icon(
                                      Icons.swap_horizontal_circle,
                                      color: AppColors.whiteColor,
                                      size: 20,
                                    ),
                                  const SizedBox(width: 8),
                                  Text(
                                    teamProvider.isTransferringCaptaincy
                                        ? 'Transferring...'
                                        : 'Transfer',
                                    style: AppTexts.emphasizedTextStyle(
                                      context: context,
                                      textColor: AppColors.whiteColor,
                                      fontSize: AppFontSizes(context).size16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  } // Add this method for Transfer Confirmation

  void _showRemoveMemberConfirmation(
    BuildContext context,
    ClubTeam team,
    ClubTeamMember newCaptain,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.navyBlueGrey,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.whiteColor.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.remove_circle_outlined,
                  size: 48,
                  color: AppColors.errorColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Remove Member?',
                  style: AppTexts.headingStyle(
                    context: context,
                    textColor: AppColors.whiteColor,
                    fontSize: AppFontSizes(context).size20,
                  ),
                ),
                const SizedBox(height: 12),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: AppTexts.bodyTextStyle(
                      context: context,
                      textColor: AppColors.greyColor,
                      fontSize: AppFontSizes(context).size14,
                    ),
                    children: [
                      const TextSpan(text: 'Are you sure you want to remove '),
                      TextSpan(
                        text: newCaptain.name,
                        style: AppTexts.emphasizedTextStyle(
                          context: context,
                          textColor: AppColors.errorColor,
                          fontSize: AppFontSizes(context).size14,
                        ),
                      ),
                      const TextSpan(text: '? This action cannot be undone.'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.greyColor.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Cancel',
                            style: AppTexts.emphasizedTextStyle(
                              context: context,
                              textColor: AppColors.whiteColor,
                              fontSize: AppFontSizes(context).size16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Consumer<CreateTeamProvider>(
                        builder: (context, teamProvider, child) {
                          return GestureDetector(
                            onTap:
                                teamProvider.isRemovingMember
                                    ? null
                                    : () async {
                                      final success = await teamProvider
                                          .removeMember(team.id, newCaptain.id);
                                      if (success && context.mounted) {
                                        Navigator.of(
                                          context,
                                        ).pop(); // Close confirmation
                                        Navigator.of(
                                          context,
                                        ).pop(); // Close member list
                                      }
                                    },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.errorColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (teamProvider.isRemovingMember)
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: SpinKitCircle(
                                        color: AppColors.whiteColor,
                                        size: 20,
                                      ),
                                    )
                                  else
                                    const Icon(
                                      Icons.remove_circle_outlined,
                                      color: AppColors.whiteColor,
                                      size: 20,
                                    ),
                                  const SizedBox(width: 8),
                                  Text(
                                    teamProvider.isRemovingMember
                                        ? 'Removing...'
                                        : 'Remove',
                                    style: AppTexts.emphasizedTextStyle(
                                      context: context,
                                      textColor: AppColors.whiteColor,
                                      fontSize: AppFontSizes(context).size16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  void _showWithdrawConfirmation(BuildContext context, ClubTeam team) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.navyBlueGrey,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.whiteColor.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber,
                  size: 48,
                  color: AppColors.warningColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Withdraw from Tournament?',
                  style: AppTexts.headingStyle(
                    context: context,
                    textColor: AppColors.whiteColor,
                    fontSize: AppFontSizes(context).size20,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Are you sure you want to withdraw "${team.name}" from ${team.registeredTournament?.title}? This action cannot be undone.',
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.greyColor,
                    fontSize: AppFontSizes(context).size14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.greyColor.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Cancel',
                            style: AppTexts.emphasizedTextStyle(
                              context: context,
                              textColor: AppColors.whiteColor,
                              fontSize: AppFontSizes(context).size16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Consumer<CreateTeamProvider>(
                        builder: (context, teamProvider, child) {
                          return GestureDetector(
                            onTap: teamProvider.isWithdrawingFromTournament
                                ? null
                                : () async {
                              final success = await teamProvider
                                  .withdrawFromTournament(team.tournamentTeam!.id);
                              if (success && context.mounted) {
                                Navigator.of(context).pop();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.warningColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (teamProvider.isWithdrawingFromTournament)
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: SpinKitCircle(
                                        color: AppColors.whiteColor,
                                        size: 20,
                                      ),
                                    )
                                  else
                                    const Icon(
                                      Icons.cancel_outlined,
                                      color: AppColors.whiteColor,
                                      size: 20,
                                    ),
                                  const SizedBox(width: 8),
                                  Text(
                                    teamProvider.isWithdrawingFromTournament
                                        ? 'Withdrawing...'
                                        : 'Withdraw',
                                    style: AppTexts.emphasizedTextStyle(
                                      context: context,
                                      textColor: AppColors.whiteColor,
                                      fontSize: AppFontSizes(context).size16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

// Add helper method for date formatting
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
