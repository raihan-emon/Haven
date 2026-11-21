import 'package:dio/dio.dart';
import '../models/wallpaper.dart';

class SearchParams {
  final String query;
  final String categories; // 3 chars: general/anime/people e.g. "111"
  final String purity;     // sfw/sketchy/nsfw e.g. "100"
  final String sorting;    // date_added, relevance, random, views, favorites, toplist
  final String order;      // desc / asc
  final String? topRange;  // 1d,3d,1w,1M,3M,6M,1y (for toplist)
  final String? atleast;   // e.g. "1920x1080"
  final String ratios;     // '', 'portrait', 'landscape'

  const SearchParams({
    this.query = '',
    this.categories = '111',
    this.purity = '100',
    this.sorting = 'toplist',
    this.order = 'desc',
    this.topRange,
    this.atleast,
    this.ratios = '',
  });

  SearchParams copyWith({
    String? query, String? categories, String? purity,
    String? sorting, String? order, String? topRange, String? atleast,
    String? ratios,
  }) =>
      SearchParams(
        query: query ?? this.query,
        categories: categories ?? this.categories,
        purity: purity ?? this.purity,
        sorting: sorting ?? this.sorting,
        order: order ?? this.order,
        topRange: topRange ?? this.topRange,
        atleast: atleast ?? this.atleast,
        ratios: ratios ?? this.ratios,
      );
}

class WallhavenApi {
  final Dio _dio;
  String? apiKey;

  WallhavenApi({this.apiKey})
      : _dio = Dio(BaseOptions(
          baseUrl: 'https://wallhaven.cc/api/v1',
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 20),
        ));

  Future<SearchPage> search(SearchParams p, {int page = 1}) async {
    final res = await _dio.get('/search', queryParameters: {
      if (p.query.isNotEmpty) 'q': p.query,
      'categories': p.categories,
      'purity': p.purity,
      'sorting': p.sorting,
      'order': p.order,
      if (p.sorting == 'toplist' && p.topRange != null) 'topRange': p.topRange,
      if (p.atleast != null && p.atleast!.isNotEmpty) 'atleast': p.atleast,
      if (p.ratios.isNotEmpty) 'ratios': p.ratios,
      'page': page,
    }, options: Options(headers: {
      if (apiKey != null && apiKey!.isNotEmpty) 'X-API-Key': apiKey,
    }));

    final data = (res.data['data'] as List)
        .map((e) => Wallpaper.fromJson(e as Map<String, dynamic>))
        .toList();
    final meta = res.data['meta'];
    return SearchPage(data, meta['current_page'], meta['last_page']);
  }

  Future<WallpaperDetail> info(String id) async {
    final res = await _dio.get('/w/$id',
        options: Options(headers: {
          if (apiKey != null && apiKey!.isNotEmpty) 'X-API-Key': apiKey,
        }));
    return WallpaperDetail.fromJson(res.data['data'] as Map<String, dynamic>);
  }
}
