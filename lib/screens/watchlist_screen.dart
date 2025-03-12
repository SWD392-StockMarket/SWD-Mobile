import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:source_code_mobile/widgets/gradient_app_bar.dart';
import '../widgets/gradient_container.dart';
import '../widgets/search_bar.dart';
import 'package:source_code_mobile/controllers/search_controller.dart';
import '../widgets/expandable_button.dart';
import '../widgets/custom_list.dart';
import '../widgets/custom_entity.dart';
import '../widgets/footer_menu.dart';
import '../services/watchlist_service.dart';

class WatchlistScreen extends StatefulWidget{
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen>{
  final WatchListService _watchListService = WatchListService();

  @override
  Widget build(BuildContext context){
    final List<Widget> sample = List.generate(50, (index) => CustomEntityWidget(title: 'aaaaaaaaaaaaaaaa', subtitle: 'bbbbbbbbbbbbbbbbbbbbbbbbb'));

    final searchController = Provider.of<SearchControllerApp>(context, listen: false);

    return GradientContainer(
      scaffold: Scaffold(
        appBar: GradientAppBar(
            title: 'Watch List',
            icon: Icons.add_box,
            onIconPressed: () async {
              if(!await _watchListService.checkWatchListExist()){
                final userWatchList = await _watchListService.createWatchList();
                final box = GetStorage();
                box.write('watchlist_id', userWatchList?.watchListId);
              }else{
                final userWatchList = await _watchListService.getWatchListByUserId();
                final box = GetStorage();
                box.write('watchlist_id', userWatchList?.watchListId);
              }
              Navigator.pushNamed(context, '/stock');
            },
        ),
        backgroundColor: Colors.transparent,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SearchBarWidget(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.05,
                controller: searchController.controller,
                onChanged: searchController.updateSearch,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ExpandableButton(
                icon: const Icon(Icons.sort, color: Colors.white),
                children: [
                  ListTile(
                    leading: Icon(Icons.home),
                    title: Text("Home"),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.settings),
                    title: Text("Settings"),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 500,
                child: CustomEntityList(entities: sample),
              ),
            ),
          ],
        ),
        bottomNavigationBar: ScrollableFooterMenu(buttons:
        [
          FooterButton(icon: Icons.home, label: "Home", onTap: () {}),
          FooterButton(icon: Icons.search, label: "Search", onTap: () {}),
          FooterButton(icon: Icons.shopping_cart, label: "Cart", onTap: () {}),
          FooterButton(icon: Icons.favorite, label: "Favorites", onTap: () {}),
          FooterButton(icon: Icons.person, label: "Profile", onTap: () {}),
          FooterButton(icon: Icons.settings, label: "Settings", onTap: () {}),
          FooterButton(icon: Icons.logout, label: "Logout", onTap: () {Navigator.pushNamed(context, '/home');}),
        ]
        ),
      ),
    );
  }
}