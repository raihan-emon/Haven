import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import '../models/wallpaper.dart';
import '../services/downloader.dart';
import '../state/favorites.dart';
import '../state/search_controller.dart';

class ViewerScreen extends ConsumerStatefulWidget {
  final ProviderListenable<List<Wallpaper>> source;
  final int initialIndex;
  final VoidCallback? onNearEnd;

  const ViewerScreen({
    super.key,
    required this.source,
    required this.initialIndex,
    this.onNearEnd,
  });

  @override
  ConsumerState<ViewerScreen> createState() => _ViewerScreenState();
}

class _ViewerScreenState extends ConsumerState<ViewerScreen> {
  late final PageController _pc;
  late int _index;
  bool _chrome = true;
  bool _zoomed = false;
  final Map<String, double> _progress = {};

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _pc = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _pc.dispose();
    super.dispose();
  }

  void _toggleChrome() {
    setState(() => _chrome = !_chrome);
    SystemChrome.setEnabledSystemUIMode(
        _chrome ? SystemUiMode.edgeToEdge : SystemUiMode.immersiveSticky);
  }

  void _showInfo(Wallpaper w) => showModalBottomSheet(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (_) => _InfoSheet(w: w),
      );

  Future<void> _download(Wallpaper w) async {
    if (_progress.containsKey(w.id)) return;
    setState(() => _progress[w.id] = 0);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final f = await ref.read(downloaderProvider).download(w, onProgress: (p) {
        if (mounted) setState(() => _progress[w.id] = p);
      });
      messenger.showSnackBar(SnackBar(
        content: Text(f == null
            ? 'Allow "All files access" to save wallpapers'
            : 'Saved to Pictures/Wallhaven'),
      ));
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('Download failed')));
    } finally {
      if (mounted) setState(() => _progress.remove(w.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(widget.source);
    if (items.isEmpty) {
      // e.g. the last favorite was un-hearted while viewing
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
      return const Scaffold(backgroundColor: Colors.black);
    }
    final w = items[_index.clamp(0, items.length - 1)];
    final fav = ref.watch(favoriteIdsProvider.select((s) => s.contains(w.id)));
    final prog = _progress[w.id];
    final btn = IconButton.styleFrom(
      backgroundColor: Colors.black54,
      foregroundColor: Colors.white, // fixes the dark back arrow
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.black,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            PageView.builder(
              controller: _pc,
              physics: _zoomed
                  ? const NeverScrollableScrollPhysics()
                  : const PageScrollPhysics(),
              itemCount: items.length,
              onPageChanged: (i) {
                setState(() {
                  _index = i;
                  _zoomed = false;
                });
                if (i >= items.length - 4) widget.onNearEnd?.call();
              },
              itemBuilder: (_, i) => _ZoomableImage(
                key: ValueKey(items[i].id),
                wallpaper: items[i],
                onTap: _toggleChrome,
                onZoomChanged: (z) {
                  if (z != _zoomed) setState(() => _zoomed = z);
                },
              ),
            ),
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: _chrome ? 1 : 0,
                duration: const Duration(milliseconds: 150),
                child: IgnorePointer(
                  ignoring: !_chrome,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              IconButton.filled(
                                style: btn,
                                icon: const Icon(Icons.arrow_back),
                                onPressed: () => Navigator.pop(context),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${w.resolution}  ·  ${_index + 1}/${items.length}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton.filled(
                                style: btn,
                                iconSize: 28,
                                icon: Icon(
                                  fav ? Icons.favorite : Icons.favorite_border,
                                  color: fav ? Colors.redAccent : Colors.white,
                                ),
                                onPressed: () => ref
                                    .read(favoritesProvider.notifier)
                                    .toggle(w),
                              ),
                              const SizedBox(width: 16),
                              IconButton.filled(
                                style: btn,
                                iconSize: 28,
                                onPressed: prog == null ? () => _download(w) : null,
                                icon: prog == null
                                    ? const Icon(Icons.download)
                                    : SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          value: prog == 0 ? null : prog,
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 16),
                              IconButton.filled(
                                style: btn,
                                iconSize: 28,
                                icon: const Icon(Icons.info_outline,
                                    color: Colors.white),
                                onPressed: () => _showInfo(w),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ZoomableImage extends StatefulWidget {
  final Wallpaper wallpaper;
  final VoidCallback onTap;
  final ValueChanged<bool> onZoomChanged;

  const _ZoomableImage({
    super.key,
    required this.wallpaper,
    required this.onTap,
    required this.onZoomChanged,
  });

  @override
  State<_ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<_ZoomableImage> {
  final _tc = TransformationController();
  Offset _tap = Offset.zero;

  @override
  void dispose() {
    _tc.dispose();
    super.dispose();
  }

  bool get _isZoomed => _tc.value.getMaxScaleOnAxis() > 1.01;

  void _doubleTap() {
    if (_isZoomed) {
      _tc.value = Matrix4.identity();
    } else {
      const s = 2.5;
      // zoom in around the tapped point
      _tc.value = Matrix4(
        s, 0, 0, 0,
        0, s, 0, 0,
        0, 0, 1, 0,
        -_tap.dx * (s - 1), -_tap.dy * (s - 1), 0, 1,
      );
    }
    widget.onZoomChanged(_isZoomed);
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.wallpaper;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onDoubleTapDown: (d) => _tap = d.localPosition,
      onDoubleTap: _doubleTap,
      child: InteractiveViewer(
        transformationController: _tc,
        minScale: 1,
        maxScale: 5,
        onInteractionEnd: (_) => widget.onZoomChanged(_isZoomed),
        child: SizedBox.expand(
          child: CachedNetworkImage(
            imageUrl: w.path,
            fit: BoxFit.contain,
            fadeInDuration: const Duration(milliseconds: 150),
            placeholder: (_, __) => Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                    imageUrl: w.thumbOriginal, fit: BoxFit.contain),
                const Center(
                    child: CircularProgressIndicator(strokeWidth: 2)),
              ],
            ),
            errorWidget: (_, __, ___) => const Center(
              child: Icon(Icons.broken_image, color: Colors.white54, size: 48),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoSheet extends ConsumerWidget {
  final Wallpaper w;
  const _InfoSheet({required this.w});

  String _size(int b) => b >= 1 << 20
      ? '${(b / (1 << 20)).toStringAsFixed(1)} MB'
      : '${(b / 1024).round()} KB';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final d = ref.watch(detailProvider(w.id));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _InfoRow('Resolution', w.resolution),
              _InfoRow('Category', w.category),
              _InfoRow('Purity', w.purity),
              _InfoRow('Views', '${w.views}'),
              _InfoRow('Favorites', '${w.favorites}'),
              const SizedBox(height: 8),
              d.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Could not load tags'),
                ),
                data: (x) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (x.uploader.isNotEmpty) _InfoRow('Uploader', x.uploader),
                    _InfoRow('File',
                        '${x.fileType.replaceFirst('image/', '').toUpperCase()} · ${_size(x.fileSize)}'),
                    if (x.source.isNotEmpty) _InfoRow('Source', x.source),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [for (final t in x.tags) Chip(label: Text(t))],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String k;
  final String v;
  const _InfoRow(this.k, this.v);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 100,
              child: Text(k,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ),
            Expanded(child: Text(v)),
          ],
        ),
      );
}
