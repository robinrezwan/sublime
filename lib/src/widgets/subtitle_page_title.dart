import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:sublime/src/models/subtitle.dart';
import 'package:sublime/src/providers/subtitle_provider.dart';
import 'package:sublime/src/themes/custom_theme_data.dart';
import 'package:sublime/src/utilities/custom_icons.dart';
import 'package:sublime/src/utilities/extensions/date_time_extension.dart';
import 'package:sublime/src/widgets/custom_alert_dialog.dart';
import 'package:sublime/src/widgets/custom_text.dart';
import 'package:sublime/src/widgets/two_layer_circular_percent_indicator.dart';

class SubtitlePageTitle extends StatelessWidget {
  const SubtitlePageTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SubtitleProvider>(
      builder: (context, subtitleProvider, child) {
        final Subtitle subtitle = subtitleProvider.getCurrentSubtitle();

        final double progress = subtitle.metadata!.noOfCompletedSequences /
            subtitle.metadata!.noOfSequences;
        final double draftProgress = subtitle.metadata!.noOfDraftSequences /
            subtitle.metadata!.noOfSequences;

        return GestureDetector(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                subtitle.subtitleName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 4, top: 2),
                        child: LinearPercentIndicator(
                          width: constraints.maxWidth - 42,
                          lineHeight: 7.4,
                          padding: EdgeInsets.zero,
                          progressColor: Theme.of(context).colorScheme.green,
                          backgroundColor:
                              Theme.of(context).colorScheme.objectBackground,
                          animation: true,
                          animateFromLastPercent: true,
                          percent: progress,
                        ),
                      ),
                      Container(
                        width: 28,
                        margin: const EdgeInsets.only(left: 10),
                        child: Text(
                          (progress * 100).toInt().toString() + "%",
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          onTap: () {
            _showSubtitleInfoDialog(context, subtitle, progress, draftProgress);
          },
        );
      },
    );
  }

  Future<void> _showSubtitleInfoDialog(BuildContext context, Subtitle subtitle,
      double progress, double draftProgress) async {
    // Hiding keyboard
    await SystemChannels.textInput.invokeMethod('TextInput.hide');

    // Waiting for the keyboard to finish hiding
    await Future.delayed(const Duration(milliseconds: 50));

    // Showing subtitle info dialog
    await showDialog(
        context: context,
        builder: (context) {
          return CustomAlertDialog(
            contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            title: Text(
              subtitle.subtitleName,
              style: const TextStyle(fontSize: 18),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtitle.dateTimeCreated.format("Created"),
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  subtitle.dateTimeModified.format("Modified"),
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 20),
                Container(
                  alignment: Alignment.center,
                  child: TwoLayerCircularPercentIndicator(
                    radius: 180,
                    lineWidth: 8,
                    primaryProgressColor: Theme.of(context).colorScheme.green,
                    secondaryProgressColor:
                        Theme.of(context).colorScheme.yellow,
                    backgroundColor:
                        Theme.of(context).colorScheme.objectBackground,
                    primaryPercent: progress,
                    secondaryPercent: progress + draftProgress,
                    center: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Draft: " +
                            (draftProgress * 100)
                                .toStringAsFixed(2)
                                .toString() +
                            "%"),
                        Text("Completed: " +
                            (progress * 100).toStringAsFixed(2).toString() +
                            "%"),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      CustomIcons.circleFilled,
                      size: 16,
                      color: Theme.of(context).colorScheme.objectBackground,
                    ),
                    const SizedBox(width: 8),
                    Text("Total: " +
                        subtitle.metadata!.noOfSequences.toString()),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      CustomIcons.circleFilled,
                      size: 16,
                      color: Theme.of(context).colorScheme.yellow,
                    ),
                    const SizedBox(width: 8),
                    Text("Draft: " +
                        subtitle.metadata!.noOfDraftSequences.toString()),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      CustomIcons.circleFilled,
                      size: 16,
                      color: Theme.of(context).colorScheme.green,
                    ),
                    const SizedBox(width: 8),
                    Text("Completed: " +
                        subtitle.metadata!.noOfCompletedSequences.toString()),
                  ],
                )
              ],
            ),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }
}
