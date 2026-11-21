import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/layout_settings.dart';

class LayoutSettingsScreen extends ConsumerWidget {
  const LayoutSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = ref.watch(layoutProvider);
    final n = ref.read(layoutProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Layout')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Grid type'),
            trailing: DropdownButton<GridType>(
              value: l.gridType,
              onChanged: (v) => n.update(l.copyWith(gridType: v)),
              items: const [
                DropdownMenuItem(
                    value: GridType.staggered, child: Text('Staggered')),
                DropdownMenuItem(
                    value: GridType.uniform, child: Text('Uniform')),
              ],
            ),
          ),
          ListTile(
            title: const Text('Column type'),
            trailing: DropdownButton<ColumnMode>(
              value: l.columnMode,
              onChanged: (v) => n.update(l.copyWith(columnMode: v)),
              items: const [
                DropdownMenuItem(
                    value: ColumnMode.adaptive, child: Text('Adaptive')),
                DropdownMenuItem(
                    value: ColumnMode.fixed, child: Text('Fixed')),
              ],
            ),
          ),
          if (l.columnMode == ColumnMode.adaptive)
            ListTile(
              title: Text(
                  'Min. column width: ${l.minColumnPercent}%  (${l.columns} columns)'),
              subtitle: Slider(
                value: l.minColumnPercent.toDouble(),
                min: 10,
                max: 50,
                divisions: 8,
                label: '${l.minColumnPercent}%',
                onChanged: (v) =>
                    n.update(l.copyWith(minColumnPercent: v.round())),
              ),
            )
          else
            ListTile(
              title: Text('Columns: ${l.fixedColumns}'),
              subtitle: Slider(
                value: l.fixedColumns.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                label: '${l.fixedColumns}',
                onChanged: (v) =>
                    n.update(l.copyWith(fixedColumns: v.round())),
              ),
            ),
          SwitchListTile(
            title: const Text('Rounded corners'),
            value: l.rounded,
            onChanged: (v) => n.update(l.copyWith(rounded: v)),
          ),
        ],
      ),
    );
  }
}
