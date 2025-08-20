enum TournamentStatus {
  underReview,
  approved,
  rejected,
  ongoing,
  completed,
  cancelled
}

extension TournamentStatusExtension on TournamentStatus {
  String get displayName {
    switch (this) {
      case TournamentStatus.underReview:
        return 'Under Review';
      case TournamentStatus.approved:
        return 'Up Coming';
      case TournamentStatus.rejected:
        return 'Rejected';
      case TournamentStatus.ongoing:
        return 'Ongoing';
      case TournamentStatus.completed:
        return 'Completed';
      case TournamentStatus.cancelled:
        return 'Cancelled';
    }
  }
}