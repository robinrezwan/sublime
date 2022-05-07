import 'package:flutter/material.dart';
import 'package:sublime/src/database/database_manager.dart';
import 'package:sublime/src/models/subtitle.dart';
import 'package:sublime/src/providers/preference_provider.dart';

class SubtitleProvider extends ChangeNotifier {
  List<Subtitle>? _subtitleList;
  Subtitle? _currentSubtitle;
  SubtitlesSort? _sortPreference;
  bool? _showFavoritesFirst;

  SubtitleProvider(
      SubtitlesSort sortPreference, bool favoritesFirstPreference) {
    setSortPreference(sortPreference);
    setShowFavoritesFirst(favoritesFirstPreference);
  }

  Future<Subtitle?> getSubtitle(int subtitleId) async {
    return await DatabaseManager().selectSubtitle(subtitleId);
  }

  Future<List<Subtitle>> getAllSubtitles() async {
    final Map<String, bool> sortBy = {};

    if (_showFavoritesFirst!) {
      sortBy[Subtitle.colIsFavorite] = false;
    }

    switch (_sortPreference!) {
      case SubtitlesSort.modified:
        sortBy[Subtitle.colDateTimeModified] = false;
        break;
      case SubtitlesSort.created:
        sortBy[Subtitle.colDateTimeCreated] = false;
        break;
      case SubtitlesSort.alphabetically:
        sortBy[Subtitle.colSubtitleName] = true;
        sortBy[Subtitle.colDateTimeModified] = false;
        break;
    }

    _subtitleList = await DatabaseManager().selectSubtitles(sortBy);
    return _subtitleList ?? [];
  }

  Subtitle getCurrentSubtitle() {
    return _currentSubtitle!;
  }

  SubtitlesSort getSortPreference() {
    return _sortPreference!;
  }

  bool getShowFavoritesFirst() {
    return _showFavoritesFirst!;
  }

  void setCurrentSubtitle(Subtitle subtitle) {
    if (_currentSubtitle != subtitle) {
      _currentSubtitle = subtitle;
      notifyListeners();
    }
  }

  void updateCurrentSubtitleMetadata(bool iscCompleted) {
    iscCompleted
        ? _currentSubtitle!.metadata!.noOfCompletedSequences += 1
        : _currentSubtitle!.metadata!.noOfDraftSequences += 1;

    notifyListeners();
  }

  void setSortPreference(SubtitlesSort sortPreference) {
    if (sortPreference != _sortPreference) {
      _sortPreference = sortPreference;
      notifyListeners();
    }
  }

  void setShowFavoritesFirst(bool showFavoritesFirst) {
    if (_showFavoritesFirst != showFavoritesFirst) {
      _showFavoritesFirst = showFavoritesFirst;
      notifyListeners();
    }
  }

  Future<int> addSubtitle(Subtitle subtitle) async {
    final int subtitleId = await DatabaseManager().insertSubtitle(subtitle);
    notifyListeners();

    return subtitleId;
  }

  Future<void> renameSubtitle(Subtitle subtitle) async {
    await DatabaseManager().updateSubtitleName(subtitle);
    notifyListeners();
  }

  Future<void> updateIsFavorite(Subtitle subtitle) async {
    await DatabaseManager().updateSubtitleIsFavorite(subtitle);
    notifyListeners();
  }

  Future<void> updateVideoPath(Subtitle subtitle) async {
    await DatabaseManager().updateSubtitleVideoPath(subtitle);
    notifyListeners();
  }

  Future<void> deleteSubtitle(int subtitleId) async {
    await DatabaseManager().deleteSubtitle(subtitleId);
    notifyListeners();
  }

  void reload() {
    notifyListeners();
  }
}
