import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../state/layout_settings.dart';
import '../state/search_controller.dart';
import '../widgets/floating_nav.dart';
import '../widgets/wallpaper_card.dart';
import 'filter_sheet.dart';
import 'viewer_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});
  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _scroll = ScrollController();
  final _text = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 800) {
        ref.read(searchProvider.notifier).loadNext();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _text.dispose();
    super.dispose();
  }

  void _submit(String q) {
    FocusScope.of(context).unfocus();
    final n = ref.read(searchProvider.notifier);
    n.applyParams(ref.read(searchProvider).params.copyWith(query: q.trim()));
  }

  void _open(int i) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ViewerScreen(
          source: searchProvider.select((s) => s.items),
          initialIndex: i,
          onNearEnd: () => ref.read(searchProvider.notifier).loadNext(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(searchProvider);
    final layout = ref.watch(layoutProvider);
    final navVisible = ref.watch(navVisibleProvider);
    final top = MediaQuery.of(context).padding.top;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      floatingActionButton: AnimatedPadding(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.only(bottom: navVisible ? kNavSpace : 0),
        child: FloatingActionButton(
          onPressed: () => showFilterSheet(context),
          child: const Icon(Icons.filter_alt),
        ),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            edgeOffset: top + 72,
            onRefresh: () => ref.read(searchProvider.notifier).refresh(),
            child: _body(s, layout, top + 80),
          ),
          Positioned(
            top: top + 8,
            left: 12,
            right: 12,
            child: IgnorePointer(
              ignoring: !navVisible,
              child: AnimatedSlide(
                offset: navVisible ? Offset.zero : const Offset(0, -1.8),
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                child: AnimatedOpacity(
                  opacity: navVisible ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Material(
                    elevation: 0,
                    color: cs.surfaceContainerHigh,
                    surfaceTintColor: Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                    child: TextField(
                      controller: _text,
                      textInputAction: TextInputAction.search,
                      onSubmitted: _submit,
                      decoration: const InputDecoration(
                        hintText: 'Search wallhaven.cc',
                        prefixIcon: Icon(Icons.search),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body(SearchState s, LayoutSettings l, double topPad) {
    if (s.items.isEmpty && s.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (s.items.isEmpty) {
      return ListView(children: [
        SizedBox(height: topPad + 120),
        Center(
          child: s.error != null
              ? TextButton(
                  onPressed: () =>
                      ref.read(searchProvider.notifier).refresh(),
                  child: Text('${s.error}. Tap to retry'),
                )
              : const Text('No results'),
        ),
      ]);
    }

    final radius = BorderRadius.circular(l.rounded ? 16 : 0);
    const gap = 8.0;

    final Widget grid;
    if (l.gridType == GridType.staggered) {
      grid = SliverMasonryGrid.count(
        crossAxisCount: l.columns,
        mainAxisSpacing: gap,
        crossAxisSpacing: gap,
        childCount: s.items.length,
        itemBuilder: (_, i) {
          final w = s.items[i];
          return WallpaperCard(
            wallpaper: w,
            imageUrl: w.thumbOriginal,
            aspect: w.aspect.clamp(0.5, 2.0),
            radius: radius,
            onTap: () => _open(i),
          );
        },
      );
    } else {
      grid = SliverGrid.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: l.columns,
          mainAxisSpacing: gap,
          crossAxisSpacing: gap,
          childAspectRatio: 0.7,
        ),
        itemCount: s.items.length,
        itemBuilder: (_, i) {
          final w = s.items[i];
          return WallpaperCard(
            wallpaper: w,
            imageUrl: w.thumbLarge,
            radius: radius,
            onTap: () => _open(i),
          );
        },
      );
    }

    return CustomScrollView(
      controller: _scroll,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(8, topPad, 8, 90),
          sliver: grid,
        ),
        if (s.loading)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(bottom: 100),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}
