import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sublime/src/models/sequence.dart';
import 'package:sublime/src/models/subtitle.dart';
import 'package:sublime/src/providers/sequence_provider.dart';
import 'package:sublime/src/providers/subtitle_provider.dart';
import 'package:sublime/src/themes/custom_theme_data.dart';
import 'package:sublime/src/utilities/constants.dart';
import 'package:sublime/src/utilities/custom_icons.dart';
import 'package:sublime/src/utilities/undo_redo_manager.dart';
import 'package:sublime/src/widgets/custom_icon_button.dart';
import 'package:sublime/src/widgets/original_text_box.dart';
import 'package:sublime/src/widgets/previous_next_buttons.dart';
import 'package:sublime/src/widgets/rounded_tab_indicator.dart';
import 'package:sublime/src/widgets/subtitle_page_options.dart';
import 'package:sublime/src/widgets/subtitle_page_title.dart';
import 'package:sublime/src/widgets/translated_text_box.dart';
import 'package:sublime/src/widgets/translated_text_box_toolbar.dart';

// Logger
final Logger log = Logger();

class SubtitlePage extends StatefulWidget {
  const SubtitlePage({Key? key}) : super(key: key);

  @override
  _SubtitlePageState createState() => _SubtitlePageState();
}

class _SubtitlePageState extends State<SubtitlePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final TextEditingController _originalController;
  late final TextEditingController _translatedController;
  late final RoundedLoadingButtonController _saveController;
  late final ItemScrollController _itemScrollController;

  final UndoRedoManager _undoRedoManager = UndoRedoManager();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _originalController = TextEditingController();
    _translatedController = TextEditingController();
    _saveController = RoundedLoadingButtonController();
    _itemScrollController = ItemScrollController();

    // Show or hide keyboard on tab change
    _tabController.addListener(() async {
      if (_tabController.indexIsChanging) {
        if (_tabController.index == 0) {
          // Showing keyboard
          await SystemChannels.textInput.invokeMethod('TextInput.show');
        } else {
          // Hiding keyboard
          await SystemChannels.textInput.invokeMethod('TextInput.hide');
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _originalController.dispose();
    _translatedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Subtitle subtitle =
        Provider.of<SubtitleProvider>(context, listen: false)
            .getCurrentSubtitle();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        leading: CustomIconButton(
          icon: const Icon(CustomIcons.home),
          tooltip: "Home",
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const SubtitlePageTitle(),
        actions: [
          SubtitlePageOptions(
            context: context,
            subtitle: subtitle,
            tabController: _tabController,
            itemScrollController: _itemScrollController,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Theme.of(context).colorScheme.onUnselectedTab,
          isScrollable: true,
          indicator: RoundedTabIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
          tabs: const [
            Tab(text: "Translate"),
            Tab(text: "Subtitle"),
          ],
        ),
      ),
      body: FutureBuilder(
        future: Provider.of<SequenceProvider>(context, listen: false)
            .getAllSequences(subtitle.subtitleId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              subtitle.sequenceList = snapshot.data as List<Sequence>;

              if (subtitle.sequenceList != null &&
                  subtitle.sequenceList!.isNotEmpty) {
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTranslateView(subtitle),
                    _buildSubtitleView(subtitle),
                  ],
                );
              }
            }
          }

          return Container(
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Widget _buildTranslateView(Subtitle subtitle) {
    Provider.of<SequenceProvider>(context, listen: false).setCurrentSequence(
        subtitle.sequenceList![subtitle.currentSequenceId - 1]);

    return SingleChildScrollView(
      child: Column(
        children: [
          Selector<SequenceProvider, Sequence>(
              selector: (context, seqProvider) =>
                  seqProvider.getCurrentSequence(),
              builder: (context, currentSequence, child) {
                return OriginalTextBox(
                  sequence: currentSequence,
                  controller: _originalController,
                );
              }),
          Selector<SequenceProvider, Sequence>(
              selector: (context, seqProvider) =>
                  seqProvider.getCurrentSequence(),
              builder: (context, currentSequence, child) {
                final SequenceProvider seqProvider =
                    Provider.of<SequenceProvider>(context, listen: false);

                // Setting initial value to text field
                _translatedController.clearComposing();
                _translatedController.value = TextEditingValue(
                  text: currentSequence.translatedText,
                  selection: TextSelection.collapsed(
                      offset: currentSequence.translatedText.length),
                );

                // Storing edit history
                _undoRedoManager.insert(_translatedController);

                return TranslatedTextBox(
                  sequence: currentSequence,
                  controller: _translatedController,
                  onChanged: (value) {
                    // Storing edit history
                    _undoRedoManager.insert(_translatedController);

                    seqProvider
                        .setIsChanged(value != currentSequence.translatedText);
                  },
                  toolbar: TranslatedTextBoxToolbar(
                    currentSequence: currentSequence,
                    originalController: _originalController,
                    translatedController: _translatedController,
                    saveController: _saveController,
                    undoRedoManager: _undoRedoManager,
                  ),
                );
              }),
          PreviousNextButtons(
            onPressedPrevious: () {
              if (subtitle.currentSequenceId > 1) {
                // Clearing undo redo history
                _undoRedoManager.clear();

                final SequenceProvider seqProvider =
                    Provider.of<SequenceProvider>(context, listen: false);

                // Saving as draft
                _saveSequenceAsDraft(context, seqProvider);

                // Going to previous sequence
                subtitle.currentSequenceId -= 1;

                seqProvider.setCurrentSequence(
                    subtitle.sequenceList![subtitle.currentSequenceId - 1]);
              } else {
                Fluttertoast.showToast(
                  msg: reachedTheBeginning,
                  toastLength: Toast.LENGTH_SHORT,
                );
              }
            },
            onPressedNext: () {
              if (subtitle.currentSequenceId <
                  subtitle.sequenceList!.last.sequenceId!) {
                // Clearing undo redo history
                _undoRedoManager.clear();

                final SequenceProvider seqProvider =
                    Provider.of<SequenceProvider>(context, listen: false);

                // Saving as draft
                _saveSequenceAsDraft(context, seqProvider);

                // Going to next sequence
                subtitle.currentSequenceId += 1;

                seqProvider.setCurrentSequence(
                    subtitle.sequenceList![subtitle.currentSequenceId - 1]);
              } else {
                Fluttertoast.showToast(
                  msg: reachedTheEnd,
                  toastLength: Toast.LENGTH_SHORT,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _saveSequenceAsDraft(
      BuildContext context, SequenceProvider seqProvider) async {
    if (seqProvider.getIsChanged()) {
      Sequence currentSequence = seqProvider.getCurrentSequence();

      currentSequence.translatedText = _translatedController.text;
      currentSequence.isCompleted = false;

      try {
        await seqProvider.updateSequence(currentSequence);

        // Updating metadata
        Provider.of<SubtitleProvider>(context, listen: false)
            .updateCurrentSubtitleMetadata(currentSequence.isCompleted);
      } catch (exception) {
        Fluttertoast.showToast(
          msg: savingFailed,
          toastLength: Toast.LENGTH_SHORT,
        );
      }
    }
  }

  Widget _buildSubtitleView(Subtitle subtitle) {
    // TODO: 11/1/2021 Add translated text on the tiles
    final List<Sequence> sequenceList = subtitle.sequenceList!;

    return Selector<SequenceProvider, Sequence>(
        selector: (context, seqProvider) => seqProvider.getCurrentSequence(),
        builder: (context, currentSequence, child) {
          return Scrollbar(
            thickness: 4,
            radius: const Radius.circular(2),
            child: ScrollablePositionedList.builder(
                itemScrollController: _itemScrollController,
                initialScrollIndex: currentSequence.sequenceId! - 1,
                itemCount: sequenceList.length,
                itemBuilder: (context, index) {
                  final Sequence sequence = sequenceList[index];

                  return Column(
                    children: [
                      ListTile(
                        leading: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 6,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(sequence.sequenceNo.toString()),
                                if (sequence.translatedText.isNotEmpty)
                                  Icon(
                                    CustomIcons.check,
                                    size: 18,
                                    color: sequence.isCompleted
                                        ? Theme.of(context).colorScheme.green
                                        : Theme.of(context).colorScheme.yellow,
                                  ),
                                if (currentSequence == sequence)
                                  Icon(
                                    CustomIcons.create,
                                    size: 16,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(sequence.startTime),
                            Text(sequence.endTime),
                          ],
                        ),
                        subtitle: Container(
                          height: 80,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            sequence.originalText,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        onTap: () {
                          // Clearing translated text box
                          _translatedController.clear();

                          // Clearing undo redo history
                          _undoRedoManager.clear();

                          // Setting current sequence
                          subtitle.currentSequenceId = index + 1;
                          Provider.of<SequenceProvider>(context, listen: false)
                              .setCurrentSequence(sequenceList[index]);

                          // Moving to translate tab
                          _tabController.animateTo(0);
                        },
                      ),
                      if (index < sequenceList.length - 1) const Divider(),
                    ],
                  );
                }),
          );
        });
  }
}
