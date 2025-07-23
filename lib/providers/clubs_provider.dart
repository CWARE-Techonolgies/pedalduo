import 'package:flutter/material.dart';
import '../models/clubs_models.dart';

class ClubsProvider extends ChangeNotifier {
  final List<ClubItem> _clubs = [
    ClubItem(
      name: 'Tennis Pakistan',
      members: '42 members',
      imageUrl: 'assets/images/tennis_pakistan.jpg',
    ),
    ClubItem(
      name: 'Karachi Sharks',
      members: '38 members',
      imageUrl: 'assets/images/karachi_sharks.jpg',
    ),
    ClubItem(
      name: 'Team Tennis Lahore',
      members: '56 members',
      imageUrl: 'assets/images/team_tennis_lahore.jpg',
    ),
    ClubItem(
      name: 'Islamabad Tennis Royals',
      members: '29 members',
      imageUrl: 'assets/images/islamabad_tennis_royals.jpg',
    ),
  ];

  List<ClubItem> get clubs => _clubs;
}