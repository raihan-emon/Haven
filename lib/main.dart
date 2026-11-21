import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_shell.dart';
import 'state/settings.dart';
import 'state/theme_settings.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(ProviderScope(
    overrides: [prefsProvider.overrideWithValue(prefs)],
    child: const App(),
  ));
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Haven',
      themeMode: t.mode,
      theme: buildTheme(
          brightness: Brightness.light, amoled: false, expressive: t.expressive),
      darkTheme: buildTheme(
          brightness: Brightness.dark,
          amoled: t.amoled,
          expressive: t.expressive),
      builder: (context, child) {
        // keeps status/navigation bar icons readable in light and dark
        final cs = Theme.of(context).colorScheme;
        final dark = Theme.of(context).brightness == Brightness.dark;
        final icons = dark ? Brightness.light : Brightness.dark;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: icons,
            systemNavigationBarColor: cs.surface,
            systemNavigationBarIconBrightness: icons,
          ),
          child: child!,
        );
      },
      home: const HomeShell(),
    );
  }
}
