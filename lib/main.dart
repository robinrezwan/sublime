import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sublime/src/pages/home_page.dart';
import 'package:sublime/src/providers/preference_provider.dart';
import 'package:sublime/src/providers/sequence_provider.dart';
import 'package:sublime/src/providers/subtitle_provider.dart';
import 'package:sublime/src/providers/theme_provider.dart';
import 'package:sublime/src/themes/custom_theme_data.dart';
import 'package:sublime/src/utilities/constants.dart';

// Logger
final Logger log = Logger();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Creating preference provider
  final PreferenceProvider prefProvider =
      PreferenceProvider(await SharedPreferences.getInstance());

  // Getting preferences
  final AppTheme themePreference = prefProvider.getThemePreference();
  final SubtitlesSort sortPreference =
      prefProvider.getSubtitlesSortPreference();
  final bool showFavoritesFirstPreference =
      prefProvider.getSubtitlesShowFavoritesFirstPreference();

  // Creating theme provider
  final ThemeProvider themeProvider = ThemeProvider(themePreference);

  // Creating subtitle provider
  final subtitleProvider =
      SubtitleProvider(sortPreference, showFavoritesFirstPreference);

  // Creating sequence provider
  final SequenceProvider sequenceProvider = SequenceProvider();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => prefProvider),
      ChangeNotifierProvider(create: (context) => themeProvider),
      ChangeNotifierProvider(create: (context) => subtitleProvider),
      ChangeNotifierProvider(create: (context) => sequenceProvider),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // FIXME: 1/23/2022 System navigation bar icon color changes back to default
      // when the app is goes to background and comes back to foreground again
      // https://stackoverflow.com/questions/69768956
      // Working around by setting the status bar and navigation bar evey time
      // the app comes to foreground
      // Change it when the issue is resolved
      Brightness? brightness =
          SchedulerBinding.instance?.window.platformBrightness;

      CustomThemeData.setSystemChrome(brightness ?? Brightness.light);
    }
  }

  @override
  void didChangePlatformBrightness() {
    final AppTheme themePreference =
        Provider.of<PreferenceProvider>(context, listen: false)
            .getThemePreference();

    if (themePreference == AppTheme.system) {
      // Resetting app theme if theme preference is set to system default
      Provider.of<ThemeProvider>(context, listen: false)
          .setTheme(themePreference);
    }

    super.didChangePlatformBrightness();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appTitle,
      theme: Provider.of<ThemeProvider>(context).getTheme(),
      home: const HomePage(),
    );
  }
}
