import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:html/parser.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:sublime/src/models/sequence.dart';
import 'package:sublime/src/models/subtitle.dart';
import 'package:sublime/src/providers/preference_provider.dart';
import 'package:sublime/src/providers/sequence_provider.dart';
import 'package:sublime/src/providers/subtitle_provider.dart';
import 'package:sublime/src/themes/custom_theme_data.dart';
import 'package:sublime/src/utilities/constants.dart';
import 'package:sublime/src/utilities/custom_icons.dart';
import 'package:sublime/src/utilities/extensions/color_extension.dart';
import 'package:sublime/src/utilities/extensions/map_extension.dart';
import 'package:sublime/src/utilities/languages.dart';
import 'package:sublime/src/utilities/undo_redo_manager.dart';
import 'package:sublime/src/widgets/bubble_popup.dart';
import 'package:sublime/src/widgets/custom_icon_button.dart';
import 'package:sublime/src/widgets/video_player_dialog.dart';
import 'package:translator/translator.dart';

// Logger
final Logger log = Logger();

class TranslatedTextBoxToolbar extends StatelessWidget {
  const TranslatedTextBoxToolbar({
    Key? key,
    required this.currentSequence,
    required this.originalController,
    required this.translatedController,
    required this.saveController,
    required this.undoRedoManager,
  }) : super(key: key);

  final Sequence currentSequence;
  final TextEditingController originalController;
  final TextEditingController translatedController;
  final RoundedLoadingButtonController saveController;

