import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

typedef StickerUpdate = void Function(double x, double y, double scale);

class DraggableStickerWidget extends StatefulWidget {
  final String assetPath;
  final double initialX;
  final double initialY;
  final double initialScale;
  final StickerUpdate onUpdate;

  const DraggableStickerWidget({
    required Key key,
    required this.assetPath,
    required this.initialX,
    required this.initialY,
    required this.initialScale,
    required this.onUpdate,
  }) : super(key: key);

  @override
  State<DraggableStickerWidget> createState() => _DraggableStickerWidgetState();
}

class _DraggableStickerWidgetState extends State<DraggableStickerWidget> {
  late double top;
  late double left;
  late double scale;

  @override
  void initState() {
    super.initState();
    top = widget.initialY;
    left = widget.initialX;
    scale = widget.initialScale;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            top += details.delta.dy;
            left += details.delta.dx;
            widget.onUpdate(left, top, scale);
          });
        },
        onScaleUpdate: (details) {
          setState(() {
            scale = (details.scale).clamp(0.5, 3.0);
            widget.onUpdate(left, top, scale);
          });
        },
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => Center(child: Lottie.asset('assets/animations/sticker_sparkle.json', width: 140, height: 140, repeat: false)),
          );
        },
        child: Transform.scale(
          scale: scale,
          child: Image.asset(widget.assetPath, width: 84, height: 84),
        ),
      ),
    );
  }
}
