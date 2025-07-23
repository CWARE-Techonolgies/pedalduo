import 'package:flutter/material.dart';

import '../models/activity_model.dart';

class ActivityProvider extends ChangeNotifier {
  final List<ActivityItem> _activities = [
    ActivityItem(
      name: 'Farhan Mustafa',
      action: 'liked your highlight',
      time: '2 hours ago',
      icon: Icons.favorite,
      iconColor: Colors.red,
    ),
    ActivityItem(
      name: 'Abdul Rehman',
      action: 'commented: Great innings!',
      time: '5 hours ago',
      icon: Icons.comment,
      iconColor: Colors.blue,
    ),
    ActivityItem(
      name: 'Nameer Shamsi',
      action: 'started following you',
      time: '1 day ago',
      icon: Icons.person_add,
      iconColor: Colors.green,
    ),
    ActivityItem(
      name: 'Seher Khawaja',
      action: 'shared your post',
      time: '2 days ago',
      icon: Icons.share,
      iconColor: Colors.purple,
    ),
  ];

  List<ActivityItem> get activities => _activities;
}