import 'package:flutter/material.dart';
import 'package:sublime/src/database/database_manager.dart';
import 'package:sublime/src/models/sequence.dart';

class SequenceProvider extends ChangeNotifier {
  List<Sequence>? _sequenceList;
  Sequence? _currentSequence;
  bool? _isChanged;

  SequenceProvider();

  Future<List<Sequence>> getAllSequences(int subtitleId) async {
    _sequenceList = await DatabaseManager().selectSequences(subtitleId);
    return _sequenceList ?? [];
  }

  Sequence getCurrentSequence() {
    return _currentSequence!;
  }

  bool getIsChanged() {
    return _isChanged ?? false;
  }

  void setCurrentSequence(Sequence sequence) {
    _currentSequence = sequence;
    _isChanged = false;
    notifyListeners();
  }

  void setIsChanged(bool isChanged) {
    if (_isChanged != isChanged) {
      _isChanged = isChanged;
      notifyListeners();
    }
  }

  Future<void> updateSequence(Sequence sequence) async {
    await DatabaseManager().updateSequence(sequence);

    _isChanged = false;
    notifyListeners();
  }
}
