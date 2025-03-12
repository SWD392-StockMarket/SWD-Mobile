import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:source_code_mobile/models/stock_reponse.dart';
import 'package:source_code_mobile/widgets/custom_entity.dart';
import 'package:source_code_mobile/widgets/gradient_container.dart';
import '../widgets/search_bar.dart';
import '../controllers/search_controller.dart';
import '../widgets/custom_list.dart';
import '../services/watchlist_service.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  late Future<StockResponse?> stockFuture;
  final WatchListService _watchListService = WatchListService();

  @override
  void initState() {
    super.initState();
    stockFuture = _watchListService.fetchStock();
  }

  void _onSearchChanged(String searchTerm) {
    setState(() {
      stockFuture = _watchListService.fetchStock(searchTerm: searchTerm);
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchController = Provider.of<SearchControllerApp>(context, listen: true);

    return GradientContainer(scaffold:
    Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SearchBarWidget(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.05,
              controller: searchController.controller,
              onChanged: _onSearchChanged, // Trigger search
            ),
          ),
          const SizedBox(height: 20),

          // Stock List
          Expanded(
            child: FutureBuilder<StockResponse?>(
              future: stockFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError || snapshot.data == null) {
                  return const Center(child: Text("No stocks found."));
                } else {
                  final stocks = snapshot.data!.items; // Extract stocks

                  final s = List.generate(
                    stocks.length,
                        (index) => CustomEntityWidget(
                      title: stocks[index].stockSymbol, // Extract stock symbol
                      subtitle: 'Company: ${stocks[index].companyName} | Market: ${stocks[index].marketName}',// Extract details
                    ),
                  );
                  return CustomEntityList(entities: s); // Pass to your list
                }
              },
            ),
          ),
        ],
      ),
    ),
    );
  }
}
