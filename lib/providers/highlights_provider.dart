import 'package:flutter/material.dart';

import '../models/highlights_model.dart';

class HighlightsProvider extends ChangeNotifier {
  int _selectedTab = 0;

  int get selectedTab => _selectedTab;

  void setSelectedTab(int index) {
    _selectedTab = index;
    notifyListeners();
  }

  // Placeholder data - will be replaced with real data later
  final List<HighlightItem> _highlights = [];

  List<HighlightItem> get highlights => _highlights;

  // Method to check if we have real data or just placeholders
  bool get hasRealData => false; // Set to true when real data is loaded

  // Placeholder message for users
  String get placeholderMessage =>
      "🎾 Come back again to check for exciting new highlights and battle updates!";
}
