import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:source_code_mobile/screens/news_screen.dart';
import 'package:source_code_mobile/screens/payment_screen.dart';
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
import 'package:source_code_mobile/screens/home_screen2.dart';

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
      child: MyApp(initialRoute: token != null ? '/stock' : '/'),
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
        '/paypal': (context) => PayPalPaymentScreen(),
      },
    );
  }
}



