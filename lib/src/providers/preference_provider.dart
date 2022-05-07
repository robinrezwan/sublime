import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppTheme { light, dark, system }
enum SubtitlesSort { modified, created, alphabetically }
enum PreviewSubtitle { original, translated }

class PreferenceProvider extends ChangeNotifier {
  static const String _theme = 'theme';

  static const String _subtitlesSortBy = 'subtitleSortBy';
  static const String _subtitlesShowFavoritesFirst =
      'subtitlesShowFavoritesFirst';

  static const String _previewSubtitle = 'previewSubtitle';
  static const String _translationLanguage = 'translationLanguage';
  static const String _textFormattingColors = 'textFormattingColors';

  // TODO: 2/18/2022 Change default preferences
  static const Map<String, dynamic> _defaultPreferences = {
    _theme: AppTheme.system,
    _subtitlesSortBy: SubtitlesSort.modified,
    _subtitlesShowFavoritesFirst: false,
    _previewSubtitle: 'Translated',
    _translationLanguage: 'Bangla',
  };

  final SharedPreferences _preferences;

  PreferenceProvider(this._preferences);

  // Get and set theme preference

  AppTheme getThemePreference() {
    String? themePreference = _preferences.getString(_theme);

    switch (themePreference) {
      case 'light':
        return AppTheme.light;
      case 'dark':
        return AppTheme.dark;
      default:
        return _defaultPreferences[_theme];
    }
  }

  void setThemePreference(AppTheme value) {
    _preferences.setString(_theme, value.name);

    notifyListeners();
  }

  // Get and set subtitles sort preference

  SubtitlesSort getSubtitlesSortPreference() {
    switch (_preferences.getString(_subtitlesSortBy)) {
      case 'modified':
        return SubtitlesSort.modified;
      case 'created':
        return SubtitlesSort.created;
      case 'alphabetically':
        return SubtitlesSort.alphabetically;
      default:
        return _defaultPreferences[_subtitlesSortBy];
    }
  }

  void setSubtitlesSortPreference(SubtitlesSort value) {
    _preferences.setString(_subtitlesSortBy, value.name);

    notifyListeners();
  }

  // Get and set subtitles show favorites first preference

  bool getSubtitlesShowFavoritesFirstPreference() {
    return _preferences.getBool(_subtitlesShowFavoritesFirst) ??
        _defaultPreferences[_subtitlesShowFavoritesFirst];
  }

  void setSubtitlesShowFavoritesFirstPreference(bool value) {
    _preferences.setBool(_subtitlesShowFavoritesFirst, value);

    notifyListeners();
  }

  // Get and set preview subtitle preference

  PreviewSubtitle getPreviewSubtitlePreference() {
    switch (_preferences.getString(_previewSubtitle)) {
      case 'original':
        return PreviewSubtitle.original;
      case 'translated':
        return PreviewSubtitle.translated;
      default:
        return _defaultPreferences[_previewSubtitle];
    }
  }

  void setPreviewSubtitlePreference(PreviewSubtitle value) {
    _preferences.setString(_previewSubtitle, value.name);

    notifyListeners();
  }

  // Get and set translation language preference

  String getTranslationLanguagePreference() {
    return _preferences.getString(_translationLanguage) ??
        _defaultPreferences[_translationLanguage];
  }

  void setTranslationLanguagePreference(String value) {
    _preferences.setString(_translationLanguage, value);

    notifyListeners();
  }

  // Get and set text formatting color preference

  List<Color> getTextFormattingColorsPreference() {
    List<String> value =
        _preferences.getStringList(_textFormattingColors) ?? [];
    return value.map((element) => Color(int.parse(element))).toList();
  }

  void setTextFormattingColorsPreference(List<Color> value) {
    _preferences.setStringList(_textFormattingColors,
        value.map((element) => element.value.toString()).toList());

    notifyListeners();
  }
}
