import 'package:candlesticks/candlesticks.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Thêm package để định dạng ngày
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
  late Future<List<Candle>> candlesFuture = Future.value([]);
  List<Session> sessions = [];
  Map<String, int> dateStockCount = {}; // Lưu số lượng stock theo ngày
  DateTime? selectedDate;
  final dateFormat = DateFormat('yyyy-MM-dd'); // Định dạng ngày

  @override
  void initState() {
    super.initState();
    stockService = StockService(token: "your_jwt_token_here");
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    try {
      sessions = await stockService.getSessions();
      if (sessions.isNotEmpty) {
        // Kiểm tra số lượng stock cho từng session
        for (var session in sessions) {
          final stocks = await stockService.getSessionStocks(session.sessionId);
          final dateStr = session.startTime != null ? dateFormat.format(session.startTime!) : 'Unknown';
          dateStockCount[dateStr] = stocks.length; // Lưu số lượng stock theo ngày
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
    // Tìm session tương ứng với ngày được chọn
    final session = sessions.firstWhere(
          (s) => s.startTime != null && dateFormat.format(s.startTime!) == dateFormat.format(date),
      orElse: () => sessions.first, // Nếu không tìm thấy, lấy session đầu tiên
    );
    final stocks = await stockService.getSessionStocks(session.sessionId);
    return stocks.map((stock) => Candle(
      date: stock.dateTime ?? date,
      open: stock.openPrice ?? 0,
      high: stock.highPrice ?? 0,
      low: stock.lowPrice ?? 0,
      close: stock.closePrice ?? 0,
      volume: stock.volume ?? 1, // Đảm bảo volume > 0
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
                  .where((dateStr) => (dateStockCount[dateStr] ?? 0) >= 3) // Chỉ hiển thị ngày có >= 5 stock
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