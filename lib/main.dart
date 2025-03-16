import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';

import 'package:source_code_mobile/screens/news_screen.dart';
import 'package:source_code_mobile/screens/profile_screen.dart';
import 'package:source_code_mobile/screens/register_screen.dart';
import 'package:source_code_mobile/screens/stock_monitor_screen.dart';
import 'package:source_code_mobile/screens/stock_screen.dart';
import 'package:source_code_mobile/screens/watchlist_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'package:source_code_mobile/controllers/search_controller.dart';
import 'package:source_code_mobile/routes/authguard.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GetStorage.init();
  await dotenv.load(fileName: ".env");

  HttpOverrides.global = MyHttpOverrides();

  final box = GetStorage();
  final token = box.read<String>('jwt_token'); // Read token from storage

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SearchControllerApp()),
      ],
      child: MyApp(initialRoute: token != null ? '/home' : '/'),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Named Routes',
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/home2': (context) => const HomeScreen2(),
        '/news': (context) => const NewsScreen(),
        '/stock monitor': (context) => const StockMonitorScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/watchlist': (context) => const WatchlistScreen(),
        '/register': (context) => const RegisterScreen(),
        '/stock': (context) => const StockScreen(),
      },
    );
  }
}

class HomeScreen2 extends StatefulWidget {
  const HomeScreen2({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen2> {
  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _requestPermission();
    _configureFCM();
    _getToken();
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

void _getToken() async {
  String? token = await FirebaseMessaging.instance.getToken();
  print("FCM Token: $token");
  final box = GetStorage();
  box.write('FCM_Token', token);
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
