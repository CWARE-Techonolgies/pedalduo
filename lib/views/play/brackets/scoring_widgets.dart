import 'package:flutter/material.dart';
import 'package:pedalduo/views/play/brackets/widgets/tennis_glass_morpishm_container.dart';
import '../../../models/scoring_system_model.dart';
import '../../../style/colors.dart';


// Loading View Widget
class TennisLoadingView extends StatelessWidget {
  final AnimationController slideController;

  const TennisLoadingView({super.key, required this.slideController});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildSkeletonContainer(height: 180, borderRadius: 20),
          const SizedBox(height: 24),
          _buildSkeletonContainer(height: 200, borderRadius: 20),
          const SizedBox(height: 24),
          _buildSkeletonContainer(height: 150, borderRadius: 20),
        ],
      ),
    );
  }

  Widget _buildSkeletonContainer({
    required double height,
    double? width,
    required double borderRadius,
  }) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.glassColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.glassBorderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: slideController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppColors.glassBorderColor.withOpacity(0.1),
                  AppColors.glassBorderColor.withOpacity(0.3),
                  AppColors.glassBorderColor.withOpacity(0.1),
                ],
                stops: [0.0, 0.5 + (slideController.value * 0.5), 1.0],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Error View Widget
class TennisErrorView extends StatelessWidget {
  final String? error;
  final VoidCallback onRetry;

