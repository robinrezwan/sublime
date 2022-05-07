import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sublime/src/models/subtitle.dart';
import 'package:sublime/src/utilities/constants.dart';
import 'package:sublime/src/utilities/custom_icons.dart';
import 'package:sublime/src/widgets/file_selector_fullscreen_dialog.dart';

// Logger
final Logger log = Logger();

class AddVideoDialog extends StatefulWidget {
  const AddVideoDialog({
    Key? key,
    required this.subtitle,
  }) : super(key: key);

  final Subtitle subtitle;

  @override
  _AddVideoDialogState createState() => _AddVideoDialogState();
}

class _AddVideoDialogState extends State<AddVideoDialog> {
  static final List<String> _videoFormats = [
    'webm',
    'mpeg',
    'mkv',
    'mp4',
    'avi',
    'mov',
    'flv'
  ];

  late final TextEditingController _videoFolderController;
  late final TextEditingController _videoFileController;

  final List<FileSystemEntity> _videoFileSystemEntityList = [];
  String? _selectedVideoFilePath;

  @override
  void initState() {
    super.initState();
    _videoFolderController = TextEditingController();
    _videoFileController = TextEditingController();
  }

  @override
  void dispose() {
    _videoFolderController.dispose();
    _videoFileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(16),
      titlePadding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      actionsPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      title: const Text("Add video"),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Wrap(
          runSpacing: 8,
          children: [
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
                      hintText: "Select video folder",
                      hintStyle: TextStyle(fontSize: 16),
                      border: UnderlineInputBorder(),
                    ),
                    controller: _videoFolderController,
                    onTap: () {
                      _selectVideoFolder();
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(CustomIcons.movieOutlined),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    scrollPhysics: const BouncingScrollPhysics(),
                    readOnly: true,
                    style: const TextStyle(fontSize: 16),
                    decoration: const InputDecoration(
                      hintText: "Select video file",
                      hintStyle: TextStyle(fontSize: 16),
                      border: UnderlineInputBorder(),
                    ),
                    controller: _videoFileController,
                    onTap: () {
                      _selectVideoFile(context);
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
          child: const Text("Add"),
          onPressed: () {
            addVideo(context);
          },
        ),
      ],
    );
  }

  Future<void> _selectVideoFolder() async {
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
      _videoFolderController.text = directoryPath;

      if (!Directory(directoryPath).existsSync()) {
        Fluttertoast.showToast(
          msg: folderNotFound,
          toastLength: Toast.LENGTH_SHORT,
        );
      }

      _videoFileSystemEntityList.clear();
      _videoFileController.clear();
      _selectedVideoFilePath = null;

      Directory(directoryPath).listSync().forEach((element) {
        if (_videoFormats.contains(element.path
            .substring(element.path.lastIndexOf('.') + 1)
            .toLowerCase())) {
          _videoFileSystemEntityList.add(element);
        }
      });

      // TODO: 11/10/2021 Sort [_videoFileSystemEntityList]
    } else if (_videoFolderController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: noFolderSelected,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  Future<void> _selectVideoFile(BuildContext context) async {
    if (_videoFolderController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: videoFolderNotSelected,
        toastLength: Toast.LENGTH_SHORT,
      );
      return;
    }

    if (_videoFileSystemEntityList.isEmpty) {
      Fluttertoast.showToast(
        msg: noVideosFound,
        toastLength: Toast.LENGTH_SHORT,
      );
      return;
    }

    // FIXME: 11/10/2021 Keyboard getting automatically opened
    // Caused by [autofocus: true] in [TranslatedTextBox]
    FileSystemEntity? selectedFileSystemEntity =
        await showFileSelectorFullScreenDialog(
      context: context,
      title: "Select video file",
      fileList: _videoFileSystemEntityList,
    );

    if (selectedFileSystemEntity != null) {
      _videoFileController.text = basename(selectedFileSystemEntity.path);
      _selectedVideoFilePath = selectedFileSystemEntity.path;
    } else if (_videoFileController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: noFileSelected,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  Future<void> addVideo(BuildContext context) async {
    if (_videoFolderController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: videoFolderNotSelected,
        toastLength: Toast.LENGTH_SHORT,
      );
      return;
    }

    if (_selectedVideoFilePath == null) {
      Fluttertoast.showToast(
        msg: videoFileNotSelected,
        toastLength: Toast.LENGTH_SHORT,
      );
      return;
    }

    // Navigating back with value
    Navigator.pop(context, _selectedVideoFilePath);
  }
}
