import 'package:flutter/material.dart';
import 'package:pedalduo/chat/chat_room_provider.dart';
import 'package:pedalduo/payments/easy_paisa_payment_provider.dart';
import 'package:pedalduo/providers/activity_provider.dart';
import 'package:pedalduo/providers/add_players_provider.dart';
import 'package:pedalduo/providers/auth_provider.dart';
import 'package:pedalduo/providers/clubs_provider.dart';
import 'package:pedalduo/providers/connectivity_provider.dart';
import 'package:pedalduo/providers/highlights_provider.dart';
import 'package:pedalduo/providers/navigation_provider.dart';
import 'package:pedalduo/providers/notification_provider.dart';
import 'package:pedalduo/providers/server_health_provider.dart';
import 'package:pedalduo/services/connectivity_wrapper.dart';
import 'package:pedalduo/style/colors.dart';
import 'package:pedalduo/views/home_screen/views/home_screen.dart';
import 'package:pedalduo/views/invitation/invitation_provider.dart';
import 'package:pedalduo/views/play/providers/brackets_provider.dart';
import 'package:pedalduo/views/play/providers/matches_provider.dart';
import 'package:pedalduo/views/play/providers/team_provider.dart';
import 'package:pedalduo/views/play/providers/tournament_provider.dart';
import 'package:pedalduo/views/play/providers/user_profile_provider.dart';
import 'package:pedalduo/views/splash_screen.dart';
import 'package:provider/provider.dart';

import 'chat/chat_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.exceptionAsString().contains('KeyUpEvent') &&
        details.exceptionAsString().contains('_pressedKeys.containsKey')) {
      // Suppress the error for this specific case
      debugPrint('Suppressed known KeyUpEvent Flutter bug.');
    } else {
      FlutterError.presentError(details);
    }
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserAuthProvider()),
        ChangeNotifierProvider(create: (context) => NavigationProvider()),
        ChangeNotifierProvider(create: (context) => ActivityProvider()),
        ChangeNotifierProvider(create: (context) => ClubsProvider()),
        ChangeNotifierProvider(create: (context) => HighlightsProvider()),
        ChangeNotifierProvider(create: (context) => ConnectivityProvider()),
        ChangeNotifierProvider(create: (context) => ServerHealthProvider()),
        ChangeNotifierProvider(create: (context) => EasyPaisaPaymentProvider()),
        ChangeNotifierProvider(create: (context) => TournamentProvider()),
        ChangeNotifierProvider(create: (context) => Brackets()),
        ChangeNotifierProvider(create: (context) => UserProfileProvider()),
        ChangeNotifierProvider(create: (context) => TeamProvider()),
        ChangeNotifierProvider(create: (context) => MatchesProvider()),
        ChangeNotifierProvider(create: (context) => ChatRoomsProvider()),
        ChangeNotifierProvider(create: (context) => AddPlayersProvider()),
        ChangeNotifierProvider(create: (context) => ChatProvider()),
        ChangeNotifierProvider(create: (context) => NotificationProvider()),
        ChangeNotifierProvider(create: (context) => InvitationsProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.orangeColor),
        ),
        builder: (context, child) {
          return ConnectivityWrapper(child: child ?? const SizedBox());
        },
        home: SplashScreen(),
      ),
    );
  }
}
