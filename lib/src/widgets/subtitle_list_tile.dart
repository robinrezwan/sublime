import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:sublime/src/models/subtitle.dart';
import 'package:sublime/src/providers/preference_provider.dart';
import 'package:sublime/src/providers/subtitle_provider.dart';
import 'package:sublime/src/themes/custom_theme_data.dart';
import 'package:sublime/src/utilities/custom_icons.dart';
import 'package:sublime/src/utilities/extensions/date_time_extension.dart';
import 'package:sublime/src/widgets/custom_text.dart';

class SubtitleListTile extends StatelessWidget {
  const SubtitleListTile({
    Key? key,
    required this.subtitle,
    required this.onTap,
  }) : super(key: key);

  final Subtitle subtitle;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final SubtitlesSort subtitlesSortPreference =
        Provider.of<SubtitleProvider>(context, listen: false)
            .getSortPreference();

    final String dateTime = subtitlesSortPreference == SubtitlesSort.modified
        ? subtitle.dateTimeModified.format("Modified")
        : subtitle.dateTimeCreated.format("Created");

    final double progress = subtitle.metadata!.noOfCompletedSequences /
        subtitle.metadata!.noOfSequences;

    return ListTile(
      contentPadding: const EdgeInsets.only(left: 16),
      horizontalTitleGap: 0,
      title: CustomText(
        subtitle.subtitleName,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              dateTime,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (subtitle.isFavorite)
            Container(
              margin: const EdgeInsets.only(right: 4),
              child: Icon(
                CustomIcons.favorite,
                size: 20,
                color: Theme.of(context).colorScheme.red,
              ),
            ),
        ],
      ),
      trailing: Container(
        height: 64,
        width: 64,
        alignment: Alignment.center,
        child: (progress != 1)
            ? CircularPercentIndicator(
                radius: 32.4,
                lineWidth: 3.2,
                backgroundWidth: 3.2,
                progressColor: Theme.of(context).colorScheme.green,
                backgroundColor: Theme.of(context).colorScheme.objectBackground,
                circularStrokeCap: CircularStrokeCap.round,
                animation: true,
                animateFromLastPercent: true,
                percent: progress,
              )
            : TweenAnimationBuilder(
                duration: const Duration(milliseconds: 300),
                tween: IntTween(begin: 19, end: 38),
                builder: (context, int size, widget) {
                  return Icon(
                    CustomIcons.checkCircleFilled,
                    size: size.toDouble(),
                    color: Theme.of(context).colorScheme.green,
                  );
                },
              ),
      ),
      onTap: onTap,
    );
  }
}
