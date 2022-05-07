import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    Key? key,
    required this.icon,
    this.tooltip,
    required this.onPressed,
    this.onDoubleTap,
  }) : super(key: key);

  final Widget icon;
  final String? tooltip;
  final GestureTapCallback? onPressed;
  final GestureTapCallback? onDoubleTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      radius: 20,
      child: tooltip != null
          ? Tooltip(
              child: _setIcon(),
              message: tooltip!,
            )
          : _setIcon(),
      onTap: onPressed,
      onDoubleTap: onDoubleTap,
    );
  }

  Widget _setIcon() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: icon,
    );
  }
}
