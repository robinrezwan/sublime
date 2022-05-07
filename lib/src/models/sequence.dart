class Sequence {
  // Database identifiers
  static const String tabSequence = 'sequence_table';
  static const String colSubtitleId = 'subtitle_id';
  static const String colSequenceId = 'sequence_id';
  static const String colSequenceNo = 'sequence_no';
  static const String colStartTime = 'start_time';
  static const String colEndTime = 'end_time';
  static const String colOriginalText = 'original_text';
  static const String colTranslatedText = 'translated_text';
  static const String colIsCompleted = 'is_completed';

  // Instance variables
  int? subtitleId;
  int? sequenceId;
  int sequenceNo;
  String startTime;
  String endTime;
  String originalText;
  String translatedText;
  bool isCompleted;

  Sequence({
    this.subtitleId,
    this.sequenceId,
    required this.sequenceNo,
    required this.startTime,
    required this.endTime,
    required this.originalText,
    this.translatedText = "",
    this.isCompleted = false,
  });

  factory Sequence.fromString({required String sequenceString}) {
    // Parsing data
    final List<String> lineList = sequenceString.trim().split('\n');

    final int sequenceNo = int.parse(lineList.elementAt(0));

    final List<String> timeCodeList = lineList.elementAt(1).split('-->');
    final String startTime = timeCodeList.first.trim();
    final String endTime = timeCodeList.last.trim();

    final String subtitleText =
        lineList.getRange(2, lineList.length).join('\n').trim();

    // Creating and returning object
    return Sequence(
      sequenceNo: sequenceNo,
      startTime: startTime,
      endTime: endTime,
      originalText: subtitleText,
    );
  }

  // Deserialization
  factory Sequence.fromMap(Map<String, dynamic> map) {
    return Sequence(
      subtitleId: map[colSubtitleId] as int,
      sequenceId: map[colSequenceId] as int,
      sequenceNo: map[colSequenceNo] as int,
      startTime: map[colStartTime] as String,
      endTime: map[colEndTime] as String,
      originalText: map[colOriginalText] as String,
      translatedText: map[colTranslatedText] as String,
      isCompleted: map[colIsCompleted] as int == 1,
    );
  }
}
