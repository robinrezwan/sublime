import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final EdgeInsetsGeometry titlePadding;
  final EdgeInsetsGeometry contentPadding;
  final EdgeInsetsGeometry actionsPadding;
  final Widget? title;
  final Widget content;
  final List<Widget> actions;

  const CustomAlertDialog(
      {Key? key,
      this.titlePadding = const EdgeInsets.fromLTRB(20, 16, 20, 8),
      this.contentPadding =
          const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      this.actionsPadding =
          const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      this.title,
      required this.content,
      required this.actions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(32),
      titlePadding: titlePadding,
      contentPadding: contentPadding,
      actionsPadding: actionsPadding,
      title: title,
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: content,
      ),
      actions: actions,
    );
  }
}
