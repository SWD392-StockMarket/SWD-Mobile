import 'dart:async';
import 'package:flutter/material.dart';

class MovableButton extends StatefulWidget {
  final List<IconData> icons;
  final List<VoidCallback> onPressedActions;

  const MovableButton({
    super.key,
    required this.icons,
    required this.onPressedActions,
  }) : assert(icons.length == onPressedActions.length, "Icons and actions must have the same length");

  @override
  MovableButtonState createState() => MovableButtonState();
}

class MovableButtonState extends State<MovableButton> {
  double posX = 100;
  double posY = 100;
  bool isExpanded = false;
  bool isVisible = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _startHideTimer();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => isVisible = false);
    });
  }

  void _resetTimerAndShow() {
    setState(() => isVisible = true);
    _startHideTimer();
  }

  @override
  Widget build(BuildContext context) {
    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Stack(
      children: [
        // Transparent GestureDetector to only capture double-taps
        Positioned.fill(
          child: GestureDetector(
            onDoubleTap: _resetTimerAndShow, // ✅ Show button when double-tapped
            behavior: HitTestBehavior.translucent, // ✅ Allows interaction with other widgets
          ),
        ),

        // Navigation buttons
        if (isVisible && isExpanded)
          ...List.generate(widget.icons.length, (index) {
            return Positioned(
              left: isLandscape ? posX + (index + 1) * 60 : posX,
              top: isLandscape ? posY : posY - (index + 1) * 60,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: Colors.blueAccent,
                onPressed: () {
                  widget.onPressedActions[index]();
                  setState(() => isExpanded = false);
                },
                child: Icon(widget.icons[index], color: Colors.white),
              ),
            );
          }),

        // Main draggable button
        if (isVisible)
          Positioned(
            left: posX,
            top: posY,
            child: Draggable(
              feedback: FloatingActionButton(
                backgroundColor: isExpanded ? Colors.red : Colors.blue,
                onPressed: () {},
                child: Icon(isExpanded ? Icons.close : Icons.menu),
              ),
              childWhenDragging: Container(),
              onDragEnd: (details) {
                setState(() {
                  posX = details.offset.dx.clamp(0, MediaQuery.of(context).size.width - 56);
                  posY = details.offset.dy.clamp(0, MediaQuery.of(context).size.height - 56);
                });
                _resetTimerAndShow();
              },
              child: FloatingActionButton(
                backgroundColor: isExpanded ? Colors.red : Colors.blue,
                onPressed: () {
                  setState(() => isExpanded = !isExpanded);
                  _resetTimerAndShow();
                },
                child: Icon(isExpanded ? Icons.close : Icons.menu),
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }
}
