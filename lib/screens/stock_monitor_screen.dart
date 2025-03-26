import 'package:candlesticks/candlesticks.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:source_code_mobile/services/stock_monitoring_service.dart';
import 'package:source_code_mobile/widgets/candle_sticks_chart.dart';
import '../widgets/movable_button.dart';

class StockMonitorScreen extends StatefulWidget {
  const StockMonitorScreen({super.key});

  @override
  State<StockMonitorScreen> createState() => _StockMonitorScreenState();
}

class _StockMonitorScreenState extends State<StockMonitorScreen> {
  late StockService stockService;
  late Future<List<Candle>> candlesFuture;
  List<Session> sessions = [];
  Map<String, int> dateStockCount = {}; // Store stock count by date
  DateTime? selectedDate;
  final dateFormat = DateFormat('yyyy-MM-dd'); // Date format
  String? hiddenValue; // Store the route argument

  @override
  void initState() {
    super.initState();
    final box = GetStorage();
    final token = box.read<String>('jwt_token');

    // Delay initialization to ensure ModalRoute is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      hiddenValue = ModalRoute.of(context)!.settings.arguments as String;
      stockService = StockService(token: token, stockId: hiddenValue!);
      _loadSessions();
    });

    // Initialize with an empty future
    candlesFuture = Future.value([]);
  }

  Future<void> _loadSessions() async {
    try {
      sessions = await stockService.getSessionsByStockId();
      if (sessions.isNotEmpty) {
        for (var session in sessions) {
          final stocks = await stockService.getSessionStocks(session.sessionId);
          final dateStr = session.startTime != null ? dateFormat.format(session.startTime!) : 'Unknown';
          dateStockCount[dateStr] = stocks.length;
          print('Session ${session.sessionId} on $dateStr has ${stocks.length} stocks');
        }
        setState(() {
          selectedDate = sessions.first.startTime ?? DateTime.now();
          candlesFuture = fetchCandlesForDate(selectedDate!);
        });
      }
    } catch (e) {
      print('Error loading sessions: $e');
    }
  }

  Future<List<Candle>> fetchCandlesForDate(DateTime date) async {
    final session = sessions.firstWhere(
          (s) => s.startTime != null && dateFormat.format(s.startTime!) == dateFormat.format(date),
      orElse: () => sessions.first,
    );
    final stocks = await stockService.getSessionStocks(session.sessionId);
    return stocks.map((stock) => Candle(
      date: stock.dateTime ?? date,
      open: stock.openPrice ?? 0,
      high: stock.highPrice ?? 0,
      low: stock.lowPrice ?? 0,
      close: stock.closePrice ?? 0,
      volume: stock.volume ?? 1, // Ensure volume > 0
    )).toList();
  }

  void _onDateChanged(String? newDateStr) {
    if (newDateStr != null) {
      final newDate = dateFormat.parse(newDateStr);
      if (newDate != selectedDate) {
        setState(() {
          selectedDate = newDate;
          candlesFuture = fetchCandlesForDate(newDate);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Monitor'),
        actions: [
          if (sessions.isNotEmpty)
            DropdownButton<String>(
              value: selectedDate != null ? dateFormat.format(selectedDate!) : null,
              items: sessions
                  .map((session) => session.startTime)
                  .where((date) => date != null)
                  .map((date) => dateFormat.format(date!))
                  .toSet()
                  .where((dateStr) => (dateStockCount[dateStr] ?? 0) >= 3) // Only show dates with >= 3 stocks
                  .map((dateStr) => DropdownMenuItem<String>(
                value: dateStr,
                child: Text(dateStr),
              ))
                  .toList(),
              onChanged: _onDateChanged,
              hint: const Text('Select Date'),
            ),
        ],
      ),
      body: Stack(
        children: [
          FutureBuilder<List<Candle>>(
            future: candlesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No data available'));
              } else {
                return CandlestickChart(candles: snapshot.data!);
              }
            },
          ),
          MovableButton(
            icons: [Icons.bar_chart, Icons.search, Icons.settings],
            onPressedActions: [
                  () => print("Chart Clicked!"),
                  () => print("Search Clicked!"),
                  () => print("Settings Clicked!"),
            ],
          ),
        ],
      ),
    );
  }
}
