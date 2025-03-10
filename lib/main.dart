
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:source_code_mobile/screens/news_screen.dart';
import 'package:source_code_mobile/screens/profile_screen.dart';
import 'package:source_code_mobile/screens/stock_monitor_screen.dart';
import 'package:source_code_mobile/screens/watchlist_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'package:source_code_mobile/controllers/search_controller.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('jwt_token');
  await dotenv.load(fileName: ".env");
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
      initialRoute: initialRoute,  // Set the default route
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/news': (context) => const NewsScreen(),
        '/stock' : (context) => const StockMonitorScreen(),
        '/profile' : (context) => const ProfileScreen(),

      },
    );
  }
}
