import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sublime/src/models/sequence.dart';
import 'package:sublime/src/models/subtitle.dart';
import 'package:sublime/src/providers/sequence_provider.dart';
import 'package:sublime/src/providers/subtitle_provider.dart';
import 'package:sublime/src/themes/custom_theme_data.dart';
import 'package:sublime/src/utilities/constants.dart';
import 'package:sublime/src/utilities/custom_icons.dart';
import 'package:sublime/src/widgets/custom_alert_dialog.dart';
import 'package:sublime/src/widgets/custom_popup_menu_button.dart';
import 'package:sublime/src/widgets/export_subtitle_dialog.dart';

class SubtitlePageOptions extends StatefulWidget {
  const SubtitlePageOptions({
    Key? key,
    required this.context,
    required this.subtitle,
    required this.tabController,
    required this.itemScrollController,
  }) : super(key: key);

  final BuildContext context;
  final Subtitle subtitle;
  final TabController tabController;
  final ItemScrollController itemScrollController;

  @override
  _SubtitlePageOptionsState createState() => _SubtitlePageOptionsState();
}

class _SubtitlePageOptionsState extends State<SubtitlePageOptions> {
  late final TextEditingController subtitleNameController;

  @override
  void initState() {
    super.initState();
    subtitleNameController = TextEditingController();
  }

  @override
  void dispose() {
    subtitleNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopupMenuButton(
      icon: const Icon(CustomIcons.more),
      tooltip: "More options",
      itemBuilder: (context) {
        return <PopupMenuEntry>[
          PopupMenuItem(
            value: 0,
            child: Row(
              children: [
                Selector<SubtitleProvider, bool>(
                  selector: (context, subtitleProvider) =>
                      subtitleProvider.getCurrentSubtitle().isFavorite,
                  builder: (context, isFavorite, child) {
                    return Icon(
                      CustomIcons.favorite,
                      color: isFavorite
                          ? Theme.of(context).colorScheme.red
                          : Theme.of(context).colorScheme.objectBackground,
                    );
                  },
                ),
                const SizedBox(width: 16),
                const Text("Favorite"),
              ],
            ),
          ),
          const PopupMenuDivider(),
          const PopupMenuItem(
            value: 1,
            child: Text("Go to"),
          ),
          const PopupMenuItem(
            value: 2,
            child: Text("Rename"),
          ),
          const PopupMenuItem(
            value: 3,
            child: Text("Delete"),
          ),
          const PopupMenuItem(
            value: 4,
            child: Text("Export"),
          ),
        ];
      },
      onSelected: (value) {
        switch (value) {
          case 0:
            _toggleFavorite(widget.subtitle);
            break;
          case 1:
            _showGoToDialog(widget.subtitle, widget.tabController,
                widget.itemScrollController);
            break;
          case 2:
            _showRenameDialog(widget.subtitle);
            break;
          case 3:
            _showDeleteDialog(widget.subtitle);
            break;
          case 4:
            _showExportSubtitleDialog(widget.subtitle);
            break;
        }
      },
    );
  }

