import 'package:flutter/material.dart';
import '../services/watchlist_service.dart';

class CustomEntityWidget extends StatefulWidget {
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final VoidCallback? onPressed; // Button press callback
  final String hiddenValue; // Hidden integer value

  const CustomEntityWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.backgroundColor = Colors.white,
    this.onPressed,
    required this.hiddenValue, // Default hidden value
  });

  @override
  State<CustomEntityWidget> createState() => _CustomEntityWidgetState();
}

class _CustomEntityWidgetState extends State<CustomEntityWidget> {
  final WatchListService _watchListService = WatchListService();
  bool _isLongPressed = false;
  OverlayEntry? _overlayEntry;
  late String _hiddenValue; // Local hidden value

  @override
  void initState() {
    super.initState();
    _hiddenValue = widget.hiddenValue; // Initialize with widget's value
  }

  void _showButton(BuildContext context) {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final tapPosition = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: tapPosition.dx + 50,
        top: tapPosition.dy,
        child: FloatingActionButton(
          onPressed: () {
            _watchListService.AddStockToWatchList(_hiddenValue as String);
            _removeOverlay();
          },
          child: const Icon(Icons.add),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _isLongPressed = false;
    });
  }

  String getHiddenValue() => _hiddenValue; // Getter method for the hidden value

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      onLongPress: () {
        setState(() {
          _isLongPressed = true;
        });
        _showButton(context);
      },
      child: Padding(
        padding: const EdgeInsets.all(7.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: _isLongPressed ? Colors.blue.shade100 : widget.backgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(widget.subtitle, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
