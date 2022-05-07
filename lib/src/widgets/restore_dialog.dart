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

class RestoreDialog extends StatefulWidget {
  const RestoreDialog({Key? key}) : super(key: key);

  @override
  _RestoreDialogState createState() => _RestoreDialogState();
}

class _RestoreDialogState extends State<RestoreDialog> {
  late final TextEditingController _backupFileController;

  PlatformFile? _platformFile;

  @override
  void initState() {
    super.initState();
    _backupFileController = TextEditingController();
  }

  @override
  void dispose() {
    _backupFileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(16),
      titlePadding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      actionsPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      title: const Text("Restore data"),
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
                      hintText: "Select backup file",
                      hintStyle: TextStyle(fontSize: 16),
                      border: UnderlineInputBorder(),
                    ),
                    controller: _backupFileController,
                    onTap: () {
                      _selectBackupFile();
                    },
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
          child: const Text("Restore"),
          onPressed: () {
            _returnBackupData();
          },
        ),
      ],
    );
  }

  Future<void> _selectBackupFile() async {
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

    if (platformFileTemp.extension != 'sb') {
      // Clearing previous file selection
      _backupFileController.clear();
      _platformFile = null;

      Fluttertoast.showToast(
        msg: unsupportedFileFormat,
        toastLength: Toast.LENGTH_SHORT,
      );

      return;
    }

    // Setting file selection
    _backupFileController.text = path.basename(platformFileTemp.path!);

    _platformFile = platformFileTemp;
  }

  Future<void> _returnBackupData() async {
    // Hiding keyboard
    await SystemChannels.textInput.invokeMethod('TextInput.hide');

    // Checking validations
    if (_platformFile == null) {
      Fluttertoast.showToast(
        msg: backupFileNotSelected,
        toastLength: Toast.LENGTH_SHORT,
      );
      return;
    }

    // Navigating back with value
    Navigator.pop(
      context,
      _platformFile!.path!, // Backup file path,
    );
  }
}
