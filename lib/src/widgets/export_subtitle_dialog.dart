import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sublime/src/models/subtitle.dart';
import 'package:sublime/src/utilities/constants.dart';
import 'package:sublime/src/utilities/custom_icons.dart';

// Logger
final Logger log = Logger();

class ExportSubtitleDialog extends StatefulWidget {
  const ExportSubtitleDialog({
    Key? key,
    required this.subtitle,
  }) : super(key: key);

  final Subtitle subtitle;

  @override
  _ExportSubtitleDialogState createState() => _ExportSubtitleDialogState();
}

class _ExportSubtitleDialogState extends State<ExportSubtitleDialog> {
  late final TextEditingController _subtitleFolderController;
  late final TextEditingController _subtitleNameController;

  bool _includeDrafts = false;

  @override
  void initState() {
    super.initState();
    _subtitleFolderController = TextEditingController();
    _subtitleNameController = TextEditingController();

    // Setting subtitle name
    _subtitleNameController.text = widget.subtitle.subtitleName;
  }

  @override
  void dispose() {
    _subtitleFolderController.dispose();
    _subtitleNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(16),
      titlePadding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      actionsPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      title: const Text("Export subtitle"),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Wrap(
          runSpacing: 8,
          children: [
            Row(
              children: [
                const Icon(CustomIcons.rename),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    scrollPhysics: const BouncingScrollPhysics(),
                    style: const TextStyle(fontSize: 16),
                    decoration: const InputDecoration(
                      hintText: "Add subtitle file name",
                      hintStyle: TextStyle(fontSize: 16),
                      border: UnderlineInputBorder(),
                    ),
                    controller: _subtitleNameController,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(CustomIcons.folder),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    scrollPhysics: const BouncingScrollPhysics(),
                    readOnly: true,
                    style: const TextStyle(fontSize: 16),
                    decoration: const InputDecoration(
                      hintText: "Select subtitle folder",
                      hintStyle: TextStyle(
                        fontSize: 16,
                      ),
                      border: UnderlineInputBorder(),
                    ),
                    controller: _subtitleFolderController,
                    onTap: () {
                      _selectSubtitleFolder();
                    },
                  ),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  StatefulBuilder(builder: (context, setCheckBoxState) {
                    return SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _includeDrafts,
                        onChanged: (value) {
                          setCheckBoxState(() {
                            _includeDrafts = value as bool;
                          });
                        },
                      ),
                    );
                  }),
                  const SizedBox(width: 12),
                  const Text("Include drafts"),
                ],
              ),
            ),
          ],
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
          child: const Text("Export"),
          onPressed: () {
            _returnSubtitleData(context);
          },
        ),
      ],
    );
  }

  Future<void> _selectSubtitleFolder() async {
    // Checking storage permission
    if (await Permission.storage.status.isDenied) {
      if (await Permission.storage.request().isDenied) {
        Fluttertoast.showToast(
          msg: storagePermissionDenied,
          toastLength: Toast.LENGTH_SHORT,
        );
        return;
      }
    }

    // Showing file picker
    String? directoryPath = await FilePicker.platform.getDirectoryPath();

    if (directoryPath != null) {
      _subtitleFolderController.text = directoryPath;
    } else if (_subtitleFolderController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: noFolderSelected,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  Future<void> _returnSubtitleData(BuildContext context) async {
    // Hiding keyboard
    await SystemChannels.textInput.invokeMethod('TextInput.hide');

    // Checking validation
    if (_subtitleFolderController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: targetFolderNotSelected,
        toastLength: Toast.LENGTH_SHORT,
      );
      return;
    }

    if (_subtitleNameController.text.trim().isEmpty) {
      Fluttertoast.showToast(
        msg: subtitleNameEmpty,
        toastLength: Toast.LENGTH_SHORT,
      );
      return;
    }

    if (_subtitleNameController.text.contains(RegExp(r'[/\<>:"?*|]'))) {
      Fluttertoast.showToast(
        msg: containsInvalidCharacters,
        toastLength: Toast.LENGTH_SHORT,
      );
      return;
    }

    // Navigating back with values
    Navigator.pop(
      context,
      [
        _subtitleFolderController.text, // Selected folder
        _subtitleNameController.text.trim(), // Subtitle  file name
        _includeDrafts, // Flag for including drafts
      ],
    );
  }
}
