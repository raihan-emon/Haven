import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/wallhaven_api.dart';
import '../models/wallpaper.dart';
import '../state/favorites.dart';
import '../state/layout_settings.dart';
import '../state/search_controller.dart';
import '../state/settings.dart';
import '../state/theme_settings.dart';

class ImportSummary {
  final int newFavorites;
  final bool apiKey;
  final bool layout;
  const ImportSummary(this.newFavorites, this.apiKey, this.layout);

  String get summary {
    final parts = <String>[
      '$newFavorites new favorite${newFavorites == 1 ? '' : 's'}',
      if (apiKey) 'API key',
      if (layout) 'layout',
    ];
    return 'Imported: ${parts.join(', ')}';
  }
}

class BackupService {
  final Ref _ref;
  BackupService(this._ref);

  Map<String, dynamic> _build({required bool includeKey}) => {
        'app': 'HavenDroid',
        'version': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        if (includeKey) 'apiKey': _ref.read(apiKeyProvider),
        'layout': _ref.read(layoutProvider).toJson(),
        'theme': _ref.read(themeProvider).toJson(),
        'favorites':
            _ref.read(favoritesProvider).map((w) => w.toJson()).toList(),
      };

  /// Returns the saved path, or null if the user cancelled.
  Future<String?> export({required bool includeKey}) async {
    final json = const JsonEncoder.withIndent('  ')
        .convert(_build(includeKey: includeKey));
    final d = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    final name =
        'havendroid-backup-${d.year}${two(d.month)}${two(d.day)}.json';
    final uri = await FilePicker.saveFile(
      dialogTitle: 'Save backup',
      fileName: name,
      bytes: Uint8List.fromList(utf8.encode(json)),
    );
    return uri?.toString();
  }

  /// Returns null if the user cancelled. Throws FormatException for bad files.
  Future<ImportSummary?> import() async {
    final file = await FilePicker.pickFile(type: FileType.any);
    if (file == null) return null;

    final bytes = await file.readAsBytes();

    final dynamic data;
    try {
      data = jsonDecode(utf8.decode(bytes));
    } catch (_) {
      throw const FormatException('That is not a HavenDroid backup');
    }
    if (data is! Map<String, dynamic> || data['app'] != 'HavenDroid') {
      throw const FormatException('That is not a HavenDroid backup');
    }

    var keyApplied = false;
    final key = data['apiKey'];
    if (key is String && key.isNotEmpty) {
      await _ref.read(apiKeyProvider.notifier).set(key);
      keyApplied = true;
    }

    var layoutApplied = false;
    final lay = data['layout'];
    if (lay is Map<String, dynamic>) {
      _ref.read(layoutProvider.notifier).update(LayoutSettings.fromJson(lay));
      layoutApplied = true;
    }

    final th = data['theme'];
    if (th is Map<String, dynamic>) {
      _ref.read(themeProvider.notifier).update(ThemeSettings.fromJson(th));
      layoutApplied = true;
    }

    var added = 0;
    final favs = data['favorites'];
    if (favs is List) {
      final list = <Wallpaper>[];
      for (final f in favs) {
        try {
          list.add(Wallpaper.fromStored(f as Map<String, dynamic>));
        } catch (_) {}
      }
      added = _ref.read(favoritesProvider.notifier).merge(list);
    }

    // reload the grid so the new key takes effect
    if (keyApplied) {
      await _ref.read(searchProvider.notifier).applyParams(const SearchParams());
    }
    return ImportSummary(added, keyApplied, layoutApplied);
  }
}

final backupProvider = Provider<BackupService>((ref) => BackupService(ref));
