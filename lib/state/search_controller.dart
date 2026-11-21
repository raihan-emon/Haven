import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../api/wallhaven_api.dart';
import '../models/wallpaper.dart';
import 'settings.dart';

final apiProvider = Provider<WallhavenApi>(
    (ref) => WallhavenApi(apiKey: ref.watch(apiKeyProvider)));

final detailProvider = FutureProvider.family<WallpaperDetail, String>(
    (ref, id) => ref.watch(apiProvider).info(id));

class SearchState {
  final SearchParams params;
  final List<Wallpaper> items;
  final int page;
  final int lastPage;
  final bool loading;
  final String? error;

  const SearchState({
    this.params = const SearchParams(),
    this.items = const [],
    this.page = 0,
    this.lastPage = 1,
    this.loading = false,
    this.error,
  });

  bool get hasMore => page < lastPage;

  SearchState copyWith({
    SearchParams? params, List<Wallpaper>? items, int? page,
    int? lastPage, bool? loading, String? error, bool clearError = false,
  }) =>
      SearchState(
        params: params ?? this.params,
        items: items ?? this.items,
        page: page ?? this.page,
        lastPage: lastPage ?? this.lastPage,
        loading: loading ?? this.loading,
        error: clearError ? null : (error ?? this.error),
      );
}

class SearchNotifier extends StateNotifier<SearchState> {
  final Ref _ref;
  SearchNotifier(this._ref) : super(const SearchState()) {
    loadNext();
  }

  Future<void> loadNext() async {
    if (state.loading || (state.page != 0 && !state.hasMore)) return;
    state = state.copyWith(loading: true, clearError: true);
    try {
      final res = await _ref.read(apiProvider).search(state.params, page: state.page + 1);
      state = state.copyWith(
        items: [...state.items, ...res.items],
        page: res.currentPage,
        lastPage: res.lastPage,
        loading: false,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: 'Could not load wallpapers');
    }
  }

  Future<void> applyParams(SearchParams p) async {
    state = SearchState(params: p);
    await loadNext();
  }

  Future<void> refresh() => applyParams(state.params);
}

final searchProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) => SearchNotifier(ref));
