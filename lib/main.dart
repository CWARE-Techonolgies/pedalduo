import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:pedalduo/chat/chat_room_provider.dart';
import 'package:pedalduo/payments/easy_paisa_payment_provider.dart';
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
import 'package:pedalduo/services/connectivity_wrapper.dart';
import 'package:pedalduo/style/colors.dart';
import 'package:pedalduo/views/invitation/invitation_provider.dart';
import 'package:pedalduo/views/play/providers/brackets_provider.dart';
import 'package:pedalduo/views/play/providers/matches_provider.dart';
import 'package:pedalduo/views/play/providers/team_provider.dart';
import 'package:pedalduo/views/play/providers/tournament_provider.dart';
import 'package:pedalduo/views/play/providers/user_profile_provider.dart';
import 'package:pedalduo/views/profile/customer_support/support_provider.dart';
import 'package:pedalduo/views/splash_screen.dart';
import 'package:provider/provider.dart';

import 'chat/chat_provider.dart';
import 'firebase_options.dart';
import 'helper/fcm_service.dart';
import 'helper/keyboard_observer.dart';

/// Handles background FCM messages
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("📩 Background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await FCMService().init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    FCMService.setNavigatorKey(MyApp.navigatorKey);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Clear badge when app becomes active or is resumed
    if (state == AppLifecycleState.resumed) {
      FCMService().clearBadgeCount();
      debugPrint('🔄 App resumed - clearing badge');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserAuthProvider()),
        ChangeNotifierProvider(create: (context) => NavigationProvider()),
        ChangeNotifierProvider(create: (context) => CreateTeamProvider()),
        ChangeNotifierProvider(create: (context) => CourtsProvider()),
        ChangeNotifierProvider(create: (context) => TennisScoringProvider()),
        ChangeNotifierProvider(create: (context) => HighlightsProvider()),
        ChangeNotifierProvider(create: (context) => ConnectivityProvider()),
        ChangeNotifierProvider(create: (context) => ServerHealthProvider()),
        ChangeNotifierProvider(create: (context) => EasyPaisaPaymentProvider()),
        ChangeNotifierProvider(create: (context) => TournamentProvider()),
        ChangeNotifierProvider(create: (context) => Brackets()),
        ChangeNotifierProvider(create: (context) => UserProfileProvider()),
        ChangeNotifierProvider(create: (context) => TeamProvider()),
        ChangeNotifierProvider(create: (context) => TeamAddPlayersProvider()),
        ChangeNotifierProvider(create: (context) => MatchesProvider()),
        ChangeNotifierProvider(create: (context) => ChatRoomsProvider()),
        ChangeNotifierProvider(create: (context) => AllPlayersProvider()),
        ChangeNotifierProvider(create: (context) => ChatProvider()),
        ChangeNotifierProvider(create: (context) => NotificationProvider()),
        ChangeNotifierProvider(create: (context) => InvitationsProvider()),
        ChangeNotifierProvider(create: (context) => SupportTicketProvider()),
      ],
      child: MaterialApp(
        navigatorKey: MyApp.navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Pedalduo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.orangeColor),
        ),
        builder: (context, child) {
          return ConnectivityWrapper(
            child: GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: child ?? const SizedBox(),
            ),
          );
        },
        navigatorObservers: [KeyboardDismissNavigatorObserver()],
        home: const SplashScreen(),
      ),
    );
  }
}