import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'dart:ui';

import '../../style/colors.dart';
import '../../style/texts.dart';
import 'invitation_card.dart';
import 'invitation_provider.dart';

class InvitationsScreen extends StatefulWidget {
  const InvitationsScreen({super.key});

  @override
  State<InvitationsScreen> createState() => _InvitationsScreenState();
}

class _InvitationsScreenState extends State<InvitationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initialize provider data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvitationsProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.darkPrimaryColor,
      extendBodyBehindAppBar: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(190),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.darkPrimaryColor,
                AppColors.darkSecondaryColor.withOpacity(0.8),
                Colors.transparent,
              ],
              stops: const [0.0, 0.7, 1.0],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header Section
                Container(
                  height: 80,
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.glassLightColor,
                        AppColors.glassColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.glassBorderColor,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                      BoxShadow(
                        color: AppColors.blackColor.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            // Back Button
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.primaryColor.withOpacity(0.3),
                                    AppColors.primaryDarkColor.withOpacity(0.2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.primaryColor.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: () => Navigator.pop(context),
                                  child: const Icon(
                                    Icons.arrow_back_ios_new,
                                    color: AppColors.textPrimaryColor,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),

                            // Title
                            Expanded(
                              child: Center(
                                child: Text(
                                  'Team Invitations',
                                  style: AppTexts.emphasizedTextStyle(
                                    context: context,
                                    textColor: AppColors.textPrimaryColor,
                                    fontSize: screenSize.width * 0.048,
                                  ),
                                ),
                              ),
                            ),

                            // Placeholder for symmetry
                            const SizedBox(width: 44),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Tab Bar Section
                Container(
                  height: 70,
                  margin: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.glassLightColor,
                        AppColors.glassColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: AppColors.glassBorderColor,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primaryColor,
                                AppColors.primaryDarkColor,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryColor.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                              BoxShadow(
                                color: AppColors.primaryColor.withOpacity(0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          labelStyle: AppTexts.bodyTextStyle(
                            context: context,
                            textColor: AppColors.textPrimaryColor,
                            fontWeight: FontWeight.w700,
                          ),
                          unselectedLabelStyle: AppTexts.bodyTextStyle(
                            context: context,
                            textColor: AppColors.textSecondaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                          labelColor: AppColors.textPrimaryColor,
                          unselectedLabelColor: AppColors.textSecondaryColor,
                          tabs: const [
                            Tab(
                              child: Text(
                                'Sent',
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                            Tab(
                              child: Text(
                                'Received',
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                          ],
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.darkPrimaryColor,
              AppColors.darkSecondaryColor,
              AppColors.darkTertiaryColor,
            ],
          ),
        ),
        child: Consumer<InvitationsProvider>(
          builder: (context, provider, child) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildSentInvitations(provider),
                _buildReceivedInvitations(provider),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSentInvitations(InvitationsProvider provider) {
    return Skeletonizer(
      enabled: provider.isLoadingSent,
      child: provider.isLoadingSent
          ? _buildSkeletonList()
          : provider.sentInvitations.isEmpty
          ? _buildEmptyState('No sent invitations', Icons.send_outlined)
          : RefreshIndicator(
        color: AppColors.primaryColor,
        backgroundColor: AppColors.darkSecondaryColor,
        onRefresh: () => provider.fetchSentInvitations(),
        child: ListView.builder(
          padding: EdgeInsets.all(
            MediaQuery.of(context).size.width * 0.04,
          ),
          itemCount: provider.sentInvitations.length,
          itemBuilder: (context, index) {
            final invitation = provider.sentInvitations[index];
            return _buildGlassInvitationCard(
              invitation: invitation,
              isSent: true,
              index: index,
            );
          },
        ),
      ),
    );
  }

  Widget _buildReceivedInvitations(InvitationsProvider provider) {
    return Skeletonizer(
      enabled: provider.isLoadingReceived,
      child: provider.isLoadingReceived
          ? _buildSkeletonList()
          : provider.receivedInvitations.isEmpty
          ? _buildEmptyState(
        'No received invitations',
        Icons.inbox_outlined,
      )
          : RefreshIndicator(
        color: AppColors.primaryColor,
        backgroundColor: AppColors.darkSecondaryColor,
        onRefresh: () => provider.fetchReceivedInvitations(),
        child: ListView.builder(
          padding: EdgeInsets.all(
            MediaQuery.of(context).size.width * 0.04,
          ),
          itemCount: provider.receivedInvitations.length,
          itemBuilder: (context, index) {
            final invitation = provider.receivedInvitations[index];
            return _buildGlassInvitationCard(
              invitation: invitation,
              isSent: false,
              index: index,
              onAccept: () => _handleAcceptInvitation(
                invitation.invitationCode,
              ),
              onDecline: () => _handleDeclineInvitation(
                invitation.invitationCode,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGlassInvitationCard({
    required dynamic invitation,
    required bool isSent,
    required int index,
    VoidCallback? onAccept,
    VoidCallback? onDecline,
  }) {

    return InvitationCard(
      invitation: invitation,
      isSent: isSent,
      onAccept: onAccept,
      onDecline: onDecline,
    );
  }

  Widget _buildSkeletonList() {
    return ListView.builder(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
      itemCount: 5,
      itemBuilder: (context, index) => _buildSkeletonCard(),
    );
  }

  Widget _buildSkeletonCard() {
    final screenSize = MediaQuery.of(context).size;

    return Container(
      margin: EdgeInsets.only(bottom: screenSize.width * 0.04),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.glassLightColor,
            AppColors.glassColor,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.glassBorderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.all(screenSize.width * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: screenSize.width * 0.12,
                      height: screenSize.width * 0.12,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.textTertiaryColor,
                            AppColors.textSecondaryColor.withOpacity(0.3),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: screenSize.width * 0.03),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: screenSize.width * 0.4,
                            height: screenSize.width * 0.04,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.textTertiaryColor,
                                  AppColors.textSecondaryColor.withOpacity(0.3),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          SizedBox(height: screenSize.width * 0.01),
                          Container(
                            width: screenSize.width * 0.3,
                            height: screenSize.width * 0.03,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.textTertiaryColor,
                                  AppColors.textSecondaryColor.withOpacity(0.3),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenSize.width * 0.03),
                Container(
                  width: double.infinity,
                  height: screenSize.width * 0.03,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.textTertiaryColor,
                        AppColors.textSecondaryColor.withOpacity(0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: screenSize.width * 0.02),
                Container(
                  width: screenSize.width * 0.6,
                  height: screenSize.width * 0.03,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.textTertiaryColor,
                        AppColors.textSecondaryColor.withOpacity(0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    final screenSize = MediaQuery.of(context).size;

    return Center(
      child: Container(
        margin: EdgeInsets.all(screenSize.width * 0.08),
        padding: EdgeInsets.all(screenSize.width * 0.08),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.glassLightColor,
              AppColors.glassColor,
            ],
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: AppColors.glassBorderColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(screenSize.width * 0.04),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryColor.withOpacity(0.2),
                      AppColors.primaryLightColor.withOpacity(0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: screenSize.width * 0.15,
                  color: AppColors.textSecondaryColor,
                ),
              ),
              SizedBox(height: screenSize.width * 0.04),
              Text(
                message,
                style: AppTexts.emphasizedTextStyle(
                  context: context,
                  textColor: AppColors.textSecondaryColor,
                  fontSize: screenSize.width * 0.04,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleAcceptInvitation(String invitationCode) async {
    final provider = context.read<InvitationsProvider>();
    await provider.handleInvitationAction(
      context,
      invitationCode,
      'accept',
      onSuccess: (message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message,
              style: const TextStyle(color: AppColors.textPrimaryColor),
            ),
            backgroundColor: AppColors.successColor.withOpacity(0.9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );
      },
    );
  }

  void _handleDeclineInvitation(String invitationCode) async {
    // Show glass morphism confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: AppColors.blackColor.withOpacity(0.7),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          content: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.glassLightColor,
                  AppColors.glassColor,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.glassBorderColor,
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Decline Invitation',
                        style: AppTexts.emphasizedTextStyle(
                          context: context,
                          textColor: AppColors.textPrimaryColor,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Are you sure you want to decline this invitation?',
                        style: AppTexts.bodyTextStyle(
                          context: context,
                          textColor: AppColors.textSecondaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.textTertiaryColor,
                                    AppColors.textSecondaryColor.withOpacity(0.3),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: AppColors.textPrimaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.errorColor,
                                    AppColors.errorColor.withOpacity(0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: Text(
                                  'Decline',
                                  style: TextStyle(
                                    color: AppColors.textPrimaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
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
        ),
      ),
    );

    if (confirmed != true) return;

    final provider = context.read<InvitationsProvider>();
    await provider.handleInvitationAction(
      context,
      invitationCode,
      'decline',
      onSuccess: (message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message,
              style: const TextStyle(color: AppColors.textPrimaryColor),
            ),
            backgroundColor: AppColors.warningColor.withOpacity(0.9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );
      },
    );
  }
}