// lib/screens/tennis_scoring_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pedalduo/views/play/brackets/scoring_widgets.dart';
import 'package:pedalduo/views/play/brackets/widgets/tennis_glass_morpishm_container.dart';
import 'package:pedalduo/views/play/brackets/widgets/tennis_sets_history.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../../providers/tennis_scoring_provider.dart';
import '../../../style/colors.dart';
import '../providers/brackets_provider.dart';

class TennisScoringScreen extends StatefulWidget {
  final int matchId;
  final int tournamentId;

  const TennisScoringScreen({
    super.key,
    required this.matchId,
    required this.tournamentId,
  });

  @override
  State<TennisScoringScreen> createState() => _TennisScoringScreenState();
}

class _TennisScoringScreenState extends State<TennisScoringScreen>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _slideController;
  late AnimationController _scoreController;
  late AnimationController _pulseController;

  // Animations
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scoreAnimation;
  late Animation<double> _pulseAnimation;

  // Flag to prevent multiple dialogs
  bool _dialogShown = false;
  // Flag to track if we're navigating away
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();

    // Load tennis score after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TennisScoringProvider>().loadTennisScore(widget.matchId);
      }
    });
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
    );

    _scoreAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scoreController, curve: Curves.elasticOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scoreController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleAddPoint(String team) async {
    // Prevent multiple rapid taps and check if already updating
    if (_isNavigating) return;

    final provider = context.read<TennisScoringProvider>();

    // Check if already updating to prevent duplicate calls
    if (provider.isUpdating) {
      if (kDebugMode) {
        print('⚠️ Ignoring tap - already updating score');
      }
      return;
    }

    try {
      // Add point and wait for completion
      await provider.addPoint(team);

      // Only animate after successful score update
      if (mounted && !_isNavigating) {
        _scoreController.forward().then((_) {
          if (mounted && !_isNavigating) {
            _scoreController.reset();
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error adding point: $e');
      }
    }
  }


  void _handleNoShow() async {
    if (_isNavigating) return; // Don't handle no-show if navigating away

    final provider = context.read<TennisScoringProvider>();
    await provider.handleNoShow();

    // Don't automatically navigate - let the match completion dialog handle it
    if (mounted && !_isNavigating) {
      // The provider will trigger the match completed state
      // which will show the dialog through the listener
    }
  }

  void _navigateBack() {
    if (_isNavigating) return;

    _isNavigating = true;
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context
            .read<Brackets>()
            .fetchTournamentData(widget.tournamentId.toString())
            .then((_) {
              Navigator.of(context).pop();
            });
      });
    }
  }

  void _showMatchCompletedDialog(String? winner) {
    if (_dialogShown || _isNavigating) return;
    _dialogShown = true;

    final provider = context.read<TennisScoringProvider>();

    // Use post frame callback to ensure widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isNavigating) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => _buildMatchCompletedDialog(winner, provider),
        ).then((_) {
          if (mounted) {
            _dialogShown = false;
          }
        });
      }
    });
  }

  void _showErrorSnackBar(String message) {
    if (mounted && !_isNavigating) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TennisScoringProvider>(
      builder: (context, provider, child) {
        // Listen for match completion and errors using post frame callback
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _isNavigating) return;

          if (provider.isMatchCompleted && !provider.isError && !_dialogShown) {
            _showMatchCompletedDialog(provider.winner);
          }

          if (provider.isError && provider.error != null) {
            _showErrorSnackBar(provider.error!);
            provider.clearError();
          }
        });

        return Scaffold(
          backgroundColor: Color(0xFF0f3460),
          appBar: TennisMatchAppBar(
            matchTypeDisplay:
                provider.hasData
                    ? provider.getMatchTypeDisplay()
                    : 'Loading...',
            status: provider.hasData ? provider.match!.status : 'Loading',
            onBackPressed: _navigateBack,
          ),
          body: Container(
            decoration: const BoxDecoration(),
            child: SafeArea(
              child: AnimatedBuilder(
                animation: _slideController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 30 * _slideAnimation.value),
                    child: Opacity(
                      opacity: _fadeAnimation.value,
                      child: _buildContent(provider),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(TennisScoringProvider provider) {
    if (provider.isLoading) {
      return TennisLoadingView(slideController: _slideController);
    }

    if (provider.isError) {
      return TennisErrorView(
        error: provider.error,
        onRetry: () {
          if (!_isNavigating) {
            provider.loadTennisScore(widget.matchId);
          }
        },
      );
    }

    if (!provider.hasData) {
      return const Center(
        child: Text(
          'No match data available',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return _buildMainContent(provider);
  }

  Widget _buildMainContent(TennisScoringProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Unified Score Board with integrated point addition
          TennisUnifiedScoreBoard(
            match: provider.match!,
            tennisScore: provider.tennisScore!,
            currentGame: provider.tennisScore!.currentGame,
            formatPointsDisplay: provider.formatPointsDisplay,
            scoreAnimation: _scoreAnimation,
            pulseAnimation: _pulseAnimation,
            isUpdating: provider.isUpdating,
            onAddPoint: _handleAddPoint,
          ),
          const SizedBox(height: 24),

          // No Show section - only show if match is not completed
          if (!provider.isMatchCompleted)
            TennisNoShowSection(
              match: provider.match!,
              team1NoShow: provider.team1NoShow,
              team2NoShow: provider.team2NoShow,
              bothNoShow: provider.bothNoShow,
              isUpdating: provider.isUpdating,
              onNoShowChanged: provider.updateNoShowState,
              onSubmitNoShow: _handleNoShow,
            ),

          if (!provider.isMatchCompleted) const SizedBox(height: 24),

          // Sets History (only if there are completed sets)
          if (provider.tennisScore!.setsHistory.isNotEmpty)
            TennisSetsHistory(
              setsHistory: provider.tennisScore!.setsHistory,
              match: provider.match!,
            ),
        ],
      ),
    );
  }

  Widget _buildMatchCompletedDialog(
    String? winner,
    TennisScoringProvider provider,
  ) {
    final winnerTeam =
        winner == 'team1'
            ? provider.match!.team1
            : winner == 'team2'
            ? provider.match!.team2
            : null;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: TennisGlassMorphContainer(
          borderColor: AppColors.successColor.withOpacity(0.5),
          child: Container(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.successColor, AppColors.primaryColor],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.successColor.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.emoji_events,
                    color: AppColors.textPrimaryColor,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Match Completed!',
                  style: TextStyle(
                    color: AppColors.textPrimaryColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                if (winnerTeam != null) ...[
                  Text(
                    'Winner',
                    style: TextStyle(
                      color: AppColors.textSecondaryColor,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    winnerTeam.name,
                    style: TextStyle(
                      color: AppColors.successColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ] else ...[
                  Text(
                    'Match ended in a tie',
                    style: TextStyle(
                      color: AppColors.textSecondaryColor,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () {
                    _navigateBack();
                    // if (mounted) {
                    //   //
                    //
                    // }
                    // Navigator.of(context).pop();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
                      'Continue',
                      style: TextStyle(
                        color: AppColors.textPrimaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
