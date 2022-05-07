import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:sublime/src/models/sequence.dart';
import 'package:sublime/src/models/subtitle.dart' as sub;
import 'package:sublime/src/providers/preference_provider.dart';
import 'package:sublime/src/providers/sequence_provider.dart';
import 'package:sublime/src/providers/subtitle_provider.dart';
import 'package:sublime/src/themes/custom_theme_data.dart';
import 'package:sublime/src/utilities/constants.dart';
import 'package:sublime/src/utilities/custom_icons.dart';
import 'package:sublime/src/widgets/app_icon_title.dart';
import 'package:sublime/src/widgets/custom_icon_button.dart';
import 'package:sublime/src/widgets/custom_popup_menu_button.dart';
import 'package:video_player/video_player.dart';

import 'add_video_dialog.dart';

// Logger
final Logger log = Logger();

class VideoPlayerDialog extends StatefulWidget {
  const VideoPlayerDialog({
    Key? key,
    required this.subtitle,
  }) : super(key: key);

  final sub.Subtitle subtitle;

  @override
  _VideoPlayerDialogState createState() => _VideoPlayerDialogState();
}

class _VideoPlayerDialogState extends State<VideoPlayerDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _playPauseController;

  ChewieController? _chewieController;
  bool _noVideoAdded = false;
  bool _noVideoFound = false;

  @override
  void initState() {
    super.initState();
    _playPauseController =
        AnimationController(duration: Duration.zero, vsync: this);

    _initializePlayer();
  }

  @override
  void dispose() {
    _playPauseController.dispose();
    _chewieController?.videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(8),
      titlePadding: const EdgeInsets.all(0),
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      actionsPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      title: Row(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: const AppIconTitle(),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 8, right: 8),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .objectBackground
                        .withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                ),
                CustomIconButton(
                  icon: const Icon(CustomIcons.close),
                  tooltip: "Close",
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  width: constraints.maxWidth,
                  height: constraints.maxWidth * (9 / 16),
                  color: _noVideoAdded || _noVideoFound
                      ? Colors.transparent
                      : Colors.black,
                  child: _buildVideoPlayer(),
                );
              },
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
                  CustomPopupMenuButton(
                    icon: const Icon(CustomIcons.more),
                    tooltip: "More options",
                    itemBuilder: (context) {
                      return <PopupMenuEntry>[
                        _noVideoAdded
                            ? const PopupMenuItem(
                                value: 0,
                                child: Text("Add video"),
                              )
                            : const PopupMenuItem(
                                value: 1,
                                child: Text("Remove video"),
                              ),
                      ];
                    },
                    onSelected: (value) {
                      switch (value) {
                        case 0:
                          // Navigating back
                          Navigator.pop(context);

                          // Showing add video dialog
                          _showAddVideoDialog();
                          break;
                        case 1:
                          _removeVideo();
                          break;
                      }
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconButton(
                        icon: const Icon(CustomIcons.replay5),
                        onPressed: () async {
                          if (_chewieController != null) {
                            Duration? position = await _chewieController!
                                .videoPlayerController.position;
                            if (position != null) {
                              _chewieController!.seekTo(
                                  position - const Duration(seconds: 5));
                            }
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: ElevatedButton(
                          child: const Icon(Icons.stop),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(0),
                            primary: Theme.of(context).colorScheme.red,
                          ),
                          onPressed: () {
                            if (_chewieController != null) {
                              _chewieController!.pause();
                              _chewieController!.seekTo(Duration.zero);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: ElevatedButton(
                          child: AnimatedIcon(
                            icon: AnimatedIcons.play_pause,
                            progress: _playPauseController,
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(0),
                            primary: Theme.of(context).colorScheme.green,
                          ),
                          onPressed: () {
                            if (_chewieController != null) {
                              if (_chewieController!.isPlaying) {
                                _playPauseController.reverse();
                                _chewieController!.pause();
                              } else {
                                _playPauseController.forward();
                                _chewieController!.play();
                              }
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: ElevatedButton(
                          child: const Icon(
                            CustomIcons.clapperBoardOpen,
                            size: 22,
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(0),
                            primary: const Color(0xFF414141),
                          ),
                          onPressed: () {
                            if (_chewieController != null) {
                              _chewieController!.seekTo(_getStartTime());
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      CustomIconButton(
                        icon: const Icon(CustomIcons.forward5),
                        onPressed: () async {
                          if (_chewieController != null) {
                            Duration? position = await _chewieController!
                                .videoPlayerController.position;
                            if (position != null) {
                              _chewieController!.seekTo(
                                  position + const Duration(seconds: 5));
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_chewieController != null) {
      return Chewie(
        controller: _chewieController!,
      );
    } else if (_noVideoAdded) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconButton(
            icon: Icon(
              CustomIcons.addCircleFilled,
              size: 32,
              color: Theme.of(context).colorScheme.green,
            ),
            tooltip: "Add video",
            onPressed: () async {
              // Navigating back
              Navigator.pop(context);

              // Showing add video dialog
              _showAddVideoDialog();
            },
          ),
          const SizedBox(height: 4),
          const Text(
            "No video added!",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text("Add a video!"),
        ],
      );
    } else if (_noVideoFound) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconButton(
            icon: Icon(
              CustomIcons.removeCircleFilled,
              size: 32,
              color: Theme.of(context).colorScheme.red,
            ),
            tooltip: "Remove video",
            onPressed: () {
              _removeVideo();
            },
          ),
          const SizedBox(height: 4),
          const Text(
            "Video not found!",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text("Remove it and add another video!"),
        ],
      );
    } else {
      return Container(
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }
  }

  Future<void> _initializePlayer() async {
    if (widget.subtitle.videoPath.isEmpty) {
      setState(() => _noVideoAdded = true);
      return;
    }

    // Getting video file
    File videoFile = File(widget.subtitle.videoPath);

    if (!videoFile.existsSync()) {
      setState(() => _noVideoFound = true);
      return;
    }

    // Setting play pause button animation status
    _playPauseController.forward();
    _playPauseController.duration = const Duration(milliseconds: 500);

    // Creating video player controller from video file
    VideoPlayerController videoPlayerController =
        VideoPlayerController.file(videoFile);

    try {
      await videoPlayerController.initialize();

      // Creating chewie controller
      _chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        startAt: _getStartTime(),
        autoPlay: true,
        allowPlaybackSpeedChanging: false,
        optionsBuilder: (context, optionsList) => _buildOptions(optionsList),
        allowFullScreen: false,
        showControlsOnInitialize: false,
        subtitle: Subtitles(_formatSubtitles()),
        subtitleBuilder: (context, subtitleText) =>
            _buildSubtitle(subtitleText),
        errorBuilder: (context, errorText) => Container(),
      );
    } catch (exception) {
      _playPauseController.reverse();

      Fluttertoast.showToast(
        msg: somethingWentWrong,
        toastLength: Toast.LENGTH_SHORT,
      );
    }

    // Adding play pause listener to video player controller
    videoPlayerController.addListener(() {
      if (videoPlayerController.value.isPlaying) {
        _playPauseController.forward();
      } else {
        _playPauseController.reverse();
      }
    });

    // Setting sate with chewie controller
    setState(() {});
  }

  Duration _getStartTime() {
    Sequence currentSequence =
        Provider.of<SequenceProvider>(context, listen: false)
            .getCurrentSequence();

    return Duration(
          hours: int.parse(currentSequence.startTime.substring(0, 2)),
          minutes: int.parse(currentSequence.startTime.substring(3, 5)),
          seconds: int.parse(currentSequence.startTime.substring(6, 8)),
          milliseconds: int.parse(currentSequence.startTime.substring(9, 12)),
        ) -
        const Duration(
          seconds: 1,
        );
  }

  Future<void> _buildOptions(optionsList) async {
    await showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              children: [
                ListTile(
                  leading: Icon(optionsList.last.iconData),
                  title: Text(optionsList.last.title),
                  onTap: optionsList.last.onTap,
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(CustomIcons.close),
                  title: const Text("Cancel"),
                  onTap: () {
                    Navigator.pop(context);
                  },
                )
              ],
            ),
          );
        });
  }

  List<Subtitle> _formatSubtitles() {
    final PreviewSubtitle previewSubtitle =
        Provider.of<PreferenceProvider>(context, listen: false)
            .getPreviewSubtitlePreference();

    return widget.subtitle.sequenceList!.map((element) {
      return Subtitle(
        index: element.sequenceNo,
        start: Duration(
          hours: int.parse(element.startTime.substring(0, 2)),
          minutes: int.parse(element.startTime.substring(3, 5)),
          seconds: int.parse(element.startTime.substring(6, 8)),
          milliseconds: int.parse(element.startTime.substring(9, 12)),
        ),
        end: Duration(
          hours: int.parse(element.endTime.substring(0, 2)),
          minutes: int.parse(element.endTime.substring(3, 5)),
          seconds: int.parse(element.endTime.substring(6, 8)),
          milliseconds: int.parse(element.endTime.substring(9, 12)),
        ),
        text: previewSubtitle == PreviewSubtitle.original
            ? element.originalText
            : element.translatedText,
      );
    }).toList();
  }

  Widget _buildSubtitle(String subtitleText) {
    Widget? subtitleView;

    try {
      subtitleView = Html(
        data: subtitleText.replaceAll('\n', '<br>'),
        style: {
          'html': Style(
            textAlign: TextAlign.center,
            textShadow: [
              const Shadow(
                offset: Offset(0.5, 0.5),
                blurRadius: 2.0,
              ),
            ],
            color: Colors.white,
            fontFamily: 'Product Sans',
            fontSize: const FontSize(16),
          ),
          'font': Style(
            fontFamily: 'Product Sans',
            fontSize: const FontSize(16),
          ),
        },
      );
    } catch (exception) {
      subtitleView = const Text(
        "⚠⚠ Error! ⚠⚠",
        style: TextStyle(color: Colors.red),
      );
    }

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: subtitleView,
    );
  }

  Future<void> _showAddVideoDialog() async {
    SubtitleProvider subtitleProvider =
        Provider.of<SubtitleProvider>(context, listen: false);

    String? videoFilePath = await showDialog(
      context: context,
      builder: (context) => AddVideoDialog(subtitle: widget.subtitle),
    );

    if (videoFilePath != null) {
      widget.subtitle.videoPath = videoFilePath;

      try {
        await subtitleProvider.updateVideoPath(widget.subtitle);

        Fluttertoast.showToast(
          msg: videoAdded,
          toastLength: Toast.LENGTH_SHORT,
        );
      } catch (exception) {
        Fluttertoast.showToast(
          msg: videoAddingFailed,
          toastLength: Toast.LENGTH_SHORT,
        );
      }
    }
  }

  Future<void> _removeVideo() async {
    String videoPathTemp = widget.subtitle.videoPath;
    widget.subtitle.videoPath = '';

    // Removing video
    try {
      await Provider.of<SubtitleProvider>(context, listen: false)
          .updateVideoPath(widget.subtitle);

      Fluttertoast.showToast(
        msg: videoRemoved,
        toastLength: Toast.LENGTH_SHORT,
      );
    } catch (exception) {
      widget.subtitle.videoPath = videoPathTemp;

      Fluttertoast.showToast(
        msg: videoRemovingFailed,
        toastLength: Toast.LENGTH_SHORT,
      );
    }

    // Navigating back
    Navigator.pop(context);
  }
}
