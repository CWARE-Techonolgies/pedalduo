import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  late final FirebaseMessaging _firebaseMessaging;
  late final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  static const DarwinNotificationDetails _iOSNotificationDetails =
  DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  Future<void> initialize() async {
    _firebaseMessaging = FirebaseMessaging.instance;
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await setupFlutterNotifications();
    // await requestNotificationPermissions();
    configureFirebaseListeners();
  }

  Future<void> setupFlutterNotifications() async {
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('launch_background'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveBackgroundNotificationResponse:
      _backgroundNotificationResponse,
      onDidReceiveNotificationResponse: _foregroundNotificationResponse,
    );
  }
  Future<void> requestNotificationPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }


  void configureFirebaseListeners() {
    FirebaseMessaging.onMessage.listen(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  }

  Future<void> handleMessage(RemoteMessage message) async {
    showNotification(message);
    print('notification has arrived');
  }

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
            icon: '@mipmap/ic_launcher',
          ),
          iOS: _iOSNotificationDetails,
        ),
        payload: jsonEncode(message.toMap()),
      );
    }
  }

  Future<String> _getAccessToken() async {
    final String jsonString =
    await rootBundle.loadString('android/app/cricketify.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    final serviceAccount = ServiceAccountCredentials.fromJson(jsonData);

    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
    final client = await clientViaServiceAccount(serviceAccount, scopes);
    final token = client.credentials.accessToken.data;
    client.close();
    return token;
  }

  // Future<String?> fcmToken() async {
  //   final token = await _firebaseMessaging.getToken();
  //   return token;
  // }

  Future<void> sendNotification(String token, String title, String body,
      {Map<String, dynamic>? additionalData}) async {
    final accessToken = await _getAccessToken();
    final projectId = await _getProjectId();

    final response = await http.post(
      Uri.parse(
          'https://fcm.googleapis.com/v1/projects/$projectId/messages:send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'message': {
            'token': token,
            'notification': {
              'title': title,
              'body': body,
            },
            'data': additionalData,
          },
        },
      ),
    );

    if (response.statusCode == 200) {
    } else {}
  }

  Future<String> _getProjectId() async {
    final String jsonString =
    await rootBundle.loadString('android/app/cricketify.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    return jsonData['project_id'];
  }

  @pragma('vm:entry-point')
  static void _backgroundNotificationResponse(NotificationResponse response) {
    if (response.payload != null) {
      final message = RemoteMessage.fromMap(jsonDecode(response.payload!));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FCMService().handleMessage(message);
      });
    }
  }

  void _foregroundNotificationResponse(NotificationResponse response) {
    if (response.payload != null) {
      final message = RemoteMessage.fromMap(jsonDecode(response.payload!));
      handleMessage(message);
    }
  }
}