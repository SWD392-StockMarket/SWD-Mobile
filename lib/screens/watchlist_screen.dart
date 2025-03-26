import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:source_code_mobile/services/authservice.dart';
import '../widgets/gradient_container.dart';
import 'package:source_code_mobile/models/watchlist_response.dart';
import 'package:source_code_mobile/widgets/custom_entity.dart';
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

class _WatchlistScreenState extends State<WatchlistScreen> {
  late Future<List<WatchlistResponse>?> watchlistFuture;
  final WatchListService _watchListService = WatchListService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    int userId = 10; // Thay bằng userId thực tế
    watchlistFuture = _watchListService.fetchWatchlistsByUserId(userId);
  }

  void _onSearchChanged(String searchTerm) {
    setState(() {
      int userId = 10; // Thay bằng userId thực tế
      watchlistFuture = _watchListService.fetchWatchlistsByUserId(
        userId,
        searchTerm: searchTerm.isNotEmpty ? searchTerm : null,
      );
    });
  }

  void _handleAddWatchlist() async {
    bool exists = await _watchListService.checkWatchListExist();
    final box = GetStorage();

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
  Widget build(BuildContext context) {
    final searchController = Provider.of<SearchControllerApp>(context, listen: true);

    return GradientContainer(
      scaffold: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text("Watch List"),
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
                    return const Center(child: Text("Không tìm thấy danh sách theo dõi."));
                  } else {
                    final stocks = snapshot.data![0].stocks;
                    if (stocks.isEmpty) {
                      return const Center(child: Text("Danh sách theo dõi trống hoặc không có kết quả tìm kiếm."));
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
