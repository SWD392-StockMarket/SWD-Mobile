import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:source_code_mobile/models/watchlist_response.dart';
import 'package:source_code_mobile/services/authservice.dart';
import 'package:source_code_mobile/widgets/custom_entity.dart';
import 'package:source_code_mobile/widgets/gradient_container.dart';
import '../widgets/search_bar.dart';
import '../controllers/search_controller.dart';
import '../widgets/custom_list.dart';
import '../widgets/expandable_button.dart';
import '../widgets/footer_menu.dart';
import '../services/watchlist_service.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> with SingleTickerProviderStateMixin {
  late Future<List<WatchlistResponse>?> watchlistFuture;
  final WatchListService _watchListService = WatchListService();
  final AuthService _authService = AuthService();
  final box = GetStorage();
  late AnimationController _controller;

  int? _getUserId() {
    final String? userId = box.read<String>('user_id');
    if (userId == null) {
      return null;
    }
    return int.tryParse(userId);
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3), // Tốc độ đổi màu
      vsync: this,
    )..repeat(); // Lặp vô hạn

    final int? userId = _getUserId();
    if (userId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/');
      });
      watchlistFuture = Future.value([]);
    } else {
      watchlistFuture = _watchListService.fetchWatchlistsByUserId(userId);
    }
  }

  void _onSearchChanged(String searchTerm) {
    setState(() {
      final int? userId = _getUserId();
      if (userId != null) {
        watchlistFuture = _watchListService.fetchWatchlistsByUserId(
          userId,
          searchTerm: searchTerm.isNotEmpty ? searchTerm : null,
        );
      }
    });
  }

  void _handleAddWatchlist() async {
    final int? userId = _getUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID is missing. Please log in.')),
      );
      Navigator.pushReplacementNamed(context, '/');
      return;
    }

    bool exists = await _watchListService.checkWatchListExist();
    if (!exists) {
      final userWatchList = await _watchListService.createWatchList();
      box.write('watchlist_id', userWatchList?.watchListId.toString());
    } else {
      final userWatchList = await _watchListService.getWatchListByUserId();
      if (!box.hasData('watchlist_id')) {
        box.write('watchlist_id', userWatchList?.watchListId.toString());
      }
    }
    Navigator.pushNamed(context, '/stock');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchController = Provider.of<SearchControllerApp>(context, listen: true);

    return GradientContainer(
      scaffold: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text(
            "Watch List",
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_box),
              onPressed: _handleAddWatchlist,
            )
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SearchBarWidget(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.05,
                controller: searchController.controller,
                onChanged: _onSearchChanged,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ExpandableButton(
                icon: const Icon(Icons.sort, color: Colors.white),
                children: [
                  ListTile(
                    leading: const Icon(Icons.home),
                    title: const Text("Home"),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text("Settings"),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<WatchlistResponse>?>(
                future: watchlistFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
                    return Center(
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return ShaderMask(
                            shaderCallback: (Rect bounds) {
                              return LinearGradient(
                                colors: [
                                  Colors.red,
                                  Colors.orange,
                                  Colors.yellow,
                                  Colors.green,
                                  Colors.blue,
                                  Colors.indigo,
                                  Colors.purple,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                transform: GradientRotation(_controller.value * 2 * 3.14159), // Xoay gradient
                              ).createShader(bounds);
                            },
                            child: const Text(
                              "Không tìm thấy danh sách theo dõi.",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  } else {
                    final stocks = snapshot.data![0].stocks;
                    if (stocks.isEmpty) {
                      return Center(
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return ShaderMask(
                              shaderCallback: (Rect bounds) {
                                return LinearGradient(
                                  colors: [
                                    Colors.red,
                                    Colors.orange,
                                    Colors.yellow,
                                    Colors.green,
                                    Colors.blue,
                                    Colors.indigo,
                                    Colors.purple,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  transform: GradientRotation(_controller.value * 2 * 3.14159),
                                ).createShader(bounds);
                              },
                              child: const Text(
                                "Danh sách theo dõi trống hoặc không có kết quả tìm kiếm.",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                    final stockWidgets = List.generate(
                      stocks.length,
                          (index) => CustomEntityWidget(
                        title: stocks[index].stockSymbol,
                        subtitle: 'Company: ${stocks[index].companyName} | Market: ${stocks[index].marketName}',
                        onPressed: () {
                          Navigator.pushNamed(context, '/stock monitor');
                        },
                        hiddenValue: stocks[index].stockId.toString(),
                      ),
                    );
                    return CustomEntityList(entities: stockWidgets);
                  }
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
            FooterButton(icon: Icons.payment, label: "PayPal", onTap: () {
              Navigator.pushNamed(context, '/paypal');
            }),
          ],
        ),
      ),
    );
  }
}