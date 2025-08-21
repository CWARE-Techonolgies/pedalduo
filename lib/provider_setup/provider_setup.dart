import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pedalduo/chat/chat_room_provider.dart';
import 'package:pedalduo/payments/easy_paisa_payment_provider.dart';
import 'package:pedalduo/providers/delete_account_provider.dart';
import 'package:pedalduo/providers/team_add_players_provider.dart';
import 'package:pedalduo/providers/create_team_provider.dart';
import 'package:pedalduo/providers/all_players_provider.dart';
import 'package:pedalduo/providers/auth_provider.dart';
import 'package:pedalduo/providers/courts_provider.dart';
import 'package:pedalduo/providers/connectivity_provider.dart';
import 'package:pedalduo/providers/highlights_provider.dart';
import 'package:pedalduo/providers/navigation_provider.dart';
import 'package:pedalduo/providers/notification_provider.dart';
import 'package:pedalduo/providers/server_health_provider.dart';
import 'package:pedalduo/providers/tennis_scoring_provider.dart';
import 'package:pedalduo/views/invitation/invitation_provider.dart';
import 'package:pedalduo/views/play/providers/brackets_provider.dart';
import 'package:pedalduo/views/play/providers/matches_provider.dart';
import 'package:pedalduo/views/play/providers/team_provider.dart';
import 'package:pedalduo/views/play/providers/tournament_provider.dart';
import 'package:pedalduo/views/play/providers/user_profile_provider.dart';
import 'package:pedalduo/views/profile/customer_support/support_provider.dart';
import 'package:pedalduo/chat/chat_provider.dart';
import 'package:provider/single_child_widget.dart';

import '../views/notification_management/manage_notification_provider.dart';

class Providers {
  static List<SingleChildWidget> initializeProviders() {
    return [
      // Core providers
      ChangeNotifierProvider(create: (context) => UserAuthProvider()),
      ChangeNotifierProvider(create: (context) => NavigationProvider()),
      ChangeNotifierProvider(create: (context) => ConnectivityProvider()),
      ChangeNotifierProvider(create: (context) => ServerHealthProvider()),
      ChangeNotifierProvider(create: (context) => NotificationProvider()),
      ChangeNotifierProvider(create: (context) => ManageNotificationProvider()),

      // Team and Tournament providers
      ChangeNotifierProvider(create: (context) => CreateTeamProvider()),
      ChangeNotifierProvider(create: (context) => TeamProvider()),
      ChangeNotifierProvider(create: (context) => TeamAddPlayersProvider()),
      ChangeNotifierProvider(create: (context) => TournamentProvider()),
      ChangeNotifierProvider(create: (context) => Brackets()),
      ChangeNotifierProvider(create: (context) => MatchesProvider()),

      // Court and Scoring providers
      ChangeNotifierProvider(create: (context) => CourtsProvider()),
      ChangeNotifierProvider(create: (context) => TennisScoringProvider()),
      ChangeNotifierProvider(create: (context) => HighlightsProvider()),

      // User and Profile providers
      ChangeNotifierProvider(create: (context) => UserProfileProvider()),
      ChangeNotifierProvider(create: (context) => AllPlayersProvider()),
      ChangeNotifierProvider(create: (context) => DeleteAccountProvider()),

      // Chat providers
      ChangeNotifierProvider(create: (context) => ChatRoomsProvider()),
      ChangeNotifierProvider(create: (context) => ChatProvider()),

      // Payment providers
      ChangeNotifierProvider(create: (context) => EasyPaisaPaymentProvider()),

      // Communication providers
      ChangeNotifierProvider(create: (context) => InvitationsProvider()),
      ChangeNotifierProvider(create: (context) => SupportTicketProvider()),
    ];
  }
}
