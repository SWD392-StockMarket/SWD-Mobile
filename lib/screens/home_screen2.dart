import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_storage/get_storage.dart';
import 'package:source_code_mobile/services/authservice.dart';
import '../screens/home_screen.dart';
class HomeScreen2 extends StatefulWidget {
  const HomeScreen2({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen2> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _requestPermission();
    _configureFCM();
    _getToken(context, _authService);
  }

  void _requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else {
      print('User denied permission');
    }
  }

  void _configureFCM() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground message: ${message.notification?.title}");
      _showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Message opened by user: ${message.notification?.title}");
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      body: Center(child: Text("FCM is Ready!")),
    );
  }
}

void _getToken(BuildContext context, AuthService auth) async {
  String? token = await FirebaseMessaging.instance.getToken();
  print("FCM Token: $token");
  final box = GetStorage();
  box.write('FCM_Token', token);
  auth.createToken(token);

  Future.delayed(Duration(seconds: 1), () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()), // Your real home screen
    );
  });
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

// Initialize settings
void _initializeNotifications() {
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);

  flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

// Show local notification
Future<void> _showNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
    'high_importance_channel', // Channel ID
    'High Importance Notifications', // Channel name
    channelDescription: 'This channel is used for important notifications.',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
  );

  const NotificationDetails platformChannelSpecifics =
  NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0, // Notification ID
    message.notification?.title ?? 'No Title',
    message.notification?.body ?? 'No Body',
    platformChannelSpecifics,
  );
}