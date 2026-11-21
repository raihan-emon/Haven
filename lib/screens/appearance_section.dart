import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/theme_settings.dart';

class AppearanceSection extends ConsumerWidget {
  const AppearanceSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeProvider);
    final n = ref.read(themeProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text('Appearance',
              style: Theme.of(context).textTheme.titleSmall),
        ),
        SegmentedButton<ThemeMode>(
          segments: const [
            ButtonSegment(
                value: ThemeMode.system,
                icon: Icon(Icons.brightness_auto),
                label: Text('Auto')),
            ButtonSegment(
                value: ThemeMode.light,
                icon: Icon(Icons.light_mode),
                label: Text('Light')),
            ButtonSegment(
                value: ThemeMode.dark,
                icon: Icon(Icons.dark_mode),
                label: Text('Dark')),
          ],
          selected: {t.mode},
          onSelectionChanged: (s) => n.update(t.copyWith(mode: s.first)),
        ),
        const SizedBox(height: 4),
        SwitchListTile(
          title: const Text('Pure black (AMOLED)'),
          subtitle: const Text('Applies in dark mode'),
          value: t.amoled,
          onChanged: t.mode == ThemeMode.light
              ? null
              : (v) => n.update(t.copyWith(amoled: v)),
        ),
        SwitchListTile(
          title: const Text('Expressive style'),
          subtitle:
              const Text('Rounder shapes, bolder text, pill navigation'),
          value: t.expressive,
          onChanged: (v) => n.update(t.copyWith(expressive: v)),
        ),
      ],
    );
  }
}
