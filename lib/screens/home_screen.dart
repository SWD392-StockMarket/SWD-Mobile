import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:source_code_mobile/models/stock_reponse.dart';
import 'package:source_code_mobile/services/authservice.dart';
import 'package:source_code_mobile/services/watchlist_service.dart';
import 'package:source_code_mobile/widgets/custom_entity.dart';
import 'package:source_code_mobile/widgets/custom_list.dart';
import '../widgets/gradient_container.dart';
import '../widgets/gradient_app_bar.dart';
import '../widgets/footer_menu.dart';
import '../widgets/search_bar.dart';
import '../controllers/search_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<StockResponse?> stockFuture;
  final WatchListService _watchListService = WatchListService();
  final AuthService _authService = AuthService();
  List<dynamic> news = []; // Danh sách tin tức

  @override
  void initState() {
    super.initState();
    stockFuture = _watchListService.fetchStock(); // Lấy danh sách stock
    fetchNews(); // Lấy dữ liệu tin tức
  }

  void _onSearchChanged(String searchTerm) {
    setState(() {
      stockFuture = _watchListService.fetchStock(searchTerm: searchTerm);
    });
  }

  // Hàm lấy dữ liệu tin tức từ NewsAPI
  Future<void> fetchNews() async {
    const url =
        'https://newsapi.org/v2/everything?q=stock&apiKey=3a0af4775eee43a29d95d356fee24d96&pageSize=100';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          news = data['articles']; // Lưu danh sách tin tức
        });
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      print('Error fetching news: $e');
    }
  }

  // Hàm mở URL trong trình duyệt
  Future<void> _launchUrl(Uri url) async {
    if (url.toString().isNotEmpty && await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.inAppBrowserView);
    } else {
      print("Could not launch URL: $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchController = Provider.of<SearchControllerApp>(context, listen: true);

    return GradientContainer(
      scaffold: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: GradientAppBar(
          title: 'FUStock',
          icon: Icons.account_circle,
          onIconPressed: () {
            Navigator.pushNamed(context, '/profile');
          },
        ),
        body: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: SearchBarWidget(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.05,
                controller: searchController.controller,
                onChanged: _onSearchChanged,
              ),
            ),
            // Filter Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) => filterButton('Filter')),
            ),
            const SizedBox(height: 10),
            // Stock List
            SizedBox(
              height: 200,
              child: FutureBuilder<StockResponse?>(
                future: stockFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError || snapshot.data == null) {
                    return const Center(child: Text("No stocks found."));
                  } else {
                    final stocks = snapshot.data!.items;
                    final stockWidgets = List.generate(
                      stocks.length,
                          (index) => CustomEntityWidget(
                        title: stocks[index].stockSymbol,
                        subtitle:
                        'Company: ${stocks[index].companyName} | Market: ${stocks[index].marketName}',
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/stock monitor',
                            arguments: stocks[index].stockId.toString(),
                          );
                        },
                        hiddenValue: stocks[index].stockId.toString(),
                      ),
                    );
                    return CustomEntityList(entities: stockWidgets);
                  }
                },
              ),
            ),
            // News Section Header
            Container(
              padding: const EdgeInsets.all(10),
              width: double.infinity,
              color: Colors.purple,
              child: const Text('News', style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
            // News Section Content
            Expanded(
              child: news.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                itemCount: news.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // News Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              news[index]['urlToImage'] ?? 'https://picsum.photos/300/300',
                              height: 60,
                              width: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.network(
                                  'https://picsum.photos/300/300',
                                  height: 60,
                                  width: 60,
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          // News Title & Description
                          Expanded(
                            child: ListTile(
                              title: Text(
                                news[index]['title'] ?? 'No Title Available',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              subtitle: Text(
                                news[index]['description'] ?? 'No Description Available',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              onTap: () async {
                                final String? url = news[index]['url'];
                                if (url != null && url.isNotEmpty) {
                                  await _launchUrl(Uri.parse(url));
                                } else {
                                  print("No URL available for this news article.");
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: ScrollableFooterMenu(
          buttons: [
            FooterButton(icon: Icons.home, label: "Home", onTap: () {
              Navigator.pushNamed(context, '/home');
            }),
            FooterButton(icon: Icons.playlist_add, label: "Watch List", onTap: () {
              Navigator.pushNamed(context, '/watchlist');
            }),
            FooterButton(icon: Icons.newspaper, label: "News", onTap: () {
              Navigator.pushNamed(context, '/news');
            }),
            FooterButton(icon: Icons.monetization_on, label: "Stock", onTap: () {
              Navigator.pushNamed(context, '/stock');
            }),
            FooterButton(icon: Icons.person, label: "Profile", onTap: () {
              Navigator.pushNamed(context, '/profile');
            }),
            FooterButton(icon: Icons.logout, label: "Logout", onTap: () {
              _authService.logout();
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            }),
          ],
        ),
      ),
    );
  }

  Widget filterButton(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        onPressed: () {},
        child: Text(text),
      ),
    );
  }
}