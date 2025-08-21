import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:pedalduo/provider_setup/provider_setup.dart';
import 'package:pedalduo/services/connectivity_wrapper.dart';
import 'package:pedalduo/style/colors.dart';
import 'package:pedalduo/views/splash_screen.dart';
import 'package:pedalduo/helper/fcm_service.dart';
import 'package:pedalduo/helper/keyboard_observer.dart';
import 'package:pedalduo/firebase_options.dart';
import 'package:provider/provider.dart';

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
    if (state == AppLifecycleState.resumed) {
      FCMService().clearBadgeCount();
      debugPrint('🔄 App resumed - clearing badge');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: Providers.initializeProviders(),
      child: MaterialApp(
        navigatorKey: MyApp.navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Padel Duo',
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
