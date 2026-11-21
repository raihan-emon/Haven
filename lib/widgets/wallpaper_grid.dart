import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/wallpaper.dart';
import '../state/layout_settings.dart';
import 'wallpaper_card.dart';

class WallpaperSliverGrid extends StatelessWidget {
  final List<Wallpaper> items;
  final LayoutSettings layout;
  final void Function(int index) onOpen;

  const WallpaperSliverGrid({
    super.key,
    required this.items,
    required this.layout,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(layout.rounded ? 16 : 0);
    const gap = 8.0;

    if (layout.gridType == GridType.staggered) {
      return SliverMasonryGrid.count(
        crossAxisCount: layout.columns,
        mainAxisSpacing: gap,
        crossAxisSpacing: gap,
        childCount: items.length,
        itemBuilder: (_, i) => WallpaperCard(
          wallpaper: items[i],
          imageUrl: items[i].thumbOriginal,
          aspect: items[i].aspect.clamp(0.5, 2.0),
          radius: radius,
          onTap: () => onOpen(i),
        ),
      );
    }
    return SliverGrid.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: layout.columns,
        mainAxisSpacing: gap,
        crossAxisSpacing: gap,
        childAspectRatio: 0.7,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => WallpaperCard(
        wallpaper: items[i],
        imageUrl: items[i].thumbLarge,
        radius: radius,
        onTap: () => onOpen(i),
      ),
    );
  }
}
