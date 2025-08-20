import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pedalduo/views/play/brackets/widgets/tennis_glass_morpishm_container.dart';

import '../../../../models/scoring_system_model.dart';
import '../../../../style/colors.dart';

class TennisSetsHistory extends StatelessWidget {
  final List<SetHistory> setsHistory;
  final TennisMatch match;

  const TennisSetsHistory({
    super.key,
    required this.setsHistory,
    required this.match,
  });

  @override
  Widget build(BuildContext context) {
    if (setsHistory.isEmpty) return const SizedBox.shrink();

    return TennisGlassMorphContainer(
      borderColor: AppColors.infoColor.withOpacity(0.3),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: AppColors.infoColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Sets History',
                  style: TextStyle(
                    color: AppColors.textPrimaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTeamNamesHeader(),
            const SizedBox(height: 12),
            ...setsHistory.map(
              (setHistory) => _buildCompactSetItem(setHistory),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamNamesHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.glassColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.glassBorderColor.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Set',
            style: TextStyle(
              color: AppColors.backgroundColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    match.team1.name,
                    style: TextStyle(
                      color: AppColors.backgroundColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'VS',
                  style: TextStyle(
                    color: AppColors.backgroundColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: Text(
                    match.team2.name,
                    style: TextStyle(
                      color: AppColors.backgroundColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactSetItem(SetHistory setHistory) {
    final isTeam1Winner = setHistory.winner == 'team1';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.glassColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.glassBorderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Set ${setHistory.setNumber}',
            style: TextStyle(
              color: AppColors.textPrimaryColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      isTeam1Winner
                          ? AppColors.successColor.withOpacity(0.2)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border:
                      isTeam1Winner
                          ? Border.all(
                            color: AppColors.successColor.withOpacity(0.3),
                          )
                          : null,
                ),
                child: Text(
                  '${setHistory.team1Games}',
                  style: TextStyle(
                    color:
                        isTeam1Winner
                            ? AppColors.successColor
                            : AppColors.textPrimaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '-',
                style: TextStyle(
                  color: AppColors.textSecondaryColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      !isTeam1Winner
                          ? AppColors.successColor.withOpacity(0.2)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border:
                      !isTeam1Winner
                          ? Border.all(
                            color: AppColors.successColor.withOpacity(0.3),
                          )
                          : null,
                ),
                child: Text(
                  '${setHistory.team2Games}',
                  style: TextStyle(
                    color:
                        !isTeam1Winner
                            ? AppColors.successColor
                            : AppColors.textPrimaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (setHistory.tiebreak != null) ...[
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warningColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.warningColor.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    'TB: ${setHistory.tiebreak!.team1}-${setHistory.tiebreak!.team2}',
                    style: TextStyle(
                      color: AppColors.warningColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
