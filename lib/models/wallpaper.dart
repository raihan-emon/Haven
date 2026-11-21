class Wallpaper {
  final String id;
  final String url;        // page URL
  final String path;       // full image
  final String thumbSmall;
  final String thumbLarge;
  final String thumbOriginal;
  final int dimX;
  final int dimY;
  final String resolution;
  final String purity;
  final String category;
  final int favorites;
  final int views;

  double get aspect => (dimX == 0 || dimY == 0) ? 1.6 : dimX / dimY;

  Wallpaper({
    required this.id,
    required this.url,
    required this.path,
    required this.thumbSmall,
    required this.thumbLarge,
    required this.thumbOriginal,
    required this.dimX,
    required this.dimY,
    required this.resolution,
    required this.purity,
    required this.category,
    required this.favorites,
    required this.views,
  });

  factory Wallpaper.fromJson(Map<String, dynamic> j) => Wallpaper(
        id: j['id'],
        url: j['url'],
        path: j['path'],
        thumbSmall: j['thumbs']['small'],
        thumbLarge: j['thumbs']['large'],
        thumbOriginal: j['thumbs']['original'] ?? j['thumbs']['large'],
        dimX: (j['dimension_x'] as num?)?.toInt() ?? 0,
        dimY: (j['dimension_y'] as num?)?.toInt() ?? 0,
        resolution: j['resolution'] ?? '',
        purity: j['purity'] ?? 'sfw',
        category: j['category'] ?? '',
        favorites: j['favorites'] ?? 0,
        views: j['views'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'url': url,
        'path': path,
        'thumbSmall': thumbSmall,
        'thumbLarge': thumbLarge,
        'thumbOriginal': thumbOriginal,
        'resolution': resolution,
        'purity': purity,
        'category': category,
        'favorites': favorites,
        'views': views,
        'dimX': dimX,
        'dimY': dimY,
      };

  factory Wallpaper.fromStored(Map<String, dynamic> j) => Wallpaper(
        id: j['id'],
        url: j['url'],
        path: j['path'],
        thumbSmall: j['thumbSmall'],
        thumbLarge: j['thumbLarge'],
        thumbOriginal: j['thumbOriginal'],
        resolution: j['resolution'] ?? '',
        purity: j['purity'] ?? 'sfw',
        category: j['category'] ?? '',
        favorites: j['favorites'] ?? 0,
        views: j['views'] ?? 0,
        dimX: j['dimX'] ?? 0,
        dimY: j['dimY'] ?? 0,
      );
}

class SearchPage {
  final List<Wallpaper> items;
  final int currentPage;
  final int lastPage;
  SearchPage(this.items, this.currentPage, this.lastPage);
}

class WallpaperDetail {
  final String uploader;
  final int fileSize;
  final String fileType;
  final String source;
  final List<String> tags;

  WallpaperDetail({
    required this.uploader,
    required this.fileSize,
    required this.fileType,
    required this.source,
    required this.tags,
  });

  factory WallpaperDetail.fromJson(Map<String, dynamic> j) => WallpaperDetail(
        uploader: j['uploader']?['username'] ?? '',
        fileSize: (j['file_size'] as num?)?.toInt() ?? 0,
        fileType: j['file_type'] ?? '',
        source: j['source'] ?? '',
        tags: ((j['tags'] as List?) ?? [])
            .map((t) => t['name'] as String)
            .toList(),
      );
}
