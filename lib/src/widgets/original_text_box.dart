import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:sublime/src/models/sequence.dart';
import 'package:sublime/src/utilities/custom_icons.dart';

// Logger
final Logger log = Logger();

class OriginalTextBox extends StatelessWidget {
  const OriginalTextBox({
    Key? key,
    required this.sequence,
    required this.controller,
  }) : super(key: key);

  final Sequence sequence;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    controller.text = sequence.originalText;

    return Card(
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Container(
        height: 116,
        margin: const EdgeInsets.all(8),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(CustomIcons.clapperBoardOpen),
                const SizedBox(width: 8),
                Text(
                  sequence.sequenceNo.toString(),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const Divider(height: 4),
            Row(
              children: [
                const Icon(CustomIcons.time),
                const SizedBox(width: 8),
                Row(
                  children: [
                    Text(
                      sequence.startTime,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Text(
                      " -> ",
                      style: TextStyle(
                        fontSize: 16,
                        fontFeatures: [
                          FontFeature.enable('clig'),
                        ],
                      ),
                    ),
                    Text(
                      sequence.startTime,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(CustomIcons.text),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    scrollPhysics: const BouncingScrollPhysics(),
                    readOnly: true,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(top: 2),
                    ),
                    controller: controller,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
