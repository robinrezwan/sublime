class Metadata {
  // Database identifiers
  static const String colSubtitleId = 'subtitle_id';
  static const String colNoOfSequences = 'no_of_sequences';
  static const String colNoOfCompletedSequences = 'no_of_completed_sequences';
  static const String colNoOfDraftSequences = 'no_of_draft_sequences';

  // Instance variables
  int subtitleId;
  int noOfSequences;
  int noOfCompletedSequences;
  int noOfDraftSequences;

  Metadata._({
    required this.subtitleId,
    required this.noOfSequences,
    required this.noOfCompletedSequences,
    required this.noOfDraftSequences,
  });

  // Deserialization
  factory Metadata.fromMap(Map<String, dynamic> map) {
    return Metadata._(
      subtitleId: map[colSubtitleId] as int,
      noOfSequences: map[colNoOfSequences] as int,
      noOfCompletedSequences: map[colNoOfCompletedSequences] as int,
      noOfDraftSequences: map[colNoOfDraftSequences] as int,
    );
  }
}
