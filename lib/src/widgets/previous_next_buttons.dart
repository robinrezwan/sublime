import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:sublime/src/utilities/custom_icons.dart';

// Logger
final Logger log = Logger();

class PreviousNextButtons extends StatelessWidget {
  const PreviousNextButtons({
    Key? key,
    required this.onPressedPrevious,
    required this.onPressedNext,
  }) : super(key: key);

  final void Function() onPressedPrevious;
  final void Function() onPressedNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 44,
              child: OutlinedButton(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: const [
                    Icon(CustomIcons.chevronLeft),
                    Text("Previous"),
                  ],
                ),
                onPressed: onPressedPrevious,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: SizedBox(
              height: 44,
              child: ElevatedButton(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: const [
                    Text("Next"),
                    Icon(CustomIcons.chevronRight),
                  ],
                ),
                onPressed: onPressedNext,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
