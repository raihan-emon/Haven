import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/favorites.dart';
import '../state/layout_settings.dart';
import '../widgets/wallpaper_grid.dart';
import 'viewer_screen.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(favoritesProvider);
    final layout = ref.watch(layoutProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Favorites (${items.length})')),
      body: items.isEmpty
          ? const Center(child: Text('Tap the heart on a wallpaper to save it here'))
          : CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 100),
                  sliver: WallpaperSliverGrid(
                    items: items,
                    layout: layout,
                    onOpen: (i) => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ViewerScreen(
                          source: favoritesProvider,
                          initialIndex: i,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
