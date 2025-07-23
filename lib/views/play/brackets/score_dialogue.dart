import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../style/colors.dart';
import '../../../style/fonts_sizes.dart';
import '../../../style/texts.dart';
import '../models/tournament_data.dart';

class ScoreScreen extends StatefulWidget {
  final MyMatch match;

  const ScoreScreen({super.key, required this.match});

  @override
  State<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen>
    with TickerProviderStateMixin {
  final TextEditingController _team1ScoreController = TextEditingController();
  final TextEditingController _team2ScoreController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  bool _team1NoShow = false;
  bool _team2NoShow = false;
  bool _bothNoShow = false;

  int? _team1Score;
  int? _team2Score;
  Team? _winnerTeam;

  @override
  void initState() {
    super.initState();
    _team1ScoreController.addListener(_updateWinner);
    _team2ScoreController.addListener(_updateWinner);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _team1ScoreController.dispose();
    _team2ScoreController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _updateWinner() {
    setState(() {
      _team1Score = int.tryParse(_team1ScoreController.text);
      _team2Score = int.tryParse(_team2ScoreController.text);

      if (_team1Score != null && _team2Score != null) {
        if (_team1Score! > _team2Score!) {
          _winnerTeam = widget.match.team1;
        } else if (_team2Score! > _team1Score!) {
          _winnerTeam = widget.match.team2;
        } else {
          _winnerTeam = null; // Tie case
        }
      } else {
        _winnerTeam = null;
      }
    });
  }

  void _updateNoShowStatus() {
    setState(() {
      if (_bothNoShow) {
        _team1NoShow = true;
        _team2NoShow = true;
        _winnerTeam = null;
      } else {
        if (_team1NoShow && !_team2NoShow) {
          _winnerTeam = widget.match.team2;
        } else if (_team2NoShow && !_team1NoShow) {
          _winnerTeam = widget.match.team1;
        } else if (!_team1NoShow && !_team2NoShow) {
          _updateWinner();
        }
      }
    });
  }

  Widget _glassMorphContainer({
    required Widget child,
    double opacity = 0.1,
    Color? borderColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(opacity),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor ?? Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1a1a2e),
              const Color(0xFF16213e),
              const Color(0xFF0f3460),
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 50 * _slideAnimation.value),
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Column(
                    children: [
                      _buildAppBar(),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              _buildMatchHeader(),
                              const SizedBox(height: 32),
                              _buildTeamScoreSection(),
                              const SizedBox(height: 32),
                              _buildNoShowSection(),
                              const SizedBox(height: 32),
                              _buildWinnerSection(),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return _glassMorphContainer(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Update Match Score',
                style: AppTexts.emphasizedTextStyle(
                  context: context,
                  textColor: Colors.white,
                  fontSize: AppFontSizes(context).size20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchHeader() {
    return _glassMorphContainer(
      opacity: 0.15,
      borderColor: AppColors.greenColor.withOpacity(0.3),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.sports_soccer,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Match ${widget.match.matchNumber}',
                    style: AppTexts.emphasizedTextStyle(
                      context: context,
                      textColor: Colors.white,
                      fontSize: AppFontSizes(context).size24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.match.roundName,
                    style: AppTexts.bodyTextStyle(
                      context: context,
                      textColor: Colors.white70,
                      fontSize: AppFontSizes(context).size16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamScoreSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Team Scores',
          style: AppTexts.emphasizedTextStyle(
            context: context,
            textColor: Colors.white,
            fontSize: AppFontSizes(context).size20,
          ),
        ),
        const SizedBox(height: 20),
        _buildTeamScoreCard(
          widget.match.team1,
          _team1ScoreController,
          _team1NoShow,
          isFirst: true,
        ),
        const SizedBox(height: 16),
        _buildVersusIndicator(),
        const SizedBox(height: 16),
        _buildTeamScoreCard(
          widget.match.team2,
          _team2ScoreController,
          _team2NoShow,
          isFirst: false,
        ),
      ],
    );
  }

  Widget _buildVersusIndicator() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'VS',
          style: AppTexts.emphasizedTextStyle(
            context: context,
            textColor: Colors.white70,
            fontSize: AppFontSizes(context).size16,
          ),
        ),
      ),
    );
  }

  Widget _buildTeamScoreCard(
      Team team,
      TextEditingController controller,
      bool noShow, {
        required bool isFirst,
      }) {
    return _glassMorphContainer(
      opacity: 0.12,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.greenColor, AppColors.lightOrangeColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Text(
                  team.name.isNotEmpty ? team.name[0].toUpperCase() : 'T',
                  style: AppTexts.emphasizedTextStyle(
                    context: context,
                    textColor: Colors.white,
                    fontSize: AppFontSizes(context).size18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    team.name,
                    style: AppTexts.emphasizedTextStyle(
                      context: context,
                      textColor: Colors.white,
                      fontSize: AppFontSizes(context).size18,
                    ),
                  ),
                  if (noShow) ...[
                    const SizedBox(height: 4),
                    Text(
                      'No Show',
                      style: AppTexts.bodyTextStyle(
                        context: context,
                        textColor: AppColors.redColor,
                        fontSize: AppFontSizes(context).size12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              width: 100,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: controller,
                enabled: !noShow && !_bothNoShow,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                decoration: InputDecoration(
                  hintText: '0',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                style: AppTexts.emphasizedTextStyle(
                  context: context,
                  textColor: Colors.white,
                  fontSize: AppFontSizes(context).size24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoShowSection() {
    return _glassMorphContainer(
      opacity: 0.08,
      borderColor: AppColors.redColor.withOpacity(0.3),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.redColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'No Show Options',
                  style: AppTexts.emphasizedTextStyle(
                    context: context,
                    textColor: AppColors.redColor,
                    fontSize: AppFontSizes(context).size18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildNoShowCheckbox('Both teams no show', _bothNoShow, (value) {
              setState(() {
                _bothNoShow = value ?? false;
                if (_bothNoShow) {
                  _team1NoShow = true;
                  _team2NoShow = true;
                  _team1ScoreController.clear();
                  _team2ScoreController.clear();
                } else {
                  _team1NoShow = false;
                  _team2NoShow = false;
                }
                _updateNoShowStatus();
              });
            }),
            const SizedBox(height: 12),
            _buildNoShowCheckbox(
              '${widget.match.team1.name} no show',
              _team1NoShow && !_bothNoShow,
                  (value) {
                setState(() {
                  _team1NoShow = value ?? false;
                  if (_team1NoShow) {
                    _team1ScoreController.clear();
                  }
                  _updateNoShowStatus();
                });
              },
              enabled: !_bothNoShow,
            ),
            const SizedBox(height: 12),
            _buildNoShowCheckbox(
              '${widget.match.team2.name} no show',
              _team2NoShow && !_bothNoShow,
                  (value) {
                setState(() {
                  _team2NoShow = value ?? false;
                  if (_team2NoShow) {
                    _team2ScoreController.clear();
                  }
                  _updateNoShowStatus();
                });
              },
              enabled: !_bothNoShow,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoShowCheckbox(
      String title,
      bool value,
      Function(bool?) onChanged, {
        bool enabled = true,
      }) {
    return GestureDetector(
      onTap: enabled ? () => onChanged(!value) : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: value ? AppColors.redColor.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: value ? AppColors.redColor : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: enabled ? AppColors.redColor : Colors.white54,
                  width: 2,
                ),
              ),
              child: value
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: AppTexts.bodyTextStyle(
                  context: context,
                  textColor: enabled ? Colors.white : Colors.white54,
                  fontSize: AppFontSizes(context).size16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWinnerSection() {
    return _glassMorphContainer(
      opacity: 0.12,
      borderColor: _winnerTeam != null
          ? AppColors.greenColor.withOpacity(0.5)
          : Colors.white.withOpacity(0.2),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _winnerTeam != null
                        ? AppColors.greenColor.withOpacity(0.8)
                        : Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _winnerTeam != null ? Icons.emoji_events : Icons.help_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Match Winner',
                        style: AppTexts.bodyTextStyle(
                          context: context,
                          textColor: Colors.white70,
                          fontSize: AppFontSizes(context).size14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _winnerTeam?.name ?? 'To Be Determined',
                        style: AppTexts.emphasizedTextStyle(
                          context: context,
                          textColor: _winnerTeam != null ? Colors.white : Colors.white54,
                          fontSize: AppFontSizes(context).size20,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_winnerTeam != null &&
                _team1Score != null &&
                _team2Score != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            '${widget.match.team1.name}:',
                            style: AppTexts.bodyTextStyle(
                              context: context,
                              textColor: Colors.white,
                              fontSize: AppFontSizes(context).size16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '$_team1Score',
                          style: AppTexts.emphasizedTextStyle(
                            context: context,
                            textColor: Colors.white,
                            fontSize: AppFontSizes(context).size18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            '${widget.match.team2.name}:',
                            style: AppTexts.bodyTextStyle(
                              context: context,
                              textColor: Colors.white,
                              fontSize: AppFontSizes(context).size16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '$_team2Score',
                          style: AppTexts.emphasizedTextStyle(
                            context: context,
                            textColor: Colors.white,
                            fontSize: AppFontSizes(context).size18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Cancel',
                    style: AppTexts.emphasizedTextStyle(
                      context: context,
                      textColor: Colors.white70,
                      fontSize: AppFontSizes(context).size16,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: _canSubmit() ? _submitScore : null,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: _canSubmit()
                      ? LinearGradient(
                    colors: [
                      AppColors.greenColor,
                      AppColors.lightOrangeColor,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                      : null,
                  color: _canSubmit() ? null : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _canSubmit()
                      ? [
                    BoxShadow(
                      color: AppColors.greenColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    'Submit Score',
                    style: AppTexts.emphasizedTextStyle(
                      context: context,
                      textColor: _canSubmit() ? Colors.white : Colors.white54,
                      fontSize: AppFontSizes(context).size16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canSubmit() {
    if (_bothNoShow) return true;
    if (_team1NoShow || _team2NoShow) return true;
    return _team1Score != null && _team2Score != null;
  }

  void _submitScore() {
    String matchStatus;
    int? winnerTeamId;

    if (_bothNoShow) {
      matchStatus = 'No Show';
      winnerTeamId = null;
    } else if (_team1NoShow || _team2NoShow) {
      matchStatus = 'No Show';
      winnerTeamId = _winnerTeam?.id;
    } else {
      matchStatus = 'completed';
      winnerTeamId = _winnerTeam?.id;
    }

    final request = UpdateScoreRequest(
      winnerTeamId: winnerTeamId,
      team1Score: _team1Score,
      team2Score: _team2Score,
      matchStatus: matchStatus,
      team1NoShow: _team1NoShow,
      team2NoShow: _team2NoShow,
    );

    Navigator.of(context).pop(request);
  }
}