  Future<void> _toggleFavorite(Subtitle subtitle) async {
    subtitle.isFavorite = !subtitle.isFavorite;

    try {
      await Provider.of<SubtitleProvider>(widget.context, listen: false)
          .updateIsFavorite(subtitle);

      if (subtitle.isFavorite) {
        Fluttertoast.showToast(
          msg: addedToFavorites,
          toastLength: Toast.LENGTH_SHORT,
        );
      } else {
        Fluttertoast.showToast(
          msg: removedFromFavorites,
          toastLength: Toast.LENGTH_SHORT,
        );
      }
    } catch (exception) {
      subtitle.isFavorite = !subtitle.isFavorite;

      Fluttertoast.showToast(
        msg: favoritesUpdatingFailed,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  Future<void> _showGoToDialog(Subtitle subtitle, TabController tabController,
      ItemScrollController itemScrollController) async {
    String inputSequenceNo = '';

    await showDialog(
        context: context,
        builder: (context) {
          return CustomAlertDialog(
            title: const Text("Go to"),
            content: Row(
              children: [
                const Icon(CustomIcons.clapperBoardOpen),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    scrollPhysics: const BouncingScrollPhysics(),
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 16),
                    decoration: const InputDecoration(
                      hintText: "Enter sequence no",
                      hintStyle: TextStyle(fontSize: 16),
                      border: UnderlineInputBorder(),
                    ),
                    onChanged: (value) {
                      inputSequenceNo = value;
                    },
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              ElevatedButton(
                child: const Text("Go"),
                onPressed: () async {
                  // Hiding keyboard
                  await SystemChannels.textInput.invokeMethod('TextInput.hide');

                  if (inputSequenceNo.isEmpty) {
                    Fluttertoast.showToast(
                      msg: emptySequenceNo,
                      toastLength: Toast.LENGTH_SHORT,
                    );

                    return;
                  }

                  // Parsing input sequence no
                  final int? sequenceNo = int.tryParse(inputSequenceNo);

                  if (sequenceNo == null) {
                    Fluttertoast.showToast(
                      msg: invalidSequenceNo,
                      toastLength: Toast.LENGTH_SHORT,
                    );

                    return;
                  }

                  final SequenceProvider seqProvider =
                      Provider.of<SequenceProvider>(context, listen: false);

                  // Searching sequence index by sequence no
                  final int index = subtitle.sequenceList!.indexWhere(
                      (element) => element.sequenceNo == sequenceNo);

                  if (index < 0) {
                    Fluttertoast.showToast(
                      msg: sequenceNotFound,
                      toastLength: Toast.LENGTH_SHORT,
                    );

                    return;
                  }

                  // Setting current sequence
                  subtitle.currentSequenceId = index + 1;
                  seqProvider.setCurrentSequence(subtitle.sequenceList![index]);

                  // Closing dialog
                  Navigator.pop(context);

                  // Changing scroll position to current sequence
                  if (tabController.index == 1) {
                    itemScrollController.jumpTo(index: index);
                  }
                },
              ),
            ],
          );
        });
  }

  Future<void> _showRenameDialog(Subtitle subtitle) async {
    // [autofocus: true] creates problems with inserting characters
    // when using [initialValue] in [TextFormField]
    // So, [TextEditingController] had to be used to set the initial text of
    // the [TextFormField] and set the cursor at the end of the text
    // TODO: 10/31/2021 Change it when the [TextFormField] autofocus issue is resolved
    subtitleNameController.value = TextEditingValue(
      text: subtitle.subtitleName,
      selection: TextSelection.collapsed(offset: subtitle.subtitleName.length),
    );

    await showDialog(
        context: context,
        builder: (context) {
          return CustomAlertDialog(
            title: const Text("Rename"),
            content: Row(
              children: [
                const Icon(CustomIcons.rename),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    scrollPhysics: const BouncingScrollPhysics(),
                    autofocus: true,
                    style: const TextStyle(fontSize: 16),
                    decoration: const InputDecoration(
                      hintText: "Enter subtitle name",
                      hintStyle: TextStyle(fontSize: 16),
                      border: UnderlineInputBorder(),
                    ),
                    controller: subtitleNameController,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              ElevatedButton(
                child: const Text("Save"),
                onPressed: () async {
                  // Hiding keyboard
                  await SystemChannels.textInput.invokeMethod('TextInput.hide');

                  if (subtitleNameController.text.trim().isEmpty) {
                    Fluttertoast.showToast(
                      msg: subtitleNameEmpty,
                      toastLength: Toast.LENGTH_SHORT,
                    );

                    return;
                  }

                  if (subtitleNameController.text
                      .contains(RegExp(r'[/\<>:"?*|]'))) {
                    Fluttertoast.showToast(
                      msg: containsInvalidCharacters,
                      toastLength: Toast.LENGTH_SHORT,
                    );

                    return;
                  }

                  // Saving subtitle name to database
                  String subtitleNameTemp = subtitle.subtitleName;
                  subtitle.subtitleName = subtitleNameController.text.trim();

                  try {
                    await Provider.of<SubtitleProvider>(context, listen: false)
                        .renameSubtitle(subtitle);

                    Fluttertoast.showToast(
                      msg: renamed,
                      toastLength: Toast.LENGTH_SHORT,
                    );
                  } catch (exception) {
                    subtitle.subtitleName = subtitleNameTemp;

                    Fluttertoast.showToast(
                      msg: renamingFailed,
                      toastLength: Toast.LENGTH_SHORT,
                    );
                  }

                  // Closing dialog
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  Future<void> _showDeleteDialog(Subtitle subtitle) async {
    await showDialog(
        context: context,
        builder: (context) {
          return CustomAlertDialog(
            title: const Text("Delete subtitle"),
            content:
                const Text("Do you want to delete this subtitle permanently?"),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              ElevatedButton(
                child: const Text("Delete"),
                onPressed: () async {
                  try {
                    await Provider.of<SubtitleProvider>(context, listen: false)
                        .deleteSubtitle(subtitle.subtitleId!);

                    Fluttertoast.showToast(
                      msg: subtitleDeleted,
                      toastLength: Toast.LENGTH_SHORT,
                    );

                    Navigator.pop(context);
                  } catch (exception) {
                    Fluttertoast.showToast(
                      msg: subtitleDeletingFailed,
                      toastLength: Toast.LENGTH_SHORT,
                    );
                  }

                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  Future<void> _showExportSubtitleDialog(Subtitle subtitle) async {
    final List<dynamic>? subtitleData = await showDialog(
      context: context,
      builder: (context) => ExportSubtitleDialog(subtitle: subtitle),
    );

    if (subtitleData == null) {
      return;
    }

    final String subtitleFolderPath = subtitleData.elementAt(0);
    final String subtitleName = subtitleData.elementAt(1);
    final bool includeDrafts = subtitleData.elementAt(2);

    // Formatting subtitle into string
    String subtitleString = '';

    for (Sequence sequence in subtitle.sequenceList!) {
      String sequenceString = '';

      sequenceString += sequence.sequenceNo.toString() + '\n';
      sequenceString += sequence.startTime + ' --> ' + sequence.endTime + '\n';

      if (sequence.isCompleted || includeDrafts) {
        sequenceString += sequence.translatedText;
      }

      sequenceString += '\n\n';

      subtitleString += sequenceString;
    }

    try {
      // Saving subtitle in file
      final String subtitleFilePath =
          path.join(subtitleFolderPath, subtitleName + '.srt');
      final File subtitleFile = File(subtitleFilePath);

      subtitleFile.writeAsStringSync(subtitleString, encoding: utf8);

      Fluttertoast.showToast(
        msg: subtitleExported,
        toastLength: Toast.LENGTH_SHORT,
      );
    } catch (exception) {
      Fluttertoast.showToast(
        msg: subtitleExportingFailed,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }
}
