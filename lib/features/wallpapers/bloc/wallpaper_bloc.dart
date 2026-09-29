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
    on<LoadCoinsEvent>(_onLoadCoins);
    on<EarnCoinFromAdEvent>(_onEarnCoinFromAd);
    on<UnlockWallpaperEvent>(_onUnlockWallpaper);
    on<ClaimDailyStreakEvent>(_onClaimDailyStreak);
    on<LoadNextPageWallpapersEvent>(_onLoadNextPageWallpapers);
  }

  String _getTodayDateString() {
    final now = DateTime.now();
    return "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  String _getYesterdayDateString() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return "${yesterday.year.toString().padLeft(4, '0')}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}";
  }

  Future<void> _onLoadCoins(
    LoadCoinsEvent event,
    Emitter<WallpaperState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final coins = prefs.getInt('user_coin_balance') ?? 10;
      final unlockedList = prefs.getStringList('unlocked_wallpaper_ids') ?? [];
      final savedFavorites = prefs.getStringList('favorite_wallpaper_ids') ?? [];
      final lastClaimDate = prefs.getString('last_streak_claim_date');
      final savedStreakDay = prefs.getInt('streak_day') ?? 1;

      final todayStr = _getTodayDateString();
      final yesterdayStr = _getYesterdayDateString();

      bool isClaimedToday = false;
      int currentStreak = savedStreakDay;

      if (lastClaimDate == todayStr) {
        isClaimedToday = true;
        currentStreak = savedStreakDay;
      } else if (lastClaimDate == yesterdayStr) {
        isClaimedToday = false;
        if (savedStreakDay >= 7) {
          currentStreak = 1;
        } else {
          currentStreak = savedStreakDay + 1;
        }
      } else {
        // Missed a day or first time
        isClaimedToday = false;
        currentStreak = 1;
      }

      emit(state.copyWith(
        coinBalance: coins,
        unlockedWallpaperIds: Set<String>.from(unlockedList),
        favoriteIds: Set<String>.from(savedFavorites),
        streakDay: currentStreak,
        isStreakClaimedToday: isClaimedToday,
        lastStreakClaimDate: lastClaimDate,
      ));
    } catch (_) {}
  }

  Future<void> _onEarnCoinFromAd(
    EarnCoinFromAdEvent event,
    Emitter<WallpaperState> emit,
  ) async {
    final newBalance = state.coinBalance + event.coins;
    emit(state.copyWith(coinBalance: newBalance));

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_coin_balance', newBalance);
    } catch (_) {}
  }

  Future<void> _onUnlockWallpaper(
    UnlockWallpaperEvent event,
    Emitter<WallpaperState> emit,
  ) async {
    if (state.coinBalance >= event.cost) {
      final newBalance = state.coinBalance - event.cost;
      final newUnlocked = Set<String>.from(state.unlockedWallpaperIds)
        ..add(event.wallpaperId);

      emit(state.copyWith(
        coinBalance: newBalance,
        unlockedWallpaperIds: newUnlocked,
      ));

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_coin_balance', newBalance);
        await prefs.setStringList('unlocked_wallpaper_ids', newUnlocked.toList());
      } catch (_) {}
    }
  }

  Future<void> _onClaimDailyStreak(
    ClaimDailyStreakEvent event,
    Emitter<WallpaperState> emit,
  ) async {
    if (state.isStreakClaimedToday) return;

    final rewardCoins = state.streakDay; // Day N gives N coins (Day 7 gives 7 coins)
    final newBalance = state.coinBalance + rewardCoins;
    final todayStr = _getTodayDateString();

    emit(state.copyWith(
      coinBalance: newBalance,
      isStreakClaimedToday: true,
      lastStreakClaimDate: todayStr,
    ));

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_coin_balance', newBalance);
      await prefs.setInt('streak_day', state.streakDay);
      await prefs.setString('last_streak_claim_date', todayStr);
    } catch (_) {}
  }

  Future<void> _onLoadWallpapers(
    LoadWallpapersEvent event,
    Emitter<WallpaperState> emit,
  ) async {
    emit(state.copyWith(isInitialLoading: true));
    add(const LoadCoinsEvent());

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
