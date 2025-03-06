import 'package:candlesticks/candlesticks.dart';
import 'package:flutter/material.dart';
import 'package:source_code_mobile/widgets/candle_sticks_chart.dart';
import '../widgets/movable_button.dart';

class StockMonitorScreen extends StatefulWidget{
  const StockMonitorScreen({super.key});

  @override
  State<StockMonitorScreen> createState() => _StockMonitorScreenState();
}

class _StockMonitorScreenState extends State<StockMonitorScreen>{
  final List<Candle> candles = [
    Candle(date: DateTime.now().add(Duration(days: 1)), open: 100, high: 105, low: 98, close: 102, volume: 500),
    Candle(date: DateTime.now().add(Duration(days: 2)), open: 102, high: 107, low: 99, close: 104, volume: 600),
    Candle(date: DateTime.now().add(Duration(days: 3)), open: 104, high: 110, low: 101, close: 108, volume: 700),
    Candle(date: DateTime.now().add(Duration(days: 4)), open: 108, high: 112, low: 106, close: 110, volume: 550),
    Candle(date: DateTime.now().add(Duration(days: 5)), open: 110, high: 115, low: 109, close: 113, volume: 650),
    Candle(date: DateTime.now().add(Duration(days: 6)), open: 113, high: 118, low: 111, close: 116, volume: 680),
    Candle(date: DateTime.now().add(Duration(days: 7)), open: 116, high: 120, low: 114, close: 118, volume: 700),
    Candle(date: DateTime.now().add(Duration(days: 8)), open: 118, high: 122, low: 117, close: 121, volume: 750),
    Candle(date: DateTime.now().add(Duration(days: 9)), open: 121, high: 125, low: 120, close: 124, volume: 800),
    Candle(date: DateTime.now().add(Duration(days: 10)), open: 124, high: 128, low: 123, close: 126, volume: 820),
    Candle(date: DateTime.now().add(Duration(days: 11)), open: 126, high: 130, low: 125, close: 129, volume: 850),
    Candle(date: DateTime.now().add(Duration(days: 12)), open: 129, high: 134, low: 127, close: 132, volume: 900),
    Candle(date: DateTime.now().add(Duration(days: 13)), open: 132, high: 137, low: 130, close: 135, volume: 950),
    Candle(date: DateTime.now().add(Duration(days: 14)), open: 135, high: 140, low: 133, close: 138, volume: 980),
    Candle(date: DateTime.now().add(Duration(days: 15)), open: 138, high: 143, low: 136, close: 141, volume: 1000),
  ];

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body:Stack(
        children: [
          CandlestickChart(candles: candles),
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