import 'package:flutter/material.dart';

import '../models/highlights_model.dart';

class HighlightsProvider extends ChangeNotifier {
  int _selectedTab = 0;

  int get selectedTab => _selectedTab;

  void setSelectedTab(int index) {
    _selectedTab = index;
    notifyListeners();
  }
  final List<HighlightItem> _highlights = [
    HighlightItem(
      title: 'Match Winning Shot!',
      author: 'Saud Gul',
      timeAgo: '2 days ago',
      likes: '1.2k',
      comments: '84',
    ),
    HighlightItem(
      title: 'Match Winning Shot!',
      author: 'Tanveer Hussain',
      timeAgo: '2 days ago',
      likes: '1.2k',
      comments: '84',
    ),
    HighlightItem(
      title: 'Match Winning Shot!',
      author: 'Muhammad Awais',
      timeAgo: '2 days ago',
      likes: '1.2k',
      comments: '84',
    ),
    HighlightItem(
      title: 'Match Winning Shot!',
      author: 'Fezan Ali',
      timeAgo: '2 days ago',
      likes: '1.2k',
      comments: '84',
    ),
  ];

  List<HighlightItem> get highlights => _highlights;
}