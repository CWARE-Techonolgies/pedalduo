import 'package:flutter/material.dart';

import '../models/courts_models.dart';

class CourtsProvider extends ChangeNotifier {
  final List<CourtItem> _courts = [
    CourtItem(name: 'Padel Arena', location: 'Model Town', courts: 2),
    CourtItem(name: 'Lets Padel', location: 'Packages Mall', courts: 2),
    CourtItem(name: 'Club Padel', location: 'DHA Phase 4', courts: 3),
    CourtItem(name: 'Padel In', location: 'DHA Phase 5', courts: 9),
    CourtItem(name: 'Padel Pro', location: 'DHA Phase 5', courts: 2),
    CourtItem(name: 'Padel Star', location: 'DHA Phase 5', courts: 1),
    CourtItem(name: 'The Big Game', location: 'DHA Phase 5', courts: 2),
    CourtItem(name: 'Padel Park', location: 'DHA Phase 5', courts: 2),
    CourtItem(name: 'Padel Club', location: 'DHA Phase 5', courts: 2),
    CourtItem(name: 'Padel Hub', location: 'DHA Phase 5', courts: 2),
    CourtItem(name: 'Space Padel', location: 'DHA Phase 5', courts: 2),
    CourtItem(name: 'Padel Connect', location: 'DHA Phase 5', courts: 2),
    CourtItem(name: 'Mega Arena', location: 'DHA Phase 5', courts: 6),
    CourtItem(name: 'Futsal Range', location: 'DHA Phase 5', courts: 2),
    CourtItem(name: '5th Generation', location: 'DHA Phase 6', courts: 1),
    CourtItem(name: 'Jumbo Jump Padel', location: 'DHA Phase 8', courts: 6),
    CourtItem(name: 'Padel Rush', location: 'DHA Phase 9', courts: 2),
    CourtItem(name: 'Palm Padel', location: 'Bedian Road', courts: 2),
    CourtItem(name: 'Fusion Station', location: 'Bedian Road', courts: 2),
    CourtItem(name: 'Padel Pro', location: 'Barki Road', courts: 2),
    CourtItem(name: 'Padel Mania', location: 'Barki Road', courts: 2),
    CourtItem(name: 'The Courts', location: 'Gulberg', courts: 1),
    CourtItem(name: 'Sky Padel', location: 'Gulberg', courts: 2),
    CourtItem(name: 'Padel Central', location: 'Gulberg', courts: 2),
    CourtItem(name: 'Lot Six', location: 'Gulberg', courts: 1),
    CourtItem(name: 'Padel Social', location: 'Gulberg', courts: 2),
    CourtItem(name: 'Padellina', location: 'Barkat Market', courts: 1),
    CourtItem(name: 'Padel X', location: 'Johar Town', courts: 1),
    CourtItem(name: 'Padelland', location: 'Johar Town', courts: 1),
    CourtItem(name: 'Beach Club Padel', location: 'Johar Town', courts: 1),
    CourtItem(name: 'Arena 360', location: 'Johar Town', courts: 1),
    CourtItem(name: 'Padel Shadel', location: 'Wapda Town', courts: 2),
    CourtItem(name: 'Cross Courts', location: 'Valencia', courts: 2),
    CourtItem(name: 'Wynn Sports Arena', location: 'Valencia', courts: 2),
    CourtItem(name: 'Pro Ball Arena', location: 'Valencia', courts: 2),
    CourtItem(name: 'Futsal Range', location: 'Valencia', courts: 2),
    CourtItem(name: 'The Box', location: 'Pine Avenue', courts: 2),
    CourtItem(name: 'Padel Next', location: 'Pine Avenue', courts: 1),
    CourtItem(name: 'Padel Play', location: 'Bahria Town', courts: 2),
    CourtItem(name: 'Pulse Active', location: 'Bahria Town', courts: 3),
    CourtItem(name: 'Padel Plus', location: 'DHA EME', courts: 2),
    CourtItem(name: 'The Mad Padel', location: 'DHA EME', courts: 1),
    CourtItem(name: 'Padel Cafe', location: 'DHA Phase 6', courts: 2),
  ];

  List<CourtItem> get courts => _courts;

  // Get courts by location
  List<String> get locations {
    return _courts.map((court) => court.location).toSet().toList()..sort();
  }

  // Filter courts by location
  List<CourtItem> getCourtsByLocation(String location) {
    return _courts.where((court) => court.location == location).toList();
  }

  // Get total number of courts
  int get totalCourts {
    return _courts.fold(0, (sum, court) => sum + court.courts);
  }

  // Search courts by name
  List<CourtItem> searchCourts(String query) {
    if (query.isEmpty) return _courts;
    return _courts
        .where((court) =>
    court.name.toLowerCase().contains(query.toLowerCase()) ||
        court.location.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}