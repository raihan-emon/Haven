import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wallpaper.dart';
import '../state/favorites.dart';

class WallpaperCard extends ConsumerWidget {
  final Wallpaper wallpaper;
  final String imageUrl;
  final double? aspect; // null = fill the space the grid gives
  final BorderRadius radius;
  final VoidCallback? onTap;

  const WallpaperCard({
    super.key,
    required this.wallpaper,
    required this.imageUrl,
    required this.radius,
    this.aspect,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fav = ref.watch(
        favoriteIdsProvider.select((s) => s.contains(wallpaper.id)));

    final content = Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          memCacheWidth: 600,
          placeholder: (_, __) => const ColoredBox(color: Colors.black12),
          errorWidget: (_, __, ___) =>
              const Center(child: Icon(Icons.broken_image)),
        ),
        Positioned(
          right: 8,
          bottom: 8,
          child: Material(
            color: Colors.black54,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => ref.read(favoritesProvider.notifier).toggle(wallpaper),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(
                  fav ? Icons.favorite : Icons.favorite_border,
                  color: fav ? Colors.redAccent : Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ],
    );

    return ClipRRect(
      borderRadius: radius,
      child: GestureDetector(
        onTap: onTap,
        child: aspect == null
            ? content
            : AspectRatio(aspectRatio: aspect!, child: content),
      ),
    );
  }
}
