import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:sublime/src/models/sequence.dart';
import 'package:sublime/src/models/subtitle.dart';
import 'package:sublime/src/pages/subtitle_page.dart';
import 'package:sublime/src/providers/preference_provider.dart';
import 'package:sublime/src/providers/subtitle_provider.dart';
import 'package:sublime/src/utilities/constants.dart';
import 'package:sublime/src/utilities/custom_icons.dart';
import 'package:sublime/src/widgets/app_icon_title.dart';
import 'package:sublime/src/widgets/custom_alert_dialog.dart';
import 'package:sublime/src/widgets/custom_icon_button.dart';
import 'package:sublime/src/widgets/custom_popup_menu_button.dart';
import 'package:sublime/src/widgets/custom_radio_list_tile.dart';
import 'package:sublime/src/widgets/import_subtitle_dialog.dart';
import 'package:sublime/src/widgets/navigation_drawer.dart';
import 'package:sublime/src/widgets/page_background.dart';
import 'package:sublime/src/widgets/search_screen.dart';
import 'package:sublime/src/widgets/subtitle_list_tile.dart';

// Logger
final Logger log = Logger();

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Subtitle> subtitleList = [];

  double _turns = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (context) {
            return CustomIconButton(
              icon: const Icon(CustomIcons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: "Menu",
            );
          },
        ),
        title: const AppIconTitle(),
        centerTitle: true,
        actions: [
          CustomIconButton(
            icon: const Icon(CustomIcons.search),
            tooltip: "Search",
            onPressed: () {
              showSearch(
                context: context,
                delegate: SearchScreen<Subtitle>(
                  searchLabel: 'Search subtitle',
                  suggestionsView: const PageBackground(
                    imageWidth: 130,
                    assetName: 'lib/assets/images/search_background.svg',
                    isSvgImage: true,
                    title: "Search subtitle by name...",
                  ),
                  failureView: const PageBackground(
                    imageWidth: 120,
                    imageMargin: EdgeInsets.all(8),
                    assetName: 'lib/assets/images/not_found_background.svg',
                    isSvgImage: true,
                    title: "No subtitle found...",
                  ),
                  items: subtitleList,
                  filter: (subtitle) => [subtitle.subtitleName],
                  itemBuilder: (subtitle) {
                    return SubtitleListTile(
                      subtitle: subtitle,
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SubtitlePage()),
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
          CustomPopupMenuButton(
            icon: const Icon(CustomIcons.more),
            tooltip: "More options",
            itemBuilder: (context) {
              return [
                const PopupMenuItem(
                  value: 0,
                  child: Text("Sort by"),
                ),
              ];
            },
            onSelected: (value) {
              switch (value) {
                case 0:
                  _showSortByDialog();
                  break;
              }
            },
          ),
        ],
      ),
      drawer: const NavigationDrawer(),
      body: StreamBuilder(
        stream:
            Provider.of<SubtitleProvider>(context).getAllSubtitles().asStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              subtitleList = snapshot.data as List<Subtitle>;

              if (subtitleList.isNotEmpty) {
                return Scrollbar(
                  radius: const Radius.circular(2),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 78),
                    itemCount: subtitleList.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          SubtitleListTile(
                            subtitle: subtitleList[index],
                            onTap: () {
                              // Setting current subtitle
                              Provider.of<SubtitleProvider>(context,
                                      listen: false)
                                  .setCurrentSubtitle(subtitleList[index]);

                              // Navigating to subtitle page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SubtitlePage()),
                              );
                            },
                          ),
                          if (index < subtitleList.length - 1) const Divider(),
                        ],
                      );
                    },
                  ),
                );
              }
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 78),
              child: const PageBackground(
                  imageWidth: 240,
                  imageMargin: EdgeInsets.all(8),
                  assetName: 'lib/assets/images/home_background.png',
                  isSvgImage: false,
                  title: "No subtitles added!",
                  subtitle: "Add one and get started!"),
            );
          }

          return Container(
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: StatefulBuilder(
        builder: (context, setFABState) {
          return FloatingActionButton(
            child: AnimatedRotation(
              turns: _turns,
              duration: const Duration(milliseconds: 500),
              child: const Icon(
                CustomIcons.add,
                size: 26,
              ),
            ),
            onPressed: () async {
              // Clockwise rotation
              setFABState(() => _turns += 0.25);

              await _showImportSubtitleDialog(context);

              // Anticlockwise rotation
              setFABState(() => _turns -= 0.25);
            },
          );
        },
      ),
    );
  }

  Future<void> _showSortByDialog() async {
    final PreferenceProvider prefProvider =
        Provider.of<PreferenceProvider>(context, listen: false);

    SubtitlesSort? selectedValue = prefProvider.getSubtitlesSortPreference();
    bool showFavoritesFirst =
        prefProvider.getSubtitlesShowFavoritesFirstPreference();

    await showDialog(
        context: context,
        builder: (context) {
          return CustomAlertDialog(
            title: const Text("Sort by"),
            contentPadding: const EdgeInsets.only(top: 8),
            content: StatefulBuilder(
              builder: (context, setSortByState) {
                return Wrap(
                  children: [
                    CustomRadioListTile(
                      title: const Text("Last modified"),
                      value: SubtitlesSort.modified,
                      groupValue: selectedValue,
                      onTap: () {
                        setSortByState(() {
                          selectedValue = SubtitlesSort.modified;
                        });
                      },
                    ),
                    CustomRadioListTile(
                      title: const Text("Last created"),
                      value: SubtitlesSort.created,
                      groupValue: selectedValue,
                      onTap: () {
                        setSortByState(() {
                          selectedValue = SubtitlesSort.created;
                        });
                      },
                    ),
                    CustomRadioListTile(
                      title: const Text("Alphabetically"),
                      value: SubtitlesSort.alphabetically,
                      groupValue: selectedValue,
                      onTap: () {
                        setSortByState(() {
                          selectedValue = SubtitlesSort.alphabetically;
                        });
                      },
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      child: const Divider(),
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 16, top: 4),
                      child: Row(
                        children: [
                          Checkbox(
                            visualDensity: VisualDensity.compact,
                            value: showFavoritesFirst,
                            onChanged: (value) {
                              setSortByState(() {
                                showFavoritesFirst = value!;
                              });
                            },
                          ),
                          const SizedBox(width: 16),
                          const Text("Show favorites first"),
                        ],
                      ),
                    ),
                  ],
                );
              },
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
                  if (selectedValue != null) {
                    // Saving selected sort preference
                    prefProvider.setSubtitlesSortPreference(selectedValue!);
                    prefProvider.setSubtitlesShowFavoritesFirstPreference(
                        showFavoritesFirst);

                    // Sorting subtitles by selected sort preference
                    final SubtitleProvider subtitleProvider =
                        Provider.of<SubtitleProvider>(context, listen: false);

                    subtitleProvider.setSortPreference(selectedValue!);
                    subtitleProvider.setShowFavoritesFirst(showFavoritesFirst);
                  }

                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  Future<void> _showImportSubtitleDialog(BuildContext context) async {
    final List<String>? subtitleData = await showDialog(
      context: context,
      builder: (context) => const ImportSubtitleDialog(),
    );

    if (subtitleData == null) {
      return;
    }

    final String subtitleFilePath = subtitleData.first;
    final String subtitleName = subtitleData.last;

    try {
      // Reading subtitle file
      final File subtitleFile = File(subtitleFilePath);
      String? subtitleString;

      if (!subtitleFile.existsSync()) {
        Fluttertoast.showToast(
          msg: fileNotFound,
          toastLength: Toast.LENGTH_SHORT,
        );
        return;
      }

      try {
        subtitleString = subtitleFile.readAsStringSync(encoding: utf8);
      } catch (exception) {
        try {
          subtitleString = subtitleFile.readAsStringSync(encoding: latin1);
        } catch (exception) {
          try {
            subtitleString = subtitleFile.readAsStringSync(encoding: ascii);
          } catch (exception) {
            Fluttertoast.showToast(
              msg: unsupportedTextEncoding,
              toastLength: Toast.LENGTH_SHORT,
            );
            return;
          }
        }
      }

      Subtitle? subtitle;

      try {
        // Changing line endings
        subtitleString = subtitleString.trim();
        subtitleString = subtitleString.replaceAll('\r\n', '\n');
        subtitleString = subtitleString.replaceAll('\r', '\n');

        // Splitting at empty lines
        List<String> sequenceStringList = subtitleString.split('\n\n');
        sequenceStringList.removeWhere((element) => element.isEmpty);

        // Creating Sequence list
        final List<Sequence> sequenceList = sequenceStringList
            .map((element) => Sequence.fromString(sequenceString: element))
            .toList();

        // Creating Subtitle object
        subtitle =
            Subtitle(subtitleName: subtitleName, sequenceList: sequenceList);
      } catch (exception) {
        Fluttertoast.showToast(
          msg: subtitleParsingFailed,
          toastLength: Toast.LENGTH_SHORT,
        );
        return;
      }

      final SubtitleProvider subtitleProvider =
          Provider.of<SubtitleProvider>(context, listen: false);

      // Adding subtitle to database
      final int subtitleId = await subtitleProvider.addSubtitle(subtitle);

      Fluttertoast.showToast(
        msg: subtitleImported,
        toastLength: Toast.LENGTH_SHORT,
      );

      // Getting current subtitle from database
      final Subtitle? addedSubtitle =
          await subtitleProvider.getSubtitle(subtitleId);

      if (addedSubtitle != null) {
        // Setting current subtitle
        subtitleProvider.setCurrentSubtitle(addedSubtitle);

        // Navigating to subtitle page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SubtitlePage()),
        );
      } else {
        Fluttertoast.showToast(
          msg: subtitleLoadingFailed,
          toastLength: Toast.LENGTH_SHORT,
        );
      }
    } catch (exception) {
      Fluttertoast.showToast(
        msg: subtitleImportingFailed,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }
}
