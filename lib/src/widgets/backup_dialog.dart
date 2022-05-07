import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sublime/src/utilities/constants.dart';
import 'package:sublime/src/utilities/custom_icons.dart';

// Logger
final Logger log = Logger();

class BackupDialog extends StatefulWidget {
  const BackupDialog({Key? key}) : super(key: key);

  @override
  _BackupDialogState createState() => _BackupDialogState();
}

class _BackupDialogState extends State<BackupDialog> {
  late final TextEditingController _backupFolderController;
  late final TextEditingController _backupNameController;

  @override
  void initState() {
    super.initState();
    _backupFolderController = TextEditingController();
    _backupNameController = TextEditingController();

    // Setting backup file name
    _backupNameController.text = "sublime-" +
        DateFormat('yyyy_MM_dd-hh_mm_ss_a')
            .format(DateTime.now())
            .toLowerCase();
  }

  @override
  void dispose() {
    _backupFolderController.dispose();
    _backupNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(16),
      titlePadding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      actionsPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      title: const Text("Backup data"),
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
                      hintText: "Add backup file name",
                      hintStyle: TextStyle(fontSize: 16),
                      border: UnderlineInputBorder(),
                    ),
                    controller: _backupNameController,
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
                      hintText: "Select backup folder",
                      hintStyle: TextStyle(
                        fontSize: 16,
                      ),
                      border: UnderlineInputBorder(),
                    ),
                    controller: _backupFolderController,
                    onTap: () {
                      _selectBackupFolder();
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
          child: const Text("Backup"),
          onPressed: () {
            _returnSubtitleData(context);
          },
        ),
      ],
    );
  }

  Future<void> _selectBackupFolder() async {
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
      _backupFolderController.text = directoryPath;
    } else if (_backupFolderController.text.isEmpty) {
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
    if (_backupFolderController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: targetFolderNotSelected,
        toastLength: Toast.LENGTH_SHORT,
      );
      return;
    }

    if (_backupNameController.text.trim().isEmpty) {
      Fluttertoast.showToast(
        msg: backupNameEmpty,
        toastLength: Toast.LENGTH_SHORT,
      );
      return;
    }

    if (_backupNameController.text.contains(RegExp(r'[/\<>:"?*|]'))) {
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
        _backupFolderController.text, // Selected folder
        _backupNameController.text.trim(), // Backup file name
      ],
    );
  }
}
