import 'package:flutter/material.dart';
import 'package:candlesticks/candlesticks.dart';

class CandlestickChart extends StatefulWidget {
  final List<Candle> candles;

  const CandlestickChart({super.key, required this.candles});

  @override
  CandlestickChartState createState() => CandlestickChartState();
}

class CandlestickChartState extends State<CandlestickChart> {
  List<Candle> _candles = [];

  @override
  void initState() {
    super.initState();
    _candles = widget.candles;
  }

  void updateData(List<Candle> newCandles) {
    setState(() {
      _candles = newCandles;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    // Show the chart only in landscape mode
    if (!isLandscape) {
      return const Center(
        child: Text(
          "Rotate your phone to landscape mode to view the chart",
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      width: MediaQuery.of(context).size.width, // Full width in landscape
      height: MediaQuery.of(context).size.height, // Full height in landscape
      padding: const EdgeInsets.all(8.0),
      child: Candlesticks(candles: _candles),
    );
  }
}
