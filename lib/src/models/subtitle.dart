import 'package:sublime/src/models/metadata.dart';
import 'package:sublime/src/models/sequence.dart';

class Subtitle {
  // Database identifiers
  static const String tabSubtitle = 'subtitle_table';
  static const String colSubtitleId = 'subtitle_id';
  static const String colSubtitleName = 'subtitle_name';
  static const String colDateTimeCreated = 'date_time_created';
  static const String colDateTimeModified = 'date_time_modified';
  static const String colCurrentSequenceId = 'current_sequence_id';
  static const String colIsFavorite = 'is_favorite';
  static const String colVideoPath = 'video_path';

  // Instance variables
  int? subtitleId;
  String subtitleName;
  final DateTime dateTimeCreated;
  DateTime dateTimeModified;
  int currentSequenceId;
  bool isFavorite;
  List<Sequence>? sequenceList;
  String videoPath;
  Metadata? metadata;

  Subtitle({
    this.subtitleId,
    required this.subtitleName,
    DateTime? dateTimeCreated,
    DateTime? dateTimeModified,
    this.currentSequenceId = 1,
    this.isFavorite = false,
    this.sequenceList,
    this.videoPath = '',
    this.metadata,
  })  : dateTimeCreated = dateTimeCreated ?? DateTime.now(),
        dateTimeModified = dateTimeModified ?? DateTime.now();

  // Deserialization
  factory Subtitle.fromMap(Map<String, dynamic> map) {
    return Subtitle(
      subtitleId: map[colSubtitleId] as int,
      subtitleName: map[colSubtitleName] as String,
      dateTimeCreated: DateTime.parse(map[colDateTimeCreated] as String),
      dateTimeModified: DateTime.parse(map[colDateTimeModified] as String),
      currentSequenceId: map[colCurrentSequenceId] as int,
      isFavorite: map[colIsFavorite] as int == 1,
      videoPath: map[colVideoPath] as String,
      metadata: Metadata.fromMap(map),
    );
  }
}
