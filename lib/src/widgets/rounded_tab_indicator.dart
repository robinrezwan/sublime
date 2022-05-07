import 'package:flutter/widgets.dart';

class RoundedTabIndicator extends Decoration {
  const RoundedTabIndicator({
    required this.color,
  });

  final Color color;

  @override
  _RoundedTabIndicatorPainter createBoxPainter([VoidCallback? onChanged]) {
    return _RoundedTabIndicatorPainter(color, onChanged);
  }
}

class _RoundedTabIndicatorPainter extends BoxPainter {
  _RoundedTabIndicatorPainter(
    this.color,
    VoidCallback? onChanged,
  ) : super(onChanged);

  final Color color;

  final double height = 4;
  final double margin = 6;
  final double radius = 8;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Size size = configuration.size!;

    final Rect rect = Offset(
          offset.dx + margin,
          size.height - height,
        ) &
        Size(
          size.width - (2 * margin),
          height,
        );

    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndCorners(
        rect,
        topLeft: Radius.circular(radius),
        topRight: Radius.circular(radius),
      ),
      paint,
    );
  }
}
