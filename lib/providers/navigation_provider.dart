import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  int _selectedIndex = 2; // Default tab

  int get selectedIndex => _selectedIndex;

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void goToTab(BuildContext context, int index) {
    setSelectedIndex(index);
    Navigator.popUntil(context, (route) => route.isFirst);
  }
}