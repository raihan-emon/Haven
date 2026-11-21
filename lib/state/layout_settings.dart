import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings.dart';

enum GridType { staggered, uniform }
enum ColumnMode { adaptive, fixed }

class LayoutSettings {
  final GridType gridType;
  final ColumnMode columnMode;
  final int minColumnPercent; // 10..50
  final int fixedColumns; // 1..5
  final bool rounded;

  const LayoutSettings({
    this.gridType = GridType.staggered,
    this.columnMode = ColumnMode.adaptive,
    this.minColumnPercent = 40,
    this.fixedColumns = 2,
    this.rounded = true,
  });

  int get columns => columnMode == ColumnMode.adaptive
      ? (100 / minColumnPercent).floor().clamp(1, 6)
      : fixedColumns;

  LayoutSettings copyWith({
    GridType? gridType,
    ColumnMode? columnMode,
    int? minColumnPercent,
    int? fixedColumns,
    bool? rounded,
  }) =>
      LayoutSettings(
        gridType: gridType ?? this.gridType,
        columnMode: columnMode ?? this.columnMode,
        minColumnPercent: minColumnPercent ?? this.minColumnPercent,
        fixedColumns: fixedColumns ?? this.fixedColumns,
        rounded: rounded ?? this.rounded,
      );

  Map<String, dynamic> toJson() => {
        'gridType': gridType.index,
        'columnMode': columnMode.index,
        'minColumnPercent': minColumnPercent,
        'fixedColumns': fixedColumns,
        'rounded': rounded,
      };

  factory LayoutSettings.fromJson(Map<String, dynamic> j) => LayoutSettings(
        gridType: GridType.values[
            ((j['gridType'] as num?)?.toInt() ?? 0)
                .clamp(0, GridType.values.length - 1)],
        columnMode: ColumnMode.values[
            ((j['columnMode'] as num?)?.toInt() ?? 0)
                .clamp(0, ColumnMode.values.length - 1)],
        minColumnPercent:
            ((j['minColumnPercent'] as num?)?.toInt() ?? 40).clamp(10, 50),
        fixedColumns: ((j['fixedColumns'] as num?)?.toInt() ?? 2).clamp(1, 5),
        rounded: j['rounded'] as bool? ?? true,
      );
}

class LayoutNotifier extends StateNotifier<LayoutSettings> {
  final SharedPreferences _p;

  LayoutNotifier(this._p)
      : super(LayoutSettings(
          gridType: GridType
              .values[(_p.getInt('grid_type') ?? 0).clamp(0, 1)],
          columnMode: ColumnMode
              .values[(_p.getInt('column_mode') ?? 0).clamp(0, 1)],
          minColumnPercent: _p.getInt('min_col_pct') ?? 40,
          fixedColumns: _p.getInt('fixed_cols') ?? 2,
          rounded: _p.getBool('rounded') ?? true,
        ));

  void update(LayoutSettings s) {
    state = s;
    _p.setInt('grid_type', s.gridType.index);
    _p.setInt('column_mode', s.columnMode.index);
    _p.setInt('min_col_pct', s.minColumnPercent);
    _p.setInt('fixed_cols', s.fixedColumns);
    _p.setBool('rounded', s.rounded);
  }
}

final layoutProvider = StateNotifierProvider<LayoutNotifier, LayoutSettings>(
    (ref) => LayoutNotifier(ref.read(prefsProvider)));
