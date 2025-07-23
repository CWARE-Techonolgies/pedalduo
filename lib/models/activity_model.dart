import 'package:flutter/material.dart';

class ActivityItem {
  final String name;
  final String action;
  final String time;
  final IconData icon;
  final Color iconColor;

  ActivityItem({
    required this.name,
    required this.action,
    required this.time,
    required this.icon,
    required this.iconColor,
  });
}
