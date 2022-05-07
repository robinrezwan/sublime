import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:sublime/src/widgets/custom_icon_button.dart';

// Logger
final Logger log = Logger();

class NipPainter extends CustomPainter {
  final bool isDown;
  final Color color;
  final Color shadowColor;
  final double shadowDepth;

  const NipPainter({
    this.isDown = true,
    required this.color,
    required this.shadowColor,
    required this.shadowDepth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();

    paint.strokeWidth = 2.0;
    paint.color = color;
    paint.style = PaintingStyle.fill;

    final Path path = Path();

    if (isDown) {
      path.moveTo(0.0, -1.0);
      path.lineTo(size.width, -1.0);
      path.lineTo(size.width / 2.0, size.height);
    } else {
      path.moveTo(size.width / 2.0, 0.0);
      path.lineTo(0.0, size.height + 1);
      path.lineTo(size.width, size.height + 1);
    }

    canvas.drawShadow(path, shadowColor, shadowDepth, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class BubblePopup {
  final GlobalKey key;

  final double popupWidth;
  final double popupHeight;

  final double elevation;
  final ShapeBorder? shape;

  final bool showBelow;

  final double nipWidth;
  final double nipHeight;

  final Widget Function(void Function() dismiss) builder;

  final Function(bool isShowing)? onStateChange;

  late final BuildContext _context;

  late final Rect _rect;
  late final Size _screenSize;
  late final Offset _offset;
  late final OverlayEntry _entry;

  bool _isNipDown = true;

  bool _isShowing = false;

  BubblePopup({
    required this.key,
    required this.popupWidth,
    required this.popupHeight,
    this.elevation = 2,
    this.shape,
    this.showBelow = false,
    this.nipWidth = 16,
    this.nipHeight = 10,
    required this.builder,
    this.onStateChange,
  });

  void show() {
    if (!_isShowing) {
      _context = key.currentContext!;

      _rect = _getGlobalRect();
      _offset = _getOffset();

      _entry = OverlayEntry(builder: (context) => _buildBubbleLayout(_offset));

      Overlay.of(_context)!.insert(_entry);
      _isShowing = true;

      if (onStateChange != null) {
        onStateChange!(true);
      }
    }
  }

  Rect _getGlobalRect() {
    RenderBox renderBox = _context.findRenderObject()! as RenderBox;
    Offset offset = renderBox.localToGlobal(Offset.zero);

    return Rect.fromLTWH(
      offset.dx,
      offset.dy,
      renderBox.size.width,
      renderBox.size.height,
    );
  }

  Offset _getOffset() {
    _screenSize = window.physicalSize / window.devicePixelRatio;

    double dx = _rect.left + _rect.width / 2 - popupWidth / 2;

    if (dx < 8) {
      dx = 8;
    }

    if (dx + popupWidth > _screenSize.width && dx > 8) {
      double tempDx = _screenSize.width - popupWidth - 8;

      if (tempDx > 8) {
        dx = tempDx;
      }
    }

    double dy = _rect.top - popupHeight;

    if (showBelow) {
      dy = nipHeight + _rect.height + _rect.top;
      _isNipDown = false;
    } else {
      if (dy <= MediaQuery.of(_context).padding.top + 8) {
        dy = nipHeight + _rect.height + _rect.top;
        _isNipDown = false;
      } else {
        dy -= nipHeight;
        _isNipDown = true;
      }
    }

    return Offset(dx, dy);
  }

  Widget _buildBubbleLayout(Offset offset) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: [
          // Elevation
          Positioned(
            left: offset.dx,
            top: offset.dy,
            child: Card(
              elevation: elevation,
              shape: shape,
              child: SizedBox(
                width: popupWidth,
                height: showBelow ? null : popupHeight,
              ),
            ),
          ),
          // Nip
          Positioned(
            left: _rect.left + _rect.width / 2 - nipWidth / 2,
            top: _isNipDown ? offset.dy + popupHeight : (offset.dy - nipHeight),
            child: CustomPaint(
              size: Size(nipWidth, nipHeight),
              painter: NipPainter(
                isDown: _isNipDown,
                color: Theme.of(_context).dialogBackgroundColor,
                shadowColor: Theme.of(_context).shadowColor,
                shadowDepth: elevation,
              ),
            ),
          ),
          // Child
          Positioned(
            left: offset.dx,
            top: offset.dy,
            child: GestureDetector(
              child: Card(
                elevation: 0,
                shape: shape,
                child: SizedBox(
                  width: popupWidth,
                  height: showBelow ? null : popupHeight,
                  child: builder(dismiss),
                ),
              ),
              onTap: () {},
            ),
          ),
        ],
      ),
      onTap: () {
        dismiss();
      },
    );
  }

  void dismiss() {
    if (_isShowing) {
      _entry.remove();
      _isShowing = false;

      if (onStateChange != null) {
        onStateChange!(false);
      }
    }
  }
}

class BubblePopupButton extends StatefulWidget {
  const BubblePopupButton({
    Key? key,
    required this.icon,
    this.tooltip,
    required this.popupWidth,
    required this.popupHeight,
    required this.popupBuilder,
    this.onPopupStateChange,
  }) : super(key: key);

  final Icon icon;
  final String? tooltip;
  final double popupWidth;
  final double popupHeight;
  final Widget Function(void Function() dismissPopup) popupBuilder;
  final Function(bool isShowing)? onPopupStateChange;

  @override
  _BubblePopupButtonState createState() => _BubblePopupButtonState();
}

class _BubblePopupButtonState extends State<BubblePopupButton> {
  final GlobalKey _bubblePopupKey = GlobalKey();
  BubblePopup? _bubblePopup;

  @override
  void dispose() {
    _bubblePopup?.dismiss();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _bubblePopup?.dismiss();
        return true;
      },
      child: CustomIconButton(
        key: _bubblePopupKey,
        icon: widget.icon,
        tooltip: widget.tooltip,
        onPressed: () {
          _bubblePopup = BubblePopup(
              key: _bubblePopupKey,
              builder: widget.popupBuilder,
              popupWidth: widget.popupWidth,
              popupHeight: widget.popupHeight,
              onStateChange: (isShowing) {
                if (!isShowing) {
                  _bubblePopup = null;
                }

                if (widget.onPopupStateChange != null) {
                  widget.onPopupStateChange!(isShowing);
                }
              });
          _bubblePopup?.show();
        },
      ),
    );
  }
}
