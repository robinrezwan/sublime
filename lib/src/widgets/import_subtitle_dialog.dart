import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:sublime/src/utilities/constants.dart';
import 'package:sublime/src/utilities/custom_icons.dart';

// Logger
final Logger log = Logger();

class ImportSubtitleDialog extends StatefulWidget {
  const ImportSubtitleDialog({Key? key}) : super(key: key);

  @override
  _ImportSubtitleDialogState createState() => _ImportSubtitleDialogState();
}

class _ImportSubtitleDialogState extends State<ImportSubtitleDialog> {
  late final TextEditingController _subtitleFileController;
  late final TextEditingController _subtitleNameController;

  PlatformFile? _platformFile;

  @override
  void initState() {
    super.initState();
    _subtitleFileController = TextEditingController();
    _subtitleNameController = TextEditingController();
  }

  @override
  void dispose() {
    _subtitleFileController.dispose();
    _subtitleNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(16),
      titlePadding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      actionsPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      title: const Text("Import subtitle"),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Wrap(
          runSpacing: 8,
          children: [
            Row(
              children: [
                const Icon(CustomIcons.file),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    scrollPhysics: const BouncingScrollPhysics(),
                    readOnly: true,
                    style: const TextStyle(fontSize: 16),
                    decoration: const InputDecoration(
                      hintText: "Select subtitle file",
                      hintStyle: TextStyle(fontSize: 16),
                      border: UnderlineInputBorder(),
                    ),
                    controller: _subtitleFileController,
                    onTap: () {
                      _selectSubtitleFile();
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(CustomIcons.rename),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    scrollPhysics: const BouncingScrollPhysics(),
                    style: const TextStyle(fontSize: 16),
                    decoration: const InputDecoration(
                      hintText: "Add subtitle name",
                      hintStyle: TextStyle(
                        fontSize: 16,
                      ),
                      border: UnderlineInputBorder(),
                    ),
                    controller: _subtitleNameController,
                  ),
                ),
              ],
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
          child: const Text("Import"),
          onPressed: () {
            _returnSubtitleData();
          },
        ),
      ],
    );
  }

  Future<void> _selectSubtitleFile() async {
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

    // Clearing cached files
    await FilePicker.platform.clearTemporaryFiles();

    // Showing file picker
    final FilePickerResult? filePickerResult =
        await FilePicker.platform.pickFiles();

    if (filePickerResult == null) {
      if (_platformFile == null) {
        Fluttertoast.showToast(
          msg: noFileSelected,
          toastLength: Toast.LENGTH_SHORT,
        );
      }
      return;
    }

    final PlatformFile platformFileTemp = filePickerResult.files.first;

    if (platformFileTemp.extension != 'srt') {
      // Clearing text fields and previous file selection
      _subtitleFileController.clear();
      _subtitleNameController.clear();

      _platformFile = null;

      Fluttertoast.showToast(
        msg: unsupportedFileFormat,
        toastLength: Toast.LENGTH_SHORT,
      );

      return;
    }

    // Setting text fields and file selection
    _subtitleFileController.text = path.basename(platformFileTemp.path!);
    _subtitleNameController.text = platformFileTemp.name
        .substring(0, platformFileTemp.name.lastIndexOf('.'));

    _platformFile = platformFileTemp;
  }

  Future<void> _returnSubtitleData() async {
    // Hiding keyboard
    await SystemChannels.textInput.invokeMethod('TextInput.hide');

    // Checking validations
    if (_platformFile == null) {
      Fluttertoast.showToast(
        msg: subtitleFileNotSelected,
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
        _platformFile!.path!, // Subtitle file path
        _subtitleNameController.text.trim(), // Subtitle name
      ],
    );
  }
}
