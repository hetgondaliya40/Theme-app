import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/wallpaper_repository.dart';
import 'wallpaper_event.dart';
import 'wallpaper_state.dart';

class WallpaperBloc extends Bloc<WallpaperEvent, WallpaperState> {
  final WallpaperRepository repository;

  WallpaperBloc({required this.repository}) : super(const WallpaperState()) {
    on<LoadWallpapersEvent>(_onLoadWallpapers);
    on<FilterByCategoryEvent>(_onFilterByCategory);
    on<SearchWallpapersEvent>(_onSearchWallpapers);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
    on<SelectActiveWallpaperEvent>(_onSelectActiveWallpaper);
    on<UpdateClockConfigEvent>(_onUpdateClockConfig);
    on<AddCustomWallpaperEvent>(_onAddCustomWallpaper);
    on<LoadNextPageWallpapersEvent>(_onLoadNextPageWallpapers);
  }

  Future<void> _onLoadWallpapers(
    LoadWallpapersEvent event,
    Emitter<WallpaperState> emit,
  ) async {
    emit(state.copyWith(isInitialLoading: true));


    try {
      final local = await repository.getLocalWallpapers();
      final active = local.isNotEmpty ? local.first : null;
      final clockConfig = active?.defaultClockConfig ?? state.activeClockConfig;

      emit(state.copyWith(
        allWallpapers: local,
        activeWallpaper: active,
        activeClockConfig: clockConfig,
        isInitialLoading: false,
      ));

      add(FilterByCategoryEvent(event.category));
    } catch (e) {
      emit(state.copyWith(
        isInitialLoading: false,
        errorMessage: 'Failed to load wallpapers: $e',
      ));
    }
  }

  Future<void> _onFilterByCategory(
    FilterByCategoryEvent event,
    Emitter<WallpaperState> emit,
  ) async {
    emit(state.copyWith(
      selectedCategory: event.category,
      isLoadingOnline: true,
    ));

    final query = event.category == 'All' ? 'cyberpunk' : event.category;
    try {
      final online = await repository.fetchOnlineWallpapers(query);
      emit(state.copyWith(
        apiWallpapers: online,
        isLoadingOnline: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoadingOnline: false));
    }
  }

  Future<void> _onSearchWallpapers(
    SearchWallpapersEvent event,
    Emitter<WallpaperState> emit,
  ) async {
    emit(state.copyWith(
      searchQuery: event.query,
      isLoadingOnline: event.query.length > 2,
    ));

    if (event.query.length > 2) {
      try {
        final online = await repository.fetchOnlineWallpapers(event.query);
        emit(state.copyWith(
          apiWallpapers: online,
          isLoadingOnline: false,
        ));
      } catch (e) {
        emit(state.copyWith(isLoadingOnline: false));
      }
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavoriteEvent event,
    Emitter<WallpaperState> emit,
  ) async {
    final updatedFavorites = Set<String>.from(state.favoriteIds);
    if (updatedFavorites.contains(event.wallpaperId)) {
      updatedFavorites.remove(event.wallpaperId);
    } else {
      updatedFavorites.add(event.wallpaperId);
    }

    emit(state.copyWith(favoriteIds: updatedFavorites));

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('favorite_wallpaper_ids', updatedFavorites.toList());
    } catch (_) {}
  }

  void _onSelectActiveWallpaper(
    SelectActiveWallpaperEvent event,
    Emitter<WallpaperState> emit,
  ) {
    emit(state.copyWith(
      activeWallpaper: event.wallpaper,
      activeClockConfig: event.wallpaper.defaultClockConfig,
    ));
  }

  void _onUpdateClockConfig(
    UpdateClockConfigEvent event,
    Emitter<WallpaperState> emit,
  ) {
    emit(state.copyWith(activeClockConfig: event.config));
  }

  void _onAddCustomWallpaper(
    AddCustomWallpaperEvent event,
    Emitter<WallpaperState> emit,
  ) {
    final updatedCustom = [event.wallpaper, ...state.customWallpapers];
    emit(state.copyWith(
      customWallpapers: updatedCustom,
      activeWallpaper: event.wallpaper,
      activeClockConfig: event.wallpaper.defaultClockConfig,
    ));
  }

  Future<void> _onLoadNextPageWallpapers(
    LoadNextPageWallpapersEvent event,
    Emitter<WallpaperState> emit,
  ) async {
    if (state.isFetchingMore || state.isLoadingOnline) return;

    emit(state.copyWith(isFetchingMore: true));
    final nextPage = state.currentPage + 1;
    final query = state.searchQuery.isNotEmpty
        ? state.searchQuery
        : (state.selectedCategory == 'All' ? 'cyberpunk' : state.selectedCategory);

    try {
      final newItems = await repository.fetchOnlineWallpapers(query, page: nextPage);
      final existingIds = state.apiWallpapers.map((e) => e.id).toSet();
      final filteredNew = newItems.where((item) => !existingIds.contains(item.id)).toList();

      emit(state.copyWith(
        apiWallpapers: [...state.apiWallpapers, ...filteredNew],
        currentPage: nextPage,
        isFetchingMore: false,
      ));
    } catch (_) {
      emit(state.copyWith(isFetchingMore: false));
    }
  }
}
