
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:source_code_mobile/screens/news_screen.dart';
import 'package:source_code_mobile/screens/profile_screen.dart';
import 'package:source_code_mobile/screens/stock_monitor_screen.dart';
import 'package:source_code_mobile/screens/stock_screen.dart';
import 'package:source_code_mobile/screens/watchlist_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'package:source_code_mobile/controllers/search_controller.dart';
import 'package:source_code_mobile/routes/authguard.dart';

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
  await GetStorage.init();
  final box = GetStorage();
  final token = box.read<String>('jwt_token'); // Read token from storage
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
      initialRoute: '/news',  // Set the default route
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => AuthGuard(child:  const HomeScreen()),
        '/news': (context) => const NewsScreen(),
        '/stock monitor' : (context) => const StockMonitorScreen(),
        '/profile' : (context) => const ProfileScreen(),
        '/watchlist' : (context) => const WatchlistScreen(),
        '/stock' : (context) => const StockScreen()
      },
    );
  }
}