  final UndoRedoManager undoRedoManager;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CustomIconButton(
          icon: const Icon(CustomIcons.play),
          tooltip: "Play preview",
          onPressed: () {
            _showVideoPlayerDialog(context);
          },
          onDoubleTap: () {
            // TODO: 3/1/2022 Show preview subtitle preference dialog
          },
        ),
        CustomIconButton(
          icon: const Icon(CustomIcons.googleTranslate),
          tooltip: "Google Translate",
          onPressed: () {
            _translateText(context);
          },
          onDoubleTap: () {
            // TODO: 3/1/2022 Show translation language preference dialog
          },
        ),
        BubblePopupButton(
          icon: const Icon(CustomIcons.formatText),
          tooltip: "Format text",
          popupWidth: 180,
          popupHeight: 48,
          popupBuilder: (dismissFormatTextPopup) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconButton(
                  icon: const Icon(CustomIcons.formatBold),
                  tooltip: "Bold",
                  onPressed: () {
                    _formatText("<b>", "</b>");
                    dismissFormatTextPopup();
                  },
                ),
                CustomIconButton(
                  icon: const Icon(CustomIcons.formatItalic),
                  tooltip: "Italic",
                  onPressed: () {
                    _formatText("<i>", "</i>");
                    dismissFormatTextPopup();
                  },
                ),
                CustomIconButton(
                  icon: const Icon(CustomIcons.formatUnderline),
                  tooltip: "Underline",
                  onPressed: () {
                    _formatText("<u>", "</u>");
                    dismissFormatTextPopup();
                  },
                ),
                BubblePopupButton(
                  icon: const Icon(CustomIcons.formatColorText),
                  tooltip: "Color",
                  popupWidth: 180,
                  popupHeight: 48,
                  popupBuilder: (dismissColorPopup) {
                    final PreferenceProvider prefProvider =
                        Provider.of<PreferenceProvider>(context, listen: false);

                    final List<Color> recentColors =
                        prefProvider.getTextFormattingColorsPreference();

                    if (recentColors.isEmpty) {
                      recentColors.insertAll(0, [
                        const Color(0xFFFF0000),
                        const Color(0xFF00FF00),
                        const Color(0xFF0000FF),
                      ]);
                    } else if (recentColors.length < 2) {
                      recentColors.insertAll(0, [
                        const Color(0xFFFF0000),
                        const Color(0xFF00FF00),
                      ]);
                    } else if (recentColors.length < 3) {
                      recentColors.insertAll(0, [
                        const Color(0xFFFF0000),
                        const Color(0xFF00FF00),
                      ]);
                    }

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconButton(
                          icon: Icon(
                            CustomIcons.circleFilled,
                            color: recentColors[0],
                          ),
                          onPressed: () {
                            final String colorHex =
                                recentColors[0].toHex().toUpperCase();

                            _formatText("<font color=$colorHex>", "</font>");

                            _saveRecentColors(
                              prefProvider,
                              recentColors,
                              recentColors[0],
                            );

                            dismissColorPopup();
                          },
                        ),
                        CustomIconButton(
                          icon: Icon(
                            CustomIcons.circleFilled,
                            color: recentColors[1],
                          ),
                          onPressed: () {
                            final String colorHex =
                                recentColors[1].toHex().toUpperCase();

                            _formatText("<font color=$colorHex>", "</font>");

                            _saveRecentColors(
                                prefProvider, recentColors, recentColors[1]);

                            dismissColorPopup();
                          },
                        ),
                        CustomIconButton(
                          icon: Icon(
                            CustomIcons.circleFilled,
                            color: recentColors[2],
                          ),
                          onPressed: () {
                            final String colorHex =
                                recentColors[2].toHex().toUpperCase();

                            _formatText("<font color=$colorHex>", "</font>");

                            _saveRecentColors(
                                prefProvider, recentColors, recentColors[2]);

                            dismissColorPopup();
                          },
                        ),
                        CustomIconButton(
                          icon: const Icon(CustomIcons.plusCircle),
                          tooltip: "More colors",
                          onPressed: () async {
                            dismissColorPopup();

                            // FIXME: 11/6/2021 [TextFormField] does not preserve text selection when opening dialogs
                            // Working around by storing the [TextEditingValue] manually
                            // Change it when the issue is resolved
                            final TextEditingValue textEditingValue =
                                translatedController.value;

                            // Showing color picker dialog
                            Color? selectedColor =
                                await _showColorPickerDialog(context);

                            // Restoring the value after 10 milliseconds, because doing it
                            // immediately does not work
                            await Future.delayed(
                                const Duration(milliseconds: 10), () {
                              translatedController.value = TextEditingValue(
                                text: textEditingValue.text,
                                selection: textEditingValue.selection,
                                composing: textEditingValue.composing,
                              );
                            });

                            if (selectedColor != null) {
                              final String colorHex =
                                  selectedColor.toHex().toUpperCase();

                              _formatText("<font color=$colorHex>", "</font>");

                              _saveRecentColors(
                                  prefProvider, recentColors, selectedColor);
                            }
                          },
                        ),
                      ],
                    );
                  },
                  onPopupStateChange: (isShowing) {
                    if (!isShowing) {
                      dismissFormatTextPopup();
                    }
                  },
                ),
              ],
            );
          },
        ),
        CustomIconButton(
          icon: const Icon(CustomIcons.undo),
          tooltip: "Undo",
          onPressed: () {
            if (!undoRedoManager.undo(translatedController)) {
              Fluttertoast.showToast(
                msg: undoNotAvailable,
                toastLength: Toast.LENGTH_SHORT,
              );
            }
          },
        ),
        CustomIconButton(
          icon: const Icon(CustomIcons.redo),
          tooltip: "Redo",
          onPressed: () {
            if (!undoRedoManager.redo(translatedController)) {
              Fluttertoast.showToast(
                msg: redoNotAvailable,
                toastLength: Toast.LENGTH_SHORT,
              );
            }
          },
        ),
        Expanded(
          child: Selector<SequenceProvider, bool>(
              selector: (context, seqProvider) => seqProvider.getIsChanged(),
              builder: (context, isChanged, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!isChanged && currentSequence.translatedText.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: Icon(
                          CustomIcons.check,
                          size: 20,
                          color: currentSequence.isCompleted
                              ? Theme.of(context).colorScheme.green
                              : Theme.of(context).colorScheme.yellow,
                        ),
                      ),
                    SizedBox(
                      height: 32,
                      width: 68,
                      child: RoundedLoadingButton(
                        elevation: 1,
                        child: const Text("Save"),
                        color: Theme.of(context).colorScheme.green,
                        loaderSize: 18,
                        animateOnTap: false,
                        controller: saveController,
                        onPressed: () {
                          _saveSequence(context);
                        },
                      ),
                    ),
                  ],
                );
              }),
        ),
      ],
    );
  }

  void _translateText(BuildContext context) async {
    // Checking connectivity
    final ConnectivityResult connectivityResult =
        await Connectivity().checkConnectivity();

    if (connectivityResult != ConnectivityResult.wifi &&
        connectivityResult != ConnectivityResult.mobile) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(noInternetConnection),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: "Connect",
            onPressed: () {
              AppSettings.openWIFISettings();
            },
          ),
        ),
      );
      return;
    }

    // Getting text from text field
    final Sequence sequence = currentSequence;

    String translatingText;

    if (originalController.selection.isCollapsed) {
      translatingText = originalController.text;
    } else {
      translatingText =
          originalController.selection.textInside(originalController.text);
    }

    // Removing line breaks
    translatingText = translatingText.replaceAll('\n', ' ');

    // Removing HTML tags
    translatingText = parse(translatingText).documentElement!.text;

    if (translatingText.isEmpty) {
      return;
    }

    try {
      final String languagePreference =
          Provider.of<PreferenceProvider>(context, listen: false)
              .getTranslationLanguagePreference();

      final String? languageCode = Languages.langs.keyOf(languagePreference);

      // Translating
      final Translation translation =
          await translatingText.translate(to: languageCode!);

      final SequenceProvider seqProvider =
          Provider.of<SequenceProvider>(context, listen: false);

      if (sequence == seqProvider.getCurrentSequence()) {
        // Setting value to text field
        translatedController.value = TextEditingValue(
          text: translation.text,
          selection: TextSelection.collapsed(offset: translation.text.length),
        );

        // Storing edit history
        undoRedoManager.insert(translatedController);

        seqProvider.setIsChanged(true);
      }
    } catch (exception) {
      Fluttertoast.showToast(
        msg: translationFailed,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  void _formatText(String openingTag, String closingTag) {
    String text = translatedController.text;
    TextSelection selection = translatedController.selection;

    String formattedText = selection.textBefore(text) +
        openingTag +
        selection.textInside(text) +
        closingTag +
        selection.textAfter(text);

    int cursorPosition = selection.end + openingTag.length;

    // Setting value to text field
    translatedController.clearComposing();
    translatedController.value = TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );

    // Storing edit history
    undoRedoManager.insert(translatedController);
  }

  Future<Color?> _showColorPickerDialog(BuildContext context) async {
    Color currentColor = const Color(0xFFFF0000);

    Color? selectedColor = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          contentPadding: const EdgeInsets.all(0),
          actionsPadding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setColorPickerState) {
                return ColorPicker(
                  pickerAreaBorderRadius:
                      const BorderRadius.all(Radius.circular(10)),
                  displayThumbColor: true,
                  enableAlpha: false,
                  labelTypes: const [ColorLabelType.hex, ColorLabelType.rgb],
                  pickerColor: currentColor,
                  onColorChanged: (color) {
                    setColorPickerState(() => currentColor = color);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: const Text("Done"),
              onPressed: () {
                // Navigating back with value
                Navigator.pop(context, currentColor);
              },
            ),
          ],
        );
      },
    );

    return selectedColor;
  }

  void _saveRecentColors(PreferenceProvider prefProvider,
      List<Color> recentColors, Color newColor) {
    recentColors.remove(newColor);

    if (recentColors.length >= 3) {
      recentColors.removeAt(0);
    }

    recentColors.add(newColor);

    prefProvider.setTextFormattingColorsPreference(recentColors);
  }

  void _saveSequence(BuildContext context) async {
    final SequenceProvider seqProvider =
        Provider.of<SequenceProvider>(context, listen: false);

    if (seqProvider.getIsChanged()) {
      saveController.start();

      currentSequence.translatedText = translatedController.text;
      currentSequence.isCompleted = true;

      try {
        await seqProvider.updateSequence(currentSequence);

        // Updating metadata
        Provider.of<SubtitleProvider>(context, listen: false)
            .updateCurrentSubtitleMetadata(currentSequence.isCompleted);

        Fluttertoast.showToast(
          msg: saved,
          toastLength: Toast.LENGTH_SHORT,
        );
      } catch (exception) {
        Fluttertoast.showToast(
          msg: savingFailed,
          toastLength: Toast.LENGTH_SHORT,
        );
      }

      Future.delayed(const Duration(milliseconds: 1000), () {
        saveController.reset();
      });
    } else {
      Fluttertoast.showToast(
        msg: noChanges,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  Future<void> _showVideoPlayerDialog(BuildContext context) async {
    // Hiding keyboard
    await SystemChannels.textInput.invokeMethod('TextInput.hide');

    // Waiting for the keyboard to finish hiding
    await Future.delayed(const Duration(milliseconds: 50));

    SubtitleProvider subtitleProvider =
        Provider.of<SubtitleProvider>(context, listen: false);
    Subtitle subtitle = subtitleProvider.getCurrentSubtitle();

    // FIXME: 11/6/2021 [TextFormField] does not preserve text selection when opening dialogs
    // Working around by storing the [TextEditingValue] manually
    // Change it when the issue is resolved
    final TextEditingValue textEditingValue = translatedController.value;

    await showDialog(
      context: context,
      builder: (context) => VideoPlayerDialog(subtitle: subtitle),
    );

    // Restoring the value after 10 milliseconds, because doing it
    // immediately does not work
    await Future.delayed(const Duration(milliseconds: 10), () {
      translatedController.value = TextEditingValue(
        text: textEditingValue.text,
        selection: textEditingValue.selection,
        composing: textEditingValue.composing,
      );
    });
  }
}
