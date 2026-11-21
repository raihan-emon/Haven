import 'package:flutter/material.dart';

const kSeedColor = Color(0xFFFF7A1A); // the orange from the icon

ThemeData buildTheme({
  required Brightness brightness,
  required bool amoled,
  required bool expressive,
}) {
  var scheme =
      ColorScheme.fromSeed(seedColor: kSeedColor, brightness: brightness);

  if (brightness == Brightness.dark && amoled) {
    scheme = scheme.copyWith(
      surface: Colors.black,
      surfaceContainerLowest: Colors.black,
      surfaceContainerLow: const Color(0xFF080808),
      surfaceContainer: const Color(0xFF101010),
      surfaceContainerHigh: const Color(0xFF181818),
      surfaceContainerHighest: const Color(0xFF212121),
    );
  }

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
  );
  final t = base.textTheme;

  return base.copyWith(
    textTheme: expressive
        ? t.copyWith(
            titleLarge: t.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            titleMedium: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            titleSmall: t.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            labelLarge: t.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          )
        : t,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      scrolledUnderElevation: 0,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(expressive ? 28 : 16),
      ),
    ),
    chipTheme: expressive ? const ChipThemeData(shape: StadiumBorder()) : null,
    bottomSheetTheme: BottomSheetThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(expressive ? 40 : 28),
        ),
      ),
    ),
  );
}
