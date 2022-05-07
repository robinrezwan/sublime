import 'package:flutter/material.dart';

/// Flutter [TextFromField] does not have a build in undo/redo functionality
/// https://github.com/flutter/flutter/issues/24222
/// Working around with this class for now
/// TODO: 11/15/2021 Change it when the undo/redo functionality gets implemented officially
class UndoRedoManager {
  final List<TextEditingValue> _undoRedoList = [];
  int _currentIndex = -1;
  DateTime _insertTime = DateTime(1970);

  TextEditingValue? _latestTextEditingValue;

  void insert(TextEditingController textEditingController) {
    if (_undoRedoList.isEmpty ||
        _undoRedoList[_currentIndex] != textEditingController.value) {
      if (_insertTime.difference(DateTime.now()).inMilliseconds.abs() > 1000) {
        _insertTime = DateTime.now();
        _currentIndex += 1;

        // Removing unnecessary values
        _undoRedoList.removeRange(_currentIndex, _undoRedoList.length);

        // Storing new value object
        _undoRedoList.add(TextEditingValue(
          text: textEditingController.value.text,
          selection: textEditingController.value.selection,
        ));

        _latestTextEditingValue = null;
      } else {
        // Storing latest value object
        _latestTextEditingValue = TextEditingValue(
          text: textEditingController.value.text,
          selection: textEditingController.value.selection,
        );
      }
    }
  }

  bool undo(TextEditingController textEditingController) {
    if (_currentIndex > 0) {
      if (_latestTextEditingValue != null) {
        _undoRedoList.add(_latestTextEditingValue!);
        _latestTextEditingValue = null;
      }

      _currentIndex -= 1;

      textEditingController.clearComposing();
      textEditingController.value = _undoRedoList[_currentIndex];

      return true;
    }
    return false;
  }

  bool redo(TextEditingController textEditingController) {
    if (_currentIndex < _undoRedoList.length - 1) {
      _currentIndex += 1;

      textEditingController.clearComposing();
      textEditingController.value = _undoRedoList[_currentIndex];

      return true;
    }
    return false;
  }

  void clear() {
    _undoRedoList.clear();
    _currentIndex = -1;
    _insertTime = DateTime(1970);
  }
}
