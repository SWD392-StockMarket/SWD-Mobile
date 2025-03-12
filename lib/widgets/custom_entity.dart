import 'package:flutter/material.dart';

class CustomEntityWidget extends StatefulWidget {
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final VoidCallback? onPressed; // Button press callback

  const CustomEntityWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.backgroundColor = Colors.white,
    this.onPressed, // Allows for a tap action
  });

  @override
  State<CustomEntityWidget> createState() => _CustomEntityWidgetState();
}

class _CustomEntityWidgetState extends State<CustomEntityWidget> {
  bool _isLongPressed = false;
  OverlayEntry? _overlayEntry;

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

            _removeOverlay();
          },
          child: const Icon(Icons.check),
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed, // Call the provided button action
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
