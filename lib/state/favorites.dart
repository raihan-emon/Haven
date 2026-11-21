import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wallpaper.dart';
import 'settings.dart';

class FavoritesNotifier extends StateNotifier<List<Wallpaper>> {
  final SharedPreferences _p;
  FavoritesNotifier(this._p) : super(_load(_p));

  static List<Wallpaper> _load(SharedPreferences p) {
    final out = <Wallpaper>[];
    for (final s in p.getStringList('fav_items') ?? <String>[]) {
      try {
        out.add(Wallpaper.fromStored(jsonDecode(s) as Map<String, dynamic>));
      } catch (_) {}
    }
    return out;
  }

  void _save() => _p.setStringList(
      'fav_items', state.map((x) => jsonEncode(x.toJson())).toList());

  void toggle(Wallpaper w) {
    final exists = state.any((x) => x.id == w.id);
    state = exists
        ? state.where((x) => x.id != w.id).toList()
        : [w, ...state]; // newest first
    _save();
  }

  /// Adds wallpapers that aren't saved yet. Returns how many were new.
  int merge(List<Wallpaper> incoming) {
    final have = state.map((w) => w.id).toSet();
    final fresh = incoming.where((w) => have.add(w.id)).toList();
    if (fresh.isEmpty) return 0;
    state = [...state, ...fresh];
    _save();
    return fresh.length;
  }
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, List<Wallpaper>>(
        (ref) => FavoritesNotifier(ref.read(prefsProvider)));

final favoriteIdsProvider = Provider<Set<String>>(
    (ref) => ref.watch(favoritesProvider).map((w) => w.id).toSet());
