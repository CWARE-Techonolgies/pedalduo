import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:provider/provider.dart';
import '../chat/chat_room.dart';
import '../chat/chat_room_provider.dart';
import '../chat/chat_screen.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  late final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  bool _isInitialized = false;

  // Add navigation key to access navigator from anywhere
  static GlobalKey<NavigatorState>? navigatorKey;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  static const DarwinNotificationDetails _iOSNotificationDetails =
  DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: false, // Keep this false to prevent auto-badging
    presentSound: true,
  );

  /// Initialize FCM service
  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;

    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await setupFlutterNotifications();
    await requestNotificationPermissions();

    // Clear badge when app starts - use proper iOS method
    await clearBadgeCount();

    // Foreground listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      handleMessage(message, fromForeground: true);
    });

    // Handle notification taps when app is opened from background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      clearBadgeCount(); // Clear badge when notification is tapped
      _handleNotificationTap(message);
    });

    // Check for initial message if app was opened from notification
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      await clearBadgeCount();
      Future.delayed(const Duration(seconds: 1), () {
        _handleNotificationTap(initialMessage);
      });
    }

    debugPrint("✅ FCM Service initialized");
  }

  /// Set the navigator key for navigation
  static void setNavigatorKey(GlobalKey<NavigatorState> key) {
    navigatorKey = key;
  }

  /// Proper iOS badge clearing method
  Future<void> clearBadgeCount() async {
    try {
      if (Platform.isIOS) {
        // Method 1: Use flutter_local_notifications to set badge to 0
        await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(badge: true);

        // Method 2: Clear using native iOS method via method channel
        const platform = MethodChannel('flutter.native/badge');
        try {
          await platform.invokeMethod('clearBadge');
          debugPrint('🔄 Badge cleared via native method channel');
        } catch (e) {
          debugPrint('⚠️ Native badge clear failed, using alternative: $e');

          // Method 3: Alternative - cancel all notifications and use local notification to reset badge
          await _flutterLocalNotificationsPlugin.cancelAll();

          // Create a dummy notification with badge 0 to reset the count
          await _flutterLocalNotificationsPlugin.show(
            999999, // Use a high ID that won't conflict
            '',
            '',
            const NotificationDetails(
              iOS: DarwinNotificationDetails(
                presentAlert: false,
                presentSound: false,
                presentBadge: true,
                badgeNumber: 0, // This should reset the badge to 0
              ),
            ),
          );

          // Immediately cancel the dummy notification
          await _flutterLocalNotificationsPlugin.cancel(999999);
        }
      }

      // Clear all pending notifications
      await _flutterLocalNotificationsPlugin.cancelAll();

      debugPrint('🔄 Badge count cleared successfully');
    } catch (e) {
      debugPrint('❌ Error clearing badge count: $e');
    }
  }

  /// Setup local notifications with proper iOS badge handling
  Future<void> setupFlutterNotifications() async {
    // Android setup
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // iOS setup with explicit badge permissions
    final iOSImplementation = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

    if (iOSImplementation != null) {
      await iOSImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    await _flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        ),
      ),
      onDidReceiveBackgroundNotificationResponse: _backgroundNotificationResponse,
      onDidReceiveNotificationResponse: _foregroundNotificationResponse,
    );
  }

  /// Ask the user for notification permissions with proper badge handling
  Future<void> requestNotificationPermissions() async {
    debugPrint('📢 Requesting notification permissions...');

    final messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('📢 Permission status: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (Platform.isIOS) {
        // For iOS, disable automatic badge handling by FCM
        await messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: false, // Important: Disable FCM's automatic badge handling
          sound: true,
        );
      }

      String? token = await messaging.getToken();
      debugPrint('📱 FCM Token: $token');
    }
  }

  /// Handle incoming notification messages
  Future<void> handleMessage(
      RemoteMessage message, {
        bool fromForeground = false,
      }) async {

    // Clear badge whenever a new message is handled while app is active
    if (fromForeground) {
      await clearBadgeCount();
    }

    if (Platform.isIOS && fromForeground && message.notification != null) {
      debugPrint('📩 iOS foreground notification handled');
      return;
    }

    showNotification(message);
    debugPrint('📩 Notification processed');
  }

  /// Show notification in system tray with controlled badge behavior
  void showNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    if (notification != null) {
      _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
            presentBadge: false, // Don't let local notifications manage badge
          ),
        ),
        payload: jsonEncode(message.toMap()),
      );
    }
  }

  /// Handle notification tap and navigate to appropriate screen
  Future<void> _handleNotificationTap(RemoteMessage message) async {
    debugPrint('📱 Notification tapped: ${message.data}');

    // Always clear badge when notification is tapped
    await clearBadgeCount();

    if (navigatorKey?.currentContext == null) {
      debugPrint('⚠️ Navigation context is null, cannot navigate');
      return;
    }

    final data = message.data;
    final type = data['type'];

    if (type == 'chat_message') {
      await _navigateToChat(data);
    }
  }

  /// Navigate to chat screen
  Future<void> _navigateToChat(Map<String, dynamic> data) async {
    try {
      final context = navigatorKey!.currentContext!;
      final roomIdString = data['room_id'];

      if (roomIdString == null) {
        debugPrint('⚠️ No room_id in notification data');
        return;
      }

      final roomId = int.parse(roomIdString.toString());
      debugPrint('🔍 Fetching chat room with ID: $roomId');

      final chatRoomsProvider = Provider.of<ChatRoomsProvider>(context, listen: false);

      ChatRoom? chatRoom = chatRoomsProvider.chatRooms
          .where((room) => room.id == roomId)
          .firstOrNull;

      if (chatRoom == null) {
        debugPrint('🌐 Chat room not found in cache, refreshing provider...');
        await chatRoomsProvider.fetchChatRooms();

        chatRoom = chatRoomsProvider.chatRooms
            .where((room) => room.id == roomId)
            .firstOrNull;
      }

      if (chatRoom != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatScreen(chatRoom: chatRoom!),
          ),
        );
        debugPrint('✅ Navigated to chat room: ${chatRoom.name}');
      } else {
        debugPrint('⚠️ Could not find chat room with ID: $roomId');
      }
    } catch (e) {
      debugPrint('❌ Error navigating to chat: $e');
    }
  }

  /// Get Google service account access token for sending notifications
  Future<String> _getAccessToken() async {
    final String jsonString = await rootBundle.loadString(
      'android/app/padel.json',
    );
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    final serviceAccount = ServiceAccountCredentials.fromJson(jsonData);
    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    final client = await clientViaServiceAccount(serviceAccount, scopes);
    final token = client.credentials.accessToken.data;
    client.close();
    return token;
  }

  /// Get Firebase project ID from service account JSON
  Future<String> _getProjectId() async {
    final String jsonString = await rootBundle.loadString(
      'android/app/padel.json',
    );
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    return jsonData['project_id'];
  }

  /// Handle background notification tap
  @pragma('vm:entry-point')
  static void _backgroundNotificationResponse(NotificationResponse response) {
    if (response.payload != null) {
      final message = RemoteMessage.fromMap(jsonDecode(response.payload!));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FCMService()._handleNotificationTap(message);
      });
    }
  }

  /// Handle foreground notification tap
  void _foregroundNotificationResponse(NotificationResponse response) {
    if (response.payload != null) {
      final message = RemoteMessage.fromMap(jsonDecode(response.payload!));
      _handleNotificationTap(message);
    }
  }
}