import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:sublime/src/database/database_manager.dart';
import 'package:sublime/src/providers/preference_provider.dart';
import 'package:sublime/src/providers/subtitle_provider.dart';
import 'package:sublime/src/utilities/constants.dart';
import 'package:sublime/src/utilities/custom_icons.dart';
import 'package:sublime/src/utilities/languages.dart';
import 'package:sublime/src/widgets/backup_dialog.dart';
import 'package:sublime/src/widgets/custom_alert_dialog.dart';
import 'package:sublime/src/widgets/custom_icon_button.dart';
import 'package:sublime/src/widgets/custom_radio_list_tile.dart';
import 'package:sublime/src/widgets/restore_dialog.dart';
import 'package:sublime/src/widgets/single_choice_full_screen_dialog.dart';

import '../providers/theme_provider.dart';

// Logger
final Logger log = Logger();

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: CustomIconButton(
          icon: const Icon(CustomIcons.arrowLeft),
          tooltip: "Back",
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Settings"),
        actions: [
          CustomIconButton(
            icon: const Icon(CustomIcons.more),
            tooltip: "More options",
            onPressed: () {
              // TODO: 11/1/2021 Set settings to default
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSectionTitle("User interface"),
            ListTile(
              leading: _buildListTileIcon(CustomIcons.theme),
              title: const Text("Theme"),
              subtitle: const Text(
                "App theme preference",
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Consumer<PreferenceProvider>(
                builder: (context, prefProvider, child) {
                  String themeLabel = "";

                  switch (prefProvider.getThemePreference()) {
                    case AppTheme.light:
                      themeLabel = "Light";
                      break;
                    case AppTheme.dark:
                      themeLabel = "Dark";
                      break;
                    case AppTheme.system:
                      themeLabel = "System default";
                      break;
                  }

                  return Text(themeLabel);
                },
              ),
              onTap: () {
                _showChooseThemeDialog();
              },
            ),
            const Divider(),
            _buildSectionTitle("Subtitle options"),
            ListTile(
              leading: _buildListTileIcon(CustomIcons.play),
              title: const Text("Preview subtitle"),
              subtitle: const Text(
                "Subtitle shown in preview",
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Consumer<PreferenceProvider>(
                builder: (context, prefProvider, child) {
                  String? previewSubtitleLabel = "";

                  switch (prefProvider.getPreviewSubtitlePreference()) {
                    case PreviewSubtitle.original:
                      previewSubtitleLabel = "Original";
                      break;
                    case PreviewSubtitle.translated:
                      previewSubtitleLabel = "Translated";
                      break;
                  }

                  return Text(previewSubtitleLabel);
                },
              ),
              onTap: () {
                _showPreviewSubtitleDialog();
              },
            ),
            ListTile(
              leading: _buildListTileIcon(CustomIcons.googleTranslate),
              title: const Text("Translation language"),
              subtitle: const Text(
                "Google Translate language",
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Consumer<PreferenceProvider>(
                builder: (context, prefProvider, child) {
                  return Text(prefProvider.getTranslationLanguagePreference());
                },
              ),
              onTap: () {
                _showChooseTranslationLanguageDialog();
              },
            ),
            const Divider(),
            _buildSectionTitle("Backup & restore"),
            ListTile(
              leading: _buildListTileIcon(CustomIcons.backupRestore),
              title: const Text("Backup or restore"),
              subtitle: const Text(
                "Backup or restore subtitles data",
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                _showBackupRestoreDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.all(16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildListTileIcon(IconData iconData) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          iconData,
          color: Theme.of(context).iconTheme.color,
        ),
      ],
    );
  }

  Future<void> _showChooseThemeDialog() async {
    final PreferenceProvider prefProvider =
        Provider.of<PreferenceProvider>(context, listen: false);

    // Getting current theme preference
    AppTheme? selectedValue = prefProvider.getThemePreference();

    selectedValue = await showDialog(
        context: context,
        builder: (context) {
          return CustomAlertDialog(
            title: const Text("Choose theme"),
            contentPadding: const EdgeInsets.only(top: 8),
            actionsPadding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
            content: Wrap(
              children: [
                CustomRadioListTile(
                  value: AppTheme.light,
                  groupValue: selectedValue,
                  title: const Text("Light"),
                  onTap: () {
                    Navigator.pop(context, AppTheme.light);
                  },
                ),
                CustomRadioListTile(
                  value: AppTheme.dark,
                  groupValue: selectedValue,
                  title: const Text("Dark"),
                  onTap: () {
                    Navigator.pop(context, AppTheme.dark);
                  },
                ),
                CustomRadioListTile(
                  value: AppTheme.system,
                  groupValue: selectedValue,
                  title: const Text("System default"),
                  onTap: () {
                    Navigator.pop(context, AppTheme.system);
                  },
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
            ],
          );
        });

    if (selectedValue != null) {
      // Saving selected theme preference
      prefProvider.setThemePreference(selectedValue);

      // Setting selected theme
      Provider.of<ThemeProvider>(context, listen: false)
          .setTheme(selectedValue);
    }
  }

  Future<void> _showPreviewSubtitleDialog() async {
    final PreferenceProvider prefProvider =
        Provider.of<PreferenceProvider>(context, listen: false);

    // Getting current preview subtitle preference
    PreviewSubtitle? selectedValue =
        prefProvider.getPreviewSubtitlePreference();

    selectedValue = await showDialog(
        context: context,
        builder: (context) {
          return CustomAlertDialog(
            title: const Text("Preview subtitle"),
            contentPadding: const EdgeInsets.only(top: 8),
            actionsPadding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
            content: Wrap(
              children: [
                CustomRadioListTile(
                  title: const Text("Original"),
                  value: PreviewSubtitle.original,
                  groupValue: selectedValue,
                  onTap: () {
                    Navigator.pop(context, PreviewSubtitle.original);
                  },
                ),
                CustomRadioListTile(
                  title: const Text("Translated"),
                  value: PreviewSubtitle.translated,
                  groupValue: selectedValue,
                  onTap: () {
                    Navigator.pop(context, PreviewSubtitle.translated);
                  },
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
            ],
          );
        });

    if (selectedValue != null) {
      // Saving selected preview subtitle preference
      prefProvider.setPreviewSubtitlePreference(selectedValue);
    }
  }

  Future<void> _showChooseTranslationLanguageDialog() async {
    final PreferenceProvider prefProvider =
        Provider.of<PreferenceProvider>(context, listen: false);

    // Getting current translation language preference
    String? selectedValue = prefProvider.getTranslationLanguagePreference();

    selectedValue = await showSingleChoiceFullScreenDialog(
      context: context,
      itemList: Languages.langs.values.toList(),
      selectedItem: selectedValue,
    );

    if (selectedValue != null) {
      // Saving selected translation language preference
      prefProvider.setTranslationLanguagePreference(selectedValue);
    }
  }

  Future<void> _showBackupRestoreDialog() async {
    await showDialog(
        context: context,
        builder: (context) {
          return CustomAlertDialog(
            title: const Text("Backup or restore"),
            contentPadding: const EdgeInsets.only(top: 8),
            actionsPadding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
            content: Wrap(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      CustomIcons.backup,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ),
                  title: const Text("Backup"),
                  onTap: () {
                    Navigator.pop(context);

                    _showBackupDialog();
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      CustomIcons.restore,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ),
                  title: const Text("Restore"),
                  onTap: () {
                    Navigator.pop(context);

                    _showRestoreDialog();
                  },
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
            ],
          );
        });
  }

  Future<void> _showBackupDialog() async {
    final List<dynamic>? backupInfo = await showDialog(
      context: context,
      builder: (context) => const BackupDialog(),
    );

    if (backupInfo == null) {
      return;
    }

    final String backupFolderPath = backupInfo.first;
    final String backupName = backupInfo.last;

    try {
      // Getting backup data from database
      String backupString = await DatabaseManager().createBackup();

      // Saving backup in file
      final String backupFilePath =
          path.join(backupFolderPath, backupName + '.sb');
      final File subtitleFile = File(backupFilePath);

      subtitleFile.writeAsStringSync(backupString, encoding: utf8);

      Fluttertoast.showToast(
        msg: backupCreationSuccessful,
        toastLength: Toast.LENGTH_SHORT,
      );
    } catch (exception) {
      Fluttertoast.showToast(
        msg: backupCreationFailed,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  Future<void> _showRestoreDialog() async {
    final String? restoreData = await showDialog(
      context: context,
      builder: (context) => const RestoreDialog(),
    );

    if (restoreData == null) {
      return;
    }

    final String backupFilePath = restoreData;

    // Reading backup file
    final File backupFile = File(backupFilePath);
    String? backupString;

    if (!backupFile.existsSync()) {
      Fluttertoast.showToast(
        msg: fileNotFound,
        toastLength: Toast.LENGTH_SHORT,
      );
      return;
    }

    try {
      backupString = backupFile.readAsStringSync(encoding: utf8);
    } catch (exception) {
      try {
        backupString = backupFile.readAsStringSync(encoding: latin1);
      } catch (exception) {
        try {
          backupString = backupFile.readAsStringSync(encoding: ascii);
        } catch (exception) {
          Fluttertoast.showToast(
            msg: unsupportedTextEncoding,
            toastLength: Toast.LENGTH_SHORT,
          );
          return;
        }
      }
    }

    try {
      // Saving backup data to database
      await DatabaseManager().restoreBackup(backupString);

      // Reloading user interface
      Provider.of<SubtitleProvider>(context, listen: false).reload();

      Fluttertoast.showToast(
        msg: backupRestoringSuccessful,
        toastLength: Toast.LENGTH_SHORT,
      );
    } catch (exception) {
      Fluttertoast.showToast(
        msg: backupRestoringFailed,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }
}
