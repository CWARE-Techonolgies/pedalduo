import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pedalduo/views/profile/settings/settings_screen.dart';
import 'package:pedalduo/views/profile/update_profile_scren.dart';
import 'package:provider/provider.dart';
import '../../style/colors.dart';
import '../../style/fonts_sizes.dart';
import '../../style/texts.dart';
import '../play/providers/user_profile_provider.dart';
import 'ccoins_screen.dart';
import 'padelduo_pro_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedTabIndex = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProfileProvider>().initializeUser();
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkPrimaryColor,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // Header Profile Section
            Consumer<UserProfileProvider>(
              builder: (
                  BuildContext context,
                  UserProfileProvider userProvider,
                  Widget? child,
                  ) {
                final user = userProvider.user;
                return Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryColor.withOpacity(0.9),
                        AppColors.primaryLightColor.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(
                      color: AppColors.glassBorderColor,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Top bar with edit and share buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (_) => UserProfileUpdateScreen(),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.glassColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.glassBorderColor,
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: AppColors.textPrimaryColor,
                                size: 20,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.accentPurpleColor,
                                      AppColors.accentBlueColor,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.accentPurpleColor.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: AppColors.textPrimaryColor,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'PadelDuo+',
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
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.glassColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.glassBorderColor,
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.share,
                                  color: AppColors.textPrimaryColor,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Profile Picture
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: AppColors.glassLightColor,
                          borderRadius: BorderRadius.circular(45),
                          border: Border.all(
                            color: AppColors.glassBorderColor,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.blackColor.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          (user?.name.isNotEmpty ?? false)
                              ? user!.name[0].toUpperCase()
                              : '?',
                          style: AppTexts.emphasizedTextStyle(
                            context: context,
                            textColor: AppColors.primaryColor,
                            fontSize: 40,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Name and Username
                      Text(
                        user?.name ?? 'User',
                        style: AppTexts.emphasizedTextStyle(
                          context: context,
                          textColor: AppColors.textPrimaryColor,
                          fontSize: AppFontSizes(context).size20,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        user?.email ?? '...',
                        style: AppTexts.bodyTextStyle(
                          context: context,
                          textColor: AppColors.textSecondaryColor,
                          fontSize: AppFontSizes(context).size14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pakistan • Professional Player',
                        style: AppTexts.bodyTextStyle(
                          context: context,
                          textColor: AppColors.textSecondaryColor,
                          fontSize: AppFontSizes(context).size14,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatItem('SERVE: 90'),
                          _buildStatItem('VOLLEY: 85'),
                          _buildStatItem('SMASH: 88'),
                          _buildStatItem('DEFENSE: 92'),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            // Navigation Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildNavButton(
                      context,
                      'Settings',
                      Icons.settings_outlined,
                      onTap: () => _navigateToSettings(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildNavButton(
                      context,
                      'PadelDuo+',
                      Icons.workspace_premium_outlined,
                      onTap: () => _navigateToPadelDuoPlus(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildNavButton(
                      context,
                      'P Coins',
                      Icons.monetization_on_outlined,
                      onTap: () => _navigateToPCoins(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Stats Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatColumn('24', 'Posts', AppColors.primaryColor),
                  _buildStatColumn('128', 'Following', AppColors.primaryColor),
                  _buildStatColumn('1.2k', 'Followers', AppColors.primaryColor),
                  _buildStatColumn('5.4k', 'Views', AppColors.primaryColor),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.glassColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.glassBorderColor,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  _buildTabItem('Stats', 0),
                  _buildTabItem('Posts', 1),
                  _buildTabItem('Dashboard', 2),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Tab Content
            _buildTabContent(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String stat) {
    return Text(
      stat,
      style: AppTexts.bodyTextStyle(
        context: context,
        textColor: AppColors.textPrimaryColor,
        fontSize: AppFontSizes(context).size12,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildNavButton(
      BuildContext context,
      String title,
      IconData icon, {
        VoidCallback? onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.glassColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.glassBorderColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.blackColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.textPrimaryColor, size: 26),
            const SizedBox(height: 6),
            Text(
              title,
              style: AppTexts.bodyTextStyle(
                context: context,
                textColor: AppColors.textPrimaryColor,
                fontSize: AppFontSizes(context).size12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: AppTexts.emphasizedTextStyle(
            context: context,
            textColor: color,
            fontSize: AppFontSizes(context).size18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTexts.bodyTextStyle(
            context: context,
            textColor: AppColors.textTertiaryColor,
            fontSize: AppFontSizes(context).size12,
          ),
        ),
      ],
    );
  }

  Widget _buildTabItem(String title, int index) {
    bool isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryColor.withOpacity(0.8)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected ? [
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: AppTexts.bodyTextStyle(
              context: context,
              textColor: isSelected
                  ? AppColors.textPrimaryColor
                  : AppColors.textTertiaryColor,
              fontSize: AppFontSizes(context).size14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildStatsTab();
      case 1:
        return _buildPostsTab();
      case 2:
        return _buildDashboardTab();
      default:
        return _buildStatsTab();
    }
  }

  Widget _buildStatsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Player Statistics',
            style: AppTexts.emphasizedTextStyle(
              context: context,
              textColor: AppColors.textPrimaryColor,
              fontSize: AppFontSizes(context).size18,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildStatCard('Matches Played', '42')),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('Win Rate', '68%')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatCard('Sets Won', '89')),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('Aces Served', '156')),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Skills Assessment',
            style: AppTexts.emphasizedTextStyle(
              context: context,
              textColor: AppColors.textPrimaryColor,
              fontSize: AppFontSizes(context).size16,
            ),
          ),
          const SizedBox(height: 16),
          _buildSkillBar('Serve Power', 90),
          _buildSkillBar('Volleys', 85),
          _buildSkillBar('Smash Technique', 88),
          _buildSkillBar('Court Defense', 92),
          _buildSkillBar('Net Play', 78),
          _buildSkillBar('Backhand', 82),
        ],
      ),
    );
  }

  Widget _buildPostsTab() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.glassColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.glassBorderColor,
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          'Posts content will be here',
          style: AppTexts.bodyTextStyle(
            context: context,
            textColor: AppColors.textSecondaryColor,
            fontSize: AppFontSizes(context).size16,
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardTab() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.glassColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.glassBorderColor,
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          'Dashboard content will be here',
          style: AppTexts.bodyTextStyle(
            context: context,
            textColor: AppColors.textSecondaryColor,
            fontSize: AppFontSizes(context).size16,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.glassBorderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTexts.bodyTextStyle(
              context: context,
              textColor: AppColors.textTertiaryColor,
              fontSize: AppFontSizes(context).size12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTexts.emphasizedTextStyle(
              context: context,
              textColor: AppColors.textPrimaryColor,
              fontSize: AppFontSizes(context).size24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillBar(String skill, int percentage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                skill,
                style: AppTexts.bodyTextStyle(
                  context: context,
                  textColor: AppColors.textPrimaryColor,
                  fontSize: AppFontSizes(context).size14,
                ),
              ),
              Text(
                '$percentage%',
                style: AppTexts.bodyTextStyle(
                  context: context,
                  textColor: AppColors.primaryColor,
                  fontSize: AppFontSizes(context).size14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.darkSecondaryColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryColor,
                      AppColors.primaryLightColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  void _navigateToPadelDuoPlus(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PadelDuoPlusScreen()),
    );
  }

  void _navigateToPCoins(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CCoinsScreen()),
    );
  }
}