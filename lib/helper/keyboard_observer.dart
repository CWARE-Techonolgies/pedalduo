import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeyboardDismissNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _dismissKeyboard();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _dismissKeyboard();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _dismissKeyboard();
  }

  void _dismissKeyboard() {
    // Multiple ways to dismiss keyboard
    if (navigator?.context != null) {
      final context = navigator!.context;

      // Method 1: Unfocus current focus
      FocusScope.of(context).unfocus();

      // Method 2: Remove focus from primary focus
      FocusManager.instance.primaryFocus?.unfocus();

      // Method 3: Hide keyboard using SystemChannels
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    }
  }
}