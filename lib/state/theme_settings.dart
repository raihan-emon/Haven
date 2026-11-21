import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings.dart';

class ThemeSettings {
  final ThemeMode mode; // system / light / dark
  final bool amoled;
  final bool expressive;

  const ThemeSettings({
    this.mode = ThemeMode.system,
    this.amoled = false,
    this.expressive = true,
  });

  ThemeSettings copyWith({ThemeMode? mode, bool? amoled, bool? expressive}) =>
      ThemeSettings(
        mode: mode ?? this.mode,
        amoled: amoled ?? this.amoled,
        expressive: expressive ?? this.expressive,
      );

  Map<String, dynamic> toJson() =>
      {'mode': mode.index, 'amoled': amoled, 'expressive': expressive};

  factory ThemeSettings.fromJson(Map<String, dynamic> j) => ThemeSettings(
        mode: ThemeMode.values[
            ((j['mode'] as num?)?.toInt() ?? 0).clamp(0, 2)],
        amoled: j['amoled'] as bool? ?? false,
        expressive: j['expressive'] as bool? ?? true,
      );
}

class ThemeNotifier extends StateNotifier<ThemeSettings> {
  final SharedPreferences _p;

  ThemeNotifier(this._p)
      : super(ThemeSettings(
          mode: ThemeMode.values[(_p.getInt('theme_mode') ?? 0).clamp(0, 2)],
          amoled: _p.getBool('theme_amoled') ?? false,
          expressive: _p.getBool('theme_expressive') ?? true,
        ));

  void update(ThemeSettings s) {
    state = s;
    _p.setInt('theme_mode', s.mode.index);
    _p.setBool('theme_amoled', s.amoled);
    _p.setBool('theme_expressive', s.expressive);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeSettings>(
    (ref) => ThemeNotifier(ref.read(prefsProvider)));
