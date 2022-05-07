import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:sublime/src/providers/preference_provider.dart';
import 'package:sublime/src/themes/custom_theme_data.dart';

class ThemeProvider extends ChangeNotifier {
  // static const String light = 'light';
  // static const String dark = 'dark';
  // static const String system = 'system';

  ThemeData? _themeData;

  ThemeProvider(AppTheme theme) {
    setTheme(theme);
  }

  ThemeData getTheme() {
    return _themeData!;
  }

  void setTheme(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        _themeData = CustomThemeData.light();
        break;
      case AppTheme.dark:
        _themeData = CustomThemeData.dark();
        break;
      default:
        _themeData = SchedulerBinding.instance?.window.platformBrightness ==
                Brightness.light
            ? CustomThemeData.light()
            : CustomThemeData.dark();
    }

    notifyListeners();
  }
}
