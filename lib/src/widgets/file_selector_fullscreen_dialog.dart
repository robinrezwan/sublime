import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sublime/src/utilities/custom_icons.dart';
import 'package:sublime/src/utilities/extensions/date_time_extension.dart';
import 'package:sublime/src/widgets/custom_icon_button.dart';

class _FileSelectorFullScreenDialog extends StatelessWidget {
  const _FileSelectorFullScreenDialog({
    required this.title,
    required this.fileList,
  });

  final String title;
  final List<FileSystemEntity> fileList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: CustomIconButton(
          icon: const Icon(CustomIcons.close),
          tooltip: "Close",
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 20),
        ),
      ),
      body: ListView.builder(
        itemCount: fileList.length,
        itemBuilder: (context, index) {
          final String fileName = basename(fileList[index].path);
          final FileStat fileStat = fileList[index].statSync();
          final String fileType =
              fileName.substring(fileName.lastIndexOf('.') + 1).toUpperCase() +
                  " video";

          return ListTile(
            leading: Container(
              padding: const EdgeInsets.only(left: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    CustomIcons.movieFilled,
                    color: Color(0xFFDB4437),
                  ),
                ],
              ),
            ),
            title: Text(fileName),
            subtitle: Row(
              children: [
                Expanded(
                  child: Text(
                    _formatDateTime(fileStat.modified),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                Expanded(
                  child: Text(
                    _formatFileSize(fileStat.size),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                Expanded(
                  child: Text(
                    fileType,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            onTap: () {
              Navigator.pop(context, fileList[index]);
            },
          );
        },
      ),
    );
  }
}

String _formatDateTime(DateTime dateTime) {
  String dateTimeString = "";

  if (dateTime.isSameDate(DateTime.now())) {
    dateTimeString += DateFormat('h:mm a').format(dateTime);
  } else if (dateTime.isSameYear(DateTime.now())) {
    dateTimeString += DateFormat('MMM, d').format(dateTime);
  } else {
    dateTimeString += DateFormat('MMM d, y').format(dateTime);
  }

  return dateTimeString;
}

String _formatFileSize(int fileSize) {
  String fileSizeString;

  double b = fileSize.toDouble();
  double kb = 0;
  double mb = 0;
  double gb = 0;

  fileSizeString = b.toStringAsFixed(2) + " B";

  if (b >= 900) {
    kb = fileSize / 1000;
    fileSizeString = kb.toStringAsFixed(2) + " kB";
  }

  if (kb >= 900) {
    mb = kb / 1000;
    fileSizeString = mb.toStringAsFixed(2) + " MB";
  }

  if (mb >= 900) {
    gb = mb / 1000;
    fileSizeString = gb.toStringAsFixed(2) + " GB";
  }

  fileSizeString.replaceAll(".00", "");

  return fileSizeString;
}

Future<FileSystemEntity?> showFileSelectorFullScreenDialog({
  required BuildContext context,
  required String title,
  required List<FileSystemEntity> fileList,
}) {
  return Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => _FileSelectorFullScreenDialog(
        title: title,
        fileList: fileList,
      ),
    ),
  );
}