  const TennisErrorView({super.key, this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TennisGlassMorphContainer(
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.errorColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.error_outline,
                  color: AppColors.errorColor,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Failed to Load Match',
                style: TextStyle(
                  color: AppColors.textPrimaryColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                error ?? 'Unknown error occurred',
                style: TextStyle(
                  color: AppColors.textSecondaryColor,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: onRetry,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryColor,
                        AppColors.primaryLightColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Text(
                    'Retry',
                    style: TextStyle(
                      color: AppColors.textPrimaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom App Bar for Match Info
// Custom App Bar for Match Info
class TennisMatchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String matchTypeDisplay;
  final String status;
  final VoidCallback? onBackPressed;

  const TennisMatchAppBar({
    super.key,
    required this.matchTypeDisplay,
    required this.status,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.backgroundColor,
      automaticallyImplyLeading: false,
      elevation: 0,
      flexibleSpace: TennisGlassMorphContainer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryColor.withOpacity(0.3),
                AppColors.primaryLightColor.withOpacity(0.2),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      color: AppColors.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.sports_tennis,
                    color: AppColors.textPrimaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          matchTypeDisplay,
                          style: TextStyle(
                            color: AppColors.textPrimaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          status,
                          style: TextStyle(
                            color: AppColors.textPrimaryColor.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
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

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// Unified Score Board with Actions
class TennisUnifiedScoreBoard extends StatelessWidget {
  final TennisMatch match;
  final TennisScore tennisScore;
  final CurrentGame currentGame;
  final String Function(String) formatPointsDisplay;
  final Animation<double> scoreAnimation;
  final Animation<double> pulseAnimation;
  final bool isUpdating;
  final Function(String) onAddPoint;

  const TennisUnifiedScoreBoard({
    super.key,
    required this.match,
    required this.tennisScore,
    required this.currentGame,
    required this.formatPointsDisplay,
    required this.scoreAnimation,
    required this.pulseAnimation,
    required this.isUpdating,
    required this.onAddPoint,
  });

  @override
  Widget build(BuildContext context) {
    if (match.status == 'Completed') {
      return TennisGlassMorphContainer(
        borderColor: AppColors.successColor.withOpacity(0.3),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: AppColors.successColor,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Match Completed',
                    style: TextStyle(
                      color: AppColors.textPrimaryColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildFinalScoreDisplay(),
            ],
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: scoreAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (0.02 * scoreAnimation.value),
          child: TennisGlassMorphContainer(
            borderColor: _getBorderColor(),
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildGameStatusHeader(),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTeamScoreSection(
                          team: match.team1,
                          sets: tennisScore.sets.team1,
                          games: tennisScore.games.team1,
                          currentPoints: currentGame.team1Points,
                          isServing: currentGame.servingTeam == 'team1',
                          onAddPoint: () => onAddPoint('team1'),
                          teamKey: 'team1',
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        width: 2,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.glassBorderColor,
                              AppColors.primaryColor.withOpacity(0.5),
                              AppColors.glassBorderColor,
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: _buildTeamScoreSection(
                          team: match.team2,
                          sets: tennisScore.sets.team2,
                          games: tennisScore.games.team2,
                          currentPoints: currentGame.team2Points,
                          isServing: currentGame.servingTeam == 'team2',
                          onAddPoint: () => onAddPoint('team2'),
                          teamKey: 'team2',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getBorderColor() {
    if (currentGame.isGoldenPoint) {
      return AppColors.warningColor.withOpacity(0.5);
    } else if (currentGame.isDeuce) {
      return AppColors.infoColor.withOpacity(0.5);
    }
    return AppColors.successColor.withOpacity(0.3);
  }

  Widget _buildGameStatusHeader() {
    if (currentGame.isGoldenPoint) {
      return AnimatedBuilder(
        animation: pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: pulseAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.warningColor, AppColors.primaryColor],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.warningColor.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.flash_on,
                    color: AppColors.textPrimaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'GOLDEN POINT',
                    style: TextStyle(
                      color: AppColors.textPrimaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else if (currentGame.isDeuce) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.infoColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.infoColor.withOpacity(0.5)),
        ),
        child: Text(
          'DEUCE',
          style: TextStyle(
            color: AppColors.infoColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else if (currentGame.inTiebreak) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.warningColor.withOpacity(0.8), AppColors.errorColor.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.warningColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.trending_up,
              color: AppColors.textPrimaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'TIEBREAK IN PROGRESS',
              style: TextStyle(
                color: AppColors.textPrimaryColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.successColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.successColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sports_tennis,
              color: AppColors.successColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'CURRENT GAME',
              style: TextStyle(
                color: AppColors.successColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildTeamScoreSection({
    required Team team,
    required int sets,
    required int games,
    required String currentPoints,
    required bool isServing,
    required VoidCallback onAddPoint,
    required String teamKey,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.glassColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isServing
                  ? AppColors.successColor.withOpacity(0.5)
                  : AppColors.glassBorderColor,
          width: isServing ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          // Team Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryColor, AppColors.primaryLightColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: AppColors.glassBorderColor, width: 2),
            ),
            child: Center(
              child: Text(
                team.name.isNotEmpty ? team.name[0].toUpperCase() : 'T',
                style: TextStyle(
                  color: AppColors.textPrimaryColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Team Name with Serving Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  team.name,
                  style: TextStyle(
                    color: AppColors.textPrimaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              if (isServing) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: AppColors.successColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.sports_tennis,
                    color: AppColors.textPrimaryColor,
                    size: 10,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // Scores Display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildScoreItem('Sets', sets.toString()),
              _buildScoreItem('Games', games.toString()),
            ],
          ),
          const SizedBox(height: 12),

          // Current Points
          Text(
            formatPointsDisplay(currentPoints),
            style: TextStyle(
              color: AppColors.textPrimaryColor,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Add Point Button
          GestureDetector(
            onTap: isUpdating ? null : onAddPoint,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                gradient:
                    isUpdating
                        ? null
                        : LinearGradient(
                          colors: [
                            AppColors.primaryColor,
                            AppColors.primaryLightColor,
                          ],
                        ),
                color: isUpdating ? AppColors.glassColor : null,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      isUpdating
                          ? AppColors.glassBorderColor
                          : AppColors.primaryColor.withOpacity(0.3),
                ),
                boxShadow:
                    isUpdating
                        ? null
                        : [
                          BoxShadow(
                            color: AppColors.primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isUpdating) ...[
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.textSecondaryColor,
                        ),
                        strokeWidth: 2,
                      ),
                    ),
                  ] else ...[
                    Icon(
                      Icons.add,
                      color: AppColors.textPrimaryColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Point',
                      style: TextStyle(
                        color: AppColors.textPrimaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondaryColor,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFinalScoreDisplay() {
    return Row(
      children: [
        Expanded(
          child: _buildFinalTeamScore(match.team1, tennisScore.sets.team1),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'VS',
            style: TextStyle(
              color: AppColors.textSecondaryColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: _buildFinalTeamScore(match.team2, tennisScore.sets.team2),
        ),
      ],
    );
  }

  Widget _buildFinalTeamScore(Team team, int sets) {
    final isWinner =
        (sets >
            (team == match.team1
                ? tennisScore.sets.team2
                : tennisScore.sets.team1));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isWinner
                ? AppColors.successColor.withOpacity(0.2)
                : AppColors.glassColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isWinner
                  ? AppColors.successColor.withOpacity(0.5)
                  : AppColors.glassBorderColor,
        ),
      ),
      child: Column(
        children: [
          Text(
            team.name,
            style: TextStyle(
              color: AppColors.textPrimaryColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isWinner) ...[
                Icon(
                  Icons.emoji_events,
                  color: AppColors.successColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                '$sets',
                style: TextStyle(
                  color: AppColors.textPrimaryColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'sets',
                style: TextStyle(
                  color: AppColors.textSecondaryColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// No Show Section Widget (unchanged but simplified)
class TennisNoShowSection extends StatelessWidget {
  final TennisMatch match;
  final bool team1NoShow;
  final bool team2NoShow;
  final bool bothNoShow;
  final bool isUpdating;
  final Function({bool? team1NoShow, bool? team2NoShow, bool? bothNoShow})
  onNoShowChanged;
  final VoidCallback onSubmitNoShow;

  const TennisNoShowSection({
    super.key,
    required this.match,
    required this.team1NoShow,
    required this.team2NoShow,
    required this.bothNoShow,
    required this.isUpdating,
    required this.onNoShowChanged,
    required this.onSubmitNoShow,
  });

  @override
  Widget build(BuildContext context) {
    return TennisGlassMorphContainer(
      borderColor: AppColors.errorColor.withOpacity(0.3),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.errorColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'No Show Options',
                  style: TextStyle(
                    color: AppColors.errorColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildCompactCheckbox(
              'Both teams no show',
              bothNoShow,
              (value) => onNoShowChanged(bothNoShow: value),
            ),
            const SizedBox(height: 12),
            _buildCompactCheckbox(
              '${match.team1.name} no show',
              team1NoShow && !bothNoShow,
              (value) => onNoShowChanged(team1NoShow: value),
              enabled: !bothNoShow,
            ),
            const SizedBox(height: 12),
            _buildCompactCheckbox(
              '${match.team2.name} no show',
              team2NoShow && !bothNoShow,
              (value) => onNoShowChanged(team2NoShow: value),
              enabled: !bothNoShow,
            ),
            if (team1NoShow || team2NoShow) ...[
              const SizedBox(height: 16),
              GestureDetector(
                onTap: isUpdating ? null : onSubmitNoShow,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient:
                        isUpdating
                            ? null
                            : LinearGradient(
                              colors: [
                                AppColors.errorColor,
                                AppColors.errorColor.withOpacity(0.8),
                              ],
                            ),
                    color: isUpdating ? AppColors.glassColor : null,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isUpdating ? 'Updating...' : 'Submit No Show',
                    style: TextStyle(
                      color: AppColors.textPrimaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompactCheckbox(
    String title,
    bool value,
    Function(bool?) onChanged, {
    bool enabled = true,
  }) {
    return GestureDetector(
      onTap: enabled ? () => onChanged(!value) : null,
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: value ? AppColors.errorColor : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color:
                    enabled
                        ? AppColors.errorColor
                        : AppColors.textTertiaryColor,
                width: 2,
              ),
            ),
            child:
                value
                    ? Icon(
                      Icons.check,
                      color: AppColors.textPrimaryColor,
                      size: 14,
                    )
                    : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color:
                    enabled
                        ? AppColors.textPrimaryColor
                        : AppColors.textTertiaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Sets History Widget with Team Names
