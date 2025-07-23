import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pedalduo/views/play/brackets/score_dialogue.dart';
import 'package:pedalduo/views/play/brackets/winner_team_dialogue.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:intl/intl.dart';

import '../../../style/colors.dart';
import '../../../style/fonts_sizes.dart';
import '../../../style/texts.dart';
import '../models/tournament_data.dart';
import '../providers/brackets_provider.dart';
import 'match_card_in_brackets_view.dart';

class AllBracketsViews extends StatefulWidget {
  final bool isOrganizer;
  final String tournamentId;
  final String tournamentName;
  final String tournamentStatus;
  final int? winnerTeamId;
  const AllBracketsViews({
    super.key,
    required this.isOrganizer,
    required this.tournamentId,
    required this.tournamentName,
    required this.tournamentStatus,
    this.winnerTeamId,
  });

  @override
  State<AllBracketsViews> createState() => _AllBracketsViewsState();
}

class _AllBracketsViewsState extends State<AllBracketsViews>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isFinalRound() {
    final provider = context.read<Brackets>();
    if (provider.tournamentData == null) return false;

    final rounds = provider.getSortedRounds();
    if (rounds.isEmpty) return false;

    final latestRound = rounds.last;
    return latestRound.roundName.toLowerCase() == 'final';
  }

  bool _isFinalMatchCompleted() {
    final provider = context.read<Brackets>();
    if (provider.tournamentData == null) return false;

    final rounds = provider.getSortedRounds();
    if (rounds.isEmpty) return false;

    final latestRound = rounds.last;
    if (!latestRound.roundName.toLowerCase().contains('final')) return false;

    return latestRound.matches.every((match) => match.isCompleted);
  }

  Team? _getWinnerTeam() {
    final provider = context.read<Brackets>();
    if (provider.tournamentData == null) return null;

    final rounds = provider.getSortedRounds();
    if (rounds.isEmpty) return null;

    final latestRound = rounds.last;
    if (!latestRound.roundName.toLowerCase().contains('final')) return null;

    final finalMatch = latestRound.matches.firstWhere(
          (match) => match.isCompleted,
      orElse: () => latestRound.matches.first,
    );

    if (finalMatch.isCompleted) {
      if (finalMatch.team1Score != null && finalMatch.team2Score != null) {
        final team1Score = int.tryParse(finalMatch.team1Score.toString()) ?? 0;
        final team2Score = int.tryParse(finalMatch.team2Score.toString()) ?? 0;

        if (team1Score > team2Score) {
          return finalMatch.team1;
        } else {
          return finalMatch.team2;
        }
      }
    }

    return null;
  }

  void _showWinnerDialog() {
    final winnerTeam = _getWinnerTeam();
    if (winnerTeam != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => WinnerDialog(
          winnerTeam: winnerTeam,
          onClose: () => Navigator.of(context).pop(),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.elasticOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<Brackets>().fetchTournamentData(widget.tournamentId);
      _fadeController.forward();
      _slideController.forward();

      if (widget.tournamentStatus == 'Completed' && widget.winnerTeamId != null) {
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (mounted) {
            _showWinnerDialog();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkPrimaryColor,
      extendBodyBehindAppBar: true,
      appBar: _buildGlassAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.primaryGradient,
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Consumer<Brackets>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return _buildLoadingSkeleton();
                    }

                    if (provider.error != null) {
                      return _buildErrorView(provider.error!);
                    }

                    if (provider.tournamentData == null) {
                      return _buildEmptyView();
                    }

                    return _buildTournamentBrackets(provider);
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildGlassAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.glassLightColor,
              AppColors.glassColor,
            ],
          ),
          border: Border(
            bottom: BorderSide(
              color: AppColors.glassBorderColor,
              width: 0.5,
            ),
          ),
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimaryColor),
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.glassColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.glassBorderColor, width: 0.5),
        ),
        child: Text(
          widget.tournamentName,
          style: AppTexts.emphasizedTextStyle(
            context: context,
            textColor: AppColors.orangeColor,
            fontSize: AppFontSizes(context).size18,
          ),
        ),
      ),
      centerTitle: true,
      actions: [
        if (widget.isOrganizer)
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: AppColors.glassColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.glassBorderColor, width: 0.5),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  context.read<Brackets>().fetchTournamentData(widget.tournamentId);
                },
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(
                    Icons.refresh_rounded,
                    color: AppColors.textPrimaryColor,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingSkeleton() {
    return Container(
      padding: const EdgeInsets.only(top: 120),
      child: Skeletonizer(
        enabled: true,
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: 3,
          itemBuilder: (context, index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 180,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.glassColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.only(bottom: 20),
                ),
                ...List.generate(2, (matchIndex) {
                  return Container(
                    height: 140,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.glassColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.glassBorderColor,
                        width: 0.5,
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 32),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Container(
      padding: const EdgeInsets.only(top: 120),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.glassColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.glassBorderColor, width: 0.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: AppColors.errorColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Something went wrong',
                style: AppTexts.emphasizedTextStyle(
                  context: context,
                  textColor: AppColors.textPrimaryColor,
                  fontSize: AppFontSizes(context).size20,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                error,
                style: AppTexts.bodyTextStyle(
                  context: context,
                  textColor: AppColors.textSecondaryColor,
                  fontSize: AppFontSizes(context).size14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _buildGlassButton(
                onPressed: () {
                  context.read<Brackets>().fetchTournamentData(widget.tournamentId);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.refresh_rounded, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Try Again',
                      style: AppTexts.bodyTextStyle(
                        context: context,
                        textColor: AppColors.textPrimaryColor,
                        fontSize: AppFontSizes(context).size16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                color: AppColors.accentBlueColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Container(
      padding: const EdgeInsets.only(top: 120),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.glassColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.glassBorderColor, width: 0.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.textTertiaryColor,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.sports_cricket_rounded,
                  size: 48,
                  color: AppColors.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No tournament data',
                style: AppTexts.emphasizedTextStyle(
                  context: context,
                  textColor: AppColors.textPrimaryColor,
                  fontSize: AppFontSizes(context).size20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tournament brackets will appear here once available',
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
    );
  }

  Widget _buildTournamentBrackets(Brackets provider) {
    final rounds = provider.getSortedRounds();

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 120, left: 20, right: 20, bottom: 20),
            itemCount: rounds.length,
            itemBuilder: (context, index) {
              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 800 + (index * 200)),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 50 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: _buildRoundSection(rounds[index], provider, index),
                    ),
                  );
                },
              );
            },
          ),
        ),
        if (widget.isOrganizer &&
            provider.canGenerateNextRound() &&
            widget.tournamentStatus != 'Completed')
          _buildActionButton(provider),
      ],
    );
  }

  Widget _buildRoundSection(TournamentRound round, Brackets provider, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.accentGradient[index % AppColors.accentGradient.length],
                  AppColors.accentGradient[(index + 1) % AppColors.accentGradient.length],
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.glassBorderColor, width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentGradient[index % AppColors.accentGradient.length]
                      .withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.glassLightColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.emoji_events_rounded,
                    color: AppColors.textPrimaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        round.roundName,
                        style: AppTexts.emphasizedTextStyle(
                          context: context,
                          textColor: AppColors.textPrimaryColor,
                          fontSize: AppFontSizes(context).size22,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Round ${round.roundNumber}',
                        style: AppTexts.bodyTextStyle(
                          context: context,
                          textColor: AppColors.textPrimaryColor.withOpacity(0.8),
                          fontSize: AppFontSizes(context).size14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.glassLightColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${round.matches.length} ${round.matches.length == 1 ? 'match' : 'matches'}',
                    style: AppTexts.bodyTextStyle(
                      context: context,
                      textColor: AppColors.textPrimaryColor,
                      fontSize: AppFontSizes(context).size12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...round.matches.asMap().entries.map(
                (entry) {
              final matchIndex = entry.key;
              final match = entry.value;
              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 600 + (matchIndex * 100)),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return MatchCardInBracketsView(
                    match: match,
                    isOrganizer: widget.isOrganizer,
                    onScheduleMatch: _scheduleMatch,
                    onUpdateScore: _updateScore,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(Brackets provider) {
    final isFinal = _isFinalRound();
    final isFinalCompleted = _isFinalMatchCompleted();

    return Container(
      padding: const EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.glassColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorderColor, width: 0.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isFinal && isFinalCompleted
                    ? () => Navigator.of(context).pop()
                    : provider.canGenerateNextRound()
                    ? () => provider.generateNextRound(widget.tournamentId, context)
                    : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isFinal && isFinalCompleted
                          ? [AppColors.errorColor, AppColors.errorColor.withOpacity(0.8)]
                          : [AppColors.primaryColor, AppColors.primaryLightColor],
                    ),
                  ),
                  child: provider.nextRoundLoading
                      ? SizedBox(
                    height: 24,
                    child: SpinKitThreeBounce(
                      color: AppColors.textPrimaryColor,
                      size: 20,
                    ),
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isFinal && isFinalCompleted
                            ? Icons.close_rounded
                            : Icons.refresh_rounded,
                        size: 24,
                        color: AppColors.textPrimaryColor,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isFinal && isFinalCompleted
                            ? 'Close Tournament'
                            : 'Generate Next Round',
                        style: AppTexts.emphasizedTextStyle(
                          context: context,
                          textColor: AppColors.textPrimaryColor,
                          fontSize: AppFontSizes(context).size16,
                        ),
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
  }

  Widget _buildGlassButton({
    required VoidCallback onPressed,
    required Widget child,
    Color? color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color?.withOpacity(0.1) ?? AppColors.glassColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color?.withOpacity(0.3) ?? AppColors.glassBorderColor,
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _scheduleMatch(MyMatch match) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primaryColor,
              surface: AppColors.darkSecondaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      final TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppColors.primaryColor,
                surface: AppColors.darkSecondaryColor,
              ),
            ),
            child: child!,
          );
        },
      );

      if (selectedTime != null) {
        final DateTime combinedDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        final String formattedDate = DateFormat(
          "yyyy-MM-dd'T'HH:mm:ss'Z'",
        ).format(combinedDateTime.toUtc());

        final success = await context.read<Brackets>().scheduleMatch(
          match.id,
          formattedDate,
          widget.tournamentId,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Container(
                decoration: BoxDecoration(
                  color: AppColors.glassColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        success
                            ? 'Match scheduled successfully'
                            : 'Failed to schedule match',
                        style: AppTexts.bodyTextStyle(
                          context: context,
                          textColor: AppColors.textPrimaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
          );
        }
      }
    }
  }

  Future<void> _updateScore(MyMatch match) async {
    final result = await Navigator.push<UpdateScoreRequest>(
      context,
      MaterialPageRoute(builder: (context) => ScoreScreen(match: match)),
    );

    if (result != null) {
      final success = await context.read<Brackets>().updateMatchScore(
        match.id,
        result,
        widget.tournamentId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Container(
              decoration: BoxDecoration(
                color: AppColors.glassColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      success
                          ? 'Match score updated successfully'
                          : 'Failed to update match score',
                      style: AppTexts.bodyTextStyle(
                        context: context,
                        textColor: AppColors.textPrimaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        );
      }
    }
  }
}