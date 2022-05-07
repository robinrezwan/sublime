import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:sublime/src/models/sequence.dart';
import 'package:sublime/src/utilities/custom_icons.dart';

// Logger
final Logger log = Logger();

class TranslatedTextBox extends StatelessWidget {
  const TranslatedTextBox({
    Key? key,
    required this.sequence,
    required this.controller,
    required this.onChanged,
    required this.toolbar,
  }) : super(key: key);

  final Sequence sequence;
  final TextEditingController controller;
  final void Function(String) onChanged;
  final Widget toolbar;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Container(
        height: 116,
        margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(CustomIcons.text),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    scrollPhysics: const BouncingScrollPhysics(),
                    // [autofocus: true] causes opening of keyboard everytime
                    // the widget rebuilds, like when an alert dialog is opened
                    // and closed
                    // FIXME: 11/10/2021 Unintentional keyboard opening on widget rebuild
                    autofocus: true,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(top: 2),
                      hintText: "Add translated text",
                    ),
                    controller: controller,
                    onChanged: onChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            Expanded(
              child: toolbar,
            ),
          ],
        ),
      ),
    );
  }
}
