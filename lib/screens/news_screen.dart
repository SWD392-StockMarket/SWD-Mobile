import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/search_controller.dart';
import '../widgets/footer_menu.dart';
import '../services/authservice.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List<dynamic> news = [];
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    const url = 'https://newsapi.org/v2/everything?q=stock&apiKey=3a0af4775eee43a29d95d356fee24d96&pageSize=100';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          news = data['articles']; // ✅ Extract the articles array
        });
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      print('Error fetching news: $e');
    }
  }

  //CHUYỂN HƯỚNG USER TỚI TRANG WEB
  Future<void> _launchUrl(Uri url) async {
    if (url.toString().isNotEmpty && await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.inAppBrowserView);
    } else {
      print("Could not launch URL: $url");
    }
  }


  @override
  Widget build(BuildContext context) {
    final searchController = Provider.of<SearchControllerApp>(context, listen: false);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              const SizedBox(width: 10),
              const Text('News'),
              const Spacer(),
              SizedBox(
                width: 200,
                child: SearchBar(
                  leading: const Icon(Icons.search),
                  controller: searchController.controller,
                  onChanged: searchController.updateSearch,
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
          toolbarHeight: 100,
          backgroundColor: Colors.black,
        ),
        body: news.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
          itemCount: news.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade800),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // News Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        news[index]['urlToImage'] ?? 'https://picsum.photos/300/300', // ✅ Fallback image
                        height: 60,
                        width: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // News Title & Description
                    Expanded(
                      child: ListTile(
                        title: Text(
                          news[index]['title'] ?? 'No Title Available',  // ✅ Handle null title
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          news[index]['description'] ?? 'No Description Available',  // ✅ Handle null description
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade400,
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
          bottomNavigationBar: ScrollableFooterMenu(buttons:
          [
            FooterButton(icon: Icons.home, label: "Home", onTap: () {Navigator.pushNamed(context, '/home');}),
            FooterButton(icon: Icons.playlist_add, label: "Watch List", onTap: () {Navigator.pushNamed(context, '/watchlist');}),
            FooterButton(icon: Icons.newspaper, label: "News", onTap: () {Navigator.pushNamed(context, '/news');}),
            FooterButton(icon: Icons.monetization_on, label: "Stock", onTap: () {Navigator.pushNamed(context, '/stock');}),
            FooterButton(icon: Icons.person, label: "Profile", onTap: () {Navigator.pushNamed(context, '/profile');}),
            FooterButton(icon: Icons.logout, label: "Logout", onTap: () {
              _authService.logout();
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            }),
          ]
          ),
      ),
    );
  }
}
