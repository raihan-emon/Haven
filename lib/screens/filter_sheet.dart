import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/wallhaven_api.dart';
import '../state/search_controller.dart';
import '../state/settings.dart';

Future<void> showFilterSheet(BuildContext context) => showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const FilterSheet(),
    );

class FilterSheet extends ConsumerStatefulWidget {
  const FilterSheet({super.key});
  @override
  ConsumerState<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<FilterSheet> {
  late SearchParams p;

  @override
  void initState() {
    super.initState();
    p = ref.read(searchProvider).params;
  }

  // "101" style flags; never allow all three off
  String _toggle(String s, int i) {
    final l = s.split('');
    l[i] = l[i] == '1' ? '0' : '1';
    return l.contains('1') ? l.join() : s;
  }

  static const _sorts = {
    'toplist': 'Toplist',
    'date_added': 'Latest',
    'relevance': 'Relevance',
    'random': 'Random',
    'views': 'Views',
    'favorites': 'Favorites',
  };
  static const _ranges = ['1d', '3d', '1w', '1M', '3M', '6M', '1y'];
  static const _res = {
    '': 'Any',
    '1920x1080': '1080p+',
    '2560x1440': '1440p+',
    '3840x2160': '4K+',
  };

  Widget _title(String t) => Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 6),
        child: Text(t, style: Theme.of(context).textTheme.titleSmall),
      );

  @override
  Widget build(BuildContext context) {
    final hasKey = ref.watch(apiKeyProvider).isNotEmpty;

    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 0, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _title('Categories'),
            Wrap(spacing: 8, children: [
              for (final e in ['General', 'Anime', 'People'].asMap().entries)
                FilterChip(
                  label: Text(e.value),
                  selected: p.categories[e.key] == '1',
                  onSelected: (_) => setState(() =>
                      p = p.copyWith(categories: _toggle(p.categories, e.key))),
                ),
            ]),
            _title(hasKey ? 'Purity' : 'Purity (NSFW needs an API key)'),
            Wrap(spacing: 8, children: [
              for (final e in ['SFW', 'Sketchy', 'NSFW'].asMap().entries)
                FilterChip(
                  label: Text(e.value),
                  selected: p.purity[e.key] == '1',
                  onSelected: (e.key == 2 && !hasKey)
                      ? null
                      : (_) => setState(
                          () => p = p.copyWith(purity: _toggle(p.purity, e.key))),
                ),
            ]),
            _title('Sort by'),
            Wrap(spacing: 8, children: [
              for (final e in _sorts.entries)
                ChoiceChip(
                  label: Text(e.value),
                  selected: p.sorting == e.key,
                  onSelected: (_) =>
                      setState(() => p = p.copyWith(sorting: e.key)),
                ),
            ]),
            if (p.sorting == 'toplist') ...[
              _title('Toplist range'),
              Wrap(spacing: 8, children: [
                for (final r in _ranges)
                  ChoiceChip(
                    label: Text(r),
                    selected: (p.topRange ?? '1M') == r,
                    onSelected: (_) =>
                        setState(() => p = p.copyWith(topRange: r)),
                  ),
              ]),
            ],
            _title('Orientation'),
            Wrap(spacing: 8, children: [
              for (final e in {'': 'Any', 'portrait': 'Portrait', 'landscape': 'Landscape'}.entries)
                ChoiceChip(
                  label: Text(e.value),
                  selected: p.ratios == e.key,
                  onSelected: (_) => setState(() => p = p.copyWith(ratios: e.key)),
                ),
            ]),
            _title('Minimum resolution'),
            Wrap(spacing: 8, children: [
              for (final e in _res.entries)
                ChoiceChip(
                  label: Text(e.value),
                  selected: (p.atleast ?? '') == e.key,
                  onSelected: (_) =>
                      setState(() => p = p.copyWith(atleast: e.key)),
                ),
            ]),
            const SizedBox(height: 20),
            Row(children: [
              TextButton(
                onPressed: () => setState(
                    () => p = SearchParams(query: p.query)),
                child: const Text('Reset'),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () {
                  ref.read(searchProvider.notifier).applyParams(p);
                  Navigator.pop(context);
                },
                child: const Text('Apply'),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
