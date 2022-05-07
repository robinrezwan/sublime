import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sublime/src/utilities/extensions/text_theme_extension.dart';

/// Defines the configuration of the overall visual theme for this app.
class CustomThemeData {
  /// Theme color for the entire app
  static const Color _primaryColor = Color(0xFFFF200C);

  /// The light theme for this app.
  static ThemeData light() {
    // Setting system chrome
    setSystemChrome(Brightness.light);

    // Creating theme data
    final ThemeData baseThemeDataLight = ThemeData.light();

    const ColorScheme colorSchemeLight = ColorScheme(
      brightness: Brightness.light,
      primary: _primaryColor,
      onPrimary: Colors.white,
      secondary: _primaryColor,
      onSecondary: Colors.white,
      error: Color(0xFFB00020),
      onError: Colors.white,
      background: Colors.white,
      onBackground: Colors.black,
      surface: Colors.white,
      onSurface: Colors.black,
    );

    const Color iconColor = Color(0xFF212121);

    return ThemeData(
      brightness: Brightness.light,
      colorScheme: colorSchemeLight,
      primaryColor: colorSchemeLight.primary,
      toggleableActiveColor: colorSchemeLight.primary,
      scaffoldBackgroundColor: colorSchemeLight.background,
      iconTheme: baseThemeDataLight.iconTheme.copyWith(color: iconColor),
      appBarTheme: _appBarTheme(baseThemeDataLight, colorSchemeLight).copyWith(
        iconTheme: baseThemeDataLight.iconTheme.copyWith(color: iconColor),
      ),
      textTheme: _textTheme(baseThemeDataLight),
      cardTheme: _cardTheme(baseThemeDataLight),
      dialogTheme: _dialogTheme(baseThemeDataLight),
      bottomSheetTheme: _bottomSheetTheme(baseThemeDataLight),
      popupMenuTheme: _popupMenuTheme(baseThemeDataLight),
      dividerTheme: _dividerTheme(baseThemeDataLight),
      elevatedButtonTheme: _elevatedButtonTheme(),
      outlinedButtonTheme: _outlinedButtonTheme(),
      textButtonTheme: _textButtonTheme(),
      splashFactory: _splashFactory(),
    );
  }

  /// The dark theme for this app
  static ThemeData dark() {
    // Setting system chrome
    setSystemChrome(Brightness.dark);

    // Creating theme data
    final ThemeData baseThemeDataDark = ThemeData.dark();

    const ColorScheme colorSchemeDark = ColorScheme(
      brightness: Brightness.dark,
      primary: _primaryColor,
      onPrimary: Colors.white,
      secondary: _primaryColor,
      onSecondary: Colors.white,
      error: Color(0xFFB00020),
      onError: Colors.white,
      background: Color(0xFF212121),
      onBackground: Colors.white,
      surface: Color(0xFF292929),
      onSurface: Colors.white,
    );

    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: colorSchemeDark,
      primaryColor: colorSchemeDark.primary,
      scaffoldBackgroundColor: colorSchemeDark.background,
      toggleableActiveColor: colorSchemeDark.primary,
      appBarTheme: _appBarTheme(baseThemeDataDark, colorSchemeDark),
      textTheme: _textTheme(baseThemeDataDark),
      cardTheme: _cardTheme(baseThemeDataDark).copyWith(
        color: colorSchemeDark.surface,
      ),
      dialogTheme: _dialogTheme(baseThemeDataDark).copyWith(
        backgroundColor: colorSchemeDark.surface,
      ),
      bottomSheetTheme: _bottomSheetTheme(baseThemeDataDark).copyWith(
        backgroundColor: colorSchemeDark.surface,
      ),
      popupMenuTheme: _popupMenuTheme(baseThemeDataDark).copyWith(
        color: colorSchemeDark.surface,
      ),
      dividerTheme: _dividerTheme(baseThemeDataDark),
      elevatedButtonTheme: _elevatedButtonTheme(),
      outlinedButtonTheme: _outlinedButtonTheme(),
      textButtonTheme: _textButtonTheme(),
      splashFactory: _splashFactory(),
    );
  }

  static void setSystemChrome(Brightness brightness) {
    // Setting orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    // Setting status bar and navigation bar theme
    if (brightness == Brightness.light) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Color(0xFFF0F0F0),
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );
    } else {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Color(0xFF0F0F0F),
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      );
    }
  }

  static AppBarTheme _appBarTheme(
      ThemeData baseThemeData, ColorScheme colorScheme) {
    return baseThemeData.appBarTheme.copyWith(
      elevation: 1,
      color: colorScheme.surface,
      titleTextStyle: TextStyle(
        fontFamily: 'Product Sans',
        fontSize: 20,
        fontFeatures: const [
          FontFeature.disable('calt'),
          FontFeature.disable('clig'),
        ],
        color: colorScheme.onSurface,
      ),
    );
  }

  static TextTheme _textTheme(ThemeData baseThemeData) {
    return baseThemeData.textTheme.applyWith(
      fontFamily: 'Product Sans',
      fontFeatures: const [
        FontFeature.disable('calt'),
        FontFeature.disable('clig'),
      ],
    );
  }

  static CardTheme _cardTheme(ThemeData baseThemeData) {
    return baseThemeData.cardTheme.copyWith(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(8),
        ),
      ),
    );
  }

  static DialogTheme _dialogTheme(ThemeData baseThemeData) {
    return baseThemeData.dialogTheme.copyWith(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
    );
  }

  static BottomSheetThemeData _bottomSheetTheme(ThemeData baseThemeData) {
    return baseThemeData.bottomSheetTheme.copyWith(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
    );
  }

  static PopupMenuThemeData _popupMenuTheme(ThemeData baseThemeData) {
    return baseThemeData.popupMenuTheme.copyWith(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
    );
  }

  static DividerThemeData _dividerTheme(ThemeData baseThemeData) {
    return baseThemeData.dividerTheme.copyWith(
      space: 1,
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        shape: const StadiumBorder(),
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme() {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        shape: const StadiumBorder(),
      ),
    );
  }

  static TextButtonThemeData _textButtonTheme() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        shape: const StadiumBorder(),
      ),
    );
  }

  static InteractiveInkFeatureFactory _splashFactory() {
    return InkRipple.splashFactory;
  }
}

/// Extension for adding custom colors to color scheme
extension ColorSchemeExtension on ColorScheme {
  // Theme aware colors

  Color get objectBackground {
    return brightness == Brightness.light
        ? const Color(0xFFEEEEEE)
        : const Color(0xFF424242);
  }

  Color get onUnselectedTab {
    return brightness == Brightness.light
        ? const Color(0xFF525252)
        : Colors.white;
  }

  // Regular colors

  Color get red => const Color(0xFFFF1010);

  Color get green => const Color(0xFF10BB10);

  Color get yellow => const Color(0xFFFFCC10);
}
